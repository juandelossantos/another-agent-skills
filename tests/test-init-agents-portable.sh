#!/usr/bin/env bash
# test-init-agents-portable.sh — init-agents is portable/standalone (P9.7) and
# detects + repairs legacy projects safely (P9.8).
#
# Contract:
#   - no absolute symlinks are ever created in a project
#   - .aas/config records the pinned version; .aas/aas-resolve.sh is copied
#   - hooks become portable shims (resolve $AAS_DIR, delegate)
#   - the project can be copied elsewhere with no dangling links
#   - --dry-run mutates nothing; --repair migrates a legacy project safely
#   - the drift notice is non-blocking; legacy projects get guidance

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export HOME="$TMP/home"; mkdir -p "$HOME"
unset ANOTHER_AGENT_SKILLS_DIR AAS_DIR AAS_AGENTS

FW="$TMP/fw"
# A fake framework root built from the real repo (hermetic + version control).
make_fw() {
  mkdir -p "$FW/scripts" "$FW/templates" "$FW/skills"
  cp -r "$REPO_ROOT/scripts/." "$FW/scripts/"
  cp "$REPO_ROOT/VERSION" "$FW/VERSION"
  cp "$REPO_ROOT/AGENTS.md" "$FW/AGENTS.md"
  cp "$REPO_ROOT/PATTERNS.md" "$FW/PATTERNS.md"
  cp "$REPO_ROOT/ANTI-PATTERNS.md" "$FW/ANTI-PATTERNS.md"
  [ -f "$REPO_ROOT/templates/gates.yml" ] && cp "$REPO_ROOT/templates/gates.yml" "$FW/templates/gates.yml"
  [ -d "$REPO_ROOT/rules" ] && cp -r "$REPO_ROOT/rules" "$FW/rules"
  # skills: self-improvement (default) + two extra for --with-skills
  cp -r "$REPO_ROOT/skills/self-improvement" "$FW/skills/self-improvement"
  for s in extra-one extra-two; do
    mkdir -p "$FW/skills/$s"
    printf '# %s\n' "$s" > "$FW/skills/$s/SKILL.md"
  done
}
make_fw
FW_VERSION="$(cat "$FW/VERSION")"
INIT="$FW/scripts/init-agents.sh"

# Fresh git project helper (no GitHub remote → no gates.yml).
make_proj() {
  local p="$1"
  mkdir -p "$p"
  git -C "$p" init -q
  git -C "$p" config user.email t@t.com
  git -C "$p" config user.name T
  git -C "$p" config commit.gpgsign false
  printf '# proj\n' > "$p/README.md"
  git -C "$p" add README.md && git -C "$p" commit -q -m init
  echo "$p"
}

