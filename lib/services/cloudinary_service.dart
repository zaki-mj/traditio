import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;

class CloudinaryService {
  static const String cloudName = 'dpont9nhr';
  static const String uploadPreset = 'flutter_mobile_unsigned';

  /// Compress + upload in one flow
  static Future<List<String>> uploadImages(List<File> images) async {
    if (images.isEmpty) return [];

    final cloudinary = CloudinaryPublic(cloudName, uploadPreset, cache: false);
    final List<String> urls = [];
    final List<String> errors = [];

    for (final originalFile in images) {
      File? compressedFile;
      try {
        // --- Compress ---
        print('→ Original: ${originalFile.lengthSync() ~/ 1024} KB');

        final String dir = originalFile.parent.path;
        final String name = p.basenameWithoutExtension(originalFile.path);
        final String compressedPath = '$dir/compressed_${name}_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final XFile? result = await FlutterImageCompress.compressAndGetFile(originalFile.absolute.path, compressedPath, quality: 75, minWidth: 1280, minHeight: 1280, format: CompressFormat.jpeg);

        if (result == null) throw Exception('Compression failed');

        compressedFile = File(result.path);
        print('← Compressed: ${compressedFile.lengthSync() ~/ 1024} KB');

        // --- Upload immediately ---
        print('→ Uploading to Cloudinary...');
        final response = await cloudinary.uploadFile(CloudinaryFile.fromFile(compressedFile.path, resourceType: CloudinaryResourceType.Image, folder: 'traditional_gems/places'));

        final url = response.secureUrl;
        if (url.isNotEmpty && url.startsWith('https://')) {
          urls.add(url);
          print('✅ Uploaded successfully: $url');
        } else {
          errors.add('Invalid URL');
        }
      } catch (e) {
        print('❌ Failed for ${originalFile.path}: $e');
        errors.add(e.toString());
      } finally {
        // Clean up compressed file
        if (compressedFile != null && await compressedFile.exists()) {
          await compressedFile.delete().catchError((_) {});
        }
      }
    }

    print('Upload finished. Success: ${urls.length}, Errors: ${errors.length}');
    return urls;
  }
}
