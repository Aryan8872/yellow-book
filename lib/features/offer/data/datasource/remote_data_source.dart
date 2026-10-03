import 'package:dio/dio.dart';
import 'package:entertainer/features/offer/data/model/offer_response.dart';
import 'package:entertainer/features/offer/domain/usecases/offer_params.dart';

abstract class RemoteDataSource {
  Future<OfferResponse> getOfferById(GetOfferByIdParams params);
  Future<PaginatedOfferResponse> getPaginatedOffers(GetPaginatedOffersParams params);
  Future<OfferResponse> createOffer(CreateOfferParams params);
  Future<OfferResponse> updateOffer(UpdateOfferParams params);
  Future<bool> deleteOffer(DeleteOfferParams params);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final Dio dio;

  RemoteDataSourceImpl(this.dio);

  @override
  Future<OfferResponse> getOfferById(GetOfferByIdParams params) async {
    final response = await dio.get('/offers/${params.id}');
    return OfferResponse.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  @override
  Future<PaginatedOfferResponse> getPaginatedOffers(GetPaginatedOffersParams params) async {
    final response = await dio.get(
      '/offers',
      queryParameters: params.toQueryParameters(),
    );
    return PaginatedOfferResponse.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  @override
  Future<OfferResponse> createOffer(CreateOfferParams params) async {
    final response = await dio.post(
      '/offers',
      data: params.toJson(),
    );
    return OfferResponse.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  @override
  Future<OfferResponse> updateOffer(UpdateOfferParams params) async {
    final path = (params.merchantId != null && params.merchantId!.isNotEmpty)
        ? '/offers/${params.merchantId}/${params.offerId}'
        : '/offers/${params.offerId}';
    final response = await dio.patch(
      path,
      data: params.toJson(),
    );
    return OfferResponse.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  @override
  Future<bool> deleteOffer(DeleteOfferParams params) async {
    final path = (params.merchantId != null && params.merchantId!.isNotEmpty)
        ? '/offers/${params.merchantId}/${params.offerId}'
        : '/offers/${params.offerId}';
    await dio.delete(path);
    return true;
  }
}
