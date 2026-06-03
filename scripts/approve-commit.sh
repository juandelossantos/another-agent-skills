#!/usr/bin/env bash
# approve-commit.sh — Records user approval for commit
# Part of another-agent-skills (github.com/juandelossantos/another-agent-skills)
#
# Philosophy:
# 1. The agent presents the plan → user approves the PLAN (says "yes" in chat)
# 2. The user says "yes commit" in chat → agent runs this script with --auto
# 3. These are SEPARATE decisions. Approving the plan ≠ approving the commit.
#
# MANDATORY: Before --auto can generate a token, a manifest file must exist
# at .git/COMMIT_MANIFEST. The agent MUST write this file before running
# this script. This prevents generating tokens without presenting changes.
#
# Modes:
#   Interactive (default): User runs directly, types "yes" in terminal
#   Auto (--auto): Agent runs after user said "yes commit" in chat

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

COMMIT_MSG="${1:-}"
AUTO_MODE="${2:-}"
REPO_ROOT=$(git rev-parse --show-toplevel)
COMMIT_APPROVED="${REPO_ROOT}/.git/COMMIT_APPROVED"
COMMIT_MANIFEST="${REPO_ROOT}/.git/COMMIT_MANIFEST"

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
  # MANDATORY CHECK: Manifest must exist before token can be generated
  if [[ ! -f "$COMMIT_MANIFEST" ]]; then
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║  BLOCKED: No commit manifest found.                        ║"
    echo "║                                                            ║"
    echo "║  Before generating an approval token, the agent MUST:      ║"
    echo "║                                                            ║"
    echo "║  1. Present what will change (files, impact, risk)         ║"
    echo "║  2. Write the manifest to .git/COMMIT_MANIFEST             ║"
    echo "║  3. Wait for user approval in chat                         ║"
    echo "║  4. THEN run this script                                   ║"
    echo "║                                                            ║"
    echo "║  The manifest is your proof that changes were reviewed.    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    exit 1
  fi

  # Display the manifest for final verification
  echo ""
  echo "╔════════════════════════════════════════════════════════════╗"
  echo "║  COMMIT MANIFEST — REVIEW BEFORE APPROVAL                ║"
  echo "╚════════════════════════════════════════════════════════════╝"
  echo ""
  cat "$COMMIT_MANIFEST"
  echo ""

  # Generate token
  PAYLOAD=$(date +%s)
  HASH=$(printf '%s\t%s' "$COMMIT_MSG" "$PAYLOAD" | sha256sum | cut -d' ' -f1)
  printf '%s\t%s' "$HASH" "$PAYLOAD" > "$COMMIT_APPROVED"

  # Delete manifest — it's been consumed
  rm -f "$COMMIT_MANIFEST"

  echo -e "${GREEN}✓${NC} Commit approved (auto). Token generated."
  echo "  Message: ${GREEN}${COMMIT_MSG}${NC}"
  echo "  ${YELLOW}Audit trail: User said 'yes commit' in chat before this script ran.${NC}"
  echo "  ${YELLOW}Manifest reviewed and deleted.${NC}"
else
  # Interactive mode: user runs directly, types "yes" in terminal
  echo ""
  echo "╔════════════════════════════════════════════════════════════╗"
  echo "║  COMMIT APPROVAL — USER GATED                            ║"
  echo "╚════════════════════════════════════════════════════════════╝"
  echo ""
  echo "  Commit message: ${GREEN}${COMMIT_MSG}${NC}"
  echo ""

  # Show staged changes if manifest doesn't exist
  if [[ -f "$COMMIT_MANIFEST" ]]; then
    cat "$COMMIT_MANIFEST"
    rm -f "$COMMIT_MANIFEST"
  else
    echo "  Staged changes:"
    git diff --cached --stat 2>/dev/null || echo "  (no staged changes)"
  fi

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
    rm -f "$COMMIT_MANIFEST"
    exit 1
  fi
fi
