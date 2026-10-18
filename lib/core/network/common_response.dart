class ApiResponse<T> {
  final bool success;
  final int statusCode;
  final String? errorCode;
  final String message;
  final T? data;
  final Map<String, dynamic>? meta;
  final DateTime? timestamp;
  final String? correlationId;

  const ApiResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    this.errorCode,
    this.data,
    this.meta,
    this.timestamp,
    this.correlationId,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic rawData) fromJsonT,
  ) {
    final rawTimestamp = json['timestamp'];
    DateTime? parsedTimestamp;
    if (rawTimestamp is String) {
      parsedTimestamp = DateTime.tryParse(rawTimestamp);
    }

    T? parsedData;
    if (json.containsKey('data') && json['data'] != null) {
      parsedData = fromJsonT(json['data']);
    }

    return ApiResponse<T>(
      success: json['success'] as bool? ?? true,
      statusCode: (json['statusCode'] as num?)?.toInt() ?? 200,
      errorCode: json['errorCode'] as String?,
      message: (json['message'] as String?) ?? 'Operation completed successfully',
      data: parsedData,
      meta: json['meta'] is Map<String, dynamic>
          ? json['meta'] as Map<String, dynamic>
          : null,
      timestamp: parsedTimestamp,
      correlationId: json['correlationId'] as String?,
    );
  }

  /// Helper factory for cases where data is already parsed or raw map/primitive
  factory ApiResponse.fromRawJson(Map<String, dynamic> json) {
    return ApiResponse.fromJson(json, (raw) => raw as T);
  }
}

/// Backwards compatibility alias for CommonResponse
typedef CommonResponse = ApiResponse<dynamic>;
