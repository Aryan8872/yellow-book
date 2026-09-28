import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:entertainer/core/errors/failure.dart';
import 'package:entertainer/core/storage/token_storage.dart';
import 'package:entertainer/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:entertainer/features/auth/domain/entities/user.dart';
import 'package:entertainer/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository{
  final AuthRemoteDatasource remote;
  final TokenStorage storage;

  AuthRepositoryImpl({required this.remote, required this.storage});
  @override
  Future<Either<Failure,User>> login(String email, String password)async {
    try{
      final dto = await remote.login(email, password);
      storage.save(dto.accessToken, dto.refreshToken);
      final user = User(id:  '', email: '',fullName: '',phoneNumber: '');
      return Right(user);
    }on DioException catch(e){
      return Left(ServerFailure(e.message ?? 'Server error'));
    }
    catch(e){
      return Left(ServerFailure(e.toString()));

    }
  }
  @override
  Future<void> logout()async {
    storage.clear();
  }

  @override
  Future<Either<Failure, User>> register(String fullName, String email, String phoneNumber, String password) async{
    try{
      final dto = await remote.register(fullName,email,phoneNumber,password);
      storage.save(dto.accessToken, dto.refreshToken);
      final user = User(id: '1',email: email,fullName: fullName,phoneNumber: phoneNumber);
      return Right(user);

    }on DioException catch(e){
      return Left(ServerFailure(e.message??'Server error'));
    }catch(e){
      return Left(ServerFailure(e.toString()));
    }
  }

}