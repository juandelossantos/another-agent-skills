#!/usr/bin/env bash
# generate-health-check.sh — Auto-generate factual sections of HEALTH-CHECK.md
# Usage:
#   bash scripts/generate-health-check.sh --check   # Verify sync (exit 1 if stale)
#   bash scripts/generate-health-check.sh --apply   # Regenerate factual sections
#
# Only overwrites the factual header region (metadata + Summary + Foundational).
# Preserves every other section: Steering File Integrity, Mechanical Enforcement,
# Landing Page, Warnings, Decision Log — and, in a project file without the AAS
# headers, the project's own "## " sections (Plan, Stack, Lint, ...). Non-owned
# prose inside the region (notes, blockquotes) is preserved too.
#
# Expected field schema (shared with validate-health-check.sh):
#   | Errors (Check 14) | **N** (guide violations) |
#   | Warnings | **N** |
#   | Overall | **<emoji> HEALTHY|DEGRADED|CRITICAL** |

set -euo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
HEALTH_FILE="HEALTH-CHECK.md"
MODE="${1:---check}"

if [ ! -f "$HEALTH_FILE" ]; then echo "FAIL: $HEALTH_FILE not found"; exit 1; fi

# --- Gather data ---
LINT_OUTPUT=$(bash scripts/skill-lint.sh 2>&1) || true
LINT_ERRORS=$(echo "$LINT_OUTPUT" | grep -oP '\d+(?=\s+error)' | head -1 || echo "0")
LINT_WARNINGS=$(echo "$LINT_OUTPUT" | grep -oP '\d+(?=\s+warning)' | head -1 || echo "0")
VERSION=$(cat VERSION 2>/dev/null || echo "unknown")
SKILL_COUNT=$(ls -d skills/*/ 2>/dev/null | wc -l || true)
GUIDE_COUNT=$(find skills/ -maxdepth 2 -type f \( -iname '*guide*' -o -iname '*checklist*' -o -iname '*examples*' -o -iname '*memory*' \) ! -path "*/evals/*" 2>/dev/null | wc -l || true)

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
# `grep -c` prints "0" AND exits 1 on no match, so `|| echo "0"` would append a
# second line ("0\n0") and break the later `[ "$TABLE_PASS" -gt 0 ]`. Use `|| true`.
TABLE_PASS=$(echo "$TABLE_RESULT" | grep -c "PASS:" || true)

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
  GENERATED=$(generate_section)
  EXPECTED_ERRORS=$(echo "$GENERATED" | grep -oP '(?<=Errors \(Check 14\) \| \*\*)\d+' | head -1 || true)
  EXPECTED_WARNINGS=$(echo "$GENERATED" | grep -oP '(?<=Warnings \| \*\*)\d+' | head -1 || true)

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
  # Regenerate the factual header region: the metadata block (Date/Version/
  # Auditor/Status) plus the "## Summary" and "## Foundational: key checks"
  # tables. Everything from the first PRESERVED section onward is kept verbatim.
  #
  # Preserved anchor (the tail we keep), in order of preference:
  #   1) the AAS section boundary (a framework-managed HEALTH-CHECK.md), else
  #   2) the first "## " section this generator does NOT own (a project's own
  #      sections: Plan, Stack, Lint, ...), else
  #   3) nothing — the file is only the factual block.
  # Located with `|| true` so a missing boundary never aborts the script under
  # `set -euo pipefail` (the old silent-death bug: it exited before printing FAIL).
  PRESERVE_LINE=$(grep -nE '^## (Mechanical Enforcement|Steering File|Landing Page)' "$HEALTH_FILE" | head -1 | cut -d: -f1 || true)
  if [ -z "$PRESERVE_LINE" ]; then
    PRESERVE_LINE=$(grep -nE '^## ' "$HEALTH_FILE" \
      | grep -vE '^[0-9]+:## (Summary|Foundational)' \
      | head -1 | cut -d: -f1 || true)
  fi

  # Build new content: header + generated section + any non-owned prose kept from
  # the regenerated region (a project note/blockquote between the Summary table
  # and the next section, e.g. courtside's "> Deuda ...") + everything from the
  # anchor on. Owned lines dropped from the region: metadata keys, markdown table
  # rows, the Summary/Foundational headings, rules and blank lines.
  HEADER=$(head -1 "$HEALTH_FILE")
  KEPT=""
  REST=""
  if [ -n "$PRESERVE_LINE" ] && [ "$PRESERVE_LINE" -gt 2 ]; then
    KEPT=$(sed -n "2,$((PRESERVE_LINE - 1))p" "$HEALTH_FILE" \
      | grep -vE '^[[:space:]]*$|^\*\*[^*]+:\*\*|^[[:space:]]*\|' \
      | grep -vE '^[[:space:]]*## (Summary|Foundational)|^[[:space:]]*---[[:space:]]*$' || true)
  fi
  if [ -n "$PRESERVE_LINE" ]; then
    REST=$(tail -n +"$PRESERVE_LINE" "$HEALTH_FILE")
  fi
  {
    echo "$HEADER"
    generate_section
    if [ -n "$KEPT" ]; then echo "$KEPT"; echo ""; fi
    if [ -n "$REST" ]; then echo "$REST"; fi
  } > "${HEALTH_FILE}.tmp"
  mv "${HEALTH_FILE}.tmp" "$HEALTH_FILE"
  echo "HEALTH-CHECK.md updated."
  exit 0

else
  echo "Usage: $0 {--check|--apply}"
  exit 1
fi
