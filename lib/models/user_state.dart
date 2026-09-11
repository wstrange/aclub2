// Holds current state information about the logged in user
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'section.dart';
import 'user_profile.dart';

part 'user_state.freezed.dart';

/// Holds current state information about the logged in user.
@freezed
abstract class UserState with _$UserState {
  const factory UserState({
    required UserProfile userProfile,
    required User user,
    required List<Section> userSections,
    required Section currentSection,
  }) = _UserState;
}
