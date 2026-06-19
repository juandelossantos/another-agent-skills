#!/bin/sh
# validate-health-check.sh — Verify HEALTH-CHECK.md reflects current linter state
# Compares factual sections against live skill-lint.sh output
# Exit codes: 0 = PASS, 1 = FAIL (HEALTH-CHECK.md out of sync)

set -e

HEALTH_FILE="HEALTH-CHECK.md"
ERRORS=0

if [ ! -f "$HEALTH_FILE" ]; then
  echo "FAIL: $HEALTH_FILE not found"
  exit 1
fi

echo "=== Validating $HEALTH_FILE against live linter state ==="

# Run linter and capture output
LINT_OUTPUT=$(bash scripts/skill-lint.sh 2>&1) || true

# Parse linter error/warning counts
LINT_ERRORS=$(echo "$LINT_OUTPUT" | grep -oP '\d+(?=\s+error)' | head -1 || echo "0")
LINT_WARNINGS=$(echo "$LINT_OUTPUT" | grep -oP '\d+(?=\s+warning)' | head -1 || echo "0")

# Parse HEALTH-CHECK.md summary values
HC_ERRORS=$(grep -oP '(?<=Errors).*\*\*\d+\*\*' "$HEALTH_FILE" | grep -oP '\*\*\d+\*\*' | grep -oP '\d+' | head -1 || echo "0")
HC_WARNINGS=$(grep -oP 'Warnings\s*\|\s*\*\*\d+\*\*' "$HEALTH_FILE" | grep -oP '\d+' || echo "unknown")
HC_OVERALL=$(grep 'Overall' "$HEALTH_FILE" | grep -oP '(HEALTHY|DEGRADED|CRITICAL)' || echo "unknown")

# Determine expected status from error count
if [ "$LINT_ERRORS" -gt 0 ]; then
  EXPECTED_STATUS="DEGRADED"
elif [ "$LINT_WARNINGS" -gt 0 ]; then
  EXPECTED_STATUS="DEGRADED"
else
  EXPECTED_STATUS="HEALTHY"
fi

echo "  Linter: $LINT_ERRORS errors, $LINT_WARNINGS warnings"
echo "  Health: errors=$HC_ERRORS, warnings=$HC_WARNINGS, status=$HC_OVERALL"
echo "  Expected status: $EXPECTED_STATUS"
echo ""

# Compare
if [ "$HC_ERRORS" != "$LINT_ERRORS" ] 2>/dev/null; then
  echo "FAIL: HEALTH-CHECK.md claims $HC_ERRORS errors but linter shows $LINT_ERRORS"
  ERRORS=$((ERRORS + 1))
fi

if [ "$HC_WARNINGS" != "$LINT_WARNINGS" ] 2>/dev/null; then
  echo "FAIL: HEALTH-CHECK.md claims $HC_WARNINGS warnings but linter shows $LINT_WARNINGS"
  ERRORS=$((ERRORS + 1))
fi

if [ "$HC_OVERALL" != "$EXPECTED_STATUS" ] 2>/dev/null; then
  echo "FAIL: HEALTH-CHECK.md status is $HC_OVERALL but should be $EXPECTED_STATUS ($LINT_ERRORS errors)"
  ERRORS=$((ERRORS + 1))
fi

echo "---"
if [ "$ERRORS" -eq 0 ]; then
  echo "PASS: HEALTH-CHECK.md matches linter state"
  exit 0
else
  echo "FAIL: $ERRORS inconsistency(ies) found. Run 'bash scripts/generate-health-check.sh' to sync."
  exit 1
fi
