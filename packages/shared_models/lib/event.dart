import 'package:freezed_annotation/freezed_annotation.dart';


import 'carpool_option.dart';
import 'enums.dart';
import 'event_location.dart';
import 'firestore_converter.dart';

part 'event.freezed.dart';
part 'event.g.dart';

/// Firestore path: `/sections/{sectionId}/events/{eventId}`
///
/// Events are always owned by a section and can span multiple days.
/// New events are created as [EventStatus.draft] and must be explicitly
/// published before they appear in public listings.
@freezed
abstract class Event with _$Event {
  const factory Event({
    /// Firestore document ID.
    required String id,

    /// Denormalised section ID for cross-collection queries.
    required String sectionId,

    required String title,

    /// Markdown-formatted description. A template can be inserted here.
    String? description,

    required EventType type,

    /// Events start as [EventStatus.draft]. Only published events appear in
    /// public listings; draft events are visible only to the creator and trip
    /// leaders.
    @Default(EventStatus.draft) EventStatus status,

    // ── Schedule ──────────────────────────────────────────────────────────
    @TimestampConverter() required DateTime startDate,
    @TimestampConverter() required DateTime endDate,

    // ── Location & Carpool ────────────────────────────────────────────────
    @JsonKey(toJson: _eventLocationToJson, fromJson: _eventLocationFromJson)
    EventLocation? location,
    @JsonKey(toJson: _carpoolOptionToJson, fromJson: _carpoolOptionFromJson)
    CarpoolOption? carpoolOption,

    // ── Capacity ──────────────────────────────────────────────────────────
    @Default(0) int minParticipants,
    required int maxParticipants,

    // ── Classification ────────────────────────────────────────────────────
    @Default(Difficulty.moderate) Difficulty difficulty,

    /// When true, registrations go to a waitlist and require approval from a
    /// trip leader or section manager before being confirmed.
    @Default(false) bool requiresApproval,

    // ── Ownership ─────────────────────────────────────────────────────────
    required String creatorId,

    /// User IDs of members leading this event. Trip leaders can update event
    /// details and communicate with participants.
    @Default([]) List<String> tripLeaderIds,

    // ── Timestamps ────────────────────────────────────────────────────────
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}

/// Builds a new [Event] duplicating another for creating a copy.
///
/// * [id] is cleared so the copy gets a fresh (auto-generated) document ID.
/// * The title is prefixed with `COPY: ` so the user knows to edit it.
/// * If the original event's dates are in the past (before [now]), they are
///   advanced to the current date(s) while preserving the original times,
///   duration, and a carpool meet time (if any, shifted by the same amount).
/// * [creatorId] becomes the owner; trip leaders are carried over only when
///   [copyParticipantsAndLeaders] is true (otherwise the copy is owned by
///   [creatorId] alone).
extension EventCopy on Event {
  Event copyForDuplicate({
    required DateTime now,
    required bool copyParticipantsAndLeaders,
    required String creatorId,
  }) {
    final duration = endDate.difference(startDate);

    var newStart = startDate;
    var newEnd = endDate;
    if (!startDate.isAfter(now)) {
      final candidate = DateTime(now.year, now.month, now.day, startDate.hour, startDate.minute);
      newStart = candidate.isAfter(now) ? candidate : candidate.add(const Duration(days: 1));
      newEnd = newStart.add(duration);
    }
    final dateShift = newStart.difference(startDate);

    return copyWith(
      id: '',
      title: 'COPY: $title',
      startDate: newStart,
      endDate: newEnd,
      creatorId: creatorId,
      tripLeaderIds: copyParticipantsAndLeaders ? tripLeaderIds : [creatorId],
      carpoolOption: carpoolOption == null
          ? null
          : carpoolOption!.copyWith(meetTime: carpoolOption!.meetTime.add(dateShift)),
      createdAt: now,
      updatedAt: now,
    );
  }
}

Map<String, dynamic>? _eventLocationToJson(EventLocation? value) => value?.toJson();
EventLocation? _eventLocationFromJson(Object? json) =>
    json is Map<String, dynamic> ? EventLocation.fromJson(json) : null;
Map<String, dynamic>? _carpoolOptionToJson(CarpoolOption? value) => value?.toJson();
CarpoolOption? _carpoolOptionFromJson(Object? json) =>
    json is Map<String, dynamic> ? CarpoolOption.fromJson(json) : null;
