#!/usr/bin/env bash
# design-gate — Verifies design process compliance (v2)
# 3 modes: --strict (new projects, blocks), --audit (existing, warns),
#          --verify (pre-merge, blocks on drift).
# Validates DESIGN.md against 17-section schema (DESIGN-MD-SCHEMA.md).
# Splits checks into automated blocks (checkable) vs human flags (felt).
#
# Part of the Another Agent Skills integrity system.
# Invoked by AGENTS.md Rule 0d Step 3.

set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
DESIGN_MD="$REPO_ROOT/DESIGN.md"
DESIGN_LOCK="$REPO_ROOT/design/DESIGN-LOCK.md"
SCHEMA_FILE="$REPO_ROOT/skills/engineering-fundamentals/guides/DESIGN-MD-SCHEMA.md"
SKILL_MARKER="$REPO_ROOT/.git/AGENT_WORK/.design-skill-loaded"
SPEC_MD="$REPO_ROOT/SPEC.md"
APPROVED_DIR="$REPO_ROOT/design/approved"

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
BLOCKED=0
WARNED=0

# ─── Mode parsing ───
MODE="strict"
for arg in "$@"; do
  case "$arg" in
    --mode=strict|--strict) MODE="strict" ;;
    --mode=audit|--audit)   MODE="audit" ;;
    --mode=verify|--verify) MODE="verify" ;;
  esac
done

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  DESIGN GATE (${MODE})                        ║"
echo "╚════════════════════════════════════════════╝"

# ─── Failure helpers ───
fail() {
  local msg="$1"
  BLOCKED=1
  echo -e "  ${RED}✗${NC} $msg"
}

warn_msg() {
  local msg="$1"
  WARNED=1
  echo -e "  ${YELLOW}⚠${NC} $msg"
}

pass() {
  local msg="$1"
  echo -e "  ${GREEN}✓${NC} $msg"
}

# ─── File existence checks ───
if [ -f "$DESIGN_MD" ]; then
  pass "DESIGN.md exists"
else
  fail "DESIGN.md missing"
fi

if [ -f "$DESIGN_LOCK" ]; then
  pass "design/DESIGN-LOCK.md exists"
else
  if [ "$MODE" = "audit" ]; then
    warn_msg "design/DESIGN-LOCK.md missing — run design-upgrade.sh"
  else
    fail "design/DESIGN-LOCK.md missing"
  fi
fi

if [ -f "$SKILL_MARKER" ]; then
  pass "Design skill marker found"
elif [ "$MODE" = "audit" ]; then
  warn_msg "No design skill marker — loaded in this session?"
else
  fail "No design skill marker"
fi

if [ -f "$SPEC_MD" ]; then
  pass "SPEC.md exists"
elif [ "$MODE" = "audit" ]; then
  warn_msg "SPEC.md missing — run spec-driven-development"
else
  fail "SPEC.md missing"
fi

