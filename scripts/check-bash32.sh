#!/usr/bin/env bash
# check-bash32.sh — fail when a runtime script uses bash 4-only syntax.
#
# Why: stock macOS ships bash 3.2 (/bin/bash), and it is the interpreter behind
# `#!/usr/bin/env bash` for every user-facing entrypoint — the `aas` CLI, the
# bootstrap, the installer, the git hooks and the gates. bash 4 additions parse
# or run fine on Linux CI and then break on a real Mac. This check makes that
# class of bug mechanical instead of a support ticket.
#
# Scope: everything that runs on a user's machine. `scripts/eval/` is
# maintainer-only tooling (never installed into a project, needs jq/Python) and
# is exempt by design.
#
# Usage: bash scripts/check-bash32.sh [--root DIR]
# Exit:  0 = clean, 1 = incompatible syntax found, 2 = bad invocation
#
# Note: this script is itself bash 3.2-compatible (it must run on macOS).

set -uo pipefail

ROOT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --root) ROOT="${2:-}"; shift 2 ;;
    -h|--help) echo "Usage: bash scripts/check-bash32.sh [--root DIR]"; exit 0 ;;
    *) echo "check-bash32: unknown argument: $1" >&2; exit 2 ;;
  esac
done
if [ -z "$ROOT" ]; then
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi
ROOT="$(cd "$ROOT" 2>/dev/null && pwd)" || { echo "check-bash32: bad --root" >&2; exit 2; }

# bash 4+ constructs that parse or run on Linux and break on macOS bash 3.2.
PATTERN_REGEXES='\$\{[A-Za-z_][A-Za-z0-9_]*(\[[^]]*\])?(\^|,)|declare -A|typeset -A|^[[:space:]]*(mapfile|readarray)[[:space:]]|(^|[[:space:]])(declare|local|typeset) -n[[:space:]]|\|&|&>>|wait -n'

FINDINGS=""

scan_file() {
  local f="$1" hits
  [ -f "$f" ] || return 0
  case "$f" in
    *.md) return 0 ;;
    "$ROOT/scripts/check-bash32.sh") return 0 ;;  # the patterns live here as strings
  esac
  # grep -nE prints "<line>:<text>". A comment that merely *names* the syntax
  # must not fail the check, so drop lines whose first non-space char is '#'.
  hits="$(grep -nE "$PATTERN_REGEXES" "$f" 2>/dev/null \
    | grep -vE '^[0-9]+:[[:space:]]*#' \
    | sed "s|^|${f}:|")"
  if [ -n "$hits" ]; then
    FINDINGS="${FINDINGS}${hits}
"
  fi
  return 0
}

# Runtime surface: everything a user executes. Git hooks are extensionless.
scan_file "$ROOT/bin/aas"
scan_file "$ROOT/bootstrap.sh"
scan_file "$ROOT/install.sh"
scan_file "$ROOT/uninstall.sh"
for f in "$ROOT"/scripts/*.sh "$ROOT"/scripts/lib/*.sh "$ROOT"/scripts/git-hooks/*; do
  scan_file "$f"
done

if [ -n "$FINDINGS" ]; then
  echo ""
  echo "bash 3.2 compatibility: incompatible syntax in runtime scripts"
  echo ""
  printf '%s' "$FINDINGS"
  echo "macOS ships bash 3.2; these constructs need bash 4+."
  echo "Rewrite them (e.g. lowercase with: printf '%s' \"\$v\" | tr '[:upper:]' '[:lower:]')."
  echo "Maintainer-only tooling under scripts/eval/ is exempt."
  exit 1
fi

echo "bash 3.2 compatibility: OK (runtime scripts)"
exit 0
