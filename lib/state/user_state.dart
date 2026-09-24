import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_models/shared_models.dart';

part 'user_state.freezed.dart';

/// Holds current state information about the logged in user.
/// this is not stored in firestore - it is created on logon
@freezed
sealed class UserState with _$UserState {
  const UserState._();

  const factory UserState({
    required UserProfile userProfile,
    required User user,
    required List<Section> userSections,
    required Section currentSection,
    required List<SectionMember> memberships,
  }) = _UserState;

  @override
  String toString() => 'UserState(user: ${user.email}, section: ${currentSection.name})';
}
