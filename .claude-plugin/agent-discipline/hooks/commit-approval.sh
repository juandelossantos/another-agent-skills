#!/usr/bin/env bash
# commit-approval.sh — Claude Code PreToolUse hook (matcher: Bash)
#
# Philosophy A: the agent NEVER runs `git commit`, `git push`, or any other
# history/remote-mutating git command — in any repo. There is NO token bypass:
# nothing the agent can write (no `.git/DECISION_APPROVED`, no
# `.git/COMMIT_APPROVED`) lets it through. The agent presents the exact
# command and message, then the USER runs it (Rule 12).
#
# Claude Code passes the hook payload as JSON on stdin:
#   {"tool_input": {"command": "..."}, ...}
# Exit 0 = allow. Exit 2 = block (Claude Code's PreToolUse block contract).
# We also emit the `permissionDecision: "deny"` JSON for clients that read it.
#
# Command classification is shared with pre-flight.sh via _risky-commands.sh
# so the two hooks can't silently drift apart. That classifier catches
# compound commands (`cd x && git push`) and word boundaries
# (`git commit-tree` is not `git commit`); an extra flags-aware check below
# catches `git -C <dir> commit`, which the segment-anchored regex does not.
set -euo pipefail

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_risky-commands.sh
source "$HOOK_DIR/_risky-commands.sh"

if ! command -v jq &>/dev/null; then
  echo "[commit-approval] WARNING: jq not found — cannot parse hook input, gate disabled for this call." >&2
  exit 0
fi

INPUT="$(cat)"
COMMAND="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"

[ -z "$COMMAND" ] && exit 0
COMMAND="$(trim_leading_whitespace "$COMMAND")"

# Blocked if either classifier matches:
#   1. _risky-commands.sh — segment-aware, handles `cd x && git push`, env
#      prefixes, and requires a word boundary after the subcommand.
#   2. The flags-aware regex — handles `git -C <dir> commit`, which the
#      segment-anchored pattern (subcommand immediately after `git`) misses.
GIT_MUTATION_WITH_FLAGS_RE='\bgit\b([[:space:]]+-[A-Za-z0-9-]+([[:space:]]+[^[:space:]]+)?)*[[:space:]]+(commit|push|merge|rebase|reset|cherry-pick|revert)([[:space:]]|$)'

if ! is_git_mutation_command "$COMMAND" \
  && ! printf '%s\n' "$COMMAND" | grep -qE "$GIT_MUTATION_WITH_FLAGS_RE"; then
  exit 0
fi

# Unconditional deny — philosophy A. No token, no bypass.
cat <<'JSON_EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "The agent never runs git mutations (commit/push/merge/rebase/reset/cherry-pick/revert), in any repo (Rule 12, no bypass). Present the exact command and message, then let the user run it."
  }
}
JSON_EOF
echo "[commit-approval] BLOCKED: \"$COMMAND\" — the agent never runs git mutations (philosophy A, no bypass)." >&2
exit 2
