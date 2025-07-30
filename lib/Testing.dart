import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTestPage extends StatelessWidget {
  const FirebaseTestPage({super.key});

  Future<void> _testWrite() async {
    try {
      await FirebaseFirestore.instance.collection('Inventory').add({
        'name': 'Yiz',
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Write success!');
    } catch (e) {
      debugPrint('❌ Write failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Test')),
      body: Center(
        child: ElevatedButton(
          onPressed: _testWrite,
          child: const Text('Write to Firebase'),
        ),
      ),
    );
  }
}