#!/usr/bin/env bash
# test-init-agents-footer-upgrade-safety.sh — post-review hardening of the B10
# footer upgrade: it must PRESERVE the file mode (a mktemp file is 600) and must
# NEVER rewrite a malformed footer (begin delimiter without an end), which would
# drop everything after it.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INIT="$REPO_ROOT/scripts/init-agents.sh"

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

mkfixture() {
  local d; d="$(mktemp -d)"
  ( cd "$d" && git init -q && git config user.email t@t.t && git config user.name t \
    && echo a > a.txt && git add a.txt && git commit -qm init \
    && printf '# TEAM AGENTS\n\nTEAM RULES — MUST KEEP\n' > AGENTS.md ) >/dev/null 2>&1
  printf '%s' "$d"
}

OLD_FOOTER='# >>> another-agent-skills-rules
# The following rules are from Another Agent Skills (github.com/juandelossantos/another-agent-skills)
# These rules ADD TO your existing workflow, they do not replace it.
# <<< another-agent-skills-rules'

# ── Mode is preserved (no 600 leaked from mktemp) ──
M="$(mkfixture)"
printf '\n%s\n' "$OLD_FOOTER" >> "$M/AGENTS.md"
chmod 644 "$M/AGENTS.md"
( cd "$M" && AAS_DIR="$REPO_ROOT" bash "$INIT" >/dev/null 2>&1 )
assert "AGENTS.md keeps its mode (644) after the upgrade" "[ \"\$(stat -c %a '$M/AGENTS.md')\" = \"644\" ]"
assert "the upgrade still happened (NON-NEGOTIABLES added)" "grep -q 'NON-NEGOTIABLES' '$M/AGENTS.md'"
rm -rf "$M"

# ── A malformed footer (begin without end) is never rewritten ──
X="$(mkfixture)"
printf '\n# >>> another-agent-skills-rules\nbanner only, no end delimiter\n\nTEAM TAIL — MUST KEEP\n' >> "$X/AGENTS.md"
( cd "$X" && AAS_DIR="$REPO_ROOT" bash "$INIT" > out.log 2>&1 )
assert "content after a malformed footer is preserved" "grep -q 'TEAM TAIL — MUST KEEP' '$X/AGENTS.md'"
assert "the malformed file is left unchanged" "! grep -q 'NON-NEGOTIABLES' '$X/AGENTS.md'"
assert "warns about the missing end delimiter" "grep -qi 'but no' '$X/out.log'"
rm -rf "$X"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
