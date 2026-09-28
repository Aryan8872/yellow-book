import 'package:dio/dio.dart';
import 'package:entertainer/core/network/dio_client.dart';
import 'package:entertainer/core/storage/token_storage.dart';
import 'package:entertainer/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:entertainer/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:entertainer/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@module
abstract class DependencyInjection {
  @LazySingleton()
  TokenStorage get tokenStorage =>TokenStorage();

  @LazySingleton()
  Dio dio()=>Dio(BaseOptions());

  @LazySingleton()
  AuthRemoteDatasource authRemoteDatasource(Dio dio)=>AuthRemoteDataSourceImpl(dio);

  @lazySingleton
  DioClient dioClient(Dio dio, TokenStorage ts, AuthRemoteDatasource authRemote) =>
      DioClient(dio: dio, storage: ts, authRemote: authRemote, baseUrl: 'https://your.api');

  @lazySingleton
  AuthRepository authRepository(AuthRemoteDatasource remote, TokenStorage ts) =>
      AuthRepositoryImpl(remote: remote, storage: ts);

  // @lazySingleton
  // LoginUseCase loginUseCase(AuthRepository repo) => LoginUseCase(repo);
}