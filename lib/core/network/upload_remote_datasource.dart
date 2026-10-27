import 'dart:io';
import 'package:dio/dio.dart';
import 'package:entertainer/core/network/api_endpoints.dart';

class UploadRemoteDatasource {
  final Dio dio;

  UploadRemoteDatasource(this.dio);

  /// Uploads an image file to backend /uploads?folder=avatars
  /// Returns the remote URL of the uploaded image.
  Future<String> uploadImage(File file, {String folder = 'avatars'}) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    final response = await dio.post(
      ApiEndpoints.uploads,
      data: formData,
      queryParameters: {'folder': folder},
    );

    final data = response.data;
    if (data is Map && data.containsKey('url')) {
      return data['url'] as String;
    } else if (data is Map && data['data'] is Map && (data['data'] as Map).containsKey('url')) {
      return (data['data'] as Map)['url'] as String;
    }
    throw StateError('Failed to parse uploaded image URL from server response');
  }
}
