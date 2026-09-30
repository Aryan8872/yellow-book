// ignore_for_file: unused_field
import 'package:entertainer/features/auth/domain/entities/user.dart';
import 'package:entertainer/features/auth/domain/usecases/login_usecase.dart';
import 'package:entertainer/features/auth/domain/usecases/register_usecase.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_event.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase _loginUsecase;
  final RegisterUsecase _registerUsecase;

  AuthBloc(this._loginUsecase, this._registerUsecase) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    
    // Simulate smooth loading animation for client demo
    await Future.delayed(const Duration(milliseconds: 600));

    // DEMO BYPASS: Directly authenticate and go to Home Page
    emit(AuthAuthenticated(User(
      id: '1',
      email: event.email,
      fullName: 'Valued Client',
      phoneNumber: '+977 9800000000',
    )));

    /* --- REAL BACKEND API CALL (Commented out for demo) ---
    final result = await _loginUsecase.call(LoginParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
    ------------------------------------------------------- */
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    // Simulate smooth loading animation for client demo
    await Future.delayed(const Duration(milliseconds: 600));

    // DEMO BYPASS: Directly authenticate and go to Home Page
    emit(AuthAuthenticated(User(
      id: '1',
      email: event.email,
      fullName: event.fullName.isNotEmpty ? event.fullName : 'Valued Client',
      phoneNumber: event.phoneNumber,
    )));

    /* --- REAL BACKEND API CALL (Commented out for demo) ---
    final result = await _registerUsecase.call(
      RegisterParams(
        fullName: event.fullName,
        email: event.email,
        phoneNumber: event.phoneNumber,
        password: event.password,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
    ------------------------------------------------------- */
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthInitial());
  }
}
