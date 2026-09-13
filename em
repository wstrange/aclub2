#!/usr/bin/env bash
pkill -HUP -f 'firebase emulators:start' || true
lsof -ti :8080 | xargs kill  2>/dev/null || true

# This configures the android usb device / emulator to forward ports 8080 and 9099 to the host machine




firebase emulators:start --import=./tmp/ --export-on-exit