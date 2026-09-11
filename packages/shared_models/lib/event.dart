import 'package:firestore_odm/firestore_odm.dart';
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
@firestoreOdm
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
    EventLocation? location,
    CarpoolOption? carpoolOption,

    // ── Capacity ──────────────────────────────────────────────────────────
    @Default(0) int minParticipants,
    required int maxParticipants,

    // ── Classification ────────────────────────────────────────────────────
    @Default(Difficulty.moderate) Difficulty difficulty,

    /// When true, registrations go to a waitlist and require approval from a
    /// trip leader or section manager before being confirmed.
    @Default(false) bool requiresApproval,

    // ── Requirements ─────────────────────────────────────────────────────
    /// List of required equipment items (free text or markdown).
    @Default([]) List<String> requiredEquipment,

    /// List of prerequisites for participation (free text or markdown).
    @Default([]) List<String> prerequisites,

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
