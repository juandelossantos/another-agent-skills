#!/usr/bin/env bash
# approve.sh — bind a human approval to the exact staged tree (Phase 15).
#
# Run this as the HUMAN, after reviewing the staged change and before
# `git commit`. It writes the approval artifact:
#
#   2026-10-19T09:50:10-05:00
#   tree=<git write-tree sha>
#
# Why: a timestamp-only token authorizes "a commit", not "this commit". Between
# approval and commit the index is still writable, so an unbound token lets
# "approve A, commit B" through. Binding the staged tree closes that channel.
#
# `pre-commit` Gate 0 refuses to commit unless the staged tree still hashes to
# the approved tree, and consumes the artifact on success (one approval, one
# commit). This also closes replay inside the freshness window.
#
# This is still L1: local and forgeable by an agent with a shell. The authority
# is the remote `gates` check. See docs/BRANCH-PROTECTION.md.
#
# Usage: bash scripts/approve.sh [--yes]
#   --yes   non-interactive (CI / release scripts)

set -euo pipefail

ROOT=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [ -z "$ROOT" ]; then
  echo "approve.sh: not inside a git repository" >&2
  exit 1
fi
cd "$ROOT"

if git diff --cached --quiet; then
  echo "approve.sh: nothing staged. Stage the exact change first." >&2
  exit 1
fi

TREE=$(git write-tree)
TS=$(date -Iseconds)

echo ""
echo "Approving this staged tree:"
echo ""
git --no-pager diff --cached --stat || true
echo ""
echo "  tree: $TREE"
echo "  at:   $TS"
echo ""

if [ "${1:-}" != "--yes" ] && [ -t 0 ]; then
  printf "Approve this exact tree? [y/N] "
  read -r answer
  case "$answer" in
    y|Y|yes|YES) ;;
    *) echo "Not approved."; exit 1 ;;
  esac
fi

printf '%s\ntree=%s\n' "$TS" "$TREE" > .git/DECISION_APPROVED
echo "Approved. The next commit must be this exact tree; the approval is consumed by it."
