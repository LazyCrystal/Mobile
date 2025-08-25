import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'inventory_detail.dart'; // Ensure this file exists with InventoryDetailScreen

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  Future<void> _setpricedialog(BuildContext context) async {
    final stockPriceController = TextEditingController();
    final marketPriceController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          AlertDialog(
            title: Text('Set Price'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: stockPriceController, // Corrected casing
                    decoration: InputDecoration(
                        labelText: 'Stock price per unit(RM)'),
                    keyboardType: TextInputType.numberWithOptions(
                        decimal: true), // Added for better input
                  ),
                  TextField(
                    controller: marketPriceController, // Corrected casing
                    decoration: InputDecoration(
                        labelText: 'Market price per unit(RM)'),
                    keyboardType: TextInputType.numberWithOptions(
                        decimal: true), // Added for better input
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                // Fixed to close dialog
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async { // async is needed for await
                  if (stockPriceController.text.isEmpty ||
                      marketPriceController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('All text fields must be filled.')),
                    );
                    return;
                  }
                  try {
                    // This should be an update, not add (document ID needed)
                    // Placeholder for update logic (see integration below)
                    Navigator.pop(context); // Close dialog on success
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: Text('Add'),
              ),
            ],
          ),
    );
  }

  Future<void> _addItem(BuildContext context) async {
    final partNumberController = TextEditingController();
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final imageUrlController = TextEditingController();
    final stockPriceController = TextEditingController();
    final marketPriceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Inventory'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: partNumberController,
                decoration: InputDecoration(labelText: 'Part Number'),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: imageUrlController,
                decoration: InputDecoration(labelText: 'Image URL'),
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
              if (partNumberController.text.isEmpty ||
                  nameController.text.isEmpty ||
                  quantityController.text.isEmpty ||
                  imageUrlController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('All fields are required!')),
                );
                return;
              }
              try {
                // Add initial item without prices
                final docRef = await FirebaseFirestore.instance.collection('Inventory').add({
                  'partNumber': partNumberController.text,
                  'name': nameController.text,
                  'quantity': int.parse(quantityController.text),
                  'imageUrl': imageUrlController.text,
                  'timestamp': FieldValue.serverTimestamp(),
                });

                // Show dialog for prices after successful addition
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    title: Text('Set Price'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: stockPriceController,
                            decoration: InputDecoration(labelText: 'Stock price per unit(RM)'),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                          ),
                          TextField(
                            controller: marketPriceController,
                            decoration: InputDecoration(labelText: 'Market price per unit(RM)'),
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
                              SnackBar(content: Text('All text fields must be filled.')),
                            );
                            return;
                          }
                          try {
                            await docRef.update({
                              'stockPrice': double.parse(stockPriceController.text),
                              'marketPrice': double.parse(marketPriceController.text),
                            });
                            Navigator.pop(context); // Close prices dialog
                            Navigator.pop(context); // Close initial add dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Prices added successfully!')),
                            );
                          } catch (e) {
                            debugPrint('❌ Failed to update prices: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                        child: Text('Add'),
                      ),
                    ],
                  ),
                );
              } catch (e) {
                debugPrint('❌ Failed to add item: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: Text('Add'),
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
          'Inventory',
          style: TextStyle(
            color: Color(0xFF0D141C),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Color(0xFF0D141C), size: 24),
            onPressed: () => _addItem(context), // Open dialog on button press
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by parts number',
                hintStyle: TextStyle(color: Colors.blueAccent),
                prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {},
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Parts',
                  style: TextStyle(
                    color: Color(0xFF0D141C),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.sort, color: Colors.blueAccent, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Inventory').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No inventory items found.'));
                }

                final inventoryItems = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: inventoryItems.length,
                  itemBuilder: (context, index) {
                    final item = inventoryItems[index].data() as Map<String, dynamic>;
                    final docId = inventoryItems[index].id; // Get document ID
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InventoryDetailScreen(item: item, docId: docId),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item['imageUrl'] ?? 'https://via.placeholder.com/150',
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 56,
                                  height: 56,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['partNumber'] ?? 'N/A',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    item['name'] ?? 'Unknown',
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              item['quantity']?.toString() ?? '0',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}