import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../network/dio_client.dart';
import '../storage/token_storage.dart';
import '../../features/auth/data/datasources/remote/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';

@module
abstract class DependencyInjection {
  @LazySingleton()
  TokenStorage get tokenStorage => TokenStorage();

  @LazySingleton()
  Dio dio() => Dio(BaseOptions());

  @LazySingleton()
  AuthRemoteDatasource authRemoteDatasource(Dio dio) => AuthRemoteDataSourceImpl(dio);

  @LazySingleton()
  HomeRemoteDataSource homeRemoteDataSource() => HomeRemoteDataSourceImpl();

  @lazySingleton
  DioClient dioClient(Dio dio, TokenStorage ts, AuthRemoteDatasource authRemote) =>
      DioClient(dio: dio, storage: ts, authRemote: authRemote, baseUrl: 'https://your.api');

  @lazySingleton
  AuthRepository authRepository(AuthRemoteDatasource remote, TokenStorage ts) =>
      AuthRepositoryImpl(remote: remote, storage: ts);

  @lazySingleton
  HomeRepository homeRepository(HomeRemoteDataSource remote) =>
      HomeRepositoryImpl(remoteDataSource: remote);
}
