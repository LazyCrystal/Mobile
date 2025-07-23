import 'package:flutter/material.dart';
import 'invoice_review.dart'; // Import the new invoice review screen
import 'invoice_generate.dart'; // Import the new generate invoice screen

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  int _selectedTabIndex = 0;

  // Make the invoices list mutable so new invoices can be added
  final List<Map<String, dynamic>> invoices = [
    {
      'id': '#12345',
      'customerName': 'Sarah Miller',
      'customerAddress': '123 Main St, Anytown, USA',
      'customerEmail': 'sarah.m@example.com',
      'amount': '\$500.00',
      'issueDate': '2024-07-01',
      'dueDate': '2024-07-31',
      'status': 'Unpaid',
      'subtotal': '\$450.00',
      'taxes': '\$50.00',
      'discount': '\$0.00',
      'totalAmount': '\$500.00',
      'notes': 'Payment due by end of month.',
      'lineItems': [
        {'itemName': 'Product A', 'quantity': '2', 'unitPrice': '\$100.00', 'totalPrice': '\$200.00'},
        {'itemName': 'Service B', 'quantity': '1', 'unitPrice': '\$250.00', 'totalPrice': '\$250.00'},
      ],
    },
    {
      'id': '#12346',
      'customerName': 'David Lee',
      'customerAddress': '456 Oak Ave, Villagetown, USA',
      'customerEmail': 'david.l@example.com',
      'amount': '\$750.00',
      'issueDate': '2024-06-15',
      'dueDate': '2024-07-15',
      'status': 'Paid',
      'subtotal': '\$700.00',
      'taxes': '\$50.00',
      'discount': '\$0.00',
      'totalAmount': '\$750.00',
      'notes': 'Thank you for your business!',
      'lineItems': [
        {'itemName': 'Consulting Hours', 'quantity': '5', 'unitPrice': '\$150.00', 'totalPrice': '\$750.00'},
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
      'status': 'Unpaid',
      'subtotal': '\$280.00',
      'taxes': '\$20.00',
      'discount': '\$0.00',
      'totalAmount': '\$300.00',
      'notes': '',
      'lineItems': [
        {'itemName': 'Web Design', 'quantity': '1', 'unitPrice': '\$300.00', 'totalPrice': '\$300.00'},
      ],
    },
    {
      'id': '#12348',
      'customerName': 'Michael Brown',
      'customerAddress': '101 Elm St, Townsville, USA',
      'customerEmail': 'michael.b@example.com',
      'amount': '\$1200.00',
      'issueDate': '2024-07-05',
      'dueDate': '2024-08-05',
      'status': 'Pending',
      'subtotal': '\$1100.00',
      'taxes': '\$100.00',
      'discount': '\$0.00',
      'totalAmount': '\$1200.00',
      'notes': 'Requires client approval before sending.',
      'lineItems': [
        {'itemName': 'Software License', 'quantity': '1', 'unitPrice': '\$1000.00', 'totalPrice': '\$1000.00'},
        {'itemName': 'Support Package', 'quantity': '1', 'unitPrice': '\$200.00', 'totalPrice': '\$200.00'},
      ],
    },
  ];

  // Callback function to add a new invoice to the list
  void _addNewInvoice(Map<String, dynamic> newInvoice) {
    setState(() {
      invoices.add(newInvoice);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF0D141C), size: 24),
            onPressed: () {
              // Navigate to the GenerateInvoiceScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GenerateInvoiceScreen(
                    onInvoiceGenerated: _addNewInvoice, // Pass the callback
                  ),
                ),
              );
            },
          ),
        ],
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
                const SizedBox(width: 16), // Add left padding for tabs
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
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final invoice = invoices[index];
                return _buildInvoiceItem(invoice);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String title, int index) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InvoiceReviewScreen(invoiceData: invoice),
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
                color: const Color(0xFFE7EDF4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.receipt,
                color: Color(0xFF0D141C),
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
              invoice['amount']!,
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