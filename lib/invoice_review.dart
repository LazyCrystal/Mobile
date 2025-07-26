import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'invoice_billing.dart'; // Import the new billing records screen

// Define a callback type for when an invoice is updated
typedef OnInvoiceUpdated = void Function(Map<String, dynamic> updatedInvoice);

class InvoiceReviewScreen extends StatefulWidget {
  // The invoice data to be displayed and reviewed.
  final Map<String, dynamic> invoiceData;
  final OnInvoiceUpdated onInvoiceUpdated; // New callback

  const InvoiceReviewScreen({
    super.key,
    required this.invoiceData,
    required this.onInvoiceUpdated, // Required for the new callback
  });

  @override
  _InvoiceReviewScreenState createState() => _InvoiceReviewScreenState();
}

class _InvoiceReviewScreenState extends State<InvoiceReviewScreen> {
  // Local state for the invoice status, allowing it to be updated
  // within this screen (e.g., after approval/rejection or managing payments).
  late String _currentStatus;
  late List<dynamic> _currentPayments; // To manage payments locally

  @override
  void initState() {
    super.initState();
    // Initialize current status and payments from the passed invoice data.
    _currentStatus = widget.invoiceData['status'] ?? 'Draft';
    _currentPayments = List.from(widget.invoiceData['payments'] ?? []);
  }

  // Helper to get total invoice amount
  double _getInvoiceTotalAmount() {
    return double.tryParse(widget.invoiceData['totalAmount']?.replaceAll('\$', '') ?? '0.0') ?? 0.0;
  }

  // Helper to calculate total paid amount from payments list
  double _calculateTotalPaid() {
    return _currentPayments.fold(0.0, (sum, payment) => sum + (double.tryParse(payment['amount'] ?? '0.0') ?? 0.0));
  }

  // Helper to determine invoice status based on payments
  String _getDerivedStatus() {
    if (_currentStatus == 'Draft' || _currentStatus == 'Rejected') {
      return _currentStatus; // Draft/Rejected are primary statuses
    }

    final totalAmount = _getInvoiceTotalAmount();
    final paidAmount = _calculateTotalPaid();

    if (paidAmount >= totalAmount && totalAmount > 0) {
      return 'Paid';
    } else if (paidAmount > 0 && paidAmount < totalAmount) {
      return 'Partially Paid';
    } else if (_isOverdue()) { // Check for overdue if unpaid
      return 'Overdue';
    } else {
      return 'Unpaid';
    }
  }

  // Helper to check if the invoice is overdue
  bool _isOverdue() {
    // Check if the invoice is not fully paid and its due date has passed.
    final totalAmount = _getInvoiceTotalAmount();
    final paidAmount = _calculateTotalPaid();

    if (widget.invoiceData['dueDate'] != null && paidAmount < totalAmount) {
      try {
        final dueDate = DateFormat('yyyy-MM-dd').parse(widget.invoiceData['dueDate']);
        final now = DateTime.now();
        return dueDate.isBefore(DateTime(now.year, now.month, now.day));
      } catch (e) {
        print('Error parsing due date for overdue check: $e');
      }
    }
    return false;
  }

  // Method to update invoice data from external calls (e.g., billing records screen)
  void _updateInvoiceFromChild(Map<String, dynamic> updatedInvoice) {
    setState(() {
      _currentStatus = updatedInvoice['status'];
      _currentPayments = List.from(updatedInvoice['payments'] ?? []);
    });
    // Also propagate the update to the parent (InvoiceScreen)
    widget.onInvoiceUpdated(updatedInvoice);
  }

