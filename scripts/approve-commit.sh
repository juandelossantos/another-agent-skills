#!/usr/bin/env bash
# approve-commit.sh — Records user approval for commit
# Part of another-agent-skills (github.com/juandelossantos/another-agent-skills)
#
# Philosophy: The agent STOPS and waits for user approval. Once approved,
# this script records the approval mechanically. The agent cannot skip
# the "stop and wait" step — but can run this script after approval.
#
# Usage:
#   bash scripts/approve-commit.sh "commit message" "yes"    # Agent runs after user approves
#   bash scripts/approve-commit.sh "commit message"          # Interactive mode (user runs directly)

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
