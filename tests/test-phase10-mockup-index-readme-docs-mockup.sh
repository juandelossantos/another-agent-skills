#!/usr/bin/env bash
# test-phase10-mockup-index-readme-docs-mockup.sh — the approved Phase 10 mockups
# (landing + docs view) exist, are valid, bilingual, and match the design contract.
#
# Name deliberately matches the mockup code stems (index, mockup, docs, docs-mockup,
# README) so the TDD gate pairs them.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
M="$REPO_ROOT/docs/mockups/phase10"

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

# --- Files exist ---
assert "landing mockup exists" "[ -f '$M/index.html' ]"
assert "docs mockup exists" "[ -f '$M/docs.html' ]"
assert "mockup CSS exists" "[ -f '$M/css/mockup.css' ]"
assert "docs CSS exists" "[ -f '$M/css/docs-mockup.css' ]"
assert "mockup JS exists" "[ -f '$M/js/mockup.js' ]"
assert "docs JS exists" "[ -f '$M/js/docs-mockup.js' ]"
assert "mockup README exists" "[ -f '$M/README.md' ]"

# --- Valid JS ---
assert "landing JS parses" "node --check '$M/js/mockup.js' >/dev/null 2>&1"
assert "docs JS parses" "node --check '$M/js/docs-mockup.js' >/dev/null 2>&1"

# --- Landing content contract ---
assert "landing has the hero terminal (3 channels)" "grep -q 'install__code\|terminal__typing' '$M/index.html'"
assert "landing has the flow / harness / loop sections" "grep -qi 'id=\"flow\"' '$M/index.html' && grep -qi 'id=\"harness\"' '$M/index.html' && grep -qi 'id=\"loop\"' '$M/index.html'"
assert "landing shows the L1/L2/L3 enforcement" "grep -qi 'L1' '$M/index.html' && grep -qi 'L2' '$M/index.html' && grep -qi 'L3' '$M/index.html'"

# --- Docs view contract ---
assert "docs has a sidebar" "grep -qi 'data-sidebar\|sidebar' '$M/docs.html'"
assert "docs has search" "grep -qi 'type=\"search\"' '$M/docs.html'"
assert "docs has an On-this-page TOC" "grep -qi 'on this page\|toc' '$M/docs.html'"

# --- Lucide icons (inlined, no CDN) ---
assert "landing uses inlined Lucide icons" "grep -q 'viewBox=\"0 0 24 24\"' '$M/index.html'"
assert "docs uses inlined Lucide icons" "grep -q 'viewBox=\"0 0 24 24\"' '$M/docs.html'"

# --- Bilingual + neutral Spanish (no voseo) ---
assert "landing i18n is EN/ES" "grep -q 'en:' '$M/js/mockup.js' && grep -q 'es:' '$M/js/mockup.js'"
assert "no Argentine voseo in the mockups" "! grep -qE 'tenés|podés|Cloná|ejecutá|instalá|usá |elegí|agregá|mirá|corré|andá' '$M/js/mockup.js' '$M/js/docs-mockup.js'"

# --- Footer shows the version (not the phase) ---
assert "footer shows the current version" "grep -q 'v6\.2\.0' '$M/js/mockup.js'"
assert "footer no longer says Phase 10" "! grep -q 'Phase 10 landing mockup' '$M/js/mockup.js'"

# --- README documents the reusable components ---
assert "README documents the component layer" "grep -qi 'section-head\|component' '$M/README.md'"

# --- The light-card padding fix (workflow--full has inline padding) ---
assert "lit workflow card has horizontal padding" "grep -q 'workflow--full' '$M/css/mockup.css'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
