#!/usr/bin/env bash
set -euo pipefail

# Ensure flutter, dart, and firebase CLI are in PATH
export PATH="$HOME/dev/flutter/bin:$HOME/development/flutter/bin:$HOME/flutter/bin:$HOME/.fvm/default/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check prerequisites
if ! command -v flutter &>/dev/null; then
  echo "❌ Error: 'flutter' not found in PATH." >&2
  echo "   Add Flutter to your PATH (e.g. export PATH=\"\$HOME/dev/flutter/bin:\$PATH\")" >&2
  exit 1
fi

if ! command -v firebase &>/dev/null; then
  echo "❌ Error: 'firebase' CLI not found." >&2
  echo "   Install via: brew install firebase-cli or npm install -g firebase-tools" >&2
  exit 1
fi

TARGET="hosting"
if [[ "${1:-}" == "--all" ]]; then
  TARGET=""
fi

echo "=========================================="
echo " Publishing aclub2 Web App to Firebase"
echo "=========================================="
echo ""

echo "🔨 Step 1/2: Building Flutter Web (Release)..."
flutter build web --release

echo ""
if [[ -n "$TARGET" ]]; then
  echo "🚀 Step 2/2: Deploying to Firebase Hosting..."
  firebase deploy --only hosting
else
  echo "🚀 Step 2/2: Deploying all targets (Hosting, Rules, Functions)..."
  firebase deploy --except storage,artifactregistry
fi

echo ""
echo "=========================================="
echo " 🎉 Published successfully!"
echo " 🌐 https://aclub2.web.app"
echo " 🌐 https://aclub2.firebaseapp.com"
echo "=========================================="
