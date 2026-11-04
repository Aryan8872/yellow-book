import 'package:smart_retry/smart_retry.dart';

class RetryHelper {
  /// Retry with exponential backoff (3 attempts, per user decision)
  static Future<T> retryWithBackoff<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 4),
    double factor = 2.0,
  }) async {
    return await SmartRetry.run(
      operation,
      maxAttempts: maxAttempts,
      initialDelay: initialDelay,
      maxDelay: maxDelay,
      factor: factor,
      backoffStrategy: BackoffStrategy.exponential,
      jitterStrategy: JitterStrategy.full,
      retryIf: _defaultRetryCondition,
    );
  }

  static bool _defaultRetryCondition(dynamic e) {
    // Retry on network errors, server errors, timeouts
    final errorStr = e.toString().toLowerCase();
    return errorStr.contains('socket') ||
           errorStr.contains('timeout') ||
           errorStr.contains('connection') ||
           errorStr.contains('5') || // 5xx errors
           errorStr.contains('network');
  }
}
