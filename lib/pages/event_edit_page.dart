import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kaisel/kaisel.dart';
import 'package:shared_models/shared_models.dart';

import '../repo.dart';

/// Page for creating or editing an [Event] in a section.
class EventEditPage extends StatelessWidget {
  const EventEditPage({super.key, required this.sectionId, required this.eventId}) : isCreate = false;

  const EventEditPage.create({super.key, required this.sectionId}) : eventId = '', isCreate = true;

  final String sectionId;
  final String eventId;
  final bool isCreate;

  @override
  Widget build(BuildContext context) {
    if (isCreate) {
      final now = DateTime.now();
      final defaultEvent = Event(
        id: '',
        sectionId: sectionId,
        title: '',
        type: EventType.hike,
        difficulty: Difficulty.moderate,
        status: EventStatus.published,
        startDate: DateTime(now.year, now.month, now.day, 9, 0).add(const Duration(days: 1)),
        endDate: DateTime(now.year, now.month, now.day, 17, 0).add(const Duration(days: 1)),
        maxParticipants: 10,
        creatorId: FirebaseAuth.instance.currentUser?.uid ?? '',
        createdAt: now,
        updatedAt: now,
      );
      return _EventEditForm(sectionId: sectionId, initialEvent: defaultEvent, isCreate: true);
    }

    return FutureBuilder<Event?>(
      future: repository.getEvent(sectionId, eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Event')),
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
            appBar: AppBar(title: const Text('Edit Event')),
            body: const Center(child: Text('Event not found.')),
          );
        }

        return _EventEditForm(sectionId: sectionId, initialEvent: event, isCreate: false);
      },
    );
  }
}

class _EventEditForm extends HookWidget {
  const _EventEditForm({required this.sectionId, required this.initialEvent, this.isCreate = false});

  final String sectionId;
  final Event initialEvent;
  final bool isCreate;

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final titleController = useTextEditingController(text: initialEvent.title);
    final descriptionController = useTextEditingController(text: initialEvent.description ?? '');
    final type = useState(initialEvent.type);
    final difficulty = useState(initialEvent.difficulty);
    final status = useState(initialEvent.status);

    final startDate = useState(initialEvent.startDate);
    final endDate = useState(initialEvent.endDate);

    final minParticipantsController = useTextEditingController(
      text: initialEvent.minParticipants > 0 ? initialEvent.minParticipants.toString() : '0',
    );
    final maxParticipantsController = useTextEditingController(
      text: initialEvent.maxParticipants > 0 ? initialEvent.maxParticipants.toString() : '10',
    );
    final requiresApproval = useState(initialEvent.requiresApproval);

    final locationDescController = useTextEditingController(text: initialEvent.location?.description ?? '');
    final locationMapUrlController = useTextEditingController(text: initialEvent.location?.mapUrl ?? '');

    final hasCarpool = useState(initialEvent.carpoolOption != null);
    final carpoolTime = useState(initialEvent.carpoolOption?.meetTime ?? initialEvent.startDate);
    final carpoolPlaceController = useTextEditingController(text: initialEvent.carpoolOption?.meetPlace ?? '');
    final carpoolMapUrlController = useTextEditingController(text: initialEvent.carpoolOption?.mapUrl ?? '');

    final requiredEquipmentController = useTextEditingController(text: initialEvent.requiredEquipment.join(', '));
    final prerequisitesController = useTextEditingController(text: initialEvent.prerequisites.join(', '));

    final isSaving = useState(false);
    final errorMessage = useState<String?>(null);

    Future<void> pickDateTime({
      required BuildContext context,
      required DateTime initial,
      required ValueChanged<DateTime> onPicked,
    }) async {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(2020),
        lastDate: DateTime(2035),
      );
      if (pickedDate == null || !context.mounted) return;

      final pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
      if (pickedTime == null) return;

