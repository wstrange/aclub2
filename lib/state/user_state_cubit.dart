import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';

import '../models/models.dart';
import '../repo.dart';

final _log = Logger('UserStateCubit');

/// Manages the authenticated user's session state, including their profile,
/// section memberships, and currently selected active section.
class UserStateCubit extends CubitSignal<UserState?> {
  UserStateCubit() : super(initialState: null);

  /// Ensures [UserState] is fully loaded and initialized.
  Future<void> ensureLoaded(User authUser, [UserProfile? knownProfile]) async {
    final profile = knownProfile ?? await repository.getUserProfile(authUser.uid, reload: true);
    if (profile == null) {
      _log.warning('Cannot load UserState: profile is null for ${authUser.uid}');
      emit(null);
      return;
    }

    // Fetch all sections
    final allSections = await repository.getSections();
    final userSections = allSections.where((s) => profile.sectionIds.contains(s.id)).toList();

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
    } else if (profile.defaultSectionId != null &&
        userSections.any((s) => s.id == profile.defaultSectionId)) {
      currentSection = userSections.firstWhere((s) => s.id == profile.defaultSectionId);
    } else {
      currentSection = userSections.first;
    }

    _log.info('UserState loaded: user=${authUser.email}, currentSection=${currentSection.name}');
    emit(UserState(
      userProfile: profile,
      user: authUser,
      userSections: userSections,
      currentSection: currentSection,
    ));
  }

  /// Sets the currently active section for the session.
  /// If [persistAsDefault] is true, also saves [defaultSectionId] in the user's Firestore profile.
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
      await ensureLoaded(user);
    } else {
      emit(null);
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
