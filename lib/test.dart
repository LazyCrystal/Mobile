import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';

Future<String?> _convertToWebP(String imageUrl, String partNumber) async {
  try {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch image');
    }
    final imageBytes = response.bodyBytes;
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }
    // Since encodeWebP is not available, use the original bytes or convert to another format
    final uploadBytes = imageBytes; // Fallback to original format
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('inventory_images/$partNumber.jpg'); // Default to .jpg
    final uploadTask = await storageRef.putData(
        Uint8List.fromList(uploadBytes), SettableMetadata(contentType: 'image/jpeg'));
    return await uploadTask.ref.getDownloadURL();
  } catch (e) {
    print('❌ Failed to convert image to WebP: $e');
    return null;
  }
}