      onPicked(DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute));
    }

    String formatDateTime(DateTime dt) {
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final weekday = weekdays[dt.weekday - 1];
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$weekday ${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} $hour:$minute';
    }

    List<String> parseList(String input) {
      return input.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }

    Future<void> save() async {
      final title = titleController.text.trim();
      final description = descriptionController.text.trim();

      if (title.isEmpty || description.isEmpty) {
        errorMessage.value = 'Title and description cannot be empty.';
        return;
      }
      if (!endDate.value.isAfter(startDate.value)) {
        errorMessage.value = 'End date must be after start date.';
        return;
      }

      if (!(formKey.currentState?.validate() ?? false)) return;

      errorMessage.value = null;
      isSaving.value = true;

      try {
        final minPart = int.tryParse(minParticipantsController.text.trim()) ?? 0;
        final maxPart = int.tryParse(maxParticipantsController.text.trim()) ?? 10;

        EventLocation? location;
        if (locationDescController.text.trim().isNotEmpty || locationMapUrlController.text.trim().isNotEmpty) {
          location = EventLocation(
            description: locationDescController.text.trim().isEmpty ? null : locationDescController.text.trim(),
            mapUrl: locationMapUrlController.text.trim().isEmpty ? null : locationMapUrlController.text.trim(),
          );
        }

        CarpoolOption? carpool;
        if (hasCarpool.value && carpoolPlaceController.text.trim().isNotEmpty) {
          carpool = CarpoolOption(
            meetTime: carpoolTime.value,
            meetPlace: carpoolPlaceController.text.trim(),
            mapUrl: carpoolMapUrlController.text.trim().isEmpty ? null : carpoolMapUrlController.text.trim(),
          );
        }

        if (isCreate) {
          final newEvent = initialEvent.copyWith(
            title: title,
            description: description.isEmpty ? null : description,
            type: type.value,
            difficulty: difficulty.value,
            status: status.value,
            startDate: startDate.value,
            endDate: endDate.value,
            minParticipants: minPart,
            maxParticipants: maxPart,
            requiresApproval: requiresApproval.value,
            location: location,
            carpoolOption: carpool,
            requiredEquipment: parseList(requiredEquipmentController.text),
            prerequisites: parseList(prerequisitesController.text),
            creatorId: FirebaseAuth.instance.currentUser?.uid ?? initialEvent.creatorId,
            tripLeaderIds: [FirebaseAuth.instance.currentUser?.uid ?? initialEvent.creatorId],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await repository.createEvent(sectionId, newEvent);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event created successfully.')));
            context.pop();
          }
        } else {
          final updatedEvent = initialEvent.copyWith(
            title: title,
            description: description.isEmpty ? null : description,
            type: type.value,
            difficulty: difficulty.value,
            status: status.value,
            startDate: startDate.value,
            endDate: endDate.value,
            minParticipants: minPart,
            maxParticipants: maxPart,
            requiresApproval: requiresApproval.value,
            location: location,
            carpoolOption: carpool,
            requiredEquipment: parseList(requiredEquipmentController.text),
            prerequisites: parseList(prerequisitesController.text),
            updatedAt: DateTime.now(),
          );

          await repository.updateEvent(sectionId, updatedEvent);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event updated successfully.')));
            context.pop();
          }
        }
      } catch (e) {
        if (context.mounted) {
          errorMessage.value = isCreate ? 'Failed to create event: $e' : 'Failed to update event: $e';
        }
      } finally {
        isSaving.value = false;
      }
    }

    Future<void> delete() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Event'),
          content: Text('Are you sure you want to delete "${initialEvent.title}"? This cannot be undone.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Theme.of(ctx).colorScheme.error),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed != true || !context.mounted) return;

      isSaving.value = true;
      try {
        await repository.deleteEvent(sectionId, initialEvent.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event deleted.')));
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          errorMessage.value = 'Failed to delete event: $e';
        }
      } finally {
        isSaving.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isCreate ? 'Create Event' : 'Edit Event'),
        actions: [
          if (!isCreate)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete Event',
              onPressed: isSaving.value ? null : delete,
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (errorMessage.value != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    errorMessage.value!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
                  ),
                ),

              _sectionHeader('Basic Information'),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Event Title *', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<EventType>(
                      initialValue: type.value,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                      items: EventType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                      onChanged: (val) {
                        if (val != null) type.value = val;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<Difficulty>(
                      initialValue: difficulty.value,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Difficulty', border: OutlineInputBorder()),
                      items: Difficulty.values.map((d) => DropdownMenuItem(value: d, child: Text(d.name))).toList(),
                      onChanged: (val) {
                        if (val != null) difficulty.value = val;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<EventStatus>(
                      initialValue: status.value,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                      items: EventStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                      onChanged: (val) {
                        if (val != null) status.value = val;
                      },
                    ),
                  ),
                ],
              ),

              _sectionHeader('Schedule'),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('Start'),
                      subtitle: Text(
                        formatDateTime(startDate.value),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => pickDateTime(
                        context: context,
                        initial: startDate.value,
                        onPicked: (dt) {
                          startDate.value = dt;
                          if (endDate.value.isBefore(dt)) {
                            endDate.value = dt.add(const Duration(hours: 2));
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FormField<DateTime>(
                      initialValue: endDate.value,
                      validator: (value) {
                        if (value == null || !value.isAfter(startDate.value)) {
                          return 'End must be after start';
                        }
                        return null;
                      },
                      builder: (field) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              title: const Text('End'),
                              subtitle: Text(
                                formatDateTime(endDate.value),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(Icons.calendar_today),
                              onTap: () => pickDateTime(
                                context: context,
                                initial: endDate.value,
                                onPicked: (dt) {
                                  endDate.value = dt;
                                  field.didChange(dt);
                                },
                              ),
                            ),
                            if (field.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  field.errorText!,
                                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.error),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),

              _sectionHeader('Capacity & Registration'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: minParticipantsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Min Participants', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: maxParticipantsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Max Participants *', border: OutlineInputBorder()),
                      validator: (value) {
                        final parsed = int.tryParse(value ?? '');
                        if (parsed == null || parsed < 1) {
                          return 'Enter a valid number (>= 1)';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Requires Approval'),
                subtitle: const Text('Registrations go to waitlist until leader approves'),
                value: requiresApproval.value,
                onChanged: (val) => requiresApproval.value = val,
              ),

              _sectionHeader('Location'),
              TextFormField(
                controller: locationDescController,
                decoration: const InputDecoration(
                  labelText: 'Location Description',
                  hintText: 'e.g. Canmore Nordic Centre, Trailhead parking',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: locationMapUrlController,
                decoration: const InputDecoration(
                  labelText: 'Map URL',
                  hintText: 'e.g. https://maps.google.com/?q=...',
                  border: OutlineInputBorder(),
                ),
              ),

              _sectionHeader('Carpooling'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Offer Carpooling'),
                value: hasCarpool.value,
                onChanged: (val) => hasCarpool.value = val,
              ),
              if (hasCarpool.value) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Carpool Meet Time'),
                  subtitle: Text(formatDateTime(carpoolTime.value)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => pickDateTime(
                    context: context,
                    initial: carpoolTime.value,
                    onPicked: (dt) => carpoolTime.value = dt,
                  ),
                ),
                TextFormField(
                  controller: carpoolPlaceController,
                  decoration: const InputDecoration(
                    labelText: 'Carpool Meeting Place',
                    hintText: 'e.g. Shouldice Park & Ride, Calgary',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: carpoolMapUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Carpool Map URL',
                    hintText: 'e.g. https://maps.app.goo.gl/...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],

              _sectionHeader('Requirements & Prerequisites'),
              TextFormField(
                controller: requiredEquipmentController,
                decoration: const InputDecoration(
                  labelText: 'Required Equipment (comma-separated)',
                  hintText: 'Helmet, Harness, Crampons, Ice Axe',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: prerequisitesController,
                decoration: const InputDecoration(
                  labelText: 'Prerequisites (comma-separated)',
                  hintText: 'AST 1, Prior scrambling experience',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isSaving.value ? null : save,
                  child: isSaving.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(isCreate ? 'Create Event' : 'Save Changes', style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
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
}
