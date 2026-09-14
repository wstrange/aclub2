import 'dart:async';

import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:shared_models/shared_models.dart';

import 'event_details_state.dart';
import '../repo.dart';

/// Manages the loaded [Event] and its [Registration]s for the event details
/// screen. Subscribes to the Firestore streams for [sectionId]/[eventId] on
/// creation and cancels them on [close]; the owning widget must create and
/// dispose it (one per event details screen).
class EventDetailsCubit extends CubitSignal<EventDetailsState> {
  EventDetailsCubit({required this.sectionId, required this.eventId})
      : super(initialState: EventDetailsState(sectionId: sectionId, eventId: eventId)) {
    _subscribe();
  }

  final String sectionId;
  final String eventId;

  late final StreamSubscription<Event?> _eventSub;
  late final StreamSubscription<List<Registration>> _registrationsSub;

  void _subscribe() {
    _eventSub = repository.streamEvent(sectionId, eventId).listen(
      (event) => emit(state.value.copyWith(event: event, isEventLoading: false, error: null)),
      onError: (Object e, StackTrace st) => emit(state.value.copyWith(isEventLoading: false, error: e)),
    );
    _registrationsSub = repository.streamEventRegistrations(sectionId, eventId).listen(
      (registrations) => emit(state.value.copyWith(registrations: registrations, isRegistrationsLoading: false)),
      onError: (Object e, StackTrace st) => emit(state.value.copyWith(error: e)),
    );
  }

  @override
  Future<void> close() async {
    await _eventSub.cancel();
    await _registrationsSub.cancel();
    await super.close();
  }

  /// Registers [registration] for this event. The registrations stream
  /// reflects the write automatically.
  Future<void> register(Registration registration) async {
    await repository.registerForEvent(sectionId, eventId, registration);
  }

  /// Sets a new [status] on an existing [Registration].
  Future<void> setRegistrationStatus(Registration registration, RegistrationStatus status) async {
    await repository.updateRegistrationStatus(sectionId, eventId, registration.userId, status.name);
  }

  /// Adds [userId] to this event as an [approved]/waitlisted registrant.
  Future<void> addParticipant(String userId, RegistrationStatus status) async {
    final now = DateTime.now();
    await repository.registerForEvent(
      sectionId,
      eventId,
      Registration(id: userId, userId: userId, status: status, registeredAt: now, updatedAt: now),
    );
  }

  /// Removes [userId] from this event's registrations.
  Future<void> removeRegistration(String userId) async {
    await repository.removeRegistration(sectionId, eventId, userId);
  }

  /// Adds [userId] to the event's trip leader list.
  Future<void> assignTripLeader(String userId) async {
    final event = state.value.event;
    if (event == null || event.tripLeaderIds.contains(userId)) return;
    await repository.updateEvent(
      sectionId,
      event.copyWith(tripLeaderIds: [...event.tripLeaderIds, userId], updatedAt: DateTime.now()),
    );
  }

  /// Removes [userId] from the event's trip leader list.
  Future<void> removeTripLeader(String userId) async {
    final event = state.value.event;
    if (event == null) return;
    await repository.updateEvent(
      sectionId,
      event.copyWith(
        tripLeaderIds: event.tripLeaderIds.where((id) => id != userId).toList(),
        updatedAt: DateTime.now(),
      ),
    );
  }
}