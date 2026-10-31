# Code Review — aclub2

**Date:** 2026-10-29
**Scope:** full repository — `lib/`, `functions/`, `packages/`, `firestore.rules`, `storage.rules`, `test/`, CI and build configuration.
**Baseline verification:** `flutter analyze` → *No issues found!*; `flutter test` → 68/68 passing; `flutter build web --no-tree-shake-icons` → succeeds.

---

## Executive summary

The codebase is in good shape mechanically: the analyzer is clean, the test suite passes, and the structure (repo layer, bloc_signals cubits, shared model package, Cloud Functions) is coherent and idiomatic for modern Flutter/Dart. The primary-constructor syntax used throughout is valid for the pinned SDK and compiles without warnings.

The risks are concentrated in **authorization**, not in compile-time correctness:

1. ~~**`firestore.rules` grants users write access to fields that determine their own privileges.** A signed-in user could set their own `sections/{id}/members/{uid}.sectionRole = 'sectionManager'`.~~ *(Resolved — role changes are admin-only and self-join is constrained to a plain `member`; the equivalent `users/{uid}.isAdmin` escalation was also removed, so admin status now comes only from Auth custom claims. See C1 and C2.)*
2. ~~**`storage.rules` is fully open** (`allow read, write: if true`) and is deployed by `firebase.json`.~~ *(Resolved — Storage is unused and now denies all; see C4.)*
3. **The notification HTTPS functions have no authentication or signature verification** and trust caller-supplied bodies, so anyone who can reach them can send arbitrary notifications (and, depending on IAM, write with the Admin SDK).
4. ~~**Registrations can be self-approved.** A member may update their own registration's `status` to `approved`/`attended`, and `create` does not validate the document ID, allowing multiple registrations per event.~~ *(Resolved — see C3.)*

Several high/medium issues follow from those: draft events leak to all section members, any trip leader can edit any event in the section, and profile PII (medical conditions, emergency contacts, phone) is readable by every signed-in user.

On the client side the notable issues are correctness/UX rather than security: `context.watch` is used where `context.select`/`BlocSignalBuilder` semantics are required (screens can get stuck), new events default to `published` and notify immediately, and the Android emulator host override is broken.

**Recommendation:** the only remaining critical action is the **C5 Cloud Run IAM lockdown** — set the notification services to non-public invokers. It is a small configuration change and does not require architectural work. All rule-level critical findings (C1–C4) are resolved.

### Severity counts

| Severity | Count |
| --- | --- |
| Critical | 0 open, 1 mitigated (C1–C4 resolved; C5 mitigated pending IAM lockdown) |
| High | 6 |
| Medium | 12 (all resolved) |
| Low / nits | 12 |

---

## 1. Critical — security

### C1. ~~Any user can make themselves a global admin~~ — **Resolved**

Previously `isGlobalAdmin()` fell back to `users/{uid}.data.isAdmin == true`, while `/users/{userId}` allowed the owner to write every field. Any signed-in user could therefore escalate with:

```js
await updateDoc(doc(db, 'users', auth.currentUser.uid), { isAdmin: true });
```

**Resolution:** the Firestore fallback has been removed. `isGlobalAdmin()` now trusts only Auth custom claims, which are not user-writable:

```rules
function isGlobalAdmin() {
  return isSignedIn() && request.auth.token.role == 'admin';
}
```

The claim shape is `{ "role": "admin" }` everywhere. The client derives `UserState.isAdmin` from it (`lib/state/user_state_cubit.dart:66`), and the admin tooling sets it via the Admin SDK (`packages/aclub_admin/lib/src/admin_repo.dart:88-90`, `packages/aclub_admin/bin/claims.dart:18`).

**Follow-up (not blocking):** `/users/{userId}` still permits the owner to write every profile field. No field there grants privileges any more, but field-level `hasOnly(...)` restrictions would still be worth adding to protect server-managed fields (e.g. `defaultSectionId`, notification preferences) and to prevent profile-shape drift. A regression test asserting that setting `isAdmin: true` on a user document does **not** grant admin access belongs in the rule suite.

