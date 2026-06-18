#!/usr/bin/env bash
# skill-lint.sh — Validates skill structure and Rule 6 compliance
# Run before committing any SKILL.md changes

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SKILLS_DIR="${1:-skills}"
ERRORS=0
WARNINGS=0

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  SKILL LINT — Rule 6 Compliance Check     ║"
echo "╚════════════════════════════════════════════╝"

for skill_dir in "$SKILLS_DIR"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")
  skill_file="$skill_dir/SKILL.md"

  [ -f "$skill_file" ] || continue

  lines=$(wc -l < "$skill_file")

  # Check 1: SKILL.md must exist and have content
  if [ "$lines" -lt 10 ]; then
    echo "  ${RED}✗${NC} $skill_name — SKILL.md too short ($lines lines, minimum 10)"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  # Check 2: SKILL.md must be under 250 lines (Rule 6: skills as indexes)
  if [ "$lines" -gt 250 ]; then
    echo "  ${RED}✗${NC} $skill_name — SKILL.md exceeds 250 lines ($lines lines)"
    echo "       Rule 6: Skills must be ~250-line indexes. Move detailed content to guides/"
    ERRORS=$((ERRORS + 1))
  else
    echo "  ${GREEN}✓${NC} $skill_name — SKILL.md size OK ($lines lines)"
  fi

  # Check 3: Must have "when to activate" or equivalent
  if ! grep -qiE '(when to (use|activate|invoke)|use when|triggers on|activate when)' "$skill_file"; then
    echo "  ${YELLOW}⚠${NC} $skill_name — No 'when to activate' section found"
    WARNINGS=$((WARNINGS + 1))
  fi

  # Check 4: Must have YAML frontmatter with name and description
  if ! head -5 "$skill_file" | grep -q "^name:"; then
    echo "  ${YELLOW}⚠${NC} $skill_name — Missing 'name' in YAML frontmatter"
    WARNINGS=$((WARNINGS + 1))
  fi

  if ! head -10 "$skill_file" | grep -q "description:"; then
    echo "  ${YELLOW}⚠${NC} $skill_name — Missing 'description' in YAML frontmatter"
    WARNINGS=$((WARNINGS + 1))
  fi

  # Check 5: If skill has guides/, SKILL.md should reference them (index pattern)
  if [ -d "${skill_dir}guides" ]; then
    guide_count=$(find "${skill_dir}guides" -name "*.md" | wc -l)
    ref_count=$(grep -cE 'guides/|→ See' "$skill_file" 2>/dev/null || echo 0)
    if [ "$guide_count" -gt 0 ] && [ "$ref_count" -eq 0 ]; then
      echo "  ${YELLOW}⚠${NC} $skill_name — Has $guide_count guides but SKILL.md doesn't reference them"
      echo "       Rule 6: Skills should be indexes that reference guides"
      WARNINGS=$((WARNINGS + 1))
    fi
  fi

  # Check 6: Micro-skills (<100 lines) are exempt from 2-guide rule
  if [ "$lines" -lt 100 ]; then
    echo "  ${GREEN}✓${NC} $skill_name — Micro-skill ($lines lines), exempt from guide requirement"
  fi

  # --- Skill Smells (based on agentskills.io standard + whitepaper Appendix A) ---

  # Check 7: Description should not start with weak phrases
  if head -10 "$skill_file" | grep -qiE '^description:.*"?[Aa] (helpful|simple|basic) skill'; then
    echo "  ${RED}✗${NC} $skill_name — Description starts with weak phrase ('A helpful skill...')"
    echo "       Rewrite: name the trigger, inputs, and output directly"
    ERRORS=$((ERRORS + 1))
  fi

  # Check 8: Avoid "ALWAYS" and "NEVER" in caps (prefer rationale instead)
  if grep -q '\bALWAYS\b' "$skill_file" 2>/dev/null || grep -q '\bNEVER\b' "$skill_file" 2>/dev/null; then
    echo "  ${YELLOW}⚠${NC} $skill_name — Contains ALWAYS or NEVER in caps"
    echo "       Prefer explaining rationale instead of imperative commands"
    WARNINGS=$((WARNINGS + 1))
  fi

  # Check 9: SKILL.md body should not exceed 5000 tokens (~1250 words heuristic)
  word_count=$(wc -w < "$skill_file")
  if [ "$word_count" -gt 1250 ]; then
    echo "  ${YELLOW}⚠${NC} $skill_name — $word_count words (may exceed 5000 token limit)"
    echo "       Move detailed content to references/ directory"
    WARNINGS=$((WARNINGS + 1))
  fi

  # Check 10: Should use at least one of scripts/, references/, assets/, or guides/
  has_scripts=false; has_refs=false; has_assets=false; has_guides=false
  [ -d "${skill_dir}scripts" ] && has_scripts=true
  [ -d "${skill_dir}references" ] && has_refs=true
  [ -d "${skill_dir}assets" ] && has_assets=true
  [ -d "${skill_dir}guides" ] && has_guides=true
  if [ "$lines" -ge 150 ] && ! $has_scripts && ! $has_refs && ! $has_assets && ! $has_guides; then
    echo "  ${YELLOW}⚠${NC} $skill_name — No scripts/, references/, assets/, or guides/ directories"
    echo "       Skills over 150 lines should leverage progressive disclosure"
    WARNINGS=$((WARNINGS + 1))
  fi

  # Check 11: Description should include version field
  if ! head -15 "$skill_file" | grep -q "^version:"; then
    echo "  ${YELLOW}⚠${NC} $skill_name — Missing 'version' in YAML frontmatter"
    WARNINGS=$((WARNINGS + 1))
  fi

  # Check 12: Description should include allowed-tools field
  if ! head -15 "$skill_file" | grep -q "^allowed-tools:"; then
    echo "  ${YELLOW}⚠${NC} $skill_name — Missing 'allowed-tools' in YAML frontmatter"
    WARNINGS=$((WARNINGS + 1))
  fi

  # Check 13: Description should include tier field
  if ! head -15 "$skill_file" | grep -q "^tier:"; then
    echo "  ${YELLOW}⚠${NC} $skill_name — Missing 'tier' in YAML frontmatter"
    WARNINGS=$((WARNINGS + 1))
  fi
done

echo ""
echo "───"
if [ "$ERRORS" -gt 0 ]; then
  echo "  ${RED}$ERRORS error(s), $WARNINGS warning(s)${NC}"
  echo "  Fix errors before committing. Warnings are non-blocking."
  exit 1
elif [ "$WARNINGS" -gt 0 ]; then
  echo "  ${YELLOW}0 errors, $WARNINGS warning(s)${NC}"
  echo "  Warnings are non-blocking but recommend fixing."
  exit 0
else
  echo "  ${GREEN}0 errors, 0 warnings — all skills compliant${NC}"
  exit 0
fi
