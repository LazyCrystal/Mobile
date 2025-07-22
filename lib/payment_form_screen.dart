import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/invoice_model.dart';
import '../providers/invoice_provider.dart';

class PaymentFormScreen extends StatefulWidget {
  final Invoice invoice;

  const PaymentFormScreen({super.key, required this.invoice});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();

  String _paymentMethod = 'Bank Transfer';
  bool _isLoading = false;

  final List<String> _paymentMethods = [
    'Bank Transfer',
    'Credit Card',
    'Debit Card',
    'Cash',
    'Check',
    'PayPal',
    'Stripe',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Set default amount to remaining balance
    _amountController.text = widget.invoice.remainingAmount.toString();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Payment'),
        backgroundColor: const Color(0xFFF8FAFC),
        foregroundColor: const Color(0xFF0D141C),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _recordPayment,
            child: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Record'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInvoiceInfo(),
              const SizedBox(height: 24),
              _buildPaymentForm(),
              const SizedBox(height: 24),
              _buildPaymentSummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceInfo() {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Invoice Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D141C),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Invoice Number', widget.invoice.invoiceNumber),
          _buildInfoRow('Customer', widget.invoice.customer.name),
          _buildInfoRow('Due Date', dateFormat.format(widget.invoice.dueDate)),
          _buildInfoRow('Total Amount', currencyFormat.format(widget.invoice.total)),
          _buildInfoRow('Paid Amount', currencyFormat.format(widget.invoice.paidAmount)),
          _buildInfoRow('Balance Due', currencyFormat.format(widget.invoice.remainingAmount)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getPaymentStatusColor(widget.invoice.paymentStatus),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _getPaymentStatusText(widget.invoice.paymentStatus),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D141C),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Payment Amount *',
              border: OutlineInputBorder(),
              prefixText: '\$',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty == true) return 'Amount is required';
              final amount = double.tryParse(value!);
              if (amount == null || amount <= 0) {
                return 'Please enter a valid amount';
              }
              if (amount > widget.invoice.remainingAmount) {
                return 'Amount cannot exceed balance due';
              }
              return null;
            },
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _paymentMethod,
            decoration: const InputDecoration(
              labelText: 'Payment Method *',
              border: OutlineInputBorder(),
            ),
            items: _paymentMethods.map((method) {
              return DropdownMenuItem(
                value: method,
                child: Text(method),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _paymentMethod = value!;
              });
            },
            validator: (value) => value?.isEmpty == true ? 'Please select a payment method' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _referenceController,
            decoration: const InputDecoration(
              labelText: 'Payment Reference',
              border: OutlineInputBorder(),
              hintText: 'Transaction ID, Check number, etc.',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF0EA5E9)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Color(0xFF0EA5E9)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Payment will be recorded on ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0369A1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    final paymentAmount = double.tryParse(_amountController.text) ?? 0.0;
    final newPaidAmount = widget.invoice.paidAmount + paymentAmount;
    final newRemainingAmount = widget.invoice.total - newPaidAmount;

    PaymentStatus newStatus;
    if (newPaidAmount >= widget.invoice.total) {
      newStatus = PaymentStatus.paid;
    } else if (newPaidAmount > 0) {
      newStatus = PaymentStatus.partiallyPaid;
    } else {
      newStatus = PaymentStatus.unpaid;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF22C55E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D141C),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Balance:',
                style: TextStyle(fontSize: 14, color: Color(0xFF49739C)),
              ),
              Text(
                NumberFormat.currency(symbol: '\$').format(widget.invoice.remainingAmount),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0D141C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Payment Amount:',
                style: TextStyle(fontSize: 14, color: Color(0xFF49739C)),
              ),
              Text(
                NumberFormat.currency(symbol: '\$').format(paymentAmount),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF22C55E),
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'New Balance:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D141C),
                ),
              ),
              Text(
                NumberFormat.currency(symbol: '\$').format(newRemainingAmount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D141C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'New Status:',
                style: TextStyle(fontSize: 14, color: Color(0xFF49739C)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getPaymentStatusColor(newStatus),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _getPaymentStatusText(newStatus),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF49739C),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF0D141C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.unpaid:
        return Colors.red;
      case PaymentStatus.partiallyPaid:
        return Colors.orange;
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.refunded:
        return Colors.purple;
    }
  }

  String _getPaymentStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.unpaid:
        return 'Unpaid';
      case PaymentStatus.partiallyPaid:
        return 'Partially Paid';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  Future<void> _recordPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<InvoiceProvider>(context, listen: false);
      final amount = double.parse(_amountController.text);

      await provider.recordPayment(
        invoiceId: widget.invoice.id,
        amount: amount,
        paymentMethod: _paymentMethod,
        paymentReference: _referenceController.text.isEmpty ? null : _referenceController.text,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment of ${NumberFormat.currency(symbol: '\$').format(amount)} recorded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error recording payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}