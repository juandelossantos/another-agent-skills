#!/usr/bin/env bash
# test-skills-discovery-paths.sh — B9 regression: skills must land in a path the
# agent actually discovers. A bare `skills/` is not a discovery path for any
# agent, and the AGENTS.md startup Protocol must not point at a non-existent
# project path.
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

# --- Static: the installer knows the real discovery paths ---
assert "init-agents defines project_skills_dir()" "grep -q 'project_skills_dir()' '$INIT'"
assert "no bare 'skills/' default in install_with_skills" "! grep -q 'local skill_dest_dir=\"skills\"' '$INIT'"
assert "AGENTS.md no longer points at skills/using-agent-skills/SKILL.md" \
  "! grep -q 'skills/using-agent-skills/SKILL.md' '$REPO_ROOT/AGENTS.md'"
assert "AGENTS.md documents the real discovery paths" \
  "grep -q 'bare \`skills/\` is not discovered' '$REPO_ROOT/AGENTS.md'"
# B9.3: install recreates scripts/skill-gate.sh (from B4), so the Protocol's
# 'bash scripts/skill-gate.sh mark' reference keeps working after --repair.
assert "install recreates scripts/skill-gate.sh (B4)" \
  "grep -q 'skill-gate.sh edit-guard.sh' '$INIT'"

mkfixture() {
  local d; d="$(mktemp -d)"
  ( cd "$d" && git init -q && git config user.email t@t.t && git config user.name t \
    && echo a > a.txt && git add a.txt && git commit -qm init ) >/dev/null 2>&1
  printf '%s' "$d"
}

# --- Behavioral: default (AGENTS.md only) → .claude/skills (discovered) ---
D="$(mkfixture)"
( cd "$D" && printf '# AGENTS\n' > AGENTS.md && AAS_DIR="$REPO_ROOT" bash "$INIT" --with-skills > out.log 2>&1 )
assert "default: skills land in .claude/skills" "[ -f '$D/.claude/skills/code-review-and-quality/SKILL.md' ]"
assert "default: bare skills/ is NOT created" "[ ! -d '$D/skills' ]"
rm -rf "$D"

# --- Behavioral: an OpenCode project → .opencode/skills ---
O="$(mkfixture)"
( cd "$O" && mkdir -p .opencode && printf '# AGENTS\n' > .opencode/AGENTS.md && AAS_DIR="$REPO_ROOT" bash "$INIT" --with-skills > out.log 2>&1 )
assert "opencode: skills land in .opencode/skills" "[ -f '$O/.opencode/skills/code-review-and-quality/SKILL.md' ]"
rm -rf "$O"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
