#!/usr/bin/env bash
# test-bootstrap-bundle.sh — the documented one-liner
#   curl -fsSL .../releases/latest/download/bootstrap.sh | bash
# must actually work (Phase 9/P9.2). The repo's bootstrap.sh sources a sibling
# scripts/lib/aas.sh and reads BASH_SOURCE, so it cannot run standalone or when
# piped. build-release.sh therefore emits a stable-name, SELF-CONTAINED
# `bootstrap.sh` asset (aas.sh inlined, sibling-source lines dropped), and
# release.yml publishes it. This pins that contract.
#
# Hermetic: a local fake release; no network.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

export HOME="$TMP/home"; mkdir -p "$HOME"
export AAS_HOME="$TMP/data" AAS_BIN_DIR="$TMP/bin" AAS_RELEASE_BASE_URL="$TMP/rel"
export AAS_LATEST_VERSION="9.8.7"
unset AAS_AGENTS 2>/dev/null || true

mkdir -p "$TMP/rel/v9.8.7"
( cd "$REPO_ROOT" && bash scripts/build-release.sh v9.8.7 "$TMP/rel/v9.8.7" ) > "$TMP/build.log" 2>&1; RC=$?
[ "$RC" -eq 0 ]; check $? "build-release emits the release (got rc=$RC)"

BUNDLE="$TMP/rel/v9.8.7/bootstrap.sh"
[ -f "$BUNDLE" ]; check $? "dist/bootstrap.sh (stable name) is emitted"
[ -x "$BUNDLE" ]; check $? "dist/bootstrap.sh is executable"
bash -n "$BUNDLE" 2>/dev/null; check $? "dist/bootstrap.sh parses"

# ── Self-contained: no sibling dependency, no unguarded BASH_SOURCE ─────────
! grep -qE '^[[:space:]]*source .*scripts/lib/aas\.sh' "$BUNDLE"; check $? "bundle does not source a sibling scripts/lib/aas.sh"
grep -q 'aas_install_release' "$BUNDLE"; check $? "bundle inlines the distribution library"

# ── The documented one-liner: pipe it to bash, run from an empty dir ─────────
RUN="$TMP/empty"; mkdir -p "$RUN"
( cd "$RUN" && cat "$BUNDLE" | bash ) > "$TMP/pipe.log" 2>&1; RC=$?
[ "$RC" -eq 0 ]; check $? "piped bundle installs (got rc=$RC)"
[ -x "$AAS_HOME/9.8.7/bin/aas" ]; check $? "piped install materialized bin/aas"
[ -L "$AAS_BIN_DIR/aas" ]; check $? "piped install linked the aas symlink"

# ── Running the asset as a file also works ───────────────────────────────────
rm -rf "$AAS_HOME" "$AAS_BIN_DIR"
( cd "$RUN" && bash "$BUNDLE" ) > "$TMP/file.log" 2>&1; RC=$?
[ "$RC" -eq 0 ]; check $? "bundle run as a file installs (got rc=$RC)"

# ── checksums cover the bundle too ───────────────────────────────────────────
grep -q 'bootstrap.sh' "$TMP/rel/v9.8.7/checksums.txt"; check $? "checksums.txt includes bootstrap.sh"

# ── release.yml publishes the stable asset ───────────────────────────────────
grep -q 'dist/bootstrap.sh' "$REPO_ROOT/.github/workflows/release.yml"; check $? "release.yml uploads dist/bootstrap.sh"

exit "$fail"
