import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_models/shared_models.dart';

part 'member_directory_state.freezed.dart';

/// Combines a [SectionMember] record with the resolved [UserProfile], if available.
class MemberDirectoryEntry {
  const MemberDirectoryEntry({
    required this.member,
    this.profile,
  });

  final SectionMember member;
  final UserProfile? profile;

  String get userId => member.id;
  SectionRole get role => member.sectionRole;
  DateTime get joinedAt => member.joinedAt;

  String get firstName => profile?.firstName ?? '';
  String get lastName => profile?.lastName ?? '';

  String get fullName => '$firstName $lastName'.trim();

  String get displayName {
    if (fullName.isNotEmpty) return fullName;
    final email = profile?.email;
    if (email != null && email.isNotEmpty) return email;
    final idPart = userId.length > 6 ? userId.substring(0, 6) : userId;
    return 'Member ($idPart)';
  }

  String get initials {
    final fn = firstName.trim();
    final ln = lastName.trim();
    if (fn.isNotEmpty && ln.isNotEmpty) {
      return '${fn[0]}${ln[0]}'.toUpperCase();
    }
    if (fn.isNotEmpty) {
      return fn.substring(0, fn.length >= 2 ? 2 : 1).toUpperCase();
    }
    final dn = displayName.trim();
    if (dn.isNotEmpty) {
      return dn.substring(0, dn.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '?';
  }

  String? get email => profile?.email;
  String? get phone => profile?.phone;
  List<String> get certifications => profile?.certifications ?? const [];

  String get roleDisplayName => switch (role) {
    SectionRole.sectionManager => 'Section Manager',
    SectionRole.tripLeader => 'Trip Leader',
    SectionRole.member => 'Member',
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberDirectoryEntry &&
          runtimeType == other.runtimeType &&
          member == other.member &&
          profile == other.profile;

  @override
  int get hashCode => member.hashCode ^ profile.hashCode;
}

@freezed
abstract class MemberDirectoryState with _$MemberDirectoryState {
  const MemberDirectoryState._();

  const factory MemberDirectoryState({
    required String sectionId,
    @Default(<MemberDirectoryEntry>[]) List<MemberDirectoryEntry> entries,
    @Default(true) bool isLoading,
    Object? error,
    @Default('') String searchQuery,
    SectionRole? selectedRole,
  }) = _MemberDirectoryState;

  int get totalCount => entries.length;
  int get managerCount => entries.where((e) => e.role == SectionRole.sectionManager).length;
  int get tripLeaderCount => entries.where((e) => e.role == SectionRole.tripLeader).length;
  int get memberCount => entries.where((e) => e.role == SectionRole.member).length;

  List<MemberDirectoryEntry> get filteredEntries {
    final query = searchQuery.trim().toLowerCase();

    final filtered = entries.where((entry) {
      if (selectedRole != null && entry.role != selectedRole) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      if (entry.displayName.toLowerCase().contains(query)) return true;
      if (entry.email?.toLowerCase().contains(query) ?? false) return true;
      if (entry.phone?.toLowerCase().contains(query) ?? false) return true;
      if (entry.roleDisplayName.toLowerCase().contains(query)) return true;
      if (entry.certifications.any((c) => c.toLowerCase().contains(query))) return true;
      return false;
    }).toList();

    // Sort by role hierarchy (Managers -> Leaders -> Members) and then alphabetically by displayName
    filtered.sort((a, b) {
      final roleOrderA = _roleOrder(a.role);
      final roleOrderB = _roleOrder(b.role);
      if (roleOrderA != roleOrderB) {
        return roleOrderA.compareTo(roleOrderB);
      }
      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });

    return filtered;
  }

  static int _roleOrder(SectionRole role) => switch (role) {
    SectionRole.sectionManager => 0,
    SectionRole.tripLeader => 1,
    SectionRole.member => 2,
  };
}
