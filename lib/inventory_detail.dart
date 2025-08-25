import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;
  final String docId;

  const InventoryDetailScreen({super.key, required this.item, required this.docId});

  Future<void> _updatePrices(BuildContext context) async {
    final stockPriceController = TextEditingController(text: item['stockPrice']?.toString() ?? '0.00');
    final marketPriceController = TextEditingController(text: item['marketPrice']?.toString() ?? '0.00');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Prices'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: stockPriceController,
                decoration: InputDecoration(labelText: 'Stock Price (per unit)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: marketPriceController,
                decoration: InputDecoration(labelText: 'Market Price (per unit)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (stockPriceController.text.isEmpty || marketPriceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Both fields are required!')),
                );
                return;
              }
              try {
                await FirebaseFirestore.instance.collection('Inventory').doc(docId).update({
                  'stockPrice': double.parse(stockPriceController.text),
                  'marketPrice': double.parse(marketPriceController.text),
                });
                Navigator.pop(context); // Close the dialog on success
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Prices updated successfully!')),
                );
              } catch (e) {
                debugPrint('❌ Failed to update prices: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          item['partNumber'] ?? 'N/A',
          style: TextStyle(
            color: Color(0xFF0D141C),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF0D141C)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item['imageUrl'] ?? 'https://via.placeholder.com/150',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Name: ${item['name'] ?? 'Unknown'}',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              'Quantity: ${item['quantity']?.toString() ?? '0'}',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              'Stock Price (per unit): ${item['stockPrice']?.toString() ?? '0.00'}',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              'Market Price (per unit): ${item['marketPrice']?.toString() ?? '0.00'}',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement increase quantity functionality
                  },
                  child: Text('Increase Quantity'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement delete functionality
                  },
                  child: Text('Delete'),
                ),
                ElevatedButton(
                  onPressed: () => _updatePrices(context),
                  child: Text('Update Prices'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}