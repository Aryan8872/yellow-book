import 'dart:async';
import 'package:dio/dio.dart';
import '../../storage/token_storage.dart';
import '../api_endpoints.dart';
import '../base_urls.dart';

/// Interceptor that handles:
/// 1. Attaching `Bearer <access_token>` to outgoing requests (except public auth endpoints).
/// 2. Concurrency-safe 401 handling: queues simultaneous requests while rotating the refresh token via POST /auth/refresh.
/// 3. Retrying queued requests upon successful rotation, or clearing session and rejecting if refresh fails.
class AuthInterceptor extends Interceptor {
  final TokenStorage storage;
  final String baseUrl;
  bool _isRefreshing = false;
  final List<_QueuedRequest> _queue = [];

  AuthInterceptor({
    required this.storage,
    required this.baseUrl,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.path;
    final isAuthEndpoint = path.contains(ApiEndpoints.login) ||
        path.contains(ApiEndpoints.register) ||
        path.contains(ApiEndpoints.refresh) ||
        path.contains(ApiEndpoints.forgotPassword) ||
        path.contains(ApiEndpoints.resetPassword);

    if (!isAuthEndpoint) {
      final token = storage.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;
    final options = err.requestOptions;
    final path = options.path;

    final isAuthEndpoint = path.contains(ApiEndpoints.login) ||
        path.contains(ApiEndpoints.register) ||
        path.contains(ApiEndpoints.refresh) ||
        path.contains(ApiEndpoints.forgotPassword) ||
        path.contains(ApiEndpoints.resetPassword);

    if (status == 401 && !isAuthEndpoint && storage.refreshToken != null && storage.refreshToken!.isNotEmpty) {
      if (_isRefreshing) {
        final completer = Completer<Response<dynamic>>();
        _queue.add(_QueuedRequest(options, completer));
        try {
          final response = await completer.future;
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
      }

      _isRefreshing = true;
      try {
        final refreshDio = Dio(
          BaseOptions(
            baseUrl: baseUrl.isNotEmpty ? baseUrl : BaseUrls.current,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

        final response = await refreshDio.post(
          ApiEndpoints.refresh,
          data: {'refreshToken': storage.refreshToken},
        );

        // NestJS returns:
        // { success: true, statusCode: 200, data: { tokens: { accessToken, refreshToken, expiresIn } } }
        // or directly { tokens: { ... } } inside data
        final rawBody = response.data;
        Map<String, dynamic> dataMap = {};
        if (rawBody is Map<String, dynamic>) {
          if (rawBody.containsKey('data') && rawBody['data'] is Map<String, dynamic>) {
            dataMap = rawBody['data'] as Map<String, dynamic>;
          } else {
            dataMap = rawBody;
          }
        }

        final tokensMap = dataMap['tokens'] is Map<String, dynamic>
            ? dataMap['tokens'] as Map<String, dynamic>
            : dataMap;

        final newAccessToken = tokensMap['accessToken']?.toString() ?? '';
        final newRefreshToken = tokensMap['refreshToken']?.toString() ?? storage.refreshToken!;

        if (newAccessToken.isNotEmpty) {
          storage.save(newAccessToken, newRefreshToken);

          final retryDio = Dio(BaseOptions(baseUrl: baseUrl.isNotEmpty ? baseUrl : BaseUrls.current));
          options.headers['Authorization'] = 'Bearer ${storage.accessToken}';
          final retryResponse = await retryDio.fetch(options);
          handler.resolve(retryResponse);

          for (final item in List<_QueuedRequest>.from(_queue)) {
            try {
              item.options.headers['Authorization'] = 'Bearer ${storage.accessToken}';
              final res = await retryDio.fetch(item.options);
              item.completer.complete(res);
            } catch (e) {
              item.completer.completeError(e);
            }
          }
          _queue.clear();
          return;
        }
      } catch (refreshErr) {
        storage.clear();
        for (final item in List<_QueuedRequest>.from(_queue)) {
          item.completer.completeError(refreshErr);
        }
        _queue.clear();
        return handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    }

    return handler.next(err);
  }
}

class _QueuedRequest {
  final RequestOptions options;
  final Completer<Response<dynamic>> completer;

  _QueuedRequest(this.options, this.completer);
}
