// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/data/datasources/remote/auth_remote_datasource.dart'
    as _i1022;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/forgot_password_usecase.dart'
    as _i560;
import '../../features/auth/domain/usecases/get_current_user_usecase.dart'
    as _i17;
import '../../features/auth/domain/usecases/google_auth_usecase.dart' as _i372;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i48;
import '../../features/auth/domain/usecases/register_usecase.dart' as _i941;
import '../../features/auth/domain/usecases/reset_password_usecase.dart'
    as _i474;
import '../../features/auth/domain/usecases/update_profile_usecase.dart'
    as _i798;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/home/data/datasources/category_remote_datasource.dart'
    as _i222;
import '../../features/home/data/datasources/home_remote_datasource.dart'
    as _i278;
import '../../features/home/domain/repositories/home_repository.dart' as _i0;
import '../../features/home/domain/usecases/get_home_feed_usecase.dart'
    as _i1054;
import '../../features/home/presentation/bloc/home_bloc.dart' as _i202;
import '../../features/map/presentation/bloc/map_bloc.dart' as _i437;
import '../../features/offer/data/datasource/branch_remote_datasource.dart'
    as _i406;
import '../../features/offer/data/datasource/favourites_remote_datasource.dart'
    as _i750;
import '../../features/offer/data/datasource/redemption_remote_datasource.dart'
    as _i8;
import '../../features/offer/data/datasource/remote_data_source.dart' as _i710;
import '../../features/offer/domain/repository/offer_repository.dart' as _i275;
import '../../features/offer/domain/repository/redemption_repository.dart'
    as _i795;
