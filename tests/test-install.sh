#!/usr/bin/env bash
# test-install.sh — Tests for install.sh --agent claude (skills + hook wiring)
# and a static sanity check on install.ps1 (its PowerShell counterpart —
# TOOL_GAP: no pwsh available in this environment, so it is checked
# statically, not executed).

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

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

echo "Test: bash install.sh --agent claude (throwaway project)"
TMP_PROJECT=$(mktemp -d)
TMP_CLAUDE_SKILLS=$(mktemp -d)
(cd "$TMP_PROJECT" && CLAUDE_SKILLS_DIR="$TMP_CLAUDE_SKILLS" bash "$REPO_ROOT/install.sh" --agent claude >/tmp/install-test.log 2>&1)

assert "CLAUDE.md installed" "[ -f '$TMP_PROJECT/CLAUDE.md' ]"
assert ".claude-plugin/ installed" "[ -d '$TMP_PROJECT/.claude-plugin' ]"
assert "skills installed to isolated CLAUDE_SKILLS_DIR" "[ -d \"$TMP_CLAUDE_SKILLS/engineering-fundamentals\" ]"
assert ".claude/settings.json created" "[ -f '$TMP_PROJECT/.claude/settings.json' ]"

if command -v jq &>/dev/null && [ -f "$TMP_PROJECT/.claude/settings.json" ]; then
  PRE_COUNT=$(jq '.hooks.PreToolUse | length' "$TMP_PROJECT/.claude/settings.json" 2>/dev/null || echo 0)
  POST_COUNT=$(jq '.hooks.PostToolUse | length' "$TMP_PROJECT/.claude/settings.json" 2>/dev/null || echo 0)
  assert "2 PreToolUse matcher groups (Edit|Write, Bash)" "[ '$PRE_COUNT' -eq 2 ]"
  assert "1 PostToolUse matcher group (Edit|Write)" "[ '$POST_COUNT' -eq 1 ]"

  BASH_HOOK_COUNT=$(jq '.hooks.PreToolUse[] | select(.matcher=="Bash") | .hooks | length' "$TMP_PROJECT/.claude/settings.json" 2>/dev/null || echo 0)
  assert "Bash matcher has 2 commands (pre-flight + commit-approval)" "[ '$BASH_HOOK_COUNT' -eq 2 ]"
fi

echo ""
echo "Test: idempotent re-run does not duplicate hooks"
(cd "$TMP_PROJECT" && CLAUDE_SKILLS_DIR="$TMP_CLAUDE_SKILLS" bash "$REPO_ROOT/install.sh" --agent claude >>/tmp/install-test.log 2>&1)
if command -v jq &>/dev/null; then
  BASH_HOOK_COUNT_2=$(jq '.hooks.PreToolUse[] | select(.matcher=="Bash") | .hooks | length' "$TMP_PROJECT/.claude/settings.json" 2>/dev/null || echo 0)
  assert "re-run: still 2 commands, no duplicates" "[ '$BASH_HOOK_COUNT_2' -eq 2 ]"
fi

echo ""
echo "Test: pre-existing user settings.json is preserved, not overwritten"
TMP_PROJECT2=$(mktemp -d)
mkdir -p "$TMP_PROJECT2/.claude"
cat > "$TMP_PROJECT2/.claude/settings.json" <<'EOF'
{"permissions": {"allow": ["Bash(ls*)"]}, "hooks": {"PreToolUse": [{"matcher": "Bash", "hooks": [{"type": "command", "command": "bash my-own-hook.sh"}]}]}}
EOF
(cd "$TMP_PROJECT2" && CLAUDE_SKILLS_DIR="$TMP_CLAUDE_SKILLS" bash "$REPO_ROOT/install.sh" --agent claude >>/tmp/install-test.log 2>&1)
if command -v jq &>/dev/null; then
  HAS_PERMISSIONS=$(jq '.permissions.allow[0]' "$TMP_PROJECT2/.claude/settings.json" 2>/dev/null)
  HAS_OWN_HOOK=$(jq '[.hooks.PreToolUse[] | select(.matcher=="Bash") | .hooks[] | select(.command=="bash my-own-hook.sh")] | length' "$TMP_PROJECT2/.claude/settings.json" 2>/dev/null || echo 0)
  assert "unrelated 'permissions' key preserved" '[ "$HAS_PERMISSIONS" = "\"Bash(ls*)\"" ]'
  assert "user's own hook command preserved alongside ours" "[ '$HAS_OWN_HOOK' -eq 1 ]"
fi

rm -rf "$TMP_PROJECT" "$TMP_PROJECT2" "$TMP_CLAUDE_SKILLS" /tmp/install-test.log

echo ""
echo "Test: install.ps1 static checks (TOOL_GAP — no pwsh in this environment, not executed)"
PS1="$REPO_ROOT/install.ps1"
assert "Install-ClaudeGlobalSkills function present" "grep -q 'function Install-ClaudeGlobalSkills' '$PS1'"
assert "Configure-ClaudeHooks function present" "grep -q 'function Configure-ClaudeHooks' '$PS1'"
assert "PowerShell version guard present (ConvertFrom-Json -AsHashtable needs PS6+)" "grep -q 'PSVersionTable.PSVersion.Major -lt 6' '$PS1'"
OPEN_BRACES=$(grep -o '{' "$PS1" | wc -l)
CLOSE_BRACES=$(grep -o '}' "$PS1" | wc -l)
assert "braces balanced ($OPEN_BRACES open / $CLOSE_BRACES close)" "[ '$OPEN_BRACES' -eq '$CLOSE_BRACES' ]"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
