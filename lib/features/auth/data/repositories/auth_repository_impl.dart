import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:entertainer/core/errors/failure.dart';
import 'package:entertainer/core/storage/token_storage.dart';
import 'package:entertainer/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:entertainer/features/auth/data/model/user_model.dart';
import 'package:entertainer/features/auth/domain/entities/user.dart';
import 'package:entertainer/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remote;
  final TokenStorage storage;

  AuthRepositoryImpl({required this.remote, required this.storage});
  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final dto = await remote.login(email, password);
      storage.save(dto.accessToken, dto.refreshToken);
      final user = User(
        id: dto.data.id,
        email: dto.data.email,
        name: dto.data.name,
        phone: dto.data.phone,
      );
      return Right(user);
    } on DioException catch (e) {
      final serverMessage = e.response?.data is Map
          ? (e.response?.data['message'] ?? e.response?.data['error'])
          : null;
      return Left(ServerFailure(serverMessage?.toString() ?? e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> logout() async {
    storage.clear();
  }

  @override
  Future<Either<Failure, User>> register(
    String fullName,
    String email,
    String phone,
    String password,
  ) async {
    try {
      final model = UserModel(
        email: email,
        name: fullName,
        phone: phone,
        password: password,
      );
      final dto = await remote.register(model);
      storage.save(dto.accessToken, dto.refreshToken);
      final user = User(
        id: dto.data.id,
        email: dto.data.email,
        name: dto.data.name,
        phone: dto.data.phone,
      );
      return Right(user);
    } on DioException catch (e) {
      final serverMessage = e.response?.data is Map
          ? (e.response?.data['message'] ?? e.response?.data['error'])
          : null;
      return Left(ServerFailure(serverMessage?.toString() ?? e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
