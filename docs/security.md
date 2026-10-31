# Security model

The authoritative implementation is `firestore.rules`, `storage.rules`, and the
Cloud Functions verification in `functions/lib/src/https_handlers.dart`. This
document explains the intended model and the known gaps.

## Authentication

Firebase Auth is the identity provider. Supported sign-in methods:

- email + password (with password reset);
- Google (native on Android/iOS/macOS, popup on web);
- Facebook (native dialog on Android/iOS/macOS, popup on web).

See `lib/pages/sign_in_page.dart` and `docs/facebook-login-setup.md` for the
provider setup.

### Onboarding guard

`appGuard` in `lib/routes.dart` runs on every navigation and enforces, in
order:

1. **Signed in** — otherwise redirect to `SignInRoute`. Stale tokens from a
   reseeded emulator are signed out rather than crashing.
2. **Waiver current** — `users/{uid}.waiverSignedDate` must be within 365 days;
   otherwise redirect to `WaiverRoute`.
3. **Profile complete** — `users/{uid}.complatedProfile` must be `true`
   (legacy spelling); otherwise redirect to `UserProfileRoute`.
4. **Section membership** — the user must belong to at least one section;
   otherwise redirect to `SectionSelectionRoute`.

`repository.checkProfile()` creates a stub profile on first login with
`complatedProfile: false`.

## Global admins

Global admin status comes **only** from a Firebase Auth custom claim:

```json
{ "role": "admin" }
```

The client reads it from `getIdTokenResult().claims['role']`
(`lib/state/user_state_cubit.dart`). Firestore rules read it from
`request.auth.token.role`.

The user document is **not** consulted. A `users/{uid}.isAdmin` field grants
nothing.

### Granting admin

Use the Firebase Admin SDK. The repository includes a sample at
`packages/aclub_admin/bin/claims.dart`:

```dart
await auth.setCustomUserClaims(uid, customUserClaims: {'role': 'admin'});
```

The affected user must refresh their ID token (sign out/in, or wait for the
token refresh) before the claim takes effect.

## Roles

### Global

| Role | Source | Scope |
|---|---|---|
| Admin | Auth custom claim `role: "admin"` | Whole application |

### Per-section

Stored in `sections/{sectionId}/members/{userId}.sectionRole`:

| Role | Can do |
|---|---|
| `sectionManager` | Manage section membership and roles; create/update/delete events; act as a trip leader |
| `tripLeader` | Create/update/delete events in the section; manage registrations |
| `member` | Read the section, register for events, edit/withdraw their own registration |

`UserStateCubit.canManageSection(sectionId)` returns true for global admins and
for `sectionManager`/`tripLeader` memberships.

> The rules also accept the legacy aliases `sectionAdmin` and `owner` wherever a
> section admin is required. The client model only writes the three values above.

## Firestore rules

| Path | Read | Write |
|---|---|---|
| `/users/{userId}` | Any signed-in user | Owner only (`request.auth.uid == userId`) |
| `/sections/{sectionId}` | Any signed-in user | Create/delete: global admin. Update: section manager or global admin |
| `/sections/{sectionId}/members/{userId}` | Any signed-in user | Create/update/delete: section manager or global admin. Self-join: own UID, existing section, `sectionRole == 'member'`, exact field shape, `externalSystemId == null`. Self-delete: own UID |
| `/sections/{sectionId}/events/{eventId}` | Section members | Trip leaders (which includes section managers) |
| `.../registrations/{registrationId}` | List: section members. Get: own registration or trip leader | See `docs/event-registration.md` |
| `/notifications/{notificationId}` | Own notifications (`recipientId == uid`) | Own notifications |
| `/templates/{templateId}` | Any signed-in user | Global admin |
| Collection group `registrations` | Own registrations or global admin | — |

### Section membership rules

The members subcollection is deliberately strict:

1. **Role changes are admin-only.** Section managers and global admins may
   create, update, or delete any membership document.
2. **Self-join is narrow.** The "My Sections" screen
   (`repository.setUserSections` → `addMemberToSection`) writes a
   `SectionMember` document for the caller. The rule requires:
   - the document ID is the caller's UID and `id == userId`;
   - `sectionId` matches the parent section and the section exists;
   - `sectionRole == 'member'` and `externalSystemId` is absent or null;
   - `joinedAt` is a timestamp;
   - the field set is exactly the `SectionMember` shape.
3. **Leaving is self-service.** A user may delete only their own membership.
   This is what `setUserSections` uses when a user deselects a section.

The result: a user can join a section as a plain member and leave it, but
cannot promote themselves or join with a privileged role. Privileged roles
require a section manager or global admin.

### Registration rules

Registration writes are constrained so members cannot self-approve, cannot
mark attendance, cannot use an arbitrary document ID, and cannot register on
another user's behalf. The full state machine is documented in
`docs/event-registration.md`.

### Capacity

`maxParticipants` **cannot** be enforced in rules because Firestore rules have
no count aggregation. Capacity is a client-side check; a determined caller can
over-register for an open event. Enforce it in a transaction/Cloud Function if
that matters.

## Storage

Firebase Storage is **not used** by the application. `storage.rules` denies all
reads and writes. If a feature starts using Storage, add narrowly scoped rules
with authentication, ownership, size, and content-type checks.

## Notification endpoints

The notification HTTPS endpoints are described in `docs/notifications.md`. In
summary:

- Cloud Run IAM is the real boundary: never grant `roles/run.invoker` to
  `allUsers`; only the Eventarc service account should have it.
- `verifyNotificationRequest` rejects non-POST requests, missing bearer tokens
  on Cloud Run, unexpected CloudEvent sources/types, and unauthenticated direct
  JSON callers (webhook secret).
- The long-term fix is native Firestore triggers; see the TODO markers in
  `functions/lib/functions.dart`.

## Known limitations

These are tracked in `docs/review.md` with more detail:

- **Profile PII is readable by every signed-in user.** `/users/{userId}` allows
  any signed-in user to read any profile, including medical conditions and
  emergency contacts (H1). The app needs member directory access, but a
  projection or a narrower rule would reduce exposure.
- **Draft events are readable by all section members.** The rules gate events
  at section level, so a member can read a draft document directly even though
  the default UI only lists published events (H2).
- **Any trip leader can edit any event in the section.** Event writes are
  section-scoped, not event-scoped (H3).
- **Profile writes are field-unrestricted.** The owner may write every profile
  field. No field grants privileges any more, but server-managed fields such as
  `defaultSectionId` and `fcmTokens` are not protected by `hasOnly(...)`
  (follow-up to C1).

## Rule tests

`test/rules/firestore_rules_test.sh` is an emulator-based regression suite. It
currently runs 28 checks covering section membership (C2), event registration
(C3), and templates (M11).

```bash
firebase emulators:exec --only firestore,auth \
  "bash test/rules/firestore_rules_test.sh"
```

Requires `firebase-tools`, `curl`, and `jq`.
