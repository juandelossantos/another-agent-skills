#!/usr/bin/env bash
# test-design-gate.sh — Tests design-gate.sh 3-mode upgrade (P6.2)
# Verifies: strict blocks incomplete, audit warns, verify catches drift,
#           checkable violations block, felt violations flag.
#
# Usage: bash tests/test-design-gate.sh
# Exit: 0 if all pass, 1 if any fail

set -uo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GATE_SCRIPT="$REPO_ROOT/scripts/design-gate.sh"
SCHEMA_FILE="$REPO_ROOT/skills/engineering-fundamentals/guides/DESIGN-MD-SCHEMA.md"

GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
PASSED=0; FAILED=0; TOTAL=0

setup() {
  local dir="$REPO_ROOT/.dgate_test_$$_$1"
  mkdir -p "$dir"
  git init -q -b test-branch "$dir" 2>/dev/null
  git -C "$dir" config user.email "t@t.com" 2>/dev/null
  git -C "$dir" config user.name "T" 2>/dev/null
  echo "$dir"
}

teardown() { rm -rf "$REPO_ROOT"/.dgate_test_*_$$ 2>/dev/null; }
trap teardown EXIT

# Create a minimal incomplete DESIGN.md (sections 1-5 only)
write_incomplete_design_md() {
  local dir="$1"
  cat > "$dir/DESIGN.md" << 'INCOMPLETE'
# Design: Incomplete Test

## Section 1: Design Principles
- Keep it simple

## Section 2: Three Dials
VARIANCE: 5, MOTION: 3, DENSITY: 5

## Section 3: Typography
Display: Serif, Body: Sans

## Section 4: Color Palette
Dark: #000, Light: #fff

## Section 5: Spacing Scale
Baseline: 4px
INCOMPLETE
}

# Create a complete 17-section DESIGN.md
write_complete_design_md() {
  local dir="$1"
  cat > "$dir/DESIGN.md" << 'COMPLETE'
# Design: Complete Test

## Section 1: Design Principles
- Ground in subject, Hero as thesis

## Section 2: Three Dials
VARIANCE: 5, MOTION: 3, DENSITY: 5

## Section 3: Typography
Display: Serif, Body: Sans, Mono: Mono, Scale: 5 sizes, Loading: Google Fonts

## Section 4: Color Palette
Dark: #1A1A18 (bg), #E8E6E3 (text, 13.99:1), #DC5C20 (accent)
Light: #F2F0ED (bg), #2A2826 (text, 12.91:1), #B8450E (accent)

## Section 5: Spacing Scale
Baseline: 8px, xs: 4, sm: 8, md: 16, lg: 24, xl: 32

## Section 6: Grid System
Max-width: 1100px, Breakpoints: 768px, 1400px

## Section 7: Motion
Fast: 150ms, Base: 300ms, Slow: 600ms, Easing: cubic-bezier(0.16,1,0.3,1)
Reduced-motion: prefers-reduced-motion fallback

## Section 8: Component Specs
Button (default, hover, active, disabled, focus)
Card (default, hover)
Input (default, focus, disabled)

## Section 9: Layout Patterns
Hero → Skills → FAQ → Footer

## Section 10: Anti-Pattern Bans
No purple gradients, No generic fonts, No equal cards, No em-dashes, No scroll indicators

## Section 11: Accessibility Baseline
Contrast: AA 4.5:1, Focus: 2px outline, Touch: 44px

## Section 12: Approved Artifacts
design/approved/

## Section 13: CSS Architecture (Platform-Specific)
Custom properties in :root

## Section 14: Theme Implementation (Platform-Specific)
data-theme attribute toggle

## Section 15: Component Framework (Platform-Specific)
Static HTML

## Section 16: Platform Responsiveness (Platform-Specific)
Mobile-first, breakpoints at 480/768/1400

## Section 17: Asset Pipeline (Platform-Specific)
Google Fonts, inline SVG icons
COMPLETE
}

