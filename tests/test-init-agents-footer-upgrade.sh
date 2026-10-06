#!/usr/bin/env bash
# test-init-agents-footer-upgrade.sh — B10/B11: a single `init-agents` run brings
# an existing project up to date. B10 upgrades an OUTDATED AAS footer in place
# (adding the Rule 12 NON-NEGOTIABLES) without touching the team's content;
# B11 makes --dry-run report the EFFECTIVE hooks dir (.husky/ for husky).
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

# ── B10: an OUTDATED footer is upgraded in place ──
T="$(mkfixture)"
printf '\n%s\n' "$OLD_FOOTER" >> "$T/AGENTS.md"
( cd "$T" && AAS_DIR="$REPO_ROOT" bash "$INIT" > out.log 2>&1 )
assert "B10: team content preserved" "grep -q 'TEAM RULES — MUST KEEP' '$T/AGENTS.md'"
assert "B10: footer upgraded (NON-NEGOTIABLES added)" "grep -q 'NON-NEGOTIABLES' '$T/AGENTS.md'"
assert "B10: Rule 12 text present" "grep -q 'NEVER runs \`git commit\`' '$T/AGENTS.md'"
assert "B10: exactly ONE footer block (no duplicate)" "[ \"\$(grep -c '# >>> another-agent-skills-rules' '$T/AGENTS.md')\" -eq 1 ]"
assert "B10: log reports the upgrade" "grep -qi 'Upgraded the AAS rules footer' '$T/out.log'"
rm -rf "$T"

# ── B10b: a CURRENT footer is left untouched on re-run ──
C="$(mkfixture)"
( cd "$C" && AAS_DIR="$REPO_ROOT" bash "$INIT" >/dev/null 2>&1 )
BEFORE="$(md5sum "$C/AGENTS.md" | cut -d' ' -f1)"
( cd "$C" && AAS_DIR="$REPO_ROOT" bash "$INIT" > out2.log 2>&1 )
AFTER="$(md5sum "$C/AGENTS.md" | cut -d' ' -f1)"
assert "B10b: current footer left untouched on re-run" "[ \"\$BEFORE\" = \"\$AFTER\" ]"
assert "B10b: log says already current" "grep -qi 'already present and current' '$C/out2.log'"
rm -rf "$C"

# ── B10c: --dry-run plans the upgrade without mutating ──
D="$(mkfixture)"
printf '\n%s\n' "$OLD_FOOTER" >> "$D/AGENTS.md"
DR="$(cd "$D" && AAS_DIR="$REPO_ROOT" bash "$INIT" --dry-run 2>&1)"
assert "B10c: --dry-run plans the footer upgrade" "printf '%s' \"\$DR\" | grep -qi 'upgrade the outdated AAS rules footer'"
assert "B10c: --dry-run does not mutate" "! grep -q 'NON-NEGOTIABLES' '$D/AGENTS.md'"
rm -rf "$D"

# ── B11: --dry-run reports the EFFECTIVE hooks dir (husky) ──
H="$(mkfixture)"
( cd "$H" && mkdir -p .husky/_ && git config core.hooksPath .husky/_ )
DRH="$(cd "$H" && AAS_DIR="$REPO_ROOT" bash "$INIT" --dry-run 2>&1)"
assert "B11: --dry-run reports .husky/pre-commit (not .git/hooks)" \
  "printf '%s' \"\$DRH\" | grep -q 'install portable hook shims (./.husky/pre-commit, commit-msg)'"
rm -rf "$H"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
