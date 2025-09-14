import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseInvoiceService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'invoices';

  // Create a new invoice
  static Future<String> createInvoice(Map<String, dynamic> invoiceData) async {
    try {
      // Add timestamp for creation
      invoiceData['createdAt'] = FieldValue.serverTimestamp();
      invoiceData['updatedAt'] = FieldValue.serverTimestamp();

      // Ensure payments list exists
      invoiceData['payments'] ??= [];

      DocumentReference docRef = await _firestore
          .collection(_collectionName)
          .add(invoiceData);

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create invoice: $e');
    }
  }

  // Get all invoices
  static Future<List<Map<String, dynamic>>> getAllInvoices() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Use Firestore document ID
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch invoices: $e');
    }
  }

  // Get a specific invoice by ID
  static Future<Map<String, dynamic>?> getInvoiceById(String invoiceId) async {
    try {
      DocumentSnapshot docSnapshot = await _firestore
          .collection(_collectionName)
          .doc(invoiceId)
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        data['id'] = docSnapshot.id;
        return data;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch invoice: $e');
    }
  }

  // Update an existing invoice
  static Future<void> updateInvoice(String invoiceId, Map<String, dynamic> invoiceData) async {
    try {
      // Add timestamp for update
      invoiceData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_collectionName)
          .doc(invoiceId)
          .update(invoiceData);
    } catch (e) {
      throw Exception('Failed to update invoice: $e');
    }
  }

  // Delete an invoice
  static Future<void> deleteInvoice(String invoiceId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(invoiceId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete invoice: $e');
    }
  }

  // Add a payment to an invoice
  static Future<void> addPayment(String invoiceId, Map<String, dynamic> paymentData) async {
    try {
      // Add timestamp for payment
      paymentData['timestamp'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_collectionName)
          .doc(invoiceId)
          .update({
        'payments': FieldValue.arrayUnion([paymentData]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add payment: $e');
    }
  }

  // Remove a payment from an invoice
  static Future<void> removePayment(String invoiceId, Map<String, dynamic> paymentData) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(invoiceId)
          .update({
        'payments': FieldValue.arrayRemove([paymentData]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to remove payment: $e');
    }
  }

  // Update invoice status
  static Future<void> updateInvoiceStatus(String invoiceId, String status) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(invoiceId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update invoice status: $e');
    }
  }

  // Get invoices by status
  static Future<List<Map<String, dynamic>>> getInvoicesByStatus(String status) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collectionName)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch invoices by status: $e');
    }
  }

  // Get invoices by customer
  static Future<List<Map<String, dynamic>>> getInvoicesByCustomer(String customerEmail) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collectionName)
          .where('customerEmail', isEqualTo: customerEmail)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch invoices by customer: $e');
    }
  }

  // Search invoices by customer name or invoice ID
  static Future<List<Map<String, dynamic>>> searchInvoices(String searchTerm) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a simple implementation that searches by customer name
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('customerName')
          .startAt([searchTerm])
          .endAt([searchTerm + '\uf8ff'])
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search invoices: $e');
    }
  }

  // Listen to real-time updates for invoices
  static Stream<List<Map<String, dynamic>>> getInvoicesStream() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Listen to real-time updates for a specific invoice
  static Stream<Map<String, dynamic>?> getInvoiceStream(String invoiceId) {
    return _firestore
        .collection(_collectionName)
        .doc(invoiceId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        data['id'] = snapshot.id;
        return data;
      }
      return null;
    });
  }
}
