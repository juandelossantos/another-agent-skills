#!/usr/bin/env bash
# test-validate-config-consistency.sh — Phase 13 S3: the config-consistency
# validator. A config file must be valid (JSON/YAML/TOML), and every local file
# a `package.json` script references must exist.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
V="$REPO_ROOT/scripts/validate-config-consistency.sh"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

PASSED=0; FAILED=0; TOTAL=0
pass() { echo -e "  ${GREEN}✓${NC} $1"; PASSED=$((PASSED + 1)); TOTAL=$((TOTAL + 1)); }
fail() { echo -e "  ${RED}✗${NC} $1"; FAILED=$((FAILED + 1)); TOTAL=$((TOTAL + 1)); }

ROOT="$TMP/proj"
mkdir -p "$ROOT/scripts"
printf 'export const x = 1\n' > "$ROOT/scripts/real.mjs"

run() { ( cd "$ROOT" && bash "$V" --root "$ROOT" "$1" >/dev/null 2>&1 ); echo $?; }
expect() { [ "$(run "$1")" = "$2" ] && pass "$3" || fail "$3 (expected exit $2, got $(run "$1"))"; }

# ── JSON ──
printf '{"a": 1}\n' > "$ROOT/good.json"
printf '{"a": 1,,}\n' > "$ROOT/bad.json"
expect good.json 0 "valid JSON → PASS"
expect bad.json  1 "invalid JSON → FAIL"

# ── TOML ──
printf 'name = "x"\n' > "$ROOT/good.toml"
printf '[section\nname = "x"\n' > "$ROOT/bad.toml"
expect good.toml 0 "valid TOML → PASS"
expect bad.toml  1 "invalid TOML → FAIL"

# ── YAML ──
printf 'name: ci\non: push\n' > "$ROOT/good.yml"
printf 'name: ci\nfoo: [unclosed\n' > "$ROOT/bad.yml"
expect good.yml 0 "valid YAML → PASS"
expect bad.yml  1 "invalid YAML → FAIL"

# ── package.json: script referencing an existing local file → PASS ──
cat > "$ROOT/package.json" <<'JSON'
{ "name": "x", "scripts": { "build": "node scripts/real.mjs", "test": "npm run build" } }
JSON
expect package.json 0 "package.json scripts reference existing files → PASS"

# ── package.json: script referencing a MISSING local file → FAIL ──
cat > "$ROOT/package.json" <<'JSON'
{ "name": "x", "scripts": { "build": "node scripts/missing.mjs" } }
JSON
expect package.json 1 "package.json script references a missing file → FAIL"

# ── package.json: binary-only scripts (no local file) → PASS ──
cat > "$ROOT/package.json" <<'JSON'
{ "name": "x", "scripts": { "lint": "eslint .", "fmt": "prettier --write ." } }
JSON
expect package.json 0 "package.json binary-only scripts → PASS"

# ── no files → PASS ──
NOFILES=$(( cd "$ROOT" && bash "$V" --root "$ROOT" >/dev/null 2>&1 ); echo $? )
[ "$NOFILES" = "0" ] && pass "no files → PASS" || fail "no files → PASS (got $NOFILES)"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
