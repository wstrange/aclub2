import 'package:aclub2/state/event_details_state.dart';
import 'package:aclub2/state/registration_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_models/shared_models.dart';

Event _event({
  int maxParticipants = 2,
  bool requiresApproval = false,
  DateTime? endDate,
}) {
  final now = DateTime(2026, 10, 1, 9);
  return Event(
    id: 'evt-1',
    sectionId: 'sec-1',
    title: 'Test event',
    type: EventType.hike,
    status: EventStatus.published,
    startDate: now,
    endDate: endDate ?? DateTime(2026, 10, 2, 17),
    maxParticipants: maxParticipants,
    requiresApproval: requiresApproval,
    creatorId: 'leader',
    createdAt: now,
    updatedAt: now,
  );
}

Registration _registration(String userId, RegistrationStatus status, {DateTime? at}) {
  final timestamp = at ?? DateTime(2026, 9, 1);
  return Registration(id: userId, userId: userId, status: status, registeredAt: timestamp, updatedAt: timestamp);
}

RegistrationView _view({
  required Event event,
  required List<Registration> registrations,
  String? currentUid = 'me',
  DateTime? now,
}) {
  return RegistrationView.from(
    event: event,
    details: EventDetailsState(
      sectionId: event.sectionId,
      eventId: event.id,
      event: event,
      registrations: registrations,
      isEventLoading: false,
      isRegistrationsLoading: false,
    ),
    currentUid: currentUid,
    now: now ?? DateTime(2026, 10, 1, 12),
  );
}

void main() {
  group('RegistrationView capacity', () {
    test('counts only approved registrations against capacity', () {
      final view = _view(
        event: _event(maxParticipants: 2),
        registrations: [
          _registration('a', RegistrationStatus.approved),
          _registration('b', RegistrationStatus.pending),
          _registration('c', RegistrationStatus.waitlisted),
        ],
      );

      expect(view.approvedCount, 1);
      expect(view.hasSpace, isTrue);
    });

    test('a full event without approval cannot be registered for', () {
      final view = _view(
        event: _event(maxParticipants: 1),
        registrations: [
          _registration('a', RegistrationStatus.approved),
          _registration('me', RegistrationStatus.withdrawn),
        ],
      );

      expect(view.hasSpace, isFalse);
      expect(view.canRegister, isFalse);
    });

    test('a full approval-required event can still join the waitlist', () {
      final view = _view(
        event: _event(maxParticipants: 1, requiresApproval: true),
        registrations: [_registration('a', RegistrationStatus.approved)],
      );

      expect(view.hasSpace, isFalse);
      expect(view.canRegister, isTrue);
    });

    test('an ended event cannot be registered for', () {
      final view = _view(
        event: _event(endDate: DateTime(2026, 9, 30, 17)),
        registrations: const [],
      );

      expect(view.hasEnded, isTrue);
      expect(view.canRegister, isFalse);
    });

    test('a withdrawn member can register again', () {
      final view = _view(
        event: _event(),
        registrations: [_registration('me', RegistrationStatus.withdrawn)],
      );

      expect(view.canRegister, isTrue);
      expect(view.statusLabel, 'Withdrawn');
    });

    test('signed-out users cannot register', () {
      final view = _view(event: _event(), registrations: const [], currentUid: null);

      expect(view.canRegister, isFalse);
      expect(view.statusLabel, 'Not registered');
    });
  });

  group('RegistrationView waitlist', () {
    test('reports the 1-based waitlist position in the status label', () {
      final view = _view(
        event: _event(requiresApproval: true),
        registrations: [
          _registration('first', RegistrationStatus.waitlisted, at: DateTime(2026, 9, 1)),
          _registration('me', RegistrationStatus.waitlisted, at: DateTime(2026, 9, 2)),
        ],
      );

      expect(view.myWaitlistPosition, 2);
      expect(view.statusLabel, 'On waitlist (#2 of 2)');
    });

    test('waitlist and manageable lists are sorted by registration time', () {
      final view = _view(
        event: _event(),
        registrations: [
          _registration('late', RegistrationStatus.waitlisted, at: DateTime(2026, 9, 3)),
          _registration('early', RegistrationStatus.waitlisted, at: DateTime(2026, 9, 1)),
          _registration('approved', RegistrationStatus.approved),
          _registration('pending', RegistrationStatus.pending),
        ],
      );

      expect(view.waitlist.map((r) => r.userId), ['early', 'late']);
      expect(view.manageable.map((r) => r.userId), containsAll(['approved', 'pending', 'early', 'late']));
    });
  });
}
