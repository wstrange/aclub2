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
import '../utils/snackbars.dart';
import '../widgets/add_participant_sheet.dart';
import '../widgets/calendar_common.dart';
import '../widgets/external_link.dart';
import '../widgets/member_search_bar.dart';
import '../widgets/roster_export.dart';
import '../widgets/user_display.dart' show UserDisplay, UserChip, resolveUserDisplay;

final _log = Logger('EventDetailPage');

/// Read-only page showing full details for an [Event].
/// Edit functionality is reached from here, not from the calendar.
class const EventDetailPage({super.key, required this.sectionId, required this.eventId}) extends HookWidget {
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
class const _EventDetailView({required this.sectionId, required this.event}) extends StatelessWidget {
  final String sectionId;
  final Event event;

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final userState = context.watch<UserStateCubit>().state.value;
    final canManage =
        currentUid != null && userState != null && context.read<UserStateCubit>().canManageSection(sectionId);

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
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(null), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Event only')),
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
        showFloatingSnackBar(context, 'Event copied.');
        // Edit the copy; if it is saved, swap the original event's details for
        // the copied event's details so the user ends up viewing the copy.
        final saved = await context.pushForResult<bool>(EventEditRoute(sectionId: sectionId, eventId: copy.id));
        if (saved == true && context.mounted) {
          context.replaceTop(EventDetailRoute(sectionId: sectionId, eventId: copy.id));
        }
      } catch (e, st) {
        // Full failure details to the console for triage (Firestore
        // PERMISSION_DENIED etc.), a readable/selectable toast for the user.
        _log.warning('copyEvent(${event.id}) in section $sectionId failed', e, st);
        if (context.mounted) {
          showErrorSnackBar(context, message: 'Failed to copy event.', error: e);
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
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
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

    String formatTime(DateTime dt) {
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    String formatDate(DateTime dt) {
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final weekday = weekdays[dt.weekday - 1];
      return '$weekday ${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${formatTime(dt)}';
    }

    // Start and end on one line: a same-day event only repeats the time at the
    // end ("Tue 2026-10-27 09:00 – 17:00").
    String formatDateRange(DateTime start, DateTime end) {
      final sameDay = start.year == end.year && start.month == end.month && start.day == end.day;
      final endText = sameDay ? formatTime(end) : formatDate(end);
      return '${formatDate(start)} – $endText';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          if (canManage) ...[
            IconButton(
              icon: const Icon(Icons.groups_outlined),
              tooltip: 'Export Roster',
              onPressed: () => showRosterExportSheet(context, event),
            ),
            IconButton(icon: const Icon(Icons.edit_outlined), tooltip: 'Edit Event', onPressed: openEdit),
            IconButton(icon: const Icon(Icons.copy_all_outlined), tooltip: 'Copy Event', onPressed: copyEvent),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              tooltip: 'Delete Event',
              onPressed: deleteEvent,
            ),
          ],
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
                if (event.status == EventStatus.draft) const DraftBadge() else const Chip(label: Text('Live')),
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
            _detailValue(formatDateRange(event.startDate, event.endDate)),

            if (event.location != null) ...[
              _sectionHeader('Location'),
              _detailRow('Description', event.location!.description ?? '', url: event.location!.mapUrl),
            ],

            if (event.carpoolOption != null) ...[
              _sectionHeader('Carpooling'),
              _detailRow('Meet Time', formatDate(event.carpoolOption!.meetTime)),
              _detailRow('Meet Place', event.carpoolOption!.meetPlace, url: event.carpoolOption!.mapUrl),
            ],

            _sectionHeader('Leadership'),
            _LeadershipSection(sectionId: sectionId, event: event),

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

  Widget _detailRow(String label, String value, {String? url}) {
    final linkUrl = url?.trim() ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
          Expanded(
            child: linkUrl.isEmpty
                ? Text(value, style: const TextStyle(fontSize: 14))
                : ExternalLink(
                    // Fall back to a generic label when the leader left the
                    // description blank but supplied a map link.
                    text: value.trim().isEmpty ? 'Open map' : value,
                    url: linkUrl,
                  ),
          ),
        ],
      ),
    );
  }

  /// A detail line that has no label column and spans the full width, so long
  /// values (like a start–end range) stay on one line on narrow screens.
  Widget _detailValue(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(value, style: const TextStyle(fontSize: 14)),
    );
  }
}

