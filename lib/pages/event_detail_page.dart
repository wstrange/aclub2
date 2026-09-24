import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kaisel/kaisel.dart';
import 'package:logging/logging.dart';
import 'package:shared_models/shared_models.dart';

import '../repo.dart';
import '../routes.dart';
import '../state/event_details_cubit.dart';
import '../state/event_details_state.dart';
import '../state/user_state_cubit.dart';
import '../widgets/user_display.dart';

final _log = Logger('EventDetailPage');

/// Read-only page showing full details for an [Event].
/// Edit functionality is reached from here, not from the calendar.
class EventDetailPage extends HookWidget {
  const EventDetailPage({super.key, required this.sectionId, required this.eventId});

  final String sectionId;
  final String eventId;

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(() => EventDetailsCubit(sectionId: sectionId, eventId: eventId), [sectionId, eventId]);
    useEffect(
      () =>
          () => cubit.close(),
      [cubit],
    );

    return BlocSignalProvider<EventDetailsCubit>.value(
      value: cubit,
      child: BlocSignalBuilder<EventDetailsCubit, EventDetailsState>(
        builder: (context, state) {
          if (state.isEventLoading && state.event == null) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (state.error != null && state.event == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Event Details')),
              body: Center(
                child: Text(
                  'Error loading event: ${state.error}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            );
          }

          final event = state.event;
          if (event == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Event Details')),
              body: const Center(child: Text('Event not found.')),
            );
          }

          return _EventDetailView(sectionId: sectionId, event: event);
        },
      ),
    );
  }
}

/// The fully-loaded detail view for an [event]. Consumes the surrounding
/// [EventDetailsCubit] (provided by [EventDetailPage]) for registrations and
/// mutations; UI-only flows such as dialogs and snackbars live here.
class _EventDetailView extends StatelessWidget {
  const _EventDetailView({required this.sectionId, required this.event});

  final String sectionId;
  final Event event;

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final userState = context.watch<UserStateCubit>().state.value;
    final canManage = currentUid != null &&
        userState != null &&
        context.read<UserStateCubit>().canManageSection(sectionId);

    Future<void> openEdit() async {
      await context.push(EventEditRoute(sectionId: sectionId, eventId: event.id));
    }

