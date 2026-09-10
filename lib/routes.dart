import 'package:kaisel/kaisel.dart';

import 'pages/home_page.dart';
import 'pages/user_profile_page.dart';

// import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
// import 'package:signals_core/signals_core.dart ';

sealed class AppRoute extends KaiselRoute {
  const AppRoute();
}

final class Home extends AppRoute {
  const Home();
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

  builder: (context, route) => switch (route) {
    Home() => const HomePage(),

    // Users() => const UsersPage(),
    CreateUser() => const CreateUserPage(),

    // UserDetail(:final id) => UserDetailPage(userId: id),
  },
);

// final repo = signal(AlpineRepository());
