#!/usr/bin/env bash
# tests/audit/run.sh — Characterization tests for scripts/audit-markdown.sh
# Purpose: pin CURRENT behavior BEFORE universal-audit.sh exists, so the later
# refactor (audit-markdown.sh -> thin wrapper over universal-audit.sh) can be
# proven non-regressive. Test-first (P1 Step 0).
#
# When universal-audit.sh lands, the json-stub test must be FLIPPED to assert
# valid JSON is emitted. The golden WARN count (34) is a regression guard:
# update it only when repo .md content intentionally changes.
set -uo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
SCRIPT="$REPO_ROOT/scripts/audit-markdown.sh"

PASS=0
FAIL=0
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok() { echo -e "  ${GREEN}✓${NC} $1"; PASS=$((PASS + 1)); }
ko() { echo -e "  ${RED}✗${NC} $1"; FAIL=$((FAIL + 1)); }

strip_ansi() { sed 's/\x1b\[[0-9;]*m//g'; }

t_golden() {
  local out clean rc warn
  out=$(cd "$REPO_ROOT" && bash "$SCRIPT" 2>/dev/null); rc=$?
  clean=$(echo "$out" | strip_ansi)
  [ "$rc" -eq 0 ] || { ko "golden: expected exit 0, got $rc"; return; }
  echo "$clean" | grep -q "FAIL: 0" || { ko "golden: expected FAIL: 0 in summary"; return; }
  echo "$clean" | grep -q "All checks passed" || { ko "golden: missing 'All checks passed'"; return; }
  warn=$(echo "$clean" | grep -oE 'WARN: [0-9]+' | grep -oE '[0-9]+' | head -1)
  [ "$warn" = "34" ] || { ko "golden: WARN drifted (expected 34, got ${warn:-none}) — update golden if content changed intentionally"; return; }
  ok "golden: exit 0, FAIL 0, WARN 34 (baseline pinned)"
}

t_json_stub() {
  local out
  out=$(cd "$REPO_ROOT" && bash "$SCRIPT" --json 2>/dev/null)
  if echo "$out" | grep -q '"failures"'; then ko "json-stub: unexpectedly contains \"failures\" JSON"; return; fi
  if echo "$out" | grep -q '"summary"'; then ko "json-stub: unexpectedly contains \"summary\" JSON"; return; fi
  ok "json-stub: --json emits no JSON (current broken behavior pinned; flip when universal-audit.sh lands)"
}

t_core_broken_link() {
  # CURRENT BUG: the link check uses `grep ... | while read` (a pipeline), so check()
  # runs in a SUBSHELL and the FAIL counter never propagates. The broken link IS
  # detected and printed, but exit stays 0 and FAIL stays 0. universal-audit.sh
  # must FIX this (broken link -> exit 1). Pin the buggy behavior here until then.
  local tmp out rc
  tmp=$(mktemp -d)
  printf '# Title\n\n[missing](nope.md)\n' > "$tmp/AGENTS.md"
  out=$(cd "$tmp" && bash "$SCRIPT" 2>/dev/null); rc=$?
  rm -rf "$tmp"
  [ "$rc" -eq 0 ] || { ko "broken-link: expected exit 0 (current subshell bug), got $rc"; return; }
  echo "$out" | grep -qi "broken link" || { ko "broken-link: 'broken link' not reported in output"; return; }
  ok "broken-link: detected + printed, but non-blocking (exit 0 — subshell bug pinned; flip to exit 1 in universal-audit.sh)"
}

t_noncore_placeholder() {
  local tmp out rc
  tmp=$(mktemp -d)
  printf '# Notes\n\nTODO: fix this later\n' > "$tmp/notes.md"
  out=$(cd "$tmp" && bash "$SCRIPT" 2>/dev/null); rc=$?
  rm -rf "$tmp"
  [ "$rc" -eq 0 ] || { ko "noncore-placeholder: expected exit 0, got $rc"; return; }
  echo "$out" | grep -qi "placeholder" || { ko "noncore-placeholder: 'placeholder' not reported"; return; }
  ok "noncore-placeholder: detected as WARN, exit 0"
}

t_clean() {
  local tmp out rc
  tmp=$(mktemp -d)
  printf '# Clean\n\nNo issues here.\n' > "$tmp/README.md"
  out=$(cd "$tmp" && bash "$SCRIPT" 2>/dev/null); rc=$?
  rm -rf "$tmp"
  [ "$rc" -eq 0 ] || { ko "clean: expected exit 0, got $rc"; return; }
  echo "$out" | grep -q "All checks passed" || { ko "clean: missing 'All checks passed'"; return; }
  ok "clean: exit 0, all passed"
}

echo "╔════════════════════════════════════════════╗"
echo "║  AUDIT CHARACTERIZATION TESTS (P1 Step 0)  ║"
echo "╚════════════════════════════════════════════╝"
echo ""
t_golden
t_json_stub
t_core_broken_link
t_noncore_placeholder
t_clean
echo ""
echo -e "  ${GREEN}PASS: $PASS${NC}  ${RED}FAIL: $FAIL${NC}"
if [ "$FAIL" -eq 0 ]; then
  echo -e "  ${GREEN}✅ All characterization tests passed — baseline captured.${NC}"
  exit 0
else
  echo -e "  ${RED}❌ $FAIL test(s) failed.${NC}"
  exit 1
fi
