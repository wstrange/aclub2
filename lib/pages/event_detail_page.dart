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
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} $hour:$minute';
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