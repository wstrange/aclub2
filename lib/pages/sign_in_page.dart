// Hand-rolled sign-in / registration page replacing the firebase_ui_auth
// SignInScreen. Feature parity:
//
//   * email + password sign-in and registration
//   * forgot-password (sendPasswordResetEmail)
//   * Google sign-in, platform-specific (see services/google_auth.dart)
//   * signed-in user  → repository.checkProfile → HomeRoute
//     new account     → repository.checkProfile → UserProfileRoute
//   * friendly FirebaseAuth error copy via SignInCubit's error mapping
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kaisel/kaisel.dart';

import '../routes.dart';
import '../state/sign_in_cubit.dart';
import '../state/sign_in_state.dart';
import '../widgets/google_logo.dart';

class const SignInPage({super.key}) extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return BlocSignalProvider<SignInCubit>(create: (_) => SignInCubit(), child: const _SignInForm());
  }
}

class const _SignInForm() extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final isRegisterMode = useState(false);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);

    Future<void> submit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;
      final cubit = context.read<SignInCubit>();
      if (isRegisterMode.value) {
        await cubit.register(emailController.text.trim(), passwordController.text);
      } else {
        await cubit.signIn(emailController.text.trim(), passwordController.text);
      }
    }

    Future<void> sendResetLink() async {
      final email = emailController.text.trim();
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            content: Text('Enter your email above first, then tap "Forgot password".'),
          ),
        );
        return;
      }
      await context.read<SignInCubit>().sendPasswordReset(email);
    }

    return BlocSignalConsumer<SignInCubit, SignInState>(
      listenWhen: (previous, current) =>
          current is SignInSignedIn || current is SignInResetSent || current is SignInError,
      listener: (context, state) async {
        if (state is SignInSignedIn) {
          // Mirror the pre-auth profile stub for other clients, then route.
          if (state.isNewAccount) {
            context.pushOrReplaceTop(const UserProfileRoute());
          } else {
            context.replaceTop(const HomeRoute());
          }
        } else if (state is SignInResetSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              content: Text('Password reset link sent to ${state.email}.'),
            ),
          );
        } else if (state is SignInError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              content: Text(state.message),
            ),
          );
        }
      },
      builder: (context, state) {
        final submittingMode = state is SignInSubmitting ? state.mode : null;
        final submitting = submittingMode != null;
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Image.asset('assets/icon/acc.png', height: 120, fit: BoxFit.contain),
                          ),
                        ),
                        Text(
                          isRegisterMode.value ? 'Create account' : 'Sign in',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'The Alpine Club of Canada',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.next,
                          enabled: !submitting,
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            if (email.isEmpty) return 'Enter your email.';
                            if (!email.contains('@') || !email.contains('.')) {
                              return "That email address doesn't look valid.";
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Password'),
                          autofillHints: const [AutofillHints.password],
                          textInputAction: isRegisterMode.value ? TextInputAction.done : TextInputAction.go,
                          onFieldSubmitted: (_) => submit(),
                          enabled: !submitting,
                          validator: (value) {
                            final password = value ?? '';
                            if (password.isEmpty) return 'Enter your password.';
                            if (isRegisterMode.value && password.length < 6) {
                              return 'Use at least 6 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: submitting ? null : submit,
                          child: submitting
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text(isRegisterMode.value ? 'Create account' : 'Sign in'),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          // Google sign-in: native account sheet on Android,
                          // iOS and macOS; Firebase popup on web; a clear
                          // "not available on this platform" message on
                          // Windows/Linux (see services/google_auth.dart).
                          onPressed: submitting ? null : () => context.read<SignInCubit>().signInWithGoogle(),
                          icon: submittingMode == 'google'
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const GoogleLogo(),
                          label: const Text('Continue with Google'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          // Facebook sign-in: native dialog on Android/iOS and
                          // a webview OAuth window on macOS; Firebase popup on
                          // web; friendly "not configured/available" message
                          // otherwise (see services/facebook_auth.dart).
                          onPressed: submitting ? null : () => context.read<SignInCubit>().signInWithFacebook(),
                          icon: submittingMode == 'facebook'
                              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 22),
                          label: const Text('Continue with Facebook'),
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: submitting
                              ? null
                              : () {
                                  isRegisterMode.value = !isRegisterMode.value;
                                },
                          child: Text(
                            isRegisterMode.value ? 'Already have an account? Sign in' : 'Need an account? Create one',
                          ),
                        ),
                        if (!isRegisterMode.value) ...[
                          TextButton(
                            onPressed: submitting ? null : sendResetLink,
                            child: const Text('Forgot password?'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
