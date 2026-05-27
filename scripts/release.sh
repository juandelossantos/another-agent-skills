#!/usr/bin/env bash
# release.sh — Automated semver release with VERSION + RELEASE-NOTES + git tag
#
# Usage:
#   bash scripts/release.sh          # patch bump (default)
#   bash scripts/release.sh minor    # minor bump
#   bash scripts/release.sh major    # major bump
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

# --- Determine bump type -------------------------------------------

BUMP="${1:-patch}"

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
  *)
    error "Invalid bump type: $BUMP. Use: patch, minor, or major."
    exit 1
    ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
log "New version:     v${NEW_VERSION} (${BUMP} bump)"

# --- Input release notes -------------------------------------------

NOTES_FILE=$(mktemp)
cat > "$NOTES_FILE" << EOF

Release notes for v${NEW_VERSION}:

EOF

${EDITOR:-nano} "$NOTES_FILE" 2>/dev/null || ${EDITOR:-vi} "$NOTES_FILE"

RELEASE_NOTES=$(cat "$NOTES_FILE" | tail -n +3 | sed '/^$/d' || true)
rm -f "$NOTES_FILE"

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
NEW_SECTION="## ${NEW_VERSION} (${TODAY})"
# Insert after the title line (# Release Notes)
sed -i "s/^# Release Notes/# Release Notes\n\n${NEW_SECTION}\n\n${RELEASE_NOTES}\n/" "${REPO_DIR}/RELEASE-NOTES.md"
ok "RELEASE-NOTES.md updated"

# 3. Update README.md version badge
sed -i "s/version-${CURRENT_VERSION}-blue/version-${NEW_VERSION}-blue/g; s/badge\/version-${CURRENT_VERSION}/badge\/version-${NEW_VERSION}/g" "${REPO_DIR}/README.md"
ok "README.md badge updated"

# --- Show final diff -----------------------------------------------

echo ""
log "Changes to be committed:"
echo ""
git -C "${REPO_DIR}" diff --stat
echo ""

# --- Ask for commit approval ---------------------------------------

echo -n "  Commit and tag v${NEW_VERSION}? [y/N] "
read -r COMMIT_RESPONSE
if [[ "$COMMIT_RESPONSE" != "y" && "$COMMIT_RESPONSE" != "Y" ]]; then
  warn "Release aborted."
  # Rollback changes
  git -C "${REPO_DIR}" checkout -- VERSION RELEASE-NOTES.md README.md
  ok "Rolled back. No changes made."
  exit 0
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

ok "Release v${NEW_VERSION} complete."
