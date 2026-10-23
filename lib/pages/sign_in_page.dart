import '../repo.dart';

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:kaisel/kaisel.dart';
import 'package:flutter/material.dart';

import '../routes.dart';

class const SignInPage({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      headerBuilder: (context, constraints, shrinkOffset) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Image.asset(
              'assets/icon/acc.png',
              fit: BoxFit.contain,
            ),
          ),
        );
      },
      sideBuilder: (context, constraints) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Image.asset(
              'assets/icon/acc.png',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
      actions: [
        // When user successfully signs in, route them to the profile screen
        AuthStateChangeAction<SignedIn>((context, state) async {
          await repository.checkProfile(state.user!);
          if (!context.mounted) return;
          context.replaceTop(const HomeRoute());
        }),
        // When user creates a new account, route them to the profile screen
        AuthStateChangeAction<UserCreated>((context, state) async {
          await repository.checkProfile(state.credential.user!);

          if (!context.mounted) return;
          context.pushOrReplaceTop(const UserProfileRoute());
        }),
      ],
    );
  }
}
