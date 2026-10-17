import 'dart:async';

import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:logging/logging.dart';
import 'package:shared_models/shared_models.dart';

import '../repo.dart';
import 'member_directory_state.dart';

final _log = Logger('MemberDirectoryCubit');

/// Number of member documents kept in the realtime window and per page fetch.
const _windowSize = 40;

/// Manages loading, filtering, and searching members belonging to a section.
///
/// Firestore cost model:
///
/// * Subscribes to a **bounded realtime window** of [_windowSize] members
///   ([AlpineRepository.streamSectionMembers]), so opening the directory
///   costs ≤[_windowSize] member reads regardless of section size.
/// * Profiles are kept in a per-uid cache and only fetched for uids that
///   appear for the first time; [refresh] clears the cache to force fresh
///   profile data.
/// * Members beyond the window are fetched page-by-page via
///   [AlpineRepository.getSectionMembersPage] when the user taps
///   [loadMore].
/// * Search/role filtering (`setSearchQuery`, `setRoleFilter`) is client-side
///   over loaded data and costs zero reads.
///
/// Trade-off: the realtime listener only covers the first [_windowSize]
/// members — writes to members loaded in later pages surface on the next
/// visit or manual refresh, and search matches loaded members only.
class MemberDirectoryCubit({required this.sectionId, this._repository, bool autoSubscribe = true})
    extends CubitSignal<MemberDirectoryState> {
  this : super(initialState: MemberDirectoryState(sectionId: sectionId)) {
    if (autoSubscribe) {
      _subscribe();
    }
  }

  final AlpineRepository? _repository;
  AlpineRepository get _repo => _repository ?? defaultRepositoryInstance;
  String sectionId;
  StreamSubscription<MembersPage>? _membersSub;

  /// Profiles resolved so far, keyed by uid. Prevents re-reading user
  /// documents on every members snapshot and every page load.
  final Map<String, UserProfile> _profileCache = {};

  /// Cursor of the furthest loaded page (`MembersPage.nextCursor`) or `null`
  /// while paging has not advanced past the realtime window.
  Object? _pageCursor;

  /// Whether more members exist beyond everything loaded so far.
  bool _hasMore = false;

  /// Emits only while the cubit is open. Stream listeners capture in-flight
  /// async continuations (e.g. `await _repo.getUserProfiles(...)` inside the
  /// snapshot callback below); after [close] cancels the subscription, such
  /// a continuation can still resume, and a bare `emit` would then trigger
  /// the post-close debug assert.
  void _safeEmit(MemberDirectoryState newState) {
    if (isClosed) return;
    emit(newState);
  }

  void _subscribe() {
    _membersSub?.cancel();
    _pageCursor = null;
    _hasMore = false;
    emit(
      value.copyWith(
        sectionId: sectionId,
        entries: const [],
        isLoading: true,
        hasMoreMembers: false,
        isLoadingMore: false,
        error: null,
      ),
    );
    // Cheap aggregate count queries (≤1 read per 1000 docs each); not awaited
    // so the member list can stream in meanwhile. Totals stay `null` (UI falls
    // back to loaded-window counts) if they fail.
    unawaited(_refreshCounts());

    _membersSub = _repo
        .streamSectionMembers(sectionId, limit: _windowSize)
        .listen(
          (page) async {
            try {
              // Don't clobber an advanced cursor built up by [loadMore].
              _pageCursor ??= page.nextCursor;
              await _mergeMembers(page.members);
              if (isClosed) return;
              // A full window strongly suggests more pages exist; exact
              // knowledge only comes from paging with [loadMore].
              _hasMore = page.members.length >= _windowSize;
              _safeEmit(value.copyWith(hasMoreMembers: _hasMore, isLoading: false, error: null));
            } catch (e, st) {
              _log.warning('Error streaming section members: $e', e, st);
              if (isClosed) return;
              _safeEmit(value.copyWith(isLoading: false, error: e));
            }
          },
          onError: (Object e, StackTrace st) {
            _log.warning('Error streaming section members: $e', e, st);
            if (isClosed) return;
            _safeEmit(value.copyWith(isLoading: false, error: e));
          },
        );
  }

  /// Fetches the true section-wide member count via an aggregate count query
  /// and emits it. Failures are logged; the total remains null and the UI
  /// falls back to loaded-window counts.
  Future<void> _refreshCounts() async {
    try {
      final total = await _repo.getSectionMemberCount(sectionId);
      _log.fine('Member count for $sectionId: $total');
      if (isClosed) return;
      _safeEmit(value.copyWith(allTotal: total));
    } catch (e, st) {
      _log.warning('Failed to fetch member count: $e', e, st);
    }
  }

  /// Merges member records into the loaded set and resolves any missing
  /// profiles from the per-_uid cache, then re-emits [entries].
  Future<void> _mergeMembers(List<SectionMember> incoming) async {
    final byId = <String, SectionMember>{for (final e in value.entries) e.userId: e.member};
    for (final m in incoming) {
      byId[m.id] = m;
    }

    final missing = byId.keys.where((uid) => !_profileCache.containsKey(uid)).toList();
    if (missing.isNotEmpty) {
      try {
        final loaded = await _repo.getUserProfiles(missing);
        for (final entry in loaded.entries) {
          _profileCache[entry.key] = entry.value;
        }
      } catch (e, st) {
        _log.warning('Error resolving member profiles: $e', e, st);
        // Members still display (id fallback); don't fail the whole page.
      }
      if (isClosed) return;
    }

    final entries = [for (final m in byId.values) MemberDirectoryEntry(member: m, profile: _profileCache[m.id])];
    _safeEmit(value.copyWith(entries: entries, isLoading: false));
  }

  /// Loads the next page of members beyond the realtime window.
  Future<void> loadMore() async {
    if (value.isLoadingMore || isClosed) return;
    emit(value.copyWith(isLoadingMore: true));
    try {
      final page = await _repo.getSectionMembersPage(sectionId, limit: _windowSize, startAfter: _pageCursor);
      if (isClosed) return;
      _pageCursor = page.nextCursor;
      _hasMore = page.hasMore;
      await _mergeMembers(page.members);
      if (isClosed) return;
      _safeEmit(value.copyWith(hasMoreMembers: _hasMore));
    } catch (e, st) {
      _log.warning('Error loading more members: $e', e, st);
      if (isClosed) return;
      _safeEmit(value.copyWith(error: e));
    } finally {
      if (!isClosed) _safeEmit(value.copyWith(isLoadingMore: false));
    }
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

  /// Refreshes the directory data and forces profile data to be re-read
  /// (the profile cache is cleared).
  Future<void> refresh() async {
    _profileCache.clear();
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
      if (isClosed) return;
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
