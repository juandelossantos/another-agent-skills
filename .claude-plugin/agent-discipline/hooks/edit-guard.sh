#!/usr/bin/env bash
# edit-guard.sh — Claude Code PreToolUse + PostToolUse hook (matcher: Edit|Write)
# Structural integrity gate: records the line count before an edit, warns if
# it changed by more than 20% after — same threshold as OpenCode's
# verifyLineCountChange() (.opencode/plugins/agent-discipline/src/lib.ts).
# OpenCode's "markers" field is computed but never checked in editGuard(), so
# this only tracks line count, matching the real reference behavior.
#
# Claude Code passes the hook payload as JSON on stdin:
#   {"hook_event_name": "PreToolUse"|"PostToolUse", "tool_input": {"file_path": "..."}, ...}
#
# PreToolUse (recording step) always exits 0 — never blocks an edit from happening.
# PostToolUse: exit 1 surfaces a non-blocking warning in the transcript (Claude
# Code's documented behavior for a non-zero, non-2 exit on PostToolUse) — exit 2
# is deliberately avoided here since its PostToolUse semantics are undocumented
# and the edit has already happened by this point regardless.

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

INPUT="$(cat)"
EVENT="$(printf '%s' "$INPUT" | jq -r '.hook_event_name // empty' 2>/dev/null || true)"
FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)"

[ -z "$FILE_PATH" ] && exit 0

SHARED_SCRIPT="$PROJECT_DIR/scripts/edit-guard.sh"
[ -f "$SHARED_SCRIPT" ] || exit 0

case "$EVENT" in
  PreToolUse)
    bash "$SHARED_SCRIPT" preflight "$FILE_PATH" >/dev/null 2>&1 || true
    exit 0
    ;;
  PostToolUse)
    if bash "$SHARED_SCRIPT" verify "$FILE_PATH" >&2; then
      exit 0
    else
      echo "[edit-guard] Line count changed >20% on $FILE_PATH — verify the edit didn't drop content." >&2
      exit 1
    fi
    ;;
  *)
    exit 0
    ;;
esac
