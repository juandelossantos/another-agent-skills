#!/usr/bin/env bash
# validate-config-consistency.sh — Phase 13 S3: config files must be consistent.
#
# 1) Valid syntax — JSON via `jq`, YAML via ruby/pyyaml, TOML via python tomllib.
# 2) Every LOCAL file a `package.json` `scripts.*` command references must exist
#    (relative to that package.json). Bare binaries (`eslint`, `astro`, …) are
#    not verifiable and are ignored.
#
# Parsers degrade gracefully: if no YAML/TOML parser is available, the syntax
# check is skipped with a warning (never a false failure).
#
# Usage: bash scripts/validate-config-consistency.sh [--root DIR] FILE...
# Exit codes: 0 = PASS, 1 = FAIL
set -uo pipefail
set -f   # no pathname expansion — script tokens are data, never globs

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'

ROOT=""
FILES=()
while [ $# -gt 0 ]; do
  case "$1" in
    --root) ROOT="${2:-}"; shift 2 ;;
    -h|--help) echo "Usage: bash scripts/validate-config-consistency.sh [--root DIR] FILE..."; exit 0 ;;
    *) FILES+=("$1"); shift ;;
  esac
done

if [ -z "$ROOT" ]; then
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi
ROOT="$(cd "$ROOT" 2>/dev/null && pwd)" || { echo "validate-config-consistency: bad --root"; exit 2; }

[ ${#FILES[@]} -eq 0 ] && exit 0

FAIL=0
fail() { echo -e "  ${RED}✗${NC} $1"; FAIL=$((FAIL + 1)); }
skip() { echo -e "  ${YELLOW}⚠${NC} $1"; }

# ── available parsers ──
YAML_CMD=""
if command -v ruby >/dev/null 2>&1; then YAML_CMD="ruby"
elif python3 -c 'import yaml' >/dev/null 2>&1; then YAML_CMD="pyyaml"; fi
TOML_CMD=""
if python3 -c 'import tomllib' >/dev/null 2>&1; then TOML_CMD="tomllib"; fi

# Is a script token a LOCAL file reference? (Not a binary, flag, or shell op.)
is_local_file() {
  local w="$1"
  [ -z "$w" ] && return 1
  echo "$w" | grep -qE '^[A-Za-z0-9._/@-]+$' || return 1     # path-safe chars only
  echo "$w" | grep -qE '^\./|^\.\./' && return 0             # explicit relative
  echo "$w" | grep -qE '\.(mjs|cjs|js|jsx|ts|tsx|sh|bash|py|rb|json|ya?ml|toml)$' && return 0
  echo "$w" | grep -qE '/' && return 0                       # directory-qualified
  return 1
}

for f in "${FILES[@]}"; do
  [ -f "$f" ] || f="$ROOT/$f"
  [ -f "$f" ] || continue
  dir="$(dirname "$f")"
  base="$(basename "$f")"
  ext="${f##*.}"

  # ── CHECK 1: syntax ──
  case "$ext" in
    json)
      jq empty "$f" >/dev/null 2>&1 || fail "$f: invalid JSON"
      ;;
    yaml|yml)
      case "$YAML_CMD" in
        ruby)   ruby -ryaml -e 'YAML.safe_load(File.read(ARGV[0]), aliases: true)' "$f" >/dev/null 2>&1 || fail "$f: invalid YAML" ;;
        pyyaml) python3 -c 'import yaml,sys; yaml.safe_load(open(sys.argv[1]))' "$f" >/dev/null 2>&1 || fail "$f: invalid YAML" ;;
        *)      skip "$f: YAML parser unavailable — syntax not verified" ;;
      esac
      ;;
    toml)
      if [ "$TOML_CMD" = "tomllib" ]; then
        python3 -c 'import tomllib,sys; tomllib.load(open(sys.argv[1],"rb"))' "$f" >/dev/null 2>&1 || fail "$f: invalid TOML"
      else
        skip "$f: TOML parser unavailable — syntax not verified"
      fi
      ;;
  esac

  # ── CHECK 2: package.json scripts reference existing local files ──
  if [ "$base" = "package.json" ]; then
    while IFS= read -r cmd; do
      [ -z "$cmd" ] && continue
      # shellcheck disable=SC2086
      for w in $cmd; do
        is_local_file "$w" || continue
        [ -e "$dir/$w" ] || [ -e "$ROOT/$w" ] || fail "$f: script references a missing file: \`$w\`"
      done
    done < <(jq -r '.scripts // {} | .[]' "$f" 2>/dev/null || true)
  fi
done

if [ "$FAIL" -gt 0 ]; then
  echo -e "  ${RED}❌ config-consistency: $FAIL issue(s).${NC}"
  exit 1
fi
exit 0
