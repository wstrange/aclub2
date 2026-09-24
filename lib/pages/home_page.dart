import 'package:aclub2/state/user_state_cubit.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaisel/kaisel.dart';
import 'package:shared_models/shared_models.dart';

import '../repo.dart';
import '../routes.dart';
import '../state/user_state.dart';
import '../widgets/calendar_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSignalBuilder<UserStateCubit, UserState?>(
      builder: (context, state) {
        if (state == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final currentSectionId = state.currentSection.id;
        final isCurrentValid = state.userSections.any((s) => s.id == currentSectionId);
        final canManage = context.read<UserStateCubit>().canManageSection(currentSectionId);

        return Scaffold(
          appBar: AppBar(
            title: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: isCurrentValid ? currentSectionId : state.userSections.first.id,
                icon: const Icon(Icons.arrow_drop_down),
                items: state.userSections
                    .map(
                      (section) => DropdownMenuItem<String>(
                        value: section.id,
                        child: Text(section.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    context.read<UserStateCubit>().setCurrentSectionById(value);
                  }
                },
              ),
            ),
            actions: [
              _NotificationIconButton(userId: state.userProfile.id),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sign out',
                onPressed: () async {
                  repository.clearProfileCache();
                  userStateCubit.clear();
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) context.replaceTop(const SignInRoute());
                },
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () async {
                    repository.clearProfileCache();
                    userStateCubit.clear();
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) context.replaceTop(const SignInRoute());
                  },
                ),
                if (canManage)
                  ListTile(
                    leading: const Icon(Icons.add_circle_outline),
                    title: const Text('Create Event'),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(EventCreateRoute(sectionId: state.currentSection.id));
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('My Profile'),
                  onTap: () {
                    context.push(const UserProfileRoute());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.manage_accounts_outlined),
                  title: const Text('Auth Profile'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push(const AuthProfileRoute());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people_outline),
                  title: const Text('Member Directory'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push(MembersDirectoryRoute(sectionId: state.currentSection.id));
                  },
                ),
                if (canManage) const _TemplatesDrawerTile(),
                ListTile(
                  leading: const Icon(Icons.group),
                  title: const Text('My Sections'),
                  onTap: () {
                    context.push(const SectionSelectionRoute());
                  },
                ),
              ],
            ),
          ),
          body: CalendarView(
            key: ValueKey(state.currentSection.id),
            sectionId: state.currentSection.id,
            userId: state.user.uid,
            onEventTap: (event) {
              context.push(EventDetailRoute(sectionId: event.sectionId, eventId: event.id));
            },
          ),
        );
      },
    );
  }
}

/// Drawer entry for the Templates feature.
///
/// Shown when the current user is a global admin, or a manager/trip leader of
/// the currently selected section (read from the loaded [UserState]).
class _TemplatesDrawerTile extends StatelessWidget {
  const _TemplatesDrawerTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.description_outlined),
      title: const Text('Templates'),
      onTap: () {
        Navigator.of(context).pop();
        context.push(const TemplateListRoute());
      },
    );
  }
}

/// App bar icon button displaying a badge with the count of unread notifications.
class _NotificationIconButton extends StatelessWidget {
  const _NotificationIconButton({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NotificationModel>>(
      stream: repository.streamNotifications(userId),
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? const [];
        final unreadCount = notifications.where((n) => !n.isRead).length;

        return IconButton(
          icon: Badge.count(
            count: unreadCount,
            isLabelVisible: unreadCount > 0,
            child: const Icon(Icons.notifications_outlined),
          ),
          tooltip: unreadCount > 0
              ? '$unreadCount unread notification${unreadCount == 1 ? '' : 's'}'
              : 'Notifications',
          onPressed: () => _showNotificationsSheet(context, userId),
        );
      },
    );
  }
}

void _showNotificationsSheet(BuildContext context, String userId) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return StreamBuilder<List<NotificationModel>>(
            stream: repository.streamNotifications(userId),
            builder: (context, snapshot) {
              final notifications = snapshot.data ?? const [];
              final unreadList = notifications.where((n) => !n.isRead).toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Text(
                          'Notifications',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        if (unreadList.isNotEmpty)
                          TextButton(
                            onPressed: () async {
                              for (final n in unreadList) {
                                await repository.markNotificationAsRead(n.id);
                              }
                            },
                            child: const Text('Mark all as read'),
                          ),
                        if (notifications.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.delete_sweep_outlined),
                            tooltip: 'Clear all notifications',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('Clear all notifications?'),
                                  content: const Text('This will delete all of your notifications.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(dialogContext).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.of(dialogContext).pop(true),
                                      child: const Text('Clear all'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await repository.deleteAllNotifications(userId);
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  if (notifications.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.notifications_none, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('No notifications', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: notifications.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return Dismissible(
                            key: ValueKey(notification.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              color: Theme.of(context).colorScheme.error,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) {
                              repository.deleteNotification(notification.id);
                            },
                            child: ListTile(
                              leading: Icon(
                                notification.isRead
                                    ? Icons.notifications_none
                                    : Icons.mark_email_unread_rounded,
                                color: notification.isRead
                                    ? Colors.grey
                                    : Theme.of(context).colorScheme.primary,
                              ),
                              title: Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(notification.message),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatNotificationTime(notification.createdAt),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                tooltip: 'Delete',
                                onPressed: () => repository.deleteNotification(notification.id),
                              ),
                              onTap: () {
                                if (!notification.isRead) {
                                  repository.markNotificationAsRead(notification.id);
                                }
                                if (notification.relatedSectionId != null &&
                                    notification.relatedEventId != null) {
                                  Navigator.of(sheetContext).pop();
                                  context.push(
                                    EventDetailRoute(
                                      sectionId: notification.relatedSectionId!,
                                      eventId: notification.relatedEventId!,
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          );
        },
      );
    },
  );
}

String _formatNotificationTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  final local = dt.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}

