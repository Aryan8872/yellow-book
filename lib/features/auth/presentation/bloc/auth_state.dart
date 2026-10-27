import '../../domain/entities/user.dart';

sealed class AuthState {
  const AuthState();

  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(User user)? authenticated,
    T Function(User user)? profileUpdating,
    T Function(User user, String message)? profileUpdateFailure,
    T Function(String message)? error,
    T Function()? forgotPasswordSuccess,
    T Function()? resetPasswordSuccess,
  }) {
    final self = this;
    if (self is AuthInitial) {
      return initial != null ? initial() : null;
    }
    if (self is AuthLoading) {
      return loading != null ? loading() : null;
    }
    if (self is AuthAuthenticated) {
      return authenticated != null ? authenticated(self.user) : null;
    }
    if (self is AuthProfileUpdating) {
      return profileUpdating != null ? profileUpdating(self.user) : null;
    }
    if (self is AuthProfileUpdateFailure) {
      return profileUpdateFailure != null
          ? profileUpdateFailure(self.user, self.message)
          : null;
    }
    if (self is AuthError) {
      return error != null ? error(self.message) : null;
    }
    if (self is ForgotPasswordSuccess) {
      return forgotPasswordSuccess != null ? forgotPasswordSuccess() : null;
    }
    if (self is ResetPasswordSuccess) {
      return resetPasswordSuccess != null ? resetPasswordSuccess() : null;
    }
    return null;
  }
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
}

final class AuthProfileUpdating extends AuthState {
  final User user;
  const AuthProfileUpdating(this.user);
}

final class AuthProfileUpdateFailure extends AuthState {
  final User user;
  final String message;

  const AuthProfileUpdateFailure(this.user, this.message);
}

final class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

final class ForgotPasswordSuccess extends AuthState {
  const ForgotPasswordSuccess();
}

final class ResetPasswordSuccess extends AuthState {
  const ResetPasswordSuccess();
}
