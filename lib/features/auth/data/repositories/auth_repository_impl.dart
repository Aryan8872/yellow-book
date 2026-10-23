import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:entertainer/core/errors/failure.dart';
import 'package:entertainer/core/network/interceptors/error_interceptor.dart';
import 'package:entertainer/core/storage/token_storage.dart';
import 'package:entertainer/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:entertainer/features/auth/data/model/user_model.dart';
import 'package:entertainer/features/auth/domain/entities/user.dart';
import 'package:entertainer/features/auth/domain/repositories/auth_repository.dart';
import 'package:entertainer/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:entertainer/features/auth/domain/usecases/google_auth_usecase.dart';

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
        id: dto.user.id,
        email: dto.user.email,
        name: dto.user.name,
        phone: dto.user.phone,
      );
      return Right(user);
    } on DioException catch (e) {
      return Left(ErrorInterceptor.mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
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
        id: dto.user.id,
        email: dto.user.email,
        name: dto.user.name,
        phone: dto.user.phone,
      );
      return Right(user);
    } on DioException catch (e) {
      return Left(ErrorInterceptor.mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final safeUser = await remote.getMe();
      final user = User(
        id: safeUser.id,
        email: safeUser.email,
        name: safeUser.name,
        phone: safeUser.phone,
      );
      return Right(user);
    } on DioException catch (e) {
      return Left(ErrorInterceptor.mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remote.logout();
    } catch (_) {
      // Best effort remote revocation
    } finally {
      storage.clear();
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await remote.forgotPassword(email);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorInterceptor.mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String token, String newPassword) async {
    try {
      await remote.resetPassword(token, newPassword);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorInterceptor.mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile(UpdateProfileParams params) async {
    try {
      final safeUser = await remote.updateProfile(params);
      final user = User(
        id: safeUser.id,
        email: safeUser.email,
        name: safeUser.name,
        phone: safeUser.phone,
      );
      return Right(user);
    } on DioException catch (e) {
      return Left(ErrorInterceptor.mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> googleAuth(String idToken) async {
    try {
      final dto = await remote.googleAuth(idToken);
      storage.save(dto.accessToken, dto.refreshToken);
      final user = User(
        id: dto.user.id,
        email: dto.user.email,
        name: dto.user.name,
        phone: dto.user.phone,
      );
      return Right(user);
    } on DioException catch (e) {
      return Left(ErrorInterceptor.mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
