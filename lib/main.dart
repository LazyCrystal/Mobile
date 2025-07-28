import 'package:flutter/material.dart';
import 'package:mobile_assignment/Schedule.dart';
import 'invoice.dart'; // Import the invoice.dart file
import 'inventory.dart'; // Import the inventory.dart file
import 'Customer.dart';
import 'home_page.dart'; // Import the new home page file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stitch Design',
      theme: ThemeData(
        primaryColor: const Color(0xFF0D141C),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: Color(0xFF0D141C),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.015,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF0D141C),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          bodySmall: TextStyle(
            color: Color(0xFF49739C),
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          labelSmall: TextStyle(
            color: Color(0xFF49739C),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.015,
          ),
        ),
      ),
      home: const HomePage(), // Set HomePage as the default starting page
    );
  }
}

// You can keep HomeScreen and other classes if needed, but they won't be the default
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 3; // Default to Inventory tab, as per your latest context

  // List of screens for bottom navigation
  final List<Widget> _screens = [
    const PlaceholderScreen(title: 'Vehicles'),
    const SchedulePage(),
    const CustomerScreen(),
    const InventoryScreen(),
    const InvoiceScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF0D141C),
        unselectedItemColor: const Color(0xFF49739C),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        backgroundColor: const Color(0xFFF8FAFC),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping, size: 24),
            label: 'Vehicles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today, size: 24),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people, size: 24),
            label: 'CRM',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory, size: 24),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description, size: 24),
            label: 'Invoices',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}

// Placeholder widget for screens not yet implemented
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
      ),
      body: Center(
        child: Text('$title Screen', style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}