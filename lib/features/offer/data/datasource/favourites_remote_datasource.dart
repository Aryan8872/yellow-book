import 'package:dio/dio.dart';
import 'package:entertainer/core/network/api_endpoints.dart';
import 'package:entertainer/features/offer/data/model/offer_model.dart';
import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';
import 'package:injectable/injectable.dart';

/// Remote data source for the favourites (saved offers) feature.
@lazySingleton
class FavouritesRemoteDataSource {
  final Dio _dio;

  FavouritesRemoteDataSource(this._dio);

  /// Toggle favourite for an offer. Returns whether the offer is now favourited.
  Future<bool> toggleFavourite(String offerId) async {
    final response = await _dio.post(ApiEndpoints.offerFavourite(offerId));
    final raw = response.data;

    // Unwrap NestJS envelope (P6 object case, mirrors redemption datasource)
    final Map<String, dynamic> payload;
    if (raw is Map) {
      final inner = raw['data'];
      payload = inner is Map
          ? Map<String, dynamic>.from(inner)
          : Map<String, dynamic>.from(raw);
    } else {
      payload = {};
    }
    return (payload['isFavourite'] as bool?) ?? false;
  }

  /// Get the authenticated user's paginated list of saved offers.
  Future<List<OfferEntity>> getFavourites({int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      ApiEndpoints.favourites,
      queryParameters: {'page': page, 'limit': limit},
    );
    final raw = response.data;

    // Unwrap NestJS envelope (P6 object case) — {success, data: {offers: [...]}}
    final Map<String, dynamic> payload;
    if (raw is Map) {
      final inner = raw['data'];
      payload = inner is Map
          ? Map<String, dynamic>.from(inner)
          : Map<String, dynamic>.from(raw);
    } else {
      payload = {};
    }

    final offers = payload['offers'] as List<dynamic>? ?? [];
    return offers
        .whereType<Map>()
        .map((o) => OfferModel.fromJson(Map<String, dynamic>.from(o)).toEntity())
        .toList();
  }
}
