// Auth-specific DTOs — standalone, no inheritance from ApiResponse.
// AuthResponse is a specialized envelope that carries tokens + user in a
// single response; forcing it into the generic ApiResponse<T> hierarchy only
// adds friction without benefit.

enum UserRole {
  user,
  merchantStaff,
  merchantAdmin,
  admin;

  factory UserRole.fromString(String value) {
    final normalized = value.trim().toUpperCase().replaceAll('_', '');
    return UserRole.values.firstWhere(
      (e) => e.name.toUpperCase() == normalized,
      orElse: () => UserRole.user,
    );
  }
}

class SafeUserResponse {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String phone;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  SafeUserResponse({
    required this.id,
    required this.email,
    required this.phone,
    required this.name,
    required this.role,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    this.deletedAt,
    this.updatedAt,
  });

  factory SafeUserResponse.fromJson(Map<String, dynamic> json) {
    return SafeUserResponse(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? json['full_name']?.toString() ?? '',
      phone: json['phone']?.toString() ??
          json['phoneNumber']?.toString() ??
          json['phone_number']?.toString() ??
          '',
      role: UserRole.fromString(json['role']?.toString() ?? 'USER'),
      isActive: json['isActive'] as bool? ?? true,
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      deletedAt: json['deletedAt'] != null
          ? DateTime.tryParse(json['deletedAt'].toString())
          : null,
    );
  }
}

/// Standalone DTO for auth endpoints (login / register / refresh).
/// Does NOT extend ApiResponse because the shape is fundamentally different:
/// it carries both tokens AND a user object in one envelope.
class AuthResponse {
  final bool success;
  final int statusCode;
  final String message;
  final DateTime? timestamp;
  final String? correlationId;

  final SafeUserResponse user;
  final String accessToken;
  final String refreshToken;

  AuthResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.timestamp,
    this.correlationId,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // ── envelope ─────────────────────────────────────────────────────────────
    // The NestJS TransformResponseInterceptor wraps everything under `data`.
    // Some auth endpoints put tokens directly in `data`, others nest under
    // `data.tokens` + `data.user`.
    Map<String, dynamic> dataMap = {};
    if (json['data'] is Map) {
      dataMap = Map<String, dynamic>.from(json['data'] as Map);
    } else {
      dataMap = json; // flat fallback
    }

    // ── user ─────────────────────────────────────────────────────────────────
    final Map<String, dynamic> userMap;
    if (dataMap['user'] is Map) {
      userMap = Map<String, dynamic>.from(dataMap['user'] as Map);
    } else if (json['user'] is Map) {
      userMap = Map<String, dynamic>.from(json['user'] as Map);
    } else {
      userMap = dataMap; // flat — user fields at same level as tokens
    }

    // ── tokens ────────────────────────────────────────────────────────────────
    Map<String, dynamic>? tokensMap;
    if (dataMap['tokens'] is Map) {
      tokensMap = Map<String, dynamic>.from(dataMap['tokens'] as Map);
    } else if (json['tokens'] is Map) {
      tokensMap = Map<String, dynamic>.from(json['tokens'] as Map);
    }

    final accessToken = tokensMap?['accessToken']?.toString() ??
        dataMap['accessToken']?.toString() ??
        json['accessToken']?.toString() ??
        '';

    final refreshToken = tokensMap?['refreshToken']?.toString() ??
        dataMap['refreshToken']?.toString() ??
        json['refreshToken']?.toString() ??
        '';

    // ── timestamp ─────────────────────────────────────────────────────────────
    DateTime? parsedTimestamp;
    final rawTs = json['timestamp'];
    if (rawTs is String) parsedTimestamp = DateTime.tryParse(rawTs);

    return AuthResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? 'Operation completed successfully',
      statusCode: (json['statusCode'] as num?)?.toInt() ?? 200,
      user: SafeUserResponse.fromJson(userMap),
      accessToken: accessToken,
      refreshToken: refreshToken,
      correlationId: json['correlationId']?.toString(),
      timestamp: parsedTimestamp,
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
}
