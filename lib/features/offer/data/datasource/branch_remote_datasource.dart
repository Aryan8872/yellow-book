import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:entertainer/core/network/base_urls.dart';
import 'package:entertainer/core/di/service_loader.dart';

@injectable
class BranchRemoteDataSource {
  final Dio _dio;

  BranchRemoteDataSource() : _dio = getIt<Dio>();

  Future<List<Map<String, dynamic>>> getBranchesNear({
    required double lat,
    required double lng,
    double radiusKm = 5,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '${BaseUrls.current}/merchants/branches/near',
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'radiusKm': radiusKm,
          'limit': limit,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      // Error logged for debugging
      return [];
    }
  }
}
