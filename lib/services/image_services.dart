
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:traditional_gems/models/place.dart';

class ImageService {
  final _picker = ImagePicker();
  final _storage = FirebaseStorage.instance;

  Future<List<XFile>> pickImages() async {
    return await _picker.pickMultiImage(imageQuality: 80, maxWidth: 1200);
  }

  Future<List<String>> uploadImages(List<XFile> images, String poiId) async {
    final List<String> imageUrls = [];
    for (int i = 0; i < images.length; i++) {
      // Generate a unique filename to avoid overwrites
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage.ref().child('pois/$poiId/image_${timestamp}_$i.jpg');
      await ref.putFile(File(images[i].path));
      imageUrls.add(await ref.getDownloadURL());
    }
    return imageUrls;
  }

  Future<void> deleteImageByUrl(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      // Log the error, but don't crash if the image doesn't exist
      print('Error deleting image by URL: $e');
    }
  }

  Future<void> deleteImages(List<String> urls) async {
    for (final url in urls) {
      await deleteImageByUrl(url);
    }
  }
}
