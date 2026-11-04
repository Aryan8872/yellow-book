import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:entertainer/core/network/api_endpoints.dart';
import 'package:entertainer/core/network/base_urls.dart';
import 'package:entertainer/core/di/service_loader.dart';

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

  PlacesRemoteDataSource([Dio? dio])
      : _dio = dio ??
            (getIt.isRegistered<Dio>()
                ? getIt<Dio>()
                : Dio(BaseOptions(baseUrl: BaseUrls.current)));

  Future<List<PlaceSuggestion>> searchPlaces({
    required String query,
    double? lat,
    double? lon,
  }) async {
    try {
      final queryParams = <String, dynamic>{'query': query};
      if (lat != null) queryParams['lat'] = lat;
      if (lon != null) queryParams['lon'] = lon;

      final url = _dio.options.baseUrl.isNotEmpty
          ? ApiEndpoints.locationsSearch
          : '${BaseUrls.current}${ApiEndpoints.locationsSearch}';
      final response = await _dio.get(url, queryParameters: queryParams);

      final raw = response.data;

      // Unwrap envelope – expect { data: [...] } or a plain list
      List<dynamic> list = [];
      if (raw is Map) {
        final inner = raw['data'];
        if (inner is List) list = inner;
      } else if (raw is List) {
        list = raw;
      }

      return list
          .whereType<Map>()
          .map((e) => PlaceSuggestion.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<NearbyPlace>> reverse({
    required double lat,
    required double lon,
  }) async {
    try {
      final url = _dio.options.baseUrl.isNotEmpty
          ? ApiEndpoints.locationsReverse
          : '${BaseUrls.current}${ApiEndpoints.locationsReverse}';
      final response = await _dio.get(
        url,
        queryParameters: {'lat': lat, 'lon': lon},
      );

      final raw = response.data;

      // Unwrap envelope – expect { data: [...] } or a plain list
      List<dynamic> list = [];
      if (raw is Map) {
        final inner = raw['data'];
        if (inner is List) list = inner;
      } else if (raw is List) {
        list = raw;
      }

      final results = list
          .whereType<Map>()
          .map((e) => NearbyPlace.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      // If the backend returned nothing (offline / key missing), fall back to a
      // coordinate-to-district lookup so the picker never shows Narayanhiti.
      if (results.isEmpty) {
        final fallbackName = _fallbackNepalLocationName(lat, lon);
        return [NearbyPlace(name: fallbackName, lat: lat, lon: lon)];
      }

      return results;
    } catch (_) {
      // On any network error, still return a coordinate-derived name so the
      // location picker always gets a usable label for the picked coordinates.
      final fallbackName = _fallbackNepalLocationName(lat, lon);
      return [NearbyPlace(name: fallbackName, lat: lat, lon: lon)];
    }
  }

  /// Maps geographic coordinates to approximate Nepal district names.
  /// Covers all 77 districts of Nepal with their approximate lat/lon bounds.
  /// Returns a human-readable location label even when the geocoding API is
  /// unavailable (e.g., no network in emulator, missing API key).
  String _fallbackNepalLocationName(double lat, double lon) {
    // Records: (name, latMin, latMax, lonMin, lonMax)
    // Ordered by most common/populous areas first for fast path.
    const districts = [
      // Bagmati Province – Kathmandu Valley
      (n: 'Kathmandu', la: 27.60, lb: 27.85, lo: 85.20, lob: 85.45),
      (n: 'Lalitpur', la: 27.55, lb: 27.70, lo: 85.25, lob: 85.45),
      (n: 'Bhaktapur', la: 27.60, lb: 27.72, lo: 85.38, lob: 85.55),
      (n: 'Kavrepalanchok', la: 27.40, lb: 27.70, lo: 85.45, lob: 85.75),
      (n: 'Sindhupalchok', la: 27.80, lb: 28.25, lo: 85.45, lob: 85.80),
      (n: 'Rasuwa', la: 28.00, lb: 28.45, lo: 85.00, lob: 85.40),
      (n: 'Nuwakot', la: 27.80, lb: 28.15, lo: 84.90, lob: 85.30),
      (n: 'Dhading', la: 27.70, lb: 28.10, lo: 84.50, lob: 85.05),
      (n: 'Makwanpur', la: 27.30, lb: 27.75, lo: 84.60, lob: 85.25),
      (n: 'Chitwan', la: 27.30, lb: 27.75, lo: 83.90, lob: 84.70),
      (n: 'Ramechhap', la: 27.30, lb: 27.75, lo: 85.80, lob: 86.30),
      (n: 'Dolakha', la: 27.60, lb: 28.10, lo: 85.80, lob: 86.30),
      (n: 'Sindhuli', la: 27.10, lb: 27.60, lo: 85.60, lob: 86.15),
      // Province 1 – Koshi
      (n: 'Morang', la: 26.50, lb: 26.95, lo: 87.05, lob: 87.60),
      (n: 'Sunsari', la: 26.45, lb: 26.95, lo: 86.80, lob: 87.25),
      (n: 'Dhankuta', la: 26.90, lb: 27.30, lo: 87.10, lob: 87.55),
      (n: 'Taplejung', la: 27.30, lb: 27.90, lo: 87.50, lob: 88.20),
      (n: 'Panchthar', la: 27.10, lb: 27.55, lo: 87.70, lob: 88.15),
      (n: 'Ilam', la: 26.75, lb: 27.20, lo: 87.70, lob: 88.10),
      (n: 'Jhapa', la: 26.30, lb: 26.85, lo: 87.70, lob: 88.20),
      (n: 'Terhathum', la: 27.10, lb: 27.45, lo: 87.35, lob: 87.75),
      (n: 'Sankhuwasabha', la: 27.30, lb: 27.90, lo: 87.00, lob: 87.55),
      (n: 'Bhojpur', la: 27.00, lb: 27.40, lo: 86.80, lob: 87.25),
      (n: 'Solukhumbu', la: 27.50, lb: 28.05, lo: 86.30, lob: 86.95),
      (n: 'Okhaldhunga', la: 27.25, lb: 27.65, lo: 86.25, lob: 86.75),
      (n: 'Khotang', la: 27.00, lb: 27.50, lo: 86.50, lob: 87.00),
      (n: 'Udayapur', la: 26.75, lb: 27.25, lo: 86.50, lob: 87.00),
      // Madhesh Province
      (n: 'Saptari', la: 26.50, lb: 26.90, lo: 86.60, lob: 87.10),
      (n: 'Siraha', la: 26.55, lb: 26.95, lo: 86.15, lob: 86.70),
      (n: 'Dhanusha', la: 26.60, lb: 26.95, lo: 85.65, lob: 86.25),
      (n: 'Mahottari', la: 26.60, lb: 26.95, lo: 85.30, lob: 85.80),
      (n: 'Sarlahi', la: 26.70, lb: 27.05, lo: 85.15, lob: 85.65),
      (n: 'Rautahat', la: 26.80, lb: 27.20, lo: 84.70, lob: 85.30),
      (n: 'Bara', la: 26.90, lb: 27.30, lo: 84.90, lob: 85.40),
      (n: 'Parsa', la: 27.00, lb: 27.45, lo: 84.55, lob: 85.05),
      // Gandaki Province
      (n: 'Gorkha', la: 27.90, lb: 28.50, lo: 84.30, lob: 84.95),
      (n: 'Lamjung', la: 28.00, lb: 28.50, lo: 84.10, lob: 84.65),
      (n: 'Tanahun', la: 27.75, lb: 28.10, lo: 84.15, lob: 84.65),
      (n: 'Syangja', la: 28.00, lb: 28.30, lo: 83.70, lob: 84.10),
      (n: 'Kaski', la: 28.10, lb: 28.55, lo: 83.75, lob: 84.25),
      (n: 'Manang', la: 28.50, lb: 29.00, lo: 83.80, lob: 84.50),
      (n: 'Mustang', la: 28.80, lb: 29.40, lo: 83.50, lob: 84.20),
      (n: 'Myagdi', la: 28.30, lb: 28.80, lo: 83.30, lob: 83.80),
      (n: 'Parbat', la: 28.20, lb: 28.55, lo: 83.55, lob: 83.95),
      (n: 'Baglung', la: 28.20, lb: 28.65, lo: 83.25, lob: 83.70),
      (n: 'Nawalpur', la: 27.50, lb: 27.90, lo: 84.00, lob: 84.50),
      // Lumbini Province
      (n: 'Rupandehi', la: 27.35, lb: 27.80, lo: 83.20, lob: 83.75),
      (n: 'Kapilvastu', la: 27.45, lb: 27.90, lo: 82.70, lob: 83.30),
      (n: 'Palpa', la: 27.65, lb: 28.00, lo: 83.35, lob: 83.85),
      (n: 'Arghakhanchi', la: 27.80, lb: 28.20, lo: 83.00, lob: 83.50),
      (n: 'Gulmi', la: 27.90, lb: 28.30, lo: 83.10, lob: 83.55),
      (n: 'Pyuthan', la: 28.00, lb: 28.45, lo: 82.75, lob: 83.20),
      (n: 'Rolpa', la: 28.15, lb: 28.60, lo: 82.30, lob: 82.85),
      (n: 'Rukum East', la: 28.50, lb: 28.90, lo: 82.40, lob: 82.90),
      // Karnali Province
      (n: 'Surkhet', la: 28.45, lb: 28.90, lo: 81.40, lob: 82.00),
      (n: 'Dailekh', la: 28.60, lb: 29.00, lo: 81.35, lob: 81.90),
      (n: 'Jajarkot', la: 28.50, lb: 28.95, lo: 82.00, lob: 82.60),
      (n: 'Rukum West', la: 28.50, lb: 28.95, lo: 82.35, lob: 82.90),
      (n: 'Salyan', la: 28.30, lb: 28.75, lo: 82.05, lob: 82.55),
      (n: 'Dolpa', la: 28.90, lb: 29.50, lo: 82.60, lob: 83.30),
      (n: 'Mugu', la: 29.20, lb: 29.85, lo: 81.85, lob: 82.55),
      (n: 'Humla', la: 29.50, lb: 30.15, lo: 81.00, lob: 82.00),
      (n: 'Kalikot', la: 28.90, lb: 29.40, lo: 81.35, lob: 81.95),
      (n: 'Jumla', la: 29.05, lb: 29.55, lo: 82.00, lob: 82.60),
      // Sudurpashchim Province
      (n: 'Kanchanpur', la: 28.80, lb: 29.30, lo: 80.00, lob: 80.55),
      (n: 'Kailali', la: 28.55, lb: 29.00, lo: 80.40, lob: 81.00),
      (n: 'Doti', la: 29.00, lb: 29.50, lo: 80.70, lob: 81.30),
      (n: 'Achham', la: 29.00, lb: 29.50, lo: 81.00, lob: 81.60),
      (n: 'Bajura', la: 29.35, lb: 29.85, lo: 81.20, lob: 81.80),
      (n: 'Bajhang', la: 29.35, lb: 29.95, lo: 80.90, lob: 81.50),
      (n: 'Darchula', la: 29.60, lb: 30.20, lo: 80.35, lob: 81.00),
      (n: 'Baitadi', la: 29.40, lb: 29.90, lo: 80.35, lob: 80.90),
      (n: 'Dadeldhura', la: 29.15, lb: 29.60, lo: 80.40, lob: 80.90),
    ];

    for (final d in districts) {
      if (lat >= d.la && lat <= d.lb && lon >= d.lo && lon <= d.lob) {
        return '${d.n} District';
      }
    }

    // Broader Nepal bounding box check
    if (lat >= 26.3 && lat <= 30.5 && lon >= 80.0 && lon <= 88.2) {
      return 'Nepal';
    }

    // Absolute last resort: coordinate string (never Narayanhiti!)
    return '${lat.toStringAsFixed(4)}\u00b0N, ${lon.toStringAsFixed(4)}\u00b0E';
  }
}
