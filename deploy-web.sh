#!/usr/bin/env bash
# ==============================================================================
# Deploy Script: Flutter Web App -> Firebase Hosting
# Project: aclub2
# ==============================================================================
set -euo pipefail

# Text formatting
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Defaults
PROJECT_ID="aclub2"
DEPLOY_TARGET="live"
PREVIEW_CHANNEL=""
SKIP_BUILD=false
WASM_BUILD=false
DRY_RUN=false
AUTO_CONFIRM=false
BASE_HREF="/"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ------------------------------------------------------------------------------
# Help message
# ------------------------------------------------------------------------------
show_help() {
  echo -e "${BOLD}Deploy Script for Flutter Web (Firebase Hosting)${NC}

${BOLD}USAGE:${NC}
  ./deploy-web.sh [OPTIONS]

${BOLD}OPTIONS:${NC}
  -l, --live, --prod          Deploy to live production site (default)
  -p, --preview [CHANNEL]     Deploy to a preview channel instead of live production
                              (defaults to current git branch name)
  -s, --skip-build            Skip 'flutter build web' and deploy existing build/web
  -w, --wasm                  Build with WebAssembly support (--wasm)
  -b, --base-href <PATH>      Set base href for Flutter build (default: /)
  --project <ID>              Override Firebase project ID (default: aclub2)
  -y, --yes                   Skip interactive confirmation prompts
  -d, --dry-run               Run build and validations without deploying
  -h, --help                  Show this help message

${BOLD}EXAMPLES:${NC}
  ./deploy-web.sh                     # Build and deploy to live production
  ./deploy-web.sh -y                  # Deploy to live without prompting
  ./deploy-web.sh -p                  # Deploy to preview channel named after current branch
  ./deploy-web.sh -p feature-test     # Deploy to preview channel 'feature-test'
  ./deploy-web.sh -s                  # Deploy existing build without rebuilding
  ./deploy-web.sh -w                  # Build with WebAssembly and deploy"
  exit 0
}

# ------------------------------------------------------------------------------
# Parse arguments
# ------------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_help
      ;;
    -l|--live|--prod)
      DEPLOY_TARGET="live"
      shift
      ;;
    -p|--preview)
      DEPLOY_TARGET="preview"
      # If the next token exists and does not start with '-', use it as channel name
      if [[ $# -gt 1 && ! "$2" =~ ^- ]]; then
        PREVIEW_CHANNEL="$2"
        shift 2
      else
        shift
      fi
      ;;
    -s|--skip-build)
      SKIP_BUILD=true
      shift
      ;;
    -w|--wasm)
      WASM_BUILD=true
      shift
      ;;
    -b|--base-href)
      if [[ $# -gt 1 && ! "$2" =~ ^- ]]; then
        BASE_HREF="$2"
        shift 2
      else
        echo -e "${RED}Error: --base-href requires an argument.${NC}" >&2
        exit 1
      fi
      ;;
    --project)
      if [[ $# -gt 1 && ! "$2" =~ ^- ]]; then
        PROJECT_ID="$2"
        shift 2
      else
        echo -e "${RED}Error: --project requires a project ID.${NC}" >&2
        exit 1
      fi
      ;;
    -y|--yes)
      AUTO_CONFIRM=true
      shift
      ;;
    -d|--dry-run)
      DRY_RUN=true
      shift
      ;;
    *)
      echo -e "${RED}Unknown argument: $1${NC}" >&2
      echo "Run './deploy-web.sh --help' for usage." >&2
      exit 1
      ;;
  esac
done

# If preview mode and no channel provided, default to git branch name or 'preview'
if [[ "$DEPLOY_TARGET" == "preview" && -z "$PREVIEW_CHANNEL" ]]; then
  if command -v git &>/dev/null && git rev-parse --is-inside-work-tree &>/dev/null; then
    GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null | tr '/.' '-' || true)"
    PREVIEW_CHANNEL="${GIT_BRANCH:-preview}"
  else
    PREVIEW_CHANNEL="preview"
  fi
fi

# ------------------------------------------------------------------------------
# Find & Verify Flutter
# ------------------------------------------------------------------------------
FLUTTER_CMD=""
if command -v flutter &>/dev/null; then
  FLUTTER_CMD="$(command -v flutter)"
else
  # Check common macOS / developer install locations
  CANDIDATE_PATHS=(
    "$HOME/dev/flutter/bin/flutter"
    "$HOME/development/flutter/bin/flutter"
    "$HOME/flutter/bin/flutter"
    "$HOME/src/flutter/bin/flutter"
    "$HOME/.fvm/default/bin/flutter"
    "/opt/homebrew/bin/flutter"
    "/usr/local/bin/flutter"
    "$HOME/.flutter/bin/flutter"
  )
  for candidate in "${CANDIDATE_PATHS[@]}"; do
    if [[ -x "$candidate" ]]; then
      FLUTTER_CMD="$candidate"
      export PATH="$(dirname "$candidate"):$PATH"
      break
    fi
  done
fi

if [[ "$SKIP_BUILD" == false && -z "$FLUTTER_CMD" ]]; then
  echo -e "${RED}Error: Flutter SDK not found in PATH or standard locations.${NC}" >&2
  echo -e "Please ensure Flutter is installed and added to your PATH, e.g.:" >&2
  echo -e "  export PATH=\"\$HOME/development/flutter/bin:\$PATH\"" >&2
  exit 1
fi

