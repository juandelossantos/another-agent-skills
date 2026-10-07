#!/usr/bin/env bash
# test-tdd-gate-matrix.sh — Phase 13 S5 (P13.8): the acceptance matrix.
#
# One contract, one table: each artifact TYPE is verified by its own tool and
# nothing passes unverified. Each row asserts BOTH the exit code AND the gate's
# recorded decision + reason (`.git/TDD_GATE_LOG`), so a wrong BLOCK reason
# also fails — the matrix is the gate's specification.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
GATE="$REPO_ROOT/scripts/tdd-gate.sh"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

PASSED=0; FAILED=0; TOTAL=0
pass() { echo -e "  ${GREEN}✓${NC} $1"; PASSED=$((PASSED + 1)); TOTAL=$((TOTAL + 1)); }
fail() { echo -e "  ${RED}✗${NC} $1"; FAILED=$((FAILED + 1)); TOTAL=$((TOTAL + 1)); }

consumer() {
  cd "$TMP" || return
  rm -rf r; mkdir r; cd r || return
  git init -q; git config user.email t@t.t; git config user.name t
  echo base > base.txt; git add base.txt; git commit -qm base
}
rtest() { printf '#!/usr/bin/env bash\nassert "x"\n' > "$1"; }   # non-empty paired test
shim() { mkdir -p scripts; printf '#!/bin/sh\nexec "$_AAS_ROOT/scripts/%s" "$@"\n' "$1" > "scripts/$1"; }

check() {  # exit decision reason name
  local rc dec rea
  ( unset REPO_ROOT; bash "$GATE" >/dev/null 2>&1 ); rc=$?
  dec=$(grep -oE '^decision=[A-Z]+' .git/TDD_GATE_LOG 2>/dev/null | cut -d= -f2)
  rea=$(grep -oE '^override=.*' .git/TDD_GATE_LOG 2>/dev/null | cut -d= -f2)
  if [ "$rc" = "$1" ] && [ "$dec" = "$2" ] && [ "$rea" = "$3" ]; then
    pass "$4"
  else
    fail "$4 (got exit=$rc decision=$dec reason=$rea; want $1/$2/$3)"
  fi
}

# ── 1. code, no test → BLOCK ──
consumer; mkdir -p src; printf 'const x=1\n' > src/foo.ts; git add -A
check 1 BLOCK no "code, no test → BLOCK (no)"

# ── 2. code + non-empty paired test → PASS ──
consumer; mkdir -p src tests
rtest tests/test-foo.sh; printf 'const x=1\n' > src/foo.ts; git add -A
check 0 PASS no "code + non-empty paired test → PASS"

# ── 3. code + empty paired test → BLOCK (empty-test) ──
consumer; mkdir -p src tests
printf '#!/usr/bin/env bash\n# nominal\n' > tests/test-foo.sh; printf 'const x=1\n' > src/foo.ts; git add -A
check 1 BLOCK empty-test "code + empty paired test → BLOCK (empty-test)"

# ── 4. code + non-paired test → BLOCK (name-mismatch) ──
consumer; mkdir -p src tests
rtest tests/test-bar.sh; printf 'const x=1\n' > src/foo.ts; git add -A
check 1 BLOCK name-mismatch "code + non-paired test → BLOCK (name-mismatch)"

# ── 5. code + pre-existing test (modified, not new) → BLOCK (no-new-test) ──
consumer; mkdir -p src tests
rtest tests/test-code.py; git add -A; git commit -qm legacy
printf 'x=1\n' > src/code.py
printf '#!/usr/bin/env bash\nassert "y"\n' > tests/test-code.py   # modify the existing test
git add -A
check 1 BLOCK no-new-test "code + pre-existing test only → BLOCK (no-new-test)"

# ── 6. docs (honest) → SKIP (no-code-files) ──
consumer; printf '# PLAN\n' > PLAN.md; git add -A
check 0 SKIP no-code-files "docs (honest) → SKIP (no-code-files)"

# ── 7. docs + broken internal link → BLOCK (docs-dishonest) ──
consumer; mkdir -p docs; printf '# D\n\nSee [x](./nope.md).\n' > docs/d.md; git add -A
check 1 BLOCK docs-dishonest "docs + broken link → BLOCK (docs-dishonest)"

# ── 8. config (valid) → SKIP (no-code-files) ──
consumer; printf '{}\n' > package.json; git add -A
check 0 SKIP no-code-files "config (valid) → SKIP (no-code-files)"

# ── 9. config (invalid JSON) → BLOCK (config-inconsistent) ──
consumer; printf '{"a":1,,}\n' > package.json; git add -A
check 1 BLOCK config-inconsistent "config (invalid JSON) → BLOCK (config-inconsistent)"

# ── 10. config: package.json script → missing file → BLOCK (config-inconsistent) ──
consumer; printf '{ "scripts": { "b": "node scripts/missing.mjs" } }\n' > package.json; git add -A
check 1 BLOCK config-inconsistent "config: script → missing file → BLOCK (config-inconsistent)"

# ── 11. shim, no integration → BLOCK (shim-no-integration) ──
consumer; shim foo.sh; git add -A
check 1 BLOCK shim-no-integration "shim, no integration → BLOCK (shim-no-integration)"

# ── 12. shim + paired invoking test → PASS ──
consumer; shim foo.sh
mkdir -p tests; printf '#!/usr/bin/env bash\nbash scripts/foo.sh\nassert "ran"\n' > tests/test-foo.sh
git add -A
check 0 PASS no "shim + paired invoking test → PASS"

# ── 13. nothing staged → SKIP (no-staged-files) ──
consumer
check 0 SKIP no-staged-files "nothing staged → SKIP (no-staged-files)"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
