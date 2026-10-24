// Cubit driving the sign-in page: email/password sign-in & registration,
// password reset, and Google sign-in across platforms.
//
// Errors from FirebaseAuthException are translated into friendly copy by
// `_friendlyMessage`; unknown failures show a generic message (with the raw
// exception logged at warning level).
//
// The profile bootstrap (`repository.checkProfile`) lives in the gateway —
// the cubit stays repo-free so its state machine can be tested with fakes.
import 'package:bloc_signals/bloc_signals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';

import 'sign_in_gateway.dart';
import 'sign_in_state.dart';

final _log = Logger('sign_in');

final _passwordSubmitting = const SignInSubmitting('password');
final _googleSubmitting = const SignInSubmitting('google');

/// Hand-rolled replacement for the firebase_ui_auth sign-in flow.
class SignInCubit extends CubitSignal<SignInState> {
  // Classic (non-primary) constructor: keeps an optional injectable gateway
  // while opting out of the primary-constructor lint for this class.
  // ignore: use_primary_constructors
  SignInCubit({this.gateway = const FirebaseSignInGateway()}) : super(initialState: const SignInIdle());

  final SignInGateway gateway;

  /// Sign in with email + password for an existing account.
  Future<void> signIn(String email, String password) async {
    await _passwordFlow(() => gateway.signInWithPassword(email, password));
  }

  /// Create a new account. Knowingly different from [signIn]: a brand-new
  /// user is routed to profile completion next.
  Future<void> register(String email, String password) async {
    await _passwordFlow(() => gateway.registerWithPassword(email, password));
  }

  Future<void> signInWithGoogle() async {
    emit(_googleSubmitting);
    try {
      final result = await gateway.signInWithGoogle();
      if (result == null) {
        // User cancelled the picker / closed the OAuth window.
        emit(const SignInIdle());
        return;
      }
      emit(SignInSignedIn(result.isNewAccount));
    } on FirebaseAuthException catch (e, st) {
      _log.warning('Google sign-in failed: ${e.code}\n$st');
      emit(SignInError(_friendlyMessage(e)));
    } catch (e, st) {
      _log.warning('Google sign-in failed: $e\n$st');
      emit(SignInError(_friendlyGeneric(e)));
    }
  }

  /// Sends a password-reset email. No user-existence leak: a successful send
  /// is reported for any well-formed email, matching Firebase behaviour.
  Future<void> sendPasswordReset(String email) async {
    emit(_passwordSubmitting);
    try {
      await gateway.sendPasswordReset(email);
      emit(SignInResetSent(email));
    } on FirebaseAuthException catch (e, st) {
      _log.warning('Password reset failed: ${e.code}\n$st');
      emit(SignInError(_friendlyMessage(e)));
    } catch (e, st) {
      _log.warning('Password reset failed: $e\n$st');
      emit(SignInError(_friendlyGeneric(e)));
    }
  }

  /// Shared wrapper for sign-in and registration: both are password-mode
  /// submissions that end in a signed-in state (or an error).
  Future<void> _passwordFlow(Future<SignInResult> Function() action) async {
    emit(_passwordSubmitting);
    try {
      final result = await action();
      emit(SignInSignedIn(result.isNewAccount));
    } on FirebaseAuthException catch (e, st) {
      _log.warning('Password flow failed: ${e.code}\n$st');
      emit(SignInError(_friendlyMessage(e)));
    } catch (e, st) {
      _log.warning('Password flow failed: $e\n$st');
      emit(SignInError(_friendlyGeneric(e)));
    }
  }
}

// ── Error copy ───────────────────────────────────────────────────────────────

/// Maps FirebaseAuthException codes to user-facing copy.
String _friendlyMessage(FirebaseAuthException e) {
  return switch (e.code.toLowerCase()) {
    'invalid-email' => "That email address doesn't look valid.",
    'invalid-credential' || 'wrong-password' => 'Incorrect email or password.',
    'user-not-found' => 'No account found for that email.',
    'user-disabled' => 'This account has been disabled.',
    'credential-already-in-use' || 'account-exists-with-different-credential' =>
      'This email is already linked to another sign-in method. Sign in with that method instead.',
    'email-already-in-use' => 'An account with this email already exists. Try signing in instead.',
    'weak-password' => 'Choose a stronger password (at least 6 characters).',
    'network-request-failed' => 'Network error — check your connection and try again.',
    'too-many-requests' => 'Too many attempts. Please wait a little and try again.',
    'operation-not-allowed' => 'That sign-in method is not enabled for this app.',
    _ => e.message ?? e.code,
  };
}

String _friendlyGeneric(Object e) {
  // The Google service uses UnsupportedError to report "platform not wired
  // up" (e.g. desktop Google sign-in without a Web OAuth client) — those
  // messages are written to be user-facing, so surface them as-is.
  if (e is UnsupportedError) {
    return e.message ?? 'Something went wrong. Please try again.';
  }
  return 'Something went wrong. Please try again.';
}
