import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'Inventory';

  // Get all inventory items
  static Future<List<Map<String, dynamic>>> getAllInventoryItems() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('partNumber')
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch inventory items: $e');
    }
  }

  // Get inventory items stream for real-time updates
  static Stream<List<Map<String, dynamic>>> getInventoryItemsStream() {
    return _firestore
        .collection(_collectionName)
        .orderBy('partNumber')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Search inventory items by part number or name
  static Future<List<Map<String, dynamic>>> searchInventoryItems(String searchTerm) async {
    try {
      if (searchTerm.isEmpty) {
        return getAllInventoryItems();
      }

      // Note: Firestore doesn't support full-text search natively
      // This is a simple implementation that searches by part number
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('partNumber')
          .startAt([searchTerm])
          .endAt([searchTerm + '\uf8ff'])
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search inventory items: $e');
    }
  }

  // Get a specific inventory item by ID
  static Future<Map<String, dynamic>?> getInventoryItemById(String itemId) async {
    try {
      DocumentSnapshot docSnapshot = await _firestore
          .collection(_collectionName)
          .doc(itemId)
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        data['id'] = docSnapshot.id;
        return data;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch inventory item: $e');
    }
  }

  // Update inventory quantity after sale
  static Future<void> updateInventoryQuantity(String itemId, int quantitySold) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(itemId)
          .update({
        'quantity': FieldValue.increment(-quantitySold),
      });
    } catch (e) {
      throw Exception('Failed to update inventory quantity: $e');
    }
  }

  // Check if inventory item has sufficient quantity
  static Future<bool> checkInventoryAvailability(String itemId, int requiredQuantity) async {
    try {
      final item = await getInventoryItemById(itemId);
      if (item == null) return false;

      final currentQuantity = item['quantity'] ?? 0;
      return currentQuantity >= requiredQuantity;
    } catch (e) {
      throw Exception('Failed to check inventory availability: $e');
    }
  }
}
