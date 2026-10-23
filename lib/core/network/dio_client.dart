import 'dart:async';
import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import '../../features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'base_urls.dart';

class DioClient {
  final Dio dio;
  final TokenStorage storage;
  final AuthRemoteDatasource authRemote;
  final String baseUrl;
  static const String _apiVersion = 'v1';
  bool _isRefreshing = false;

  // queue of pending requests (each holds the original RequestOptions and a completer)
  final List<_QueuedRequest> _queue = [];

  DioClient({
    required this.dio,
    required this.storage,
    required this.authRemote,
    String? baseUrl,
  }) : baseUrl = (baseUrl != null && baseUrl.isNotEmpty) ? baseUrl : BaseUrls.current {
    dio.options.baseUrl = this.baseUrl;
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add API version header
        options.headers['X-API-Version'] = _apiVersion;
        
        final access = storage.accessToken;
        if (access != null && access.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final status = error.response?.statusCode;
        final opts = error.requestOptions;

        // Handle rate limit (429) with exponential backoff retry
        if (status == 429) {
          final retryAfter = error.response?.headers['retry-after'];
          final delayMs = retryAfter != null 
              ? (int.tryParse(retryAfter.first) ?? 5) * 1000
              : 5000; // Default 5 seconds

          await Future.delayed(Duration(milliseconds: delayMs));
          
          // Retry the request once
          try {
            final resp = await dio.fetch(opts);
            return handler.resolve(resp);
          } catch (e) {
            return handler.next(error);
          }
        }

        if (status == 401 && storage.refreshToken != null && storage.refreshToken!.isNotEmpty) {
          if (_isRefreshing) {
            // queue this request and wait for refresh to complete
            final completer = Completer<Response<dynamic>>();
            _queue.add(_QueuedRequest(opts, completer));
            try {
              final resp = await completer.future;
              return handler.resolve(resp);
            } catch (e) {
              return handler.next(error);
            }
          }

          // no refresh running, start one
          _isRefreshing = true;
          try {
            final refreshed = await authRemote.refresh(storage.refreshToken!);
            // save new tokens
            storage.save(refreshed.accessToken, refreshed.refreshToken);

            // retry the original request with new token
            opts.headers['Authorization'] = 'Bearer ${storage.accessToken}';
            final resp = await dio.fetch(opts);
            handler.resolve(resp);

            // drain queue
            for (final qr in List<_QueuedRequest>.from(_queue)) {
              try {
                qr.requestOptions.headers['Authorization'] = 'Bearer ${storage.accessToken}';
                final r = await dio.fetch(qr.requestOptions);
                qr.completer.complete(r);
              } catch (e) {
                qr.completer.completeError(e);
              }
            }
            _queue.clear();
          } catch (e) {
            // refresh failed -> clear tokens and fail queued requests
            storage.clear();
            for (final qr in List<_QueuedRequest>.from(_queue)) {
              qr.completer.completeError(e);
            }
            _queue.clear();
            return handler.next(error);
          } finally {
            _isRefreshing = false;
          }
          return;
        }

        return handler.next(error);
      },
    ));
  }
}

class _QueuedRequest {
  final RequestOptions requestOptions;
  final Completer<Response<dynamic>> completer;

  _QueuedRequest(this.requestOptions, this.completer);
}