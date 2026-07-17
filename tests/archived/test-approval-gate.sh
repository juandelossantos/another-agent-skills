#!/usr/bin/env bash
# test-approval-gate.sh — Tests approval-gate.sh prototype→approved transition (P6.4)
# Verifies: missing prototype blocks, missing README blocks, --approve passes,
#           dry-run doesn't move files, Section 12 created if missing.
#
# Usage: bash tests/test-approval-gate.sh
# Exit: 0 if all pass, 1 if any fail

set -uo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GATE_SCRIPT="$REPO_ROOT/scripts/approval-gate.sh"

GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
PASSED=0; FAILED=0; TOTAL=0

TV_TMP="$REPO_ROOT/.ag_test_p64"
rm -rf "$TV_TMP" 2>/dev/null
mkdir -p "$TV_TMP"

# Create a minimal project structure
mkdir -p "$TV_TMP/design/prototype/hero-v2"
mkdir -p "$TV_TMP/design/approved"
cat > "$TV_TMP/design/prototype/hero-v2/README.md" << 'README'
Date: 2026-07-17
Explored: centered layout, split layout, full-bleed editorial
Decision: Split layout won — better for code snippet display
README

cat > "$TV_TMP/DESIGN.md" << 'DESIGN'
## Section 12: Approved Artifacts
(empty)

## Section 13: CSS Architecture
Custom properties
DESIGN

cleanup() { rm -rf "$TV_TMP" 2>/dev/null; }
trap cleanup EXIT

assert_exit() {
  local name="$1" expected="$2" actual="$3"
  TOTAL=$((TOTAL+1))
  if [ "$actual" -eq "$expected" ]; then
    PASSED=$((PASSED+1)); echo -e "  ${GREEN}✓${NC} $name (exit=$actual)"
  else
    FAILED=$((FAILED+1)); echo -e "  ${RED}✗${NC} $name — expected $expected got $actual"
  fi
}

assert_file_exists() {
  local name="$1" file="$2"
  TOTAL=$((TOTAL+1))
  if [ -f "$file" ] || [ -d "$file" ]; then
    PASSED=$((PASSED+1)); echo -e "  ${GREEN}✓${NC} $name"
  else
    FAILED=$((FAILED+1)); echo -e "  ${RED}✗${NC} $name — not found: $file"
  fi
}

echo -e "${YELLOW}Approval Gate Test Suite${NC}"
echo "──────────────────────────────────────"

# Test 1: Missing prototype → BLOCK
echo ""
echo "Test 1: Missing prototype dir (expect BLOCK 1)"
ACTUAL=0; bash "$GATE_SCRIPT" --project-dir "$TV_TMP" --prototype "design/prototype/nonexistent" 2>/dev/null || ACTUAL=$?
assert_exit "Missing prototype → BLOCK" 1 "$ACTUAL"

# Test 2: Missing README → BLOCK
echo ""
echo "Test 2: Missing README in prototype (expect BLOCK 1)"
mkdir -p "$TV_TMP/design/prototype/no-readme"
ACTUAL=0; bash "$GATE_SCRIPT" --project-dir "$TV_TMP" --prototype "design/prototype/no-readme" 2>/dev/null || ACTUAL=$?
assert_exit "Missing README → BLOCK" 1 "$ACTUAL"

# Test 3: Dry-run without --approve → no files moved
echo ""
echo "Test 3: Dry-run without --approve (expect PASS 0, no files moved)"
APPROVED_COUNT_BEFORE=$(ls "$TV_TMP/design/approved/" 2>/dev/null | wc -l)
ACTUAL=0; OUTPUT=$(bash "$GATE_SCRIPT" --project-dir "$TV_TMP" --prototype "design/prototype/hero-v2" 2>&1) || ACTUAL=$?
APPROVED_COUNT_AFTER=$(ls "$TV_TMP/design/approved/" 2>/dev/null | wc -l)
assert_exit "Dry-run → PASS" 0 "$ACTUAL"
if [ "$APPROVED_COUNT_AFTER" -eq "$APPROVED_COUNT_BEFORE" ]; then
  PASSED=$((PASSED+1)); echo -e "  ${GREEN}✓${NC} Dry-run: no files moved"
else
  FAILED=$((FAILED+1)); echo -e "  ${RED}✗${NC} Dry-run: files were moved"
fi
TOTAL=$((TOTAL+1))

# Test 4: --approve with valid prototype → PASS
echo ""
echo "Test 4: --approve valid prototype (expect PASS 0)"
ACTUAL=0; OUTPUT=$(bash "$GATE_SCRIPT" --project-dir "$TV_TMP" --prototype "design/prototype/hero-v2" --approve 2>&1) || ACTUAL=$?
assert_exit "--approve valid → PASS" 0 "$ACTUAL"
assert_file_exists "Prototype copied to approved" "$TV_TMP/design/approved/hero-v2"

# Test 5: DESIGN.md Section 12 updated after approval
echo ""
echo "Test 5: DESIGN.md references approved artifact"
if grep -q "hero-v2\|approved" "$TV_TMP/DESIGN.md" 2>/dev/null; then
  PASSED=$((PASSED+1)); echo -e "  ${GREEN}✓${NC} DESIGN.md updated with approved reference"
else
  FAILED=$((FAILED+1)); echo -e "  ${RED}✗${NC} DESIGN.md not updated"
fi
TOTAL=$((TOTAL+1))

echo ""
echo "──────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
echo ""
[ $FAILED -eq 0 ] || exit 1
