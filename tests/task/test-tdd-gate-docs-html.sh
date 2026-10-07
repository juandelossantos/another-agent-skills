#!/usr/bin/env bash
# test-tdd-gate-docs-html.sh — docs/**/*.html are documentation, not code.
# Editing a docs-site HTML page must NOT demand a name-paired test (the docs
# pipeline owns it); a root-level .html is still frontend code.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
GATE="$REPO_ROOT/scripts/tdd-gate.sh"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

PASSED=0; FAILED=0; TOTAL=0
pass() { echo -e "  ${GREEN}✓${NC} $1"; PASSED=$((PASSED + 1)); TOTAL=$((TOTAL + 1)); }
fail() { echo -e "  ${RED}✗${NC} $1"; FAILED=$((FAILED + 1)); TOTAL=$((TOTAL + 1)); }

consumer() {
  cd "$TMP" || return
  rm -rf r; mkdir r; cd r || return
  git init -q; git config user.email t@t.t; git config user.name t
  echo base > base.txt; git add base.txt; git commit -qm base
}
gate_exit() { ( unset REPO_ROOT; bash "$GATE" >/dev/null 2>&1 ); echo $?; }
expect() { [ "$(gate_exit)" = "$1" ] && pass "$2" || fail "$2 (expected exit $1, got $(gate_exit))"; }

# ── docs/page.html → docs (not code) → not blocked ──
consumer; mkdir -p docs; printf '<html></html>\n' > docs/page.html; git add -A
expect 0 "docs/page.html → docs (not code) → not blocked"

# ── root index.html → code → BLOCK (no paired test) ──
consumer; printf '<html></html>\n' > index.html; git add -A
expect 1 "root index.html → code → BLOCK (no test)"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
