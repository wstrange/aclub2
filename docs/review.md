# Code Review — aclub2

**Date:** 2026-10-29
**Scope:** full repository — `lib/`, `functions/`, `packages/`, `firestore.rules`, `storage.rules`, `test/`, CI and build configuration.
**Current verification:** `flutter analyze` clean; `flutter test` 79/79; `functions` 44/44; `aclub_admin` 25/25; emulator rules suite 37/37; `flutter build web --no-tree-shake-icons` succeeds.

---

## Executive summary

The codebase is mechanically healthy: the analyzer is clean, the test suites pass, and the structure (repo layer, bloc_signals cubits, shared model package, Cloud Functions) is coherent and idiomatic for modern Flutter/Dart.

The remaining risks are concentrated in **authorization** and the **notification endpoint boundary**:

1. **C5.** The notification HTTPS endpoints still depend on Cloud Run IAM for their real authentication. In-handler verification is a stopgap until native triggers can be deployed.
2. **H1.** Profile PII (medical conditions, emergency contacts, phone) is readable by every signed-in user.
3. **H3.** Event writes are section-scoped, so any trip leader can edit or delete any event in the section.
4. **H2.** Drafts are filtered from the default UI, but the rules still allow any section member to read a draft document directly.

Everything else from the original review has been resolved and removed from this document; the git history retains the individual findings and fixes.

### Severity counts

| Severity | Count |
| --- | --- |
| Critical | 0 open, 1 mitigated (C5 pending IAM lockdown) |
| High | 2 open (H1, H3), 1 rule-level limitation (H2) |
| Medium | 0 |
| Low / nits | 0 |

---

## 1. Critical — security

### C5. Notification HTTPS endpoints — lightweight verification added (Cloud Run IAM still required) (`functions/lib/functions.dart:33-60`, `functions/lib/src/https_handlers.dart:232+`)

`eventCreatedHttp`, `eventUpdatedHttp`, `registrationCreatedHttp`, `registrationUpdatedHttp`, `registrationDeletedHttp`, and `notificationTriggerHttp` are `onRequest` handlers with no App Check, no OIDC/signature check, and no caller verification. They accept `sectionId`/`eventId`/`data` from the body and then act with Admin SDK privileges and send FCM messages. Consequences:

- Anyone who can reach the URL can trigger notification fan-out (spam / cost).
- Depending on how the handlers use the payload, they can be used to write or overwrite Firestore documents with admin privileges.
- The `GET` branch returns a readiness payload, which makes discovery trivial.

These are deployed as Cloud Run services and are intended to be invoked only by
GCP event delivery (Eventarc/Pub/Sub). "Not intended to be public" is not a
control: gen2 `onRequest` functions are deployed with the `allUsers` invoker by
default, so the URL is publicly callable unless IAM is changed.

**Status — implemented (workaround):** `verifyNotificationRequest`
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

### H3. Any trip leader can edit or delete any event in the section (`firestore.rules:87`)

`allow write: if isTripLeader(sectionId)` is section-wide. The model supports per-event leaders (`tripLeaderIds`), and the intended model has event managers. A trip leader can therefore modify or delete events they do not lead.

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

---

## 3. Known limitations and follow-ups

### H2. Draft events are readable directly by section members (`firestore.rules:84-87`)

`streamSectionEvents` now queries `status == 'published'` by default and, when a user ID is supplied, ORs in drafts where the user is the creator or in `tripLeaderIds`. The calendar therefore no longer shows other members' drafts.

The rule itself is still section-scoped (`allow read: if isSectionMember(sectionId)`), so a member can read a draft document directly if they know its ID. Firestore rules cannot filter list results, so closing this needs either a `get` rule that checks `status`/leadership or moving drafts to a separate collection. This is documented as a known limitation in `docs/security.md`, not as intended visibility.

### Registration capacity is enforced client-side only

`maxParticipants` cannot be enforced in rules (no count aggregation), so capacity remains a client-side check; a determined user can still over-register for an open event. Enforce capacity in a Cloud Function/transaction if that matters.

### Profile writes are field-unrestricted

`/users/{userId}` permits the owner to write every profile field. No field there grants privileges any more, but field-level `hasOnly(...)` restrictions would still be worth adding to protect server-managed fields (e.g. `defaultSectionId`, notification preferences, `fcmTokens`) and to prevent profile-shape drift. A regression test asserting that setting `isAdmin: true` on a user document does **not** grant admin access belongs in the rule suite.

### Enum/documentation sync is unenforced

The docs state that `packages/shared_models/lib/enums.dart` is authoritative, but nothing enforces it. Add a CI check or doc test that keeps the enum tables in sync.

---

## 4. Tests and CI

**Current state:** `flutter test` 79/79, `functions` 44/44, `aclub_admin` 25/25, emulator rules suite 37/37; `flutter analyze` and `dart analyze` are clean.

**Gaps, in priority order:**

1. **Security-rule regression suite exists.** `test/rules/firestore_rules_test.sh` runs against the Firestore/Auth emulators and covers section membership, event registration, templates, section creation, and notification ownership. Run it with:
   ```bash
   firebase emulators:exec --only firestore,auth "bash test/rules/firestore_rules_test.sh"
   ```
   Still to add: the C1 no-admin-escalation check and a CI job that runs the suite.
2. **HTTPS handler verification** is unit-tested via `verifyNotificationRequest` (see C5), but there is no test that Cloud Run IAM rejects unauthenticated callers at the platform level.
3. **No repository tests** for pagination (`hasMore`), the profile cache, or batch limits.
4. **No routing/guard tests** for the auth/profile-completion redirects.
5. **`functions/test/notification_handlers_test.dart` describes itself as "AI generated, and mostly useless".** Either rewrite it against real payloads and assert side effects, or delete it; a misleading green test is a liability.
6. **CI:** workflows exist but do not run the rules suite or a `flutter build web` smoke job consistently. Consider a matrix of `analyze`, `test`, `build web`, and `firebase emulators:exec --only firestore,auth "bash test/rules/firestore_rules_test.sh"`.

---

## 5. Suggested remediation order

1. **Ship-blocker (minutes):** set the Cloud Run invoker to non-public for the notification endpoints (C5).
2. **Same release (days):** H1 (PII projection) and H3 (event-scoped leadership).
3. **Next iteration:** H2 rule enforcement and server-side capacity enforcement, if those exposures matter.
4. **Ongoing:** run the rule suite in CI, add the C1 no-admin-escalation check, and add the enum/doc sync check.

---

## 6. What is working well

- Clean layering: UI → cubits → `repo.dart` → Firebase, with models isolated in `packages/shared_models`.
- Consistent primary-constructor style; analyzer clean with no ignores needed.
- Emulator support, seed data, and the admin package show good developer ergonomics.
- The withdrawal design (soft delete with `withdrawnByUserId`, documented trade-offs in `docs/event-registration.md`) is well thought through.
- `avatar_cache.dart`/`user_avatar.dart` are sensibly bounded.
- Error paths in the repo layer generally log and rethrow rather than swallowing, which makes debugging feasible.

The main takeaway: the application logic is solid; the authorization layer (H1, H3) and the notification endpoint boundary (C5) are the parts that still need work.
