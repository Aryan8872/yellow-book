import 'package:dio/dio.dart';
import 'package:entertainer/features/auth/data/model/auth_response.dart';
import 'package:entertainer/features/auth/data/model/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> refresh(String refreshToken);
  Future<AuthResponse> register(UserModel user);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDatasource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<AuthResponse> login(String email, String password) async {
    final response = await dio.post(
      '/auth/login',
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
      '/auth/refresh',
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
      '/auth/register',
      data: user.toJson(),
    );
    return AuthResponse.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}
