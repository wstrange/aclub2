#!/usr/bin/env bash
#
# setup_eventarc_triggers.sh
#
# Configures GCP Eventarc triggers to route Firestore document events
# to the HTTPS Cloud Functions / Cloud Run services.
#
# Usage:
#   ./functions/scripts/setup_eventarc_triggers.sh [OPTIONS]
#
# Options:
#   --project-id=ID      GCP Project ID (default: read from .firebaserc or gcloud config)
#   --region=REGION      GCP Region (default: us-central1)
#   --mode=MODE          "individual" (default) to target individual endpoints,
#                        or "unified" to target notificationtriggerhttp
#   --database=DB        Firestore database name (default: (default))
#   --service-account=SA Service account name (default: eventarc-functions-invoker)
#   --help               Show this help message
#

set -euo pipefail

# ── Color helpers ─────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# ── Default parameters ────────────────────────────────────────────────────────
PROJECT_ID=""
REGION="us-central1"
MODE="individual" # "individual" or "unified"
DATABASE="(default)"
SA_NAME="eventarc-functions-invoker"

# Read PROJECT_ID from .firebaserc if present
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

if [[ -f "${REPO_ROOT}/.firebaserc" ]]; then
  DETECTED_PROJECT=$(grep -o '"default": "[^"]*"' "${REPO_ROOT}/.firebaserc" | cut -d'"' -f4 || true)
  if [[ -n "${DETECTED_PROJECT}" ]]; then
    PROJECT_ID="${DETECTED_PROJECT}"
  fi
fi

# Parse command line arguments
for arg in "$@"; do
  case $arg in
    --project-id=*)
      PROJECT_ID="${arg#*=}"
      shift
      ;;
    --region=*)
      REGION="${arg#*=}"
      shift
      ;;
    --mode=*)
      MODE="${arg#*=}"
      shift
      ;;
    --database=*)
      DATABASE="${arg#*=}"
      shift
      ;;
    --service-account=*)
      SA_NAME="${arg#*=}"
      shift
      ;;
    --help)
      sed -n '2,19p' "$0" | sed 's/^# //' | sed 's/^#//'
      exit 0
      ;;
    *)
      log_error "Unknown argument: $arg"
      exit 1
      ;;
  esac
done

if [[ -z "${PROJECT_ID}" ]]; then
  PROJECT_ID=$(gcloud config get-value project 2>/dev/null || true)
fi

if [[ -z "${PROJECT_ID}" ]]; then
  log_error "Project ID could not be determined. Please specify with --project-id=YOUR_PROJECT_ID"
  exit 1
fi

log_info "Configuring Eventarc triggers for project: ${PROJECT_ID}"
log_info "Region: ${REGION}, Database: ${DATABASE}, Mode: ${MODE}"

# ── 1. Enable required GCP services ───────────────────────────────────────────
log_info "Enabling required GCP APIs (Eventarc, Cloud Run, Cloud Functions, IAM)..."
gcloud services enable \
  eventarc.googleapis.com \
  eventarcpublishing.googleapis.com \
  run.googleapis.com \
  cloudfunctions.googleapis.com \
  iam.googleapis.com \
  --project="${PROJECT_ID}"

# ── 2. Configure Service Account for Eventarc trigger invocation ──────────────
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

log_info "Checking if service account ${SA_EMAIL} exists..."
if ! gcloud iam service-accounts describe "${SA_EMAIL}" --project="${PROJECT_ID}" >/dev/null 2>&1; then
  log_info "Creating service account ${SA_NAME}..."
  gcloud iam service-accounts create "${SA_NAME}" \
    --display-name="Eventarc Trigger Invoker for Cloud Functions" \
    --project="${PROJECT_ID}"
fi

log_info "Granting eventReceiver role to service account..."
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/eventarc.eventReceiver" \
  --condition=None >/dev/null

log_info "Granting run.invoker role to service account..."
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/run.invoker" \
  --condition=None >/dev/null

