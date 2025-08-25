import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class InventoryImage {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Function to pick image from gallery or local path
  Future<File?> pickImage({bool useLocalPath = false, String? localPath}) async {
    if (useLocalPath && localPath != null) {
      // For development: Use a specific local file
      if (await File(localPath).exists()) {
        return File(localPath);
      } else {
        print('Image not found at $localPath');
        return null;
      }
    } else {
      // For production: Pick from gallery
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      return image != null ? File(image.path) : null;
    }
  }

  // Function to upload image to Firebase Storage and get download URL
  Future<String?> uploadImage(File? image, String fileName) async {
    if (image == null) return null;

    try {
      // Upload to Firebase Storage under 'inventory_images' folder
      final storageRef = _storage.ref().child('inventory_images/$fileName');
      final uploadTask = await storageRef.putFile(image);

      // Get download URL
      final imageUrl = await uploadTask.ref.getDownloadURL();
      print('✅ Image uploaded: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('❌ Failed to upload image: $e');
      return null;
    }
  }
}