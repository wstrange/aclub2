# Eventarc Trigger Scripts

This directory contains shell automation scripts for configuring GCP Eventarc triggers to route Cloud Firestore document events to the Cloud Functions / Cloud Run endpoints in production.

## Scripts

### 1. `setup_eventarc_triggers.sh`
Configures GCP APIs, IAM permissions, service accounts, and Eventarc triggers.

#### Options:
- `--project-id=ID`: GCP project ID (default: auto-detected from `.firebaserc` or `gcloud config`).
- `--region=REGION`: GCP region (default: `us-central1`).
- `--mode=MODE`:
  - `individual` (default): Routes to dedicated endpoints (`eventcreatedhttp`, `eventupdatedhttp`, `registrationcreatedhttp`, `registrationupdatedhttp`, `registrationdeletedhttp`).
  - `unified`: Routes all triggers to the unified dispatcher endpoint `notificationtriggerhttp`.
- `--database=DB`: Firestore database ID (default: `(default)`).
- `--service-account=SA`: Service account name for Eventarc invoker (default: `eventarc-functions-invoker`).

#### Example:
```bash
./functions/scripts/setup_eventarc_triggers.sh --project-id=aclub2 --region=us-central1
```

### 2. `teardown_eventarc_triggers.sh`
Cleans up and deletes the Eventarc triggers created by `setup_eventarc_triggers.sh`.

#### Example:
```bash
./functions/scripts/teardown_eventarc_triggers.sh --project-id=aclub2 --region=us-central1
```
