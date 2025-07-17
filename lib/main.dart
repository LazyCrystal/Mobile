import 'package:flutter/material.dart';
import 'inventory.dart'; // Import the inventory.dart file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stitch Design', // Updated title to match inventory theme
      theme: ThemeData(
        primaryColor: const Color(0xFF0D141C),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Inter', // Consistent font with inventory design
      ),
      home: const InventoryScreen(), // Set InventoryScreen as the home
    );
  }
}