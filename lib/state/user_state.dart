import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_models/shared_models.dart';

part 'user_state.freezed.dart';

/// Holds current state information about the logged in user.
@freezed
abstract class UserState with _$UserState {
  const factory UserState({
    required UserProfile userProfile,
    required User user,
    required List<Section> userSections,
    required Section currentSection,
    required List<SectionMember> memberships,
  }) = _UserState;

  @override
  String toString() {
    return "$userProfile ${userProfile.email} ${user.email} $userSections $currentSection";
  }
}
