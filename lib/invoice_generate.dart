import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'firebase_invoice_service.dart'; // Import Firebase service
import 'inventory_service.dart'; // Import inventory service

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
  List<Map<String, dynamic>> _lineItems = [];

  // Financial calculations
  double _subtotal = 0.0;
  final _taxesRate = 0.06;
  double _taxesAmount = 0.0;
  double _discountRate = 0.0; // Example discount rate (0%)
  double _discountAmount = 0.0;
  double _totalAmount = 0.0;

  // Loading state
  bool _isGenerating = false;
  bool _isLoadingInventory = false;
  List<Map<String, dynamic>> _inventoryItems = [];

  @override
  void initState() {
    super.initState();
    // Initialize with a default line item
    _addLineItem();
    // Auto-generate a simple invoice ID for demonstration
    _invoiceIdController.text = '#INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    // Load inventory items
    _loadInventoryItems();
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _invoiceIdController.dispose();
    _customerNameController.dispose();
    _customerEmailController.dispose();
    _customerAddressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Load inventory items
  Future<void> _loadInventoryItems() async {
    try {
      setState(() {
        _isLoadingInventory = true;
      });

      final items = await InventoryService.getAllInventoryItems();
      setState(() {
        _inventoryItems = items;
        _isLoadingInventory = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingInventory = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading inventory: $e')),
        );
      }
    }
  }

  // Method to add a new line item row
  void _addLineItem() {
    setState(() {
      _lineItems.add({
        'selectedItem': null, // Selected inventory item
        'quantity': 1, // Default quantity
        'unitPrice': 0.0, // Default price
        'totalPrice': 0.0, // Calculated total
      });
      _calculateTotals(); // Recalculate totals after adding
    });
  }

  // Method to remove a line item row
  void _removeLineItem(int index) {
    setState(() {
      _lineItems.removeAt(index);
      _calculateTotals(); // Recalculate totals after removing
    });
  }

  // Method to select inventory item for a line item
  void _selectInventoryItem(int lineItemIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Inventory Item'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _isLoadingInventory
              ? const Center(child: CircularProgressIndicator())
              : _inventoryItems.isEmpty
              ? const Center(child: Text('No inventory items available'))
              : ListView.builder(
            itemCount: _inventoryItems.length,
            itemBuilder: (context, index) {
              final item = _inventoryItems[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(
                    item['imageUrl'] ?? 'assets/images/Tire.jpg',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey,
                      child: const Icon(Icons.image),
                    ),
                  ),
                ),
                title: Text(item['name'] ?? 'Unknown'),
                subtitle: Text('${item['partNumber']} - Qty: ${item['quantity']}'),
                trailing: Text(
                  '\$${item['marketPrice']?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  setState(() {
                    _lineItems[lineItemIndex]['selectedItem'] = item;
                    _lineItems[lineItemIndex]['unitPrice'] = item['marketPrice'] ?? 0.0;
                    _lineItems[lineItemIndex]['totalPrice'] =
                        (_lineItems[lineItemIndex]['quantity'] as int) *
                            (_lineItems[lineItemIndex]['unitPrice'] as double);
                  });
                  _calculateTotals();
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

  // Method to calculate subtotal, taxes, discount, and total
  void _calculateTotals() {
    double currentSubtotal = 0.0;
    for (var item in _lineItems) {
      final quantity = item['quantity'] as int? ?? 0;
      final unitPrice = item['unitPrice'] as double? ?? 0.0;
      final totalPrice = quantity * unitPrice;
      item['totalPrice'] = totalPrice;
      currentSubtotal += totalPrice;
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
  Future<void> _generateInvoice() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save all form fields

      // Validate that at least one inventory item is selected
      bool hasValidItems = false;
      for (var item in _lineItems) {
        if (item['selectedItem'] != null && item['quantity'] > 0) {
          hasValidItems = true;
          break;
        }
      }

      if (!hasValidItems) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one inventory item with quantity > 0')),
        );
        return;
      }

      setState(() {
        _isGenerating = true;
      });

      try {
        // Construct the new invoice data map
        final newInvoice = {
          'invoiceId': _invoiceIdController.text, // Keep original invoice ID for display
          'customerName': _customerNameController.text,
          'customerAddress': _customerAddressController.text,
          'customerEmail': _customerEmailController.text,
          'amount': '\$${_totalAmount.toStringAsFixed(2)}', // Formatted for display
          'issueDate': _issueDate != null ? DateFormat('yyyy-MM-dd').format(_issueDate!) : 'N/A',
          'dueDate': _dueDate != null ? DateFormat('yyyy-MM-dd').format(_dueDate!) : 'N/A',
          'status': 'Draft', // Default status for newly generated invoices
          'subtotal': '\$${_subtotal.toStringAsFixed(2)}',
          'taxes': '\$${_taxesAmount.toStringAsFixed(2)}',
          'discount': '\$${_discountAmount.toStringAsFixed(2)}',
          'totalAmount': '\$${_totalAmount.toStringAsFixed(2)}',
          'notes': _notesController.text,
          'lineItems': _lineItems.map((item) {
            final selectedItem = item['selectedItem'] as Map<String, dynamic>?;
            final quantity = item['quantity'] as int? ?? 0;
            final unitPrice = item['unitPrice'] as double? ?? 0.0;
            final totalPrice = item['totalPrice'] as double? ?? 0.0;

            return {
              'itemName': selectedItem?['name'] ?? 'Custom Item',
              'partNumber': selectedItem?['partNumber'] ?? '',
              'quantity': quantity.toString(),
              'unitPrice': '\$${unitPrice.toStringAsFixed(2)}',
              'totalPrice': '\$${totalPrice.toStringAsFixed(2)}',
              'inventoryItemId': selectedItem?['id'],
            };
          }).toList(),
          'payments': [], // Initialize empty payments list
        };

        // Save to Firebase and get the document ID
        final firebaseInvoiceId = await FirebaseInvoiceService.createInvoice(newInvoice);

        // Add the Firebase document ID to the invoice data
        newInvoice['id'] = firebaseInvoiceId;

        // Call the callback to pass the new invoice data back
        widget.onInvoiceGenerated(newInvoice);

        // Show a success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invoice generated successfully!')),
          );
        }

        // Pop the screen after generation
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error generating invoice: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isGenerating = false;
          });
        }
      }
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
                  onPressed: _isGenerating ? null : _generateInvoice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D98F4),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isGenerating
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
                        'Generating...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                      : const Text(
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
    final lineItem = _lineItems[index];
    final selectedItem = lineItem['selectedItem'] as Map<String, dynamic>?;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          // Item selection row
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectInventoryItem(index),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7EDF4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selectedItem != null ? const Color(0xFF3D98F4) : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (selectedItem != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.asset(
                              selectedItem['imageUrl'] ?? 'assets/images/Tire.jpg',
                              width: 32,
                              height: 32,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 32,
                                height: 32,
                                color: Colors.grey,
                                child: const Icon(Icons.image, size: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedItem['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF0D141C),
                                  ),
                                ),
                                Text(
                                  selectedItem['partNumber'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF49739C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          const Icon(Icons.add_shopping_cart, color: Color(0xFF49739C)),
                          const SizedBox(width: 8),
                          const Text(
                            'Select Inventory Item',
                            style: TextStyle(color: Color(0xFF49739C)),
                          ),
                        ],
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down, color: Color(0xFF49739C)),
                      ],
                    ),
                  ),
                ),
              ),
              if (_lineItems.length > 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFD92D20)),
                  onPressed: () => _removeLineItem(index),
                ),
            ],
          ),

          if (selectedItem != null) ...[
            const SizedBox(height: 8),
            // Quantity and price row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF49739C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: () {
                              if (lineItem['quantity'] > 1) {
                                setState(() {
                                  lineItem['quantity'] = (lineItem['quantity'] as int) - 1;
                                });
                                _calculateTotals();
                              }
                            },
                          ),
                          Container(
                            width: 50,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              '${lineItem['quantity']}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: () {
                              final availableQuantity = selectedItem['quantity'] ?? 0;
                              if (lineItem['quantity'] < availableQuantity) {
                                setState(() {
                                  lineItem['quantity'] = (lineItem['quantity'] as int) + 1;
                                });
                                _calculateTotals();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Only ${availableQuantity} items available in inventory')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Unit Price',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF49739C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          '\$${lineItem['unitPrice'].toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0D141C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF49739C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3D98F4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF3D98F4).withOpacity(0.3)),
                        ),
                        child: Text(
                          '\$${lineItem['totalPrice'].toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3D98F4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
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