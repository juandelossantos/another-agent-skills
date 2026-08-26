#!/usr/bin/env bash
# test-i18n-en-es.sh — Validates i18n/{en,es}.json and docs/i18n/{en,es}.json:
# valid JSON, 100% key parity between EN/ES, and presence of the new
# Claude Code parity copy added in both languages.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
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

flat_keys() { jq -r 'paths(scalars) | join(".")' "$1" | sort; }

for pair in "i18n/en.json:i18n/es.json" "docs/i18n/en.json:docs/i18n/es.json"; do
  en="${pair%%:*}"; es="${pair##*:}"
  assert "$en is valid JSON" "jq empty '$REPO_ROOT/$en' 2>/dev/null"
  assert "$es is valid JSON" "jq empty '$REPO_ROOT/$es' 2>/dev/null"
  DIFF=$(diff <(flat_keys "$REPO_ROOT/$en") <(flat_keys "$REPO_ROOT/$es"))
  assert "$en and $es have identical key sets" "[ -z '$DIFF' ]"
done

assert "i18n/en.json has compatible.claudeCallout" "jq -e '.compatible.claudeCallout' '$REPO_ROOT/i18n/en.json' >/dev/null 2>&1"
assert "i18n/es.json has compatible.claudeCallout" "jq -e '.compatible.claudeCallout' '$REPO_ROOT/i18n/es.json' >/dev/null 2>&1"
assert "i18n/en.json faq.a3 mentions Claude Code parity" "jq -r '.faq.a3' '$REPO_ROOT/i18n/en.json' | grep -qi 'full automatic parity\\|full.*parity'"

assert "docs/i18n/en.json agents.claudeCodeDesc mentions ~/.claude/skills/" "jq -r '.agents.claudeCodeDesc' '$REPO_ROOT/docs/i18n/en.json' | grep -q '~/.claude/skills/'"
assert "docs/i18n/es.json agents.claudeCodeDesc mentions ~/.claude/skills/" "jq -r '.agents.claudeCodeDesc' '$REPO_ROOT/docs/i18n/es.json' | grep -q '~/.claude/skills/'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