  // Dialog for approving invoice
  void _showApproveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Approve Invoice?'),
          content: const Text('Are you sure you want to approve this invoice?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF49739C))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D98F4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Approve', style: TextStyle(color: Colors.white)),
              onPressed: () {
                setState(() {
                  _currentStatus = 'Unpaid'; // Approved means it's now awaiting payment
                  // Clear payments on approval if it was previously rejected/draft
                  _currentPayments = [];
                  widget.invoiceData['status'] = _currentStatus;
                  widget.invoiceData['payments'] = _currentPayments; // Update original data
                  widget.onInvoiceUpdated(widget.invoiceData);
                });
                Navigator.of(context).pop(); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invoice approved successfully! Status: Unpaid')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Dialog for rejecting invoice with reason input
  void _showRejectDialog(BuildContext context) {
    String rejectReason = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Reject Invoice'),
          content: TextField(
            onChanged: (value) {
              rejectReason = value;
            },
            decoration: InputDecoration(
              hintText: 'Reason for rejection (required)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 3,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF49739C))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD92D20), // Red color for reject
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Reject', style: TextStyle(color: Colors.white)),
              onPressed: () {
                if (rejectReason.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please provide a reason for rejection.')),
                  );
                  return;
                }
                setState(() {
                  _currentStatus = 'Rejected';
                  _currentPayments = []; // Clear payments on rejection
                  widget.invoiceData['status'] = _currentStatus;
                  widget.invoiceData['payments'] = _currentPayments; // Update original data
                  widget.onInvoiceUpdated(widget.invoiceData);
                });
                Navigator.of(context).pop(); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Invoice rejected. Reason: $rejectReason')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayStatus = _getDerivedStatus(); // Get the derived status for display

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: Text(
          'Invoice ${widget.invoiceData['id']}',
          style: const TextStyle(color: Color(0xFF0D141C)),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D141C)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice Summary
            _buildSectionTitle('Invoice Summary'),
            _buildInfoRow('Invoice ID:', widget.invoiceData['id']),
            _buildInfoRow('Status:', displayStatus), // Use displayStatus
            _buildInfoRow('Issue Date:', widget.invoiceData['issueDate']),
            _buildInfoRow('Due Date:', widget.invoiceData['dueDate']),
            _buildInfoRow('Total Amount:', widget.invoiceData['totalAmount']),
            _buildInfoRow('Amount Paid:', '\$${_calculateTotalPaid().toStringAsFixed(2)}'),
            _buildInfoRow('Remaining Due:', '\$${(_getInvoiceTotalAmount() - _calculateTotalPaid()).toStringAsFixed(2)}', isBold: true),
            const SizedBox(height: 20),

            // Customer Information
            _buildSectionTitle('Customer Information'),
            _buildInfoRow('Name:', widget.invoiceData['customerName']),
            _buildInfoRow('Address:', widget.invoiceData['customerAddress']),
            _buildInfoRow('Email:', widget.invoiceData['customerEmail']),
            const SizedBox(height: 20),

            // Line Items
            _buildSectionTitle('Line Items'),
            if (widget.invoiceData['lineItems'] is List)
              ..._buildLineItems(widget.invoiceData['lineItems']),
            const SizedBox(height: 20),

            // Financial Summary
            _buildSectionTitle('Financial Summary'),
            _buildInfoRow('Subtotal:', widget.invoiceData['subtotal']),
            _buildInfoRow('Taxes:', widget.invoiceData['taxes']),
            _buildInfoRow('Discount:', widget.invoiceData['discount']),
            _buildInfoRow('Total Due:', widget.invoiceData['totalAmount'], isBold: true),
            const SizedBox(height: 20),

            // Notes/Comments
            if (widget.invoiceData['notes'] != null && widget.invoiceData['notes'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Notes'),
                  Text(
                    widget.invoiceData['notes'],
                    style: const TextStyle(
                      color: Color(0xFF0D141C),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),

            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  // Helper to build section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF0D141C),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helper to build information rows
  Widget _buildInfoRow(String label, String? value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100, // Fixed width for labels for alignment
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF49739C),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(
                color: const Color(0xFF0D141C),
                fontSize: 14,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build line items list
  List<Widget> _buildLineItems(List<dynamic> lineItems) {
    return lineItems.map<Widget>((item) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                item['itemName'] ?? 'Unknown Item',
                style: const TextStyle(color: Color(0xFF0D141C), fontSize: 14),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                'x${item['quantity'] ?? 0}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF49739C), fontSize: 14),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                item['totalPrice'] ?? '\$0.00',
                textAlign: TextAlign.right,
                style: const TextStyle(color: Color(0xFF0D141C), fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // Helper to build action buttons
  Widget _buildActionButtons(BuildContext context) {
    // Determine if Approve button is enabled
    final bool canApprove = _currentStatus == 'Draft' || _currentStatus == 'Rejected';
    final VoidCallback? approveOnPressed = canApprove ? () => _showApproveDialog(context) : null;
    final Color approveBgColor = canApprove ? const Color(0xFF3D98F4) : Colors.grey.shade400;
    final Color approveTextColor = canApprove ? Colors.white : Colors.grey.shade600;
    final String approveNote = canApprove ? '' : 'Invoice must be in Draft or Rejected status to be approved.';

    // Determine if Reject button is enabled
    final bool canReject = _currentStatus == 'Draft' || _currentStatus == 'Unpaid' || _currentStatus == 'Partially Paid';
    final VoidCallback? rejectOnPressed = canReject ? () => _showRejectDialog(context) : null;
    final Color rejectFgColor = canReject ? const Color(0xFFD92D20) : Colors.grey.shade600;
    final Color rejectBorderColor = canReject ? const Color(0xFFD92D20) : Colors.grey.shade400;
    final String rejectNote = canReject ? '' : 'Invoice cannot be rejected in its current status.';

    // Determine if Manage Payments button is enabled
    final bool canManagePayments = _currentStatus != 'Draft' && _currentStatus != 'Rejected';
    final VoidCallback? managePaymentsOnPressed = canManagePayments ? () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InvoiceBillingScreen(
            invoiceData: widget.invoiceData,
            onInvoiceUpdated: _updateInvoiceFromChild,
          ),
        ),
      );
    } : null;
    final Color managePaymentsFgColor = canManagePayments ? const Color(0xFF49739C) : Colors.grey.shade600;
    final String managePaymentsNote = canManagePayments
        ? ''
        : 'Approve invoice first to manage payments.';


    return Column(
      children: [
        // Approve Invoice Button
        SizedBox(
          width: double.infinity,
          child: Tooltip( // Added Tooltip for notes
            message: approveNote,
            preferBelow: false,
            triggerMode: approveNote.isNotEmpty ? TooltipTriggerMode.longPress : TooltipTriggerMode.manual,
            child: ElevatedButton(
              onPressed: approveOnPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: approveBgColor, // Direct Color assignment
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                // Removed elevation, shadowColor, overlayColor
              ),
              child: Text(
                'Approve Invoice',
                style: TextStyle(
                  color: approveTextColor, // Direct Color assignment
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        if (approveNote.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
            child: Text(
              approveNote,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12), // Simple gray note
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 12),

        // Reject Invoice Button
        SizedBox(
          width: double.infinity,
          child: Tooltip( // Added Tooltip for notes
            message: rejectNote,
            preferBelow: false,
            triggerMode: rejectNote.isNotEmpty ? TooltipTriggerMode.longPress : TooltipTriggerMode.manual,
            child: OutlinedButton(
              onPressed: rejectOnPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: rejectFgColor, // Direct Color assignment
                side: BorderSide(color: rejectBorderColor), // Direct BorderSide assignment
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                // Removed overlayColor
              ),
              child: const Text(
                'Reject Invoice',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        if (rejectNote.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
            child: Text(
              rejectNote,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12), // Simple gray note
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 12),

        // Manage Payments Button
        SizedBox(
          width: double.infinity,
          child: Tooltip( // Added Tooltip for notes
            message: managePaymentsNote,
            preferBelow: false,
            triggerMode: managePaymentsNote.isNotEmpty ? TooltipTriggerMode.longPress : TooltipTriggerMode.manual,
            child: TextButton(
              onPressed: managePaymentsOnPressed,
              style: TextButton.styleFrom(
                foregroundColor: managePaymentsFgColor, // Direct Color assignment
                padding: const EdgeInsets.symmetric(vertical: 12),
                // Removed overlayColor, textStyle
              ),
              child: const Text(
                'Manage Payments',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        if (managePaymentsNote.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
            child: Text(
              managePaymentsNote,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12), // Simple gray note
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
