import 'package:dartz/dartz.dart';
import 'package:entertainer/core/errors/failure.dart';
import 'package:entertainer/features/auth/domain/entities/user.dart';
import 'package:entertainer/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:entertainer/features/auth/domain/usecases/google_auth_usecase.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> register(String fullName, String email, String phone, String password);
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> forgotPassword(String email);
  Future<Either<Failure, void>> resetPassword(String token, String newPassword);
  Future<Either<Failure, User>> updateProfile(UpdateProfileParams params);
  Future<Either<Failure, User>> googleAuth(String idToken);
}