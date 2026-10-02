#!/usr/bin/env bash
# test-enforcement-honesty.sh — Docs honesty for the enforcement page (Phase 8, P8.5).
#
# INCIDENT_004 never added "main branch protection" — the fix was a LOCAL Gate 1
# branch check in pre-commit. Remote branch protection arrived later, in Phase 8.
# This suite guards against that false claim coming back and checks the L1/L2/L3
# model is documented and localized (EN/ES).

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
HTML="$REPO_ROOT/docs/enforcement.html"
EN="$REPO_ROOT/docs/i18n/en.json"
ES="$REPO_ROOT/docs/i18n/es.json"

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

# --- The false claim is gone, everywhere ---
assert "enforcement.html drops 'Added main branch protection'" "! grep -q 'Added main branch protection' '$HTML'"
assert "en.json drops 'Added main branch protection'" "! grep -q 'Added main branch protection' '$EN'"
assert "es.json drops 'protección de branch main'" "! grep -q 'protección de branch main' '$ES'"
assert "no doc claims INCIDENT_004 added branch protection" "! grep -rqi 'Added main branch protection' '$REPO_ROOT/docs/'"

# --- The honest replacement is present ---
assert "enforcement.html credits the local Gate 1 branch check" "grep -q 'Gate 1 branch check' '$HTML'"
assert "en.json credits the local Gate 1 branch check" "grep -q 'Gate 1 branch check' '$EN'"
assert "en.json notes the remote layer came in Phase 8" "grep -q 'Remote branch protection came later, in Phase 8' '$EN'"
assert "es.json notes the remote layer came in Phase 8" "grep -q 'La branch protection remota llegó después, en Phase 8' '$ES'"

# --- EN/ES parity for the incident line ---
assert "es.json has an incident4 key" "grep -q '\"incident4\"' '$ES'"
assert "incident4 is translated (ES differs from EN)" "! diff <(grep '\"incident4\"' '$EN') <(grep '\"incident4\"' '$ES') >/dev/null 2>&1"

# --- The L1/L2/L3 model is documented and localized ---
assert "enforcement.html has the layers section" "grep -q 'enforcement.layersTitle' '$HTML'"
assert "layers desc renders HTML so the link works" "grep -q 'data-i18n=\"enforcement.layersDesc\" data-i18n-html' '$HTML'"
assert "enforcement.html links the three-layer model" "grep -q 'BRANCH-PROTECTION.md' '$HTML'"
assert "en.json has layersTitle" "grep -q '\"layersTitle\"' '$EN'"
assert "en.json has layersDesc" "grep -q '\"layersDesc\"' '$EN'"
assert "es.json has layersTitle" "grep -q '\"layersTitle\"' '$ES'"
assert "es.json has layersDesc" "grep -q '\"layersDesc\"' '$ES'"

# --- i18n files stay valid JSON ---
assert "en.json is valid JSON" "python3 -c 'import json,sys; json.load(open(sys.argv[1]))' '$EN' 2>/dev/null || jq empty '$EN' 2>/dev/null"
assert "es.json is valid JSON" "python3 -c 'import json,sys; json.load(open(sys.argv[1]))' '$ES' 2>/dev/null || jq empty '$ES' 2>/dev/null"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
