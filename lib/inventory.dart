import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'inventory_detail.dart';
import 'firebase_options.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // Declare all controllers as instance variables
  final _searchController = TextEditingController();
  final _partNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _stockPriceController = TextEditingController();
  final _marketPriceController = TextEditingController();
  String _sortOption = 'none'; // Track sorting state

  @override
  void initState() {
    super.initState();
    // No initial data to load for these controllers, but _searchController is ready for use
  }

  @override
  void dispose() {
    _searchController.clear();
    _partNumberController.clear();
    _nameController.clear();
    _quantityController.clear();
    _stockPriceController.clear();
    _marketPriceController.clear();
    _searchController.dispose();
    _partNumberController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _stockPriceController.dispose();
    _marketPriceController.dispose();
    super.dispose();
  }

  Future<void> _addItem(BuildContext context) async {
    final List<String> assetImages = [
      'assets/images/Tire.jpg',
      'assets/images/Brake_Pad.jpg',
      'assets/images/Oil_Filter.jpg',
      'assets/images/Spark_Plug.jpg',
      'assets/images/Battery.jpg',
    ];
    String? selectedImage = assetImages[0];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Inventory'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _partNumberController,
                decoration: InputDecoration(labelText: 'Part Number'),
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                initialValue: selectedImage,
                decoration: InputDecoration(labelText: 'Select Image'),
                items: assetImages.map((String assetPath) {
                  return DropdownMenuItem<String>(
                    value: assetPath,
                    child: Text(assetPath.split('/').last),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  selectedImage = newValue;
                  debugPrint('Selected image: $selectedImage');
                },
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
              if (_partNumberController.text.isEmpty ||
                  _nameController.text.isEmpty ||
                  _quantityController.text.isEmpty ||
                  selectedImage == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('All fields are required!')),
                );
                return;
              }
              try {
                final docRef = await FirebaseFirestore.instance.collection('Inventory').add({
                  'partNumber': _partNumberController.text,
                  'name': _nameController.text,
                  'quantity': int.parse(_quantityController.text),
                  'imageUrl': selectedImage!,
                  'timestamp': FieldValue.serverTimestamp(),
                });
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
                            controller: _stockPriceController,
                            decoration: InputDecoration(labelText: 'Stock price per unit(RM)'),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                          ),
                          TextField(
                            controller: _marketPriceController,
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
                          if (_stockPriceController.text.isEmpty ||
                              _marketPriceController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('All text fields must be filled.')),
                            );
                            return;
                          }
                          try {
                            await docRef.update({
                              'stockPrice': double.parse(_stockPriceController.text),
                              'marketPrice': double.parse(_marketPriceController.text),
                            });
                            Navigator.pop(context);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Item added successfully!')),
                            );
                            // Clear controllers after successful addition
                            _partNumberController.clear();
                            _nameController.clear();
                            _quantityController.clear();
                            _stockPriceController.clear();
                            _marketPriceController.clear();
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

  Future<void> _showSortOptions(BuildContext context) async {
    String? sortOption = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sort Items'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Low Quantity to High Quantity'),
              onTap: () {
                Navigator.pop(context, 'lowToHigh');
              },
            ),
            ListTile(
              title: Text('High Quantity to Low Quantity'),
              onTap: () {
                Navigator.pop(context, 'highToLow');
              },
            ),
            ListTile(
              title: Text('By Group (Txxx, BPxxx, OFxxx, SPxxx, BTxxx)'),
              onTap: () {
                Navigator.pop(context, 'byGroup');
              },
            ),
          ],
        ),
      ),
    );

    if (sortOption != null) {
      setState(() {
        _sortOption = sortOption;
      });
    }
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
            onPressed: () => _addItem(context),
          ),
          IconButton(
            icon: Icon(Icons.sort, color: Colors.blueAccent, size: 20),
            onPressed: () => _showSortOptions(context),
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
              controller: _searchController,
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
              onChanged: (value) {
                setState(() {});
              },
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
                  debugPrint('Firestore error: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No inventory items found.'));
                }
                final inventoryItems = snapshot.data!.docs;

                // Filter by search term
                final searchTerm = _searchController.text.toLowerCase();
                var filteredItems = searchTerm.isEmpty
                    ? inventoryItems
                    : inventoryItems.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['partNumber']?.toLowerCase().contains(searchTerm) ?? false;
                }).toList();

                // Apply sorting based on _sortOption
                filteredItems.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aQuantity = aData['quantity'] ?? 0;
                  final bQuantity = bData['quantity'] ?? 0;
                  final aPartNumber = aData['partNumber'] ?? '';
                  final bPartNumber = bData['partNumber'] ?? '';

                  switch (_sortOption) {
                    case 'lowToHigh':
                      return aQuantity.compareTo(bQuantity);
                    case 'highToLow':
                      return bQuantity.compareTo(aQuantity);
                    case 'byGroup':
                      final aPrefix = aPartNumber.isNotEmpty ? aPartNumber.substring(0, 2) : 'ZZ';
                      final bPrefix = bPartNumber.isNotEmpty ? bPartNumber.substring(0, 2) : 'ZZ';
                      return aPrefix.compareTo(bPrefix);
                    default:
                      return 0;
                  }
                });

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index].data() as Map<String, dynamic>;
                    final docId = filteredItems[index].id;
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
                              child: Image.asset(
                                item['imageUrl'] ?? 'https://via.placeholder.com/150',
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 56,
                                  height: 56,
                                  color: Colors.grey,
                                  child: Text('Error: $error'),
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