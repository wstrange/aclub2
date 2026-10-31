# Event registration lifecycle

Registrations live at
`/sections/{sectionId}/events/{eventId}/registrations/{registrationId}`. The
document ID is the registering member's UID, so a member can hold at most one
registration per event.

The model is `Registration` in `packages/shared_models/lib/registration.dart`;
the write rules are in `firestore.rules`; the notification side effects are in
`functions/lib/src/registration_handlers.dart`.

## States

| Status | Meaning |
|---|---|
| `pending` | Requested a place on an approval-required event; waiting for a leader |
| `approved` | Confirmed participant |
| `waitlisted` | On the waitlist (capacity reached or leader moved them) |
| `rejected` | Request declined |
| `attended` | Leader marked the member as having attended |
| `absent` | Leader marked the member as not having attended |
| `withdrawn` | Soft-deleted: withdrew or was removed; the document is retained |

## Creating a registration

A member registers themselves with:

```dart
repository.registerForEvent(sectionId, eventId, registration)
// writes registrations/{uid}
```

Initial status depends on the event:

| Event | Initial status |
|---|---|
| `requiresApproval == false` | `approved` |
| `requiresApproval == true`, capacity available | `pending` |
| `requiresApproval == true`, capacity reached | `waitlisted` |

Rules enforce:

- the document ID must equal `userId` (no arbitrary IDs, no duplicates);
- a member may register only themselves; leaders may register another member;
- the initial status must be `approved` for direct events, or
  `pending`/`waitlisted` for approval-required events.

## Updating a registration

Members may:

- edit non-status fields (`guestName`, `isDriver`, `needsRide`, `updatedAt`);
- withdraw an active registration (`pending`/`waitlisted`/`approved` →
  `withdrawn`) with `withdrawnByUserId == their UID`;
- re-register after a withdrawal.

Members may **not** set `approved`, `attended`, `absent`, or `rejected`
themselves. Trip leaders and section managers may update any registration in
their section.

Capacity (`maxParticipants`) is a client-side check; rules cannot count
documents. See `docs/security.md`.

## Withdrawal vs. hard delete

The application uses **soft delete** for normal withdrawal and leader removal:

- `status` becomes `withdrawn`;
- `withdrawnByUserId` records who performed the action;
- `withdrawnAt` and `updatedAt` are stamped;
- the document is retained.

This preserves an audit trail (who registered, when they dropped out, who
removed them), avoids update/delete race conditions, and lets the update trigger
reliably distinguish self-withdrawal from leader removal.

Hard delete is leader-only and is reserved for cleanup:

```dart
repository.removeRegistration(sectionId, eventId, userId)
```

## Re-registration

`registerForEvent` uses `set()` with the user's UID, so re-registering overwrites
the withdrawn document with a fresh `registeredAt`/`updatedAt` and a new
initial status. The rules explicitly allow a `withdrawn` document to move back
to `approved`, `pending`, or `waitlisted`.

## Notification side effects

All transitions are processed by the registration handlers, either through the
production HTTPS endpoints or the emulator's native Firestore triggers (see
`docs/notifications.md`).

| Transition | Recipients | Notification type |
|---|---|---|
| Created as `pending` | Event `tripLeaderIds` + `creatorId` (excluding the applicant) | `registration_pending` |
| Created as `approved` by a leader for another member | The added member | `registration_added` |
| Created as `waitlisted` | The member | `registration_waitlisted` |
| `pending`/`waitlisted` → `approved` | The member | `registration_approved` |
| `*` → `waitlisted` | The member | `registration_waitlisted` |
| `*` → `rejected` | The member | `registration_rejected` |
| Self-withdrawal (`withdrawnByUserId == userId`) | Event `tripLeaderIds` + `creatorId` (excluding the withdrawing leader) | `registration_withdrawn` |
| Leader removal (`withdrawnByUserId != userId`) | The removed member | `registration_removed` |
| Hard delete after self-withdrawal | Event leaders/creator | `registration_withdrawn` |
| Hard delete of an active registration by a leader | The removed member | `registration_removed` |

`sendNotificationToUser` respects each recipient's
`notificationPreferences`: in-app documents are written when `inAppEnabled`,
push is sent when `pushEnabled` and the profile has FCM tokens.

> The `Registration` model still has `guestName`, but guest registration is not
> exposed as a separate flow in the current UI. The rules require the
> registration document ID to be the caller's UID, so a guest entry is stored on
> the member's own registration.

## Event duplication

`repository.duplicateEvent` copies an event, clears its ID, prefixes the title
with `COPY: `, forces `status: draft`, advances past dates to the next
occurrence, and optionally copies active registrations and trip leaders. See
`Event.copyForDuplicate` in `packages/shared_models/lib/event.dart`.