    Future<void> copyEvent() async {
      final copyRelations = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Copy Event'),
          content: Text(
            'This creates a copy of "${event.title}" with the date(s) brought '
            'up to the current day.\n\n'
            'Copy over the current participants and trip leaders?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Event only'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Copy participants & leaders'),
            ),
          ],
        ),
      );
      if (copyRelations == null || !context.mounted) return;

      if (currentUid == null) return;

      try {
        final copy = await repository.duplicateEvent(
          sectionId,
          source: event,
          copyParticipantsAndLeaders: copyRelations,
          creatorId: currentUid,
        );
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event copied.')));
        // Edit the copy; if it is saved, swap the original event's details for
        // the copied event's details so the user ends up viewing the copy.
        final saved = await context.pushForResult<bool>(
          EventEditRoute(sectionId: sectionId, eventId: copy.id),
        );
        if (saved == true && context.mounted) {
          context.replaceTop(EventDetailRoute(sectionId: sectionId, eventId: copy.id));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to copy event: $e')));
        }
      }
    }

    Future<void> deleteEvent() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Delete Event'),
          content: Text('Are you sure you want to delete "${event.title}"? This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Theme.of(dialogContext).colorScheme.error),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;

      try {
        await repository.deleteEvent(sectionId, event.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event deleted.')));
        context.pop();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete event: $e')));
        }
      }
    }

    String formatDate(DateTime dt) {
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final weekday = weekdays[dt.weekday - 1];
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$weekday ${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} $hour:$minute';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          if (canManage)
            IconButton(icon: const Icon(Icons.edit), tooltip: 'Edit Event', onPressed: openEdit),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Chip(label: Text(event.status.name)),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text(event.type.name)),
                if (event.difficulty != Difficulty.moderate) Chip(label: Text(event.difficulty.name)),
                if (event.requiresApproval) const Chip(label: Text('Approval required')),
              ],
            ),
            const SizedBox(height: 16),
            if (event.description != null && event.description!.isNotEmpty) ...[
              MarkdownBody(data: event.description!),
              const SizedBox(height: 16),
            ],
            _RegistrationSection(event: event),
            _sectionHeader('Schedule'),
            _detailRow('Start', formatDate(event.startDate)),
            _detailRow('End', formatDate(event.endDate)),

            if (event.location != null) ...[
              _sectionHeader('Location'),
              _detailRow('Description', event.location!.description ?? ''),
              if (event.location!.mapUrl != null && event.location!.mapUrl!.isNotEmpty)
                _detailRow('Map', event.location!.mapUrl ?? ''),
            ],

            if (event.carpoolOption != null) ...[
              _sectionHeader('Carpooling'),
              _detailRow('Meet Time', formatDate(event.carpoolOption!.meetTime)),
              _detailRow('Meet Place', event.carpoolOption!.meetPlace),
              if (event.carpoolOption!.mapUrl != null && event.carpoolOption!.mapUrl!.isNotEmpty)
                _detailRow('Map', event.carpoolOption!.mapUrl ?? ''),
            ],

            _sectionHeader('Capacity & Registration'),
            _detailRow('Participants', '${event.minParticipants} - ${event.maxParticipants}'),
            _detailRow('Approval Required', event.requiresApproval ? 'Yes' : 'No'),

            _sectionHeader('Leadership'),
            _LeadershipSection(sectionId: sectionId, event: event),

            if (canManage) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: openEdit,
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Event'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: copyEvent,
                        icon: const Icon(Icons.copy_all_outlined),
                        label: const Text('Copy Event'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                  onPressed: deleteEvent,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete Event'),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

/// Shows the event's creator and trip leaders. A section manager or trip
/// leader can assign additional trip leaders from the section's members.
class _LeadershipSection extends HookWidget {
  const _LeadershipSection({required this.sectionId, required this.event});

  final String sectionId;
  final Event event;

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final userState = context.watch<UserStateCubit>().state.value;
    final canManage = currentUid != null &&
        userState != null &&
        context.read<UserStateCubit>().canManageSection(sectionId);

    final leaderIds = event.tripLeaderIds;

    Future<void> assignLeader(String uid) async {
      if (leaderIds.contains(uid)) return;
      try {
        await context.read<EventDetailsCubit>().assignTripLeader(uid);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trip leader added.')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add trip leader: $e')));
        }
      }
    }

    Future<void> removeLeader(String uid) async {
      try {
        await context.read<EventDetailsCubit>().removeTripLeader(uid);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trip leader removed.')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to remove trip leader: $e')));
        }
      }
    }

    Future<void> confirmRemove(String uid) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Remove trip leader?'),
          content: const Text('They will no longer be able to manage this event.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Remove')),
          ],
        ),
      );
      if (confirmed == true) {
        await removeLeader(uid);
      }
    }

    void showAssignSheet() {
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) {
          return SafeArea(
            child: FutureBuilder<List<SectionMember>>(
              future: repository.getSectionMembers(sectionId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text('Error loading members: ${snapshot.error}')),
                  );
                }
                final candidates = (snapshot.data ?? const <SectionMember>[])
                    .where((m) => !leaderIds.contains(m.id))
                    .toList();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(
                        'Assign Trip Leader',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (candidates.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('No other section members to assign.')),
                      )
                    else
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: candidates.length,
                          itemBuilder: (context, index) {
                            final member = candidates[index];
                            return ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: UserDisplay(userId: member.id, style: const TextStyle(fontSize: 14)),
                              subtitle: Text(member.sectionRole.name),
                              onTap: () {
                                Navigator.of(sheetContext).pop();
                                assignLeader(member.id);
                              },
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 120,
                child: Text('Created by', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ),
              Expanded(
                child: UserDisplay(userId: event.creatorId, style: const TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 120,
                child: Text('Trip Leaders', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ),
              Expanded(
                child: leaderIds.isEmpty
                    ? const Text('No trip leaders assigned.', style: TextStyle(fontSize: 14))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final leaderId in leaderIds)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  const Icon(Icons.emoji_people_outlined, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: UserDisplay(userId: leaderId, style: const TextStyle(fontSize: 14)),
                                  ),
                                  if (canManage && leaderId != event.creatorId)
                                    IconButton(
                                      icon: Icon(
                                        Icons.person_remove_outlined,
                                        size: 20,
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                      tooltip: 'Remove Trip Leader',
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => confirmRemove(leaderId),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
        if (canManage)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: showAssignSheet,
                icon: const Icon(Icons.person_add_alt, size: 18),
                label: const Text('Assign Trip Leader'),
              ),
            ),
          ),
      ],
    );
  }
}

