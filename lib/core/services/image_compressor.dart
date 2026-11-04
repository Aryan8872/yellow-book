import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';


class ImageCompressor {
  /// Compress image to target size with quality control
  /// Target: Max 2MB, 85% quality per user decision
  static Future<File> compressImage(
    File file, {
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 85,
    int targetSizeBytes = 2 * 1024 * 1024, // 2MB max
  }) async {
    // Check if already under size limit
    if (file.lengthSync() <= targetSizeBytes) {
      return file;
    }

    // First pass: resize + quality compression
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: maxWidth,
      minHeight: maxHeight,
      quality: quality,
      format: CompressFormat.jpeg,
    );

    if (result == null) {
      return file; // Return original if compression fails
    }

    // If still too large, progressively reduce quality
    int currentQuality = quality;
    Uint8List compressed = result;
    while (compressed.lengthInBytes > targetSizeBytes && currentQuality > 10) {
      currentQuality -= 10;
      final nextResult = await FlutterImageCompress.compressWithList(
        compressed,
        quality: currentQuality,
      );
      if (nextResult != null) {
        compressed = nextResult;
      }
    }

    // Write compressed file
    final compressedFile = File('${file.parent.path}/compressed_${file.uri.pathSegments.last}');
    await compressedFile.writeAsBytes(compressed);
    return compressedFile;
  }

  /// Compress from XFile (image_picker output)
  static Future<Uint8List?> compressXFile(
    XFile xfile, {
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 85,
  }) async {
    return await FlutterImageCompress.compressWithFile(
      xfile.path,
      minWidth: maxWidth,
      minHeight: maxHeight,
      quality: quality,
    );
  }
}
