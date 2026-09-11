#!/usr/bin/env bash
pkill -f 'firebase emulators:start' || true
lsof -ti :8080 | xargs kill  2>/dev/null || true
firebase emulators:start --import=./tmp/ --export-on-exit