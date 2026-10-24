// Facebook sign-in on web: Firebase's popup OAuth flow (the flutter_facebook_auth
// JS-SDK flow is not used on web; `firebase_auth` handles it via the app's
// configured Facebook provider).
import 'package:firebase_auth/firebase_auth.dart';

/// Firebase web popup error codes that represent the user dismissing the
/// popup rather than a real failure.
const _popupDismissedCodes = {'popup-closed-by-user', 'cancelled-popup-request'};

/// Signs in with Facebook via the Firebase web popup. Returns `null` when the
/// user closes the popup without completing the flow.
Future<UserCredential?> signInWithFacebook() async {
  try {
    // `public_profile` is implicit, but email must be requested explicitly.
    // This matches the native flow and lets Firebase populate the account's
    // email address when Facebook makes it available to the person signing in.
    final provider = FacebookAuthProvider()..addScope('email');
    return await FirebaseAuth.instance.signInWithPopup(provider);
  } on FirebaseAuthException catch (e) {
    if (_popupDismissedCodes.contains(e.code.toLowerCase())) {
      return null; // user closed the popup
    }
    rethrow;
  }
}

/// Kept for signature parity with the native implementation (which bootstraps
/// its desktop session). Firebase's popup flow needs no SDK bootstrap.
Future<void> initializeFacebookAuth() async {}
