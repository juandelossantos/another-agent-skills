#!/usr/bin/env bash
# tests/audit/universal.sh — Feature tests for scripts/universal-audit.sh
# Test-first: written BEFORE the engine exists. First run = RED (script missing).
# Then build scripts/universal-audit.sh until all tests = GREEN.
#
# These assert TARGET behavior (fixes the 3 bugs pinned by run.sh):
#   - --json emits valid JSON (fixes stub)
#   - broken link in core file -> exit 1 (fixes subshell counter bug)
#   - --init creates a config with all required keys
#   - checks.<name>=false skips that check (config-gating)
#   - config-driven: project_name + core_files read from .audit-config.json
#   - portable: works in a foreign temp project with its own config
set -uo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
ENGINE="$REPO_ROOT/scripts/universal-audit.sh"

PASS=0
FAIL=0
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok() { echo -e "  ${GREEN}✓${NC} $1"; PASS=$((PASS + 1)); }
ko() { echo -e "  ${RED}✗${NC} $1"; FAIL=$((FAIL + 1)); }
skip_if_no_engine() { [ -f "$ENGINE" ] || { echo -e "  ${YELLOW}⊘${NC} $1 (engine not built yet — RED)"; FAIL=$((FAIL + 1)); return 1; }; return 0; }

# --- valid JSON shape ---
t_json_shape() {
  skip_if_no_engine "json-shape" || return
  local out
  out=$(cd "$REPO_ROOT" && bash "$ENGINE" --json 2>/dev/null) || { ko "json-shape: engine exited $?" ; return; }
  echo "$out" | jq -e '.summary and .summary.pass and .summary.warn and .summary.fail' >/dev/null 2>&1 \
    || { ko "json-shape: .summary.{pass,warn,fail} missing"; return; }
  echo "$out" | jq -e '.failures and .warnings' >/dev/null 2>&1 \
    || { ko "json-shape: .failures/.warnings arrays missing"; return; }
  ok "json-shape: valid JSON with .summary + .failures + .warnings"
}

# --- JSON is parseable (not stderr spam) ---
t_json_parseable() {
  skip_if_no_engine "json-parseable" || return
  local out
  out=$(cd "$REPO_ROOT" && bash "$ENGINE" --json 2>/dev/null) || { ko "json-parseable: exited $?"; return; }
  echo "$out" | jq . >/dev/null 2>&1 || { ko "json-parseable: jq rejects output"; return; }
  ok "json-parseable: full document parses with jq"
}

# --- broken link in core file -> exit 1 (subshell bug FIXED) ---
t_broken_link_blocks() {
  skip_if_no_engine "broken-link-blocks" || return
  local tmp out rc
  tmp=$(mktemp -d)
  printf '{\n  "project_name":"t",\n  "include_patterns":["**/*.md"],\n  "exclude_patterns":[],\n  "core_files":["^AGENTS\\\\.md$"],\n  "max_file_length":250,\n  "length_check_paths":[],\n  "checks":{"tables":true,"links":true,"placeholders":true,"file_length":true,"mermaid":true,"terminology":false},\n  "terminology_rules":{}\n}\n' > "$tmp/.audit-config.json"
  printf '# Title\n\n[missing](nope.md)\n' > "$tmp/AGENTS.md"
  out=$(cd "$tmp" && bash "$ENGINE" 2>/dev/null); rc=$?
  rm -rf "$tmp"
  [ "$rc" -eq 1 ] || { ko "broken-link-blocks: expected exit 1 (FIXED), got $rc"; return; }
  ok "broken-link-blocks: broken link in core file -> exit 1 (subshell bug fixed)"
}

# --- --init creates a config with all required keys ---
t_init_creates_config() {
  skip_if_no_engine "init-creates-config" || return
  local tmp
  tmp=$(mktemp -d)
  (cd "$tmp" && bash "$ENGINE" --init >/dev/null 2>&1) || { ko "init: --init exited $?"; rm -rf "$tmp"; return; }
  [ -f "$tmp/.audit-config.json" ] || { ko "init: .audit-config.json not created"; rm -rf "$tmp"; return; }
  local cfg="$tmp/.audit-config.json"
  for k in project_name include_patterns exclude_patterns core_files max_file_length length_check_paths checks terminology_rules; do
    jq -e --arg k "$k" 'has($k)' "$cfg" >/dev/null 2>&1 || { ko "init: key '$k' missing from config"; rm -rf "$tmp"; return; }
  done
  ok "init: --init creates .audit-config.json with all 8 required keys"
  rm -rf "$tmp"
}

