import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_models/shared_models.dart';

import '../repo.dart';
import '../state/member_directory_cubit.dart';
import '../state/member_directory_state.dart';
import '../state/user_state.dart';
import '../state/user_state_cubit.dart';
import '../widgets/user_avatar.dart';

/// Role filter options for the app-bar dropdown: label shown for each filter
/// value (null = no role filter, i.e. all members). Managers and trip leaders
/// are members too, so there is no "Members" entry — "All members" covers it.
const List<(SectionRole?, String)> _roleFilterEntries = [
  (null, 'All members'),
  (SectionRole.sectionManager, 'Managers'),
  (SectionRole.tripLeader, 'Trip Leaders'),
];

/// Title for the all-members / load-more tile: shows loaded-of-total while
/// the member list is windowed, and the plain total once everything is loaded
/// (or when only window counts are available).
String _allTileTitle(MemberDirectoryState state) {
  if (state.hasMoreMembers) {
    return 'All members (${state.totalCount} of ${state.allTotal ?? '…'})';
  }
  return 'All members (${state.displayAllCount})';
}

/// Subtitle spelling out what tapping the tile does.
String _allTileSubtitle(MemberDirectoryState state) {
  if (state.hasMoreMembers) {
    final remaining = state.allTotal == null ? null : state.allTotal! - state.totalCount;
    return remaining == null ? 'Tap to load more members' : '$remaining more members available — tap to load';
  }
  if (state.selectedRole != null) return 'Tap to show every member';
  if (state.allTotal != null && state.allTotal! > state.totalCount) {
    return '${state.allTotal! - state.totalCount} not loaded yet — tap to refresh';
  }
  return 'Tap to show every member';
}

/// Screen allowing members to look up, search, and view profiles of other
/// members in the same section.
class const MembersDirectoryPage({super.key, this.initialSectionId}) extends StatelessWidget {
  final String? initialSectionId;

  @override
  Widget build(BuildContext context) {
    return BlocSignalBuilder<UserStateCubit, UserState?>(
      builder: (context, userState) {
        if (userState == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (userState.isAdmin) {
          return _GlobalAdminDirectory(
            initialSectionId: initialSectionId,
            currentSectionId: userState.currentSection.id,
            fallbackSections: userState.userSections,
          );
        }

        final userSections = userState.userSections;
        if (userSections.isEmpty) {
          return const _NoSectionsView();
        }

        final targetSectionId = initialSectionId != null && userSections.any((s) => s.id == initialSectionId)
            ? initialSectionId!
            : userState.currentSection.id;

        return BlocSignalProvider<MemberDirectoryCubit>(
          key: ValueKey('member-directory-$targetSectionId'),
          create: (_) => MemberDirectoryCubit(sectionId: targetSectionId),
          child: _MembersDirectoryView(userSections: userSections, isGlobalAdmin: false),
        );
      },
    );
  }
}

/// Global-admin variant of the directory: loads every section once, then lets
/// the directory switch between them.
///
/// The section list is cached in [initState] so rebuilding the page does not
/// re-issue the Firestore query, and the provider is keyed by section so
/// switching sections creates a fresh cubit rather than reusing stale data.
class const _GlobalAdminDirectory({
  required this.initialSectionId,
  required this.currentSectionId,
  required this.fallbackSections,
}) extends StatefulWidget {
  final String? initialSectionId;
  final String currentSectionId;
  final List<Section> fallbackSections;

  @override
  State<_GlobalAdminDirectory> createState() => _GlobalAdminDirectoryState();
}

class _GlobalAdminDirectoryState() extends State<_GlobalAdminDirectory> {
  late Future<List<Section>> _sectionsFuture;

  @override
  void initState() {
    super.initState();
    _sectionsFuture = repository.getSections();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Section>>(
      future: _sectionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done && snapshot.data == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final sections = (snapshot.data != null && snapshot.data!.isNotEmpty)
            ? snapshot.data!
            : widget.fallbackSections;
        if (sections.isEmpty) {
          return const _NoSectionsView();
        }

        final targetSectionId = widget.initialSectionId != null && sections.any((s) => s.id == widget.initialSectionId)
            ? widget.initialSectionId!
            : (sections.any((s) => s.id == widget.currentSectionId) ? widget.currentSectionId : sections.first.id);

        return BlocSignalProvider<MemberDirectoryCubit>(
          key: ValueKey('member-directory-$targetSectionId'),
          create: (_) => MemberDirectoryCubit(sectionId: targetSectionId),
          child: _MembersDirectoryView(userSections: sections, isGlobalAdmin: true),
        );
      },
    );
  }
}

