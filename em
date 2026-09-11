#!/usr/bin/env bash
pkill -f 'firebase emulators:start' || true
firebase emulators:start --import=./tmp/ --export-on-exit