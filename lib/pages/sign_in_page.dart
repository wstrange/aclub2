import '../repo.dart';

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:kaisel/kaisel.dart';
import 'package:flutter/material.dart';

import '../routes.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      actions: [
        // When user successfully signs in, route them to the profile screen
        AuthStateChangeAction<SignedIn>((context, state) async {
          await repository.checkProfile(state.user!);
          if (!context.mounted) return;
          context.replaceTop(const Home());
        }),
        // When user creates a new account, route them to the profile screen
        AuthStateChangeAction<UserCreated>((context, state) async {
          // await repository.checkProfile(state.credential.user!);

          context.pushOrReplaceTop(const UserProfileRoute());
        }),
      ],
    );
  }
}
