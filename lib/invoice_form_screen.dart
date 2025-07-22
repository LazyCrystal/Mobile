import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/invoice_model.dart';
import '../providers/invoice_provider.dart';

class InvoiceFormScreen extends StatefulWidget {
  final Invoice? invoice;

  const InvoiceFormScreen({super.key, this.invoice});

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _customerCityController = TextEditingController();
  final _customerStateController = TextEditingController();
  final _customerZipController = TextEditingController();
  final _customerCountryController = TextEditingController();
  final _notesController = TextEditingController();
  final _discountController = TextEditingController();
  final _taxRateController = TextEditingController();

  List<InvoiceItem> _items = [];
  DateTime _issueDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  Customer? _selectedCustomer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.invoice != null) {
      _loadInvoiceData();
    } else {
      _addNewItem();
    }
  }

  void _loadInvoiceData() {
    final invoice = widget.invoice!;
    _selectedCustomer = invoice.customer;
    _customerNameController.text = invoice.customer.name;
    _customerEmailController.text = invoice.customer.email;
    _customerPhoneController.text = invoice.customer.phone;
    _customerAddressController.text = invoice.customer.address;
    _customerCityController.text = invoice.customer.city;
    _customerStateController.text = invoice.customer.state;
    _customerZipController.text = invoice.customer.zipCode;
    _customerCountryController.text = invoice.customer.country;
    _notesController.text = invoice.notes;
    _discountController.text = invoice.discountPercentage.toString();
    _taxRateController.text = invoice.taxRate.toString();
    _items = List.from(invoice.items);
    _issueDate = invoice.issueDate;
    _dueDate = invoice.dueDate;
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerEmailController.dispose();
    _customerPhoneController.dispose();
    _customerAddressController.dispose();
    _customerCityController.dispose();
    _customerStateController.dispose();
    _customerZipController.dispose();
    _customerCountryController.dispose();
    _notesController.dispose();
    _discountController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.invoice != null ? 'Edit Invoice' : 'Create Invoice'),
        backgroundColor: const Color(0xFFF8FAFC),
        foregroundColor: const Color(0xFF0D141C),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveInvoice,
            child: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Save'),
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
              _buildDateSection(),
              const SizedBox(height: 24),
              _buildCustomerSection(),
              const SizedBox(height: 24),
              _buildItemsSection(),
              const SizedBox(height: 24),
              _buildCalculationsSection(),
              const SizedBox(height: 24),
              _buildNotesSection(),
              const SizedBox(height: 24),
              _buildTotalSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSection() {
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
            'Invoice Dates',
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
                child: _buildDateField(
                  'Issue Date',
                  _issueDate,
                      (date) => setState(() => _issueDate = date),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateField(
                  'Due Date',
                  _dueDate,
                      (date) => setState(() => _dueDate = date),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, DateTime date, Function(DateTime) onChanged) {
    return InkWell(
      onTap: () async {
        final newDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (newDate != null) {
          onChanged(newDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE7EDF4)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF49739C),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, yyyy').format(date),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF0D141C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSection() {
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
          Row(
            children: [
              const Text(
                'Customer Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D141C),
                ),
              ),
              const Spacer(),
              Consumer<InvoiceProvider>(
                builder: (context, provider, child) {
                  return TextButton.icon(
                    onPressed: () => _showCustomerSelector(provider.customers),
                    icon: const Icon(Icons.person_search),
                    label: const Text('Select Existing'),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _customerNameController,
            decoration: const InputDecoration(
              labelText: 'Customer Name *',
              border: OutlineInputBorder(),
            ),
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _customerEmailController,
            decoration: const InputDecoration(
              labelText: 'Email *',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty == true) return 'Required';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                return 'Invalid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _customerPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _customerCountryController,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _customerAddressController,
            decoration: const InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _customerCityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _customerStateController,
                  decoration: const InputDecoration(
                    labelText: 'State',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _customerZipController,
                  decoration: const InputDecoration(
                    labelText: 'ZIP Code',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
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
          Row(
            children: [
              const Text(
                'Invoice Items',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D141C),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addNewItem,
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildItemRow(index, item);
          }),
        ],
      ),
    );
  }

  Widget _buildItemRow(int index, InvoiceItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE7EDF4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Item ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0D141C),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _removeItem(index),
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: item.description,
            decoration: const InputDecoration(
              labelText: 'Description *',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _updateItem(index, description: value),
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: item.quantity.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Quantity *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _updateItem(
                    index,
                    quantity: double.tryParse(value) ?? 0,
                  ),
                  validator: (value) {
                    final qty = double.tryParse(value ?? '');
                    return qty == null || qty <= 0 ? 'Invalid quantity' : null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: item.unitPrice.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Unit Price *',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _updateItem(
                    index,
                    unitPrice: double.tryParse(value) ?? 0,
                  ),
                  validator: (value) {
                    final price = double.tryParse(value ?? '');
                    return price == null || price < 0 ? 'Invalid price' : null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: item.taxRate.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Tax Rate %',
                    border: OutlineInputBorder(),
                    suffixText: '%',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _updateItem(
                    index,
                    taxRate: double.tryParse(value) ?? 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Total: ${NumberFormat.currency(symbol: '\$').format(item.total)}',
                style: const TextStyle(
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

  Widget _buildCalculationsSection() {
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
            'Additional Calculations',
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
                child: TextFormField(
                  controller: _discountController,
                  decoration: const InputDecoration(
                    labelText: 'Discount %',
                    border: OutlineInputBorder(),
                    suffixText: '%',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _taxRateController,
                  decoration: const InputDecoration(
                    labelText: 'Additional Tax %',
                    border: OutlineInputBorder(),
                    suffixText: '%',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
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
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Additional notes or terms',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    final subtotal = _items.fold(0.0, (sum, item) => sum + item.subtotal);
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    final discountAmount = subtotal * (discount / 100);
    final subtotalAfterDiscount = subtotal - discountAmount;
    final additionalTax = double.tryParse(_taxRateController.text) ?? 0.0;
    final itemTax = _items.fold(0.0, (sum, item) => sum + item.taxAmount);
    final totalTax = (subtotalAfterDiscount * (additionalTax / 100)) + itemTax;
    final total = subtotalAfterDiscount + totalTax;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0EA5E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildTotalRow('Subtotal', NumberFormat.currency(symbol: '\$').format(subtotal)),
          if (discount > 0) ...[
            _buildTotalRow('Discount ($discount%)',
                '-${NumberFormat.currency(symbol: '\$').format(discountAmount)}'),
            _buildTotalRow('Subtotal after discount',
                NumberFormat.currency(symbol: '\$').format(subtotalAfterDiscount)),
          ],
          if (totalTax > 0)
            _buildTotalRow('Tax', NumberFormat.currency(symbol: '\$').format(totalTax)),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D141C),
                ),
              ),
              Text(
                NumberFormat.currency(symbol: '\$').format(total),
                style: const TextStyle(
                  fontSize: 24,
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

  void _addNewItem() {
    setState(() {
      _items.add(InvoiceItem(
        description: '',
        quantity: 1,
        unitPrice: 0,
      ));
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _updateItem(int index, {
    String? description,
    double? quantity,
    double? unitPrice,
    double? taxRate,
  }) {
    setState(() {
      final item = _items[index];
      _items[index] = item.copyWith(
        description: description ?? item.description,
        quantity: quantity ?? item.quantity,
        unitPrice: unitPrice ?? item.unitPrice,
        taxRate: taxRate ?? item.taxRate,
      );
    });
  }

  void _showCustomerSelector(List<Customer> customers) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Customer'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return ListTile(
                title: Text(customer.name),
                subtitle: Text(customer.email),
                onTap: () {
                  _selectCustomer(customer);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _selectCustomer(Customer customer) {
    setState(() {
      _selectedCustomer = customer;
      _customerNameController.text = customer.name;
      _customerEmailController.text = customer.email;
      _customerPhoneController.text = customer.phone;
      _customerAddressController.text = customer.address;
      _customerCityController.text = customer.city;
      _customerStateController.text = customer.state;
      _customerZipController.text = customer.zipCode;
      _customerCountryController.text = customer.country;
    });
  }

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty || _items.any((item) => item.description.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one valid item')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<InvoiceProvider>(context, listen: false);

      // Create or update customer
      final customer = Customer(
        id: _selectedCustomer?.id,
        name: _customerNameController.text,
        email: _customerEmailController.text,
        phone: _customerPhoneController.text,
        address: _customerAddressController.text,
        city: _customerCityController.text,
        state: _customerStateController.text,
        zipCode: _customerZipController.text,
        country: _customerCountryController.text,
      );

      if (_selectedCustomer == null) {
        await provider.addCustomer(customer);
      } else if (_selectedCustomer!.id != customer.id) {
        await provider.updateCustomer(customer);
      }

      // Create or update invoice
      final invoice = Invoice(
        id: widget.invoice?.id,
        invoiceNumber: widget.invoice?.invoiceNumber ?? provider.generateInvoiceNumber(),
        customer: customer,
        items: _items,
        issueDate: _issueDate,
        dueDate: _dueDate,
        notes: _notesController.text,
        discountPercentage: double.tryParse(_discountController.text) ?? 0.0,
        taxRate: double.tryParse(_taxRateController.text) ?? 0.0,
        status: widget.invoice?.status ?? InvoiceStatus.draft,
        paymentStatus: widget.invoice?.paymentStatus ?? PaymentStatus.unpaid,
        approvedBy: widget.invoice?.approvedBy ?? '',
        approvedDate: widget.invoice?.approvedDate,
        paidDate: widget.invoice?.paidDate,
        paidAmount: widget.invoice?.paidAmount ?? 0.0,
        paymentMethod: widget.invoice?.paymentMethod ?? '',
        paymentReference: widget.invoice?.paymentReference ?? '',
      );

      if (widget.invoice != null) {
        await provider.updateInvoice(invoice);
      } else {
        await provider.addInvoice(invoice);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.invoice != null
                ? 'Invoice updated successfully'
                : 'Invoice created successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving invoice: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}