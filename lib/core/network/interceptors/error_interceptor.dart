import 'package:dio/dio.dart';
import '../../errors/failure.dart';

/// Interceptor that inspects Dio errors and enriches them with backend RFC 7807 problem details
/// and AppErrorCode information from NestJS.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final failure = mapDioExceptionToFailure(err);
    // Attach domain failure into request options extra for convenient consumption if desired
    err.requestOptions.extra['failure'] = failure;
    super.onError(err, handler);
  }

  static Failure mapDioExceptionToFailure(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return const NetworkFailure('No Internet connection or server timed out');
    }

    final response = err.response;
    if (response != null && response.data != null) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        final errorCode = data['errorCode'] as String?;
        final statusCode = response.statusCode ?? 500;

        String formattedMessage = 'Server error occurred';
        if (message is List) {
          formattedMessage = message.join(', ');
        } else if (message is String) {
          formattedMessage = message;
        }

        if (statusCode == 401) {
          return AuthFailure.withDetails(formattedMessage, errorCode: errorCode);
        } else if (statusCode == 400 || statusCode == 422) {
          return ValidationFailure.withDetails(formattedMessage, errorCode: errorCode);
        } else if (statusCode == 404) {
          return NotFoundFailure.withDetails(formattedMessage, errorCode: errorCode);
        } else if (statusCode == 429) {
          return RateLimitFailure.withDetails(formattedMessage, errorCode: errorCode);
        }

        return ServerFailure.withDetails(
          formattedMessage,
          errorCode: errorCode,
          statusCode: statusCode,
        );
      }
    }

    return ServerFailure(
      err.message ?? 'An unexpected network error occurred',
    );
  }
}
