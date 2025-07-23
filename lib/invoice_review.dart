import 'package:flutter/material.dart';

class InvoiceReviewScreen extends StatefulWidget {
  // The invoice data to be displayed and reviewed.
  // Using Map<String, dynamic> for flexibility to include more detailed fields.
  final Map<String, dynamic> invoiceData;

  const InvoiceReviewScreen({super.key, required this.invoiceData});

  @override
  _InvoiceReviewScreenState createState() => _InvoiceReviewScreenState();
}

class _InvoiceReviewScreenState extends State<InvoiceReviewScreen> {
  // Local state for the invoice status, allowing it to be updated
  // within this screen (e.g., after approval/rejection).
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    // Initialize current status from the passed invoice data.
    _currentStatus = widget.invoiceData['status'] ?? 'Draft';
  }

  @override
  Widget build(BuildContext context) {
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
            _buildInfoRow('Status:', _currentStatus),
            _buildInfoRow('Issue Date:', widget.invoiceData['issueDate']),
            _buildInfoRow('Due Date:', widget.invoiceData['dueDate']),
            _buildInfoRow('Total Amount:', widget.invoiceData['totalAmount']),
            const SizedBox(height: 20),

            // Customer Information
            _buildSectionTitle('Customer Information'),
            _buildInfoRow('Name:', widget.invoiceData['customerName']),
            _buildInfoRow('Address:', widget.invoiceData['customerAddress']),
            _buildInfoRow('Email:', widget.invoiceData['customerEmail']),
            const SizedBox(height: 20),

            // Line Items
            _buildSectionTitle('Line Items'),
            // Check if lineItems exist and are a List
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
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showApproveDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D98F4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Approve Invoice',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _showRejectDialog(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD92D20), // Red color for reject
              side: const BorderSide(color: Color(0xFFD92D20)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              // Placeholder for edit functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit Invoice functionality not yet implemented.')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF49739C),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Edit Invoice',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
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
                  _currentStatus = 'Approved';
                });
                Navigator.of(context).pop(); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invoice approved successfully!')),
                );
                // In a real app, you would make an API call here to update the status in the backend.
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
                });
                Navigator.of(context).pop(); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Invoice rejected. Reason: $rejectReason')),
                );
                // In a real app, you would make an API call here to update the status and send the reason to the backend.
              },
            ),
          ],
        );
      },
    );
  }
}