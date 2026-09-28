import 'package:dio/dio.dart';
import 'package:entertainer/features/auth/data/model/auth_response.dart';

abstract class AuthRemoteDatasource {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> refresh(String refreshToken);
  Future<AuthResponse> register(String fullName, String email,String phoneNumber, String password);
}
class AuthRemoteDataSourceImpl implements AuthRemoteDatasource{
  final Dio dio;
  AuthRemoteDataSourceImpl(this.dio);
  @override
  Future<AuthResponse> login(String email, String password)async {
    final resp = await dio.post('/auth/login',data: {
      "email":email,
      "password":password});
    return AuthResponse.fromJson(Map<String,dynamic>.from(resp.data));
  }

  @override
  Future<AuthResponse> refresh(String refreshToken) async{
    final resp = await dio.post('/auth/refresh',data: {
        'refreshToken':refreshToken});
    return AuthResponse.fromJson(Map<String,dynamic>.from(resp.data));
  }

  @override
  Future<AuthResponse> register(String fullName, String email, String phoneNumber, String password) async{
    final resp = await dio.post('/auth/register',data: {
      'email':email,
      'fullName':fullName,
      'phoneNumber':phoneNumber,
      'password':password
    });
    return AuthResponse.fromJson(Map<String,dynamic>.from(resp.data));
  }
  
}