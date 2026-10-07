#!/usr/bin/env bash
# test-tdd-gate-shim-integration.sh — Phase 13 S4 (P13.4): an AAS shim is no
# longer silently exempt. A staged shim requires a name-paired staged test that
# actually INVOKES it (integration), not a nominal file.
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
# an AAS shim: #!/bin/sh + exec "$_AAS_ROOT/..."
shim() { mkdir -p scripts; printf '#!/bin/sh\nexec "$_AAS_ROOT/scripts/%s" "$@"\n' "$1" > "scripts/$1"; }
gate_exit() { ( unset REPO_ROOT; bash "$GATE" >/dev/null 2>&1 ); echo $?; }
expect() { [ "$(gate_exit)" = "$1" ] && pass "$2" || fail "$2 (expected exit $1, got $(gate_exit))"; }

# ── shim only → BLOCK (no integration test) ──
consumer; shim foo.sh; git add -A
expect 1 "shim only → BLOCK (no integration test)"

# ── shim + nominal (non-invoking) paired test → BLOCK ──
consumer; shim foo.sh
mkdir -p tests; printf '#!/usr/bin/env bash\n# nominal\n' > tests/test-foo.sh
git add -A
expect 1 "shim + nominal paired test (does not invoke) → BLOCK"

# ── shim + paired test that INVOKES it → PASS ──
consumer; shim foo.sh
mkdir -p tests; printf '#!/usr/bin/env bash\nbash scripts/foo.sh\nassert "ran"\n' > tests/test-foo.sh
git add -A
expect 0 "shim + paired test that invokes it → PASS"

# ── shim + invoking but NON-paired test → BLOCK ──
consumer; shim foo.sh
mkdir -p tests; printf '#!/usr/bin/env bash\nbash scripts/foo.sh\nassert "ran"\n' > tests/test-bar.sh
git add -A
expect 1 "shim + invoking non-paired test → BLOCK"

# ── a real (non-shim) .sh keeps the code path → BLOCK (no test) ──
consumer; mkdir -p scripts; printf '#!/usr/bin/env bash\necho hi\n' > scripts/real.sh; git add -A
expect 1 "real .sh (not a shim) → code path → BLOCK (no test)"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
