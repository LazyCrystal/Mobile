import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/invoice_model.dart';
import '../providers/invoice_provider.dart';
import 'invoice_form_screen.dart';
import 'payment_form_screen.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, child) {
        final invoice = provider.getInvoiceById(invoiceId);

        if (invoice == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Invoice Not Found'),
              backgroundColor: const Color(0xFFF8FAFC),
              foregroundColor: const Color(0xFF0D141C),
            ),
            body: const Center(
              child: Text('Invoice not found'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(invoice.invoiceNumber),
            backgroundColor: const Color(0xFFF8FAFC),
            foregroundColor: const Color(0xFF0D141C),
            elevation: 0,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, value, invoice, provider),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  if (invoice.status == InvoiceStatus.draft)
                    const PopupMenuItem(value: 'submit', child: Text('Submit for Approval')),
                  if (invoice.status == InvoiceStatus.pending) ...[
                    const PopupMenuItem(value: 'approve', child: Text('Approve')),
                    const PopupMenuItem(value: 'reject', child: Text('Reject')),
                  ],
                  if (invoice.status == InvoiceStatus.approved)
                    const PopupMenuItem(value: 'send', child: Text('Send Invoice')),
                  if (invoice.paymentStatus != PaymentStatus.paid &&
                      invoice.status == InvoiceStatus.sent)
                    const PopupMenuItem(value: 'payment', child: Text('Record Payment')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCards(invoice),
                const SizedBox(height: 24),
                _buildInvoiceInfo(invoice),
                const SizedBox(height: 24),
                _buildCustomerInfo(invoice.customer),
                const SizedBox(height: 24),
                _buildItemsList(invoice),
                const SizedBox(height: 24),
                _buildTotals(invoice),
                const SizedBox(height: 24),
                if (invoice.paymentStatus == PaymentStatus.paid ||
                    invoice.paymentStatus == PaymentStatus.partiallyPaid)
                  _buildPaymentInfo(invoice),
                if (invoice.notes.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildNotes(invoice.notes),
                ],
                if (invoice.approvedBy.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildApprovalInfo(invoice),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusCards(Invoice invoice) {
    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            'Status',
            _getStatusText(invoice.status),
            _getStatusColor(invoice.status),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusCard(
            'Payment',
            _getPaymentStatusText(invoice.paymentStatus),
            _getPaymentStatusColor(invoice.paymentStatus),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(String title, String status, Color color) {
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
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF49739C),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              status,
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

  Widget _buildInvoiceInfo(Invoice invoice) {
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Invoice Number', invoice.invoiceNumber),
                    _buildInfoRow('Issue Date', dateFormat.format(invoice.issueDate)),
                    _buildInfoRow('Due Date', dateFormat.format(invoice.dueDate)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Total Amount', NumberFormat.currency(symbol: '\$').format(invoice.total)),
                    _buildInfoRow('Paid Amount', NumberFormat.currency(symbol: '\$').format(invoice.paidAmount)),
                    _buildInfoRow('Balance Due', NumberFormat.currency(symbol: '\$').format(invoice.remainingAmount)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(Customer customer) {
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
            'Customer Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D141C),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Name', customer.name),
          _buildInfoRow('Email', customer.email),
          if (customer.phone.isNotEmpty) _buildInfoRow('Phone', customer.phone),
          if (customer.address.isNotEmpty) _buildInfoRow('Address', customer.address),
          if (customer.city.isNotEmpty || customer.state.isNotEmpty || customer.zipCode.isNotEmpty)
            _buildInfoRow('City/State/Zip', '${customer.city} ${customer.state} ${customer.zipCode}'),
          if (customer.country.isNotEmpty) _buildInfoRow('Country', customer.country),
        ],
      ),
    );
  }

  Widget _buildItemsList(Invoice invoice) {
    return Container(
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
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D141C),
              ),
            ),
          ),
          ...invoice.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == invoice.items.length - 1;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: isLast ? null : const Border(
                  bottom: BorderSide(color: Color(0xFFE7EDF4)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.description,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0D141C),
                          ),
                        ),
                        if (item.taxRate > 0)
                          Text(
                            'Tax: ${item.taxRate}%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF49739C),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF49739C),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      NumberFormat.currency(symbol: '\$').format(item.unitPrice),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF49739C),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      NumberFormat.currency(symbol: '\$').format(item.total),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0D141C),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTotals(Invoice invoice) {
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildTotalRow('Subtotal', NumberFormat.currency(symbol: '\$').format(invoice.subtotal)),
          if (invoice.discountPercentage > 0) ...[
            _buildTotalRow('Discount (${invoice.discountPercentage}%)',
                '-${NumberFormat.currency(symbol: '\$').format(invoice.discountAmount)}'),
            _buildTotalRow('Subtotal after discount',
                NumberFormat.currency(symbol: '\$').format(invoice.subtotalAfterDiscount)),
          ],
          if (invoice.taxAmount > 0)
            _buildTotalRow('Tax', NumberFormat.currency(symbol: '\$').format(invoice.taxAmount)),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D141C),
                ),
              ),
              Text(
                NumberFormat.currency(symbol: '\$').format(invoice.total),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D141C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(Invoice invoice) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0EA5E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D141C),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Amount Paid', NumberFormat.currency(symbol: '\$').format(invoice.paidAmount)),
          if (invoice.paymentMethod.isNotEmpty) _buildInfoRow('Payment Method', invoice.paymentMethod),
          if (invoice.paymentReference.isNotEmpty) _buildInfoRow('Reference', invoice.paymentReference),
          if (invoice.paidDate != null) _buildInfoRow('Payment Date', dateFormat.format(invoice.paidDate!)),
        ],
      ),
    );
  }

  Widget _buildNotes(String notes) {
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
            'Notes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D141C),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            notes,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF49739C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalInfo(Invoice invoice) {
    final dateFormat = DateFormat('MMM dd, yyyy');

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
            'Approval Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D141C),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Approved By', invoice.approvedBy),
          if (invoice.approvedDate != null)
            _buildInfoRow('Approval Date', dateFormat.format(invoice.approvedDate!)),
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

  Widget _buildTotalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF49739C),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0D141C),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.pending:
        return Colors.orange;
      case InvoiceStatus.approved:
        return Colors.blue;
      case InvoiceStatus.sent:
        return Colors.purple;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.cancelled:
        return Colors.red.shade800;
    }
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

  String _getStatusText(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.pending:
        return 'Pending';
      case InvoiceStatus.approved:
        return 'Approved';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
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

  Future<void> _handleMenuAction(BuildContext context, String action, Invoice invoice, InvoiceProvider provider) async {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InvoiceFormScreen(invoice: invoice),
          ),
        );
        break;
      case 'submit':
        await provider.submitForApproval(invoice.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invoice submitted for approval')),
          );
        }
        break;
      case 'approve':
        await _showApprovalDialog(context, invoice, provider);
        break;
      case 'reject':
        await _showRejectionDialog(context, invoice, provider);
        break;
      case 'send':
        await provider.sendInvoice(invoice.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invoice sent to customer')),
          );
        }
        break;
      case 'payment':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentFormScreen(invoice: invoice),
          ),
        );
        break;
      case 'delete':
        await _showDeleteDialog(context, invoice, provider);
        break;
    }
  }



  Future<void> _showApprovalDialog(BuildContext context, Invoice invoice, InvoiceProvider provider) async {
    final TextEditingController controller = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Invoice'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your name to approve this invoice:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Approved by',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await provider.approveInvoice(invoice.id, controller.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invoice approved')),
                  );
                }
              }
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRejectionDialog(BuildContext context, Invoice invoice, InvoiceProvider provider) async {
    final TextEditingController controller = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Invoice'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Rejection reason',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await provider.rejectInvoice(invoice.id, controller.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invoice rejected')),
                  );
                }
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, Invoice invoice, InvoiceProvider provider) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: Text('Are you sure you want to delete invoice ${invoice.invoiceNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.deleteInvoice(invoice.id);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invoice deleted')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}