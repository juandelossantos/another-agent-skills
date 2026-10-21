#!/usr/bin/env bash
# check-portability.sh — fail when a runtime script uses GNU-only tool syntax.
#
# Why: macOS ships BSD userland. `grep -P` is not available, `sed -i` needs a
# backup suffix, `date -d` and `readlink -f` do not exist. These commands fail
# *silently* inside `$( ... || true )`, so a gate reads empty values and blocks
# forever — exactly how Gate 11 (`validate-health-check.sh`) became impossible
# to pass on a Mac. Linux CI cannot see it.
#
# Scope: everything that runs on a user's machine. `scripts/eval/` is
# maintainer-only and exempt. A line with `||` (a BSD fallback) or
# `command -v` (feature detection) is allowed.
#
# Usage: bash scripts/check-portability.sh [--root DIR]
# Exit:  0 = clean, 1 = GNU-only syntax found, 2 = bad invocation
#
# Note: this script is itself bash 3.2-compatible and BSD-safe.

set -uo pipefail

ROOT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --root) ROOT="${2:-}"; shift 2 ;;
    -h|--help) echo "Usage: bash scripts/check-portability.sh [--root DIR]"; exit 0 ;;
    *) echo "check-portability: unknown argument: $1" >&2; exit 2 ;;
  esac
done
if [ -z "$ROOT" ]; then
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi
ROOT="$(cd "$ROOT" 2>/dev/null && pwd)" || { echo "check-portability: bad --root" >&2; exit 2; }

# GNU-only constructs, and why each one breaks on macOS.
PATTERN_REGEXES='(^|[^[:alnum:]_])(grep|egrep)[[:space:]][^|;]*-[[:alpha:]]*P([[:space:]"'"'"']|$)|(^|[[:space:]])sed[[:space:]]+-i([[:space:]]|$)|(^|[[:space:]])date[[:space:]]+-d[[:space:]]|(^|[[:space:]])readlink[[:space:]]+-f|(^|[[:space:]])stat[[:space:]]+-c([[:space:]]|$)|(^|[[:space:]])xargs[[:space:]]+-r([[:space:]]|$)|(^|[[:space:]])sort[[:space:]]+-V([[:space:]]|$)|(^|[[:space:]])sed[[:space:]]+-r([[:space:]]|$)'

FINDINGS=""

scan_file() {
  local f="$1" hits
  [ -f "$f" ] || return 0
  case "$f" in
    *.md) return 0 ;;
    "$ROOT/scripts/check-portability.sh") return 0 ;;  # the patterns live here
  esac
  # Drop comments, lines with a BSD fallback (||), and feature detection.
  hits="$(grep -nE "$PATTERN_REGEXES" "$f" 2>/dev/null \
    | grep -vE '^[0-9]+:[[:space:]]*#' \
    | grep -vF '||' \
    | grep -vF 'command -v' \
    | sed "s|^|${f}:|")"
  if [ -n "$hits" ]; then
    FINDINGS="${FINDINGS}${hits}
"
  fi
  return 0
}

scan_file "$ROOT/bin/aas"
scan_file "$ROOT/bootstrap.sh"
scan_file "$ROOT/install.sh"
scan_file "$ROOT/uninstall.sh"
for f in "$ROOT"/scripts/*.sh "$ROOT"/scripts/lib/*.sh "$ROOT"/scripts/git-hooks/*; do
  scan_file "$f"
done

if [ -n "$FINDINGS" ]; then
  echo ""
  echo "portability: GNU-only tool syntax in runtime scripts (macOS/BSD breaks)"
  echo ""
  printf '%s' "$FINDINGS"
  echo "Fixes: grep -oP -> grep -oE | sed -n 's/.../p'; sed -i -> sed -i.bak + rm;"
  echo "       date -d -> BSD fallback; readlink -f -> cd+pwd -P; stat -c -> stat -f fallback."
  echo "Maintainer-only tooling under scripts/eval/ is exempt."
  exit 1
fi

echo "portability: OK (no GNU-only syntax in runtime scripts)"
exit 0
