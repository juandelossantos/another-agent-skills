#!/usr/bin/env bash
# test-tdd-gate-web-skip.sh — the web project (web/) is a separate build with its
# own test suite (web/tests: node:test + Playwright). The core TDD gate must skip
# it, so the core CI never requires the web build.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GATE="$REPO_ROOT/scripts/tdd-gate.sh"

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

# Static: the skip pattern is present with its rationale.
assert "gate skips the web project" "grep -q \"'web/\\*'\" '$GATE'"
assert "the skip is justified in a comment" "grep -qi 'separate build for the public site' '$GATE'"

# Behavioral: a staged web/ code file is not treated as a core code file.
TMP=$(mktemp -d)
(
  cd "$TMP"
  git init -q
  git config user.email t@t.com
  git config user.name T
  mkdir -p web/src scripts
  echo "# init" > README.md && git add README.md && git commit -q -m init
  # A staged web code file + no test: the core gate must SKIP (exit 0), not block.
  echo "export const x = 1" > web/src/thing.ts
  git add web/src/thing.ts
) >/dev/null 2>&1
( cd "$TMP" && bash "$GATE" ) >/dev/null 2>&1
RC=$?
rm -rf "$TMP"
assert "a staged web/ file does not block the core gate (exit 0)" "[ $RC -eq 0 ]"

# Behavioral: a staged CORE code file still blocks (the skip is scoped, not global).
TMP2=$(mktemp -d)
(
  cd "$TMP2"
  git init -q
  git config user.email t@t.com
  git config user.name T
  echo "# init" > README.md && git add README.md && git commit -q -m init
  echo "echo hi" > core.sh
  git add core.sh
) >/dev/null 2>&1
( cd "$TMP2" && bash "$GATE" ) >/dev/null 2>&1
RC2=$?
rm -rf "$TMP2"
assert "a staged core code file still blocks (exit != 0)" "[ $RC2 -ne 0 ]"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
