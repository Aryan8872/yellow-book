import 'package:dio/dio.dart';
import 'package:entertainer/core/network/api_endpoints.dart';

class SubscriptionCheckoutService {
  final Dio _dio;

  SubscriptionCheckoutService(this._dio);

  Future<List<Map<String, dynamic>>> fetchUserPlans() async {
    try {
      final res = await _dio.get(
        ApiEndpoints.subscriptionPlans,
        queryParameters: {'audience': 'USER'},
      );
      final raw = res.data;
      final List<dynamic> list = raw is Map && raw['data'] is List
          ? raw['data']
          : raw is List
              ? raw
              : [];
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> initiatePayment({
    required String planId,
    required String gateway, // 'KHALTI' or 'ESEWA'
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.initiatePayment,
        data: {
          'planId': planId,
          'gateway': gateway,
          'returnUrl': 'offernepal://payment-callback',
        },
      );
      final raw = res.data;
      if (raw is Map && raw['data'] is Map) {
        return Map<String, dynamic>.from(raw['data']);
      } else if (raw is Map) {
        return Map<String, dynamic>.from(raw);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> verifyPayment({
    required String gateway,
    required String orderId,
    String? token,
    String? refId,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.verifyPayment,
        data: {
          'gateway': gateway,
          'orderId': orderId,
          if (token != null) 'token': token,
          if (refId != null) 'refId': refId,
        },
      );
      final raw = res.data;
      return raw is Map && (raw['success'] == true || raw['data']?['success'] == true);
    } catch (_) {
      return false;
    }
  }
}
