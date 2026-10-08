#!/usr/bin/env bash
# test-check-channel-consistency.sh — Phase 14 S3: the channel-consistency check.
# Every version surface (npm package, README badge, docs, bootstrap example, the
# web footer config) must agree with VERSION. This is the check that turns
# "all channels agree" from a promise into something executable.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECK="$REPO_ROOT/scripts/check-channel-consistency.sh"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

PASSED=0; FAILED=0; TOTAL=0
pass() { echo -e "  ${GREEN}✓${NC} $1"; PASSED=$((PASSED + 1)); TOTAL=$((TOTAL + 1)); }
fail() { echo -e "  ${RED}✗${NC} $1"; FAILED=$((FAILED + 1)); TOTAL=$((TOTAL + 1)); }

# Build a fixture repo where every surface is at $1.
fixture() {
  local v="$1" r="$TMP/repo"
  rm -rf "$r"; mkdir -p "$r/npm" "$r/docs" "$r/web/src" "$r/web/src/i18n"
  printf '%s\n' "$v" > "$r/VERSION"
  printf '{\n  "version": "%s"\n}\n' "$v" > "$r/npm/package.json"
  printf '[![Version: v%s](https://img.shields.io/badge/version-%s-blue.svg)](./RELEASE-NOTES.md)\n' "$v" "$v" > "$r/README.md"
  printf '      <tr><td data-i18n="overview.version">Current version</td><td>v%s</td></tr>\n' "$v" > "$r/docs/index.html"
  printf '#!/usr/bin/env bash\n#   bash bootstrap.sh --version v%s\n' "$v" > "$r/bootstrap.sh"
  printf "export const VERSION = 'v%s';\n" "$v" > "$r/web/src/config.ts"
  printf "    copy: 'v%s · MIT License · Made by x',\n" "$v" > "$r/web/src/i18n/en.ts"
  printf "    copy: 'v%s · Licencia MIT · Hecho por x',\n" "$v" > "$r/web/src/i18n/es.ts"
  echo "$r"
}
run() { ( bash "$CHECK" --root "$1" >/dev/null 2>&1 ); echo $?; }
expect() { [ "$(run "$2")" = "$1" ] && pass "$3" || fail "$3 (expected exit $1, got $(run "$2"))"; }

# ── all surfaces agree → PASS ──
r="$(fixture 9.9.9)"
expect 0 "$r" "all surfaces agree (9.9.9) → PASS"

# ── npm/package.json out of sync → FAIL ──
r="$(fixture 9.9.9)"; printf '{\n  "version": "9.9.8"\n}\n' > "$r/npm/package.json"
expect 1 "$r" "npm/package.json out of sync → FAIL"

# ── web footer config out of sync → FAIL ──
r="$(fixture 9.9.9)"; printf "export const VERSION = 'v9.9.8';\n" > "$r/web/src/config.ts"
expect 1 "$r" "web/src/config.ts out of sync → FAIL"

# ── README badge out of sync → FAIL ──
r="$(fixture 9.9.9)"; printf '[![Version: v9.9.8](https://img.shields.io/badge/version-9.9.8-blue.svg)](./RELEASE-NOTES.md)\n' > "$r/README.md"
expect 1 "$r" "README badge out of sync → FAIL"

# ── missing VERSION → FAIL ──
r="$(fixture 9.9.9)"; rm -f "$r/VERSION"
expect 1 "$r" "missing VERSION → FAIL"

# ── the real repo is consistent → PASS ──
expect 0 "$REPO_ROOT" "the real repo is consistent → PASS"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
