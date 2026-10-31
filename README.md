# aclub2

A multi-tenant alpine club application built with Flutter and Firebase.
Members belong to one or more sections, sections host events, and members
register for those events and receive notifications.

## What it does

- **Membership** — Firebase Auth accounts (email/password, Google, Facebook)
  with a profile containing emergency contacts, certifications, and
  notification preferences. Members join sections and choose the section they
  are currently viewing.
- **Sections** — each section has its own members, events, and managers.
  Roles are per-section: `sectionManager`, `tripLeader`, and `member`.
- **Events** — draft/published events with schedules, locations, carpooling,
  capacity, difficulty, and approval-required registration. Trip leaders and
  section managers can create, edit, duplicate, and delete events.
- **Registrations** — direct or approval-based signup, waitlists, attendance
  tracking, and soft-delete withdrawal that preserves an audit trail.
- **Notifications** — in-app notification feed plus FCM push: section-wide
  topic broadcasts for new events and targeted alerts for registration changes.
- **Templates** — admin-managed markdown snippets that can be inserted into
  event descriptions.
- **Waiver** — annual liability waiver acceptance enforced by the router guard.

## Tech stack

| Layer | Choice |
|---|---|
| UI | Flutter (web, Android, iOS, macOS) |
| Routing | [`kaisel`](https://pub.dev/packages/kaisel) |
| State | `bloc_signals` |
| Models | `freezed` + `json_serializable` in `packages/shared_models` |
| Auth / data | Firebase Auth, Cloud Firestore |
| Push | Firebase Cloud Messaging |
| Backend | Dart Cloud Functions (`functions/`) |
| Admin tooling | Dart CLI in `packages/aclub_admin` |

## Quick start

```bash
flutter pub get
(cd functions && dart pub get)
./em                              # start Firebase emulators (Auth, Firestore, Functions)
flutter run -d chrome             # debug builds connect to the emulators
```

Seed sample data:

```bash
(cd packages/aclub_admin && dart run bin/admin.dart seed)
```

Run the checks:

```bash
flutter analyze && flutter test
firebase emulators:exec --only firestore,auth \
  "bash test/rules/firestore_rules_test.sh"
```

See [docs/development.md](docs/development.md) for prerequisites, Android port
forwarding, deployment, and troubleshooting.

## Documentation

| Document | Contents |
|---|---|
| [docs/data-model.md](docs/data-model.md) | Firestore collections, fields, enums, and relationships |
| [docs/security.md](docs/security.md) | Authentication, admin claims, roles, rules matrix, known limitations |
| [docs/event-registration.md](docs/event-registration.md) | Registration states, withdrawal, re-registration, notifications |
| [docs/notifications.md](docs/notifications.md) | Channels, triggers, FCM topics, device tokens, endpoint security |
| [docs/development.md](docs/development.md) | Setup, emulators, tests, builds, deployment, admin CLI |
| [docs/facebook-login-setup.md](docs/facebook-login-setup.md) | Facebook sign-in configuration |
| [docs/review.md](docs/review.md) | Security/code review findings and remediation status |

## Project layout

```
lib/                         Flutter app (pages, cubits, repo, services)
packages/shared_models/      Models and enums shared by app and functions
packages/aclub_admin/        Admin CLI: seed data, templates, claims
packages/facebook_auth_desktop/  Vendored macOS Facebook auth plugin
functions/                   Cloud Functions and their tests
test/                        App tests
test/rules/                  Emulator security-rules tests
docs/                        Documentation
firestore.rules              Firestore security rules
storage.rules                Storage rules (deny all; Storage is unused)
```

## Roles at a glance

- **Global admin** — a Firebase Auth custom claim `{ "role": "admin" }`. Never
  stored on the user document.
- **Section manager** — `sectionRole: sectionManager` in a section's `members`
  subcollection; manages that section's membership and events.
- **Trip leader** — `sectionRole: tripLeader`; manages events and
  registrations in that section.
- **Member** — `sectionRole: member`; registers for events and manages their own
  registration.

See [docs/security.md](docs/security.md) for the full rules.

## Status and known limitations

The application is functional and the analyzer and test suite are clean. The
remaining security work is tracked in [docs/review.md](docs/review.md); the
most relevant limitations are:

- notification HTTPS endpoints still require a Cloud Run IAM lockdown;
- profile PII is readable by all signed-in users;
- draft events are readable by all section members (the UI hides them);
- event write rules are section-scoped, not event-scoped;
- email notifications and preference batching are not implemented;
- event capacity is enforced in the UI, not in security rules.