/// Shown when the user has no sections (or a global admin has no sections at
/// all) instead of dereferencing `sections.first`.
class const _NoSectionsView() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.group_off_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text('No sections available', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Text(
                'You are not a member of any section yet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class const _MembersDirectoryView({required this.userSections, this.isGlobalAdmin = false}) extends StatefulWidget {
  final List<Section> userSections;
  final bool isGlobalAdmin;

  @override
  State<_MembersDirectoryView> createState() => _MembersDirectoryViewState();
}

class _MembersDirectoryViewState() extends State<_MembersDirectoryView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocSignalBuilder<MemberDirectoryCubit, MemberDirectoryState>(
      builder: (context, state) {
        final currentSection = widget.userSections.firstWhere(
          (s) => s.id == state.sectionId,
          orElse: () => widget.userSections.first,
        );

        final isSectionAdmin = userStateCubit.roleFor(state.sectionId) == SectionRole.sectionManager;
        final canManageRoles = widget.isGlobalAdmin || isSectionAdmin;

        return Scaffold(
          appBar: AppBar(
            title: widget.userSections.length > 1
                ? DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentSection.id,
                      icon: const Icon(Icons.arrow_drop_down),
                      items: widget.userSections
                          .map(
                            (s) => DropdownMenuItem(
                              value: s.id,
                              child: Text('${s.name} Directory', style: const TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          )
                          .toList(),
                      onChanged: (newId) {
                        if (newId != null) {
                          context.read<MemberDirectoryCubit>().changeSection(newId);
                        }
                      },
                    ),
                  )
                : Text('${currentSection.name} Directory'),
            actions: [
              // Role filter as a dropdown — filters are rarely used, so they
              // live in the app bar instead of taking up permanent screen
              // space. Tinted when active so a filter is never forgotten.
              PopupMenuButton<SectionRole?>(
                tooltip: 'Filter by role',
                icon: state.selectedRole == null
                    ? const Icon(Icons.filter_list)
                    : Icon(Icons.filter_list, color: Theme.of(context).colorScheme.primary),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                initialValue: state.selectedRole,
                onSelected: (role) => context.read<MemberDirectoryCubit>().setRoleFilter(role),
                itemBuilder: (context) => [
                  for (final entry in _roleFilterEntries)
                    PopupMenuItem<SectionRole?>(
                      value: entry.$1,
                      child: Row(
                        children: [
                          if (state.selectedRole == entry.$1)
                            const Icon(Icons.check, size: 18)
                          else
                            const Icon(Icons.check, size: 18, color: Colors.transparent),
                          const SizedBox(width: 8),
                          Text(entry.$2),
                        ],
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: () => context.read<MemberDirectoryCubit>().refresh(),
              ),
            ],
          ),
          body: Column(
            children: [
              // Search input bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, role, certification...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<MemberDirectoryCubit>().setSearchQuery('');
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (text) {
                    context.read<MemberDirectoryCubit>().setSearchQuery(text);
                    setState(() {});
                  },
                ),
              ),

              // All members / load more tile.
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    title: Text(_allTileTitle(state), style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(_allTileSubtitle(state)),
                    trailing: state.isLoadingMore
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : state.hasMoreMembers
                        ? const Icon(Icons.expand_more)
                        : null,
                    onTap: () {
                      final cubit = context.read<MemberDirectoryCubit>();
                      // While member data is windowed, tapping loads the next
                      // page; otherwise tapping clears any role filter.
                      if (state.hasMoreMembers) {
                        cubit.loadMore();
                      } else {
                        cubit.setRoleFilter(null);
                      }
                    },
                  ),
                ),
              ),

              // Members list
              Expanded(child: _buildMembersList(context, state, canManageRoles)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMembersList(BuildContext context, MemberDirectoryState state, bool canManageRoles) {
    if (state.isLoading && state.entries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text('Failed to load member directory', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                '${state.error}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: () => context.read<MemberDirectoryCubit>().refresh(),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = state.filteredEntries;
    if (filtered.isEmpty) {
      final isFiltering = state.searchQuery.isNotEmpty || state.selectedRole != null;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isFiltering ? Icons.search_off : Icons.group_off_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                isFiltering ? 'No members match your criteria' : 'No members found in this section',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (isFiltering) ...[
                if (state.hasMoreMembers) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Search covers loaded members — tap "All members" above to load more.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    context.read<MemberDirectoryCubit>().setSearchQuery('');
                    context.read<MemberDirectoryCubit>().setRoleFilter(null);
                    setState(() {});
                  },
                  child: const Text('Clear Filters'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<MemberDirectoryCubit>().refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 32),
        itemCount: filtered.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final entry = filtered[index];
          return _MemberCard(
            entry: entry,
            canManageRoles: canManageRoles,
            onTap: () => _showMemberDetailsSheet(context, entry, canManageRoles),
            onEditRole: canManageRoles ? () => _promptChangeRole(context, entry) : null,
          );
        },
      ),
    );
  }

  void _showMemberDetailsSheet(BuildContext context, MemberDirectoryEntry entry, bool canManageRoles) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => _MemberDetailBottomSheet(
        entry: entry,
        canManageRoles: canManageRoles,
        onEditRole: canManageRoles ? () => _promptChangeRole(context, entry) : null,
      ),
    );
  }

  Future<void> _promptChangeRole(BuildContext context, MemberDirectoryEntry entry) async {
    final currentRole = entry.role;
    final currentUserId = context.read<UserStateCubit>().state.value?.user.uid;
    final cubit = context.read<MemberDirectoryCubit>();

    final selectedRole = await showDialog<SectionRole>(
      context: context,
      builder: (dialogContext) {
        return _ChangeRoleDialog(memberName: entry.displayName, currentRole: currentRole);
      },
    );

    if (selectedRole == null || selectedRole == currentRole || !context.mounted) {
      return;
    }

    // If demoting oneself from sectionManager, warn the user
    if (entry.userId == currentUserId &&
        currentRole == SectionRole.sectionManager &&
        selectedRole != SectionRole.sectionManager) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (confirmContext) => AlertDialog(
          title: const Text('Demote yourself?'),
          content: const Text(
            'You are removing your own Section Manager role for this section. You will lose access to manage member roles and section settings.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(confirmContext).pop(false), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Theme.of(confirmContext).colorScheme.error),
              onPressed: () => Navigator.of(confirmContext).pop(true),
              child: const Text('Demote Myself'),
            ),
          ],
        ),
      );

      if (confirm != true || !context.mounted) return;
    }

    try {
      await cubit.updateMemberRole(entry.userId, selectedRole);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Updated ${entry.displayName}\'s role to ${_roleName(selectedRole)}')));
        if (entry.userId == currentUserId) {
          userStateCubit.refresh();
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Theme.of(context).colorScheme.error, content: Text('Failed to update role: $e')),
        );
      }
    }
  }
}