# ── 3. Helper to create or update an Eventarc trigger ──────────────────────────
create_trigger() {
  local trigger_name="$1"
  local event_type="$2"
  local doc_pattern="$3"
  local target_service="$4"
  local target_path="${5:-/}"

  log_info "Configuring trigger: ${trigger_name} -> ${target_service} (${target_path})"

  # Delete existing trigger if present to allow idempotent updates
  if gcloud eventarc triggers describe "${trigger_name}" --location="${REGION}" --project="${PROJECT_ID}" >/dev/null 2>&1; then
    log_info "Trigger ${trigger_name} already exists; updating..."
    gcloud eventarc triggers delete "${trigger_name}" \
      --location="${REGION}" \
      --project="${PROJECT_ID}" \
      --quiet
  fi

  gcloud eventarc triggers create "${trigger_name}" \
    --location="${REGION}" \
    --project="${PROJECT_ID}" \
    --event-filters="type=${event_type}" \
    --event-filters="database=${DATABASE}" \
    --event-filters-path-pattern="document=${doc_pattern}" \
    --destination-run-service="${target_service}" \
    --destination-run-path="${target_path}" \
    --destination-run-region="${REGION}" \
    --service-account="${SA_EMAIL}"

  log_success "Created trigger: ${trigger_name}"
}

# ── 4. Create triggers based on chosen mode ───────────────────────────────────
EVENTS_DOC_PATTERN="sections/{sectionId}/events/{eventId}"
REGS_DOC_PATTERN="sections/{sectionId}/events/{eventId}/registrations/{registrationId}"

if [[ "${MODE}" == "unified" ]]; then
  UNIFIED_SERVICE="notificationtriggerhttp"
  log_info "Setting up triggers routing to unified dispatcher service: ${UNIFIED_SERVICE}"

  create_trigger "event-created-trigger" \
    "google.cloud.firestore.document.v1.created" \
    "${EVENTS_DOC_PATTERN}" \
    "${UNIFIED_SERVICE}" \
    "/"

  create_trigger "event-updated-trigger" \
    "google.cloud.firestore.document.v1.updated" \
    "${EVENTS_DOC_PATTERN}" \
    "${UNIFIED_SERVICE}" \
    "/"

  create_trigger "reg-created-trigger" \
    "google.cloud.firestore.document.v1.created" \
    "${REGS_DOC_PATTERN}" \
    "${UNIFIED_SERVICE}" \
    "/"

  create_trigger "reg-updated-trigger" \
    "google.cloud.firestore.document.v1.updated" \
    "${REGS_DOC_PATTERN}" \
    "${UNIFIED_SERVICE}" \
    "/"

  create_trigger "reg-deleted-trigger" \
    "google.cloud.firestore.document.v1.deleted" \
    "${REGS_DOC_PATTERN}" \
    "${UNIFIED_SERVICE}" \
    "/"

else
  log_info "Setting up triggers routing to dedicated individual services..."

  create_trigger "event-created-trigger" \
    "google.cloud.firestore.document.v1.created" \
    "${EVENTS_DOC_PATTERN}" \
    "eventcreatedhttp" \
    "/"

  create_trigger "event-updated-trigger" \
    "google.cloud.firestore.document.v1.updated" \
    "${EVENTS_DOC_PATTERN}" \
    "eventupdatedhttp" \
    "/"

  create_trigger "reg-created-trigger" \
    "google.cloud.firestore.document.v1.created" \
    "${REGS_DOC_PATTERN}" \
    "registrationcreatedhttp" \
    "/"

  create_trigger "reg-updated-trigger" \
    "google.cloud.firestore.document.v1.updated" \
    "${REGS_DOC_PATTERN}" \
    "registrationupdatedhttp" \
    "/"

  create_trigger "reg-deleted-trigger" \
    "google.cloud.firestore.document.v1.deleted" \
    "${REGS_DOC_PATTERN}" \
    "registrationdeletedhttp" \
    "/"
fi

echo ""
log_success "All Eventarc triggers successfully configured!"
log_info "To verify trigger status in GCP, run:"
echo "  gcloud eventarc triggers list --location=${REGION} --project=${PROJECT_ID}"
