#!/usr/bin/env bash
# commit-approval.sh — Claude Code hook: Block commits without approval
# BLOCKING: Exits 1 if no COMMIT_APPROVED token found

set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

APPROVAL_FILE="$REPO_ROOT/.git/COMMIT_APPROVED"

if [ ! -f "$APPROVAL_FILE" ]; then
  echo ""
  echo "╔════════════════════════════════════════════════════════════╗"
  echo "║  BLOCKED: No commit approval token found.               ║"
  echo "║                                                          ║"
  echo "║  The agent must present a Commit Manifest and get        ║"
  echo "║  your explicit approval before committing.              ║"
  echo "║                                                          ║"
  echo "║  To bypass this check (process violation):              ║"
  echo "║    git commit --no-verify                               ║"
  echo "╚════════════════════════════════════════════════════════════╝"
  echo ""
  exit 1
fi

# Token exists - read it for logging
TOKEN_CONTENT=$(cat "$APPROVAL_FILE" 2>/dev/null || echo "")
TOKEN_HASH=$(echo "$TOKEN_CONTENT" | cut -d'|' -f1)

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  COMMIT APPROVAL CHECK                                    ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo "  Token: ${TOKEN_HASH:0:16}..."
echo "  ✓ Approval token present"
echo ""

exit 0
