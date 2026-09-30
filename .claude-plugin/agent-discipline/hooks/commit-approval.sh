#!/usr/bin/env bash
# commit-approval.sh — Claude Code PreToolUse hook (matcher: Bash)
#
# Philosophy A: the agent NEVER runs `git commit` or `git push` — in any repo.
# There is no token bypass. The agent presents the exact command and message,
# then the USER runs it (Rule 12).
#
# Registered in ~/.claude/settings.json under hooks.PreToolUse. Reads the hook
# payload from stdin and emits a deny decision for commit/push.
set -euo pipefail

PAYLOAD="$(cat)"
COMMAND="$(echo "$PAYLOAD" | jq -r '.tool_input.command // empty' 2>/dev/null || echo "")"

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# \b after (commit|push) so `commit-graph`/`push-something` do not match, but
# `git commit` and `git push` do (with optional flags in between).
if echo "$COMMAND" | grep -qE '\bgit\b([[:space:]]+-[A-Za-z0-9-]+([[:space:]]+[^[:space:]]+)?)*[[:space:]]+(commit|push)([[:space:]]|$)'; then
  cat <<'JSON_EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "The agent never runs git commit or git push, in any repo (Rule 12, no bypass). Present the exact command and message, then let the user run it."
  }
}
JSON_EOF
fi

exit 0
