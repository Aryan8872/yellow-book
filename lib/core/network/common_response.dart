class CommonResponse {
  final bool success;
  final int statusCode;
  final String? errorCode;
  final String message;
  final DateTime timestamp;
  final String correlationId;

  CommonResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    this.errorCode,
    required this.timestamp,
    required this.correlationId
  });
}
