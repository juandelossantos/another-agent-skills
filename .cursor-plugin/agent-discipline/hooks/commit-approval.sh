#!/usr/bin/env bash
# commit-approval.sh — Cursor hook (beforeShellExecution).
#
# Philosophy A: the agent NEVER runs `git commit`, `git push`, or any other
# history/remote-mutating git command — in any repo. There is NO token bypass:
# nothing the agent can write lets it through. The agent presents the exact
# command and message, then the USER runs it (Rule 12). Mirrors the Claude
# guardrail (.claude-plugin/agent-discipline/hooks/commit-approval.sh).
#
# Cursor passes the hook payload as JSON on stdin: {"command": "...", ...}.
# A Claude-style {"tool_input":{"command":"..."}} payload and a bare "$1" are
# also accepted so the same gate works across adapters.
# Exit 0 = allow. Exit 2 = block (Cursor's documented deny contract; the JSON
# denial shape is emitted too for clients that read stdout).
set -euo pipefail

if ! command -v jq &>/dev/null; then
  echo "[commit-approval] WARNING: jq not found — cannot parse hook input, gate disabled for this call." >&2
  exit 0
fi

INPUT="$(cat)"
COMMAND="$(printf '%s' "$INPUT" | jq -r '.command // .tool_input.command // empty' 2>/dev/null || true)"
[ -z "$COMMAND" ] && COMMAND="${1:-}"
[ -z "$COMMAND" ] && exit 0

trim_leading_whitespace() {
  local s="$1"
  echo "${s#"${s%%[![:space:]]*}"}"
}

_strip_prefixes() {
  local seg
  seg="$(trim_leading_whitespace "$1")"
  # strip sudo/env invocations (with flags) and bare NAME=value assignments.
  while :; do
    local before="$seg"
    if [[ "$seg" =~ ^(sudo|env)[[:space:]]+(.*)$ ]]; then seg="${BASH_REMATCH[2]}"; fi
    if [[ "$seg" =~ ^-[A-Za-z][A-Za-z0-9-]*[[:space:]]+[^[:space:]]+[[:space:]]+(.*)$ ]]; then seg="${BASH_REMATCH[1]}"; fi
    while [[ "$seg" =~ ^[A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+(.*)$ ]]; do seg="${BASH_REMATCH[1]}"; done
    [ "$seg" = "$before" ] && break
  done
  echo "$seg"
}

# Segment-aware + flags-aware: catches `cd x && git commit`,
# `FOO=bar git commit`, `sudo git commit`, and `git -C dir commit`, while
# requiring a word boundary so `git commit-tree` (plumbing) is not
# misclassified. Best-effort, not a hard security boundary.
_is_git_mutation() {
  local cmd="$1" seg stripped
  local flags_re='(-[A-Za-z0-9-]+(=[^[:space:]]*)?([[:space:]]+[^[:space:]]+)?[[:space:]]+)*'
  while IFS= read -r seg; do
    stripped="$(_strip_prefixes "$seg")"
    if [[ "$stripped" =~ ^git[[:space:]]+${flags_re}(commit|push|merge|rebase|reset|cherry-pick|revert)([[:space:]]|$) ]]; then
      return 0
    fi
  done <<< "$(printf '%s\n' "$cmd" | sed -E 's/(&&|\|\||;|\|)/\n/g')"
  return 1
}

_is_git_mutation "$COMMAND" || exit 0

# Unconditional deny — philosophy A. No token, no bypass.
cat <<'JSON_EOF'
{
  "continue": false,
  "permission": "deny",
  "user_message": "Blocked: the agent never runs git mutations (commit/push/merge/rebase/reset/cherry-pick/revert), in any repo (Rule 12, no bypass). Present the exact command and message, then run it yourself.",
  "agent_message": "The agent never runs git mutations (philosophy A, no bypass)."
}
JSON_EOF
echo "[commit-approval] BLOCKED: \"$COMMAND\" — the agent never runs git mutations (philosophy A, no bypass)." >&2
exit 2
