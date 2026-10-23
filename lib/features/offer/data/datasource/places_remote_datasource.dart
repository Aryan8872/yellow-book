import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:entertainer/core/network/api_endpoints.dart';

class PlaceSuggestion {
  final String formatted;
  final String name;
  final String? district;
  final double lat;
  final double lon;
  final double confidence;

  PlaceSuggestion({
    required this.formatted,
    required this.name,
    this.district,
    required this.lat,
    required this.lon,
    required this.confidence,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      formatted: json['formatted'] as String? ?? json['name'] as String,
      name: json['name'] as String,
      district: json['district'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

class NearbyPlace {
  final String name;
  final double lat;
  final double lon;

  NearbyPlace({
    required this.name,
    required this.lat,
    required this.lon,
  });

  factory NearbyPlace.fromJson(Map<String, dynamic> json) {
    return NearbyPlace(
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }
}

@injectable
class PlacesRemoteDataSource {
  final Dio _dio;

  PlacesRemoteDataSource() : _dio = Dio();

  Future<List<PlaceSuggestion>> searchPlaces({
    required String query,
    double? lat,
    double? lon,
  }) async {
    try {
      final queryParams = <String, dynamic>{'query': query};
      if (lat != null) queryParams['lat'] = lat;
      if (lon != null) queryParams['lon'] = lon;

      final response = await _dio.get(
        ApiEndpoints.locationsSearch,
        queryParameters: queryParams,
      );

      final raw = response.data;

      // Unwrap envelope — expect { data: [...] } or a plain list
      List<dynamic> list = [];
      if (raw is Map) {
        final inner = raw['data'];
        if (inner is List) {
          list = inner;
        }
      } else if (raw is List) {
        list = raw;
      }

      return list
          .whereType<Map>()
          .map((e) => PlaceSuggestion.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<NearbyPlace>> reverse({
    required double lat,
    required double lon,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.locationsReverse,
        queryParameters: {
          'lat': lat,
          'lon': lon,
        },
      );

      final raw = response.data;

      // Unwrap envelope — expect { data: [...] } or a plain list
      List<dynamic> list = [];
      if (raw is Map) {
        final inner = raw['data'];
        if (inner is List) {
          list = inner;
        }
      } else if (raw is List) {
        list = raw;
      }

      return list
          .whereType<Map>()
          .map((e) => NearbyPlace.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
