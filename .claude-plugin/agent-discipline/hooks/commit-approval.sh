#!/usr/bin/env bash
# commit-approval.sh — Claude Code PreToolUse hook (matcher: Bash)
# Blocks git commit/push/merge/rebase/reset/cherry-pick/revert without an approval token.
#
# Claude Code passes the hook payload as JSON on stdin:
#   {"tool_input": {"command": "..."}, ...}
# Exit 0 = allow. Exit 2 = block (Claude Code's PreToolUse block contract).
#
# Scoped in-script (not via the settings.json "if" matcher) because partial
# glob matching like "Bash(git commit*)" isn't documented precisely — matching
# on the full command string here is unambiguous and mirrors the OpenCode
# reference implementation (.opencode/plugins/agent-discipline/src/lib.ts
# BLOCKED_COMMANDS).

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

INPUT="$(cat)"
COMMAND="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"

[ -z "$COMMAND" ] && exit 0

# Strip leading whitespace so an indented command (e.g. from a heredoc) still matches.
COMMAND="${COMMAND#"${COMMAND%%[![:space:]]*}"}"

is_blocked_command() {
  case "$1" in
    git\ commit*|git\ push*|git\ merge*|git\ rebase*|git\ reset*|git\ cherry-pick*|git\ revert*)
      return 0 ;;
    *)
      return 1 ;;
  esac
}

is_blocked_command "$COMMAND" || exit 0

REPO_ROOT="$(cd "$PROJECT_DIR" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null || echo "$PROJECT_DIR")"
APPROVAL_FILE="$REPO_ROOT/.git/COMMIT_APPROVED"

if [ ! -f "$APPROVAL_FILE" ]; then
  cat >&2 <<EOF
[commit-approval] BLOCKED: "$COMMAND" — no commit approval token found.

Before running this command, the agent MUST:
  1. Present a DECISION POINT (what changes, why, risk)
  2. Wait for explicit user approval (not "ok"/silence)
  3. Write the approval token (Commit Manifest Protocol)

NEVER bypass this gate.
EOF
  exit 2
fi

exit 0
