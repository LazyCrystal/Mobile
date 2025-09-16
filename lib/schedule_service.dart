import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ScheduleService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'appointments';

  // Count upcoming appointments (today and future)
  static Future<int> getUpcomingAppointmentsCount() async {
    try {
      final now = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(now);
      // Assumes docs have a 'date' string in yyyy-MM-dd format
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('date', isGreaterThanOrEqualTo: todayStr)
          .get();
      return snapshot.docs.length;
    } catch (_) {
      return 0;
    }
  }
}


