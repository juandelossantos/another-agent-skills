#!/usr/bin/env bash
# test-plugin-load-log.sh — guards against plugin load failures in the OpenCode
# log: the duplicate-id collision and "failed to load plugin" for agent-discipline.
# Skips gracefully when there is no log (e.g. CI without a running OpenCode).
set -uo pipefail

LOG="${OPENCODE_LOG:-$HOME/.local/share/opencode/log/opencode.log}"
if [ ! -f "$LOG" ]; then
  echo "  − no OpenCode log at $LOG — skipped"
  exit 0
fi

# Ignore "spawning process" lines: they echo the agent's own commands, which may
# legitimately contain these strings (e.g. a grep for the very error).
TAIL="$(tail -n 2000 "$LOG" | grep -v "spawning process")"
fail=0

if printf '%s\n' "$TAIL" | grep -q "Duplicate plugin ID"; then
  echo "  ✗ duplicate plugin ID in the recent log"
  printf '%s\n' "$TAIL" | grep "Duplicate plugin ID" | tail -2
  fail=1
else
  echo "  ✓ no duplicate plugin ID in the recent log"
fi

if printf '%s\n' "$TAIL" | grep "failed to load plugin" | grep -qi "agent-discipline"; then
  echo "  ✗ agent-discipline failed to load in the recent log"
  fail=1
else
  echo "  ✓ no agent-discipline load failures in the recent log"
fi

# Optional: ask a running OpenCode whether agent-discipline is in a failed state
# (the duplicate-id error surfaces via the plugin list, not always in the log).
if command -v opencode >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  OUT="$(timeout 25 opencode api get /api/plugin --header "x-opencode-directory: $PWD" 2>/dev/null || true)"
  if [ -n "$OUT" ]; then
    N="$(printf '%s' "$OUT" | jq '[.data[] | select(.id=="agent-discipline" and .state.status=="failed")] | length' 2>/dev/null || echo 0)"
    if [ "$N" = "0" ]; then
      echo "  ✓ agent-discipline not in a failed state (API)"
    else
      echo "  ✗ agent-discipline plugin failed (API)"
      fail=1
    fi
  fi
fi

exit "$fail"
