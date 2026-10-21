#!/usr/bin/env bash
# bash32-smoke-inner.sh — the user-facing entrypoints, executed under bash 3.2.
#
# This file is NOT a test suite by itself: tests/test-bash32-smoke.sh runs it
# inside a `bash:3.2` container (stock macOS's /bin/bash) with the framework
# mounted read-only at /src. It reproduces the real failure modes:
#
#   aas install --agents auto   -> args[@]: unbound variable (empty array + set -u)
#   aas uninstall (no rc files) -> files[@]: unbound variable
#
# It must stay bash 3.2-compatible itself, so no bash 4 syntax and no empty
# array expansion.

set -uo pipefail

REPO="/src"
WORK="${TMPDIR:-/tmp}/aas32.$$"
mkdir -p "$WORK/home" "$WORK/proj" "$WORK/emptyhome"
trap 'rm -rf "$WORK"' EXIT

fail=0
check() {  # description, rc
  if [ "$2" -eq 0 ]; then
    echo "  ✓ $1"
  else
    echo "  ✗ $1"
    fail=1
  fi
}

echo ""
echo "bash 3.2 smoke — user-facing entrypoints"
echo "────────────────────────────────────────"

echo ""
echo "Group 1 — aas --version / --dir"
V="$(tr -d '[:space:]' < "$REPO/VERSION")"
OUT="$(HOME="$WORK/home" bash "$REPO/bin/aas" --version 2>&1)"; check "aas --version exits 0" $?
[ "$OUT" = "$V" ]; check "aas --version prints $V (got '$OUT')" $?
OUT="$(bash "$REPO/bin/aas" --dir 2>&1)"; check "aas --dir exits 0" $?
[ "$OUT" = "$REPO" ]; check "aas --dir prints the framework root" $?

echo ""
echo "Group 2 — aas install (the reported macOS failure)"
OUT="$(cd "$WORK/proj" && HOME="$WORK/home" bash "$REPO/bin/aas" install --agents auto </dev/null 2>&1)"; RC=$?
check "aas install --agents auto exits 0 (got $RC)" "$RC"
[ -f "$WORK/proj/AGENTS.md" ]; check "install created AGENTS.md" $?
echo "$OUT" | grep -q 'unbound variable'; [ $? -ne 0 ]; check "no 'unbound variable' in the output" $?

echo ""
echo "Group 3 — the non-empty args path still threads the flag"
OUT="$(cd "$WORK/proj" && HOME="$WORK/home" bash "$REPO/bin/aas" install --agents claude --skip-self-improvement </dev/null 2>&1)"; RC=$?
check "aas install --skip-self-improvement exits 0 (got $RC)" "$RC"
echo "$OUT" | grep -q 'unbound variable'; [ $? -ne 0 ]; check "no 'unbound variable' in the output" $?

echo ""
echo "Group 4 — aas uninstall with no shell rc files"
OUT="$(HOME="$WORK/emptyhome" AAS_HOME="$WORK/emptyhome/data" AAS_BIN_DIR="$WORK/emptyhome/bin" \
  bash "$REPO/bin/aas" uninstall 2>&1)"; RC=$?
check "aas uninstall exits 0 with an empty HOME (got $RC)" "$RC"
echo "$OUT" | grep -q 'unbound variable'; [ $? -ne 0 ]; check "no 'unbound variable' in the output" $?

echo ""
echo "Group 5 — the guard itself runs on bash 3.2"
bash "$REPO/scripts/check-bash32.sh" --root "$REPO" >/dev/null 2>&1
check "check-bash32.sh passes on bash 3.2" $?

echo ""
if [ "$fail" -ne 0 ]; then
  echo "FAILED"
  exit 1
fi
echo "PASS"
exit 0
