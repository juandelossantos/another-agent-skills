#!/usr/bin/env bash
# commit-approval.sh — Claude Code PreToolUse hook (matcher: Bash)
# Blocks git commit/push/merge/rebase/reset/cherry-pick/revert unless a fresh
# .git/DECISION_APPROVED token exists — the repo's current approval-token
# scheme (see rules/common/enforcement.md, GLOSSARY.md). The old
# .git/COMMIT_APPROVED scheme this hook used to check was retired in
# commit-msg v4; nothing in current tooling writes that file anymore.
#
# Claude Code passes the hook payload as JSON on stdin:
#   {"tool_input": {"command": "..."}, ...}
# Exit 0 = allow. Exit 2 = block (Claude Code's PreToolUse block contract).
#
# Scoped in-script (not via the settings.json "if" matcher) because partial
# glob matching like "Bash(git commit*)" isn't documented precisely — matching
# on the full command string here is unambiguous.

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_risky-commands.sh
source "$HOOK_DIR/_risky-commands.sh"

INPUT="$(cat)"
COMMAND="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"

[ -z "$COMMAND" ] && exit 0
COMMAND="$(trim_leading_whitespace "$COMMAND")"

is_git_mutation_command "$COMMAND" || exit 0

REPO_ROOT="$(cd "$PROJECT_DIR" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null || echo "$PROJECT_DIR")"
DECISION_FILE="$REPO_ROOT/.git/DECISION_APPROVED"
MAX_AGE_SECONDS=600

block() {
  cat >&2 <<EOF
[commit-approval] BLOCKED: "$COMMAND" — $1

Before running this command, the agent MUST:
  1. Present a DECISION POINT (what changes, why, risk)
  2. Wait for explicit user approval (not "ok"/silence)
  3. Write .git/DECISION_APPROVED: echo "\$(date -Iseconds)" > .git/DECISION_APPROVED

NEVER bypass this gate.
EOF
  exit 2
}

[ -f "$DECISION_FILE" ] || block "no .git/DECISION_APPROVED token found"

DECISION_TS="$(grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}' "$DECISION_FILE" 2>/dev/null | head -1)"
[ -n "$DECISION_TS" ] || block ".git/DECISION_APPROVED has no valid timestamp"

DECISION_EPOCH="$(date -d "$DECISION_TS" +%s 2>/dev/null || echo 0)"
NOW_EPOCH="$(date +%s)"
AGE=$(( NOW_EPOCH - DECISION_EPOCH ))

if [ "$AGE" -gt "$MAX_AGE_SECONDS" ]; then
  block "decision token is stale (${AGE}s old, max ${MAX_AGE_SECONDS}s) — present a new DECISION POINT"
fi

exit 0
