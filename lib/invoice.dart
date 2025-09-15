import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for DateFormat to check overdue status
import 'invoice_review.dart'; // Import the invoice review screen
import 'invoice_generate.dart'; // Import the generate invoice screen
import 'firebase_invoice_service.dart'; // Import Firebase service
import 'base_scaffold.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  String _selectedStatus = 'All'; // Track selected status filter
  List<Map<String, dynamic>> _allInvoices = [];
  List<Map<String, dynamic>> _filteredInvoices = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Define all possible invoice statuses
  final List<String> _allStatuses = [
    'All',
    'Paid',
    'Unpaid',
    'Partially Paid',
    'Overdue',
    'Draft',
    'Rejected'
  ];

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load invoices from Firebase
  Future<void> _loadInvoices() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final invoices = await FirebaseInvoiceService.getAllInvoices();
      setState(() {
        _allInvoices = invoices;
        _isLoading = false;
      });
      _filterInvoices();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading invoices: $e')),
        );
      }
    }
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
      List<Map<String, dynamic>> filtered = List.from(_allInvoices);

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        filtered = filtered.where((invoice) {
          final customerName = invoice['customerName']?.toString().toLowerCase() ?? '';
          final invoiceId = invoice['id']?.toString().toLowerCase() ?? '';
          final searchLower = _searchQuery.toLowerCase();
          return customerName.contains(searchLower) || invoiceId.contains(searchLower);
        }).toList();
      }

      // Apply status filter
      if (_selectedStatus == 'All') {
        _filteredInvoices = filtered;
      } else {
        _filteredInvoices = filtered.where((invoice) {
          final status = _getInvoiceStatus(invoice);
          return status == _selectedStatus;
        }).toList();
      }
    });
  }

  // Helper method to get count of invoices for each status
  int _getStatusCount(String status) {
    if (status == 'All') {
      return _allInvoices.length;
    }
    return _allInvoices.where((invoice) {
      final invoiceStatus = _getInvoiceStatus(invoice);
      return invoiceStatus == status;
    }).length;
  }

  Future<void> _addNewInvoice(Map<String, dynamic> newInvoice) async {
    try {
      // Add to Firebase
      final invoiceId = await FirebaseInvoiceService.createInvoice(newInvoice);
      newInvoice['id'] = invoiceId;

      setState(() {
        _allInvoices.insert(0, newInvoice); // Add to beginning of list
      });
      _filterInvoices();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating invoice: $e')),
        );
      }
    }
  }

  Future<void> _updateInvoice(Map<String, dynamic> updatedInvoice) async {
    try {
      // Update in Firebase
      await FirebaseInvoiceService.updateInvoice(updatedInvoice['id'], updatedInvoice);

      setState(() {
        final index = _allInvoices.indexWhere((invoice) => invoice['id'] == updatedInvoice['id']);
        if (index != -1) {
          _allInvoices[index] = updatedInvoice;
        }
      });
      _filterInvoices();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating invoice: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Invoices',
      currentIndex: 2,
      onRefresh: _loadInvoices,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _filterInvoices();
              },
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
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFF49739C)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                    _filterInvoices();
                  },
                )
                    : null,
              ),
            ),
          ),
          _buildStatusFilterSection(),
          const Divider(color: Color(0xFFCEDBE8), height: 1),
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3D98F4)),
              ),
            )
                : _filteredInvoices.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'No invoices found matching "$_searchQuery"'
                        : 'No invoices found',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                  if (_searchQuery.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                        _filterInvoices();
                      },
                      child: const Text('Clear search'),
                    ),
                  ],
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadInvoices,
              color: const Color(0xFF3D98F4),
              child: ListView.builder(
                itemCount: _filteredInvoices.length,
                itemBuilder: (context, index) {
                  final invoice = _filteredInvoices[index];
                  return _buildInvoiceItem(invoice);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0D141C),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _allStatuses.map((status) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildStatusChip(status),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final bool isSelected = _selectedStatus == status;
    final int count = _getStatusCount(status);
    final Color statusColor = _getStatusColor(status);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
          _filterInvoices();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? statusColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? statusColor : const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: statusColor.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            if (isSelected) const SizedBox(width: 6),
            Text(
              status,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF0D141C),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return const Color(0xFF4CAF50);
      case 'Unpaid':
        return const Color(0xFF3D98F4);
      case 'Partially Paid':
        return const Color(0xFFFF9800);
      case 'Overdue':
        return const Color(0xFFF44336);
      case 'Draft':
        return const Color(0xFF9E9E9E);
      case 'Rejected':
        return const Color(0xFFF44336);
      case 'All':
      default:
        return const Color(0xFF3D98F4);
    }
  }

  Widget _buildInvoiceItem(Map<String, dynamic> invoice) {
    // Determine the status for this specific invoice item
    final String status = _getInvoiceStatus(invoice);

    // Define icon and background color based on status
    IconData iconData;
    Color iconColor = Colors.white; // Default icon color
    Color backgroundColor = _getStatusColor(status);

    switch (status) {
      case 'Paid':
        iconData = Icons.check_circle_outline;
        break;
      case 'Partially Paid':
        iconData = Icons.payments_outlined;
        break;
      case 'Overdue':
        iconData = Icons.warning_amber_rounded;
        break;
      case 'Draft':
        iconData = Icons.edit_note;
        break;
      case 'Rejected':
        iconData = Icons.cancel_outlined;
        break;
      case 'Unpaid': // Approved but not paid yet
      default:
        iconData = Icons.receipt_long;
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
                    invoice['invoiceId'] ?? invoice['id'] ?? 'N/A',
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