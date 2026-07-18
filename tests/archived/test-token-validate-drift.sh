#!/usr/bin/env bash
# test-prompt-drift.sh — Verifies prompt drift detection in token-validate.sh (P6.12)
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$REPO_ROOT/scripts/token-validate.sh"
GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
P=0; F=0; T=0
TV_TMP="$REPO_ROOT/.pd_test_p612"
rm -rf "$TV_TMP" 2>/dev/null; mkdir -p "$TV_TMP"
cleanup() { rm -rf "$TV_TMP" 2>/dev/null; }
trap cleanup EXIT
assert() { T=$((T+1)); if eval "$2"; then P=$((P+1)); echo -e "  ${GREEN}✓${NC} $1"; else F=$((F+1)); echo -e "  ${RED}✗${NC} $1"; fi; }

echo -e "${YELLOW}Prompt Drift Test Suite${NC}"
echo "──────────────────────────────────────"

# Setup: DESIGN.md with font and drift check flag
cat > "$TV_TMP/DESIGN.md" << 'DESIGN'
## Section 3: Typography
Display: Newsreader, Body: system-ui, Mono: JetBrains Mono

## Section 5: Spacing Scale
Baseline: 8px
DESIGN

mkdir -p "$TV_TMP/css"
cat > "$TV_TMP/css/style.css" << 'CSS'
:root { --font-serif: 'Newsreader', serif; }
.element { font-family: var(--font-serif); }
.bad { font-family: 'Comic Sans', cursive; }
CSS

echo ""
echo "Test 1: Detects prompt drift with --drift flag"
ACTUAL=0; OUTPUT=$(bash "$SCRIPT" --design-dir "$TV_TMP" --css-dir "$TV_TMP/css" --drift 2>&1) || ACTUAL=$?
if echo "$OUTPUT" | grep -qi "comic\|drift\|unmatched"; then
  echo -e "  ${GREEN}✓${NC} Drift detection reports unauthorized font"
  P=$((P+1))
else
  echo -e "  ${RED}✗${NC} Drift detection did not flag Comic Sans"
  F=$((F+1))
fi
T=$((T+1))

echo ""
echo "Test 2: --drift flag is documented in --help"
ACTUAL=0; OUTPUT=$(bash "$SCRIPT" --help 2>&1) || ACTUAL=$?
if echo "$OUTPUT" | grep -qi "drift"; then
  echo -e "  ${GREEN}✓${NC} --drift documented in help"
  P=$((P+1))
else
  echo -e "  ${RED}✗${NC} --drift not in help"
  F=$((F+1))
fi
T=$((T+1))

echo ""
echo "──────────────────────────────────────"
echo -e "Results: ${GREEN}$P passed${NC}, ${RED}$F failed${NC}, $T total"
echo ""
[ $F -eq 0 ] || exit 1
