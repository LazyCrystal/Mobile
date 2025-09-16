// firebase_test_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Required for Firestore operations

class FirebaseTestPage extends StatelessWidget {
  const FirebaseTestPage({super.key});

  Future<void> _testWrite(BuildContext context) async { // Added BuildContext parameter
    try {
      await FirebaseFirestore.instance.collection('POOP').add({
        'name': 'Test User',
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Write success!');
      // Provide visual feedback to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write successful! Check Firestore!')),
      );
    } catch (e) {
      debugPrint('❌ Write failed: $e');
      // Provide visual feedback to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Write failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Test')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _testWrite(context), // Pass context to _testWrite
          child: const Text('Write to Firebase'),
        ),
      ),
    );
  }
}