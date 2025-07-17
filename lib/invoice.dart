import 'package:flutter/material.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  int _selectedTabIndex = 0;

  final List<Map<String, String>> invoices = [
    {'id': '#12345', 'customer': 'Sarah Miller', 'amount': '\$500'},
    {'id': '#12346', 'customer': 'David Lee', 'amount': '\$750'},
    {'id': '#12347', 'customer': 'Emily Chen', 'amount': '\$300'},
    {'id': '#12348', 'customer': 'Michael Brown', 'amount': '\$1200'},
  ];

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
            onPressed: () {},
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
                return _buildInvoiceItem(
                  invoice['id']!,
                  invoice['customer']!,
                  invoice['amount']!,
                );
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

  Widget _buildInvoiceItem(String id, String customer, String amount) {
    return Padding(
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
                  id,
                  style: const TextStyle(
                    color: Color(0xFF0D141C),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Customer: $customer',
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
            amount,
            style: const TextStyle(
              color: Color(0xFF0D141C),
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}