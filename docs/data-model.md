# Data model

This document describes the Firestore schema **as implemented** in
`packages/shared_models`. The models are the source of truth; if this document
and the code disagree, the code wins.

- Models: `packages/shared_models/lib/*.dart`
- Serialization: `json_serializable` with `freezed`; timestamps use
  `TimestampConverter` and are stored as Firestore `Timestamp`s.
- Document IDs are always the Firestore document ID. User IDs match the
  Firebase Auth UID.

## Collection hierarchy

```
/users/{userId}
/sections/{sectionId}
/sections/{sectionId}/members/{userId}
/sections/{sectionId}/events/{eventId}
/sections/{sectionId}/events/{eventId}/registrations/{registrationId}
/notifications/{notificationId}
/templates/{templateId}
```

There is also a **collection group** query on `registrations` so a signed-in
user can list their own registrations across events.

## Relationships

- A **member** is a Firebase Auth user with a `/users/{userId}` profile.
- A member joins one or more **sections** through
  `/sections/{sectionId}/members/{userId}`. Section membership is *not* stored
  on the user profile.
- **Events** belong to a section and are stored in that section's subcollection.
- **Registrations** belong to an event and are stored in the event's
  subcollection.
- **Notifications** are per-recipient documents at the top level.
- **Templates** are global, admin-managed markdown snippets.

---

## `/users/{userId}`

Profile and preferences beyond what Firebase Auth provides.

| Field | Type | Required | Default | Notes |
|---|---|:---:|---|---|
| `id` | `String` | ✓ | | Firebase Auth UID; same as document ID |
| `firstName` | `String` | ✓ | | |
| `lastName` | `String` | ✓ | | |
| `email` | `String?` | | | Denormalized from Auth for display |
| `photoUrl` | `String?` | | | Avatar URL |
| `phone` | `String?` | | | |
| `emergencyContactName` | `String` | ✓ | | Enforced as mandatory by the profile form |
| `emergencyContactPhone` | `String` | ✓ | | |
| `emergencyContactRelation` | `String?` | | | e.g. "Spouse", "Parent" |
| `medicalConditions` | `String?` | | | Sensitive; see the PII limitation in `docs/security.md` |
| `certifications` | `String[]` | | `[]` | Free text, e.g. `["First Aid", "AST 2"]` |
| `defaultSectionId` | `String?` | | | Section to select on next login |
| `complatedProfile` | `Boolean` | | `false` | **Legacy misspelling**, kept for schema compatibility. The router guard uses it to decide whether to send the user to the profile page |
| `waiverSignedDate` | `Timestamp?` | | `null` | Last waiver signature. `null` = never; re-sign required after 365 days |
| `fcmTokens` | `String[]` | | `[]` | Device tokens registered by `FcmService` |
| `notificationPreferences` | `Map` | ✓ | | See below |
| `createdAt` | `Timestamp` | ✓ | | |
| `updatedAt` | `Timestamp` | ✓ | | |

There is **no `role` or `isAdmin` field** on the profile. Global admin status is
a Firebase Auth custom claim; per-section roles live on `SectionMember`.

### Embedded `notificationPreferences`

| Field | Type | Default | Notes |
|---|---|---|---|
| `pushEnabled` | `Boolean` | `true` | FCM push |
| `emailEnabled` | `Boolean` | `true` | Reserved; email delivery is not implemented yet |
| `inAppEnabled` | `Boolean` | `true` | `/notifications` feed |
| `notifyForNewEvents` | `Boolean` | `false` | Subscribe to the section's new-event topic |
| `frequency` | `String` | `immediate` | `immediate` \| `daily` \| `weekly`; reserved, batching is not implemented |

---

## `/sections/{sectionId}`

