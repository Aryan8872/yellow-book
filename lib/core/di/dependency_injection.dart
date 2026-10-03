import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/dio_client.dart';
import '../storage/token_storage.dart';
import '../../features/auth/data/datasources/remote/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/offer/data/datasource/remote_data_source.dart';
import '../../features/offer/data/repository/offer_repository_impl.dart';
import '../../features/offer/domain/repository/offer_repository.dart';

// Compile-time environment variable evaluation required for Dart Web / DDC
const String _envBaseUrl = String.fromEnvironment('BASE_URL', defaultValue: '');

@module
abstract class DependencyInjection {
  @LazySingleton()
  TokenStorage get tokenStorage => TokenStorage();

  @LazySingleton()
  Dio dio(TokenStorage storage) {
    const defaultWebUrl = 'https://yellow-bookapi-production.up.railway.app/api/v1';
    const defaultAndroidUrl = 'https://yellow-bookapi-production.up.railway.app/api/v1';

    final baseUrl = _envBaseUrl.isNotEmpty
        ? _envBaseUrl
        : (kIsWeb ? defaultWebUrl : defaultAndroidUrl);

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        storage: storage,
        baseUrl: baseUrl,
      ),
    );

    return dio;
  }

  @LazySingleton()
  AuthRemoteDatasource authRemoteDatasource(Dio dio) => AuthRemoteDataSourceImpl(dio);

  @LazySingleton()
  HomeRemoteDataSource homeRemoteDataSource() => HomeRemoteDataSourceImpl();

  @lazySingleton
  DioClient dioClient(Dio dio, TokenStorage ts, AuthRemoteDatasource authRemote) =>
      DioClient(
        dio: dio,
        storage: ts,
        authRemote: authRemote,
        baseUrl: _envBaseUrl.isNotEmpty
            ? _envBaseUrl
            : (kIsWeb ? 'https://yellow-bookapi-production.up.railway.app/api/v1' : 'https://yellow-bookapi-production.up.railway.app/api/v1'),
      );

  @lazySingleton
  AuthRepository authRepository(AuthRemoteDatasource remote, TokenStorage ts) =>
      AuthRepositoryImpl(remote: remote, storage: ts);

  @lazySingleton
  HomeRepository homeRepository(HomeRemoteDataSource remote) =>
      HomeRepositoryImpl(remoteDataSource: remote);

  @LazySingleton()
  RemoteDataSource offerRemoteDataSource(Dio dio) => RemoteDataSourceImpl(dio);

  @lazySingleton
  OfferRepository offerRepository(RemoteDataSource remote) =>
      OfferRepositoryImpl(remote);
}
