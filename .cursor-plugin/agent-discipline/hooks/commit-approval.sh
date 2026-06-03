#!/usr/bin/env bash
# commit-approval.sh — Cursor hook: Block commits without approval
# BLOCKING: Exits 1 if no COMMIT_APPROVED token found
# Updated: v1.6.1 — references manifest gate and new rules

set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

APPROVAL_FILE="$REPO_ROOT/.git/COMMIT_APPROVED"

if [ ! -f "$APPROVAL_FILE" ]; then
  echo ""
  echo "╔════════════════════════════════════════════════════════════╗"
  echo "║  BLOCKED: No commit approval token found.               ║"
  echo "║                                                          ║"
  echo "║  Before committing, the agent MUST:                     ║"
  echo "║                                                          ║"
  echo "║  1. Read SOUL.md and AGENTS.md for project rules        ║"
  echo "║  2. Present what will change (Commit Manifest)          ║"
  echo "║  3. Explain impact and risk                              ║"
  echo "║  4. Ask: 'Do you approve this commit?'                   ║"
  echo "║  5. Wait for explicit approval                           ║"
  echo "║  6. Run: bash scripts/approve-commit.sh \"message\" --auto ║"
  echo "║                                                          ║"
  echo "║  Key rules to follow:                                    ║"
  echo "║  - Rule 0h: TOOL_GAP — report 'ship status unknown'     ║"
  echo "║    when tools can't verify. Never fake a win.           ║"
  echo "║  - Rule 0i: Continuation Over Recap — resume, don't     ║"
  echo "║    recap after context loss.                             ║"
  echo "║  - Principle 8: Verification without evidence is        ║"
  echo "║    inspection.                                           ║"
  echo "║                                                          ║"
  echo "║  NEVER bypass this gate. Doing so is a process violation.║"
  echo "╚════════════════════════════════════════════════════════════╝"
  echo ""
  exit 1
fi

# Token exists - read it for logging
TOKEN_CONTENT=$(cat "$APPROVAL_FILE" 2>/dev/null || echo "")
TOKEN_HASH=$(echo "$TOKEN_CONTENT" | cut -d$'\t' -f1)

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  COMMIT APPROVAL CHECK                                    ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo "  Token: ${TOKEN_HASH:0:16}..."
echo "  ✓ Approval token present"
echo ""

exit 0
