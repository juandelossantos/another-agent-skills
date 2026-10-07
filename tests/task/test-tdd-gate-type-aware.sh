#!/usr/bin/env bash
# test-tdd-gate-type-aware.sh — Phase 13 (S1): the gate classifies staged files
# by TYPE. docs (`*.md`) and config (`*.json`) are NOT code (warn, not block, in
# S1 — the docs/config validators land in S2/S3). Code keeps the pairing + a NEW
# non-empty check: a paired but EMPTY test must BLOCK (today it passes).
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
GATE="$REPO_ROOT/scripts/tdd-gate.sh"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

PASSED=0; FAILED=0; TOTAL=0
pass() { echo -e "  ${GREEN}✓${NC} $1"; PASSED=$((PASSED + 1)); TOTAL=$((TOTAL + 1)); }
fail() { echo -e "  ${RED}✗${NC} $1"; FAILED=$((FAILED + 1)); TOTAL=$((TOTAL + 1)); }
assert() { TOTAL=$((TOTAL + 1)); if eval "$2"; then pass "$1"; else fail "$1"; fi; }

consumer() {
  cd "$TMP" || return
  rm -rf r; mkdir r; cd r || return
  git init -q; git config user.email t@t.t; git config user.name t
  echo base > base.txt; git add base.txt; git commit -qm base
}
gate_exit() { ( unset REPO_ROOT; bash "$GATE" >/dev/null 2>&1 ); echo $?; }
expect() { [ "$(gate_exit)" = "$1" ] && pass "$2" || fail "$2 (expected exit $1)"; }

# ── docs-only → NOT code (S1: warn, not block) ──
consumer
printf '# PLAN\n' > PLAN.md; git add -A
expect 0 "docs-only (PLAN.md) → not blocked"

# ── docs + broken internal link → BLOCK (Phase 13 S2: docs-honesty) ──
consumer
mkdir -p docs; printf '# Doc\n\nSee [x](./nope.md).\n' > docs/broken.md; git add -A
expect 1 "docs with a broken internal link → BLOCK (S2)"

# ── config-only → NOT code (S1: warn, not block) ──
consumer
printf '{}\n' > package.json; git add -A
expect 0 "config-only (valid package.json) → not blocked"

# ── config + invalid JSON → BLOCK (Phase 13 S3: config-consistency) ──
consumer
printf '{"a": 1,,}\n' > package.json; git add -A
expect 1 "config with invalid JSON → BLOCK (S3)"

# ── code-only → BLOCK (no test) ──
consumer
mkdir -p src; printf 'const x=1\n' > src/foo.ts; git add -A
expect 1 "code-only (src/foo.ts) → BLOCK"

# ── code + EMPTY test → BLOCK (the new non-empty check) ──
consumer
mkdir -p src tests
printf '#!/usr/bin/env bash\n' > tests/test-foo.sh   # created first (staging order)
printf 'const x=1\n' > src/foo.ts
git add -A
expect 1 "code + EMPTY test → BLOCK"

# ── code + real test (asserts) → PASS ──
consumer
mkdir -p src tests
printf '#!/usr/bin/env bash\nassert(){ :; }\nassert "foo behaves"\n' > tests/test-foo.sh
printf 'const x=1\n' > src/foo.ts
git add -A
expect 0 "code + real test → PASS"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
