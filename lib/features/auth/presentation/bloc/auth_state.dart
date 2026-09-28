import '../../domain/entities/user.dart';

sealed class AuthState {
  const AuthState();

  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(User user)? authenticated,
    T Function(String message)? error,
  }) {
    final self = this;
    if (self is AuthInitial) return initial != null ? initial() : null;
    if (self is AuthLoading) return loading != null ? loading() : null;
    if (self is AuthAuthenticated) return authenticated != null ? authenticated(self.user) : null;
    if (self is AuthError) return error != null ? error(self.message) : null;
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

final class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}