### C2. ~~Any user can make themselves a section manager~~ — **Resolved**

Previously:

```rules
match /members/{userId} {
  allow read: if isSignedIn();
  allow write: if isSectionAdmin(sectionId) || isUser(userId) || isGlobalAdmin();
}
```

`isUser(userId)` let the owner write **all** fields of their member document, including `sectionRole`, so any user could self-promote to `sectionManager` (or self-join any section).

**Resolution:** the members subcollection now enforces three invariants:

1. **Role changes are admin-only.** `create`/`update`/`delete` require `isSectionAdmin(sectionId) || isGlobalAdmin()`.
2. **Self-service join is narrow.** The "My Sections" flow (`setUserSections` → `addMemberToSection`) still works, but only for the caller, only in an existing section, and only as a plain member:
   - `isUser(userId)` — the path id must be the caller's UID;
   - `request.resource.data.id == userId` and `sectionId == sectionId` — no spoofed ids;
   - `sectionRole == 'member'` and `externalSystemId == null` — no privileged role or external-membership claim;
   - `joinedAt` must be a timestamp and the field set must exactly match the `SectionMember` shape;
   - the parent section must exist.
3. **Leaving is self-service.** A user may delete only their own membership (`allow delete: if isUser(userId)`).

```rules
allow create, update, delete: if isSectionAdmin(sectionId) || isGlobalAdmin();

allow create: if isUser(userId)
  && exists(/databases/$(database)/documents/sections/$(sectionId))
  && request.resource.data.id == userId
  && request.resource.data.sectionId == sectionId
  && request.resource.data.sectionRole == 'member'
  && (!('externalSystemId' in request.resource.data)
    || request.resource.data.externalSystemId == null)
  && request.resource.data.joinedAt is timestamp
  && request.resource.data.keys().hasAll(['id', 'sectionId', 'sectionRole', 'joinedAt'])
  && request.resource.data.keys().hasOnly(['id', 'sectionId', 'sectionRole', 'externalSystemId', 'joinedAt']);

allow delete: if isUser(userId);
```

**Verified** with the emulator rule suite (`test/rules/firestore_rules_test.sh`): self-promotion denied, privileged self-join denied, member self-join allowed, post-join promotion denied, spoofed ids / nonexistent sections / external ids / extra fields denied, self-leave allowed, deleting another member denied, and a section manager can still change roles. The suite now runs 28 checks (C2 + C3 + M11), all passing.

### C3. ~~Registration status can be self-approved; duplicate registrations possible~~ — **Resolved**

Previously:

```rules
allow create: if isSectionMember(sectionId) && (request.resource.data.userId == request.auth.uid || isTripLeader(sectionId));
allow update, delete: if isSectionMember(sectionId) && (resource.data.userId == request.auth.uid || isTripLeader(sectionId));
```

A member could self-approve, self-mark `attended`, or create registrations under arbitrary document IDs.

**Resolution:** the rules now enforce three invariants:

