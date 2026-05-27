#!/usr/bin/env bash
# release.sh — Automated semver release with VERSION + RELEASE-NOTES + git tag
#
# Usage:
#   bash scripts/release.sh              # patch bump (default, interactive)
#   bash scripts/release.sh minor        # minor bump
#   bash scripts/release.sh major        # major bump
#   bash scripts/release.sh minor -y     # non-interactive (auto-commit + auto-push)
#
# Pre-conditions:
#   - Working tree clean (git diff --stat must be empty)
#   - VERSION file exists
#
# Post-conditions:
#   - VERSION updated
#   - RELEASE-NOTES.md updated
#   - README.md version badge updated
#   - Commit + annotated tag created (only after user approval)
#   - Push (only after separate user approval)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log()   { echo -e "${BLUE}[release]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# --- Guards ---------------------------------------------------------

if [[ ! -f "${REPO_DIR}/VERSION" ]]; then
  error "VERSION file not found at ${REPO_DIR}/VERSION"
  exit 1
fi

if [[ ! -f "${REPO_DIR}/RELEASE-NOTES.md" ]]; then
  error "RELEASE-NOTES.md not found at ${REPO_DIR}/RELEASE-NOTES.md"
  exit 1
fi

if [[ -n "$(git -C "${REPO_DIR}" diff --stat)" ]]; then
  error "Working tree has uncommitted changes. Commit or stash before releasing."
  git -C "${REPO_DIR}" diff --stat
  exit 1
fi

# --- Parse current version ------------------------------------------

CURRENT_VERSION=$(cat "${REPO_DIR}/VERSION" | tr -d '[:space:]')
log "Current version: v${CURRENT_VERSION}"

# Validate semver: X.Y.Z
if ! echo "$CURRENT_VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  error "VERSION must be semver (X.Y.Z). Got: ${CURRENT_VERSION}"
  exit 1
fi

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# --- Parse arguments ------------------------------------------------

BUMP="patch"
RELEASE_NOTES=""
YES_FLAG=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -m|--message)
      RELEASE_NOTES="$2"
      shift 2
      ;;
    -y|--yes)
      YES_FLAG=true
      shift
      ;;
    patch|minor|major)
      BUMP="$1"
      shift
      ;;
    *)
      error "Unknown argument: $1. Usage: release.sh [-m 'notes'] [-y] [patch|minor|major]"
      exit 1
      ;;
  esac
done

case "$BUMP" in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH + 1))
    ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
log "New version:     v${NEW_VERSION} (${BUMP} bump)"

# --- Input release notes (if not provided via -m) -------------------

if [[ -z "$RELEASE_NOTES" ]]; then
  echo ""
  log "Enter release notes (end with Ctrl+D or empty line):"
  echo ""
  NOTES_LINES=()
  while IFS= read -r LINE; do
    [[ -z "$LINE" ]] && break
    NOTES_LINES+=("$LINE")
  done
  RELEASE_NOTES=$(printf '%s\n' "${NOTES_LINES[@]}")
fi

if [[ -z "$RELEASE_NOTES" ]]; then
  warn "No release notes provided. Proceeding with empty notes."
  RELEASE_NOTES="Bug fixes and improvements."
fi

# --- Show summary before applying ----------------------------------

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  Release Summary"
echo "═══════════════════════════════════════════════════════"
echo "  v${CURRENT_VERSION} → v${NEW_VERSION} (${BUMP})"
echo ""
echo "  Notes:"
while IFS= read -r line; do
  echo "    ${line}"
done <<< "$RELEASE_NOTES"
echo "═══════════════════════════════════════════════════════"
echo ""

# --- Apply changes ------------------------------------------------

# 1. Update VERSION file
echo -n "$NEW_VERSION" > "${REPO_DIR}/VERSION"
ok "VERSION updated to v${NEW_VERSION}"

# 2. Update RELEASE-NOTES.md
TODAY=$(date +%Y-%m-%d)
NOTES_FILE=$(mktemp)
{
  echo "# Release Notes"
  echo ""
  echo "## ${NEW_VERSION} (${TODAY})"
  echo ""
  echo "${RELEASE_NOTES}"
  echo ""
  tail -n +2 "${REPO_DIR}/RELEASE-NOTES.md"
} > "$NOTES_FILE"
mv "$NOTES_FILE" "${REPO_DIR}/RELEASE-NOTES.md"
ok "RELEASE-NOTES.md updated"

# 3. Update README.md version badge (escape dots for sed)
CURRENT_ESC=$(echo "$CURRENT_VERSION" | sed 's/\./\\./g')
NEW_ESC=$(echo "$NEW_VERSION" | sed 's/\./\\./g')
sed -i "s/version-${CURRENT_ESC}-blue/version-${NEW_ESC}-blue/g" "${REPO_DIR}/README.md"
sed -i "s|badge/version-${CURRENT_ESC}|badge/version-${NEW_ESC}|g" "${REPO_DIR}/README.md"
sed -i "s/Version: v${CURRENT_ESC}/Version: v${NEW_ESC}/g" "${REPO_DIR}/README.md"
ok "README.md badge updated"

# --- Show final diff -----------------------------------------------

echo ""
log "Changes to be committed:"
echo ""
git -C "${REPO_DIR}" diff --stat
echo ""

# --- Ask for commit approval ---------------------------------------

if [[ "$YES_FLAG" == false ]]; then
  echo -n "  Commit and tag v${NEW_VERSION}? [y/N] "
  read -r COMMIT_RESPONSE
  if [[ "$COMMIT_RESPONSE" != "y" && "$COMMIT_RESPONSE" != "Y" ]]; then
    warn "Release aborted."
    git -C "${REPO_DIR}" checkout -- VERSION RELEASE-NOTES.md README.md
    ok "Rolled back. No changes made."
    exit 0
  fi
fi

# --- Commit + Tag --------------------------------------------------

TAG_MSG="v${NEW_VERSION}

${RELEASE_NOTES}"

git -C "${REPO_DIR}" add VERSION RELEASE-NOTES.md README.md
date +%s > "${REPO_DIR}/.git/COMMIT_APPROVED"
git -C "${REPO_DIR}" commit -m "release: v${NEW_VERSION}

${RELEASE_NOTES}"
git -C "${REPO_DIR}" tag -a "v${NEW_VERSION}" -m "$TAG_MSG"

ok "Commit and tag v${NEW_VERSION} created."

# --- Ask for push --------------------------------------------------

if [[ "$YES_FLAG" == true ]]; then
  git -C "${REPO_DIR}" push origin main
  git -C "${REPO_DIR}" push origin "v${NEW_VERSION}"
  ok "Pushed to origin."
else
  echo ""
  echo -n "  Push commit and tag to origin? [y/N] "
  read -r PUSH_RESPONSE
  if [[ "$PUSH_RESPONSE" == "y" || "$PUSH_RESPONSE" == "Y" ]]; then
    git -C "${REPO_DIR}" push origin main
    git -C "${REPO_DIR}" push origin "v${NEW_VERSION}"
    ok "Pushed to origin."
  else
    log "Skipped push. You can push later:"
    log "  git push origin main && git push origin v${NEW_VERSION}"
  fi
fi

ok "Release v${NEW_VERSION} complete."
