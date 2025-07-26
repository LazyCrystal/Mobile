import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

// Define a callback type for when an invoice is generated
typedef OnInvoiceGenerated = void Function(Map<String, dynamic> newInvoice);

class GenerateInvoiceScreen extends StatefulWidget {
  // Callback to pass the new invoice back to the parent screen (InvoiceScreen)
  final OnInvoiceGenerated onInvoiceGenerated;

  const GenerateInvoiceScreen({super.key, required this.onInvoiceGenerated});

  @override
  _GenerateInvoiceScreenState createState() => _GenerateInvoiceScreenState();
}

class _GenerateInvoiceScreenState extends State<GenerateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text input fields
  final TextEditingController _invoiceIdController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerEmailController = TextEditingController();
  final TextEditingController _customerAddressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Dates
  DateTime? _issueDate;
  DateTime? _dueDate;

  // Line items for the invoice
  List<Map<String, TextEditingController>> _lineItems = [];

  // Financial calculations
  double _subtotal = 0.0;
  final _taxesRate = 0.06;
  double _taxesAmount = 0.0;
  double _discountRate = 0.0; // Example discount rate (0%)
  double _discountAmount = 0.0;
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    // Initialize with a default line item
    _addLineItem();
    // Auto-generate a simple invoice ID for demonstration
    _invoiceIdController.text = '#INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _invoiceIdController.dispose();
    _customerNameController.dispose();
    _customerEmailController.dispose();
    _customerAddressController.dispose();
    _notesController.dispose();
    for (var item in _lineItems) {
      item['itemName']!.dispose();
      item['quantity']!.dispose();
      item['unitPrice']!.dispose();
    }
    super.dispose();
  }

  // Method to add a new line item row
  void _addLineItem() {
    setState(() {
      _lineItems.add({
        'itemName': TextEditingController(),
        'quantity': TextEditingController(text: '1'), // Default quantity
        'unitPrice': TextEditingController(text: '0.00'), // Default price
      });
      _calculateTotals(); // Recalculate totals after adding
    });
  }

  // Method to remove a line item row
  void _removeLineItem(int index) {
    setState(() {
      _lineItems[index]['itemName']!.dispose();
      _lineItems[index]['quantity']!.dispose();
      _lineItems[index]['unitPrice']!.dispose();
      _lineItems.removeAt(index);
      _calculateTotals(); // Recalculate totals after removing
    });
  }

  // Method to calculate subtotal, taxes, discount, and total
  void _calculateTotals() {
    double currentSubtotal = 0.0;
    for (var item in _lineItems) {
      final quantity = double.tryParse(item['quantity']!.text) ?? 0.0;
      final unitPrice = double.tryParse(item['unitPrice']!.text) ?? 0.0;
      currentSubtotal += (quantity * unitPrice);
    }

    setState(() {
      _subtotal = currentSubtotal;
      _taxesAmount = _subtotal * _taxesRate;
      _discountAmount = _subtotal * _discountRate; // Apply discount on subtotal
      _totalAmount = _subtotal + _taxesAmount - _discountAmount;
    });
  }

  // Function to pick a date
  Future<void> _selectDate(BuildContext context, bool isIssueDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3D98F4), // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Color(0xFF0D141C), // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3D98F4), // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isIssueDate) {
          _issueDate = picked;
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  // Function to handle invoice generation
  void _generateInvoice() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save all form fields

      // Construct the new invoice data map
      final newInvoice = {
        'id': _invoiceIdController.text,
        'customerName': _customerNameController.text,
        'customerAddress': _customerAddressController.text,
        'customerEmail': _customerEmailController.text,
        'amount': '\$${_totalAmount.toStringAsFixed(2)}', // Formatted for display
        'issueDate': _issueDate != null ? DateFormat('yyyy-MM-dd').format(_issueDate!) : 'N/A',
        'dueDate': _dueDate != null ? DateFormat('yyyy-MM-dd').format(_dueDate!) : 'N/A',
        'status': 'Pending', // Default status for newly generated invoices
        'subtotal': '\$${_subtotal.toStringAsFixed(2)}',
        'taxes': '\$${_taxesAmount.toStringAsFixed(2)}',
        'discount': '\$${_discountAmount.toStringAsFixed(2)}',
        'totalAmount': '\$${_totalAmount.toStringAsFixed(2)}',
        'notes': _notesController.text,
        'lineItems': _lineItems.map((item) {
          final quantity = double.tryParse(item['quantity']!.text) ?? 0.0;
          final unitPrice = double.tryParse(item['unitPrice']!.text) ?? 0.0;
          return {
            'itemName': item['itemName']!.text,
            'quantity': quantity.toString(), // Store as string for consistency with existing data
            'unitPrice': '\$${unitPrice.toStringAsFixed(2)}',
            'totalPrice': '\$${(quantity * unitPrice).toStringAsFixed(2)}',
          };
        }).toList(),
      };

      // Call the callback to pass the new invoice data back
      widget.onInvoiceGenerated(newInvoice);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice generated successfully!')),
      );

      // Pop the screen after generation
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: const Text(
          'Generate Invoice',
          style: TextStyle(color: Color(0xFF0D141C)),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D141C)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Invoice Details'),
              _buildTextField(
                controller: _invoiceIdController,
                labelText: 'Invoice ID',
                readOnly: true, // Auto-generated
              ),
              _buildTextField(
                controller: _customerNameController,
                labelText: 'Customer Name',
                validator: (value) => value!.isEmpty ? 'Please enter customer name' : null,
              ),
              _buildTextField(
                controller: _customerEmailController,
                labelText: 'Customer Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter customer email';
                  if (!value.contains('@')) return 'Please enter a valid email';
                  return null;
                },
              ),
              _buildTextField(
                controller: _customerAddressController,
                labelText: 'Customer Address',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              _buildSectionTitle('Dates'),
              _buildDateSelectionField(
                context,
                'Issue Date',
                _issueDate,
                    () => _selectDate(context, true),
              ),
              _buildDateSelectionField(
                context,
                'Due Date',
                _dueDate,
                    () => _selectDate(context, false),
              ),
              const SizedBox(height: 16),

              _buildSectionTitle('Line Items'),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _lineItems.length,
                itemBuilder: (context, index) {
                  return _buildLineItemRow(index);
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _addLineItem,
                  icon: const Icon(Icons.add, color: Color(0xFF3D98F4)),
                  label: const Text(
                    'Add Item',
                    style: TextStyle(color: Color(0xFF3D98F4), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildSectionTitle('Summary'),
              _buildSummaryRow('Subtotal:', _subtotal),
              _buildSummaryRow('Taxes (${(_taxesRate * 100).toStringAsFixed(0)}%):', _taxesAmount),
              _buildSummaryRow('Discount (${(_discountRate * 100).toStringAsFixed(0)}%):', _discountAmount),
              _buildSummaryRow('Total Amount:', _totalAmount, isBold: true, fontSize: 18),
              const SizedBox(height: 16),

              _buildSectionTitle('Notes'),
              _buildTextField(
                controller: _notesController,
                labelText: 'Notes/Comments',
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _generateInvoice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D98F4),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Generate Invoice',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
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

  // Helper for text input fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: labelText,
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
        style: const TextStyle(color: Color(0xFF0D141C)),
      ),
    );
  }

  // Helper for date selection fields
  Widget _buildDateSelectionField(
      BuildContext context, String label, DateTime? date, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: label,
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
              suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF49739C)),
            ),
            controller: TextEditingController(
              text: date != null ? DateFormat('yyyy-MM-dd').format(date) : '',
            ),
            readOnly: true,
            style: const TextStyle(color: Color(0xFF0D141C)),
          ),
        ),
      ),
    );
  }

  // Helper for a single line item row
  Widget _buildLineItemRow(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 4,
            child: _buildTextField(
              controller: _lineItems[index]['itemName']!,
              labelText: 'Item Name',
              onChanged: (value) => _calculateTotals(),
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _buildTextField(
              controller: _lineItems[index]['quantity']!,
              labelText: 'Qty',
              keyboardType: TextInputType.number,
              onChanged: (value) => _calculateTotals(),
              validator: (value) {
                if (value!.isEmpty) return 'Req';
                if (double.tryParse(value) == null) return 'Num';
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: _buildTextField(
              controller: _lineItems[index]['unitPrice']!,
              labelText: 'Unit Price',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) => _calculateTotals(),
              validator: (value) {
                if (value!.isEmpty) return 'Req';
                if (double.tryParse(value) == null) return 'Num';
                return null;
              },
            ),
          ),
          if (_lineItems.length > 1) // Only show remove button if more than one item
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFD92D20)),
              onPressed: () => _removeLineItem(index),
            ),
        ],
      ),
    );
  }

  // Helper for summary rows
  Widget _buildSummaryRow(String label, double amount, {bool isBold = false, double fontSize = 16}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF49739C),
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: const Color(0xFF0D141C),
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}