/// Shows the event's creator and trip leaders. A section manager or trip
/// leader can assign additional trip leaders from the section's members.
class const _LeadershipSection({required this.sectionId, required this.event}) extends HookWidget {
  final String sectionId;
  final Event event;

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final userState = context.watch<UserStateCubit>().state.value;
    final canManage =
        currentUid != null && userState != null && context.read<UserStateCubit>().canManageSection(sectionId);

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
        isScrollControlled: true,
        useSafeArea: true,
        builder: (sheetContext) => _AssignLeaderSheet(
          sectionId: sectionId,
          excludedIds: leaderIds.toSet(),
          onPick: (uid) {
            Navigator.of(sheetContext).pop();
            assignLeader(uid);
          },
        ),
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
                child: UserChip(userId: event.creatorId, style: const TextStyle(fontSize: 14)),
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
                                    child: UserChip(userId: leaderId, style: const TextStyle(fontSize: 14)),
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
class const _RegistrationSection({required this.event}) extends HookWidget {
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

    // Registering is impossible once the event has passed. Managers can
    // still manage existing registrations (e.g. recording attendance).
    final hasEnded = isEventPast(event);

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

    Future<void> unregister(
      String userId, {
      required String confirmTitle,
      required String confirmMessage,
      required String successMessage,
      String? withdrawnByUserId,
    }) async {
      final cubit = context.read<EventDetailsCubit>();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(confirmTitle),
          content: Text(confirmMessage),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Remove')),
          ],
        ),
      );
      if (confirmed != true) return;
      isSaving.value = true;
      try {
        await cubit.withdrawRegistration(userId, withdrawnByUserId: withdrawnByUserId);
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
        withdrawnByUserId: currentUid,
      );
    }

    Future<void> withdraw() async {
      final uid = currentUid;
      if (uid == null) return;
      final cubit = context.read<EventDetailsCubit>();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Withdraw from event?'),
          content: const Text('You will no longer be registered for this event.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Withdraw')),
          ],
        ),
      );
      if (confirmed != true) return;
      isSaving.value = true;
      try {
        await cubit.withdrawRegistration(uid, withdrawnByUserId: uid);
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('You have withdrawn from the event.')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to withdraw: $e')));
        }
      } finally {
        isSaving.value = false;
      }
    }

    Future<void> register() async {
      if (hasEnded) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This event has already ended.')));
        return;
      }
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
      final registeredIds = registrations
          .where((r) => r.status != RegistrationStatus.withdrawn && r.status != RegistrationStatus.rejected)
          .map((r) => r.userId)
          .toSet();
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (sheetContext) {
          return AddParticipantSheet(
            sectionId: event.sectionId,
            excludedIds: registeredIds,
            isSaving: isSaving,
            onPickMember: (userId) {
              Navigator.of(sheetContext).pop();
              pickAddStatus(userId);
            },
          );
        },
      );
    }

    final waitlist = eventDetails.waitlist;
    final pending = eventDetails.pendingRegistrations;
    final approved = eventDetails.approvedRegistrations;

    final myWaitlistIndex = currentUid != null && myRegistration?.status == RegistrationStatus.waitlisted
        ? waitlist.indexWhere((r) => r.userId == currentUid)
        : -1;
    final myWaitlistPosition = myWaitlistIndex >= 0 ? myWaitlistIndex + 1 : null;

    final String statusLabel = switch (myRegistration?.status) {
      null => 'Not registered',
      RegistrationStatus.approved => 'Approved',
      RegistrationStatus.pending => 'Pending approval',
      RegistrationStatus.waitlisted =>
        myWaitlistPosition != null ? 'On waitlist (#$myWaitlistPosition of ${waitlist.length})' : 'On waitlist',
      RegistrationStatus.rejected => 'Rejected',
      RegistrationStatus.attended => 'Attended',
      RegistrationStatus.absent => 'Absent',
      RegistrationStatus.withdrawn => 'Withdrawn',
    };

    final bool canRegister =
        currentUid != null &&
        !hasEnded &&
        (myRegistration == null || myRegistration.status == RegistrationStatus.withdrawn) &&
        (hasSpace || event.requiresApproval);

    // Registrations a leader/manager can act on: pending, waitlisted, approved.
    final manageable = [...approved, ...pending, ...waitlist];
    final participantIds = registrations.map((registration) => registration.userId).toSet().toList();
    final participantProfiles = useState<Map<String, UserProfile>>({});
    final areParticipantProfilesLoaded = useState(false);
    useEffect(() {
      if (participantIds.isEmpty) {
        areParticipantProfilesLoaded.value = true;
        return null;
      }
      var disposed = false;
      areParticipantProfilesLoaded.value = false;
      repository.getUserProfiles(participantIds).then((profiles) {
        if (!disposed) {
          participantProfiles.value = {...participantProfiles.value, ...profiles};
          areParticipantProfilesLoaded.value = true;
        }
      }).catchError((_) {
        if (!disposed) areParticipantProfilesLoaded.value = true;
      });
      return () => disposed = true;
    }, [participantIds.join(',')]);

    String formatRegisteredAt(DateTime dt) {
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} $hour:$minute';
    }

    Widget buildRegistrationRow(Registration registration, {int? waitlistPosition}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            if (waitlistPosition != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#$waitlistPosition',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!areParticipantProfilesLoaded.value)
                    const Text('…', style: TextStyle(fontSize: 14))
                  else
                    UserChip(
                      userId: registration.userId,
                      profile: participantProfiles.value[registration.userId],
                      profileResolved: true,
                      style: const TextStyle(fontSize: 14),
                    ),
                  Text(
                    'Registered ${formatRegisteredAt(registration.registeredAt)}',
                    style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
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
      );
    }

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
            ] else if (hasEnded &&
                (myRegistration == null || myRegistration.status == RegistrationStatus.withdrawn)) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.event_busy, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This event has already ended. Registration is closed.',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ] else if (myRegistration != null && myRegistration.status != RegistrationStatus.withdrawn) ...[
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
              if (approved.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(
                    'Approved participants (${approved.length})',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                for (final registration in approved)
                  buildRegistrationRow(registration),
              ],
              if (pending.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(
                    'Pending approval (${pending.length})',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                for (final registration in pending)
                  buildRegistrationRow(registration),
              ],
              if (waitlist.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(
                    'Waitlist (${waitlist.length})',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                for (var i = 0; i < waitlist.length; i++)
                  buildRegistrationRow(waitlist[i], waitlistPosition: i + 1),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AssignLeaderSheet
// ─────────────────────────────────────────────────────────────────────────────

/// Bottom-sheet picker for assigning a trip leader from the section's members.
///
/// Shows a [MemberSearchBar] at the top that filters the candidate list
/// client-side. Uses plain [UserDisplay] (no popover) so the hover card
/// doesn't interfere with tapping to assign.
class const _AssignLeaderSheet({required this.sectionId, required this.excludedIds, required this.onPick})
    extends HookWidget {
  final String sectionId;

  /// IDs of members who are already trip leaders (hidden from the list).
  final Set<String> excludedIds;

  /// Called with the selected user ID; the caller is responsible for closing
  /// the sheet before invoking this.
  final void Function(String userId) onPick;

  @override
  Widget build(BuildContext context) {
    final query = useState('');

    final membersFuture = useMemoized(() => repository.getSectionMembers(sectionId), [sectionId]);
    final snapshot = useFuture(membersFuture);

    // Batch-load profiles so the search filter can match on name/email.
    final profiles = useState<Map<String, UserProfile>>({});
    useEffect(() {
      if (snapshot.data == null) return null;
      final ids = snapshot.data!.map((m) => m.id).toList();
      repository.getUserProfiles(ids).then((loaded) {
        profiles.value = loaded;
      });
      return null;
    }, [snapshot.data]);

    final isLoading = snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData;
    final error = snapshot.error;
    final allCandidates = (snapshot.data ?? const <SectionMember>[]).where((m) => !excludedIds.contains(m.id)).toList();

    String displayFor(SectionMember m) => resolveUserDisplay(m.id, profiles.value[m.id]);

    final q = query.value.trim().toLowerCase();
    final filtered = q.isEmpty
        ? allCandidates
        : allCandidates.where((m) {
            final display = displayFor(m).toLowerCase();
            return display.contains(q) || m.id.toLowerCase().contains(q);
          }).toList();

    Widget body;
    if (isLoading) {
      body = const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (error != null) {
      body = Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: Text('Error loading members: $error')),
      );
    } else if (allCandidates.isEmpty) {
      body = const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('No other section members to assign.')),
      );
    } else if (filtered.isEmpty) {
      body = Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: Text('No members match "$q".')),
      );
    } else {
      body = Flexible(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final member = filtered[index];
            return ListTile(
              leading: const Icon(Icons.person_outline),
              // Plain text — no UserChip popover inside an action sheet.
              title: Text(displayFor(member), style: const TextStyle(fontSize: 14)),
              subtitle: Text(member.sectionRole.name),
              onTap: () => onPick(member.id),
            );
          },
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                'Assign Trip Leader',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: MemberSearchBar(hintText: 'Search members', onChanged: (value) => query.value = value),
            ),
            body,
          ],
        ),
      ),
    );
  }
}