/// Shows the current user's registration status for an [event] and lets them
/// register. Approval-required events go to a waitlist; otherwise the user is
/// added directly if the event has space.
class _RegistrationSection extends HookWidget {
  const _RegistrationSection({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final eventDetails = context.watch<EventDetailsCubit>().state.value;
    final registrations = eventDetails.registrations;
    final isRegistrationsLoading = eventDetails.isRegistrationsLoading;

    final isSaving = useState(false);
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    final myRegistration = currentUid == null ? null : registrations.where((r) => r.userId == currentUid).firstOrNull;

    final canManage = currentUid != null && context.read<UserStateCubit>().canManageSection(event.sectionId);

    // Only approved registrations count towards the event's capacity.
    final approvedCount = registrations.where((r) => r.status == RegistrationStatus.approved).length;
    final hasSpace = approvedCount < event.maxParticipants;

    Future<void> setStatus(Registration registration, RegistrationStatus status) async {
      isSaving.value = true;
      try {
        await context.read<EventDetailsCubit>().setRegistrationStatus(registration, status);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update registration: $e')));
        }
      } finally {
        isSaving.value = false;
      }
    }

    Future<void> approve(Registration registration) async {
      if (!hasSpace) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This event is full.')));
        }
        return;
      }
      await setStatus(registration, RegistrationStatus.approved);
    }

    Future<void> unregister(String userId, {required String confirmTitle, required String confirmMessage, required String successMessage}) async {
      final cubit = context.read<EventDetailsCubit>();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(confirmTitle),
          content: Text(confirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Remove'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      isSaving.value = true;
      try {
        await cubit.removeRegistration(userId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage)));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to remove: $e')));
        }
      } finally {
        isSaving.value = false;
      }
    }

    Future<void> remove(Registration registration) {
      return unregister(
        registration.userId,
        confirmTitle: 'Remove registration?',
        confirmMessage: 'This removes the participant from the event.',
        successMessage: 'Registration removed.',
      );
    }

    Future<void> withdraw() async {
      final uid = currentUid;
      if (uid == null) return;
      await unregister(
        uid,
        confirmTitle: 'Withdraw from event?',
        confirmMessage: 'You will no longer be registered for this event.',
        successMessage: 'You have withdrawn from the event.',
      );
    }

    Future<void> register() async {
      if (currentUid == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in to register.')));
        return;
      }

      final RegistrationStatus status;
      if (event.requiresApproval) {
        status = hasSpace ? RegistrationStatus.pending : RegistrationStatus.waitlisted;
      } else {
        if (!hasSpace) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This event is full.')));
          return;
        }
        status = RegistrationStatus.approved;
      }

      final now = DateTime.now();
      final registration = Registration(
        id: currentUid,
        userId: currentUid,
        status: status,
        registeredAt: now,
        updatedAt: now,
      );

      isSaving.value = true;
      try {
        await context.read<EventDetailsCubit>().register(registration);
        if (context.mounted) {
          final message = switch (status) {
            RegistrationStatus.waitlisted => 'You are on the waitlist.',
            RegistrationStatus.pending => 'Registration pending approval.',
            _ => 'Registered successfully.',
          };
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to register: $e')));
        }
      } finally {
        isSaving.value = false;
      }
    }

    Future<void> addParticipant(String userId, RegistrationStatus status) async {
      if (status == RegistrationStatus.approved && !hasSpace) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('This event is full. Add them to the waitlist instead.')));
        }
        return;
      }

      isSaving.value = true;
      try {
        await context.read<EventDetailsCubit>().addParticipant(userId, status);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(status == RegistrationStatus.approved ? 'Added to event.' : 'Added to waitlist.')),
          );
        }
      } catch (e, stackTrace) {
        _log.severe('Failed to add participant $userId to event ${event.id}: $e\n$stackTrace');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add participant: $e')));
        }
      } finally {
        isSaving.value = false;
      }
    }

    Future<void> pickAddStatus(String userId) async {
      final status = await showDialog<RegistrationStatus>(
        context: context,
        builder: (dialogContext) => SimpleDialog(
          title: const Text('Add to event or waitlist?'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(RegistrationStatus.approved),
              child: const Row(
                children: [Icon(Icons.event_available, size: 20), SizedBox(width: 12), Text('Add to event')],
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(RegistrationStatus.waitlisted),
              child: const Row(
                children: [Icon(Icons.hourglass_top, size: 20), SizedBox(width: 12), Text('Add to waitlist')],
              ),
            ),
            SimpleDialogOption(onPressed: () => Navigator.of(dialogContext).pop(null), child: const Text('Cancel')),
          ],
        ),
      );
      if (status != null) {
        await addParticipant(userId, status);
      }
    }

    void showAddParticipantSheet() {
      final registeredIds = registrations.map((r) => r.userId).toSet();
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) {
          return SafeArea(
            child: FutureBuilder<List<SectionMember>>(
              future: repository.getSectionMembers(event.sectionId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text('Error loading members: ${snapshot.error}')),
                  );
                }
                final candidates = (snapshot.data ?? const <SectionMember>[])
                    .where((m) => !registeredIds.contains(m.id))
                    .toList();

                return Column(
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
                    if (candidates.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('All section members are already registered.')),
                      )
                    else
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: candidates.length,
                          itemBuilder: (context, index) {
                            final member = candidates[index];
                            return ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: UserDisplay(userId: member.id, style: const TextStyle(fontSize: 14)),
                              subtitle: Text(member.sectionRole.name),
                              enabled: !isSaving.value,
                              onTap: () {
                                Navigator.of(sheetContext).pop();
                                pickAddStatus(member.id);
                              },
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
      );
    }

    final String statusLabel = switch (myRegistration?.status) {
      null => 'Not registered',
      RegistrationStatus.approved => 'Approved',
      RegistrationStatus.pending => 'Pending approval',
      RegistrationStatus.waitlisted => 'On waitlist',
      RegistrationStatus.rejected => 'Rejected',
      RegistrationStatus.attended => 'Attended',
      RegistrationStatus.absent => 'Absent',
    };

    final bool canRegister = currentUid != null && myRegistration == null && (hasSpace || event.requiresApproval);

    // Registrations a leader/manager can act on: pending, waitlisted, approved.
    final manageable = registrations
        .where(
          (r) =>
              r.status == RegistrationStatus.pending ||
              r.status == RegistrationStatus.waitlisted ||
              r.status == RegistrationStatus.approved,
        )
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_available, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Registration',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('$approvedCount / ${event.maxParticipants} participants'),
            const SizedBox(height: 4),
            Text(myRegistration == null ? statusLabel : 'Your status: $statusLabel'),
            if (isRegistrationsLoading)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (canRegister) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  onPressed: isSaving.value ? null : register,
                  child: isSaving.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Register'),
                ),
              ),
            ] else if (myRegistration != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: isSaving.value ? null : withdraw,
                  icon: const Icon(Icons.person_remove_outlined, size: 20),
                  label: isSaving.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Withdraw'),
                ),
              ),
            ],
            if (canManage) ...[
              const SizedBox(height: 16),
              Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
              const SizedBox(height: 12),
              Text(
                'Manage registrations',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: isSaving.value ? null : showAddParticipantSheet,
                  icon: const Icon(Icons.person_add_alt, size: 18),
                  label: const Text('Add Participant'),
                ),
              ),
            ],
            if (canManage && manageable.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final registration in manageable)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: UserDisplay(userId: registration.userId, style: const TextStyle(fontSize: 14)),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(registration.status.name, style: const TextStyle(fontSize: 11)),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 8),
                      if (registration.status == RegistrationStatus.approved)
                        TextButton(
                          onPressed: isSaving.value
                              ? null
                              : () => setStatus(registration, RegistrationStatus.waitlisted),
                          child: const Text('To waitlist'),
                        )
                      else
                        TextButton(
                          onPressed: isSaving.value ? null : () => approve(registration),
                          child: const Text('Approve'),
                        ),
                      const SizedBox(width: 4),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Remove',
                        onPressed: isSaving.value ? null : () => remove(registration),
                        icon: const Icon(Icons.delete_outline, size: 18),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
