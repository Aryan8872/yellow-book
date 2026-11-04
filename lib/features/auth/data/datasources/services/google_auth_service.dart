import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService() {
    // Initialize only on mobile (not web)
    if (!kIsWeb) {
      GoogleSignIn.instance.initialize(
        scopes: ['email', 'profile'],
      );
    }
  }

  Future<GoogleSignInAccount?> signIn() async {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    
    // Lightweight authentication (no scopes)
    final result = await googleSignIn.signInSilently();
    if (result != null) return result;
    
    // Full sign-in with scopes
    return await googleSignIn.signIn();
  }

  Future<String?> getIdToken() async {
    final account = GoogleSignIn.instance.currentUser;
    if (account == null) return null;
    
    final authentication = await account.authentication;
    return authentication.idToken;
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
  }
}
