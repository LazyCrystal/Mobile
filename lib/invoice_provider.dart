import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_assignment/models/invoice_model.dart';
import 'package:intl/intl.dart';

class InvoiceProvider with ChangeNotifier {
  List<Invoice> _invoices = [];
  List<Customer> _customers = [];
  bool _isLoading = false;
  String _searchQuery = '';
  InvoiceStatus? _filterStatus;
  PaymentStatus? _filterPaymentStatus;

  List<Invoice> get invoices {
    var filtered = _invoices.where((invoice) {
      bool matchesSearch = _searchQuery.isEmpty ||
          invoice.invoiceNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          invoice.customer.name.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesStatus = _filterStatus == null || invoice.status == _filterStatus;
      bool matchesPaymentStatus = _filterPaymentStatus == null ||
          invoice.paymentStatus == _filterPaymentStatus;

      return matchesSearch && matchesStatus && matchesPaymentStatus;
    }).toList();

    // Sort by issue date (newest first)
    filtered.sort((a, b) => b.issueDate.compareTo(a.issueDate));
    return filtered;
  }

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  InvoiceStatus? get filterStatus => _filterStatus;
  PaymentStatus? get filterPaymentStatus => _filterPaymentStatus;

  // Statistics
  int get totalInvoices => _invoices.length;
  int get pendingInvoices => _invoices.where((i) => i.status == InvoiceStatus.pending).length;
  int get approvedInvoices => _invoices.where((i) => i.status == InvoiceStatus.approved).length;
  int get paidInvoices => _invoices.where((i) => i.paymentStatus == PaymentStatus.paid).length;
  int get overdueInvoices => _invoices.where((i) => i.isOverdue).length;

  double get totalAmount => _invoices.fold(0.0, (sum, invoice) => sum + invoice.total);
  double get paidAmount => _invoices
      .where((i) => i.paymentStatus == PaymentStatus.paid)
      .fold(0.0, (sum, invoice) => sum + invoice.total);
  double get outstandingAmount => totalAmount - paidAmount;

  InvoiceProvider() {
    _loadData();
  }

