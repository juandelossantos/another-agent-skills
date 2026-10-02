#!/usr/bin/env bash
# test-aas-resolve.sh — hermetic tests for scripts/aas-resolve.sh (P9.7).
#
# The resolver sets AAS_DIR to the framework root, in order:
#   1. $AAS_DIR (already a valid framework dir)
#   2. $ANOTHER_AGENT_SKILLS_DIR
#   3. `aas --dir` on PATH
#   4. per-OS install dir for the version pinned in .aas/config
#   5. legacy global dir (~/.config/opencode)
#   6. the framework source itself (resolver runs inside it)
#
# It must be POSIX and must never hardcode a developer path.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESOLVER="$REPO_ROOT/scripts/aas-resolve.sh"

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

# A minimal but valid framework dir (VERSION + scripts/git-hooks/).
make_fw() {
  local d="$1" v="${2:-6.2.0}"
  mkdir -p "$d/scripts/git-hooks"
  printf '%s\n' "$v" > "$d/VERSION"
}

# Source the resolver in a controlled env and print AAS_DIR.
# usage: resolve <project-dir> [KEY=VALUE ...]
resolve() {
  local proj="$1"; shift
  local envs=("HOME=$FAKE_HOME")
  local kv
  for kv in "$@"; do envs+=("$kv"); done
  ( cd "$proj" && env -u AAS_DIR -u ANOTHER_AGENT_SKILLS_DIR -u AAS_HOME \
      -u XDG_DATA_HOME -u LOCALAPPDATA "${envs[@]}" \
      sh -c ". '$RESOLVER'; printf '%s' \"\${AAS_DIR:-}\"" )
}

echo ""
echo "AAS RESOLVER — portable framework resolution (P9.7)"
echo "────────────────────────────────────────────────────"

# --- Static: POSIX + no hardcoded developer path ---
assert "resolver exists" "[ -f '$RESOLVER' ]"
assert "resolver is POSIX (no 'local ', '[[' or 'source ')" \
  "! grep -qE '(^|[[:space:]])local[[:space:]]|(^|[[:space:]])\[\[[[:space:]]|(^|[[:space:]])source[[:space:]]' '$RESOLVER'"
assert "resolver never hardcodes a developer/home path" \
  "! grep -qE '/home/|/Users/' '$RESOLVER'"
assert "resolver has no bash-only shebang requirement (sourced)" \
  "! grep -q 'BASH_SOURCE' '$RESOLVER'"

# --- 1. $AAS_DIR already valid wins ---
FAKE_HOME="$TMP/home1"; mkdir -p "$FAKE_HOME"
FW1="$TMP/fw1"; make_fw "$FW1" "1.1.1"
PROJ1="$TMP/proj1"; mkdir -p "$PROJ1"
OUT="$(resolve "$PROJ1" "AAS_DIR=$FW1")"
assert "1. explicit AAS_DIR is honored" "[ '$OUT' = '$FW1' ]"

# --- 2. ANOTHER_AGENT_SKILLS_DIR ---
FAKE_HOME="$TMP/home2"; mkdir -p "$FAKE_HOME"
FW2="$TMP/fw2"; make_fw "$FW2" "2.2.2"
PROJ2="$TMP/proj2"; mkdir -p "$PROJ2"
OUT="$(resolve "$PROJ2" "ANOTHER_AGENT_SKILLS_DIR=$FW2")"
assert "2. ANOTHER_AGENT_SKILLS_DIR is honored" "[ '$OUT' = '$FW2' ]"

# --- 3. aas --dir on PATH ---
FAKE_HOME="$TMP/home3"; mkdir -p "$FAKE_HOME"
FW3="$TMP/fw3"; make_fw "$FW3" "3.3.3"
PROJ3="$TMP/proj3"; mkdir -p "$PROJ3"
BIN3="$TMP/bin3"; mkdir -p "$BIN3"
printf '#!/bin/sh\nprintf "%%s\\n" "%s"\n' "$FW3" > "$BIN3/aas"
chmod +x "$BIN3/aas"
OUT="$( ( cd "$PROJ3" && env -u AAS_DIR -u ANOTHER_AGENT_SKILLS_DIR -u AAS_HOME \
    HOME="$FAKE_HOME" PATH="$BIN3:$PATH" \
    sh -c ". '$RESOLVER'; printf '%s' \"\${AAS_DIR:-}\"" ) )"
