import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kaisel/kaisel.dart';
import 'package:shared_models/shared_models.dart';

import '../repo.dart';
import '../routes.dart';
import '../widgets/user_display.dart';

/// Read-only page showing full details for an [Event].
/// Edit functionality is reached from here, not from the calendar.
class EventDetailPage extends HookWidget {
  const EventDetailPage({super.key, required this.sectionId, required this.eventId});

  final String sectionId;
  final String eventId;

  @override
  Widget build(BuildContext context) {
    final eventStream = useMemoized(
      () => repository.streamEvent(sectionId, eventId),
      [sectionId, eventId],
    );
    final snapshot = useStream(eventStream);

    if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (snapshot.hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Details')),
        body: Center(
          child: Text(
            'Error loading event: ${snapshot.error}',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }

    final event = snapshot.data;
    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Details')),
        body: const Center(child: Text('Event not found.')),
      );
    }

    Future<void> openEdit() async {
      await context.push(EventEditRoute(sectionId: sectionId, eventId: eventId));
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
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Event',
            onPressed: openEdit,
          ),
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
                if (event.difficulty != Difficulty.moderate)
                  Chip(label: Text(event.difficulty.name)),
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

            if (event.requiredEquipment.isNotEmpty) ...[
              _sectionHeader('Required Equipment'),
              _bulkList(event.requiredEquipment),
            ],

            if (event.prerequisites.isNotEmpty) ...[
              _sectionHeader('Prerequisites'),
              _bulkList(event.prerequisites),
            ],

            _sectionHeader('Leadership'),
            _LeadershipSection(creatorId: event.creatorId, leaderIds: event.tripLeaderIds),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: openEdit,
                icon: const Icon(Icons.edit),
                label: const Text('Edit Event'),
              ),
            ),
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
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _bulkList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 14)),
                Expanded(child: Text(item, style: const TextStyle(fontSize: 14))),
              ],
            ),
          ),
      ],
    );
  }
}

/// Resolves user IDs into display names and emails via their [UserProfile].
class _LeadershipSection extends StatelessWidget {
  const _LeadershipSection({required this.creatorId, required this.leaderIds});

  final String creatorId;
  final List<String> leaderIds;

  @override
  Widget build(BuildContext context) {
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
                child: UserDisplay(userId: creatorId, style: const TextStyle(fontSize: 14)),
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
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (var i = 0; i < leaderIds.length; i++) ...[
                      if (i > 0) const Text(', '),
                      UserDisplay(userId: leaderIds[i], style: const TextStyle(fontSize: 14)),
                    ],
                  ],
                ),
              ),
            ],
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
    final registrationsStream = useMemoized(
      () => repository.streamEventRegistrations(event.sectionId, event.id),
      [event.sectionId, event.id],
    );
    final registrationsSnapshot = useStream(registrationsStream);
    final registrations = registrationsSnapshot.data ?? const <Registration>[];

    final isSaving = useState(false);
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    final memberStream = useMemoized(
      () => repository.streamMember(event.sectionId, currentUid ?? ''),
      [event.sectionId, currentUid],
    );
    final memberSnapshot = useStream(memberStream);

    final myRegistration = currentUid == null ? null : registrations.where((r) => r.userId == currentUid).firstOrNull;

    final isSectionManager = memberSnapshot.data?.sectionRole == SectionRole.sectionManager;
    final isTripLeader = event.tripLeaderIds.contains(currentUid);
    final canManage = currentUid != null && (isSectionManager || isTripLeader);

    // Only approved registrations count towards the event's capacity.
    final approvedCount = registrations.where((r) => r.status == RegistrationStatus.approved).length;
    final hasSpace = approvedCount < event.maxParticipants;

    Future<void> setStatus(Registration registration, RegistrationStatus status) async {
      isSaving.value = true;
      try {
        await repository.updateRegistrationStatus(
          event.sectionId,
          event.id,
          registration.userId,
          status.name,
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update registration: $e')),
          );
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
        await repository.registerForEvent(event.sectionId, event.id, registration);
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
        .where((r) => r.status == RegistrationStatus.pending ||
            r.status == RegistrationStatus.waitlisted ||
            r.status == RegistrationStatus.approved)
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
            if (registrationsSnapshot.connectionState == ConnectionState.waiting)
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
            ],
            if (canManage && manageable.isNotEmpty) ...[
              const SizedBox(height: 16),
              Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
              const SizedBox(height: 12),
              Text(
                'Manage registrations',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
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
                          onPressed: isSaving.value ? null : () => setStatus(registration, RegistrationStatus.waitlisted),
                          child: const Text('To waitlist'),
                        )
                      else
                        TextButton(
                          onPressed: isSaving.value ? null : () => approve(registration),
                          child: const Text('Approve'),
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