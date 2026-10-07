#!/usr/bin/env bash
# test-validate-docs-honesty.sh — Phase 13 S2: the docs-honesty validator.
#
# A doc is HONEST only if (a) every repo path it cites in backticks exists and
# (b) its internal `.md` links resolve. Placeholders are a non-blocking WARN.
# This is the real bug Phase 13 fixes: docs that cite paths/scripts that do not
# exist (the startup Protocol; the Gate 11 remedy).
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
V="$REPO_ROOT/scripts/validate-docs-honesty.sh"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

PASSED=0; FAILED=0; TOTAL=0
pass() { echo -e "  ${GREEN}✓${NC} $1"; PASSED=$((PASSED + 1)); TOTAL=$((TOTAL + 1)); }
fail() { echo -e "  ${RED}✗${NC} $1"; FAILED=$((FAILED + 1)); TOTAL=$((TOTAL + 1)); }

# ── fixture project ──
ROOT="$TMP/proj"
DOC="$ROOT/docs/doc.md"
mkdir -p "$ROOT/scripts" "$ROOT/docs"
printf 'echo hi\n' > "$ROOT/scripts/real.sh"
printf '# Sibling\n' > "$ROOT/docs/sibling.md"

# The validator is exercised on the fixed DOC path (rewritten per case).
run() { ( cd "$ROOT" && bash "$V" --root "$ROOT" docs/doc.md >/dev/null 2>&1 ); echo $?; }
run_strict() { ( cd "$ROOT" && bash "$V" --root "$ROOT" --strict docs/doc.md >/dev/null 2>&1 ); echo $?; }
expect() { [ "$(run)" = "$1" ] && pass "$2" || fail "$2 (expected exit $1, got $(run))"; }
expect_strict() { [ "$(run_strict)" = "$1" ] && pass "$2" || fail "$2 (expected strict exit $1, got $(run_strict))"; }

# ── honest doc: cites an existing path + plain commands ──
cat > "$DOC" <<'MD'
# Honest

Run `scripts/real.sh`, then `git commit -m "x"`.
MD
expect 0 "honest doc (cited path exists) → PASS"
expect_strict 0 "honest doc --strict → PASS"

# ── dishonest doc: cites a missing path → WARN by default, BLOCK with --strict ──
cat > "$DOC" <<'MD'
# Dishonest

Run `scripts/missing.sh` now.
MD
expect 0 "cited missing path → WARN (non-blocking)"
expect_strict 1 "cited missing path --strict → FAIL"

# ── command citing a missing script (the Gate 11 bug) → WARN / --strict FAIL ──
cat > "$DOC" <<'MD'
# Remedy

Apply `bash scripts/not-installed.sh` to fix it.
MD
expect 0 "command citing a missing script → WARN (non-blocking)"
expect_strict 1 "command citing a missing script --strict → FAIL"

# ── broken internal link → FAIL ──
cat > "$DOC" <<'MD'
# Broken

See [other](./nope.md).
MD
expect 1 "broken internal .md link → FAIL"

# ── resolved internal link → PASS ──
cat > "$DOC" <<'MD'
# OK

See [sibling](./sibling.md).
MD
expect 0 "resolved internal .md link → PASS"

# ── command tokens / branch names are not paths → PASS ──
cat > "$DOC" <<'MD'
# Commands

`git commit -m "x"` · `npx foo bar` · branch `feat/phase13-x`
MD
expect 0 "commands + branch names → not paths → PASS"

# ── placeholder → WARN (non-blocking) → PASS ──
cat > "$DOC" <<'MD'
# WIP

TODO: finish this.
MD
expect 0 "placeholder → WARN (non-blocking) → PASS"

# ── no doc files → PASS (nothing to verify) ──
NOFILES=$(( cd "$ROOT" && bash "$V" --root "$ROOT" >/dev/null 2>&1 ); echo $? )
[ "$NOFILES" = "0" ] && pass "no files → PASS" || fail "no files → PASS (got $NOFILES)"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
