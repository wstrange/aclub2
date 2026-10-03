import 'dart:async';

import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:logging/logging.dart';
import 'package:shared_models/shared_models.dart';

import '../repo.dart';
import 'member_directory_state.dart';

final _log = Logger('MemberDirectoryCubit');

/// Manages loading, filtering, and searching members belonging to a section.
///
/// Subscribes to [AlpineRepository.streamSectionMembers] on initialization and
/// resolves full [UserProfile] records for rich display. Cancels subscriptions
/// on [close].
class MemberDirectoryCubit extends CubitSignal<MemberDirectoryState> {
  MemberDirectoryCubit({required this.sectionId, this._repository, bool autoSubscribe = true})
    : super(initialState: MemberDirectoryState(sectionId: sectionId)) {
    if (autoSubscribe) {
      _subscribe();
    }
  }

  final AlpineRepository? _repository;
  AlpineRepository get _repo => _repository ?? defaultRepositoryInstance;
  String sectionId;
  StreamSubscription<List<SectionMember>>? _membersSub;

  void _subscribe() {
    _membersSub?.cancel();
    emit(value.copyWith(sectionId: sectionId, isLoading: true, error: null));

    _membersSub = _repo
        .streamSectionMembers(sectionId)
        .listen(
          (members) async {
            try {
              final uids = members.map((m) => m.id).toList();
              final profiles = await _repo.getUserProfiles(uids);
              final entries = members.map((m) => MemberDirectoryEntry(member: m, profile: profiles[m.id])).toList();
              emit(value.copyWith(entries: entries, isLoading: false, error: null));
            } catch (e, st) {
              _log.warning('Error resolving member profiles: $e', e, st);
              final entries = members.map((m) => MemberDirectoryEntry(member: m)).toList();
              emit(value.copyWith(entries: entries, isLoading: false, error: e));
            }
          },
          onError: (Object e, StackTrace st) {
            _log.warning('Error streaming section members: $e', e, st);
            emit(value.copyWith(isLoading: false, error: e));
          },
        );
  }

  /// Updates the text search query (case-insensitive across name, email, phone, role, certifications).
  void setSearchQuery(String query) {
    emit(value.copyWith(searchQuery: query));
  }

  /// Filters by [SectionRole] or clears filter when [role] is null.
  void setRoleFilter(SectionRole? role) {
    emit(value.copyWith(selectedRole: role));
  }

  /// Switches the active section being viewed and resubscribes to member updates.
  void changeSection(String newSectionId) {
    if (sectionId == newSectionId && !value.isLoading) return;
    sectionId = newSectionId;
    _subscribe();
  }

  /// Refreshes the directory data.
  Future<void> refresh() async {
    _subscribe();
  }

  /// Updates the role of a member in the current section.
  Future<void> updateMemberRole(String userId, SectionRole newRole) async {
    final originalEntries = value.entries;
    try {
      final updated = value.entries.map((e) {
        if (e.userId == userId) {
          final updatedMember = e.member.copyWith(sectionRole: newRole);
          return MemberDirectoryEntry(member: updatedMember, profile: e.profile);
        }
        return e;
      }).toList();
      emit(value.copyWith(entries: updated));

      await _repo.updateMemberRole(sectionId: sectionId, userId: userId, newRole: newRole);
    } catch (e, st) {
      _log.warning('Error updating member role: $e', e, st);
      emit(value.copyWith(entries: originalEntries, error: e));
      rethrow;
    }
  }

  @override
  Future<void> close() async {
    await _membersSub?.cancel();
    _membersSub = null;
    await super.close();
  }
}

// Global fallback repository reference
AlpineRepository get defaultRepositoryInstance => repository;
