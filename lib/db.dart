import 'package:cloud_firestore/cloud_firestore.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  DBHelper._init();

  // Firestore 集合：users
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

  /// 登录验证
  Future<bool> login(String username, String password) async {
    try {
      final snapshot = await usersCollection
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print("Login error: $e");
      return false;
    }
  }

  /// 添加用户
  Future<bool> addUser(String username, String password) async {
    try {
      final existing =
      await usersCollection.where('username', isEqualTo: username).get();

      if (existing.docs.isNotEmpty) {
        // 用户名已存在
        return false;
      }

      await usersCollection.add({
        'username': username,
        'password': password,
      });
      return true;
    } catch (e) {
      print("Add user error: $e");
      return false;
    }
  }

  /// 获取所有用户
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final snapshot = await usersCollection.get();
      return snapshot.docs
          .map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>
      })
          .toList();
    } catch (e) {
      print("Get users error: $e");
      return [];
    }
  }

  /// 删除用户
  Future<void> deleteUser(String username) async {
    try {
      final snapshot =
      await usersCollection.where('username', isEqualTo: username).get();

      for (var doc in snapshot.docs) {
        await usersCollection.doc(doc.id).delete();
      }
    } catch (e) {
      print("Delete user error: $e");
    }
  }

  /// 修改密码
  Future<void> updateUserPassword(
      String username, String newPassword) async {
    try {
      final snapshot =
      await usersCollection.where('username', isEqualTo: username).get();

      for (var doc in snapshot.docs) {
        await usersCollection.doc(doc.id).update({'password': newPassword});
      }
    } catch (e) {
      print("Update password error: $e");
    }
  }
}