1. **One registration per member per event.** Registrations use the member's UID as the document ID, so `create` requires `registrationId == userId == request.resource.data.id` (leaders may register someone else, but still with `userId == registrationId`).
2. **No self-approval.** A self-registration may only start in `pending`/`waitlisted` for `requiresApproval` events, or `approved` for open events (`isAllowedInitialStatus`, which reads the parent event's `requiresApproval`).
3. **No self-promotion on update.** A member may only:
   - edit non-status fields (`guestName`, `isDriver`, `needsRide`, `updatedAt`),
   - withdraw an active registration (`pending`/`waitlisted`/`approved` → `withdrawn`, with `withdrawnByUserId == auth.uid`),
   - re-register after a withdrawal (only to an allowed initial status).

   `attended`/`absent`/`rejected` and ownership/`registeredAt` changes are leader-only.

```rules
allow create: if isSectionMember(sectionId) && (
  (isTripLeader(sectionId)
    && request.resource.data.userId == registrationId
    && request.resource.data.id == registrationId)
  || (request.resource.data.userId == request.auth.uid
    && registrationId == request.auth.uid
    && request.resource.data.id == registrationId
    && isAllowedInitialStatus(sectionId, eventId, request.resource.data.status))
);

allow update: if isSectionMember(sectionId) && (
  isTripLeader(sectionId)
  || (resource.data.userId == request.auth.uid
    && request.resource.data.userId == resource.data.userId
    && request.resource.data.id == resource.data.id
    && (
      (request.resource.data.status == resource.data.status
        && request.resource.data.registeredAt == resource.data.registeredAt
        && request.resource.data.diff(resource.data).affectedKeys()
             .hasOnly(['guestName', 'isDriver', 'needsRide', 'updatedAt']))
      || (request.resource.data.status == 'withdrawn'
        && resource.data.status in ['pending', 'waitlisted', 'approved']
        && request.resource.data.withdrawnByUserId == request.auth.uid)
      || (resource.data.status == 'withdrawn'
        && isAllowedInitialStatus(sectionId, eventId, request.resource.data.status))
    ))
);
```

**Verified** with the emulator rule suite (`test/rules/firestore_rules_test.sh`): self-approve on create/update denied, pending create allowed, withdraw/re-register allowed, arbitrary doc ID denied, registering another user denied, open-event self-registration allowed, self-mark-attended denied, leader approve/register allowed, member hard-delete denied, leader hard-delete allowed.

**Residual limitation:** `maxParticipants` cannot be enforced in rules (no count aggregation), so capacity remains a client-side check; a determined user can still over-register for an open event. Enforce capacity in a Cloud Function/transaction if that matters.

### C4. ~~Storage is world-readable and world-writable~~ — **Resolved**

Previously:

```rules
match /{allPaths=**} {
  allow read, write: if true; // ⚠️ Warning: Open for local testing. Restrict before deploying!
}
```

`firebase.json` deploys `storage.rules`, so anyone could read or overwrite any object.

**Resolution:** Firebase Storage is not used by the app (no `firebase_storage` dependency and no client usage), so the rules now deny everything by default:

```rules
match /{allPaths=**} {
  allow read, write: if false;
}
```

If a feature starts using Storage, add narrowly scoped rules with authentication, ownership, size, and content-type checks — for example:

```rules
match /users/{userId}/{fileName} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && request.auth.uid == userId
    && request.resource.size < 5 * 1024 * 1024
    && request.resource.contentType.matches('image/.*');
}
```

### C5. Notification HTTPS endpoints — lightweight verification added (Cloud Run IAM still required) (`functions/lib/functions.dart:33-60`, `functions/lib/src/https_handlers.dart:232+`)

`eventCreatedHttp`, `eventUpdatedHttp`, `registrationCreatedHttp`, `registrationUpdatedHttp`, `registrationDeletedHttp`, and `notificationTriggerHttp` are `onRequest` handlers with no App Check, no OIDC/signature check, and no caller verification. They accept `sectionId`/`eventId`/`data` from the body and then act with Admin SDK privileges and send FCM messages. Consequences:

- Anyone who can reach the URL can trigger notification fan-out (spam / cost).
- Depending on how the handlers use the payload, they can be used to write or overwrite Firestore documents with admin privileges.
- The `GET` branch returns a readiness payload, which makes discovery trivial.

These are deployed as Cloud Run services and are intended to be invoked only by
GCP event delivery (Eventarc/Pub/Sub). "Not intended to be public" is not a
control: gen2 `onRequest` functions are deployed with the `allUsers` invoker by
default, so the URL is publicly callable unless IAM is changed.

**Status — implemented:** `verifyNotificationRequest`
(`functions/lib/src/https_handlers.dart`) now runs at the top of every HTTP
handler and rejects:

- non-`POST` requests (the `GET` readiness probe remains);
- requests without a bearer token when `K_SERVICE` is set (Cloud Run);
- CloudEvents whose `ce-source` is not a Firestore source or whose `ce-type` is
  not a Firestore document event;
- on Cloud Run, direct JSON calls that are not CloudEvents unless they present
  a matching `x-notification-secret` (`NOTIFICATION_WEBHOOK_SECRET`), for
  manual replay/webhooks only — Eventarc cannot send custom headers;
- elsewhere (emulator/local), non-CloudEvent calls are rejected if a webhook
  secret is configured but does not match.

This is deliberately **minor** verification: Cloud Run IAM still performs the
real OIDC signature/audience validation. The source carries a
`TODO(security)` in both `functions.dart` and `https_handlers.dart` to migrate
to native triggers when Dart supports deploying them in production.

**Recommended verification — layered:**

1. **Cloud Run IAM (the real gate).** Remove the `allUsers` binding and grant
   `roles/run.invoker` only to the Eventarc trigger's service account. Eventarc
   then attaches a Google-signed OIDC ID token, and Cloud Run validates issuer,
   audience, signature, and expiry before the request reaches the container.
   Verify with `gcloud run services get-iam-policy <service> --region=<region>`;
   an unauthenticated `curl` must return **403 from the platform**, not a
   response from the handler. Re-check after every deploy (or manage IAM with
   Terraform) because redeploys can re-grant `allUsers`. Lock down `helloWorld`
   the same way or delete it.
2. **In-handler OIDC check (defence in depth).** If the request reaches your
   code, require `Authorization: Bearer <JWT>` and validate `iss ==
   https://accounts.google.com`, `aud == <Cloud Run service URL>` (configure via
   an env var), `email == <expected trigger service account>`,
   `email_verified == true`, and `exp`/`iat`, with the signature checked against
   Google's JWKS (`https://www.googleapis.com/oauth2/v3/certs`). Reject with
   401. Use a maintained JWT library rather than hand-rolled parsing.
3. **Validate the CloudEvents envelope.** Require `ce-specversion: 1.0`,
   `ce-type` in an allowlist (`google.cloud.firestore.document.v1.created|updated|deleted`),
   `ce-source == //firestore.googleapis.com/projects/<project>/databases/(default)`,
   and `ce-subject` matching the expected document path. Accept `POST` only and
   cap the body size; the current `GET` readiness response is unnecessary
   surface.
4. **Never trust the body.** `parseNotificationRequest` currently takes
   `sectionId`, `eventId`, `status`, `title`, `authId`, and `data` from the
   body/query, and `handleNewEventCreated` uses a caller-supplied `status` when
   present. A forged `status: "published"` can therefore fan out notifications
   for an arbitrary or draft event. Treat the payload as a pointer only:
   re-read the event/registration from Firestore with the Admin SDK and derive
   `status`, `title`, recipients, and the actor from the stored document.
5. **Make delivery idempotent.** Eventarc/CloudEvents is at-least-once; dedupe
   on `ce-id` (a short-TTL `_processedEvents` collection or an event-id field)
   so retries do not send duplicate notifications.

**Preferred architectural fix (deferred):** the native Firestore triggers
already exist for the emulator (`functions/lib/functions.dart:73-97`:
`onDocumentCreated`, `onDocumentUpdated`, `onDocumentCreatedWithAuthContext`,
etc.). Registering them in production would let Eventarc create and
authenticate the triggers, make the Cloud Run service non-publicly-invocable,
and remove the forged-body surface. This is deferred because the Dart
`firebase_functions` package does not yet support deploying these triggers in
production; the `TODO(security)` markers track the migration.

**Tests:** the lightweight checks are covered in
`functions/test/https_handlers_test.dart` (GET allowed, non-POST rejected,
bearer required on Cloud Run, bad CloudEvent source/type rejected, webhook
secret enforced). Still to add: an unauthenticated request returns 403 from the
platform, a valid token with a forged `status`/`title` produces no side effects,
a replayed `ce-id` produces one notification, and a draft event produces no
notification.

---

## 2. High

### H1. All profile PII is readable by every signed-in user (`firestore.rules:47`)

`/users/{userId}` allows `read: if isSignedIn()`. Profiles contain `phone`, `emergencyContactName`, `emergencyContactPhone`, `emergencyContactRelation`, and `medicalConditions` (`packages/shared_models/lib/user_profile.dart:33-41`). Any account can enumerate the whole collection and harvest medical and emergency-contact data across all sections.

**Fix:** restrict reads to self, global admins, and members who share a section (or expose a reduced public profile and keep sensitive fields in a `private` subcollection readable only by leaders/admins). A shared-section check needs a membership lookup; a cheaper design is a `publicProfiles` projection plus a leader-only `profiles/{uid}/private`.

### H2. Draft events are visible to all section members (`firestore.rules:84-87`, `lib/repo.dart:111-115`) **Resolved**

The README (`README.md:29,37,194`) says events start as `draft` and drafts are visible only to the creator and trip leaders, and must not appear in the event list. In practice:

- `streamSectionEvents` streams the entire `events` collection with no status filter.
- The rules allow `read` for any section member and do not check `status`.

So drafts leak to everyone in the section, and the calendar renders them.

**Fix:** either filter in the query (`where('status', isEqualTo: 'published')`) and add a leader-only draft query, or enforce in rules:

```rules
allow get: if isSectionMember(sectionId)
  && (resource.data.status == 'published' || isTripLeader(sectionId));
allow list: if isSectionMember(sectionId); // then constrain the query client-side
```

Firestore rules cannot filter list results, so the query must carry the constraint. Add `where('status', isEqualTo: 'published')` to the member-facing stream and a separate `streamSectionDrafts` gated on leadership.

### H3. Any trip leader can edit or delete any event in the section (`firestore.rules:87`)

`allow write: if isTripLeader(sectionId)` is section-wide. The model supports per-event leaders (`tripLeaderIds`), and the README describes event managers. A trip leader can therefore modify or delete events they do not lead.

**Fix:** for `update`/`delete`, require leadership *of that event*:

```rules
function leadsEvent() {
  return isSectionMember(sectionId)
    && (isSectionAdmin(sectionId)
        || request.auth.uid in resource.data.tripLeaderIds
        || resource.data.createdByUserId == request.auth.uid);
}
allow update, delete: if leadsEvent();
allow create: if isTripLeader(sectionId)
  && request.resource.data.createdByUserId == request.auth.uid;
```

### H4. `context.watch` does not rebuild on state changes (`lib/pages/event_edit_page.dart:23`, `lib/pages/event_detail_page.dart:85,320`)

```dart
final userState = context.watch<UserStateCubit>().state.value;
```

With bloc_signals, `context.watch` tracks *provider replacement*, not signal value changes; reading `.state.value` after `watch` gives a snapshot that is not refreshed when the cubit emits. The edit page consequently can remain stuck on the "no permission" branch after the user state loads or changes section, and the detail page's permission/capacity UI can be stale.

**Fix:** use the builder that subscribes to the signal:

```dart
BlocSignalBuilder<UserStateCubit, UserState?>(
  builder: (context, userState) { ... },
)
```

or `context.select((UserStateCubit c) => c.state.value)` if a selector API is available. This is exactly the trap the bloc-signals guidance warns about.

### H5. New events are published immediately and notify members (`lib/pages/event_edit_page.dart:50`)

```dart
status: EventStatus.published,
```

This contradicts the documented draft-first workflow and means a half-filled event is visible and triggers notifications before the leader has reviewed it. Combined with C5, the notification path depends on Cloud Run IAM plus the lightweight handler check.

**Fix:** default to `EventStatus.draft`; publish explicitly from the edit screen, and only fire the notification function on the draft → published transition.

### H6. Profile cache is a single global slot (`lib/repo.dart:377,451-461`) **Resolved**

`_cachedProfile` holds one `UserProfile`. `getUserProfile(uid)` overwrites it on every call, so:

- Two concurrent callers for different users thrash the cache and can return the wrong profile (the `id == uid` check prevents a wrong *return*, but the cache is effectively useless under concurrency).
- `UserChip`/`UserDisplay` each perform a Firestore read per widget with no effective sharing → N+1 reads in rosters and registration lists.

**Fix:** replace with a `Map<String, UserProfile>` (with TTL/size bound) or an LRU, and have list screens use the existing `getUserProfiles(List<String>)` batch helper (`lib/repo.dart:469`) instead of per-widget reads.

---

## 3. Medium

### M1. ~~`deleteAllNotifications` can exceed the Firestore batch limit~~ — **Resolved**

`lib/repo.dart` now has a `_writeInBatches` helper that commits at most 500 operations per batch. `deleteAllNotifications` uses it, as does the new `markAllNotificationsAsRead` (see M8). It was the only `WriteBatch` built from an unbounded query in `lib/`.

### M2. ~~Pagination `hasMore` is wrong for short pages~~ — **Resolved**

`getSectionMembersPage` and `streamSectionMembers` now set `nextCursor` only when `docs.length == limit`. A short page clears the cursor and `hasMore` with it, so `MemberDirectoryCubit.loadMore` stops instead of repeatedly fetching empty pages.

### M3. ~~`pickDateTime` hardcodes `firstDate: DateTime(2026)`~~ — **Resolved**

`lib/pages/event_edit_page.dart` now uses a window of `now.year - 5` … `now.year + 5` and clamps `initialDate` into that range, so editing an older (or far-future) event no longer trips the picker assertion.

### M4. ~~`updateUserProfile` silently keeps the old email~~ — **Resolved**

`verifyBeforeUpdateEmail` only sends a link, so the new address is no longer written to the profile. `UserFormSuccess` carries the pending address (`verificationEmailSentTo`) and the success snackbar reports "Verification email sent to …". The profile continues to store the current, verified Auth email until the user confirms the change.

### M5. ~~Debug UI in production~~ — **Resolved**

The profile form previously exposed a `Status (Remove latet)` section with a user-toggleable **Profile completed** switch (`lib/pages/user_profile_page.dart`). Both the heading and the toggle have been removed; the section is now titled `Status` and only shows the read-only waiver state. Profile completion is still set to `true` automatically when the form is saved.

### M6. ~~`MembersDirectoryPage` crashes for a global admin with no sections~~ — **Resolved**

The global-admin branch now lives in `_GlobalAdminDirectory`, which caches the `getSections()` future in `initState`, renders `_NoSectionsView` when the section list is empty, and keys the `MemberDirectoryCubit` provider by section. The non-admin branch also guards an empty `userSections` before constructing the view.

### M7. ~~Roster export includes pending registrations~~ — **Resolved**

`_loadParticipants` now includes only `approved`/`attended` registrations. Pending and waitlisted members are excluded from the safety roster, and the unused `status` field was removed from `_ParticipantInfo`.

### M8. ~~Notification sheet duplicates the badge stream and has unsafe mutations~~ — **Resolved**

`_NotificationIconButton` owns a single broadcast stream, shared by the badge and the sheet. `_NotificationsSheet` hides an optimistically deleted ID until the write completes and restores it (with an error snackbar) on failure, so a `Dismissible` is never left in the tree. "Mark all as read" calls the new batched `repository.markAllNotificationsAsRead`, and "Clear all" reverts its optimistic removal on failure.

### M9. ~~FCM token removal can be a no-op~~ — **Resolved**

`syncDeviceToken` now reads and caches the current token (falling back to the deprecated `getToken()` because `onRegistered` is not a pull API) before syncing. `handleSignOut` falls back to `getToken()` when no token was cached and clears `_currentToken`. The home-page sign-out button now calls `handleSignOut` *before* `FirebaseAuth.signOut()` — the rules reject post-sign-out writes to `users/{uid}`, and the old code cleared `userStateCubit` first so the auth listener could not clean up either.

### M10. ~~Dead/broken event queries~~ — **Resolved**

Removed `streamPublicEvents` and `streamLeaderDrafts` from `lib/repo.dart`; both targeted a schema that does not exist and had no callers.

### M11. ~~`templates` is writable by any signed-in user~~ — **Resolved**

`firestore.rules` now uses `allow read: if isSignedIn(); allow write: if isGlobalAdmin();`, and the Templates drawer entry is gated on `UserState.isAdmin` to match. Verified with the emulator: signed-in read allowed, non-admin write denied, unauthenticated write denied.

### M12. ~~Duplicated notification-topic logic~~ — **Resolved**

`sanitizeTopicName` and `sectionEventsTopic` now live in `packages/shared_models/lib/fcm_topics.dart`, exported by `shared_models`. Both `lib/services/fcm_service.dart` and `functions/lib/src/notification_dispatcher.dart` import them from there, so publisher and subscriber cannot drift. The client and functions tests were updated to use the shared implementation.

**Medium verification:** `flutter analyze` clean, `flutter test` 68/68, `functions` `dart analyze` clean and `dart test` 27/27, `shared_models` `dart analyze` clean, and the emulator rules suite 28/28 (C2 membership, C3 registration, and M11 template checks).

---

## 4. Low / nits

- **L1.** `main.dart:118-129`: `_connectToFirebaseEmulator` sets `localHost = 'localhost'` unconditionally at line 128, after the Android `10.0.2.2` branch, so Android emulator debug always points at the wrong host. Move the Android override after the final assignment or delete the redundant line.
- **L2.** `lib/widgets/user_display.dart`: per-widget profile reads (see H6). Prefer passing a resolved `UserProfile` or using the batch helper.
- **L3.** `lib/pages/event_detail_page.dart`: registration/capacity checks are recomputed in several builders; extract a single derived view-model to keep "can register / waitlist / full" consistent.
- **L4.** `AddParticipantSheet`: email search lowercases the query but compares against the raw stored email; lowercase both sides.
- **L5.** `calendar_agenda_view.dart:97`: pluralization uses `filteredEvents.length` instead of the per-month count. `isTomorrow`/`isYesterday` (lines 227-228) compare `day + 1` without handling month rollover. `useEffect` depends only on `dayEntries.length` (line 167), so same-length updates can be missed.
- **L6.** `firestore.rules:62`: `allow write: if isSectionAdmin(sectionId)` is redundant/contradictory after the explicit `create/update/delete` rules and, because `write` includes `create`, re-permits section admins to create sections. Remove it.
- **L7.** `firestore.rules:104-105`: notification rules are confusing (`resource` is undefined on create; the second `allow create` overrides). Consolidate into `allow read, update, delete` keyed on recipient and a single `allow create` keyed on `request.resource`.
- **L8.** `functions/lib/src/notification_dispatcher.dart`: multicast failures are logged but invalid tokens are never pruned, so dead tokens accumulate and inflate every send.
- **L9.** `functions/lib/src/registration_handlers.dart`: withdrawal notification transitions are not covered by tests; the status transition table is implicit. Centralise allowed transitions and test them.
- **L10.** Tracked build artifact `android/build/reports/problems/problems-report.html` should be removed from git; `.gitignore` already covers `*.log` (the 1 GB `firestore-debug.log` is untracked but should be deleted from disk).
- **L11.** `AvatarHttpFileService` ignores the `concurrentFetches` queue per request (bounded, so not a leak, but the option is misleading).
- **L12.** `pubspec.yaml` pins are fine, but consider `dependency_overrides`/`resolution: workspace` consistency if the packages are developed together; currently `packages/` are path dependencies, which is correct.

---

## 5. Documentation drift

The README is a design document as much as a usage guide, and it has diverged from the implementation. These are not cosmetic: they mislead contributors about the security model.

| README claim | Reality |
| --- | --- |
| `managerIds` on `/sections/{id}` (`README.md:120,166`) | Per-user `sections/{id}/members/{uid}.sectionRole` (`packages/shared_models/lib/section_member.dart:22`). |
| `UserRole` = `admin \| tripLeader \| member \| guest` (`README.md:284`) | `enum UserRole { admin, member }` (`packages/shared_models/lib/enums.dart:9`); section roles are separate (`SectionRole { sectionManager, tripLeader, member }`). |
| Events have `visibility` and `tripLeaders` (`README.md:29`) | Events are stored under `sections/{id}/events`, use `tripLeaderIds`, and have no `visibility` field. |
| New events default to `draft` (`README.md:37,194`) | `EventEditPage` creates `EventStatus.published` (`lib/pages/event_edit_page.dart:50`). |
| Drafts visible only to creator + trip leaders | All section members can read them (H2). |
| Section membership managed by an external system | Members self-join via rules as a plain `member`; privileged roles require a section/global admin (C2). |
| Profile fields | `UserProfile`/`Section` doc comments still describe removed/renamed fields. |

**Recommendation:** update the README schema and role tables to match `shared_models`, and add a CI check (or a short doc test) that keeps the enum lists in sync. Where the README describes intended behaviour that is not implemented (draft visibility, external-only membership), either implement it or mark it explicitly as "planned".

---

## 6. Tests and CI

**Current state:** 68 tests pass; `flutter analyze` is clean; the web build succeeds. That is a good baseline.

**Gaps, in priority order:**

1. **Security-rule regression suite exists.** `test/rules/firestore_rules_test.sh` runs against the Firestore/Auth emulators and covers C2 (role escalation, narrow self-join, self-leave), C3 (registration status, doc IDs, duplicates), and M11 (templates). Run it with:
   ```bash
   firebase emulators:exec --only firestore,auth "bash test/rules/firestore_rules_test.sh"
   ```
   Still to add: a check that `isAdmin: true` on a user document does *not* grant admin (C1), and a CI job that runs the suite.
2. **HTTPS handler verification** is now unit-tested via `verifyNotificationRequest` (see C5), but there is no test that Cloud Run IAM rejects unauthenticated callers at the platform level.
3. **No repository tests** for pagination (`hasMore`), the profile cache, or batch limits.
4. **No routing/guard tests** for the auth/profile-completion redirects.
5. **`functions/test/notification_handlers_test.dart` describes itself as "AI generated, and mostly useless".** Either rewrite it against real payloads and assert side effects, or delete it; a misleading green test is a liability.
6. **CI:** workflows exist but do not run the rules suite or a `flutter build web` smoke job consistently. Consider a matrix of `analyze`, `test`, `build web`, and `firebase emulators:exec --only firestore,auth "bash test/rules/firestore_rules_test.sh"`.

---

## 7. Suggested remediation order

1. **Ship-blocker (minutes):** set the Cloud Run invoker to non-public for the notification endpoints (C5). All rule-level critical findings (C1, C2, C3, C4) are resolved and covered by the emulator rule suite.
2. **Same release (days):** H1 (PII projection), H2 (draft filtering), H3 (event-scoped leadership), H5 (draft default), H4 (watch → builder).
3. **Next iteration:** H6 cache, plus the remaining High items. (M1/M2 pagination and batching, M6 crash guard, M9 FCM token lifecycle and the rest of section 3 are resolved.)
4. **Ongoing:** run the rule suite in CI, add the C1 no-admin-escalation check, README schema sync. (Dead queries and debug UI have been removed; see M5/M10.)

---

## 8. What is working well

- Clean layering: UI → cubits → `repo.dart` → Firebase, with models isolated in `packages/shared_models`.
- Consistent primary-constructor style; analyzer clean with no ignores needed.
- Emulator support, seed data, and the admin package show good developer ergonomics.
- The withdrawal design (soft delete with `withdrawnByUserId`, documented trade-offs in `README.md:308-309`) is well thought through.
- `avatar_cache.dart`/`user_avatar.dart` are sensibly bounded.
- Error paths in the repo layer generally log and rethrow rather than swallowing, which makes debugging feasible.

The main takeaway: the application logic is solid; the authorization layer is the part that needs to be brought up to the same standard.
