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