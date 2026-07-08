#!/usr/bin/env bash
# tests/init/run.sh — Feature tests for init-agents.sh --with-self-improvement
#
# Written test-first (P1.4.6) before install_self_improvement() exists.
# First run = RED (flag + function not yet implemented).
# Tests scaffold a temp project, run init-agents, verify artifacts.
set -uo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
INIT_SCRIPT="$REPO_ROOT/scripts/init-agents.sh"

PASS=0
FAIL=0
GREEN=$'\033[0;32m'
RED=$'\033[0;31m'
YELLOW=$'\033[1;33m'
NC=$'\033[0m'

ok() { echo -e "  ${GREEN}✓${NC} $1"; PASS=$((PASS + 1)); }
ko() { echo -e "  ${RED}✗${NC} $1"; FAIL=$((FAIL + 1)); }

# --- Contract: init-agents (default) creates all 7 artifacts ---
t_default_creates_all_7() {
  local tmp rc
  tmp=$(mktemp -d)
  (cd "$tmp" && bash "$INIT_SCRIPT" >/dev/null 2>&1); rc=$?
  local missing=0
  [ -f "$tmp/.audit-config.json" ] || { echo "  missing .audit-config.json"; missing=1; }
  [ -f "$tmp/scripts/audit-project.sh" ] || { echo "  missing scripts/audit-project.sh"; missing=1; }
  [ -d "$tmp/skills/self-improvement" ] || { echo "  missing skills/self-improvement/"; missing=1; }
  [ -f "$tmp/skills/self-improvement/SKILL.md" ] || { echo "  missing skills/self-improvement/SKILL.md"; missing=1; }
  [ -f "$tmp/PATTERNS.md" ] || { echo "  missing PATTERNS.md"; missing=1; }
  [ -f "$tmp/ANTI-PATTERNS.md" ] || { echo "  missing ANTI-PATTERNS.md"; missing=1; }
  [ -d "$tmp/ADRs" ] || { echo "  missing ADRs/"; missing=1; }
  [ -f "$tmp/scripts/generate-adr.sh" ] || { echo "  missing scripts/generate-adr.sh"; missing=1; }
  rm -rf "$tmp"
  [ "$missing" = "0" ] || { ko "default-creates-7: $missing artifact(s) missing (expected all 7 by default)"; return; }
  ok "default-creates-7: init-agents creates all 7 artifacts by default"
}

# --- Contract: with --skip-self-improvement flag, zero artifacts exist ---
t_skip_no_artifacts() {
  local tmp
  tmp=$(mktemp -d)
  (cd "$tmp" && bash "$INIT_SCRIPT" --skip-self-improvement >/dev/null 2>&1)
  local found=0
  [ -f "$tmp/.audit-config.json" ] && found=$((found + 1))
  [ -f "$tmp/scripts/audit-project.sh" ] && found=$((found + 1))
  [ -d "$tmp/skills/self-improvement" ] && found=$((found + 1))
  [ -f "$tmp/PATTERNS.md" ] && found=$((found + 1))
  [ -f "$tmp/ANTI-PATTERNS.md" ] && found=$((found + 1))
  [ -d "$tmp/ADRs" ] && found=$((found + 1))
  [ -f "$tmp/scripts/generate-adr.sh" ] && found=$((found + 1))
  rm -rf "$tmp"
  [ "$found" -eq 0 ] || { ko "skip-flag: found $found artifact(s) with --skip-self-improvement (should be 0)"; return; }
  ok "skip-flag: --skip-self-improvement produces zero self-improvement artifacts"
}

# --- Contract: Node project gets node_modules/ in excludes ---
t_config_stack_aware_node() {
  local tmp
  tmp=$(mktemp -d)
  echo '{"name":"test"}' > "$tmp/package.json"
  (cd "$tmp" && bash "$INIT_SCRIPT" >/dev/null 2>&1)
  local excludes
  excludes=$(jq -r '.exclude_patterns[]' "$tmp/.audit-config.json" 2>/dev/null)
  local has_node=false
  echo "$excludes" | grep -q 'node_modules' && has_node=true
  rm -rf "$tmp"
  $has_node || { ko "config-node: node_modules/ not in excludes"; return; }
  ok "config-node: Node project gets node_modules/ in excludes"
}

