import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../network/base_urls.dart';
import '../network/dio_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/error_interceptor.dart';
import '../storage/token_storage.dart';
import '../../features/auth/data/datasources/remote/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/datasources/category_remote_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/offer/data/datasource/remote_data_source.dart';
import '../../features/offer/data/datasource/redemption_remote_datasource.dart';
import '../../features/offer/data/repository/offer_repository_impl.dart';
import '../../features/offer/data/repository/redemption_repository_impl.dart';
import '../../features/offer/domain/repository/offer_repository.dart';
import '../../features/offer/domain/repository/redemption_repository.dart';

@module
abstract class DependencyInjection {
  @LazySingleton()
  TokenStorage get tokenStorage => TokenStorage();

  @LazySingleton()
  Dio dio(TokenStorage storage) {
    final baseUrl = BaseUrls.current;

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

    dio.interceptors.addAll([
      AuthInterceptor(
        storage: storage,
        baseUrl: baseUrl,
      ),
      ErrorInterceptor(),
    ]);

    return dio;
  }

  @LazySingleton()
  AuthRemoteDatasource authRemoteDatasource(Dio dio) => AuthRemoteDataSourceImpl(dio);

  @LazySingleton()
  HomeRemoteDataSource homeRemoteDataSource(Dio dio) => HomeRemoteDataSourceImpl(dio);

  @LazySingleton()
  CategoryRemoteDataSource categoryRemoteDataSource(Dio dio) => CategoryRemoteDataSourceImpl(dio);

  @lazySingleton
  DioClient dioClient(Dio dio, TokenStorage ts, AuthRemoteDatasource authRemote) =>
      DioClient(
        dio: dio,
        storage: ts,
        authRemote: authRemote,
        baseUrl: BaseUrls.current,
      );

  @lazySingleton
  AuthRepository authRepository(AuthRemoteDatasource remote, TokenStorage ts) =>
      AuthRepositoryImpl(remote: remote, storage: ts);

  @lazySingleton
  HomeRepository homeRepository(
    HomeRemoteDataSource homeRemote,
    CategoryRemoteDataSource categoryRemote,
  ) =>
      HomeRepositoryImpl(
        remoteDataSource: homeRemote,
        categoryRemoteDataSource: categoryRemote,
      );

  @LazySingleton()
  RemoteDataSource offerRemoteDataSource(Dio dio) => RemoteDataSourceImpl(dio);

  @LazySingleton()
  RedemptionRemoteDatasource redemptionRemoteDatasource(Dio dio) =>
      RedemptionRemoteDatasourceImpl(dio);

  @lazySingleton
  OfferRepository offerRepository(RemoteDataSource remote) =>
      OfferRepositoryImpl(remote);

  @lazySingleton
  RedemptionRepository redemptionRepository(
          RedemptionRemoteDatasource remote) =>
      RedemptionRepositoryImpl(remote);

  @LazySingleton()
  RedemptionRemoteDatasourceImpl redemptionRemoteDatasourceImpl(Dio dio) =>
      RedemptionRemoteDatasourceImpl(dio);
}

