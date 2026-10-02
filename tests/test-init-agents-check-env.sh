#!/usr/bin/env bash
# test-init-agents-check-env.sh — `init-agents --check-env` must not fail on a
# fresh machine (no plugins dir).
#
# Same class of bug as the pre-commit tests/task one: `set -euo pipefail` +
# `find <missing-dir> | wc -l` aborts the whole script. The plugin-duplicates
# check ran unconditionally, so --check-env exited 1 when
# ~/.config/opencode/plugins/ did not exist (e.g. before `install.sh`).

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INIT="$REPO_ROOT/scripts/init-agents.sh"

PASSED=0; FAILED=0; TOTAL=0
assert() {
  local name="$1" condition="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$condition"; then
    echo -e "  ${GREEN}✓${NC} $name"
    PASSED=$((PASSED + 1))
  else
    echo -e "  ${RED}✗${NC} $name"
    FAILED=$((FAILED + 1))
  fi
}

# Static: the plugins-dir find is guarded.
assert "source guards the plugins-dir find" "grep -q 'if \[ -d \"\${PLUGINS_DIR}\" \]' '$INIT'"
assert "defaults duplicates to 0 when absent" "grep -q 'DUPLICATES=0' '$INIT'"

# Behavioral: an isolated HOME with no ~/.config/opencode/plugins/ must not fail.
TMP=$(mktemp -d)
( HOME="$TMP" bash "$INIT" --check-env ) >/dev/null 2>&1
RC=$?
rm -rf "$TMP"
assert "--check-env exits 0 without a plugins dir" "[ $RC -eq 0 ]"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
