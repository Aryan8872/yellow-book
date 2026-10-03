import 'dart:async';
import 'package:dio/dio.dart';
import 'package:entertainer/core/storage/token_storage.dart';
import 'package:entertainer/features/auth/data/model/auth_response.dart';

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
    final isAuthEndpoint = path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh');

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

    final isAuthEndpoint = path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh');

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
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

        final response = await refreshDio.post(
          '/auth/refresh',
          data: {'refreshToken': storage.refreshToken},
        );

        final authResponse = AuthResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );

        if (authResponse.accessToken.isNotEmpty) {
          storage.save(
            authResponse.accessToken,
            authResponse.refreshToken.isNotEmpty ? authResponse.refreshToken : storage.refreshToken!,
          );

          final retryDio = Dio(BaseOptions(baseUrl: baseUrl));
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
