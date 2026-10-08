#!/usr/bin/env bash
# test-generate-health-check.sh — B14 regression: generate-health-check.sh --apply
# must regenerate a HEALTH-CHECK.md that has NO AAS section headers (a real
# project file), never die silently, and produce a file that validate-health-check.sh
# accepts. Before the fix it aborted (exit 1, no output) because the boundary
# `grep` failed under `set -euo pipefail` — the remediation tool was unusable and
# the failure invisible.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GEN="$REPO_ROOT/scripts/generate-health-check.sh"
VAL="$REPO_ROOT/scripts/validate-health-check.sh"

PASSED=0; FAILED=0; TOTAL=0
assert() {
  local name="$1" condition="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$condition"; then
    echo -e "  ${GREEN}✓${NC} $name"; PASSED=$((PASSED + 1))
  else
    echo -e "  ${RED}✗${NC} $name"; FAILED=$((FAILED + 1))
  fi
}

# The generator parses `bash scripts/skill-lint.sh`; stub it in the fixture.
stub_linters() {
  local d="$1"
  mkdir -p "$d/scripts"
  printf '#!/bin/sh\necho "Skill lint: 0 errors, 0 warnings"\n' > "$d/scripts/skill-lint.sh"
  printf '#!/bin/sh\necho "PASS: skill table matches"\n' > "$d/scripts/validate-skill-table.sh"
  chmod +x "$d/scripts/skill-lint.sh" "$d/scripts/validate-skill-table.sh"
}

# A project-style HEALTH-CHECK.md: NO "## Mechanical Enforcement/Steering/Landing"
# boundary, a stale Summary, and a project-owned "## Plan" section that must survive.
mkproject_fixture() {
  local d; d="$(mktemp -d)"
  stub_linters "$d"
  cat > "$d/HEALTH-CHECK.md" <<'EOF'
# Project Health Check

**Date:** 2020-01-01
**Auditor:** Someone

## Summary

| Metric | Value |
|---|---|
| Critical Issues | **0** |
| Errors (Check 14) | **99** (stale) |
| Warnings | **99** |
| Overall | **🔴 CRITICAL** |

## Plan

Project plan content — MUST KEEP.
EOF
  printf '%s' "$d"
}

# ── Case 1: --apply on a project file without AAS headers ──
F="$(mkproject_fixture)"
( cd "$F" && bash "$GEN" --apply > apply.log 2>&1 ); RC=$?
assert "--apply exits 0 (no silent death)" "[ $RC -eq 0 ]"
assert "--apply prints a status (not silent)" "grep -q 'updated' '$F/apply.log'"
assert "project section '## Plan' preserved" "grep -q '^## Plan' '$F/HEALTH-CHECK.md'"
assert "project content preserved" "grep -q 'MUST KEEP' '$F/HEALTH-CHECK.md'"
assert "stale errors replaced with 0" "grep -q 'Errors (Check 14) | \*\*0\*\*' '$F/HEALTH-CHECK.md'"
assert "Foundational section generated" "grep -q '^## Foundational' '$F/HEALTH-CHECK.md'"

# Generator ⇄ validator aligned: the regenerated file must PASS the validator.
( cd "$F" && bash "$VAL" > validate.log 2>&1 ); VRC=$?
assert "validate-health-check.sh PASSes after --apply" "[ $VRC -eq 0 ]"

# ── Case 2: --apply is idempotent ──
cp "$F/HEALTH-CHECK.md" "$F/first.md"
( cd "$F" && bash "$GEN" --apply >/dev/null 2>&1 )
assert "--apply is idempotent" "diff -q '$F/first.md' '$F/HEALTH-CHECK.md' >/dev/null 2>&1"
rm -rf "$F"

# ── Case 3: a framework-managed file (with the AAS boundary) still works ──
A="$(mktemp -d)"; stub_linters "$A"
cat > "$A/HEALTH-CHECK.md" <<'EOF'
# Health Check

**Date:** 2020-01-01

## Summary

| Metric | Value |
|---|---|
| Errors (Check 14) | **99** |
| Warnings | **99** |
| Overall | **🔴 CRITICAL** |

## Mechanical Enforcement: PASS

Framework boundary content — MUST KEEP.
EOF
( cd "$A" && bash "$GEN" --apply >/dev/null 2>&1 ); ARC=$?
assert "AAS-boundary file: --apply exits 0" "[ $ARC -eq 0 ]"
assert "AAS-boundary file: boundary content preserved" "grep -q 'MUST KEEP' '$A/HEALTH-CHECK.md'"
rm -rf "$A"

# ── Case 4: missing file → visible FAIL (never silent) ──
M="$(mktemp -d)"
( cd "$M" && bash "$GEN" --apply > miss.log 2>&1 ); MRC=$?
assert "missing HEALTH-CHECK.md exits non-zero" "[ $MRC -ne 0 ]"
assert "missing HEALTH-CHECK.md prints a reason (not silent)" "grep -qi 'not found\|FAIL' '$M/miss.log'"
rm -rf "$M"

# ── Case 5: a FAILing table validator must not corrupt the counts ──
# (`grep -c "PASS:" || echo 0` used to yield "0\n0" → `[: integer expected`.)
T="$(mkproject_fixture)"
printf '#!/bin/sh\necho "FAIL: no PROGRESS_STATUS.md"\n' > "$T/scripts/validate-skill-table.sh"
( cd "$T" && bash "$GEN" --apply > apply.log 2>&1 ); TRC=$?
assert "FAILing table validator: --apply exits 0" "[ $TRC -eq 0 ]"
assert "FAILing table validator: no integer error" "! grep -q 'integer expected' '$T/apply.log'"
assert "FAILing table validator: reported as FAIL" "grep -q 'validate-skill-table | 🔴 FAIL' '$T/HEALTH-CHECK.md'"
rm -rf "$T"

# ── Case 6: a project note inside the regenerated region is preserved ──
N="$(mkproject_fixture)"
awk '{ if ($0 == "## Plan" && !seen) { print "> Project debt note — MUST KEEP NOTE"; seen=1 } print }' \
  "$N/HEALTH-CHECK.md" > "$N/hc.tmp" && mv "$N/hc.tmp" "$N/HEALTH-CHECK.md"
assert "fixture has the note before regeneration" "grep -q 'MUST KEEP NOTE' '$N/HEALTH-CHECK.md'"
( cd "$N" && bash "$GEN" --apply >/dev/null 2>&1 )
assert "project note preserved across --apply" "grep -q 'MUST KEEP NOTE' '$N/HEALTH-CHECK.md'"
assert "project section still preserved" "grep -q '^## Plan' '$N/HEALTH-CHECK.md'"
rm -rf "$N"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
