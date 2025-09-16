import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'customers';

  // Get total customers count (fallback to 0 if collection missing)
  static Future<int> getTotalCustomersCount() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      return snapshot.docs.length;
    } catch (_) {
      return 0;
    }
  }
}


