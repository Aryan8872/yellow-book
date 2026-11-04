import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  late final GoogleSignIn _googleSignIn;

  GoogleAuthService() {
    // Initialize GoogleSignIn instance for v6.x API
    _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
    );
  }

  Future<GoogleSignInAccount?> signIn() async {
    // Lightweight authentication (no scopes)
    final result = await _googleSignIn.signInSilently();
    if (result != null) return result;

    // Full sign-in with scopes
    return await _googleSignIn.signIn();
  }

  Future<String?> getIdToken() async {
    final account = _googleSignIn.currentUser;
    if (account == null) return null;

    final authentication = await account.authentication;
    return authentication.idToken;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
