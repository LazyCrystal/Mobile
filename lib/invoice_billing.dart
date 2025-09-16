import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'firebase_invoice_service.dart'; // Import Firebase service

// Define a callback for when an invoice is updated
typedef OnInvoiceUpdated = void Function(Map<String, dynamic> updatedInvoice);

class InvoiceBillingScreen extends StatefulWidget {
  final Map<String, dynamic> invoiceData;
  final OnInvoiceUpdated onInvoiceUpdated;

  const InvoiceBillingScreen({
    super.key,
    required this.invoiceData,
    required this.onInvoiceUpdated,
  });

  @override
  _InvoiceBillingScreenState createState() => _InvoiceBillingScreenState();
}

class _InvoiceBillingScreenState extends State<InvoiceBillingScreen> {
  late Map<String, dynamic> _currentInvoice;
  final TextEditingController _paymentAmountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false; // Loading state for payment operations

  @override
  void initState() {
    super.initState();
    // Create a mutable copy of the invoice data to modify locally
    _currentInvoice = Map<String, dynamic>.from(widget.invoiceData);
    // Ensure payments list exists
    _currentInvoice['payments'] ??= [];
  }

  @override
  void dispose() {
    _paymentAmountController.dispose();
    super.dispose();
  }

  // Helper to calculate total invoice amount
  double _getInvoiceTotalAmount() {
    return double.tryParse(_currentInvoice['totalAmount']?.replaceAll('\$', '') ?? '0.0') ?? 0.0;
  }

  // Helper to calculate total paid amount from payments list
  double _calculateTotalPaid() {
    final payments = _currentInvoice['payments'] as List<dynamic>? ?? [];
    return payments.fold(0.0, (sum, payment) => sum + (double.tryParse(payment['amount'] ?? '0.0') ?? 0.0));
  }

  // Helper to get remaining amount due
  double _getRemainingAmount() {
    return _getInvoiceTotalAmount() - _calculateTotalPaid();
  }

  // Helper to determine invoice status based on payments
  String _getInvoiceStatus() {
    final totalAmount = _getInvoiceTotalAmount();
    final paidAmount = _calculateTotalPaid();

    if (paidAmount >= totalAmount && totalAmount > 0) {
      return 'Paid';
    } else if (paidAmount > 0 && paidAmount < totalAmount) {
      return 'Partially Paid';
    } else {
      return 'Unpaid';
    }
  }

  // Method to record a new payment
  Future<void> _recordPayment() async {
    if (_formKey.currentState!.validate()) {
      final double payment = double.tryParse(_paymentAmountController.text) ?? 0.0;
      final String paymentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      setState(() {
        _isProcessing = true;
      });

      try {
        // Create payment data
        final paymentData = {
          'date': paymentDate,
          'amount': payment.toStringAsFixed(2),
        };

        // Add payment to Firebase
        await FirebaseInvoiceService.addPayment(_currentInvoice['id'], paymentData);

        setState(() {
          // Add new payment to the local list
          (_currentInvoice['payments'] as List).add(paymentData);

          // Update the invoice status based on new paid amount
          _currentInvoice['status'] = _getInvoiceStatus();
        });

        // Call the callback to update the invoice in the parent list (InvoiceScreen)
        widget.onInvoiceUpdated(_currentInvoice);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment of \$${payment.toStringAsFixed(2)} recorded. Invoice now ${_currentInvoice['status']}.')),
          );

          _paymentAmountController.clear(); // Clear the input field
          Navigator.of(context).pop(); // Go back to review screen after recording
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error recording payment: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      }
    }
  }

  // Method to delete a payment record
  Future<void> _deletePayment(int index) async {
    final paymentToDelete = (_currentInvoice['payments'] as List)[index];

    setState(() {
      _isProcessing = true;
    });

    try {
      // Remove payment from Firebase
      await FirebaseInvoiceService.removePayment(_currentInvoice['id'], paymentToDelete);

      setState(() {
        (_currentInvoice['payments'] as List).removeAt(index);
        _currentInvoice['status'] = _getInvoiceStatus(); // Re-evaluate status
      });

      widget.onInvoiceUpdated(_currentInvoice); // Propagate update

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment record deleted.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting payment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> payments = _currentInvoice['payments'] as List<dynamic>? ?? [];
    final currentStatus = _getInvoiceStatus(); // Get the derived status for display

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: Text(
          'Billing Records for ${_currentInvoice['invoiceId'] ?? _currentInvoice['id'] ?? 'N/A'}',
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
            _buildSectionTitle('Invoice Summary'),
            _buildInfoRow('Invoice ID:', _currentInvoice['invoiceId'] ?? _currentInvoice['id']),
            _buildInfoRow('Customer:', _currentInvoice['customerName']),
            _buildInfoRow('Total Amount:', _currentInvoice['totalAmount']),
            _buildInfoRow('Current Status:', currentStatus, isBold: true),
            _buildInfoRow('Total Paid:', '\$${_calculateTotalPaid().toStringAsFixed(2)}'),
            _buildInfoRow('Remaining Due:', '\$${_getRemainingAmount().toStringAsFixed(2)}', isBold: true),
            const SizedBox(height: 30),

            _buildSectionTitle('Payment History'),
            if (payments.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'No payments recorded yet.',
                  style: TextStyle(color: Color(0xFF49739C), fontStyle: FontStyle.italic),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  final payment = payments[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Paid: \$${(double.tryParse(payment['amount'] ?? '0.0') ?? 0.0).toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: Color(0xFF0D141C),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                'Date: ${payment['date']}',
                                style: const TextStyle(
                                    color: Color(0xFF49739C),
                                    fontSize: 12),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: _isProcessing
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD92D20)),
                              ),
                            )
                                : const Icon(Icons.delete_outline, color: Color(0xFFD92D20)),
                            onPressed: _isProcessing ? null : () => _deletePayment(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 30),

            _buildSectionTitle('Record New Payment'),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _paymentAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Payment Amount',
                      hintText: 'e.g., 100.00',
                      prefixText: '\$',
                      labelStyle: const TextStyle(color: Color(0xFF49739C)),
                      filled: true,
                      fillColor: const Color(0xFFE7EDF4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF3D98F4), width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid positive number';
                      }
                      if (amount > _getRemainingAmount() + 0.001) { // Add a small tolerance for floating point
                        return 'Amount exceeds remaining due';
                      }
                      return null;
                    },
                    style: const TextStyle(color: Color(0xFF0D141C)),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_getRemainingAmount() <= 0.001 || _isProcessing) ? null : _recordPayment, // Disable if fully paid or processing
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isProcessing ? Colors.grey.shade400 : const Color(0xFF4CAF50), // Green for payment
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isProcessing
                          ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Recording...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                          : const Text(
                        'Record Payment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF0D141C),
          fontSize: 18,
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
            width: 120, // Fixed width for labels for alignment
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
}

