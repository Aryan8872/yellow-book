abstract class Failure {
  final String message;
  final String? errorCode;
  final int? statusCode;

  const Failure(this.message, {this.errorCode, this.statusCode});

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Server error occurred',
    String? errorCode,
    int? statusCode,
  ]) : super(errorCode: errorCode, statusCode: statusCode);

  const ServerFailure.withDetails(
    super.message, {
    super.errorCode,
    super.statusCode,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'No Internet connection',
    String? errorCode,
    int? statusCode,
  ]) : super(errorCode: errorCode, statusCode: statusCode);

  const NetworkFailure.withDetails(
    super.message, {
    super.errorCode,
    super.statusCode,
  });
}

class AuthFailure extends Failure {
  const AuthFailure([
    super.message = 'Authentication failed',
    String? errorCode,
    int? statusCode,
  ]) : super(errorCode: errorCode, statusCode: statusCode);

  const AuthFailure.withDetails(
    super.message, {
    super.errorCode,
    super.statusCode,
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure([
    super.message = 'Validation error occurred',
    String? errorCode,
    int? statusCode,
  ]) : super(errorCode: errorCode, statusCode: statusCode);

  const ValidationFailure.withDetails(
    super.message, {
    super.errorCode,
    super.statusCode,
  });
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([
    super.message = 'Resource not found',
    String? errorCode,
    int? statusCode,
  ]) : super(errorCode: errorCode, statusCode: statusCode);

  const NotFoundFailure.withDetails(
    super.message, {
    super.errorCode,
    super.statusCode,
  });
}

class RateLimitFailure extends Failure {
  const RateLimitFailure([
    super.message = 'Too many requests. Please slow down.',
    String? errorCode,
    int? statusCode,
  ]) : super(errorCode: errorCode, statusCode: statusCode);

  const RateLimitFailure.withDetails(
    super.message, {
    super.errorCode,
    super.statusCode,
  });
}