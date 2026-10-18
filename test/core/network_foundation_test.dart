import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:entertainer/core/network/base_urls.dart';
import 'package:entertainer/core/network/api_endpoints.dart';
import 'package:entertainer/core/network/common_response.dart';
import 'package:entertainer/core/network/interceptors/error_interceptor.dart';
import 'package:entertainer/core/errors/failure.dart';
import 'package:entertainer/core/storage/token_storage.dart';

void main() {
  group('Wave 1 Network Infrastructure Tests', () {
    test('BaseUrls resolves expected endpoints', () {
      expect(BaseUrls.androidEmulator, 'http://10.0.2.2:3000/api/v1');
      expect(BaseUrls.localHost, 'http://localhost:3000/api/v1');
      expect(BaseUrls.production, 'https://yellow-bookapi-production.up.railway.app/api/v1');
      expect(BaseUrls.current.isNotEmpty, isTrue);
    });

    test('ApiEndpoints maps correct authentication & catalog paths', () {
      expect(ApiEndpoints.login, '/auth/login');
      expect(ApiEndpoints.register, '/auth/register');
      expect(ApiEndpoints.refresh, '/auth/refresh');
      expect(ApiEndpoints.offersHome, '/offers/home');
      expect(ApiEndpoints.redeemInit('offer-123'), '/offers/offer-123/redeem-init');
    });

    test('ApiResponse parses NestJS TransformResponseInterceptor envelope successfully', () {
      final json = {
        'success': true,
        'statusCode': 200,
        'errorCode': 'SUCCESS',
        'message': 'Offers fetched successfully',
        'data': {'id': 'offer-1', 'title': '50% off Momo'},
        'meta': {'total': 1},
        'timestamp': '2026-10-12T10:00:00.000Z',
        'correlationId': 'corr-abc-123',
      };

      final response = ApiResponse.fromJson(
        json,
        (data) => Map<String, dynamic>.from(data as Map),
      );

      expect(response.success, isTrue);
      expect(response.statusCode, 200);
      expect(response.errorCode, 'SUCCESS');
      expect(response.message, 'Offers fetched successfully');
      expect(response.data?['title'], '50% off Momo');
      expect(response.correlationId, 'corr-abc-123');
    });

    test('ErrorInterceptor maps NestJS 401 response to AuthFailure with error code', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/auth/me'),
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: '/auth/me'),
          data: {
            'success': false,
            'statusCode': 401,
            'errorCode': 'UNAUTHORIZED',
            'message': 'Token expired or invalid',
          },
        ),
      );

      final failure = ErrorInterceptor.mapDioExceptionToFailure(dioError);
      expect(failure, isA<AuthFailure>());
      expect(failure.message, 'Token expired or invalid');
      expect(failure.errorCode, 'UNAUTHORIZED');
    });

    test('ErrorInterceptor maps connection timeout to NetworkFailure', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/offers'),
        type: DioExceptionType.connectionTimeout,
      );

      final failure = ErrorInterceptor.mapDioExceptionToFailure(dioError);
      expect(failure, isA<NetworkFailure>());
    });

    test('TokenStorage initializes, saves, and clears in memory without crashing', () {
      final storage = TokenStorage();
      expect(storage.accessToken, isNull);
      expect(storage.hasAccess(), isFalse);

      storage.save('access_123', 'refresh_456');
      expect(storage.accessToken, 'access_123');
      expect(storage.refreshToken, 'refresh_456');
      expect(storage.hasAccess(), isTrue);

      storage.clear();
      expect(storage.accessToken, isNull);
      expect(storage.refreshToken, isNull);
      expect(storage.hasAccess(), isFalse);
    });
  });
}
