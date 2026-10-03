import 'package:entertainer/core/network/common_response.dart';

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
      phone: json['phone']?.toString() ?? json['phoneNumber']?.toString() ?? json['phone_number']?.toString() ?? '',
      role: UserRole.fromString(json['role']?.toString() ?? 'USER'),
      isActive: json['isActive'] as bool? ?? true,
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'].toString()) : null,
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt'].toString()) : null,
    );
  }
}

class AuthResponse extends CommonResponse {
  final SafeUserResponse data;
  final String accessToken;
  final String refreshToken;

  AuthResponse({
    required this.data,
    required this.accessToken,
    required this.refreshToken,
    required super.success,
    required super.statusCode,
    required super.message,
    required super.timestamp,
    required super.correlationId,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final tokensMap = json['tokens'] is Map ? json['tokens'] as Map<String, dynamic> : null;
    return AuthResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      statusCode: (json['statusCode'] as num?)?.toInt() ?? 200,
      data: SafeUserResponse.fromJson((json['data'] is Map ? json['data'] : {}) as Map<String, dynamic>),
      accessToken: tokensMap?['accessToken']?.toString() ?? json['accessToken']?.toString() ?? '',
      refreshToken: tokensMap?['refreshToken']?.toString() ?? json['refreshToken']?.toString() ?? '',
      correlationId: json['correlationId']?.toString() ?? '',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
}
