/// Shared enums for the aclub2 data model.
/// These are serialised by name (e.g. UserRole.admin → "admin") by
/// json_serializable, which matches Firestore storage convention.
library;

/// Global application roles.
/// Only admins have a global role. All other roles are per-section and are
/// stored on the [SectionMember] document for each section a user belongs to.
enum UserRole { admin, member }

/// Role a user holds within a specific section.
/// A user can hold different roles in different sections — for example, a
/// TripLeader in Calgary but a regular Member in Edmonton.
enum SectionRole { sectionManager, tripLeader, member }

/// The category / activity type of an event.
enum EventType { rock, trailRun, hike, climb, alpineSki, skiMountaineering, snowshoe, social, presentation }

/// Lifecycle state of an event.
enum EventStatus { draft, published }

/// Difficulty rating to help members choose appropriate activities.
enum Difficulty { easy, moderate, hard }

/// A member's registration state for an event.
enum RegistrationStatus { pending, approved, waitlisted, rejected, attended, absent }

/// Delivery channels for a notification.
enum NotificationChannel { push, email, inApp }

/// How often a member wants to receive notifications.
enum NotificationFrequency { immediate, daily, weekly }
