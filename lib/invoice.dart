import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for DateFormat to check overdue status
import 'invoice_review.dart'; // Import the invoice review screen
import 'invoice_generate.dart'; // Import the generate invoice screen

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  int _selectedTabIndex = 0; // 0: All, 1: Unpaid, 2: Paid

  final List<Map<String, dynamic>> _allInvoices = [
    {
      'id': '#12345',
      'customerName': 'Sarah Miller',
      'customerAddress': '123 Main St, Anytown, USA',
      'customerEmail': 'sarah.m@example.com',
      'amount': '\$500.00',
      'issueDate': '2024-07-01',
      'dueDate': '2024-07-31',
      'status': 'Unpaid', // Approved, awaiting payment
      'subtotal': '\$450.00',
      'taxes': '\$50.00',
      'discount': '\$0.00',
      'totalAmount': '\$500.00',
      'notes': 'Payment due by end of month.',
      'lineItems': [
        {'itemName': 'Product A', 'quantity': '2', 'unitPrice': '\$100.00', 'totalPrice': '\$200.00'},
        {'itemName': 'Service B', 'quantity': '1', 'unitPrice': '\$250.00', 'totalPrice': '\$250.00'},
      ],
      'payments': [], // Changed from 'paidAmount' to 'payments' list
    },
    {
      'id': '#12346',
      'customerName': 'David Lee',
      'customerAddress': '456 Oak Ave, Villagetown, USA',
      'customerEmail': 'david.l@example.com',
      'amount': '\$750.00',
      'issueDate': '2024-06-15',
      'dueDate': '2024-07-15',
      'status': 'Paid', // This will be derived from payments
      'subtotal': '\$700.00',
      'taxes': '\$50.00',
      'discount': '\$0.00',
      'totalAmount': '\$750.00',
      'notes': 'Thank you for your business!',
      'lineItems': [
        {'itemName': 'Consulting Hours', 'quantity': '5', 'unitPrice': '\$150.00', 'totalPrice': '\$750.00'},
      ],
      'payments': [ // Example of multiple payments
        {'date': '2024-07-10', 'amount': '500.00'},
        {'date': '2024-07-14', 'amount': '250.00'},
      ],
    },
    {
      'id': '#12347',
      'customerName': 'Emily Chen',
      'customerAddress': '789 Pine Ln, Cityville, USA',
      'customerEmail': 'emily.c@example.com',
      'amount': '\$300.00',
      'issueDate': '2024-07-10',
      'dueDate': '2024-08-10',
      'status': 'Draft', // Needs internal approval
      'subtotal': '\$280.00',
      'taxes': '\$20.00',
      'discount': '\$0.00',
      'totalAmount': '\$300.00',
      'notes': '',
      'lineItems': [
        {'itemName': 'Web Design', 'quantity': '1', 'unitPrice': '\$300.00', 'totalPrice': '\$300.00'},
      ],
      'payments': [],
    },
    {
      'id': '#12348',
      'customerName': 'Michael Brown',
      'customerAddress': '101 Elm St, Townsville, USA',
      'customerEmail': 'michael.b@example.com',
      'amount': '\$1200.00',
      'issueDate': '2024-07-05',
      'dueDate': '2024-08-05',
      'status': 'Rejected', // Was rejected, needs correction/re-approval
      'subtotal': '\$1100.00',
      'taxes': '\$100.00',
      'discount': '\$0.00',
      'totalAmount': '\$1200.00',
      'notes': 'Requires client approval before sending.',
      'lineItems': [
        {'itemName': 'Software License', 'quantity': '1', 'unitPrice': '\$1000.00', 'totalPrice': '\$1000.00'},
        {'itemName': 'Support Package', 'quantity': '1', 'unitPrice': '\$200.00', 'totalPrice': '\$200.00'},
      ],
      'payments': [],
    },
  ];

  List<Map<String, dynamic>> _filteredInvoices = [];

  @override
  void initState() {
    super.initState();
    _filterInvoices();
  }

  // Helper to calculate total paid amount from payments list
  double _calculateTotalPaid(List<dynamic> payments) {
    return payments.fold(0.0, (sum, payment) => sum + (double.tryParse(payment['amount'] ?? '0.0') ?? 0.0));
  }

  // Helper to get total invoice amount
  double _getInvoiceTotalAmount(Map<String, dynamic> invoice) {
    return double.tryParse(invoice['totalAmount']?.replaceAll('\$', '') ?? '0.0') ?? 0.0;
  }

  // Helper to check if the invoice is overdue (used internally here)
  bool _isOverdue(Map<String, dynamic> invoice) {
    final totalAmount = _getInvoiceTotalAmount(invoice);
    final paidAmount = _calculateTotalPaid(invoice['payments'] ?? []);

    if (invoice['dueDate'] != null && paidAmount < totalAmount) {
      try {
        final dueDate = DateFormat('yyyy-MM-dd').parse(invoice['dueDate']);
        final now = DateTime.now();
        return dueDate.isBefore(DateTime(now.year, now.month, now.day));
      } catch (e) {
        print('Error parsing due date for overdue check: $e');
      }
    }
    return false;
  }

  // Helper to determine invoice status based on payments and internal status
  String _getInvoiceStatus(Map<String, dynamic> invoice) {
    if (invoice['status'] == 'Draft' || invoice['status'] == 'Rejected') {
      return invoice['status']; // Draft/Rejected are primary statuses
    }

    final totalAmount = _getInvoiceTotalAmount(invoice);
    final paidAmount = _calculateTotalPaid(invoice['payments'] ?? []);

    if (paidAmount >= totalAmount && totalAmount > 0) {
      return 'Paid';
    } else if (paidAmount > 0 && paidAmount < totalAmount) {
      return 'Partially Paid';
    } else if (_isOverdue(invoice)) { // Check for overdue if unpaid
      return 'Overdue';
    } else {
      return 'Unpaid';
    }
  }

  void _filterInvoices() {
    setState(() {
      if (_selectedTabIndex == 0) { // All
        _filteredInvoices = List.from(_allInvoices);
      } else if (_selectedTabIndex == 1) { // Unpaid (includes Draft, Rejected, Unpaid, Partially Paid, Overdue)
        _filteredInvoices = _allInvoices.where((invoice) {
          final status = _getInvoiceStatus(invoice);
          return status != 'Paid';
        }).toList();
      } else if (_selectedTabIndex == 2) { // Paid
        _filteredInvoices = _allInvoices.where((invoice) {
          final status = _getInvoiceStatus(invoice);
          return status == 'Paid';
        }).toList();
      }
    });
  }

  void _addNewInvoice(Map<String, dynamic> newInvoice) {
    setState(() {
      newInvoice['payments'] = []; // New invoices start with no payments
      newInvoice['status'] = 'Draft'; // New invoices start as Draft
      _allInvoices.add(newInvoice);
      _filterInvoices();
    });
  }

  void _updateInvoice(Map<String, dynamic> updatedInvoice) {
    setState(() {
      final index = _allInvoices.indexWhere((invoice) => invoice['id'] == updatedInvoice['id']);
      if (index != -1) {
        _allInvoices[index] = updatedInvoice;
      }
      _filterInvoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: const Text(
          'Invoices',
          style: TextStyle(color: Color(0xFF0D141C)),
        ),
        centerTitle: true,
        actions: const [],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF49739C),
                  size: 24,
                ),
                hintText: 'Search invoices',
                hintStyle: const TextStyle(color: Color(0xFF49739C)),
                filled: true,
                fillColor: const Color(0xFFE7EDF4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 16),
                _buildTab(context, 'All', 0),
                const SizedBox(width: 32),
                _buildTab(context, 'Unpaid', 1),
                const SizedBox(width: 32),
                _buildTab(context, 'Paid', 2),
              ],
            ),
          ),
          const Divider(color: Color(0xFFCEDBE8), height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredInvoices.length,
              itemBuilder: (context, index) {
                final invoice = _filteredInvoices[index];
                return _buildInvoiceItem(invoice);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GenerateInvoiceScreen(
                onInvoiceGenerated: _addNewInvoice,
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF3D98F4),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildTab(BuildContext context, String title, int index) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
          _filterInvoices();
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? const Color(0xFF0D141C) : const Color(0xFF49739C),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.015,
            ),
          ),
          Container(
            height: 3,
            width: 40,
            color: isSelected ? const Color(0xFF3D98F4) : Colors.transparent,
            margin: const EdgeInsets.only(top: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceItem(Map<String, dynamic> invoice) {
    // Determine the status for this specific invoice item
    final String status = _getInvoiceStatus(invoice);

    // Define icon and background color based on status
    IconData iconData;
    Color iconColor = Colors.white; // Default icon color
    Color backgroundColor;

    switch (status) {
      case 'Paid':
        iconData = Icons.check_circle_outline;
        backgroundColor = Colors.green.shade600; // Green for paid
        break;
      case 'Partially Paid':
        iconData = Icons.payments_outlined;
        backgroundColor = Colors.orange.shade600; // Orange for partially paid
        break;
      case 'Overdue':
        iconData = Icons.warning_amber_rounded;
        backgroundColor = Colors.red.shade600; // Red for overdue
        break;
      case 'Draft':
        iconData = Icons.edit_note;
        backgroundColor = Colors.blueGrey.shade400; // Grey-blue for draft
        break;
      case 'Rejected':
        iconData = Icons.cancel_outlined;
        backgroundColor = Colors.red.shade400; // Lighter red for rejected
        break;
      case 'Unpaid': // Approved but not paid yet
      default:
        iconData = Icons.receipt_long;
        backgroundColor = const Color(0xFF3D98F4); // Blue for unpaid/pending
        break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InvoiceReviewScreen(
              invoiceData: invoice,
              onInvoiceUpdated: _updateInvoice,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: backgroundColor, // Dynamic background color
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                iconData, // Dynamic icon
                color: iconColor, // Dynamic icon color
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice['id']!,
                    style: const TextStyle(
                      color: Color(0xFF0D141C),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Customer: ${invoice['customerName']!}',
                    style: const TextStyle(
                      color: Color(0xFF49739C),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              invoice['amount']!, // This is the total amount, not paid
              style: const TextStyle(
                color: Color(0xFF0D141C),
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}