# Notifications

This document describes the notification system as implemented. The earlier
FCM design plan has been folded into this file; the unimplemented parts are
listed under [Future work](#future-work).

## Channels

| Channel | Status | Implementation |
|---|---|---|
| In-app | Implemented | A `/notifications/{id}` Firestore document per recipient, shown in the app's notification sheet |
| Push (FCM) | Implemented | Direct multicast to `users/{uid}.fcmTokens` for personal alerts; topic broadcast for new events |
| Email | **Not implemented** | `emailEnabled` exists in preferences and `NotificationChannel.email` exists in the enum, but no email is sent |

`NotificationPreferences.frequency` (`immediate`/`daily`/`weekly`) is also
reserved; all notifications are currently delivered immediately. The profile
page still shows the email and frequency controls, but they are persisted
without affecting delivery.

## Delivery rules

`sendNotificationToUser` (`functions/lib/src/notification_dispatcher.dart`)
loads the recipient's profile and:

1. writes an in-app notification when `inAppEnabled` is true;
2. sends an FCM multicast when `pushEnabled` is true and `fcmTokens` is not
   empty.

A malformed or missing profile is skipped rather than failing the whole
dispatch.

`notifySectionMembersOfEvent` handles new-event announcements:

- publishes one FCM topic message to `section_{sectionId}_events`;
- writes in-app notifications for every section member whose
  `notifyForNewEvents` and `inAppEnabled` are true.

## Triggers

Production and the emulator use different trigger mechanisms because the Dart
`firebase_functions` package cannot yet deploy native Firestore triggers.

### Production (HTTPS endpoints)

| Endpoint | Purpose |
|---|---|
| `helloWorld` | Health check |
| `eventCreatedHttp` | New event created |
| `eventUpdatedHttp` | Event updated (including draft → published) |
| `registrationCreatedHttp` | Registration created |
| `registrationUpdatedHttp` | Registration updated |
| `registrationDeletedHttp` | Registration hard-deleted |
| `notificationTriggerHttp` | Unified dispatcher for Eventarc/webhooks |

Each endpoint accepts Eventarc CloudEvents, and direct JSON when authenticated
(see [Security](#security)). `GET` is allowed as a readiness probe.

### Emulator (native Firestore triggers)

When `FUNCTIONS_EMULATOR=true`, `registerFunctions` also registers:

- `onDocumentCreated` / `onDocumentUpdated` on
  `sections/{sectionId}/events/{eventId}`;
- `onDocumentCreatedWithAuthContext`, `onDocumentUpdatedWithAuthContext`, and
  `onDocumentDeletedWithAuthContext` on
  `sections/{sectionId}/events/{eventId}/registrations/{registrationId}`.

The handlers are shared with the HTTPS endpoints, so behaviour is identical.

> `TODO(security)` in `functions/lib/functions.dart` tracks migrating production
> to these native triggers once the package supports deployment. That removes
> the public HTTP surface entirely.

## Notification types

| Type | Trigger | Recipient |
|---|---|---|
| `new_event` | Event created as published | Section topic + opted-in members |
| `event_published` | Draft event published | Section topic + opted-in members |
| `registration_pending` | Registration created/updated to `pending` | Event trip leaders + creator |
| `registration_added` | Leader registers another member as `approved` | Added member |
| `registration_approved` | Registration approved | Member |
| `registration_waitlisted` | Registration created as or moved to `waitlisted` | Member |
| `registration_rejected` | Registration rejected | Member |
| `registration_withdrawn` | Member withdraws | Event trip leaders + creator |
| `registration_removed` | Leader removes a member | Removed member |

The exact transition table lives in `docs/event-registration.md`.

## FCM topics

Topic names are shared between the client and the backend through
`packages/shared_models/lib/fcm_topics.dart`:

```dart
String sanitizeTopicName(String input) =>
    input.replaceAll(RegExp(r'[^a-zA-Z0-9-_.~%]'), '_');

String sectionEventsTopic(String sectionId) =>
    'section_${sanitizeTopicName(sectionId)}_events';
```

Sharing the helpers prevents the publisher and subscriber from drifting.

The client (`FcmService.syncTopicSubscriptions`) subscribes to every section the
user belongs to when **both** `pushEnabled` and `notifyForNewEvents` are true,
and unsubscribes otherwise. FCM Web does not support client-side topic
subscriptions, so topics are skipped on web (`isTopicSupported`).

### Why topics for announcements?

A topic broadcast is O(1) regardless of section size, instead of reading every
member profile to collect device tokens. Personal alerts (approval, removal)
still use direct multicast because they target one user.

## Device tokens

`FcmService` (`lib/services/fcm_service.dart`):

- requests notification permission;
- registers the device and stores the token in `users/{uid}.fcmTokens`;
- listens for token refresh via `onRegistered`;
- removes the token from the previous user's profile and unsubscribes from
  topics on sign-out;
- handles foreground messages, background taps, and cold-start navigation to
  `EventDetailRoute`.

`getToken()` is deprecated in `firebase_messaging` 17 but is used deliberately
in `syncDeviceToken`/`handleSignOut` because `onRegistered` is not a pull API
and sign-out must be able to remove the exact token.

## Deep links

Push payloads carry `sectionId`, `eventId`, and `link`. Tapping a notification
navigates to the event detail page. In-app notification `link` values use the
same `/events/{eventId}` shape.

## Security

The real boundary is **Cloud Run IAM**:

- never grant `roles/run.invoker` to `allUsers`;
- only the Eventarc trigger service account should be able to invoke the
  services.

`verifyNotificationRequest` adds defence in depth:

- rejects non-`POST` methods (except the `GET` readiness probe);
- on Cloud Run, requires an `Authorization: Bearer …` header (Eventarc attaches
  a Google-signed OIDC token that Cloud Run validates);
- for CloudEvents, allowlists the `ce-source`
  (`//firestore.googleapis.com/projects/…`) and `ce-type`
  (`google.cloud.firestore.document.v1.…`);
- for direct JSON, requires the `x-notification-secret` header to match
  `NOTIFICATION_WEBHOOK_SECRET`; on Cloud Run this is mandatory, so a stray
  HTTP call cannot masquerade as an event.

Unit tests for these checks live in
`functions/test/https_handlers_test.dart`.

## Local development

The emulator has no FCM service, so push delivery is logged instead of sent:

```
[emulator] FCM push skipped (no FCM emulator). Would send to N device token(s)…
[emulator] FCM topic push: topic="section_calgary_events", …
```

In-app notifications are still written to Firestore and appear in the app.

## Future work

1. **Email delivery** — use `emailEnabled` and a transactional email provider.
2. **Frequency batching** — honour `NotificationFrequency` with a scheduled
   digest instead of immediate delivery.
3. **Native Firestore triggers in production** — removes the public HTTPS
   surface and the forged-body risk. Blocked on `firebase_functions` support.
4. **Idempotency** — Eventarc is at-least-once; dedupe on `ce-id` or an
   event-id field before enabling retries.
5. **Activity sub-topics** — e.g. `section_{id}_events_{type}` or FCM
   conditions so members can follow only the activities they care about.
   `section_{id}_events` remains the backward-compatible default.
6. **Derive payloads from stored documents** — the handlers currently trust
   some caller-supplied fields; production triggers should re-read the
   event/registration and derive status, title, and recipients from Firestore.