  // Search and Filter
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(InvoiceStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setPaymentStatusFilter(PaymentStatus? status) {
    _filterPaymentStatus = status;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterStatus = null;
    _filterPaymentStatus = null;
    notifyListeners();
  }

  // Invoice CRUD Operations
  Future<void> addInvoice(Invoice invoice) async {
    _isLoading = true;
    notifyListeners();

    _invoices.add(invoice);
    await _saveData();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateInvoice(Invoice updatedInvoice) async {
    _isLoading = true;
    notifyListeners();

    final index = _invoices.indexWhere((invoice) => invoice.id == updatedInvoice.id);
    if (index != -1) {
      _invoices[index] = updatedInvoice;
      await _saveData();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteInvoice(String invoiceId) async {
    _isLoading = true;
    notifyListeners();

    _invoices.removeWhere((invoice) => invoice.id == invoiceId);
    await _saveData();

    _isLoading = false;
    notifyListeners();
  }

  Invoice? getInvoiceById(String id) {
    try {
      return _invoices.firstWhere((invoice) => invoice.id == id);
    } catch (e) {
      return null;
    }
  }

  // Approval Workflow
  Future<void> submitForApproval(String invoiceId) async {
    final invoice = getInvoiceById(invoiceId);
    if (invoice != null && invoice.status == InvoiceStatus.draft) {
      await updateInvoice(invoice.copyWith(status: InvoiceStatus.pending));
    }
  }

  Future<void> approveInvoice(String invoiceId, String approvedBy) async {
    final invoice = getInvoiceById(invoiceId);
    if (invoice != null && invoice.status == InvoiceStatus.pending) {
      await updateInvoice(invoice.copyWith(
        status: InvoiceStatus.approved,
        approvedBy: approvedBy,
        approvedDate: DateTime.now(),
      ));
    }
  }

  Future<void> rejectInvoice(String invoiceId, String reason) async {
    final invoice = getInvoiceById(invoiceId);
    if (invoice != null && invoice.status == InvoiceStatus.pending) {
      await updateInvoice(invoice.copyWith(
        status: InvoiceStatus.draft,
        notes: '${invoice.notes}\n\nRejected: $reason',
      ));
    }
  }

  Future<void> sendInvoice(String invoiceId) async {
    final invoice = getInvoiceById(invoiceId);
    if (invoice != null && invoice.status == InvoiceStatus.approved) {
      await updateInvoice(invoice.copyWith(status: InvoiceStatus.sent));
    }
  }

  // Payment Management
  Future<void> recordPayment({
    required String invoiceId,
    required double amount,
    required String paymentMethod,
    String? paymentReference,
  }) async {
    final invoice = getInvoiceById(invoiceId);
    if (invoice == null) return;

    final newPaidAmount = invoice.paidAmount + amount;
    PaymentStatus newPaymentStatus;

    if (newPaidAmount >= invoice.total) {
      newPaymentStatus = PaymentStatus.paid;
    } else if (newPaidAmount > 0) {
      newPaymentStatus = PaymentStatus.partiallyPaid;
    } else {
      newPaymentStatus = PaymentStatus.unpaid;
    }

    await updateInvoice(invoice.copyWith(
      paidAmount: newPaidAmount,
      paymentStatus: newPaymentStatus,
      paymentMethod: paymentMethod,
      paymentReference: paymentReference ?? '',
      paidDate: newPaymentStatus == PaymentStatus.paid ? DateTime.now() : null,
    ));
  }

  Future<void> refundPayment(String invoiceId, double refundAmount) async {
    final invoice = getInvoiceById(invoiceId);
    if (invoice == null) return;

    final newPaidAmount = (invoice.paidAmount - refundAmount).clamp(0.0, double.infinity);
    PaymentStatus newPaymentStatus;

    if (newPaidAmount == 0) {
      newPaymentStatus = PaymentStatus.refunded;
    } else if (newPaidAmount < invoice.total) {
      newPaymentStatus = PaymentStatus.partiallyPaid;
    } else {
      newPaymentStatus = PaymentStatus.paid;
    }

    await updateInvoice(invoice.copyWith(
      paidAmount: newPaidAmount,
      paymentStatus: newPaymentStatus,
      paidDate: newPaymentStatus == PaymentStatus.paid ? invoice.paidDate : null,
    ));
  }

  // Customer Management
  Future<void> addCustomer(Customer customer) async {
    _customers.add(customer);
    await _saveData();
    notifyListeners();
  }

  Future<void> updateCustomer(Customer updatedCustomer) async {
    final index = _customers.indexWhere((customer) => customer.id == updatedCustomer.id);
    if (index != -1) {
      _customers[index] = updatedCustomer;
      await _saveData();
      notifyListeners();
    }
  }

  Customer? getCustomerById(String id) {
    try {
      return _customers.firstWhere((customer) => customer.id == id);
    } catch (e) {
      return null;
    }
  }

  // Invoice Number Generation
  String generateInvoiceNumber() {
    final now = DateTime.now();
    final yearMonth = DateFormat('yyyyMM').format(now);
    final count = _invoices.where((i) => i.invoiceNumber.startsWith('INV-$yearMonth')).length + 1;
    return 'INV-$yearMonth-${count.toString().padLeft(3, '0')}';
  }

  // Data Persistence
  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load invoices
      final invoicesJson = prefs.getString('invoices');
      if (invoicesJson != null) {
        final List<dynamic> invoicesList = json.decode(invoicesJson);
        _invoices = invoicesList.map((json) => Invoice.fromJson(json)).toList();
      }

      // Load customers
      final customersJson = prefs.getString('customers');
      if (customersJson != null) {
        final List<dynamic> customersList = json.decode(customersJson);
        _customers = customersList.map((json) => Customer.fromJson(json)).toList();
      }

      // Load sample data if empty
      if (_invoices.isEmpty) {
        await _loadSampleData();
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      await _loadSampleData();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save invoices
      final invoicesJson = json.encode(_invoices.map((invoice) => invoice.toJson()).toList());
      await prefs.setString('invoices', invoicesJson);

      // Save customers
      final customersJson = json.encode(_customers.map((customer) => customer.toJson()).toList());
      await prefs.setString('customers', customersJson);
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  Future<void> _loadSampleData() async {
    // Sample customers
    final sampleCustomers = [
      Customer(name: 'Sarah Miller', email: 'sarah@example.com', phone: '+1-555-0101'),
      Customer(name: 'David Lee', email: 'david@example.com', phone: '+1-555-0102'),
      Customer(name: 'Emily Chen', email: 'emily@example.com', phone: '+1-555-0103'),
      Customer(name: 'Michael Brown', email: 'michael@example.com', phone: '+1-555-0104'),
      Customer(name: 'Jessica Wilson', email: 'jessica@example.com', phone: '+1-555-0105'),
    ];

    _customers.addAll(sampleCustomers);

    // Sample invoices
    final now = DateTime.now();
    final sampleInvoices = [
      Invoice(
        invoiceNumber: generateInvoiceNumber(),
        customer: sampleCustomers[0],
        items: [
          InvoiceItem(description: 'Web Development Service', quantity: 20, unitPrice: 75.0),
          InvoiceItem(description: 'UI/UX Design', quantity: 10, unitPrice: 100.0),
        ],
        issueDate: now.subtract(const Duration(days: 15)),
        dueDate: now.subtract(const Duration(days: 15)).add(const Duration(days: 30)),
        status: InvoiceStatus.sent,
        paymentStatus: PaymentStatus.unpaid,
        taxRate: 8.5,
      ),
      Invoice(
        invoiceNumber: generateInvoiceNumber(),
        customer: sampleCustomers[1],
        items: [
          InvoiceItem(description: 'Mobile App Development', quantity: 40, unitPrice: 85.0),
        ],
        issueDate: now.subtract(const Duration(days: 10)),
        dueDate: now.subtract(const Duration(days: 10)).add(const Duration(days: 30)),
        status: InvoiceStatus.sent,
        paymentStatus: PaymentStatus.paid,
        paidAmount: 3400.0,
        paidDate: now.subtract(const Duration(days: 2)),
        paymentMethod: 'Bank Transfer',
        taxRate: 8.5,
      ),
      Invoice(
        invoiceNumber: generateInvoiceNumber(),
        customer: sampleCustomers[2],
        items: [
          InvoiceItem(description: 'Consulting Services', quantity: 8, unitPrice: 150.0),
        ],
        issueDate: now.subtract(const Duration(days: 5)),
        dueDate: now.subtract(const Duration(days: 5)).add(const Duration(days: 30)),
        status: InvoiceStatus.pending,
        paymentStatus: PaymentStatus.unpaid,
        taxRate: 8.5,
      ),
      Invoice(
        invoiceNumber: generateInvoiceNumber(),
        customer: sampleCustomers[3],
        items: [
          InvoiceItem(description: 'Software License', quantity: 1, unitPrice: 2500.0),
          InvoiceItem(description: 'Support Package', quantity: 12, unitPrice: 200.0),
        ],
        issueDate: now.subtract(const Duration(days: 45)),
        dueDate: now.subtract(const Duration(days: 45)).add(const Duration(days: 30)),
        status: InvoiceStatus.sent,
        paymentStatus: PaymentStatus.unpaid,
        taxRate: 8.5,
      ),
      Invoice(
        invoiceNumber: generateInvoiceNumber(),
        customer: sampleCustomers[4],
        items: [
          InvoiceItem(description: 'E-commerce Setup', quantity: 1, unitPrice: 1800.0),
        ],
        issueDate: now.subtract(const Duration(days: 3)),
        dueDate: now.subtract(const Duration(days: 3)).add(const Duration(days: 30)),
        status: InvoiceStatus.approved,
        paymentStatus: PaymentStatus.unpaid,
        approvedBy: 'Admin',
        approvedDate: now.subtract(const Duration(days: 1)),
        taxRate: 8.5,
      ),
    ];

    _invoices.addAll(sampleInvoices);
    await _saveData();
  }

  // Export/Import functionality
  String exportInvoicesAsJson() {
    return json.encode({
      'invoices': _invoices.map((invoice) => invoice.toJson()).toList(),
      'customers': _customers.map((customer) => customer.toJson()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> importInvoicesFromJson(String jsonString) async {
    try {
      final data = json.decode(jsonString);

      if (data['invoices'] != null) {
        final List<dynamic> invoicesList = data['invoices'];
        _invoices = invoicesList.map((json) => Invoice.fromJson(json)).toList();
      }

      if (data['customers'] != null) {
        final List<dynamic> customersList = data['customers'];
        _customers = customersList.map((json) => Customer.fromJson(json)).toList();
      }

      await _saveData();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error importing data: $e');
      return false;
    }
  }
}