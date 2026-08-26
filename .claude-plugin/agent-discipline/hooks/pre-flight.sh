#!/usr/bin/env bash
# pre-flight.sh — Claude Code PreToolUse hook (matcher: Bash)
# Blocks risky git/filesystem commands when the working tree is dirty or the
# branch is behind its upstream — mirrors OpenCode's isRiskyCommand()/preFlight()
# (.opencode/plugins/agent-discipline/src/lib.ts + hooks.ts), not the broader
# manual `scripts/pre-flight.sh` (branch/.gitignore/.env.example session-start
# checks — those stay manual, firing them on every git command would block
# routine `git status` whenever the tree is dirty, which is most of the time).
#
# Claude Code passes the hook payload as JSON on stdin:
#   {"tool_input": {"command": "..."}, ...}
# Exit 0 = allow. Exit 2 = block (Claude Code's PreToolUse block contract).

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

INPUT="$(cat)"
COMMAND="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"

[ -z "$COMMAND" ] && exit 0

# Strip leading whitespace so an indented command (e.g. from a heredoc) still matches.
COMMAND="${COMMAND#"${COMMAND%%[![:space:]]*}"}"

is_risky_command() {
  case "$1" in
    git\ commit*|git\ push*|git\ merge*|git\ rebase*|git\ reset*|git\ cherry-pick*|git\ revert*|rm\ -rf*|mv\ *)
      return 0 ;;
    *)
      return 1 ;;
  esac
}

is_risky_command "$COMMAND" || exit 0

REPO_ROOT="$(cd "$PROJECT_DIR" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null || echo "")"
[ -z "$REPO_ROOT" ] && exit 0
cd "$REPO_ROOT"

if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
  echo "[pre-flight] BLOCKED: dirty working tree. Commit, stash, or discard changes before \"$COMMAND\"" >&2
  exit 2
fi

UPSTREAM="$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || echo "")"
if [ -n "$UPSTREAM" ]; then
  BEHIND="$(git rev-list --count "HEAD..${UPSTREAM}" 2>/dev/null || echo 0)"
  if [ "${BEHIND:-0}" -gt 0 ]; then
    echo "[pre-flight] BLOCKED: branch is $BEHIND commit(s) behind $UPSTREAM. Pull --rebase before \"$COMMAND\"" >&2
    exit 2
  fi
fi

exit 0
