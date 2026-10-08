#!/usr/bin/env bash
# test-init-agents-validators.sh — B15 regression: the validators the gates and
# STEERING-GUIDE reference as remediation (validate-skill-table.sh,
# validate-health-check.sh, generate-health-check.sh) must be installed in the
# project as portable shims, so the promised `bash scripts/<validator>.sh` is
# executable. Before the fix only the 10 legacy scripts were shimmed and the
# remediation command failed with "No such file or directory".
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INIT="$REPO_ROOT/scripts/init-agents.sh"
VALIDATORS="validate-skill-table.sh validate-health-check.sh generate-health-check.sh"

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

mkproj() {
  local d; d="$(mktemp -d)"
  ( cd "$d" && git init -q \
    && git config user.email t@t.t && git config user.name t \
    && echo x > x.txt && git add x.txt && git commit -qm init ) >/dev/null 2>&1
  printf '%s' "$d"
}

# ── Case 1: a normal install installs the validator shims ──
P="$(mkproj)"
( cd "$P" && AAS_DIR="$REPO_ROOT" bash "$INIT" > install.log 2>&1 )
for v in $VALIDATORS; do
  assert "installed: scripts/${v}" "[ -x '$P/scripts/${v}' ]"
  assert "shim: scripts/${v} is portable" "grep -q '_AAS_WALK' '$P/scripts/${v}' 2>/dev/null"
  assert "shim: scripts/${v} delegates to \$AAS_DIR" "grep -qF 'exec \"\$_AAS_ROOT/scripts/${v}\"' '$P/scripts/${v}' 2>/dev/null"
done

# ── Case 2: the installed shim actually runs the framework script ──
OUT="$(cd "$P" && AAS_DIR="$REPO_ROOT" bash scripts/validate-skill-table.sh 2>&1 || true)"
assert "installed validate-skill-table.sh executes the framework script" \
  "printf '%s' \"\$OUT\" | grep -q 'PROGRESS_STATUS.md'"
rm -rf "$P"

# ── Case 3: --dry-run lists the validator shims ──
D="$(mkproj)"
DR="$(cd "$D" && AAS_DIR="$REPO_ROOT" bash "$INIT" --dry-run 2>&1)"
for v in $VALIDATORS; do
  assert "dry-run plans scripts/${v}" "printf '%s' \"\$DR\" | grep -q 'scripts/${v}'"
done
rm -rf "$D"

# ── Case 4: --repair recreates the validator shims from legacy absolute symlinks ──
R="$(mkproj)"
mkdir -p "$R/scripts"
( cd "$R" && for v in $VALIDATORS; do ln -s "$REPO_ROOT/scripts/$v" "scripts/$v"; done )
( cd "$R" && AAS_DIR="$REPO_ROOT" bash "$INIT" --repair >/dev/null 2>&1 )
for v in $VALIDATORS; do
  assert "repair recreates scripts/${v} as a shim" \
    "[ -x '$R/scripts/${v}' ] && grep -q '_AAS_WALK' '$R/scripts/${v}' 2>/dev/null"
done
rm -rf "$R"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
