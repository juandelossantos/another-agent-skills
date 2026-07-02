#!/usr/bin/env bash
# tests/audit/run.sh — Wrapper-contract tests for scripts/audit-markdown.sh
#
# After P1.3, audit-markdown.sh is a thin wrapper over universal-audit.sh.
# This suite verifies the wrapper preserves the contract consumers depend on
# (self-improvement skill, HEALTH-CHECK, pre-commit Test chain):
#   1. golden   — repo run via wrapper reproduces 34/0/0, exit 0
#   2. json     — --json passes through to valid, consistent JSON  (flips old stub pin)
#   3. broken-link — broken link in core file -> exit 1 via wrapper  (flips old subshell-bug pin)
#
# Engine feature tests (init, gating, portability) live in tests/audit/universal.sh.
set -uo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
WRAPPER="$REPO_ROOT/scripts/audit-markdown.sh"

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
  out=$(cd "$REPO_ROOT" && bash "$WRAPPER" 2>/dev/null); rc=$?
  clean=$(echo "$out" | strip_ansi)
  [ "$rc" -eq 0 ] || { ko "golden: expected exit 0, got $rc"; return; }
  echo "$clean" | grep -q "FAIL: 0" || { ko "golden: expected FAIL: 0"; return; }
  echo "$clean" | grep -q "All checks passed" || { ko "golden: missing 'All checks passed'"; return; }
  warn=$(echo "$clean" | grep -oE 'WARN: [0-9]+' | grep -oE '[0-9]+' | head -1)
  [ "$warn" = "3" ] || { ko "golden: WARN drifted (expected 3 after self-improvement iteration 1 — 3 known inline-code false positives; got ${warn:-none})"; return; }
  ok "golden: wrapper reproduces exit 0, FAIL 0, WARN 3 (post-iteration-1 baseline)"
}

t_json_valid() {
  local out sf lf
  out=$(cd "$REPO_ROOT" && bash "$WRAPPER" --json 2>/dev/null) || { ko "json-valid: exited $?"; return; }
  echo "$out" | jq -e '.summary and .failures and .warnings' >/dev/null 2>&1 || { ko "json-valid: missing .summary/.failures/.warnings"; return; }
  echo "$out" | jq . >/dev/null 2>&1 || { ko "json-valid: jq rejects output"; return; }
  sf=$(echo "$out" | jq -r '.summary.fail'); lf=$(echo "$out" | jq '.failures | length')
  [ "$sf" = "$lf" ] || { ko "json-valid: summary.fail=$sf != failures.length=$lf"; return; }
  ok "json-valid: --json via wrapper emits valid, consistent JSON (stub fixed)"
}

t_broken_link_via_wrapper() {
  local tmp out rc
  tmp=$(mktemp -d)
  cat > "$tmp/.audit-config.json" <<'JSON'
{"project_name":"t","include_patterns":["**/*.md"],"exclude_patterns":[],"core_files":["^AGENTS\\.md$"],"max_file_length":250,"length_check_paths":[],"checks":{"tables":true,"links":true,"placeholders":true,"file_length":true,"mermaid":true,"terminology":false},"terminology_rules":{}}
JSON
  printf '# Title\n\n[missing](nope.md)\n' > "$tmp/AGENTS.md"
  out=$(cd "$tmp" && bash "$WRAPPER" 2>/dev/null); rc=$?
  rm -rf "$tmp"
  [ "$rc" -eq 1 ] || { ko "broken-link: expected exit 1 via wrapper, got $rc"; return; }
  echo "$out" | grep -qi "broken link" || { ko "broken-link: 'broken link' not reported"; return; }
  ok "broken-link: via wrapper, broken link in core file -> exit 1 (subshell bug fixed)"
}

echo "╔════════════════════════════════════════════════╗"
echo "║  AUDIT WRAPPER-CONTRACT TESTS (P1.3)           ║"
echo "╚════════════════════════════════════════════════╝"
echo ""
t_golden
t_json_valid
t_broken_link_via_wrapper
echo ""
echo -e "  ${GREEN}PASS: $PASS${NC}  ${RED}FAIL: $FAIL${NC}"
if [ "$FAIL" -eq 0 ]; then
  echo -e "  ${GREEN}✅ All wrapper-contract tests passed.${NC}"
  exit 0
else
  echo -e "  ${RED}❌ $FAIL test(s) failed.${NC}"
  exit 1
fi
