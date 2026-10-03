#!/usr/bin/env bash
#
# teardown_eventarc_triggers.sh
#
# Deletes Eventarc triggers created for Cloud Functions.
#
# Usage:
#   ./functions/scripts/teardown_eventarc_triggers.sh [OPTIONS]
#
# Options:
#   --project-id=ID      GCP Project ID (default: read from .firebaserc or gcloud config)
#   --region=REGION      GCP Region (default: us-central1)
#   --help               Show this help message
#

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

PROJECT_ID=""
REGION="us-central1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

if [[ -f "${REPO_ROOT}/.firebaserc" ]]; then
  DETECTED_PROJECT=$(grep -o '"default": "[^"]*"' "${REPO_ROOT}/.firebaserc" | cut -d'"' -f4 || true)
  if [[ -n "${DETECTED_PROJECT}" ]]; then
    PROJECT_ID="${DETECTED_PROJECT}"
  fi
fi

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
    --help)
      sed -n '2,15p' "$0" | sed 's/^# //' | sed 's/^#//'
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
  log_error "Project ID could not be determined."
  exit 1
fi

TRIGGERS=(
  "event-created-trigger"
  "event-updated-trigger"
  "reg-created-trigger"
  "reg-updated-trigger"
  "reg-deleted-trigger"
)

log_info "Deleting Eventarc triggers for project ${PROJECT_ID} in ${REGION}..."

for trigger in "${TRIGGERS[@]}"; do
  if gcloud eventarc triggers describe "${trigger}" --location="${REGION}" --project="${PROJECT_ID}" >/dev/null 2>&1; then
    log_info "Deleting trigger: ${trigger}..."
    gcloud eventarc triggers delete "${trigger}" \
      --location="${REGION}" \
      --project="${PROJECT_ID}" \
      --quiet
    log_success "Deleted: ${trigger}"
  else
    log_info "Trigger ${trigger} does not exist. Skipping."
  fi
done

log_success "Teardown complete!"
