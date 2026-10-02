#!/usr/bin/env bash
# test-install-and-init-agents-tdd-gate.sh — Phase 8.1 enforcement-delivery fixes.
#
# Covers three real bugs found while testing "no GitHub / no git" projects:
#   A — tdd-gate.sh was never distributed by install.sh or init-agents.sh, so
#       the commit-msg hook silently skipped the flagship TDD gate.
#   B — init-agents installed .github/workflows/gates.yml (and told the user to
#       run setup-branch-protection.sh) even in projects with no git or no
#       GitHub remote — impossible instructions.
#   C — scripts/tdd-gate.sh run outside a git repo exited 0 but created a stray
#       .git/ directory.
#
# Name-matches install.sh, scripts/init-agents.sh, scripts/tdd-gate.sh.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INIT_SCRIPT="$REPO_ROOT/scripts/init-agents.sh"
INSTALL_SCRIPT="$REPO_ROOT/install.sh"
GATE_SCRIPT="$REPO_ROOT/scripts/tdd-gate.sh"

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

# Fake global install dir so init-agents links scripts deterministically
# (install_framework_symlinks reads ${HOME}/.config/opencode).
FAKE_HOME="$TMP/home"
mkdir -p "$FAKE_HOME/.config/opencode/scripts"
cp "$GATE_SCRIPT" "$FAKE_HOME/.config/opencode/scripts/tdd-gate.sh"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  PHASE 8.1 — ENFORCEMENT DELIVERY                          ║"
echo "╚════════════════════════════════════════════════════════════╝"

# ─── A — Distribute tdd-gate.sh ───
echo ""
echo "A — tdd-gate.sh distribution"

assert "install.sh global script list includes tdd-gate.sh" \
  "sed -n '/for script in skill-gate.sh edit-guard.sh/,/^    done/p' '$INSTALL_SCRIPT' | grep -q 'tdd-gate.sh'"
assert "install.sh distributes git-hooks + resolver to the global dir" \
  "grep -q 'scripts/git-hooks' '$INSTALL_SCRIPT' && grep -q 'aas-resolve.sh' '$INSTALL_SCRIPT'"
assert "init-agents installs a portable commit-msg shim" \
  "grep -q 'git-hooks/commit-msg' '$INIT_SCRIPT'"
assert "framework commit-msg resolves tdd-gate from \$AAS_DIR" \
  "grep -q 'TDD_GATE=\"\${AAS_SCRIPTS}/tdd-gate.sh\"' '$REPO_ROOT/scripts/git-hooks/commit-msg'"
assert "init-agents resolves the framework from \$AAS_DIR" \
  "grep -q 'AAS_DIR' '$INIT_SCRIPT'"

# Behavioral: init-agents ships the gate, and it actually blocks.
repo="$TMP/repo-a"
mkdir -p "$repo"
git -C "$repo" init -q
git -C "$repo" config user.email test@test.com
git -C "$repo" config user.name Test
git -C "$repo" config commit.gpgsign false
echo "# init" > "$repo/README.md"
git -C "$repo" add README.md
git -C "$repo" commit -q -m init

(cd "$repo" && HOME="$FAKE_HOME" bash "$INIT_SCRIPT" >/dev/null 2>&1)
assert "init-agents installs a portable commit-msg shim" \
  "[ -f '$repo/.git/hooks/commit-msg' ] && grep -q 'AAS_DIR' '$repo/.git/hooks/commit-msg'"

echo 'export const x = 1' > "$repo/foo.js"
git -C "$repo" add foo.js
printf 'code without test\n' > "$TMP/msg-a.txt"
(cd "$repo" && AAS_DIR="$REPO_ROOT" bash .git/hooks/commit-msg "$TMP/msg-a.txt") >/dev/null 2>&1
hook_rc=$?
assert "commit-msg blocks a code-without-test commit" "[ $hook_rc -ne 0 ]"

# ─── B — init-agents detects git / GitHub remote ───
echo ""
echo "B — git / GitHub remote detection"

# B1: no git repository.
nogit="$TMP/no-git"
mkdir -p "$nogit"
(cd "$nogit" && HOME="$FAKE_HOME" bash "$INIT_SCRIPT" > "$TMP/out-nogit.txt" 2>&1)
assert "no-git project gets no gates.yml" "[ ! -f '$nogit/.github/workflows/gates.yml' ]"
assert "no-git next steps say convention-only" "grep -qi 'convention-only' '$TMP/out-nogit.txt'"
assert "no-git next steps omit the L2 block" "! grep -q 'REMOTE ENFORCEMENT (L2' '$TMP/out-nogit.txt'"

# B2: git repository without a GitHub remote.
gitnr="$TMP/git-no-remote"
mkdir -p "$gitnr"
git -C "$gitnr" init -q
git -C "$gitnr" config user.email test@test.com
git -C "$gitnr" config user.name Test
(cd "$gitnr" && HOME="$FAKE_HOME" bash "$INIT_SCRIPT" > "$TMP/out-gitnr.txt" 2>&1)
assert "git-without-GitHub gets no gates.yml" "[ ! -f '$gitnr/.github/workflows/gates.yml' ]"
assert "git-without-GitHub next steps say local only" "grep -qi 'Local git only' '$TMP/out-gitnr.txt'"
assert "git-without-GitHub next steps mention L2 needs a GitHub remote" \
  "grep -q 'L2' '$TMP/out-gitnr.txt' && grep -qi 'GitHub remote' '$TMP/out-gitnr.txt'"
assert "git-without-GitHub next steps omit the L2 block" "! grep -q 'REMOTE ENFORCEMENT (L2' '$TMP/out-gitnr.txt'"

# B3: git repository with a GitHub remote.
ghr="$TMP/git-gh"
mkdir -p "$ghr"
git -C "$ghr" init -q
git -C "$ghr" config user.email test@test.com
git -C "$ghr" config user.name Test
git -C "$ghr" remote add origin https://github.com/example/demo.git
(cd "$ghr" && HOME="$FAKE_HOME" bash "$INIT_SCRIPT" > "$TMP/out-ghr.txt" 2>&1)
assert "git+GitHub gets gates.yml" "[ -f '$ghr/.github/workflows/gates.yml' ]"
assert "git+GitHub next steps show the L2 block" "grep -q 'REMOTE ENFORCEMENT (L2' '$TMP/out-ghr.txt'"

# ─── C — tdd-gate.sh without git ───
echo ""
echo "C — tdd-gate.sh without git"

nonrepo="$TMP/not-a-repo"
mkdir -p "$nonrepo"
(cd "$nonrepo" && bash "$GATE_SCRIPT" > "$TMP/out-c.txt" 2>&1)
rc_c=$?
assert "tdd-gate.sh in a non-git dir exits 0" "[ $rc_c -eq 0 ]"
assert "tdd-gate.sh prints a SKIP message" "grep -qi 'SKIP' '$TMP/out-c.txt'"
assert "tdd-gate.sh does not create .git/" "[ ! -d '$nonrepo/.git' ]"
assert "log_gate is guarded against creating .git without a repo" \
  "[ \$(grep -c 'is-inside-work-tree' '$GATE_SCRIPT') -ge 2 ]"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