| Field | Type | Required | Notes |
|---|---|:---:|---|
| `id` | `String` | ✓ | Firestore document ID |
| `name` | `String` | ✓ | |
| `description` | `String?` | | |
| `location` | `String?` | | Region or city, e.g. "Vancouver, BC" |
| `contactEmail` | `String?` | | |
| `contactPhone` | `String?` | | |
| `createdAt` | `Timestamp?` | | |
| `updatedAt` | `Timestamp?` | | |

Section managers are **not** listed here. They are members whose
`sectionRole` is `sectionManager` in the `members` subcollection.

---

## `/sections/{sectionId}/members/{userId}`

Join record linking a user to a section. The document ID is the user's UID.

| Field | Type | Required | Notes |
|---|---|:---:|---|
| `id` | `String` | ✓ | User UID; same as document ID |
| `sectionId` | `String` | ✓ | Parent section ID |
| `sectionRole` | `String` (enum) | ✓ | `sectionManager` \| `tripLeader` \| `member` |
| `externalSystemId` | `String?` | | Optional ID from an external membership system |
| `joinedAt` | `Timestamp` | ✓ | |

Write rules (see `docs/security.md`):

- section managers and global admins can create/update/delete any membership;
- a user may self-join an existing section **only** as `member`, with this exact
  field shape;
- a user may delete only their own membership.

---

## `/sections/{sectionId}/events/{eventId}`

| Field | Type | Required | Default | Notes |
|---|---|:---:|---|---|
| `id` | `String` | ✓ | | Firestore document ID |
| `sectionId` | `String` | ✓ | | Denormalized for queries |
| `title` | `String` | ✓ | | |
| `description` | `String?` | | | Markdown; templates can be inserted here |
| `type` | `String` (enum) | ✓ | | `rock` \| `trailRun` \| `hike` \| `climb` \| `alpineSki` \| `skiMountaineering` \| `snowshoe` \| `social` \| `presentation` |
| `status` | `String` (enum) | | `draft` | `draft` \| `published` |
| `startDate` | `Timestamp` | ✓ | | Events may span multiple days |
| `endDate` | `Timestamp` | ✓ | | |
| `location` | `Map?` | | | See below |
| `carpoolOption` | `Map?` | | | See below; `null` when carpooling is not offered |
| `minParticipants` | `Number` | | `0` | |
| `maxParticipants` | `Number` | ✓ | | Capacity is enforced by the UI, not by rules |
| `difficulty` | `String` (enum) | | `moderate` | `easy` \| `moderate` \| `hard` |
| `requiresApproval` | `Boolean` | | `false` | `true` = registrations start `pending`/`waitlisted` |
| `creatorId` | `String` | ✓ | | User ID of the creator |
| `tripLeaderIds` | `String[]` | | `[]` | Members leading the event |
| `createdAt` | `Timestamp` | ✓ | | |
| `updatedAt` | `Timestamp` | ✓ | | |

New events are created as `draft`. The default event list shows only
`published` events; the creator and listed trip leaders also see their drafts.

> There is no `visibility` field and no `requiredEquipment` / `prerequisites`
> field. Reusable content such as equipment lists belongs in a markdown
> template inserted into `description`.

### Embedded `location`

| Field | Type | Notes |
|---|---|---|
| `description` | `String?` | e.g. "Meet at the base of the north face" |
| `latitude` | `Number?` | GPS decimal degrees |
| `longitude` | `Number?` | GPS decimal degrees |
| `mapUrl` | `String?` | HTTP link to a map (Google Maps, CalTopo, …) |

At least one of `description`, GPS (`latitude` + `longitude`), or `mapUrl`
should be set. This is a UI convention, not a rule.

### Embedded `carpoolOption`

| Field | Type | Required | Notes |
|---|---|:---:|---|
| `meetTime` | `Timestamp` | ✓ | Date and time to meet |
| `meetPlace` | `String` | ✓ | e.g. "Park & Ride on Hwy 1" |
| `mapUrl` | `String?` | | Optional map of the meeting point |

Individual driving preference is stored on the registration
(`isDriver` / `needsRide`).

