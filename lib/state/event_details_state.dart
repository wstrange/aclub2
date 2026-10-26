import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_models/shared_models.dart';

part 'event_details_state.freezed.dart';

/// Holds the loaded [Event] and its [Registration]s for the event details
/// screen, plus the loading/error states of the two backing stream
/// subscriptions ([EventDetailsCubit]).
@freezed
abstract class EventDetailsState with _$EventDetailsState {
  const factory EventDetailsState({
    required String sectionId,
    required String eventId,
    Event? event,
    @Default(<Registration>[]) List<Registration> registrations,
    @Default(true) bool isEventLoading,
    @Default(true) bool isRegistrationsLoading,
    Object? error,
  }) = _EventDetailsState;
}

/// Convenience extensions on [EventDetailsState] for filtered & sorted registrations.
extension EventDetailsStateX on EventDetailsState {
  /// Registrations on the waitlist, sorted by registration timestamp in
  /// ascending order (earliest registered first, for first-come, first-served).
  List<Registration> get waitlist =>
      registrations.where((r) => r.status == RegistrationStatus.waitlisted).toList()
        ..sort((a, b) => a.registeredAt.compareTo(b.registeredAt));

  /// Approved registrations, sorted by registration timestamp ascending.
  List<Registration> get approvedRegistrations =>
      registrations.where((r) => r.status == RegistrationStatus.approved).toList()
        ..sort((a, b) => a.registeredAt.compareTo(b.registeredAt));

  /// Pending registrations awaiting leader approval, sorted by registration timestamp ascending.
  List<Registration> get pendingRegistrations =>
      registrations.where((r) => r.status == RegistrationStatus.pending).toList()
        ..sort((a, b) => a.registeredAt.compareTo(b.registeredAt));
}
