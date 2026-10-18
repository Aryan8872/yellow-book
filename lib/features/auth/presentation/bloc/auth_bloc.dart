import 'package:entertainer/core/usecase/usecase.dart';
import 'package:entertainer/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:entertainer/features/auth/domain/usecases/login_params.dart';
import 'package:entertainer/features/auth/domain/usecases/login_usecase.dart';
import 'package:entertainer/features/auth/domain/usecases/logout_usecase.dart';
import 'package:entertainer/features/auth/domain/usecases/register_params.dart';
import 'package:entertainer/features/auth/domain/usecases/register_usecase.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_event.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase _loginUsecase;
  final RegisterUsecase _registerUsecase;
  final GetCurrentUserUsecase _getCurrentUserUsecase;
  final LogoutUsecase _logoutUsecase;

  AuthBloc(
    this._loginUsecase,
    this._registerUsecase,
    this._getCurrentUserUsecase,
    this._logoutUsecase,
  ) : super(const AuthInitial()) {
    on<CheckAuthStatusRequested>(_onCheckAuthStatusRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthStatusRequested(
    CheckAuthStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _getCurrentUserUsecase.call(const NoParams());
    result.fold(
      (failure) => emit(const AuthInitial()),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _loginUsecase.call(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _registerUsecase.call(
      RegisterParams(
        name: event.fullName,
        email: event.email,
        phone: event.phone,
        password: event.password,
      ),
    );
    result.fold(
      (error) => emit(AuthError(error.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await _logoutUsecase.call(const NoParams());
    emit(const AuthInitial());
  }
}
