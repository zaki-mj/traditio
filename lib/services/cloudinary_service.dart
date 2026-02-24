import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  static const String cloudName = 'dpont9nhr'; // ← double-check this!
  static const String uploadPreset = 'flutter_mobile_unsigned'; // ← exact match, case-sensitive

  static Future<List<String>> uploadImages(List<File> images) async {
    if (images.isEmpty) return [];

    final cloudinary = CloudinaryPublic(cloudName, uploadPreset, cache: false);
    final List<String> urls = [];
    final List<String> errors = [];

    for (final file in images) {
      try {
        print('→ Attempting upload: ${file.path} (${file.lengthSync() ~/ 1024} KB)');

        final response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            file.path,
            resourceType: CloudinaryResourceType.Image,
            folder: 'traditional_gems/places', // optional
          ),
        );

        print('← Cloudinary raw response: ${response.toString()}');

        final url = response.secureUrl;
        if (url.isNotEmpty && url.startsWith('https://')) {
          urls.add(url);
          print('Success: $url');
        } else {
          final errMsg = 'Empty or invalid secureUrl: ${response.secureUrl}';
          print(errMsg);
          errors.add(errMsg);
        }
      } catch (e, stack) {
        final errMsg = 'Upload failed for ${file.path}: $e\n$stack';
        print(errMsg);
        errors.add(errMsg);
      }
    }

    if (errors.isNotEmpty) {
      print('↑↑↑ TOTAL ERRORS DURING UPLOAD: ${errors.length}');
      // You can show this in UI later if you want
    }

    return urls;
  }
}
