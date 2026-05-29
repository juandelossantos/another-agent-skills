#!/usr/bin/env bash
# commit-approval.sh — Commit Approval Gate
# BLOCKING: Exits 1 if no COMMIT_APPROVED token found
# Source: AGENTS.md Rule 12 + ADR-005

set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
APPROVAL_FILE="$REPO_ROOT/.git/COMMIT_APPROVED"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if [ ! -f "$APPROVAL_FILE" ]; then
  echo ""
  echo "╔════════════════════════════════════════════════════════════╗"
  echo "║  BLOCKED: No commit approval token found.               ║"
  echo "║                                                          ║"
  echo "║  The agent must present a Commit Manifest and get        ║"
  echo "║  your explicit approval before committing.               ║"
  echo "║                                                          ║"
  echo "║  Commit Manifest Protocol:                               ║"
  echo "║  1. Present what will change                            ║"
  echo "║  2. Explain impact and risk                              ║"
  echo "║  3. Ask: 'Do you approve this commit?'                   ║"
  echo "║  4. Wait for explicit 'yes'/'sí'/'commit'               ║"
  echo "║  5. Generate: printf 'msg' | sha256sum > .git/COMMIT_APPROVED"
  echo "║                                                          ║"
  echo "║  To bypass (process violation):                         ║"
  echo "║    git commit --no-verify                               ║"
  echo "╚════════════════════════════════════════════════════════════╝"
  echo ""
  exit 1
fi

TOKEN_CONTENT=$(cat "$APPROVAL_FILE" 2>/dev/null || echo "")
TOKEN_HASH=$(echo "$TOKEN_CONTENT" | cut -d'|' -f1)

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  COMMIT APPROVAL CHECK                                  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo "  Token: ${TOKEN_HASH:0:16}..."
echo "  ✓ Approval token present"
echo ""

exit 0
