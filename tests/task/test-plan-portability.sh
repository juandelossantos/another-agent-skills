#!/usr/bin/env bash
# test-plan-portability.sh — Phase 9 records portability/standalone (P9.7/P9.8)
# and Phase 10 records the FAQ/user-guide block (Bloque E).

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PLAN="$REPO_ROOT/PLAN.md"

PASSED=0; FAILED=0; TOTAL=0
assert() {
  local name="$1" condition="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$condition"; then
    echo -e "  ${GREEN}✓${NC} $name"
    PASSED=$((PASSED + 1))
  else
    echo -e "  ${RED}✗${NC} $name"
    FAILED=$((FAILED + 1))
  fi
}

# --- P9.7 portable / standalone / cross-platform ---
assert "P9.7 exists (portable/standalone)" "grep -q '^| \*\*P9.7\*\*' '$PLAN'"
assert "P9.7 forbids linking to \$SCRIPT_DIR" "grep -q 'nunca\*\* enlaza a \`\$SCRIPT_DIR\`' '$PLAN'"
assert "P9.7 uses .aas/config" "grep -q '\.aas/config' '$PLAN'"
assert "P9.7 names the cross-platform resolver" "grep -q 'ANOTHER_AGENT_SKILLS_DIR' '$PLAN'"
assert "P9.7 is POSIX-first with a thin PS wrapper" "grep -q 'POSIX-first + wrapper PS fino' '$PLAN'"
assert "P9.7 has an optional --with-skills" "grep -q -- '--with-skills' '$PLAN'"

# --- P9.8 detection + guidance + legacy adoption ---
assert "P9.8 exists (detection + repair)" "grep -q '^| \*\*P9.8\*\*' '$PLAN'"
assert "P9.8 has --dry-run" "grep -q 'init-agents --dry-run' '$PLAN'"
assert "P9.8 has --repair" "grep -q -- '--repair' '$PLAN'"
assert "P9.8 is non-blocking drift notice" "grep -q 'no bloqueante\*\* de drift' '$PLAN'"
assert "P9.8 detects legacy (no .aas/config)" "grep -qi 'legacy' '$PLAN'"
assert "P9.8 covers backup hygiene" "grep -q '\.aas/backups/' '$PLAN'"

# --- Ordering + the real case ---
assert "records the recommended intra-Phase-9 order" "grep -q 'P9.7 → P9.8' '$PLAN'"
assert "cites the shared-project real case" "grep -q 'courtside-scoreboard' '$PLAN'"

# --- Phase 10 Bloque E (FAQ / user guides) ---
assert "Phase 10 has Bloque E (FAQ)" "grep -q 'Bloque E — FAQ + guías de uso' '$PLAN'"
assert "FAQ covers install-once (E1)" "grep -q 'una vez por máquina' '$PLAN'"
assert "FAQ covers the collaborator-without-AAS case (E3)" "grep -qi 'no tiene AAS' '$PLAN'"
assert "FAQ covers the legacy migration case (E4)" "grep -q 'Heredé/migré un proyecto' '$PLAN'"
assert "FAQ feeds AEO/FAQPage" "grep -q 'FAQPage JSON-LD' '$PLAN'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
