#!/usr/bin/env bash
# Gracefully stops the Firebase emulator suite.
#
# Sends SIGINT (the equivalent of Ctrl+C) to the `firebase emulators:start`
# process so it performs its graceful shutdown, including the data export to
# ./tmp/ (the --export-on-exit flag used by `em`). Falls back to SIGTERM /
# SIGKILL if the shutdown hangs, then frees the standard emulator ports.
#
# Usage: ./stop-emulator.sh [timeout_seconds]

set -u

EXPORT_DIR="./tmp"
TIMEOUT_SECONDS="${1:-30}"

FIREBASE_PID=$(pgrep -f 'firebase emulators:start' | head -n1)

if [ -z "$FIREBASE_PID" ]; then
  echo "No running 'firebase emulators:start' process found."
  if lsof -ti :8080,9099,4000,5001 2>/dev/null | grep -q .; then
    echo "Stray emulator processes detected on standard ports; killing..."
    lsof -ti :8080,9099,4000,5001 | xargs kill 2>/dev/null || true
  fi
  exit 0
fi

echo "Gracefully stopping Firebase emulators (PID $FIREBASE_PID, export to ./$EXPORT_DIR)..."

# SIGINT triggers firebase's clean shutdown handler, including --export-on-exit.
kill -INT "$FIREBASE_PID"

waited=0
while kill -0 "$FIREBASE_PID" 2>/dev/null; do
  if [ "$waited" -ge "$TIMEOUT_SECONDS" ]; then
    echo "Timed out after ${TIMEOUT_SECONDS}s; sending SIGTERM..."
    kill -TERM "$FIREBASE_PID"
    sleep 3
    if kill -0 "$FIREBASE_PID" 2>/dev/null; then
      echo "Still alive; sending SIGKILL (export may be incomplete)..."
      kill -KILL "$FIREBASE_PID"
    fi
    break
  fi
  sleep 1
  waited=$((waited + 1))
done

# Clear any leftover emulator child processes.
if pgrep -f 'cloud-firestore-emulator|pubsub-emulator|firebase emulators:start' >/dev/null; then
  echo "Cleaning up remaining emulator processes..."
  pkill -f 'cloud-firestore-emulator' 2>/dev/null || true
  pkill -f 'pubsub-emulator' 2>/dev/null || true
  pkill -f 'firebase emulators:start' 2>/dev/null || true
fi

# Verify the standard emulator ports are free.
if lsof -ti :8080,9099,4000,5001 2>/dev/null | grep -q .; then
  echo "Ports 8080/9099/4000/5001 still in use; freeing them..."
  lsof -ti :8080,9099,4000,5001 | xargs kill 2>/dev/null || true
fi

echo "Emulator stopped."