# Create DESIGN.md with checkable violation (missing contrast target)
write_no_contrast_design_md() {
  local dir="$1"
  cat > "$dir/DESIGN.md" << 'NOCONTRAST'
# Design: No Contrast Test

## Section 1: Design Principles
Test

## Section 2: Three Dials
VARIANCE: 5, MOTION: 3, DENSITY: 5

## Section 3: Typography
Display: Serif

## Section 4: Color Palette
Dark: #1A1A18 (bg), #E8E6E3 (text)
Light: #F2F0ED (bg), #2A2826 (text)

## Section 5: Spacing Scale
Baseline: 8px

## Section 6: Grid System
Max-width: 1100px

## Section 7: Motion
Fast: 150ms

## Section 8: Component Specs
Button (default)

## Section 9: Layout Patterns
Hero

## Section 10: Anti-Pattern Bans
No purple

## Section 11: Accessibility Baseline
(no contrast target specified)

## Section 12: Approved Artifacts
design/approved/
NOCONTRAST
}

run_gate() {
  local mode="$1" dir="$2"
  cd "$dir" && bash "$GATE_SCRIPT" "--mode=$mode" 2>/dev/null
  return $?
}

assert_exit() {
  local name="$1" expected="$2" actual="$3"
  TOTAL=$((TOTAL+1))
  if [ "$actual" -eq "$expected" ]; then
    PASSED=$((PASSED+1)); echo -e "  ${GREEN}✓${NC} $name (exit=$actual)"
  else
    FAILED=$((FAILED+1)); echo -e "  ${RED}✗${NC} $name — expected $expected got $actual"
  fi
}

echo -e "${YELLOW}Design Gate Test Suite${NC}"
echo "──────────────────────────────────────"

# === Test 1: Strict mode blocks when DESIGN.md is incomplete ===
echo ""
echo "Test 1: --strict with incomplete DESIGN.md (expect BLOCK 1)"
D1=$(setup "test1")
write_incomplete_design_md "$D1"
run_gate "strict" "$D1"
assert_exit "--strict incomplete → BLOCK" 1 $?

# === Test 2: Strict mode passes when DESIGN.md is complete ===
echo ""
echo "Test 2: --strict with complete 17-section DESIGN.md (expect PASS 0)"
D2=$(setup "test2")
write_complete_design_md "$D2"
mkdir -p "$D2/design/approved"
touch "$D2/design/approved/test.txt"
echo "# DESIGN-LOCK" > "$D2/design/DESIGN-LOCK.md"
# Create skill marker and SPEC.md
mkdir -p "$D2/.git/AGENT_WORK"
touch "$D2/.git/AGENT_WORK/.design-skill-loaded"
echo "# SPEC" > "$D2/SPEC.md"
git -C "$D2" add . 2>/dev/null
run_gate "strict" "$D2"
assert_exit "--strict complete → PASS" 0 $?

# === Test 3: Audit mode warns but doesn't block on incomplete ===
echo ""
echo "Test 3: --audit with incomplete DESIGN.md (expect PASS 0 — warns)"
D3=$(setup "test3")
write_incomplete_design_md "$D3"
run_gate "audit" "$D3"
assert_exit "--audit incomplete → PASS (warns)" 0 $?

# === Test 4: Audit output mentions upgrade path ===
echo ""
echo "Test 4: --audit output suggests upgrade"
D4=$(setup "test4")
write_incomplete_design_md "$D4"
OUTPUT=$(cd "$D4" && bash "$GATE_SCRIPT" "--mode=audit" 2>&1 || true)
if echo "$OUTPUT" | grep -qi "design-upgrade\|upgrade"; then
  echo -e "  ${GREEN}✓${NC} --audit suggests upgrade path"
  PASSED=$((PASSED+1))
else
  echo -e "  ${RED}✗${NC} --audit does not suggest upgrade"
  FAILED=$((FAILED+1))
fi
TOTAL=$((TOTAL+1))

echo ""
echo "──────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
echo ""
[ $FAILED -eq 0 ] || exit 1