---

## `/sections/{sectionId}/events/{eventId}/registrations/{registrationId}`

The registration document ID is the registering user's UID. This enforces at
most one registration per member per event.

| Field | Type | Required | Default | Notes |
|---|---|:---:|---|---|
| `id` | `String` | ✓ | | Firestore document ID; equals `userId` |
| `userId` | `String` | ✓ | | Registering member's UID |
| `guestName` | `String?` | | | Set when a member registers a guest |
| `status` | `String` (enum) | | `pending` | `pending` \| `approved` \| `waitlisted` \| `rejected` \| `attended` \| `absent` \| `withdrawn` |
| `isDriver` | `Boolean?` | | | Carpool: willing to drive |
| `needsRide` | `Boolean?` | | | Carpool: needs a ride |
| `registeredAt` | `Timestamp` | ✓ | | Initial registration time |
| `updatedAt` | `Timestamp` | ✓ | | |
| `withdrawnByUserId` | `String?` | | | Set on soft delete (self or leader) |
| `withdrawnAt` | `Timestamp?` | | | Set on soft delete |

Initial status is derived from the event: an event with
`requiresApproval == true` allows `pending` or `waitlisted`; otherwise the
registration starts `approved`. See `docs/event-registration.md` for the full
lifecycle.

---

## `/notifications/{notificationId}`

| Field | Type | Required | Default | Notes |
|---|---|:---:|---|---|
| `id` | `String` | ✓ | | Firestore document ID |
| `recipientId` | `String` | ✓ | | Recipient's UID |
| `title` | `String` | ✓ | | |
| `message` | `String` | ✓ | | |
| `link` | `String?` | | | In-app route, e.g. `/events/abc123` |
| `channels` | `String[]` | | `[]` | `push` \| `email` \| `inApp` |
| `isRead` | `Boolean` | | `false` | |
| `relatedEventId` | `String?` | | | |
| `relatedSectionId` | `String?` | | | |
| `createdAt` | `Timestamp` | ✓ | | |

`channels` is stored as strings because the ODM builder does not support
`List<Enum>`.

---

## `/templates/{templateId}`

Admin-managed markdown templates. Only global admins can write them.

| Field | Type | Required | Notes |
|---|---|:---:|---|
| `id` | `String` | ✓ | Firestore document ID |
| `language` | `String` | ✓ | `en` or `fr` |
| `title` | `String` | ✓ | Admin-visible name |
| `markdownText` | `String` | ✓ | Full markdown body |
| `createdBy` | `String` | ✓ | UID of the admin who created it |
| `createdAt` | `Timestamp` | ✓ | |
| `updatedAt` | `Timestamp` | ✓ | |

---

## Enums

Defined in `packages/shared_models/lib/enums.dart` and serialized by name.

| Enum | Values |
|---|---|
| `UserRole` | `admin`, `member` |
| `SectionRole` | `sectionManager`, `tripLeader`, `member` |
| `EventType` | `rock`, `trailRun`, `hike`, `climb`, `alpineSki`, `skiMountaineering`, `snowshoe`, `social`, `presentation` |
| `EventStatus` | `draft`, `published` |
| `Difficulty` | `easy`, `moderate`, `hard` |
| `RegistrationStatus` | `pending`, `approved`, `waitlisted`, `rejected`, `attended`, `absent`, `withdrawn` |
| `NotificationChannel` | `push`, `email`, `inApp` |
| `NotificationFrequency` | `immediate`, `daily`, `weekly` |

`UserRole` only distinguishes global admins. Everything else is a
`SectionRole`, scoped to one section.

---

## Timestamps

All timestamp fields use `TimestampConverter` (`packages/shared_models/lib/firestore_converter.dart`)
and are stored as Firestore `Timestamp` values. `NullableTimestampConverter`
is used for optional timestamps such as `waiverSignedDate` and `withdrawnAt`.
