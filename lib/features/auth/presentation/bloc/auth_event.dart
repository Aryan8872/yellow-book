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

final class UpdateProfileRequested extends AuthEvent {
  final String name;
  final String? phone;
  final String? avatarUrl;

  const UpdateProfileRequested({
    required this.name,
    this.phone,
    this.avatarUrl,
  });
}

final class GoogleLoginRequested extends AuthEvent {
  final String idToken;

  const GoogleLoginRequested({required this.idToken});
}

final class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested({required this.email});
}

final class ResetPasswordRequested extends AuthEvent {
  final String token;
  final String newPassword;

  const ResetPasswordRequested({
    required this.token,
    required this.newPassword,
  });
}
