#!/usr/bin/env bash
# test-index.sh — Content checks for index.html: the new Claude Code parity
# callout in the compatible-agents section, and the updated meta keywords.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FILE="$REPO_ROOT/index.html"

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

assert "meta keywords mentions Claude Code" "grep -q 'name=\"keywords\".*Claude Code' '$FILE'"
assert "compatible section has claudeCallout data-i18n hook" "grep -q 'data-i18n=\"compatible.claudeCallout\"' '$FILE'"
assert "compatible__grid is still present (layout untouched)" "grep -q 'class=\"compatible__grid\"' '$FILE'"
assert "faq.a3 data-i18n hook still present" "grep -q 'data-i18n=\"faq.a3\"' '$FILE'"

DOCS_INDEX="$REPO_ROOT/docs/index.html"
assert "docs/index.html shows current version v6.3.0" "grep -q '<tr><td data-i18n=\"overview.version\">Current version</td><td>v6.3.1</td></tr>' '$DOCS_INDEX'"
assert "docs/index.html shows the real guide count (151)" "grep -q '<tr><td data-i18n=\"overview.guidesCount\">Guides</td><td>151</td></tr>' '$DOCS_INDEX'"
assert "docs/index.html demotes v6.0.0 into Previous releases" "grep -q 'v6.0.0 — Phase 6' '$DOCS_INDEX'"
assert "docs/index.html What's New is v6.3.0" "grep -q \"What's New in v6.3.0\" '$DOCS_INDEX'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
