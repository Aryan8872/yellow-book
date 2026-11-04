import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressor {
  /// Compresses an image to a maximum of 2MB at 85% quality
  /// Returns the compressed bytes or original bytes if compression fails
  Future<Uint8List> compressImage(Uint8List bytes) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        quality: 85,
        minHeight: 800,
        minWidth: 800,
      );

      // If result is larger than 2MB, try reducing quality
      if (result.lengthInBytes > 2 * 1024 * 1024) {
        final fallback = await FlutterImageCompress.compressWithList(
          bytes,
          quality: 70,
          minHeight: 600,
          minWidth: 600,
        );
        return fallback;
      }

      return result;
    } catch (e) {
      // Return original bytes if compression fails
      return bytes;
    }
  }
}
