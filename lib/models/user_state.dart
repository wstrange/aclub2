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

  /// The user's [SectionRole] within [sectionId], or null if they are not a
  /// member of that section.
  SectionRole? roleFor(String sectionId) {
    for (final m in memberships) {
      if (m.sectionId == sectionId) return m.sectionRole;
    }
    return null;
  }

  /// True if the user is a section manager or trip leader of [sectionId].
  bool canManageSection(String sectionId) {
    final role = roleFor(sectionId);
    return role == SectionRole.sectionManager || role == SectionRole.tripLeader;
  }
}