import '../../features/offer/domain/usecases/offer_usecase.dart' as _i302;
import '../../features/offer/domain/usecases/redemption_usecase.dart' as _i405;
import '../../features/offer/presentation/bloc/favourites_bloc.dart' as _i1059;
import '../../features/offer/presentation/bloc/offers_bloc.dart' as _i728;
import '../../features/offer/presentation/bloc/redemption_bloc.dart' as _i790;
import '../network/dio_client.dart' as _i667;
import '../storage/token_storage.dart' as _i973;
import 'dependency_injection.dart' as _i9;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final dependencyInjection = _$DependencyInjection();
    gh.factory<_i406.BranchRemoteDataSource>(
        () => _i406.BranchRemoteDataSource());
    gh.lazySingleton<_i973.TokenStorage>(
        () => dependencyInjection.tokenStorage);
    gh.lazySingleton<_i361.Dio>(
        () => dependencyInjection.dio(gh<_i973.TokenStorage>()));
    gh.lazySingleton<_i1022.AuthRemoteDatasource>(
        () => dependencyInjection.authRemoteDatasource(gh<_i361.Dio>()));
    gh.lazySingleton<_i278.HomeRemoteDataSource>(
        () => dependencyInjection.homeRemoteDataSource(gh<_i361.Dio>()));
    gh.lazySingleton<_i222.CategoryRemoteDataSource>(
        () => dependencyInjection.categoryRemoteDataSource(gh<_i361.Dio>()));
    gh.lazySingleton<_i710.RemoteDataSource>(
        () => dependencyInjection.offerRemoteDataSource(gh<_i361.Dio>()));
    gh.lazySingleton<_i8.RedemptionRemoteDatasource>(
        () => dependencyInjection.redemptionRemoteDatasource(gh<_i361.Dio>()));
    gh.lazySingleton<_i8.RedemptionRemoteDatasourceImpl>(() =>
        dependencyInjection.redemptionRemoteDatasourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i750.FavouritesRemoteDataSource>(
        () => _i750.FavouritesRemoteDataSource(gh<_i361.Dio>()));
    gh.lazySingleton<_i275.OfferRepository>(() =>
        dependencyInjection.offerRepository(gh<_i710.RemoteDataSource>()));
    gh.lazySingleton<_i0.HomeRepository>(
        () => dependencyInjection.homeRepository(
              gh<_i278.HomeRemoteDataSource>(),
              gh<_i222.CategoryRemoteDataSource>(),
            ));
    gh.lazySingleton<_i667.DioClient>(() => dependencyInjection.dioClient(
          gh<_i361.Dio>(),
          gh<_i973.TokenStorage>(),
          gh<_i1022.AuthRemoteDatasource>(),
        ));
    gh.factory<_i1054.GetHomeFeedUseCase>(
        () => _i1054.GetHomeFeedUseCase(gh<_i0.HomeRepository>()));
    gh.lazySingleton<_i787.AuthRepository>(
        () => dependencyInjection.authRepository(
              gh<_i1022.AuthRemoteDatasource>(),
              gh<_i973.TokenStorage>(),
            ));
    gh.factory<_i560.ForgotPasswordUsecase>(
        () => _i560.ForgotPasswordUsecase(gh<_i787.AuthRepository>()));
    gh.factory<_i17.GetCurrentUserUsecase>(
        () => _i17.GetCurrentUserUsecase(gh<_i787.AuthRepository>()));
    gh.factory<_i372.GoogleAuthUsecase>(
        () => _i372.GoogleAuthUsecase(gh<_i787.AuthRepository>()));
    gh.factory<_i48.LogoutUsecase>(
        () => _i48.LogoutUsecase(gh<_i787.AuthRepository>()));
    gh.factory<_i941.RegisterUsecase>(
        () => _i941.RegisterUsecase(gh<_i787.AuthRepository>()));
    gh.factory<_i474.ResetPasswordUsecase>(
        () => _i474.ResetPasswordUsecase(gh<_i787.AuthRepository>()));
    gh.factory<_i798.UpdateProfileUsecase>(
        () => _i798.UpdateProfileUsecase(gh<_i787.AuthRepository>()));
    gh.factory<_i1059.FavouritesBloc>(
        () => _i1059.FavouritesBloc(gh<_i750.FavouritesRemoteDataSource>()));
    gh.lazySingleton<_i795.RedemptionRepository>(() => dependencyInjection
        .redemptionRepository(gh<_i8.RedemptionRemoteDatasource>()));
    gh.factory<_i302.GetOfferByIdUsecase>(
        () => _i302.GetOfferByIdUsecase(gh<_i275.OfferRepository>()));
    gh.factory<_i302.GetPaginatedOffersUsecase>(
        () => _i302.GetPaginatedOffersUsecase(gh<_i275.OfferRepository>()));
    gh.factory<_i302.CreateOfferUsecase>(
        () => _i302.CreateOfferUsecase(gh<_i275.OfferRepository>()));
    gh.factory<_i302.UpdateOfferUsecase>(
        () => _i302.UpdateOfferUsecase(gh<_i275.OfferRepository>()));
    gh.factory<_i302.DeleteOfferUsecase>(
        () => _i302.DeleteOfferUsecase(gh<_i275.OfferRepository>()));
    gh.factory<_i728.OffersBloc>(() => _i728.OffersBloc(
          gh<_i302.GetPaginatedOffersUsecase>(),
          gh<_i302.GetOfferByIdUsecase>(),
        ));
    gh.factory<_i188.LoginUsecase>(
        () => _i188.LoginUsecase(gh<_i787.AuthRepository>()));
    gh.factory<_i202.HomeBloc>(
        () => _i202.HomeBloc(gh<_i1054.GetHomeFeedUseCase>()));
    gh.factory<_i437.MapBloc>(
        () => _i437.MapBloc(gh<_i302.GetPaginatedOffersUsecase>()));
    gh.factory<_i405.InitRedemptionUsecase>(
        () => _i405.InitRedemptionUsecase(gh<_i795.RedemptionRepository>()));
    gh.factory<_i405.GetMyRedemptionsUsecase>(
        () => _i405.GetMyRedemptionsUsecase(gh<_i795.RedemptionRepository>()));
    gh.factory<_i405.CancelRedemptionUsecase>(
        () => _i405.CancelRedemptionUsecase(gh<_i795.RedemptionRepository>()));
    gh.factory<_i797.AuthBloc>(() => _i797.AuthBloc(
          gh<_i188.LoginUsecase>(),
          gh<_i941.RegisterUsecase>(),
          gh<_i17.GetCurrentUserUsecase>(),
          gh<_i48.LogoutUsecase>(),
          gh<_i798.UpdateProfileUsecase>(),
          gh<_i372.GoogleAuthUsecase>(),
          gh<_i560.ForgotPasswordUsecase>(),
          gh<_i474.ResetPasswordUsecase>(),
        ));
    gh.factory<_i790.RedemptionBloc>(() => _i790.RedemptionBloc(
          gh<_i405.InitRedemptionUsecase>(),
          gh<_i405.GetMyRedemptionsUsecase>(),
          gh<_i405.CancelRedemptionUsecase>(),
        ));
    return this;
  }
}

class _$DependencyInjection extends _i9.DependencyInjection {}
