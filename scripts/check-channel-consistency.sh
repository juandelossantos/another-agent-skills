#!/usr/bin/env bash
# check-channel-consistency.sh — Phase 14 S3: every version surface must agree
# with VERSION. Turns "all channels agree" from a promise into a check.
#
# Local surfaces (always): npm/package.json · README badge · docs/index.html ·
# bootstrap.sh example · web footer config. With --online it also compares the
# npm registry and the GitHub release tag.
#
# Usage: bash scripts/check-channel-consistency.sh [--root DIR] [--online]
# Exit codes: 0 = consistent, 1 = a surface disagrees
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'

ROOT=""; ONLINE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --root) ROOT="${2:-}"; shift 2 ;;
    --online) ONLINE=1; shift ;;
    -h|--help) echo "Usage: bash scripts/check-channel-consistency.sh [--root DIR] [--online]"; exit 0 ;;
    *) shift ;;
  esac
done
[ -z "$ROOT" ] && ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
ROOT="$(cd "$ROOT" 2>/dev/null && pwd)" || { echo "check-channel-consistency: bad --root"; exit 2; }

FAIL=0
ok()  { echo -e "  ${GREEN}✓${NC} $1"; }
bad() { echo -e "  ${RED}✗${NC} $1"; FAIL=$((FAIL + 1)); }

if [ ! -f "$ROOT/VERSION" ]; then
  echo -e "  ${RED}✗${NC} VERSION not found at $ROOT/VERSION"
  exit 1
fi
V="$(tr -d '[:space:]' < "$ROOT/VERSION")"

# assert a file contains a literal string
contains() {  # relpath needle label
  if [ ! -f "$ROOT/$1" ]; then bad "$1 missing"; return; fi
  if grep -qF -- "$2" "$ROOT/$1"; then ok "$3"; else bad "$3 — expected '$2' in $1"; fi
}

contains "npm/package.json"  "\"version\": \"$V\""  "npm/package.json = $V"
contains "README.md"         "Version: v$V"          "README badge = v$V"
contains "docs/index.html"   "<td>v$V</td>"          "docs/index.html current version = v$V"
contains "bootstrap.sh"      "--version v$V"         "bootstrap.sh example = v$V"
contains "web/src/config.ts" "VERSION = 'v$V'"       "web footer config = v$V"
contains "web/src/i18n/en.ts" "v$V · MIT License"     "web footer (EN) = v$V"
contains "web/src/i18n/es.ts" "v$V · Licencia MIT"    "web footer (ES) = v$V"

if [ "$ONLINE" = "1" ]; then
  if command -v npm >/dev/null 2>&1; then
    REG="$(npm view @juandelossantos/another-agent-skills version 2>/dev/null || true)"
    if [ -z "$REG" ]; then bad "npm registry — could not read (offline?)"
    elif [ "$REG" = "$V" ]; then ok "npm registry = $V"
    else bad "npm registry = $REG (expected $V)"; fi
  else bad "npm CLI not available"; fi

  if command -v gh >/dev/null 2>&1; then
    REL="$(gh release view "v$V" --json tagName --jq .tagName 2>/dev/null || true)"
    if [ "$REL" = "v$V" ]; then ok "GitHub release v$V exists"
    else bad "GitHub release v$V not found"; fi
  fi
fi

echo ""
if [ "$FAIL" -gt 0 ]; then
  echo -e "  ${RED}✗ $FAIL channel(s) inconsistent with VERSION=$V${NC}"
  exit 1
fi
echo -e "  ${GREEN}✓ all channels consistent with VERSION=$V${NC}"
exit 0
