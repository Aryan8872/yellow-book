sealed class AuthEvent {
  const AuthEvent();
}

/// Dispatched on app startup to check if a saved token exists and hydrate user profile from /auth/me
final class CheckAuthStatusRequested extends AuthEvent {
  const CheckAuthStatusRequested();
}

final class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });
}

final class RegisterRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String password;
  final String phone;

  const RegisterRequested({
    required this.fullName,
    required this.email,
    required this.password,
    required this.phone,
  });
}

final class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
