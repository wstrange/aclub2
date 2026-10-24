// Unit tests for SignInCubit with a fake sign-in gateway (no Firebase).
import 'package:aclub2/state/sign_in_cubit.dart';
import 'package:aclub2/state/sign_in_gateway.dart';
import 'package:aclub2/state/sign_in_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

/// Firebase [User] stub — production consumers never dereference it through
/// the cubit (profile mirroring happens inside the real gateway), so an
/// all-`noSuchMethod` stub suffices for the state-machine tests.
class _FakeUser() implements User {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

SignInResult _result({required bool isNewAccount}) => SignInResult(user: _FakeUser(), isNewAccount: isNewAccount);

class _FakeGateway({this._result, this._thrown}) implements SignInGateway {
  final SignInResult? _result;
  final Object? _thrown;

  int signInCalls = 0;
  int registerCalls = 0;
  int googleCalls = 0;
  int resetCalls = 0;
  final List<String> resetEmails = [];

  SignInResult _finish() {
    final thrown = _thrown;
    if (thrown != null) throw thrown;
    return _result!;
  }

  @override
  Future<SignInResult> signInWithPassword(String email, String password) async {
    signInCalls++;
    return _finish();
  }

  @override
  Future<SignInResult> registerWithPassword(String email, String password) async {
    registerCalls++;
    return _finish();
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    resetCalls++;
    resetEmails.add(email);
    final thrown = _thrown;
    if (thrown != null) throw thrown;
  }

  @override
  Future<SignInResult?> signInWithGoogle() async {
    googleCalls++;
    if (_thrown != null) throw _thrown;
    return _result; // null → user cancelled the provider flow
  }
}

SignInState _state(SignInCubit cubit) => cubit.state.value;

void main() {
  group('SignInCubit', () {
    test('signIn success transitions to signed-in (existing account)', () async {
      final gateway = _FakeGateway(result: _result(isNewAccount: false));
      final cubit = SignInCubit(gateway: gateway);

      await cubit.signIn('a@b.co', 'secret');

      expect(gateway.signInCalls, 1);
      expect(gateway.registerCalls, 0);
      expect(_state(cubit), isA<SignInSignedIn>().having((s) => s.isNewAccount, 'isNewAccount', false));
    });

    test('register success marks a brand-new account', () async {
      final gateway = _FakeGateway(result: _result(isNewAccount: true));
      final cubit = SignInCubit(gateway: gateway);

      await cubit.register('a@b.co', 'secret');

      expect(gateway.registerCalls, 1);
      expect(_state(cubit), isA<SignInSignedIn>().having((s) => s.isNewAccount, 'isNewAccount', true));
    });

    test('wrong-password failures map to friendly copy', () async {
      final gateway = _FakeGateway(
        thrown: FirebaseAuthException(code: 'wrong-password', message: 'raw'),
      );
      final cubit = SignInCubit(gateway: gateway);

      await cubit.signIn('a@b.co', 'nope');

      final state = _state(cubit);
      expect(state, isA<SignInError>().having((s) => s.message, 'message', 'Incorrect email or password.'));
    });

    test('credential-already-in-use explains the mixed-provider case', () async {
      final gateway = _FakeGateway(thrown: FirebaseAuthException(code: 'credential-already-in-use'));
      final cubit = SignInCubit(gateway: gateway);

      await cubit.signInWithGoogle();

      expect(gateway.googleCalls, 1);
      final state = _state(cubit);
      expect(state, isA<SignInError>().having((s) => s.message, 'message', contains('another sign-in method')));
    });

    test('unexpected failures copy the generic message', () async {
      final gateway = _FakeGateway(thrown: StateError('boom'));
      final cubit = SignInCubit(gateway: gateway);

      await cubit.signIn('a@b.co', 'x');

      expect(_state(cubit), isA<SignInError>().having((s) => s.message, 'message', contains('Something went wrong')));
    });

    test('Google sign-in success carries new-account flag', () async {
      final gateway = _FakeGateway(result: _result(isNewAccount: true));
      final cubit = SignInCubit(gateway: gateway);

      await cubit.signInWithGoogle();

      expect(_state(cubit), isA<SignInSignedIn>().having((s) => s.isNewAccount, 'isNewAccount', true));
    });

    test('cancelled Google sign-in returns to idle without errors', () async {
      final gateway = _FakeGateway(); // no result, no error → treated as cancel
      final cubit = SignInCubit(gateway: gateway);

      await cubit.signInWithGoogle();

      expect(gateway.googleCalls, 1);
      expect(_state(cubit), isA<SignInIdle>());
    });

    test('desktop unsupported-platform error surfaces its user-facing copy', () async {
      final gateway = _FakeGateway(thrown: UnsupportedError('Google sign-in is not available on this platform yet.'));
      final cubit = SignInCubit(gateway: gateway);

      await cubit.signInWithGoogle();

      final state = _state(cubit);
      expect(state, isA<SignInError>().having((s) => s.message, 'message', contains('not available on this platform')));
    });

    test('password reset succeeds and reports the email', () async {
      final gateway = _FakeGateway(result: _result(isNewAccount: false));
      final cubit = SignInCubit(gateway: gateway);

      await cubit.sendPasswordReset('a@b.co');

      expect(gateway.resetCalls, 1);
      expect(gateway.resetEmails, ['a@b.co']);
      expect(_state(cubit), isA<SignInResetSent>().having((s) => s.email, 'email', 'a@b.co'));
    });
  });
}
