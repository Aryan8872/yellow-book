import 'package:dio/dio.dart';
import 'package:entertainer/core/network/api_endpoints.dart';
import 'package:entertainer/features/offer/data/model/redemption_model.dart';

abstract class RedemptionRemoteDatasource {
  Future<RedemptionModel> initRedemption(String offerId);
  Future<List<RedemptionModel>> getMyRedemptions();
}

class RedemptionRemoteDatasourceImpl implements RedemptionRemoteDatasource {
  final Dio dio;

  RedemptionRemoteDatasourceImpl(this.dio);

  @override
  Future<RedemptionModel> initRedemption(String offerId) async {
    final response = await dio.post(ApiEndpoints.redeemInit(offerId));
    final raw = response.data;

    // Unwrap NestJS envelope
    final Map<String, dynamic> payload;
    if (raw is Map) {
      final inner = raw['data'];
      payload = inner is Map
          ? Map<String, dynamic>.from(inner)
          : Map<String, dynamic>.from(raw);
    } else {
      payload = {};
    }

    return RedemptionModel.fromJson(payload);
  }

  @override
  Future<List<RedemptionModel>> getMyRedemptions() async {
    final response = await dio.get(ApiEndpoints.myRedemptions);
    final raw = response.data;

    // Unwrap envelope — expect { data: [...] } or { data: { items: [...] } }
    List<dynamic> list = [];
    if (raw is Map) {
      final inner = raw['data'];
      if (inner is List) {
        list = inner;
      } else if (inner is Map) {
        final items = inner['items'] ?? inner['redemptions'] ?? [];
        if (items is List) list = items;
      }
    } else if (raw is List) {
      list = raw;
    }

    return list
        .whereType<Map>()
        .map((e) => RedemptionModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
