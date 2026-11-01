# Development guide

## Prerequisites

- Flutter SDK with Dart `>=3.13` (`flutter --version`)
- `firebase-tools` (`npm install -g firebase-tools` or `brew install firebase-cli`)
- `jq` and `curl` for the rules test script
- Optional: an Android emulator/device or Xcode for native builds

The repository is a Flutter app with two path packages and a Cloud Functions
package:

```
lib/                         Flutter app
packages/shared_models/      Pure-Dart models shared by app + functions
packages/aclub_admin/        Admin CLI (seed data, templates, claims)
packages/facebook_auth_desktop/  Vendored Facebook auth plugin for macOS
functions/                   Cloud Functions (Dart)
test/                        App tests
test/rules/                  Emulator security-rules tests
docs/                        Documentation
```

## Setup

```bash
flutter pub get
(cd functions && dart pub get)
(cd packages/shared_models && dart pub get)
(cd packages/aclub_admin && dart pub get)
```

Generate code after changing a `freezed` model (run inside the package that
owns the model, e.g. `packages/shared_models` or the app root):

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Dependency layout

`shared_models` is consumed as a **path dependency** by the app, `functions`,
and `aclub_admin`:

```yaml
shared_models:
  path: packages/shared_models   # ../packages/shared_models from subprojects
```

This is deliberate. The app is a Flutter package, `functions` is a pure-Dart
package, and the admin CLI has its own toolchain; keeping separate lockfiles
lets each resolve its own SDK constraints without forcing a single pub
workspace. Run `pub get` in each package after changing a shared dependency
(see [Setup](#setup)).

A `resolution: workspace` setup was considered and rejected: it would require
every package to share one SDK constraint and would churn all lockfiles for no
functional benefit. The vendored `facebook_auth_desktop` is the only
`dependency_overrides` entry, and it exists because the published plugin ships
only CocoaPods metadata (see `packages/facebook_auth_desktop/README.md`).

## Firebase emulators

Debug builds (`kDebugMode`) automatically connect Auth to `localhost:9099` and
Firestore to `localhost:8080`; release builds use the configured Firebase
project (`lib/firebase_options.dart`).

Start the suite with data import/export:

```bash
./em                 # firebase emulators:start --import=./tmp/ --export-on-exit
./stop-emulator.sh   # graceful shutdown + export
./k.sh               # kill stray emulator processes on the standard ports
```

Emulator ports: Auth `9099`, Firestore `8080`, Functions `5001`, Storage
`9199`, UI `4000`.

### Android device / emulator

Debug builds resolve the emulator host automatically: `10.0.2.2` on the
Android emulator, `localhost` elsewhere. For a physical Android device
connected over USB, forward the emulator ports and point the app at
`localhost`:

```bash
./adb_fix
flutter run --dart-define=EMULATOR_HOST=localhost
# or manually:
adb reverse tcp:9099 tcp:9099
adb reverse tcp:8080 tcp:8080
```

### Seed data

```bash
(cd packages/aclub_admin && dart run bin/admin.dart seed)
```

Use `--prod` to target the real project instead of the emulator. Other commands
include `reset`, `stats`, `list-sections`, `list-events`, and `templates`.

## Running the app

```bash
flutter run -d chrome
flutter run -d macos
flutter run -d <android-device-id>
```

## Tests and analysis

```bash
flutter analyze
flutter test

(cd functions && dart analyze && dart test)
(cd packages/shared_models && dart analyze)
(cd packages/aclub_admin && dart analyze && dart test)
```

### Security-rules tests

The rules suite talks to the Firestore/Auth emulator REST API directly, so the
app does not need to be running:

```bash
firebase emulators:exec --only firestore,auth \
  "bash test/rules/firestore_rules_test.sh"
```

It currently runs 37 checks covering section membership, event registration,
templates, section-creation authorization, and notification ownership. See
`docs/security.md`.

## Building and deploying

### Web

```bash
./deploy-web.sh --help
./deploy-web.sh                 # build + deploy to live Hosting
./deploy-web.sh --preview pr-1  # preview channel
./deploy-web.sh --dry-run       # build and validate only
./deploy-web.sh --wasm          # WebAssembly build
```

`publish.sh` is a thin wrapper that publishes Hosting (or everything with
`--all`).

GitHub Actions deploy Hosting automatically:

- `.github/workflows/firebase-hosting-merge.yml` on push to `main`;
- `.github/workflows/firebase-hosting-pull-request.yml` for previews.

Neither workflow runs `flutter analyze`, `flutter test`, or the rules suite.

### Firebase services

```bash
firebase deploy --only firestore:rules,storage
firebase deploy --only functions
```

Before deploying functions, read the Cloud Run IAM note in
`docs/notifications.md`: the notification services must not be invokable by
`allUsers`.

### Android APK

```bash
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

## Admin CLI

`packages/aclub_admin` seeds sample sections, users, events, and templates and
manages templates. Admin claims are set with the Admin SDK; see
`packages/aclub_admin/bin/claims.dart` and `docs/security.md`.

## Troubleshooting

- **Blank screen in release** — bootstrap failures render a diagnostic error
  screen; check the console logs.
- **Emulator permission denied on first listen** — a known Firestore emulator
  quirk with `get()`/`exists()` inside rules; the immediate re-evaluation
  succeeds. Real Firestore is consistent. See the note in `firestore.rules`.
- **Stale auth user after reseeding** — the router guard signs out users whose
  token no longer resolves instead of crashing.
- **FCM push not delivered in the emulator** — expected: there is no FCM
  emulator. The functions log what they would have sent; in-app notifications
  are still written.
