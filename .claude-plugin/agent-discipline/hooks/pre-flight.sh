#!/usr/bin/env bash
# pre-flight.sh — Claude Code PreToolUse hook (matcher: Bash)
# Blocks risky git/filesystem commands when the working tree is dirty or the
# branch is behind its upstream — mirrors OpenCode's isRiskyCommand()/preFlight()
# (.opencode/plugins/agent-discipline/src/lib.ts + hooks.ts), not the broader
# manual `scripts/pre-flight.sh` (branch/.gitignore/.env.example session-start
# checks — those stay manual).
#
# "git commit" is deliberately EXEMPT from the dirty-tree check: committing
# requires staged (dirty) changes, so gating it on a clean tree would block
# every normal commit. It's still gated by commit-approval.sh's approval-token
# check. The upstream-behind check still applies to it (no reason to commit
# on top of a stale branch).
#
# Claude Code passes the hook payload as JSON on stdin:
#   {"tool_input": {"command": "..."}, ...}
# Exit 0 = allow. Exit 2 = block (Claude Code's PreToolUse block contract).

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_risky-commands.sh
source "$HOOK_DIR/_risky-commands.sh"

if ! command -v jq &>/dev/null; then
  echo "[pre-flight] WARNING: jq not found — cannot parse hook input, gate disabled for this call." >&2
  exit 0
fi

INPUT="$(cat)"
COMMAND="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"

[ -z "$COMMAND" ] && exit 0
COMMAND="$(trim_leading_whitespace "$COMMAND")"

is_risky_command "$COMMAND" || exit 0

REPO_ROOT="$(cd "$PROJECT_DIR" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null || echo "")"
[ -z "$REPO_ROOT" ] && exit 0
cd "$REPO_ROOT"

if is_dirty_tree_risky_command "$COMMAND" && [ -n "$(git status --porcelain 2>/dev/null)" ]; then
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
