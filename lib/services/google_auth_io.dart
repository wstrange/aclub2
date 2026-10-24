// Google sign-in on native platforms (Android, iOS, macOS) via the
// `google_sign_in` plugin (v7 API: initialize once, then authenticate()).
// The resulting Google ID token is exchanged with Firebase Auth.
//
// Windows/Linux: not wired up — the call fails with a clear [UnsupportedError]
// that surfaces as a friendly message in the sign-in UI.
import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// iOS/macOS OAuth client (from Google Cloud Console / GoogleService-Info.plist
/// CLIENT_ID). The Android client id is picked up from google-services config.
/// This is not a secret that must be protected. It is public.
const String _iosMacClientId =
    '797970173318-61nopoe594icajtj7u0c3pql7ep20see.apps.googleusercontent.com';

/// [GoogleSignIn.instance.initialize] must complete exactly once per process
/// before any other call, so the first sign-in triggers it and the rest reuse.
bool _googleSignInInitialized = false;

/// Signs in with Google, returning the Firebase [UserCredential]. Returns
/// `null` when the user cancels the native account picker.
Future<UserCredential?> signInWithGoogle() async {
  if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
    final googleSignIn = GoogleSignIn.instance;
    if (!_googleSignInInitialized) {
      await googleSignIn.initialize(
        clientId: Platform.isAndroid ? null : _iosMacClientId,
      );
      _googleSignInInitialized = true;
    }

    final GoogleSignInAccount googleUser;
    try {
      googleUser = await googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }

    // v7 exposes the ID token only (an access token requires a separate
    // authorization request, which Firebase Auth doesn't need).
    final idToken = googleUser.authentication.idToken;
    if (idToken == null) {
      throw StateError('Google sign-in completed without an ID token.');
    }
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  throw UnsupportedError(
    'Google sign-in is not available on this platform yet. Please sign in with '
    'email and password.',
  );
}