class const _MemberCard({required this.entry, required this.onTap, this.canManageRoles = false, this.onEditRole})
    extends StatelessWidget {
  final MemberDirectoryEntry entry;
  final VoidCallback onTap;
  final bool canManageRoles;
  final VoidCallback? onEditRole;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (roleColor, roleIcon) = _roleVisuals(entry.role, theme);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(
                photoUrl: entry.photoUrl,
                initials: entry.initials,
                radius: 24,
                backgroundColor: roleColor.withValues(alpha: 0.2),
                foregroundColor: roleColor,
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.displayName,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        _RoleBadge(label: entry.roleDisplayName, color: roleColor, icon: roleIcon),
                      ],
                    ),
                    if (entry.email != null && entry.email!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.email_outlined, size: 14, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              entry.email!,
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (entry.certifications.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: entry.certifications.take(3).map((cert) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              cert,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (canManageRoles && onEditRole != null)
                IconButton(
                  icon: const Icon(Icons.manage_accounts_outlined),
                  tooltip: 'Change role',
                  onPressed: onEditRole,
                )
              else
                Icon(Icons.chevron_right, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }

  static (Color, IconData) _roleVisuals(SectionRole role, ThemeData theme) => switch (role) {
    SectionRole.sectionManager => (Colors.deepPurple, Icons.admin_panel_settings),
    SectionRole.tripLeader => (Colors.teal, Icons.explore),
    SectionRole.member => (theme.colorScheme.primary, Icons.person),
  };
}

class const _RoleBadge({required this.label, required this.color, required this.icon}) extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class const _MemberDetailBottomSheet({required this.entry, this.canManageRoles = false, this.onEditRole})
    extends StatelessWidget {
  final MemberDirectoryEntry entry;
  final bool canManageRoles;
  final VoidCallback? onEditRole;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (roleColor, roleIcon) = _MemberCard._roleVisuals(entry.role, theme);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                UserAvatar(
                  photoUrl: entry.photoUrl,
                  initials: entry.initials,
                  radius: 32,
                  backgroundColor: roleColor.withValues(alpha: 0.2),
                  foregroundColor: roleColor,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.displayName, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          _RoleBadge(label: entry.roleDisplayName, color: roleColor, icon: roleIcon),
                          if (canManageRoles && onEditRole != null)
                            ActionChip(
                              avatar: const Icon(Icons.edit, size: 14),
                              label: const Text('Change Role'),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                Navigator.of(context).pop();
                                onEditRole!();
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // Membership information
            _DetailTile(icon: Icons.calendar_today_outlined, title: 'Member Since', value: _formatDate(entry.joinedAt)),

            // Contact: Email
            if (entry.email != null && entry.email!.isNotEmpty)
              _DetailTile(
                icon: Icons.email_outlined,
                title: 'Email',
                value: entry.email!,
                trailing: IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: 'Copy email',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: entry.email!));
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Email copied to clipboard')));
                  },
                ),
              ),

            // Contact: Phone
            if (entry.phone != null && entry.phone!.isNotEmpty)
              _DetailTile(
                icon: Icons.phone_outlined,
                title: 'Phone',
                value: entry.phone!,
                trailing: IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: 'Copy phone',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: entry.phone!));
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Phone copied to clipboard')));
                  },
                ),
              ),

            // Certifications
            if (entry.certifications.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Certifications',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: entry.certifications.map((cert) {
                  return Chip(label: Text(cert), avatar: const Icon(Icons.verified, size: 16));
                }).toList(),
              ),
            ],

            const SizedBox(height: 20),
            Row(
              children: [
                if (canManageRoles && onEditRole != null) ...[
                  Expanded(
                    child: FilledButton.tonalIcon(
                      icon: const Icon(Icons.manage_accounts),
                      label: const Text('Change Role'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onEditRole!();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class const _DetailTile({required this.icon, required this.title, required this.value, this.trailing})
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

String _roleName(SectionRole role) => switch (role) {
  SectionRole.sectionManager => 'Section Manager',
  SectionRole.tripLeader => 'Trip Leader',
  SectionRole.member => 'Member',
};

class const _ChangeRoleDialog({required this.memberName, required this.currentRole}) extends StatefulWidget {
  final String memberName;
  final SectionRole currentRole;

  @override
  State<_ChangeRoleDialog> createState() => _ChangeRoleDialogState();
}

class _ChangeRoleDialogState() extends State<_ChangeRoleDialog> {
  late SectionRole _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.currentRole;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Change Role'),
      content: SingleChildScrollView(
        child: RadioGroup<SectionRole>(
          groupValue: _selectedRole,
          onChanged: (val) {
            if (val != null) setState(() => _selectedRole = val);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select role for ${widget.memberName}:',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              _roleOption(
                role: SectionRole.sectionManager,
                title: 'Section Manager',
                subtitle: 'Can manage events, templates, and member roles',
                icon: Icons.admin_panel_settings,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 8),
              _roleOption(
                role: SectionRole.tripLeader,
                title: 'Trip Leader',
                subtitle: 'Can create and lead section events',
                icon: Icons.explore,
                color: Colors.teal,
              ),
              const SizedBox(height: 8),
              _roleOption(
                role: SectionRole.member,
                title: 'Member',
                subtitle: 'Can view and register for section events',
                icon: Icons.person,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancel')),
        FilledButton(
          onPressed: _selectedRole != widget.currentRole ? () => Navigator.of(context).pop(_selectedRole) : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _roleOption({
    required SectionRole role,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedRole == role;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => setState(() => _selectedRole = role),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? color.withValues(alpha: 0.08) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            Radio<SectionRole>(value: role, activeColor: color),
          ],
        ),
      ),
    );
  }
}
