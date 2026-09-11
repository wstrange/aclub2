import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaisel/kaisel.dart';
import 'package:logging/logging.dart';

import 'pages/event_edit_page.dart';
import 'pages/home_page.dart';
import 'pages/section_selection_page.dart';
import 'pages/sign_in_page.dart';
import 'pages/user_profile_page.dart';
import 'repo.dart';
import 'state/user_state_cubit.dart';

final _log = Logger('route');

sealed class AppRoute extends KaiselRoute {
  const AppRoute();
}

final class HomeRoute extends AppRoute {
  const HomeRoute();
}

final class SignInRoute extends AppRoute {
  const SignInRoute();
}

final class UserProfileRoute extends AppRoute {
  const UserProfileRoute();
}

final class SectionSelectionRoute extends AppRoute {
  const SectionSelectionRoute();
}

final class EventEditRoute extends AppRoute {
  const EventEditRoute({required this.sectionId, required this.eventId});

  final String sectionId;
  final String eventId;

  @override
  List<Object?> get props => [sectionId, eventId];
}

final class EventCreateRoute extends AppRoute {
  const EventCreateRoute({required this.sectionId});

  final String sectionId;

  @override
  List<Object?> get props => [sectionId];
}

final routerConfig = KaiselRouterConfig<AppRoute>(
  initial: FirebaseAuth.instance.currentUser != null ? const HomeRoute() : const SignInRoute(),
  guards: [authGuard, profileCompletionGuard, sectionMembershipGuard],
  builder: (context, route) => switch (route) {
    HomeRoute() => const HomePage(),
    SignInRoute() => const SignInPage(),
    UserProfileRoute() => const UserProfilePage(),
    SectionSelectionRoute() => const SectionSelectionPage(),
    EventCreateRoute(:final sectionId) => EventEditPage.create(sectionId: sectionId),
    EventEditRoute(:final sectionId, :final eventId) => EventEditPage(sectionId: sectionId, eventId: eventId),
  },
);

List<AppRoute> authGuard(List<AppRoute> current, List<AppRoute> proposed) {
  // Check if the user is authenticated with Firebase
  final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

  // Determine if the destination stack already includes the sign-in screen
  final bool headingToLogin = proposed.any((r) => r is SignInRoute);

  // If they aren't logged in and aren't going to the login page, redirect them
  if (!isLoggedIn && !headingToLogin) {
    return [const SignInRoute()];
  }

  // If they are logged in and heading to login, redirect to home
  if (isLoggedIn && headingToLogin) {
    return [const HomeRoute()];
  }

  _log.info('Auth guard: isLoggedIn: $isLoggedIn, headingToLogin: $headingToLogin, proposed: $proposed');
  return proposed;
}

/// Redirects authenticated users to complete their profile if it is marked as not completed.
Future<List<AppRoute>> profileCompletionGuard(List<AppRoute> current, List<AppRoute> proposed) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return proposed;
  }

  // Allow navigation if already heading to the profile screen
  final bool headingToProfile = proposed.any((r) => r is UserProfileRoute);
  if (headingToProfile) {
    return proposed;
  }

  // agy made this a cached lookup. Maybe OK? Will be fast
  var profile = await repository.getUserProfile(user.uid);
  if (profile == null) {
    await repository.checkProfile(user);
    profile = await repository.getUserProfile(user.uid);
  }

  if (profile == null || !profile.complatedProfile) {
    _log.info('Profile incomplete for user ${user.uid}, redirecting to UserProfileRoute');
    return [const UserProfileRoute()];
  }

  return proposed;
}

/// Redirects authenticated users who belong to no sections to [SectionSelectionRoute].
Future<List<AppRoute>> sectionMembershipGuard(List<AppRoute> current, List<AppRoute> proposed) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return proposed;
  }

  // Allow navigation if heading to login, profile, or section selection
  final bool headingToLogin = proposed.any((r) => r is SignInRoute);
  final bool headingToProfile = proposed.any((r) => r is UserProfileRoute);
  final bool headingToSections = proposed.any((r) => r is SectionSelectionRoute);
  if (headingToLogin || headingToProfile || headingToSections) {
    return proposed;
  }

  final profile = await repository.getUserProfile(user.uid);
  if (profile == null || profile.sectionIds.isEmpty) {
    _log.info('User ${user.uid} belongs to no sections, redirecting to SectionSelectionRoute');
    return [const SectionSelectionRoute()];
  }

  // Once all guards have passed, ensure UserState is fully loaded
  await userStateCubit.ensureLoaded(user, profile);

  return proposed;
}
