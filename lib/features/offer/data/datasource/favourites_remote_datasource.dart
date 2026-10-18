import 'package:dio/dio.dart';
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
    final response = await _dio.post('/offers/$offerId/favourite');
    final data = response.data as Map<String, dynamic>;
    return (data['isFavourite'] as bool?) ?? false;
  }

  /// Get the authenticated user's paginated list of saved offers.
  Future<List<OfferEntity>> getFavourites({int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      '/offers/favourites',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data as Map<String, dynamic>;
    final offers = data['offers'] as List<dynamic>? ?? [];
    return offers
        .map((o) => OfferModel.fromJson(Map<String, dynamic>.from(o as Map)).toEntity())
        .toList();
  }
}
