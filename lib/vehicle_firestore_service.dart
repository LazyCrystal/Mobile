import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleService {
  final CollectionReference vehicles =
  FirebaseFirestore.instance.collection('vehicles');

  Future<void> addVehicle(Map<String, dynamic> data) {
    return vehicles.add(data);
  }

  Future<List<Map<String, dynamic>>> getVehicles() async {
    final snapshot = await vehicles.get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<void> updateVehicle(String id, Map<String, dynamic> data) {
    return vehicles.doc(id).update(data);
  }

  Future<void> deleteVehicle(String id) {
    return vehicles.doc(id).delete();
  }
}
