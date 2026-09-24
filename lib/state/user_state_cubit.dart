import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';
import 'package:shared_models/shared_models.dart';

import '../repo.dart';
import 'models.dart';

final _log = Logger('UserStateCubit');

/// Manages the authenticated user's session state, including their profile,
/// section memberships, and currently selected active section.
class UserStateCubit extends CubitSignal<UserState?> {
  UserStateCubit() : super(initialState: null);

  /// Ensures [UserState] is fully loaded and initialized.
  ///
  /// Idempotent: if [UserState] is already loaded for [authUser], the cached
  /// state is returned without re-fetching. Pass [force] to always reload
  /// (e.g. after profile or membership changes).
  Future<void> ensureLoaded(User authUser, [UserProfile? knownProfile, bool force = false]) async {
    final existing = state.value;
    if (!force && existing != null && existing.user.uid == authUser.uid) {
      _log.fine('UserState already loaded for ${authUser.email}, skipping reload');
      return;
    }

    final profile = knownProfile ?? await repository.getUserProfile(authUser.uid, reload: true);
    if (profile == null) {
      _log.warning('Cannot load UserState: profile is null for ${authUser.uid}');
      emit(null);
      return;
    }

    // Fetch all sections and the user's memberships. Membership is sourced
    // from the members subcollection, not the profile.
    final allSections = await repository.getSections();
    final memberships = await repository.getUserMemberships(authUser.uid, sections: allSections);
    final memberSectionIds = memberships.map((m) => m.sectionId).toSet();
    final userSections = allSections.where((s) => memberSectionIds.contains(s.id)).toList();

    if (userSections.isEmpty) {
      _log.warning('Cannot load UserState: user ${authUser.uid} belongs to no sections');
      emit(null);
      return;
    }

    // Determine currentSection:
    // 1. Keep existing currentSection if user is already in it
    // 2. Otherwise default to profile.defaultSectionId if valid
    // 3. Otherwise default to the first section
    final current = state.value;
    Section currentSection;
    if (current != null && userSections.any((s) => s.id == current.currentSection.id)) {
      currentSection = userSections.firstWhere((s) => s.id == current.currentSection.id);
    } else if (profile.defaultSectionId != null && userSections.any((s) => s.id == profile.defaultSectionId)) {
      currentSection = userSections.firstWhere((s) => s.id == profile.defaultSectionId);
    } else {
      currentSection = userSections.first;
    }

    _log.info('UserState loaded: user=${authUser.email}, currentSection=${currentSection.name}');
    emit(
      UserState(
        userProfile: profile,
        user: authUser,
        userSections: userSections,
        currentSection: currentSection,
        memberships: memberships,
      ),
    );
  }

  /// Returns the user's [SectionRole] for [sectionId], or null if they are not
  /// a member of that section. Based on the memberships fetched at load time;
  /// call [refresh] after membership or role changes.
  SectionRole? roleFor(String sectionId) {
    for (final m in state.value?.memberships ?? const <SectionMember>[]) {
      if (m.sectionId == sectionId) return m.sectionRole;
    }
    return null;
  }

  /// True if the user is a section manager or trip leader of [sectionId].
  bool canManageSection(String sectionId) {
    final role = roleFor(sectionId);
    return role == SectionRole.sectionManager || role == SectionRole.tripLeader;
  }

  /// Sets the currently active section for the session.
  /// If [persistAsDefault] is true, also saves [defaultSectionId] in the user's Firestore profile.
  ///  TODO:  Do we want to allow access if the users profile has the admin role set??
  Future<void> setCurrentSection(Section section, {bool persistAsDefault = false}) async {
    final current = state.value;
    if (current == null) return;
    emit(current.copyWith(currentSection: section));
    _log.info('Switched active section to: ${section.name}');

    if (persistAsDefault) {
      final updatedProfile = current.userProfile.copyWith(defaultSectionId: section.id);
      await repository.updateUserProfile(updatedProfile);
      emit(current.copyWith(currentSection: section, userProfile: updatedProfile));
      _log.info('Persisted defaultSectionId: ${section.id}');
    }
  }

  /// Sets the currently active section by its ID.
  /// If [persistAsDefault] is true, also saves [defaultSectionId] in the user's Firestore profile.
  Future<void> setCurrentSectionById(String sectionId, {bool persistAsDefault = false}) async {
    final current = state.value;
    if (current == null) return;
    final match = current.userSections.where((s) => s.id == sectionId).firstOrNull;
    if (match != null) {
      await setCurrentSection(match, persistAsDefault: persistAsDefault);
    }
  }

  /// Refreshes the user profile and section memberships if already logged in.
  Future<void> refresh() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await ensureLoaded(user, null, true);
    } else {
      emit(null);
    }
  }

  /// Updates the [UserState]'s stored profile in place without refetching.
  ///
  /// Prefer this over [refresh] right after a profile write: a reload
  /// immediately after an awaited write can race — the client resolver may
  /// resolve the write from the local queue while a subsequent server read
  /// still returns the pre-write document, which would overwrite the cached
  /// profile with stale data. Merging the just-saved model avoids that.
  Future<void> applyProfile(UserProfile profile) async {
    final current = state.value;
    if (current != null) {
      emit(current.copyWith(userProfile: profile));
      _log.fine('Applied updated profile for ${current.user.uid}');
    }
  }

  /// Clears user state on sign out.
  void clear() {
    _log.info('UserState cleared');
    emit(null);
  }
}

/// App-wide singleton instance of [UserStateCubit].
final userStateCubit = UserStateCubit();
