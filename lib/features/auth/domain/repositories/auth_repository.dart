
import 'package:dartz/dartz.dart';
import 'package:entertainer/core/errors/failure.dart';
import 'package:entertainer/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure,User>>login(String email,String password);
  Future<void> logout();
  Future<Either<Failure, User>> register(String fullName, String email,String phoneNumber, String password);
}