# --- Contract: Python project gets __pycache__/ in excludes ---
t_config_stack_aware_python() {
  local tmp
  tmp=$(mktemp -d)
  echo '[tool.pytest.ini_options]' > "$tmp/pyproject.toml"
  (cd "$tmp" && bash "$INIT_SCRIPT" >/dev/null 2>&1)
  local excludes
  excludes=$(jq -r '.exclude_patterns[]' "$tmp/.audit-config.json" 2>/dev/null)
  local has_pycache=false
  echo "$excludes" | grep -q '__pycache__' && has_pycache=true
  rm -rf "$tmp"
  $has_pycache || { ko "config-python: __pycache__/ not in excludes"; return; }
  ok "config-python: Python project gets __pycache__/ in excludes"
}

# --- Contract: skill installs to .claude/skills/ if .claude/ exists ---
t_skill_install_path_claude() {
  local tmp
  tmp=$(mktemp -d)
  mkdir -p "$tmp/.claude"
  echo "# test" > "$tmp/.claude/CLAUDE.md"
  (cd "$tmp" && bash "$INIT_SCRIPT" >/dev/null 2>&1)
  local in_claude=false
  [ -d "$tmp/.claude/skills/self-improvement" ] && in_claude=true
  rm -rf "$tmp"
  $in_claude || { ko "skill-path-claude: skill not installed to .claude/skills/"; return; }
  ok "skill-path-claude: skill installs to .claude/skills/ when .claude/ exists"
}

# --- Contract: link_or_copy doesn't crash when symlinks unavailable ---
t_link_fallback_copy() {
  # Even on Linux where symlinks work, link_or_copy should succeed (symlink path)
  local tmp
  tmp=$(mktemp -d)
  (cd "$tmp" && bash "$INIT_SCRIPT" >/dev/null 2>&1)
  local rc=$?
  rm -rf "$tmp"
  [ "$rc" -eq 0 ] || { ko "link-fallback: init-agents crashed (exit $rc)"; return; }
  ok "link-fallback: link_or_copy succeeded (symlink on this system)"
}

# --- Contract: after scaffolding, audit-project.sh runs and exits 0 ---
t_audit_project_runs() {
  local tmp out
  tmp=$(mktemp -d)
  (cd "$tmp" && bash "$INIT_SCRIPT" >/dev/null 2>&1)
  out=$(cd "$tmp" && bash scripts/audit-project.sh --json 2>/dev/null | jq -r '.summary.fail // -1')
  rm -rf "$tmp"
  [ "$out" = "0" ] || { ko "audit-runs: audit-project.sh --json failed (fail=$out)"; return; }
  ok "audit-runs: audit-project.sh --json exits 0 in scaffolded project ($out failures)"
}

echo "╔═══════════════════════════════════════════════╗"
echo "║  INIT-AGENTS FEATURE TESTS (test-first)       ║"
echo "╚═══════════════════════════════════════════════╝"
echo ""
t_default_creates_all_7
t_skip_no_artifacts
t_config_stack_aware_node
t_config_stack_aware_python
t_skill_install_path_claude
t_link_fallback_copy
t_audit_project_runs
echo ""
echo -e "  ${GREEN}PASS: $PASS${NC}  ${RED}FAIL: $FAIL${NC}"
if [ "$FAIL" -eq 0 ]; then
  echo -e "  ${GREEN}✅ All init tests passed.${NC}"
  exit 0
else
  echo -e "  ${RED}❌ $FAIL test(s) RED — implement install_self_improvement to turn these green.${NC}"
  exit 1
fi
