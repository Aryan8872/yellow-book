sealed class AuthEvent {
  const AuthEvent();
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
  final String phoneNumber;

  const RegisterRequested({
    required this.fullName,
    required this.email,
    required this.password,
    required this.phoneNumber,
  });
}

final class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
