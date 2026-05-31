#!/usr/bin/env bash
# approve-commit.sh — Records user approval for commit
# Part of another-agent-skills (github.com/juandelossantos/another-agent-skills)
#
# Philosophy:
# 1. The agent presents the plan → user approves the PLAN (says "yes" in chat)
# 2. The user runs this script → user approves the COMMIT (types "yes" here)
# 3. These are SEPARATE decisions. Approving the plan ≠ approving the commit.
#
# If a stale token exists, forces interactive mode to prevent auto-regeneration.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

COMMIT_MSG="${1:-}"
APPROVAL="${2:-}"
REPO_ROOT=$(git rev-parse --show-toplevel)
COMMIT_APPROVED="${REPO_ROOT}/.git/COMMIT_APPROVED"

if [[ -z "$COMMIT_MSG" ]]; then
  echo -e "${RED}Error: No commit message provided.${NC}"
  echo "Usage: bash scripts/approve-commit.sh \"feat: your message\" [yes]"
  exit 1
fi

# Check for stale token — if it exists, force interactive mode
if [[ -f "$COMMIT_APPROVED" ]]; then
  EXISTING_HASH=$(cat "$COMMIT_APPROVED" | cut -d$'\t' -f1)
  # Verify if existing token matches current message
  PAYLOAD_CHECK=$(cat "$COMMIT_APPROVED" | cut -d$'\t' -f2)
  EXPECTED_HASH=$(printf '%s\t%s' "$COMMIT_MSG" "$PAYLOAD_CHECK" | sha256sum | cut -d' ' -f1)

  if [[ "$EXISTING_HASH" != "$EXPECTED_HASH" ]]; then
    echo ""
    echo -e "${YELLOW}⚠${NC} Stale token detected. Previous approval was for a different commit."
    echo "  Regenerating requires interactive approval."
    echo ""
    APPROVAL=""  # Force interactive mode
  fi
fi

# Interactive mode (user runs directly)
if [[ -z "$APPROVAL" ]]; then
  echo ""
  echo "╔════════════════════════════════════════════╗"
  echo "║  COMMIT APPROVAL — USER GATED             ║"
  echo "╚════════════════════════════════════════════╝"
  echo ""
  echo "  Commit message: ${GREEN}${COMMIT_MSG}${NC}"
  echo ""
  echo "  Do you approve this commit?"
  echo "  Type ${GREEN}yes${NC} to approve, anything else to cancel."
  echo ""
  read -p "  > " response
else
  # Agent mode — user already approved in chat
  response="$APPROVAL"
fi

if [[ "$response" == "yes" ]]; then
  PAYLOAD=$(date +%s)
  HASH=$(printf '%s\t%s' "$COMMIT_MSG" "$PAYLOAD" | sha256sum | cut -d' ' -f1)
  printf '%s\t%s' "$HASH" "$PAYLOAD" > "$COMMIT_APPROVED"
  echo ""
  echo -e "${GREEN}✓${NC} Commit approved. Token generated."
else
  echo ""
  echo -e "${YELLOW}✗${NC} Commit cancelled. No token generated."
  exit 1
fi