# --- checks.links=false -> link check skipped (config-gating) ---
t_config_gating_links() {
  skip_if_no_engine "config-gating-links" || return
  local tmp out rc
  tmp=$(mktemp -d)
  printf '{\n  "project_name":"t",\n  "include_patterns":["**/*.md"],\n  "exclude_patterns":[],\n  "core_files":["^AGENTS\\\\.md$"],\n  "max_file_length":250,\n  "length_check_paths":[],\n  "checks":{"tables":true,"links":false,"placeholders":true,"file_length":true,"mermaid":true,"terminology":false},\n  "terminology_rules":{}\n}\n' > "$tmp/.audit-config.json"
  printf '# Title\n\n[missing](nope.md)\n' > "$tmp/AGENTS.md"
  out=$(cd "$tmp" && bash "$ENGINE" 2>/dev/null); rc=$?
  rm -rf "$tmp"
  [ "$rc" -eq 0 ] || { ko "config-gating-links: with links disabled, expected exit 0, got $rc"; return; }
  echo "$out" | grep -qi "broken link" && { ko "config-gating-links: broken link reported despite checks.links=false"; return; }
  ok "config-gating-links: checks.links=false skips link check (exit 0, no broken-link report)"
}

# --- config-driven: project_name appears in banner ---
t_config_project_name() {
  skip_if_no_engine "config-project-name" || return
  local tmp out
  tmp=$(mktemp -d)
  printf '{\n  "project_name":"MY-FEATURE-PROJECT",\n  "include_patterns":["**/*.md"],\n  "exclude_patterns":[],\n  "core_files":[],\n  "max_file_length":250,\n  "length_check_paths":[],\n  "checks":{"tables":true,"links":true,"placeholders":true,"file_length":true,"mermaid":true,"terminology":false},\n  "terminology_rules":{}\n}\n' > "$tmp/.audit-config.json"
  printf '# Clean\n\nNo issues.\n' > "$tmp/README.md"
  out=$(cd "$tmp" && bash "$ENGINE" 2>/dev/null)
  rm -rf "$tmp"
  echo "$out" | grep -q "MY-FEATURE-PROJECT" || { ko "config-project-name: project_name not in banner output"; return; }
  ok "config-project-name: project_name read from config and shown in banner"
}

# --- portable: works in a foreign temp project with no hardcoded paths ---
t_portable_foreign_project() {
  skip_if_no_engine "portable-foreign" || return
  local tmp out rc
  tmp=$(mktemp -d)
  printf '{\n  "project_name":"foreign-app",\n  "include_patterns":["**/*.md"],\n  "exclude_patterns":["node_modules/**"],\n  "core_files":["^README\\\\.md$"],\n  "max_file_length":250,\n  "length_check_paths":[],\n  "checks":{"tables":true,"links":true,"placeholders":true,"file_length":true,"mermaid":true,"terminology":false},\n  "terminology_rules":{}\n}\n' > "$tmp/.audit-config.json"
  printf '# Foreign App\n\nA clean foreign project.\n' > "$tmp/README.md"
  out=$(cd "$tmp" && bash "$ENGINE" 2>/dev/null); rc=$?
  rm -rf "$tmp"
  [ "$rc" -eq 0 ] || { ko "portable-foreign: clean foreign project expected exit 0, got $rc"; return; }
  echo "$out" | grep -q "All checks passed" || { ko "portable-foreign: missing 'All checks passed'"; return; }
  ok "portable-foreign: engine runs standalone in a foreign project, exit 0"
}

# --- golden on this repo (regression guard): 0 fail via JSON ---
t_repo_golden_json() {
  skip_if_no_engine "repo-golden-json" || return
  local out fails warns
  out=$(cd "$REPO_ROOT" && bash "$ENGINE" --json 2>/dev/null) || { ko "repo-golden-json: exited $?"; return; }
  fails=$(echo "$out" | jq -r '.summary.fail')
  [ "$fails" = "0" ] || { ko "repo-golden-json: expected fail=0, got $fails"; return; }
  ok "repo-golden-json: 0 failures on this repo (regression guard)"
}

echo "╔════════════════════════════════════════════════╗"
echo "║  UNIVERSAL-AUDIT FEATURE TESTS (test-first)    ║"
echo "╚════════════════════════════════════════════════╝"
echo ""
t_json_shape
t_json_parseable
t_broken_link_blocks
t_init_creates_config
t_config_gating_links
t_config_project_name
t_portable_foreign_project
t_repo_golden_json
echo ""
echo -e "  ${GREEN}PASS: $PASS${NC}  ${RED}FAIL: $FAIL${NC}"
if [ "$FAIL" -eq 0 ]; then
  echo -e "  ${GREEN}✅ All feature tests passed — engine is GREEN.${NC}"
  exit 0
else
  echo -e "  ${RED}❌ $FAIL test(s) RED — build scripts/universal-audit.sh to turn these green.${NC}"
  exit 1
fi
