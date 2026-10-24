// Gateway over FirebaseAuth for the sign-in flow.
//
// The cubit depends on this small interface instead of FirebaseAuth directly,
// which keeps the flow unit-testable with fakes (see test/sign_in_cubit_test.dart).
//
// After a successful sign-in the gateway mirrors the auth user into a
// Firestore profile stub via `repository.checkProfile` — the same
// book-keeping firebase_ui_auth's `AuthStateChangeAction` used to do.
import 'package:firebase_auth/firebase_auth.dart';

import '../repo.dart';
import '../services/facebook_auth.dart' as facebook_sign_in_flow;
import '../services/google_auth.dart' as google_sign_in_flow;

/// Result of a successful credential sign-in / registration.
class const SignInResult({required this.user, required this.isNewAccount}) {
  final User user;

  /// True when Firebase created the account during this sign-in (first-time
  /// registration, including a first-time Google provider registration).
  final bool isNewAccount;
}

abstract class const SignInGateway() {
  Future<SignInResult> signInWithPassword(String email, String password);
  Future<SignInResult> registerWithPassword(String email, String password);
  Future<void> sendPasswordReset(String email);

  /// Returns `null` when the user cancels the Google account picker / OAuth
  /// window, rather than treating that as an error.
  Future<SignInResult?> signInWithGoogle();

  /// Returns `null` when the user cancels the Facebook login dialog.
  Future<SignInResult?> signInWithFacebook();
}

/// Converts a Firebase credential into a [SignInResult], bootstrapping the
/// user's Firestore profile stub in the meantime.
Future<SignInResult> _fromCredential(UserCredential credential) async {
  final user = credential.user;
  if (user == null) {
    throw StateError('Firebase returned a credential without a user.');
  }
  // Mirror the auth user into the profile store (merge) — same as the old
  // SignInScreen actions did right after sign-in.
  await repository.checkProfile(user);
  return SignInResult(user: user, isNewAccount: credential.additionalUserInfo?.isNewUser ?? false);
}

class const FirebaseSignInGateway() implements SignInGateway {
  @override
  Future<SignInResult> signInWithPassword(String email, String password) async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    return _fromCredential(credential);
  }

  @override
  Future<SignInResult> registerWithPassword(String email, String password) async {
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    return _fromCredential(credential);
  }

  @override
  Future<void> sendPasswordReset(String email) {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  @override
  Future<SignInResult?> signInWithGoogle() async {
    final credential = await google_sign_in_flow.signInWithGoogle();
    return credential == null ? null : _fromCredential(credential);
  }

  @override
  Future<SignInResult?> signInWithFacebook() async {
    final credential = await facebook_sign_in_flow.signInWithFacebook();
    return credential == null ? null : _fromCredential(credential);
  }
}
