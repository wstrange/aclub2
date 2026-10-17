import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shared_models/shared_models.dart';

import '../repo.dart';

/// Number of member documents read per Firestore page.
const int _pageSize = 40;

/// Bottom-sheet picker for adding a participant to an event, with a "search
/// by name or email" filter box.
///
/// Firestore cost model:
///
/// * Members are fetched in bounded pages of [_pageSize] documents instead of
///   reading the whole `members` subcollection, so opening the sheet never
///   costs more than [_pageSize] reads regardless of section size.
/// * User profiles needed for name/email display are batch-loaded with
///   `whereIn` (≤30 ids per query) only for the fetched window.
/// * Typing in the filter box runs entirely client-side over already-loaded
///   data and costs zero reads.
/// * If the person isn't in the loaded window, "Load more" fetches the next
///   [_pageSize]-document page on demand.
class AddParticipantSheet extends HookWidget {
  // Primary-constructor head syntax can't be combined with `const`, and this
  // class must have a const constructor, so use a classic one here.
  // ignore: use_primary_constructors
  const AddParticipantSheet({
    super.key,
    required this.sectionId,
    required this.excludedIds,
    required this.isSaving,
    required this.onPickMember,
  });

  final String sectionId;

  /// Member (user) IDs to hide from the list, e.g. already-registered users.
  final Set<String> excludedIds;

  /// Shared saving flag; picker tiles read it (non-reactively, matching the
  /// page's behaviour) to disable interaction while a participant is added.
  final ValueNotifier<bool> isSaving;

  /// Called with the picked member's user ID; the caller closes the sheet
  /// before this fires.
  final void Function(String userId) onPickMember;

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final query = useState('');
    final members = useState<List<SectionMember>>([]);
    final profiles = useState<Map<String, UserProfile>>({});
    final loading = useState(true);
    final loadingMore = useState(false);
    final hasMore = useState(false);
    final error = useState<String?>(null);
    final cursor = useRef<Object?>(null);

    Future<void> loadNextPage({bool append = false}) async {
      if (loadingMore.value) return;
      if (append) {
        loadingMore.value = true;
      } else {
        loading.value = true;
        error.value = null;
        members.value = const [];
        profiles.value = {};
        cursor.value = null;
      }
      try {
        final page = await repository.getSectionMembersPage(
          sectionId,
          limit: _pageSize,
          startAfter: append ? cursor.value : null,
        );
        if (!context.mounted) return;

        cursor.value = page.nextCursor;
        hasMore.value = page.hasMore;

        final merged = <String, SectionMember>{for (final m in members.value) m.id: m};
        for (final m in page.members) {
          merged.putIfAbsent(m.id, () => m);
        }
        members.value = merged.values.toList();

        // Batch-load profiles for newly fetched users (≤30 ids per query).
        final missing = page.members.map((m) => m.id).where((id) => !profiles.value.containsKey(id)).toSet().toList();
        if (missing.isNotEmpty) {
          final loaded = await repository.getUserProfiles(missing);
          if (!context.mounted) return;
          profiles.value = {...profiles.value, ...loaded};
        }
      } catch (e) {
        if (context.mounted) error.value = '$e';
      } finally {
        if (context.mounted) {
          loading.value = false;
          loadingMore.value = false;
        }
      }
    }

    useEffect(() {
      loadNextPage();
      return null;
    }, [sectionId]);

    String displayName(SectionMember member) {
      final profile = profiles.value[member.id];
      if (profile == null) return member.id;
      final name = [profile.firstName, profile.lastName].where((s) => s.isNotEmpty).join(' ').trim();
      if (name.isNotEmpty) return name;
      final email = profile.email;
      return (email != null && email.isNotEmpty) ? email : member.id;
    }

    String emailOf(SectionMember member) {
      final profile = profiles.value[member.id];
      final email = profile?.email;
      return (email == null || email.isEmpty) ? '' : email;
    }

    final q = query.value.trim().toLowerCase();
    final filtered =
        members.value
            .where((m) => !excludedIds.contains(m.id))
            .where((m) => q.isEmpty || displayName(m).toLowerCase().contains(q) || emailOf(m).contains(q))
            .toList()
          ..sort((a, b) => displayName(a).compareTo(displayName(b)));

    Widget content;
    if (loading.value) {
      content = const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (error.value != null) {
      content = Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: Text('Error loading members: ${error.value}')),
      );
    } else if (filtered.isEmpty && q.isEmpty) {
      content = const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('No section members to show.')),
      );
    } else if (filtered.isEmpty) {
      content = Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No loaded member matches "$q".\nUse "Load more members" to search further.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      content = ListView.builder(
        shrinkWrap: true,
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final member = filtered[index];
          final email = emailOf(member);
          final name = displayName(member);
          return ListTile(
            leading: CircleAvatar(
              child: name.isEmpty || name == member.id ? const Icon(Icons.person_outline) : Text(name[0].toUpperCase()),
            ),
            title: Text(name, style: const TextStyle(fontSize: 14)),
            subtitle: Text(
              email.isEmpty ? member.sectionRole.name : '${member.sectionRole.name} · $email',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            enabled: !isSaving.value,
            onTap: isSaving.value ? null : () => onPickMember(member.id),
          );
        },
      );
    }

    final showLoadMore = !loading.value && hasMore.value && error.value == null;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Add Participant',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search by name or email',
                  isDense: true,
                  suffixIcon: q.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            query.value = '';
                          },
                        ),
                ),
                onChanged: (value) => query.value = value,
              ),
            ),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: content),
                  if (showLoadMore)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 16),
                      child: Center(
                        child: loadingMore.value
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: FilledButton.tonal(
                                  onPressed: () => loadNextPage(append: true),
                                  child: Text(
                                    filtered.isEmpty && q.isNotEmpty
                                        ? 'No match yet — load more members'
                                        : 'Load more members',
                                  ),
                                ),
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
