#!/usr/bin/env bash
# test-phase6-e2e.sh — End-to-end Phase 6 gate verification (P6.13-P6.14)
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
P=0; F=0; T=0
assert() { T=$((T+1)); if eval "$2"; then P=$((P+1)); echo -e "  ${GREEN}✓${NC} $1"; else F=$((F+1)); echo -e "  ${RED}✗${NC} $1"; fi; }

echo -e "${YELLOW}Phase 6 E2E Test Suite${NC}"
echo "──────────────────────────────────────"

# P6.13: design-upgrade.sh works on real project
TMPD=$(mktemp -d)
cp -r "$REPO_ROOT/css" "$TMPD/" 2>/dev/null
cp "$REPO_ROOT/index.html" "$TMPD/" 2>/dev/null
bash "$REPO_ROOT/scripts/design-upgrade.sh" --project-dir "$TMPD" 2>/dev/null
assert "design-upgrade generates 17 sections" "[ \$(grep -c '^## Section' \"\$TMPD/DESIGN.md\") -eq 17 ]"
assert "design-upgrade extracts colors" "grep -q '#1A1A18' '$TMPD/DESIGN.md'"
assert "design-upgrade extracts spacing" "grep -q '4px\|8px\|16px' '$TMPD/DESIGN.md'"
assert "design-upgrade extracts fonts" "grep -qi 'Newsreader\|JetBrains' '$TMPD/DESIGN.md'"
rm -rf "$TMPD"

# P6.14: Gates exist and are executable
assert "design-gate.sh exists" "[ -f '$REPO_ROOT/scripts/design-gate.sh' ]"
assert "token-validate.sh exists" "[ -f '$REPO_ROOT/scripts/token-validate.sh' ]"
assert "approval-gate.sh exists" "[ -f '$REPO_ROOT/scripts/approval-gate.sh' ]"
assert "design-upgrade.sh exists" "[ -f '$REPO_ROOT/scripts/design-upgrade.sh' ]"
assert "DESIGN-MD-SCHEMA.md exists" "[ -f '$REPO_ROOT/skills/engineering-fundamentals/guides/DESIGN-MD-SCHEMA.md' ]"
assert "DISCOVERY-GUIDE.md exists" "[ -f '$REPO_ROOT/skills/engineering-fundamentals/guides/DISCOVERY-GUIDE.md' ]"

# P6.9+8: Direction + platform skills have DESIGN.md output
for s in industrial-brutalist-ui minimalist-ui soft-premium-ui; do
  assert "$s has DESIGN.md Output" "grep -q 'DESIGN.md Output' '$REPO_ROOT/skills/$s/SKILL.md'"
done
for s in frontend-web frontend-mobile frontend-desktop frontend-pwa; do
  assert "$s has DESIGN.md Output" "grep -q 'DESIGN.md Output' '$REPO_ROOT/skills/$s/SKILL.md'"
done

echo ""
echo "──────────────────────────────────────"
echo -e "Results: ${GREEN}$P passed${NC}, ${RED}$F failed${NC}, $T total"
echo ""
[ $F -eq 0 ] || exit 1
