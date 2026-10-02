#!/usr/bin/env bash
# test-bootstrap-hardening.sh — bootstrap.sh argument hardening.
#
# A missing --version value must be a clear usage error (rc 2), not a silent
# `set -e` abort from `shift 2` with no explanation.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

export HOME="$TMP/home"; mkdir -p "$HOME"
export AAS_HOME="$TMP/data" AAS_BIN_DIR="$TMP/bin"

bash "$REPO_ROOT/bootstrap.sh" --version >"$TMP/a.log" 2>&1; RC=$?
[ "$RC" -eq 2 ]; check $? "bootstrap --version (no value) exits 2 (got $RC)"
grep -qi "version" "$TMP/a.log"; check $? "bootstrap --version (no value) reports an error"

bash "$REPO_ROOT/bootstrap.sh" --version= >"$TMP/b.log" 2>&1; RC=$?
[ "$RC" -eq 2 ]; check $? "bootstrap --version= (empty) exits 2 (got $RC)"

# --dry-run with a pinned version still mutates nothing (regression guard).
bash "$REPO_ROOT/bootstrap.sh" --version 1.2.3 --dry-run >"$TMP/c.log" 2>&1; RC=$?
[ "$RC" -eq 0 ]; check $? "bootstrap --dry-run still exits 0 (got $RC)"
[ ! -e "$AAS_HOME" ]; check $? "--dry-run created no install root"

exit "$fail"
