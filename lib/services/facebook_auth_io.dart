// Facebook sign-in on Android, iOS and macOS, via the `flutter_facebook_auth`
// plugin (v7 API). The resulting Facebook access token is exchanged with
// Firebase Auth's FacebookAuthProvider.
//
// macOS: the vendored `facebook_auth_desktop` (packages/facebook_auth_desktop)
// drives the OAuth dialog in a webview window and stores the session in the
// keychain. It must be configured with `initializeFacebookAuth()` first (done
// in main.dart), and needs "Login with the JavaScript SDK" + `Login from
// Devices` enabled in the Facebook app console.
//
// Windows/Linux: not wired up — the call fails with a clear [UnsupportedError]
// that surfaces as a friendly message in the sign-in UI.
import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

/// Facebook App ID for the app (developers.facebook.com → App Dashboard,
/// Settings → Basic). The Client Token (Settings → Advanced) is set in the
/// native configs: `android/app/src/main/res/values/strings.xml` and
/// `ios/Runner/Info.plist`. Facebook sign-in is treated as configured while
/// this constant holds a real numeric app id.
const String kFacebookAppId = '954559893876564';

const List<String> _facebookPermissions = ['email', 'public_profile'];

bool get _facebookConfigured => !kFacebookAppId.startsWith('CHANGE_ME');

/// Native platforms supported by flutter_facebook_auth.
bool get facebookSignInSupported => Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

/// Signs in with Facebook, returning the Firebase [UserCredential]. Returns
/// `null` when the user cancels the Facebook dialog.
Future<UserCredential?> signInWithFacebook() async {
  if (!facebookSignInSupported) {
    throw UnsupportedError(
      'Facebook sign-in is not available on this platform yet. Please sign in with '
      'email and password.',
    );
  }
  if (!_facebookConfigured) {
    throw UnsupportedError(
      'Facebook sign-in is not configured yet. Set the Meta App ID and Client '
      'Token in the project (see lib/services/facebook_auth_io.dart).',
    );
  }

  final result = await FacebookAuth.i.login(permissions: _facebookPermissions);
  switch (result.status) {
    case LoginStatus.success:
      final accessToken = result.accessToken;
      if (accessToken == null) {
        throw StateError('Facebook reported success without an access token.');
      }
      final credential = FacebookAuthProvider.credential(accessToken.tokenString);
      return FirebaseAuth.instance.signInWithCredential(credential);
    case LoginStatus.cancelled:
      return null; // user closed the Facebook login dialog
    case LoginStatus.failed:
    case LoginStatus.operationInProgress:
      throw StateError(result.message ?? 'Facebook login failed.');
  }
}

/// One-time bootstrap for the macOS desktop session storage / webflow — call
/// from main(). No-op until the Meta App ID is configured; on Android/iOS the
/// native SDKs are configured through their plists/manifest, not here.
Future<void> initializeFacebookAuth() async {
  if (!_facebookConfigured) {
    return;
  }
  await FacebookAuth.i.webAndDesktopInitialize(appId: kFacebookAppId, cookie: true, xfbml: true, version: 'v22.0');
}
