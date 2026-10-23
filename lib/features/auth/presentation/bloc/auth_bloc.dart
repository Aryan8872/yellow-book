import 'package:entertainer/core/usecase/usecase.dart';
import 'package:entertainer/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:entertainer/features/auth/domain/usecases/login_params.dart';
import 'package:entertainer/features/auth/domain/usecases/login_usecase.dart';
import 'package:entertainer/features/auth/domain/usecases/logout_usecase.dart';
import 'package:entertainer/features/auth/domain/usecases/register_params.dart';
import 'package:entertainer/features/auth/domain/usecases/register_usecase.dart';
import 'package:entertainer/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:entertainer/features/auth/domain/usecases/google_auth_usecase.dart';
import 'package:entertainer/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:entertainer/features/auth/domain/usecases/reset_password_usecase.dart';
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
  final UpdateProfileUsecase _updateProfileUsecase;
  final GoogleAuthUsecase _googleAuthUsecase;
  final ForgotPasswordUsecase _forgotPasswordUsecase;
  final ResetPasswordUsecase _resetPasswordUsecase;

  AuthBloc(
    this._loginUsecase,
    this._registerUsecase,
    this._getCurrentUserUsecase,
    this._logoutUsecase,
    this._updateProfileUsecase,
    this._googleAuthUsecase,
    this._forgotPasswordUsecase,
    this._resetPasswordUsecase,
  ) : super(const AuthInitial()) {
    on<CheckAuthStatusRequested>(_onCheckAuthStatusRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
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

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) {
      emit(const AuthError('User not authenticated'));
      return;
    }

    emit(const AuthLoading());
    final result = await _updateProfileUsecase.call(
      UpdateProfileParams(
        name: event.name,
        phone: event.phone,
        avatarUrl: event.avatarUrl,
      ),
    );
    result.fold(
      (error) => emit(AuthError(error.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onGoogleLoginRequested(
    GoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _googleAuthUsecase.call(
      GoogleAuthParams(idToken: event.idToken),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _forgotPasswordUsecase.call(event.email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const ForgotPasswordSuccess()),
    );
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _resetPasswordUsecase.call(
      event.token,
      event.newPassword,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const ResetPasswordSuccess()),
    );
  }
}