# True when every symlink under a dir has a non-absolute target.
no_absolute_symlinks() {
  local dir="$1" found=""
  while IFS= read -r -d '' path; do
    [ -L "$path" ] || continue
    t="$(readlink "$path")"
    case "$t" in /*) found="$path -> $t" ;; esac
  done < <(find "$dir" -type l -print0 2>/dev/null)
  [ -z "$found" ]
}

echo ""
echo "INIT-AGENTS — portable / standalone (P9.7) + safe repair (P9.8)"
echo "────────────────────────────────────────────────────────────────"

# ── A. Fresh install: portable form, no absolute symlinks ────────────────────
P1="$(make_proj "$TMP/p1")"
( cd "$P1" && AAS_DIR="$FW" bash "$INIT" > "$TMP/p1.log" 2>&1 )
assert "fresh install exits 0" "[ $? -eq 0 ]"
assert ".aas/config exists" "[ -f '$P1/.aas/config' ]"
assert ".aas/config records the framework version" "grep -q '\"version\": \"$FW_VERSION\"' '$P1/.aas/config'"
assert ".aas/config records detected agents key" "grep -q '\"agents\"' '$P1/.aas/config'"
assert ".aas/aas-resolve.sh is copied (not a symlink)" "[ -f '$P1/.aas/aas-resolve.sh' ] && [ ! -L '$P1/.aas/aas-resolve.sh' ]"
assert "project has zero absolute symlinks" "no_absolute_symlinks '$P1'"
assert "pre-commit hook is a portable shim" "grep -q 'aas-resolve\\|AAS_DIR' '$P1/.git/hooks/pre-commit' && [ \$(wc -l < '$P1/.git/hooks/pre-commit') -lt 40 ]"
assert "commit-msg hook is a portable shim" "grep -q 'aas-resolve\\|AAS_DIR' '$P1/.git/hooks/commit-msg' && [ \$(wc -l < '$P1/.git/hooks/commit-msg') -lt 40 ]"
assert "no rules/common symlink is created" "[ ! -L '$P1/rules/common' ]"
assert "no SOUL.md symlink is created" "[ ! -L '$P1/SOUL.md' ]"
assert "no VERSION symlink is created" "[ ! -L '$P1/VERSION' ]"

# ── B. Portable copy: no dangling links ──────────────────────────────────────
P1COPY="$TMP/p1-copy"
cp -r "$P1" "$P1COPY"
assert "copied project has no dangling symlinks" "[ -z \"\$(find '$P1COPY' -type l ! -exec test -e {} \\; -print 2>/dev/null)\" ]"
assert "copied project keeps .aas/config" "[ -f '$P1COPY/.aas/config' ]"

# ── C. --dry-run mutates nothing ─────────────────────────────────────────────
P2="$(make_proj "$TMP/p2")"
( cd "$P2" && AAS_DIR="$FW" bash "$INIT" --dry-run > "$TMP/p2.log" 2>&1 )
RC=$?
assert "--dry-run exits 0" "[ $RC -eq 0 ]"
assert "--dry-run prints its plan" "grep -q '\\[dry-run\\]' '$TMP/p2.log'"
assert "--dry-run does not write .aas/" "[ ! -e '$P2/.aas' ]"
assert "--dry-run does not create AGENTS.md" "[ ! -f '$P2/AGENTS.md' ]"
assert "--dry-run does not install hooks" "[ ! -f '$P2/.git/hooks/pre-commit' ]"

# ── D. --repair migrates a legacy project without data loss ──────────────────
P3="$(make_proj "$TMP/p3")"
mkdir -p "$P3/rules" "$P3/scripts"
printf '# My Project\n\nMY CUSTOM RULES — keep me\n' > "$P3/AGENTS.md"
ln -s "$FW/rules/common" "$P3/rules/common"       # absolute, valid
ln -s "$FW/SOUL.md" "$P3/SOUL.md"                 # absolute, valid
ln -s "$FW/VERSION" "$P3/VERSION"                 # absolute, valid
ln -s "$TMP/does-not-exist/tdd-gate.sh" "$P3/scripts/tdd-gate.sh"  # broken absolute
( cd "$P3" && AAS_DIR="$FW" bash "$INIT" --repair > "$TMP/p3.log" 2>&1 )
assert "--repair exits 0" "[ $? -eq 0 ]"
assert "--repair preserves the custom AGENTS.md content" "grep -q 'MY CUSTOM RULES' '$P3/AGENTS.md'"
assert "--repair appends the AAS footer" "grep -q 'another-agent-skills-rules' '$P3/AGENTS.md'"
assert "--repair writes a backup under .aas/backups/" "[ -n \"\$(ls '$P3/.aas/backups/'*AGENTS.md* 2>/dev/null)\" ]"
assert "--repair removes absolute symlinks" "no_absolute_symlinks '$P3'"
assert "--repair writes .aas/config" "[ -f '$P3/.aas/config' ]"
assert "--repair installs portable hooks" "grep -q 'aas-resolve\\|AAS_DIR' '$P3/.git/hooks/commit-msg'"

# ── E. Drift notice is non-blocking ──────────────────────────────────────────
P4="$(make_proj "$TMP/p4")"
( cd "$P4" && AAS_DIR="$FW" bash "$INIT" >/dev/null 2>&1 )
printf '{ "version": "0.0.1", "agents": "opencode", "initialized": "2020-01-01" }\n' > "$P4/.aas/config"
( cd "$P4" && AAS_DIR="$FW" bash "$INIT" > "$TMP/p4.log" 2>&1 )
RC=$?
assert "drift re-run exits 0 (non-blocking)" "[ $RC -eq 0 ]"
assert "drift notice mentions the pinned and installed versions" "grep -q '0.0.1' '$TMP/p4.log' && grep -q '$FW_VERSION' '$TMP/p4.log'"

# ── F. Legacy detection (AAS artifacts, no .aas/config) ──────────────────────
P5="$(make_proj "$TMP/p5")"
printf '# Existing\n\n# >>> another-agent-skills-rules\n# <<< another-agent-skills-rules\n' > "$P5/AGENTS.md"
( cd "$P5" && AAS_DIR="$FW" bash "$INIT" > "$TMP/p5.log" 2>&1 )
assert "legacy project is detected as having no version marker" "grep -qi 'version marker' '$TMP/p5.log'"
assert "legacy guidance recommends --dry-run then --repair" "grep -q -- '--dry-run' '$TMP/p5.log' && grep -q -- '--repair' '$TMP/p5.log'"

# ── G. --with-skills copies skills for a self-contained project ──────────────
P6="$(make_proj "$TMP/p6")"
( cd "$P6" && AAS_DIR="$FW" bash "$INIT" --with-skills --skip-self-improvement >/dev/null 2>&1 )
assert "--with-skills copies extra skills (discoverable path)" "[ -f '$P6/.claude/skills/extra-one/SKILL.md' ] && [ -f '$P6/.claude/skills/extra-two/SKILL.md' ]"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
