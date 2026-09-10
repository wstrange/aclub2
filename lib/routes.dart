import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaisel/kaisel.dart';

import 'pages/home_page.dart';
import 'pages/sign_in_page.dart';
import 'pages/user_profile_page.dart';

// import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
// import 'package:signals_core/signals_core.dart ';

sealed class AppRoute extends KaiselRoute {
  const AppRoute();
}

final class Home extends AppRoute {
  const Home();
}

final class SignInRoute extends AppRoute {
  const SignInRoute();
}

// final class Users extends AppRoute {
//   const Users();
// }

final class CreateUser extends AppRoute {
  const CreateUser();
}

// final class UserDetail extends AppRoute {
//   const UserDetail(this.id);

// //   final String id;

// @override
// List<Object?> get props => [id];
// // }

final routerConfig = KaiselRouterConfig<AppRoute>(
  initial: const Home(),
  guards: [authGuard],
  builder: (context, route) => switch (route) {
    Home() => const HomePage(),
    SignInRoute() => SignInPage(),

    // Users() => const UsersPage(),
    CreateUser() => const CreateUserPage(),

    // UserDetail(:final id) => UserDetailPage(userId: id),
  },
);

// final repo = signal(AlpineRepository());

List<AppRoute> authGuard(List<AppRoute> current, List<AppRoute> proposed) {
  // Check if the user is authenticated with Firebase
  final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

  // Determine if the destination stack already includes the sign-in screen
  final bool headingToLogin = proposed.any((r) => r is SignInRoute);

  // If they aren't logged in and aren't going to the login page, redirect them
  if (!isLoggedIn && !headingToLogin) {
    return [const SignInRoute()];
  }

  // Otherwise, allow the proposed navigation stack to proceed normally
  return proposed;
}
