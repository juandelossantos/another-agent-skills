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
#
# fail-open on missing jq is INTENTIONAL (documented, not an oversight): jq is a
# declared prerequisite, and blocking every shell command on a host without it
# is worse than a best-effort gate. This mirrors the Claude hook. The manifest
# sets failClosed:true, which covers crashes/timeouts/non-zero exits — exit 0
# here is a deliberate allow with a visible warning.
set -euo pipefail

if ! command -v jq &>/dev/null; then
  echo "[commit-approval] WARNING: jq not found — cannot parse hook input, gate disabled for this call (intentional fail-open; see header)." >&2
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

# Only these known wrappers are peeled, and their options are stripped only
# after a wrapper is seen. A generic "strip any leading flag" rule is the C1
# bug: `env -i git commit` reduced to `commit` because `-i` ate `git`.
_WRAPPERS_RE='^(sudo|env|command|nohup|time|nice|xargs|exec)([[:space:]]+(.*))?$'

_strip_prefixes() {
  local seg="$1"
  seg="$(trim_leading_whitespace "$seg")"

  # Bounded grouping peel: `(git commit)` / `{ git commit; }`.
  if [[ "$seg" == "("* ]]; then seg="${seg#(}"; fi
  if [[ "$seg" == "{"* ]]; then seg="${seg#\{}"; fi
  seg="$(trim_leading_whitespace "$seg")"
  if [[ "$seg" == *")" ]]; then seg="${seg%\)}"; fi
  if [[ "$seg" == *"}" ]]; then seg="${seg%\}}"; fi
  seg="$(trim_leading_whitespace "$seg")"

  local saw_wrapper=0
  while :; do
    local before="$seg"
    # bare NAME=value assignments
    while [[ "$seg" =~ ^[A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+(.*)$ ]]; do
      seg="${BASH_REMATCH[1]}"
    done
    # a wrapper word starts an option run
    if [[ "$seg" =~ $_WRAPPERS_RE ]]; then
      seg="${BASH_REMATCH[3]:-}"
      saw_wrapper=1
    fi
    # strip wrapper options; never consume git/rm/mv as an option value
    if [ "$saw_wrapper" -eq 1 ]; then
      while [[ "$seg" =~ ^(-[^[:space:]]+)([[:space:]]+(.*))?$ ]]; do
        local opt="${BASH_REMATCH[1]}"
        seg="${BASH_REMATCH[3]:-}"
        if [ "$opt" = "--" ]; then break; fi
        if [[ "$opt" == *=* ]]; then continue; fi
        if [[ "$seg" =~ ^([^[:space:]-][^[:space:]]*)([[:space:]]+(.*))?$ ]]; then
          local val="${BASH_REMATCH[1]}"
          if [ "$val" != "git" ] && [ "$val" != "rm" ] && [ "$val" != "mv" ]; then
            seg="${BASH_REMATCH[3]:-}"
          fi
        fi
        seg="$(trim_leading_whitespace "$seg")"
      done
    fi
    seg="$(trim_leading_whitespace "$seg")"
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
