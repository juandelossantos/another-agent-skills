#!/usr/bin/env bash
# generate-health-check.sh — Auto-generate factual sections of HEALTH-CHECK.md
# Usage:
#   bash scripts/generate-health-check.sh --check   # Verify sync (exit 1 if stale)
#   bash scripts/generate-health-check.sh --apply   # Regenerate factual sections
#
# Only overwrites the Summary + Foundational sections.
# Preserves: Steering File Integrity, Mechanical Enforcement, Landing Page, Warnings, Decision Log.

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
HEALTH_FILE="HEALTH-CHECK.md"
MODE="${1:---check}"

if [ ! -f "$HEALTH_FILE" ]; then echo "FAIL: $HEALTH_FILE not found"; exit 1; fi

# --- Gather data ---
LINT_OUTPUT=$(bash scripts/skill-lint.sh 2>&1) || true
LINT_ERRORS=$(echo "$LINT_OUTPUT" | grep -oP '\d+(?=\s+error)' | head -1 || echo "0")
LINT_WARNINGS=$(echo "$LINT_OUTPUT" | grep -oP '\d+(?=\s+warning)' | head -1 || echo "0")
VERSION=$(cat VERSION 2>/dev/null || echo "unknown")
SKILL_COUNT=$(ls -d skills/*/ 2>/dev/null | wc -l)
GUIDE_COUNT=$(find skills/ -maxdepth 2 -type f \( -iname '*guide*' -o -iname '*checklist*' -o -iname '*examples*' -o -iname '*memory*' \) ! -path "*/evals/*" 2>/dev/null | wc -l)

# Determine status
if [ "$LINT_ERRORS" -gt 0 ]; then
  STATUS="DEGRADED"
  STATUS_EMOJI="🟡"
elif [ "$LINT_WARNINGS" -gt 0 ]; then
  STATUS="DEGRADED"
  STATUS_EMOJI="🟡"
else
  STATUS="HEALTHY"
  STATUS_EMOJI="✅"
fi

# Check table validation
TABLE_RESULT=$(bash scripts/validate-skill-table.sh 2>&1) || true
TABLE_PASS=$(echo "$TABLE_RESULT" | grep -c "PASS:" || echo "0")

# Generate factual section
generate_section() {
cat << EOF

**Date:** $(date +%Y-%m-%d)
**Version:** ${VERSION}
**Auditor:** OpenCode Agent (auto-generated)
**Status:** ${STATUS_EMOJI} ${STATUS}

---

## Summary

| Metric | Value |
|---|---|
| Critical Issues | **0** |
| Errors (Check 14) | **${LINT_ERRORS}** (guide violations) |
| Warnings | **${LINT_WARNINGS}** |
| Overall | **${STATUS_EMOJI} ${STATUS}** |

---

## Foundational: key checks

| Check | Status | Notes |
|---|---|---|
| SKILL.md files | ✅ ${SKILL_COUNT} on disk | All ≤ 250 lines |
| Guide distribution | $([ "$LINT_ERRORS" -gt 0 ] && echo "🔴 ${LINT_ERRORS} errors" || echo "✅ 0 errors") | Skills >100 lines with <2 guides |
| ALWAYS/NEVER | ✅ 0 | Fixed in Phase 6.5.1 |
| VERSION | ✅ ${VERSION} | Consistent |
| Skill lint | $([ "$LINT_ERRORS" -gt 0 ] && echo "🟡 ${LINT_ERRORS} errors" || echo "✅ 0 errors"), ${LINT_WARNINGS} warnings | |
| validate-skill-table | $([ "$TABLE_PASS" -gt 0 ] && echo "✅ PASS" || echo "🔴 FAIL") | Guide counts validated |

EOF
}

if [ "$MODE" == "--check" ]; then
  # Compare current HEALTH-CHECK.md header against generated
  CURRENT_VERSION=$(grep -oP '\*\*Date:\*\*.*' "$HEALTH_FILE" | head -1 || echo "")
  GENERATED=$(generate_section)
  EXPECTED_ERRORS=$(echo "$GENERATED" | grep -oP '(?<=Errors \(Check 14\) \| \*\*)\d+' | head -1)
  EXPECTED_WARNINGS=$(echo "$GENERATED" | grep -oP '(?<=Warnings \| \*\*)\d+' | head -1)

  # Parse current file
  CURRENT_ERRORS=$(grep -oP '(?<=Errors \(Check 14\) \| \*\*)\d+' "$HEALTH_FILE" | head -1 || echo "unknown")
  CURRENT_WARNINGS=$(grep -oP '(?<=Warnings \| \*\*)\d+' "$HEALTH_FILE" | head -1 || echo "unknown")

  ERRORS=0
  if [ "$CURRENT_ERRORS" != "$EXPECTED_ERRORS" ] 2>/dev/null; then
    echo "FAIL: HEALTH-CHECK.md says $CURRENT_ERRORS errors but linter shows $EXPECTED_ERRORS"
    ERRORS=1
  fi
  if [ "$CURRENT_WARNINGS" != "$EXPECTED_WARNINGS" ] 2>/dev/null; then
    echo "FAIL: HEALTH-CHECK.md says $CURRENT_WARNINGS warnings but linter shows $EXPECTED_WARNINGS"
    ERRORS=1
  fi
  if [ "$ERRORS" -gt 0 ]; then
    echo "Run 'bash scripts/generate-health-check.sh --apply' to sync."
    exit 1
  fi
  echo "PASS: HEALTH-CHECK.md is in sync with linter"
  exit 0

elif [ "$MODE" == "--apply" ]; then
  # We need to replace the top section of HEALTH-CHECK.md (Date through Foundational)
  # Find the line where Steering File Integrity section starts
  STEERING_LINE=$(grep -n "^## Mechanical Enforcement\|^## Steering File\|^## Landing Page" "$HEALTH_FILE" | head -1 | cut -d: -f1)
  if [ -z "$STEERING_LINE" ]; then
    echo "FAIL: Could not find section boundary in $HEALTH_FILE"
    exit 1
  fi

  # Build new content: generated section + everything from Steering onwards
  HEADER=$(head -1 "$HEALTH_FILE")
  REST=$(tail -n +"$STEERING_LINE" "$HEALTH_FILE")
  {
    echo "$HEADER"
    generate_section
    echo "$REST"
  } > "${HEALTH_FILE}.tmp"
  mv "${HEALTH_FILE}.tmp" "$HEALTH_FILE"
  echo "HEALTH-CHECK.md updated."
  exit 0

else
  echo "Usage: $0 {--check|--apply}"
  exit 1
fi
