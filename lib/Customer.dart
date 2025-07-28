import 'package:flutter/material.dart';



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Customers',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const CustomerScreen(),
    );
  }
}

class Customer {
  final String name;
  final String phone;

  const Customer({required this.name, required this.phone});
}

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final List<Customer> _customers = [
    Customer(
      name: 'Ethan Carter',
      phone: '+1-555-123-4567',
    ),
    Customer(
      name: 'Olivia Bennett',
      phone: '+1-555-987-6543',
    ),
    Customer(
      name: 'Noah Thompson',
      phone: '+1-555-246-8013',
    ),
    Customer(
      name: 'Sophia Harper',
      phone: '+1-555-369-1470',
    ),
    Customer(
      name: 'Liam Foster',
      phone: '+1-555-789-0123',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  List<Customer> _filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    _filteredCustomers = _customers;
    _searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomers = _customers
          .where((customer) => customer.name.toLowerCase().contains(query))
          .toList();
    });
  }

  void _addCustomer() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Customer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter customer name',
              ),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                hintText: 'Enter phone number',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('Cancel button pressed');
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                print('Adding customer: ${nameController.text}, ${phoneController.text}');
                setState(() {
                  _customers.add(Customer(
                    name: nameController.text,
                    phone: phoneController.text,
                  ));
                  _filterCustomers();
                });
                Navigator.pop(context);
              } else {
                print('Invalid input: Name or phone is empty');
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: const Text(
          'Customers',
          style: TextStyle(
            color: Color(0xFF0D141C),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF0D141C), size: 24),
            onPressed: () {
              print('Add button pressed');
              _addCustomer();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search customers',
                hintStyle: const TextStyle(color: Color(0xFF49739C)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF49739C)),
                filled: true,
                fillColor: const Color(0xFFE7EDF4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCustomers.length,
              itemBuilder: (context, index) {
                final customer = _filteredCustomers[index];
                return ListTile(
                  title: Text(
                    customer.name,
                    style: const TextStyle(
                      color: Color(0xFF0D141C),
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    customer.phone,
                    style: const TextStyle(
                      color: Color(0xFF49739C),
                      fontSize: 14,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}