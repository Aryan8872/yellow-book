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
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/register_usecase.dart' as _i941;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
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
    gh.lazySingleton<_i973.TokenStorage>(
        () => dependencyInjection.tokenStorage);
    gh.lazySingleton<_i361.Dio>(() => dependencyInjection.dio());
    gh.lazySingleton<_i1022.AuthRemoteDatasource>(
        () => dependencyInjection.authRemoteDatasource(gh<_i361.Dio>()));
    gh.lazySingleton<_i667.DioClient>(() => dependencyInjection.dioClient(
          gh<_i361.Dio>(),
          gh<_i973.TokenStorage>(),
          gh<_i1022.AuthRemoteDatasource>(),
        ));
    gh.lazySingleton<_i787.AuthRepository>(
        () => dependencyInjection.authRepository(
              gh<_i1022.AuthRemoteDatasource>(),
              gh<_i973.TokenStorage>(),
            ));
    gh.factory<_i941.RegisterUsecase>(
        () => _i941.RegisterUsecase(gh<_i787.AuthRepository>()));
    gh.factory<_i188.LoginUsecase>(
        () => _i188.LoginUsecase(gh<_i787.AuthRepository>()));
    gh.factory<_i797.AuthBloc>(() => _i797.AuthBloc(
          gh<_i188.LoginUsecase>(),
          gh<_i941.RegisterUsecase>(),
        ));
    return this;
  }
}

class _$DependencyInjection extends _i9.DependencyInjection {}