# ------------------------------------------------------------------------------
# Find & Verify Firebase CLI
# ------------------------------------------------------------------------------
FIREBASE_CMD=""
if command -v firebase &>/dev/null; then
  FIREBASE_CMD="$(command -v firebase)"
elif [[ -x "/opt/homebrew/bin/firebase" ]]; then
  FIREBASE_CMD="/opt/homebrew/bin/firebase"
elif [[ -x "/usr/local/bin/firebase" ]]; then
  FIREBASE_CMD="/usr/local/bin/firebase"
elif command -v npx &>/dev/null; then
  FIREBASE_CMD="npx firebase-tools"
else
  echo -e "${RED}Error: Firebase CLI not found.${NC}" >&2
  echo -e "Please install it via: npm install -g firebase-tools or brew install firebase-cli" >&2
  exit 1
fi

# ------------------------------------------------------------------------------
# Pre-flight Summary
# ------------------------------------------------------------------------------
echo -e "${BOLD}${CYAN}====================================================${NC}"
echo -e "${BOLD}${CYAN}   Flutter Web App Deployment -> Firebase Hosting   ${NC}"
echo -e "${BOLD}${CYAN}====================================================${NC}"
echo -e "Project:       ${BOLD}${PROJECT_ID}${NC}"
if [[ "$DEPLOY_TARGET" == "live" ]]; then
  echo -e "Target:        ${GREEN}${BOLD}LIVE (Production)${NC}"
else
  echo -e "Target:        ${YELLOW}${BOLD}PREVIEW CHANNEL: ${PREVIEW_CHANNEL}${NC}"
fi
echo -e "Build:         $([[ "$SKIP_BUILD" == true ]] && echo "${YELLOW}Skipped (using existing build/web)${NC}" || echo "${GREEN}flutter build web --release${NC}")"
if [[ "$WASM_BUILD" == true ]]; then
  echo -e "Wasm Mode:     ${GREEN}Enabled (--wasm)${NC}"
fi
if [[ "$DRY_RUN" == true ]]; then
  echo -e "Dry Run:       ${YELLOW}Enabled (will not deploy)${NC}"
fi
echo -e "${CYAN}----------------------------------------------------${NC}"

# Confirmation for live deploy
if [[ "$DEPLOY_TARGET" == "live" && "$AUTO_CONFIRM" == false && "$DRY_RUN" == false ]]; then
  read -r -p "Deploy live to project '${PROJECT_ID}'? [y/N] " response
  case "$response" in
    [yY][eE][sS]|[yY])
      ;;
    *)
      echo -e "${YELLOW}Deployment cancelled.${NC}"
      exit 0
      ;;
  esac
fi

START_TIME=$(date +%s)

# ------------------------------------------------------------------------------
# Step 1: Flutter Build
# ------------------------------------------------------------------------------
if [[ "$SKIP_BUILD" == false ]]; then
  echo -e "\n${BLUE}${BOLD}[1/2] Building Flutter Web App...${NC}"

  BUILD_ARGS=("build" "web" "--release" "--base-href" "$BASE_HREF")
  if [[ "$WASM_BUILD" == true ]]; then
    BUILD_ARGS+=("--wasm")
  fi

  echo -e "Running: ${CYAN}flutter ${BUILD_ARGS[*]}${NC}"
  "$FLUTTER_CMD" "${BUILD_ARGS[@]}"

  # Verify build artifacts
  if [[ ! -f "build/web/index.html" ]]; then
    echo -e "${RED}Error: build/web/index.html was not generated! Build failed.${NC}" >&2
    exit 1
  fi

  BUILD_SIZE="$(du -sh build/web 2>/dev/null | cut -f1 || echo "unknown")"
  echo -e "${GREEN}✓ Build succeeded! Output size: ${BUILD_SIZE}${NC}"
else
  echo -e "\n${YELLOW}${BOLD}[1/2] Skipping build step (using existing build/web)${NC}"
  if [[ ! -f "build/web/index.html" ]]; then
    echo -e "${RED}Error: build/web/index.html does not exist. Please run without -s first.${NC}" >&2
    exit 1
  fi
fi

# ------------------------------------------------------------------------------
# Step 2: Firebase Hosting Deploy
# ------------------------------------------------------------------------------
if [[ "$DRY_RUN" == true ]]; then
  echo -e "\n${YELLOW}${BOLD}[2/2] Dry run complete. Deployment skipped.${NC}"
  exit 0
fi

echo -e "\n${BLUE}${BOLD}[2/2] Deploying to Firebase Hosting...${NC}"

if [[ "$DEPLOY_TARGET" == "live" ]]; then
  echo -e "Running: ${CYAN}firebase deploy --only hosting --project $PROJECT_ID${NC}"
  $FIREBASE_CMD deploy --only hosting --project "$PROJECT_ID"
else
  echo -e "Running: ${CYAN}firebase hosting:channel:deploy $PREVIEW_CHANNEL --project $PROJECT_ID${NC}"
  $FIREBASE_CMD hosting:channel:deploy "$PREVIEW_CHANNEL" --project "$PROJECT_ID"
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo -e "\n${BOLD}${GREEN}====================================================${NC}"
echo -e "${BOLD}${GREEN}   ✓ Deployment Completed Successfully! (${DURATION}s)    ${NC}"
echo -e "${BOLD}${GREEN}====================================================${NC}"
if [[ "$DEPLOY_TARGET" == "live" ]]; then
  echo -e "Live URL: ${BOLD}https://${PROJECT_ID}.web.app${NC} / ${BOLD}https://${PROJECT_ID}.firebaseapp.com${NC}"
fi
echo ""
