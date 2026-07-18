#!/usr/bin/env bash
# test-design-upgrade.sh — Tests design-upgrade.sh auto-extraction (P6.7)
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$REPO_ROOT/scripts/design-upgrade.sh"
GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
P=0; F=0; T=0

TV_TMP="$REPO_ROOT/.du_test_p67"
rm -rf "$TV_TMP" 2>/dev/null; mkdir -p "$TV_TMP"
cleanup() { rm -rf "$TV_TMP" 2>/dev/null; }
trap cleanup EXIT

assert() { T=$((T+1)); if eval "$2"; then P=$((P+1)); echo -e "  ${GREEN}✓${NC} $1"; else F=$((F+1)); echo -e "  ${RED}✗${NC} $1"; fi; }
assert_in_file() { local n="$1" f="$2" p="$3"; T=$((T+1)); if [ -f "$f" ] && grep -qi "$p" "$f"; then P=$((P+1)); echo -e "  ${GREEN}✓${NC} $n"; else F=$((F+1)); echo -e "  ${RED}✗${NC} $n — pattern not found in $f"; fi; }

echo -e "${YELLOW}Design Upgrade Test Suite${NC}"
echo "──────────────────────────────────────"

# Setup: mock project with CSS vars, breakpoints, font loading, and HTML
mkdir -p "$TV_TMP/css"
cat > "$TV_TMP/css/style.css" << 'CSS'
:root {
  --space-xs: 4px;
  --space-sm: 8px;
  --space-md: 16px;
  --space-lg: 24px;
  --space-xl: 32px;
  --bg: #1A1A18;
  --text: #E8E6E3;
  --accent: #DC5C20;
  --border: #2C2A28;
  --radius-sm: 2px;
  --radius-md: 4px;
}
@media (max-width: 768px) { }
@media (max-width: 480px) { }
@media (min-width: 1400px) { }
@media (prefers-reduced-motion: reduce) { }
@media print { }
CSS

cat > "$TV_TMP/index.html" << 'HTML'
<html lang="en" data-theme="dark">
<head>
<link href="https://fonts.googleapis.com/css2?family=Newsreader" rel="stylesheet">
</head>
<body></body>
</html>
HTML

# Run the upgrade
mkdir -p "$TV_TMP/design/approved"
ACTUAL=0; OUTPUT=$(bash "$SCRIPT" --project-dir "$TV_TMP" 2>&1) || ACTUAL=$?

echo ""
echo "Test 1: Generates DESIGN.md"
assert "DESIGN.md created" "[ -f '$TV_TMP/DESIGN.md' ]"

echo ""
echo "Test 2: Extracts spacing scale from CSS"
assert_in_file "Spacing tokens extracted" "$TV_TMP/DESIGN.md" "4px\|8px\|16px"

echo ""
echo "Test 3: Extracts color palette from CSS"
assert_in_file "Color tokens extracted" "$TV_TMP/DESIGN.md" "#1A1A18\|#E8E6E3\|#DC5C20"

echo ""
echo "Test 4: Extracts breakpoints"
assert_in_file "Breakpoints extracted" "$TV_TMP/DESIGN.md" "768\|480\|1400"

echo ""
echo "Test 5: Detects font loading"
assert_in_file "Font loading detected" "$TV_TMP/DESIGN.md" "Newsreader\|Google Fonts\|font"

echo ""
echo "Test 6: Detects theme implementation"
assert_in_file "Theme detected" "$TV_TMP/DESIGN.md" "data-theme\|dark"

echo ""
echo "Test 7: Output has section headers"
SEC_COUNT=$(grep -c '^## Section' "$TV_TMP/DESIGN.md" 2>/dev/null || echo 0)
assert "DESIGN.md has sections (found $SEC_COUNT)" "[ $SEC_COUNT -ge 5 ]"

echo ""
echo "──────────────────────────────────────"
echo -e "Results: ${GREEN}$P passed${NC}, ${RED}$F failed${NC}, $T total"
echo ""
[ $F -eq 0 ] || exit 1
