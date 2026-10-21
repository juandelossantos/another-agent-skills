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

# Parse linter error/warning counts.
# Portable on purpose: BSD/macOS grep has no -P (PCRE). The previous
# `grep -oP` pipelines failed silently there, so this gate could never pass on
# a Mac no matter what HEALTH-CHECK.md said. POSIX awk/sed only.
LINT_ERRORS=$(printf '%s\n' "$LINT_OUTPUT" \
  | awk 'match($0, /[0-9]+ errors?/) { n=substr($0,RSTART,RLENGTH); sub(/ errors?/,"",n); v=n } END { print (v==""?"0":v) }')
LINT_WARNINGS=$(printf '%s\n' "$LINT_OUTPUT" \
  | awk 'match($0, /[0-9]+ warnings?/) { n=substr($0,RSTART,RLENGTH); sub(/ warnings?/,"",n); v=n } END { print (v==""?"0":v) }')

# Parse HEALTH-CHECK.md summary values (portable sed; no lookbehind).
HC_ERRORS=$(sed -n 's/^| *Errors[^|]*| *\*\*\([0-9][0-9]*\)\*\*.*/\1/p' "$HEALTH_FILE" | head -1)
HC_WARNINGS=$(sed -n 's/^| *Warnings[^|]*| *\*\*\([0-9][0-9]*\)\*\*.*/\1/p' "$HEALTH_FILE" | head -1)
HC_OVERALL=$(sed -n 's/^| *Overall[^|]*| *\*\*[^A-Z]*\(HEALTHY\|DEGRADED\|CRITICAL\).*/\1/p' "$HEALTH_FILE" | head -1)
: "${HC_ERRORS:=unknown}"
: "${HC_WARNINGS:=unknown}"
: "${HC_OVERALL:=unknown}"

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