assert "3. aas --dir is honored when aas is on PATH" "[ '$OUT' = '$FW3' ]"

# --- 4. per-OS install dir for the pinned .aas/config version ---
FAKE_HOME="$TMP/home4"; mkdir -p "$FAKE_HOME"
FW4="$FAKE_HOME/.local/share/another-agent-skills/4.4.4"; make_fw "$FW4" "4.4.4"
PROJ4="$TMP/proj4"; mkdir -p "$PROJ4/.aas"
printf '{ "version": "4.4.4" }\n' > "$PROJ4/.aas/config"
OUT="$(resolve "$PROJ4")"
assert "4. pinned version resolves the per-OS install dir" "[ '$OUT' = '$FW4' ]"

# --- 5. legacy global dir (~/.config/opencode) ---
FAKE_HOME="$TMP/home5"; mkdir -p "$FAKE_HOME"
FW5="$FAKE_HOME/.config/opencode"; make_fw "$FW5" "5.5.5"
PROJ5="$TMP/proj5"; mkdir -p "$PROJ5"
OUT="$(resolve "$PROJ5")"
assert "5. legacy global dir is a fallback" "[ '$OUT' = '$FW5' ]"

# --- 6. the framework source itself (resolver runs inside it) ---
FAKE_HOME="$TMP/home6"; mkdir -p "$FAKE_HOME"
SRC="$TMP/src"; make_fw "$SRC" "6.6.6"
mkdir -p "$SRC/scripts"
cp "$RESOLVER" "$SRC/scripts/aas-resolve.sh"
PROJ6="$TMP/proj6"; mkdir -p "$PROJ6"
OUT="$( ( cd "$PROJ6" && env -u AAS_DIR -u ANOTHER_AGENT_SKILLS_DIR -u AAS_HOME \
    HOME="$FAKE_HOME" \
    sh -c "SCRIPT_DIR='$SRC/scripts'; . '$SRC/scripts/aas-resolve.sh'; printf '%s' \"\${AAS_DIR:-}\"" ) )"
assert "6. running inside the source returns the source tree" "[ '$OUT' = '$SRC' ]"

# --- 7. nothing found → AAS_DIR empty, no crash ---
FAKE_HOME="$TMP/home7"; mkdir -p "$FAKE_HOME"
PROJ7="$TMP/proj7"; mkdir -p "$PROJ7"
OUT="$( ( cd "$PROJ7" && env -u AAS_DIR -u ANOTHER_AGENT_SKILLS_DIR -u AAS_HOME \
    HOME="$FAKE_HOME" PATH="/usr/bin:/bin" \
    sh -c ". '$RESOLVER'; printf '%s' \"\${AAS_DIR:-}\"" ) )"
assert "7. no install → empty AAS_DIR (does not abort)" "[ -z '$OUT' ]"

# --- 8. drift notice is non-blocking and one line ---
FAKE_HOME="$TMP/home8"; mkdir -p "$FAKE_HOME"
FW8="$TMP/fw8"; make_fw "$FW8" "8.8.8"
PROJ8="$TMP/proj8"; mkdir -p "$PROJ8/.aas"
printf '{ "version": "1.0.0" }\n' > "$PROJ8/.aas/config"
OUT="$( ( cd "$PROJ8" && AAS_DIR="$FW8" sh -c \
    ". '$RESOLVER'; _aas_resolve_drift_notice" 2>&1 ); echo "rc=$?" )"
assert "8. drift notice mentions both versions" "echo '$OUT' | grep -q '1.0.0' && echo '$OUT' | grep -q '8.8.8'"
assert "8. drift notice never blocks (rc=0)" "echo '$OUT' | grep -q 'rc=0'"

# --- 9. matching versions → no drift notice ---
FAKE_HOME="$TMP/home9"; mkdir -p "$FAKE_HOME"
FW9="$TMP/fw9"; make_fw "$FW9" "9.9.9"
PROJ9="$TMP/proj9"; mkdir -p "$PROJ9/.aas"
printf '{ "version": "9.9.9" }\n' > "$PROJ9/.aas/config"
OUT="$( ( cd "$PROJ9" && AAS_DIR="$FW9" sh -c \
    ". '$RESOLVER'; _aas_resolve_drift_notice" 2>&1 ) )"
assert "9. no drift when versions match" "[ -z '$OUT' ]"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
