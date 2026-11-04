import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Typed, user-safe failure for every Google Sign-In step.
class GoogleAuthException implements Exception {
  final String message;

  const GoogleAuthException(this.message);

  @override
  String toString() => message;
}

/// Thin wrapper around `google_sign_in` that guarantees a non-empty Google ID
/// token and converts platform errors into actionable messages.
///
/// `GOOGLE_SERVER_CLIENT_ID` must be supplied at build time (the Web/Server
/// OAuth client ID). Without it Android cannot mint an ID token for the
/// backend, so we fail with a clear message instead of sending a null token.
class GoogleAuthService {
  static const String _serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email', 'profile'],
    serverClientId: _serverClientId.isEmpty ? null : _serverClientId,
  );

  /// Shows the native account picker and returns the Google ID token.
  Future<String> signInAndGetIdToken() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw const GoogleAuthException('Google sign-in was cancelled.');
      }

      final authentication = await account.authentication;
      final idToken = authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw const GoogleAuthException(
          'Google did not return an ID token. Please try again.',
        );
      }

      return idToken;
    } on GoogleAuthException {
      rethrow;
    } on PlatformException catch (error) {
      throw GoogleAuthException(_messageFor(error));
    } catch (_) {
      throw const GoogleAuthException(
        'Google sign-in failed. Please check your connection and try again.',
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Signing out is best-effort; never block the app on it.
    }
  }

  String _messageFor(PlatformException error) {
    switch (error.code) {
      case 'sign_in_canceled':
      case 'canceled':
        return 'Google sign-in was cancelled.';
      case 'network_error':
        return 'No internet connection. Please try again.';
      case 'sign_in_failed':
        return 'Google sign-in is unavailable on this device right now.';
      default:
        return 'Google sign-in failed. Please try again.';
    }
  }
}
