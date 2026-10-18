import 'package:dio/dio.dart';
import 'package:entertainer/core/network/api_endpoints.dart';
import '../../model/auth_response.dart';
import '../../model/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> refresh(String refreshToken);
  Future<AuthResponse> register(UserModel user);
  Future<SafeUserResponse> getMe();
  Future<void> logout();
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String token, String newPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDatasource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<AuthResponse> login(String email, String password) async {
    final response = await dio.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );
    return AuthResponse.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  @override
  Future<AuthResponse> refresh(String refreshToken) async {
    final response = await dio.post(
      ApiEndpoints.refresh,
      data: {
        'refreshToken': refreshToken,
      },
    );
    return AuthResponse.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  @override
  Future<AuthResponse> register(UserModel user) async {
    final response = await dio.post(
      ApiEndpoints.register,
      data: user.toJson(),
    );
    return AuthResponse.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  @override
  Future<SafeUserResponse> getMe() async {
    final response = await dio.get(ApiEndpoints.me);
    final raw = response.data;
    Map<String, dynamic> dataMap = {};
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('data') && raw['data'] is Map<String, dynamic>) {
        dataMap = raw['data'] as Map<String, dynamic>;
      } else {
        dataMap = raw;
      }
    }
    final userMap = dataMap['user'] is Map
        ? Map<String, dynamic>.from(dataMap['user'] as Map)
        : dataMap;
    return SafeUserResponse.fromJson(userMap);
  }

  @override
  Future<void> logout() async {
    await dio.post(ApiEndpoints.logout);
  }

  @override
  Future<void> forgotPassword(String email) async {
    await dio.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    await dio.post(
      ApiEndpoints.resetPassword,
      data: {'token': token, 'password': newPassword},
    );
  }
}
