#!/usr/bin/env bash
# test-init-agents-repair-equivalents.sh — B4 regression: --repair (and a normal
# install) must recreate a portable equivalent of every legacy absolute symlink
# it removes, so nothing the project's AGENTS.md references is lost. Before the
# fix, --repair deleted rules/common, SOUL.md, AGENTS-EXTENDED.md, VERSION and
# scripts/*.sh without recreating them.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INIT="$REPO_ROOT/scripts/init-agents.sh"
LEGACY_SCRIPTS="skill-gate.sh edit-guard.sh task-manifest.sh pre-flight.sh commit-approval.sh pr-review-checklist.sh design-gate.sh skill-lint.sh setup-branch-protection.sh tdd-gate.sh"

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

mklegacy() {
  local d; d="$(mktemp -d)"
  (
    cd "$d"
    git init -q
    git config user.email t@t.t; git config user.name t
    echo a > a.txt; git add a.txt; git commit -qm init
    printf '# TEAM AGENTS\n\nTEAM RULES — MUST KEEP\n' > AGENTS.md
    mkdir -p rules scripts
    ln -s "$REPO_ROOT/rules/common" rules/common
    for f in SOUL.md AGENTS-EXTENDED.md VERSION PATTERNS.md ANTI-PATTERNS.md; do
      ln -s "$REPO_ROOT/$f" "$f"
    done
    for s in $LEGACY_SCRIPTS; do
      ln -s "$REPO_ROOT/scripts/$s" "scripts/$s"
    done
  ) >/dev/null 2>&1
  printf '%s' "$d"
}

# ── Case 1: --repair ──
L="$(mklegacy)"
( cd "$L" && AAS_DIR="$REPO_ROOT" bash "$INIT" --repair > repair.log 2>&1 )
assert "repair exits 0" "[ -f '$L/repair.log' ]"
assert "team AGENTS.md preserved" "grep -q 'TEAM RULES — MUST KEEP' '$L/AGENTS.md'"
assert "AAS footer appended" "grep -q 'another-agent-skills-rules' '$L/AGENTS.md'"

# Docs: recreated as real copies (no dangling absolute symlinks).
for p in rules/common SOUL.md AGENTS-EXTENDED.md VERSION; do
  assert "recreated + portable: ${p}" "[ -e '$L/$p' ] && ! [ -L '$L/$p' ]"
done
assert "rules/common content present (behavioral.md)" "[ -f '$L/rules/common/behavioral.md' ]"

# Scripts: recreated as portable shims that delegate to $AAS_DIR.
for s in $LEGACY_SCRIPTS; do
  assert "shim: scripts/${s} executable + portable" "[ -x '$L/scripts/${s}' ] && grep -q '_AAS_WALK' '$L/scripts/${s}' 2>/dev/null"
  assert "shim: scripts/${s} delegates to \$AAS_DIR" "grep -qF 'exec \"\$_AAS_ROOT/scripts/${s}\"' '$L/scripts/${s}' 2>/dev/null"
done

rm -rf "$L"

# --dry-run on a FRESH legacy repo lists exactly what would be removed and
# recreated (B4.3) — and mutates nothing.
DR_DIR="$(mklegacy)"
DR="$(cd "$DR_DIR" && AAS_DIR="$REPO_ROOT" bash "$INIT" --dry-run 2>&1)"
assert "dry-run plans rules/common removal+recreate" "printf '%s' \"\$DR\" | grep -q 'rules/common'"
assert "dry-run plans scripts/skill-gate.sh removal+recreate" "printf '%s' \"\$DR\" | grep -q 'scripts/skill-gate.sh'"
assert "dry-run mutates nothing (symlink still present)" "[ -L '$DR_DIR/scripts/skill-gate.sh' ]"
rm -rf "$DR_DIR"

# ── Case 2: a normal install (no --repair) also migrates (B4.2) ──
N="$(mklegacy)"
( cd "$N" && AAS_DIR="$REPO_ROOT" bash "$INIT" > normal.log 2>&1 )
assert "normal: rules/common recreated (no mixed state)" "[ -f '$N/rules/common/behavioral.md' ]"
assert "normal: SOUL.md is a real file" "[ -e '$N/SOUL.md' ] && ! [ -L '$N/SOUL.md' ]"
assert "normal: skill-gate.sh is a portable shim" "grep -q '_AAS_WALK' '$N/scripts/skill-gate.sh' 2>/dev/null"
assert "normal: no absolute symlink remains under scripts/" \
  "! find '$N/scripts' -type l -printf '%l\n' 2>/dev/null | grep -q '^/'"
rm -rf "$N"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
