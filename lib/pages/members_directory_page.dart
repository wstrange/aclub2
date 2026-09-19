import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_models/shared_models.dart';

import '../state/member_directory_cubit.dart';
import '../state/member_directory_state.dart';
import '../state/user_state.dart';
import '../state/user_state_cubit.dart';

/// Screen allowing members to look up, search, and view profiles of other
/// members in the same section.
class MembersDirectoryPage extends StatelessWidget {
  const MembersDirectoryPage({super.key, this.initialSectionId});

  final String? initialSectionId;

  @override
  Widget build(BuildContext context) {
    return BlocSignalBuilder<UserStateCubit, UserState?>(
      builder: (context, userState) {
        if (userState == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userSections = userState.userSections;
        final targetSectionId = initialSectionId != null && userSections.any((s) => s.id == initialSectionId)
            ? initialSectionId!
            : userState.currentSection.id;

        return BlocSignalProvider<MemberDirectoryCubit>(
          create: (_) => MemberDirectoryCubit(sectionId: targetSectionId),
          child: _MembersDirectoryView(userSections: userSections),
        );
      },
    );
  }
}

class _MembersDirectoryView extends StatefulWidget {
  const _MembersDirectoryView({required this.userSections});

  final List<Section> userSections;

  @override
  State<_MembersDirectoryView> createState() => _MembersDirectoryViewState();
}

class _MembersDirectoryViewState extends State<_MembersDirectoryView> {
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
                              child: Text(
                                '${s.name} Directory',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
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

              // Filter chips for roles
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    FilterChip(
                      label: Text('All (${state.totalCount})'),
                      selected: state.selectedRole == null,
                      onSelected: (_) => context.read<MemberDirectoryCubit>().setRoleFilter(null),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      avatar: const Icon(Icons.admin_panel_settings, size: 16),
                      label: Text('Managers (${state.managerCount})'),
                      selected: state.selectedRole == SectionRole.sectionManager,
                      onSelected: (selected) => context.read<MemberDirectoryCubit>().setRoleFilter(
                            selected ? SectionRole.sectionManager : null,
                          ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      avatar: const Icon(Icons.explore, size: 16),
                      label: Text('Trip Leaders (${state.tripLeaderCount})'),
                      selected: state.selectedRole == SectionRole.tripLeader,
                      onSelected: (selected) => context.read<MemberDirectoryCubit>().setRoleFilter(
                            selected ? SectionRole.tripLeader : null,
                          ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      avatar: const Icon(Icons.person, size: 16),
                      label: Text('Members (${state.memberCount})'),
                      selected: state.selectedRole == SectionRole.member,
                      onSelected: (selected) => context.read<MemberDirectoryCubit>().setRoleFilter(
                            selected ? SectionRole.member : null,
                          ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 16),

              // Members list
              Expanded(
                child: _buildMembersList(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMembersList(BuildContext context, MemberDirectoryState state) {
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
              Text(
                'Failed to load member directory',
                style: Theme.of(context).textTheme.titleMedium,
              ),
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
              Icon(
                isFiltering ? Icons.search_off : Icons.group_off_outlined,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                isFiltering ? 'No members match your criteria' : 'No members found in this section',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (isFiltering) ...[
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filtered.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final entry = filtered[index];
          return _MemberCard(
            entry: entry,
            onTap: () => _showMemberDetailsSheet(context, entry),
          );
        },
      ),
    );
  }

  void _showMemberDetailsSheet(BuildContext context, MemberDirectoryEntry entry) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _MemberDetailBottomSheet(entry: entry),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.entry, required this.onTap});

  final MemberDirectoryEntry entry;
  final VoidCallback onTap;

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
              CircleAvatar(
                radius: 24,
                backgroundColor: roleColor.withValues(alpha: 0.2),
                foregroundColor: roleColor,
                child: Text(
                  entry.initials,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
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
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _RoleBadge(
                          label: entry.roleDisplayName,
                          color: roleColor,
                          icon: roleIcon,
                        ),
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
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
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

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

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

class _MemberDetailBottomSheet extends StatelessWidget {
  const _MemberDetailBottomSheet({required this.entry});

  final MemberDirectoryEntry entry;

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
                CircleAvatar(
                  radius: 32,
                  backgroundColor: roleColor.withValues(alpha: 0.2),
                  foregroundColor: roleColor,
                  child: Text(
                    entry.initials,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.displayName,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      _RoleBadge(
                        label: entry.roleDisplayName,
                        color: roleColor,
                        icon: roleIcon,
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
            _DetailTile(
              icon: Icons.calendar_today_outlined,
              title: 'Member Since',
              value: _formatDate(entry.joinedAt),
            ),

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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email copied to clipboard')),
                    );
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Phone copied to clipboard')),
                    );
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
                  return Chip(
                    label: Text(cert),
                    avatar: const Icon(Icons.verified, size: 16),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.title,
    required this.value,
    this.trailing,
  });

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
                Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
