// Sign-in flow state. Kept as a plain sealed hierarchy (matching
// UserProfileFormState) — no freezed needed for these simple variants.
sealed class const SignInState();

/// Nothing happening; the form is idle.
class const SignInIdle() extends SignInState;

/// A sign-in / registration / reset request is in flight. [mode] is either
/// `password` or `google`; the UI uses it to spinner the right control.
class const SignInSubmitting(this.mode) extends SignInState {
  final String mode;
}

/// Sign-in / registration finished. [isNewAccount] distinguishes a fresh
/// registration (routed straight to profile completion) from an existing
/// user signing back in.
class const SignInSignedIn(this.isNewAccount) extends SignInState {
  final bool isNewAccount;
}

/// A password-reset email has been sent.
class const SignInResetSent(this.email) extends SignInState {
  final String email;
}

/// The last auth action failed with [message]; the form stays usable.
class const SignInError(this.message) extends SignInState {
  final String message;
}
