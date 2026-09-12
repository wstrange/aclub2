#!/usr/bin/env bash
pkill -f 'firebase emulators:start' || true
lsof -ti :8080 | xargs kill  2>/dev/null || true

# This configures the android usb device / emulator to forward ports 8080 and 9099 to the host machine

~/Library/Android/sdk/platform-tools/adb reverse tcp:9099 tcp:9099
~/Library/Android/sdk/platform-tools/adb reverse tcp:8080 tcp:8080


firebase emulators:start --import=./tmp/ --export-on-exit