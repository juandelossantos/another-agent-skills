#!/usr/bin/env bash
# approve-commit.sh — Records user approval for commit
# Part of another-agent-skills (github.com/juandelossantos/another-agent-skills)
#
# Philosophy:
# 1. The agent presents the plan → user approves the PLAN (says "yes" in chat)
# 2. The user says "yes commit" in chat → agent runs this script with --auto
# 3. These are SEPARATE decisions. Approving the plan ≠ approving the commit.
#
# Modes:
#   Interactive (default): User runs directly, types "yes" in terminal
#   Auto (--auto): Agent runs after user said "yes commit" in chat, no prompt

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

COMMIT_MSG="${1:-}"
AUTO_MODE="${2:-}"
REPO_ROOT=$(git rev-parse --show-toplevel)
COMMIT_APPROVED="${REPO_ROOT}/.git/COMMIT_APPROVED"

if [[ -z "$COMMIT_MSG" ]]; then
  echo -e "${RED}Error: No commit message provided.${NC}"
  echo "Usage: bash scripts/approve-commit.sh \"feat: your message\" [--auto]"
  echo ""
  echo "  Interactive: User runs directly, types 'yes' in terminal"
  echo "  Auto: Agent runs after user said 'yes commit' in chat"
  exit 1
fi

# Check for stale token — if it exists, warn
if [[ -f "$COMMIT_APPROVED" ]]; then
  EXISTING_HASH=$(cat "$COMMIT_APPROVED" | cut -d$'\t' -f1)
  PAYLOAD_CHECK=$(cat "$COMMIT_APPROVED" | cut -d$'\t' -f2)
  EXPECTED_HASH=$(printf '%s\t%s' "$COMMIT_MSG" "$PAYLOAD_CHECK" | sha256sum | cut -d' ' -f1)

  if [[ "$EXISTING_HASH" != "$EXPECTED_HASH" ]]; then
    echo ""
    echo -e "${YELLOW}⚠${NC} Stale token detected. Previous approval was for a different commit."
    echo "  Regenerating with new approval."
    echo ""
  fi
fi

if [[ "$AUTO_MODE" == "--auto" ]]; then
  # Auto mode: agent runs after user said "yes commit" in chat
  # No interactive prompt — approval is in chat history
  PAYLOAD=$(date +%s)
  HASH=$(printf '%s\t%s' "$COMMIT_MSG" "$PAYLOAD" | sha256sum | cut -d' ' -f1)
  printf '%s\t%s' "$HASH" "$PAYLOAD" > "$COMMIT_APPROVED"
  echo ""
  echo -e "${GREEN}✓${NC} Commit approved (auto). Token generated."
  echo "  Message: ${GREEN}${COMMIT_MSG}${NC}"
  echo "  ${YELLOW}Audit trail: User said 'yes commit' in chat before this script ran.${NC}"
else
  # Interactive mode: user runs directly, types "yes" in terminal
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
fi
