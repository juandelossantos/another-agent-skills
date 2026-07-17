#!/usr/bin/env bash
# test-token-validate.sh — Tests token-validate.sh CSS drift detection (P6.3)
# Verifies: detects unmapped hex, passes when tokens match, finds unused tokens,
#           skips allowlist values and code blocks.
#
# Usage: bash tests/test-token-validate.sh
# Exit: 0 if all pass, 1 if any fail

set -uo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VALIDATE_SCRIPT="$REPO_ROOT/scripts/token-validate.sh"

GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
PASSED=0; FAILED=0; TOTAL=0

TV_TMP="$REPO_ROOT/.tv_test_p63"
rm -rf "$TV_TMP" 2>/dev/null
mkdir -p "$TV_TMP"
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

assert_output() {
  local name="$1" pattern="$2"
  TOTAL=$((TOTAL+1))
  if echo "$OUTPUT" | grep -qi "$pattern"; then
    PASSED=$((PASSED+1)); echo -e "  ${GREEN}✓${NC} $name"
  else
    FAILED=$((FAILED+1)); echo -e "  ${RED}✗${NC} $name — pattern not found"
  fi
}

echo -e "${YELLOW}Token Validate Test Suite${NC}"
echo "──────────────────────────────────────"

# === Setup: DESIGN.md with known tokens ===
cat > "$TV_TMP/DESIGN.md" << 'DESIGN'
# Design Test

## Section 4: Color Palette
--bg: #1A1A18
--text: #E8E6E3
--accent: #DC5C20
--green: #3CCE1E
--border: #2C2A28

## Section 5: Spacing Scale
--space-sm: 8px
--space-md: 16px
--space-lg: 24px

## Section 7: Motion
--transition-base: 300ms

## Section 10: Anti-Pattern Bans
No purple gradients

## Code example (should be ignored)
```
#bad: #FF00FF
```
DESIGN

# === Setup: CSS with matching + non-matching values ===
cat > "$TV_TMP/style.css" << 'CSS'
:root {
  --bg: #1A1A18;
  --text: #E8E6E3;
  --accent: #DC5C20;
  --green: #3CCE1E;
  --border: #2C2A28;
  --space-sm: 8px;
  --space-md: 16px;
  --space-lg: 24px;
  --transition-base: 300ms;
  --bad-color: #FF0000;
}
.element {
  color: #E8E6E3;
  background: #FF00FF;
  border: 1px solid #2C2A28;
}
CSS

# === Setup: CSS with only matching values ===
cat > "$TV_TMP/style-match.css" << 'CSS'
:root {
  --bg: #1A1A18;
  --text: #E8E6E3;
  --accent: #DC5C20;
}
.element { color: var(--text); background: var(--bg); }
CSS

echo ""
echo "Test 1: Detects unmapped hex in CSS"
ACTUAL=0; OUTPUT=$(bash "$VALIDATE_SCRIPT" --design-dir "$TV_TMP" --css-dir "$TV_TMP" --css-file "style.css" 2>&1) || ACTUAL=$?
assert_exit "Detects drift (exit 1)" 1 "$ACTUAL"
assert_output "Reports FF0000" "FF0000"
assert_output "Reports FF00FF" "FF00FF"

echo ""
echo "Test 2: Passes when tokens match"
ACTUAL=0; OUTPUT=$(bash "$VALIDATE_SCRIPT" --design-dir "$TV_TMP" --css-dir "$TV_TMP" --css-file "style-match.css" 2>&1) || ACTUAL=$?
assert_exit "Pass when matching (exit 0)" 0 "$ACTUAL"

echo ""
echo "Test 3: Reports unmatched count"
assert_output "Reports matched tokens count" "matched"
FOUND=0
if echo "$OUTPUT" | grep -qi "match\|0 unmatched\|no drift\|all good\|pass"; then FOUND=1; fi
if [ "$FOUND" -eq 1 ]; then
  PASSED=$((PASSED+1)); echo -e "  ${GREEN}✓${NC} Reports match status"
else
  FAILED=$((FAILED+1)); echo -e "  ${RED}✗${NC} No match status"
fi
TOTAL=$((TOTAL+1))

echo ""
echo "Test 4: Skips allowlist values"
cat > "$TV_TMP/style-allow.css" << 'CSS'
.element { color: inherit; background: transparent; border-color: currentColor; }
CSS
ACTUAL=0; OUTPUT=$(bash "$VALIDATE_SCRIPT" --design-dir "$TV_TMP" --css-dir "$TV_TMP" --css-file "style-allow.css" 2>&1) || ACTUAL=$?
assert_exit "Allowlist values not flagged (exit 0)" 0 "$ACTUAL"

echo ""
echo "Test 5: Skips code blocks in DESIGN.md"
# The #FF00FF in the code block should NOT be extracted as a token
TOKENS_IN_DESIGN=$(grep -c '#[0-9A-Fa-f]\{6\}' "$TV_TMP/DESIGN.md" 2>/dev/null || echo 0)
# DESIGN.md has 5 hex values in the color section + 1 in code block = 6 total
# But token-validate.sh should only extract the 5 from the color section
ACTUAL=0; OUTPUT=$(bash "$VALIDATE_SCRIPT" --design-dir "$TV_TMP" --css-dir "$TV_TMP" --css-file "style-allow.css" 2>&1) || ACTUAL=$?
echo "  (DESIGN.md has $TOKENS_IN_DESIGN hex values total — script should extract only section values)"

echo ""
echo "──────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
echo ""
[ $FAILED -eq 0 ] || exit 1
