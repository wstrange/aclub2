import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaisel/kaisel.dart';
import 'package:logging/logging.dart';

import 'pages/event_detail_page.dart';
import 'pages/event_edit_page.dart';
import 'pages/home_page.dart';
import 'pages/members_directory_page.dart';
import 'pages/section_selection_page.dart';
import 'pages/sign_in_page.dart';
import 'pages/template_editor_page.dart';
import 'pages/template_list_page.dart';
import 'pages/user_profile_page.dart';
import 'pages/waiver_page.dart';
import 'repo.dart';
import 'state/user_state_cubit.dart';

final _log = Logger('route');

sealed class const AppRoute() extends KaiselRoute;

final class const HomeRoute() extends AppRoute;

final class const SignInRoute() extends AppRoute;

final class const UserProfileRoute() extends AppRoute;

final class const SectionSelectionRoute() extends AppRoute;

final class const EventEditRoute({required this.sectionId, required this.eventId}) extends AppRoute {
  final String sectionId;
  final String eventId;

  @override
  List<Object?> get props => [sectionId, eventId];
}

final class const EventDetailRoute({required this.sectionId, required this.eventId}) extends AppRoute {
  final String sectionId;
  final String eventId;

  @override
  List<Object?> get props => [sectionId, eventId];
}

final class const EventCreateRoute({required this.sectionId}) extends AppRoute {
  final String sectionId;

  @override
  List<Object?> get props => [sectionId];
}

final class const TemplateListRoute() extends AppRoute;

final class const TemplateEditRoute({this.templateId = ''}) extends AppRoute {
  /// Empty [templateId] creates a new template.
  final String templateId;

  @override
  List<Object?> get props => [templateId];
}

final class const MembersDirectoryRoute({this.sectionId}) extends AppRoute {
  final String? sectionId;

  @override
  List<Object?> get props => [sectionId];
}

final class const WaiverRoute() extends AppRoute;

KaiselRouterConfig<AppRoute> createRouterConfig({AppRoute initial = const SignInRoute()}) {
  return KaiselRouterConfig<AppRoute>(
    initial: initial,
    guards: [appGuard],
    builder: (context, route) => switch (route) {
      HomeRoute() => const HomePage(),
      SignInRoute() => const SignInPage(),
      UserProfileRoute() => const UserProfilePage(),
      SectionSelectionRoute() => const SectionSelectionPage(),
      MembersDirectoryRoute(:final sectionId) => MembersDirectoryPage(initialSectionId: sectionId),
      EventCreateRoute(:final sectionId) => EventEditPage.create(sectionId: sectionId),
      EventEditRoute(:final sectionId, :final eventId) => EventEditPage(sectionId: sectionId, eventId: eventId),
      EventDetailRoute(:final sectionId, :final eventId) => EventDetailPage(sectionId: sectionId, eventId: eventId),
      TemplateListRoute() => const TemplateListPage(),
      TemplateEditRoute(:final templateId) => TemplateEditPage(templateId: templateId),
      WaiverRoute() => const WaiverPage(),
    },
  );
}

late KaiselRouterConfig<AppRoute> routerConfig;

/// Single cascading guard that verifies authentication, profile completion,
/// and section memberships in strict priority order.
Future<List<AppRoute>> appGuard(List<AppRoute> current, List<AppRoute> proposed) async {
  final user = FirebaseAuth.instance.currentUser;
  final bool headingToLogin = proposed.any((r) => r is SignInRoute);

  // 1. Authentication check
  if (user == null) {
    if (!headingToLogin) {
      _log.info('Unauthenticated access, redirecting to SignInRoute');
      return const [SignInRoute()];
    }
    return proposed;
  }

  // Ensure ID token round-trip completes before Firestore queries.
  // A persisted user that the active backend no longer knows (e.g. a macOS
  // keychain user surviving an emulator reseed or a prod/emulator switch)
  // fails token refresh with backend auth errors. That used to crash app
  // bootstrap on macOS — instead, sign the stale user out and show sign-in.
  try {
    await user.getIdToken();
  } on FirebaseAuthException catch (e) {
    const staleTokenCodes = {'internal-error', 'user-not-found', 'user-token-expired', 'invalid-user-token'};
    if (!staleTokenCodes.contains(e.code)) rethrow;
    _log.warning('Auth token refresh failed (${e.code}) for ${user.uid}; signing out and redirecting to SignInRoute');
    userStateCubit.clear();
    try {
      await FirebaseAuth.instance.signOut();
    } catch (signOutError, st) {
      _log.warning('Failed to sign out stale auth user: $signOutError\n$st');
    }
    return const [SignInRoute()];
  }

  // If already logged in and heading to login, redirect towards HomeRoute
  if (headingToLogin) {
    proposed = const [HomeRoute()];
  }

  // 2. Profile completion check
  var profile = await repository.getUserProfile(user.uid);
  if (profile == null) {
    await repository.checkProfile(user);
    profile = await repository.getUserProfile(user.uid);
  }

  // 2. Waiver check — must be signed within the past 365 days.
  final waiverSignedDate = profile?.waiverSignedDate;
  final bool waiverCurrent = waiverSignedDate != null && DateTime.now().difference(waiverSignedDate).inDays < 365;
  final bool headingToWaiver = proposed.any((r) => r is WaiverRoute);

  if (!waiverCurrent) {
    if (!headingToWaiver) {
      _log.info('Waiver not current for ${user.uid}, redirecting to WaiverRoute');
      return const [WaiverRoute()];
    }
    return proposed;
  }

  // Waiver is current; skip waiver page if explicitly requested
  if (headingToWaiver) {
    proposed = const [HomeRoute()];
  }

  // 3. Profile completion check
  final bool profileComplete = profile != null && profile.complatedProfile;
  final bool headingToProfile = proposed.any((r) => r is UserProfileRoute);

  if (!profileComplete) {
    if (!headingToProfile) {
      _log.info('Incomplete profile for ${user.uid}, redirecting to UserProfileRoute');
      return const [UserProfileRoute()];
    }
    return proposed;
  }

  // Profile is complete; allow viewing/editing profile if requested
  if (headingToProfile) {
    return proposed;
  }

  // 4. Section membership check
  // UserStateCubit.ensureLoaded initializes session and emits null if userSections is empty.
  await userStateCubit.ensureLoaded(user, profile);

  final bool hasSections = userStateCubit.state.value != null;
  final bool headingToSections = proposed.any((r) => r is SectionSelectionRoute);

  if (!hasSections) {
    if (!headingToSections) {
      _log.info('No section memberships for ${user.uid}, redirecting to SectionSelectionRoute');
      return const [SectionSelectionRoute()];
    }
    return proposed;
  }

  return proposed;
}