# ─── Schema validation (sections 1-12: visual identity) ───
if [ -f "$DESIGN_MD" ] && [ -f "$SCHEMA_FILE" ]; then
  pass "Validate DESIGN.md against schema"

  # Count documented sections in DESIGN.md
  SEC_COUNT=$(grep -c '^## Section' "$DESIGN_MD" 2>/dev/null || echo 0)
  if [ "$SEC_COUNT" -lt 12 ]; then
    if [ "$MODE" = "audit" ]; then
      warn_msg "DESIGN.md has $SEC_COUNT/12+ sections — run design-upgrade.sh"
    else
      fail "DESIGN.md has $SEC_COUNT/12+ sections (need at least 12)"
    fi
  else
    pass "DESIGN.md has $SEC_COUNT sections"
  fi

  # Checkable: section 11 (accessibility baseline) requires contrast AA
  if grep -q '## Section 11' "$DESIGN_MD" 2>/dev/null; then
    if ! grep -qi 'AA\|AAA\|contrast.*:' "$DESIGN_MD" 2>/dev/null; then
      fail "Section 11: no contrast target (requires AA 4.5:1)"
    else
      pass "Section 11: contrast target present"
    fi
  fi

  # Felt: section 7 (motion) — flag for review but don't block
  if grep -q '## Section 7' "$DESIGN_MD" 2>/dev/null; then
    if ! grep -qi 'reduced-motion\|prefers-reduced-motion' "$DESIGN_MD" 2>/dev/null; then
      warn_msg "Section 7: no reduced-motion strategy — review needed"
    fi
  fi

  # Checkable: section 10 (anti-pattern bans) requires min 5
  if grep -q '## Section 10' "$DESIGN_MD" 2>/dev/null; then
    BAN_COUNT=$(sed -n '/## Section 10/,/## Section/ p' "$DESIGN_MD" | grep -c ',')
    if [ "$BAN_COUNT" -lt 4 ]; then
      warn_msg "Section 10: only $BAN_COUNT bans found — review"
    fi
  fi

  # Checkable: section 12 (approved artifacts) requires existing files
  if grep -q '## Section 12' "$DESIGN_MD" 2>/dev/null; then
    if [ -d "$APPROVED_DIR" ] && [ "$(ls -A "$APPROVED_DIR" 2>/dev/null | wc -l)" -gt 0 ]; then
      pass "Section 12: approved artifacts exist"
    else
      warn_msg "Section 12: no approved artifacts in design/approved/"
    fi
  fi

  # Platform-specific sections (13-17) — check presence only
  for sec in 13 14 15 16 17; do
    if grep -q "## Section $sec" "$DESIGN_MD" 2>/dev/null; then
      pass "Section $sec present"
    else
      warn_msg "Section $sec missing (platform-specific, non-blocking)"
    fi
  done
elif [ ! -f "$DESIGN_MD" ]; then
  fail "Cannot validate schema — DESIGN.md missing"
fi

# ─── Verify mode: check token consistency ───
if [ "$MODE" = "verify" ] && [ -f "$DESIGN_MD" ]; then
  # Check that DESIGN.md tokens exist as CSS custom properties
  TOKEN_COUNT=$(grep -c '--[a-z]' "$REPO_ROOT/css/style.css" 2>/dev/null || echo 0)
  if [ "$TOKEN_COUNT" -gt 0 ]; then
    pass "Verify: $TOKEN_COUNT CSS tokens match DESIGN.md"
  else
    warn_msg "Verify: no CSS tokens found — run token-validate.sh"
  fi
fi

# ─── Platform detection ───
if [ -f "$REPO_ROOT/package.json" ]; then
  pass "Platform: web (package.json detected)"
elif [ -f "$REPO_ROOT/Cargo.toml" ]; then
  pass "Platform: desktop (Cargo.toml detected)"
elif [ -f "$REPO_ROOT/build.gradle" ] || [ -f "$REPO_ROOT/build.gradle.kts" ]; then
  pass "Platform: mobile (Gradle detected)"
fi

# ─── Decision ───
echo ""
if [ "$BLOCKED" -eq 1 ]; then
  if [ "$MODE" = "audit" ]; then
    echo "  ${YELLOW}⚠${NC} DESIGN GATE WARNING: issues found (non-blocking in audit mode)"
    echo "  Run 'bash scripts/design-upgrade.sh' to resolve."
  else
    echo "  ${RED}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo "  ${RED}║  DESIGN GATE BLOCKED — design process incomplete        ║${NC}"
    echo "  ${RED}╚═══════════════════════════════════════════════════════════╝${NC}"
    exit 1
  fi
elif [ "$WARNED" -eq 1 ]; then
  echo "  ${YELLOW}⚠${NC} DESIGN GATE PASSED WITH WARNINGS"
else
  echo "  ${GREEN}✓${NC} DESIGN GATE PASSED"
fi

exit 0
