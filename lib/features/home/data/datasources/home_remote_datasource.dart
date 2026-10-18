import 'package:dio/dio.dart';
import 'package:entertainer/features/offer/data/model/offer_model.dart';

abstract class HomeRemoteDataSource {
  Future<HomeDataModel> fetchHomeData();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSourceImpl(this.dio);

  @override
  Future<HomeDataModel> fetchHomeData() async {
    final response = await dio.get('/offers/home');
    final raw = response.data;

    // Backend wraps: { success, statusCode, data: { featured, trending, popular } }
    // Unwrap the envelope if present.
    final Map<String, dynamic> payload;
    if (raw is Map) {
      final inner = raw['data'];
      if (inner is Map) {
        payload = Map<String, dynamic>.from(inner);
      } else {
        payload = Map<String, dynamic>.from(raw);
      }
    } else {
      payload = {};
    }

    return HomeDataModel.fromJson(payload);
  }
}

class HomeDataModel {
  final List<OfferModel> featured;
  final List<OfferModel> trending;
  final List<OfferModel> popular;

  HomeDataModel({
    required this.featured,
    required this.trending,
    required this.popular,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    List<OfferModel> parseList(dynamic raw) {
      if (raw is! List) return [];
      return raw.whereType<Map>().map((e) {
        return OfferModel.fromJson(Map<String, dynamic>.from(e));
      }).toList();
    }

    return HomeDataModel(
      featured: parseList(json['featured']),
      trending: parseList(json['trending']),
      popular: parseList(json['popular']),
    );
  }
}
