#!/usr/bin/env bash
# Re-applies the upstream SPM pin patch for google_sign_in_ios.
#
# WHY THIS EXISTS (late 2026):
#   firebase-ios-sdk 13.1.x (pulled by firebase_core 5.1+) depends on
#   gtm-session-fetcher 4.x..<6.x, while GoogleSignIn-iOS 9.x — the version
#   range google_sign_in_ios 6.3.8 pins via `from: "9.0.0"` — depends on
#   gtm-session-fetcher 3.x. Xcode's SPM resolver refuses incompatible major
#   versions, so `flutter build` on iOS/macOS fails with
#   "Could not resolve package dependencies".
#
#   GoogleSignIn-iOS 10.0.0 widened its GTMSessionFetcher dependency to allow
#   4.x/5.x (and raised min iOS 15.0 / macOS 12.0 — this project already
#   targets those). This script repins google_sign_in_ios' local pub-cache
#   Package.swift to `from: "10.0.0"` plus the matching platform minimums,
#   which unlocks the resolver. The plugin's Swift wrapper compiles fine
#   against GoogleSignIn-iOS 10.
#
# VERIFY BEFORE USING: patch first, then run `flutter build macos --debug`.
#
# WHEN TO DELETE: once google_sign_in_ios releases a version pinning
# GoogleSignIn-iOS >= 10 (or firebase-ios-sdk relaxes GTMSessionFetcher),
# run `flutter pub cache repair`-equivalent or bump the version here and
# remove this script.
#
# NOTE: pub may overwrite the cache (e.g. `flutter pub cache repair`,
# pub get after cache clean). Re-run this script after that, or wire it in
# before `flutter build`/`flutter run` in CI.
set -euo pipefail

pub_cache="${PUB_CACHE:-$HOME/.pub-cache}/hosted/pub.dev"

# Find the installed google_sign_in_ios version(s); patch the newest one.
latest=""
for dir in "$pub_cache"/google_sign_in_ios-*; do
  [[ -e "$dir" ]] || continue
  latest="$dir"
done
if [[ -z "$latest" ]]; then
  echo "google_sign_in_ios not found in pub cache at $pub_cache"
  exit 1
fi
pkg_dir="$latest/darwin/google_sign_in_ios"
pkg="$pkg_dir/Package.swift"

if grep -q 'from: "10.0.0"' "$pkg"; then
  echo "Already patched: $pkg"
  exit 0
fi

tmp="$(mktemp)"
sed -E \
  -e 's/\.iOS\("13\.0"\)/.iOS("15.0")/' \
  -e 's/\.macOS\("10\.15"\)/.macOS("12.0")/' \
  -e 's/from: "9\.0\.0"/from: "10.0.0"/' \
  "$pkg" > "$tmp"
mv "$tmp" "$pkg"
echo "Patched $pkg (GoogleSignIn-iOS 10.0.0, iOS 15.0, macOS 12.0)"
echo "Now run: flutter build <ios|macos> --debug to update Package.resolved"
