#!/usr/bin/env bash
# stack-config-cmd.sh — single source for reading a command from a project's
# STACK_CONFIG.md table. Used by the pre-commit Gate 14 (B12) and MIRRORED by
# templates/gates.yml, which runs in CI without the framework installed (so it
# cannot call this script — the parity is asserted by tests/test-stack-config-cmd.sh).
#
# Usage: stack-config-cmd.sh <field> [file]
#   <field>  Test | Lint | Build | Type check | …
#   [file]   STACK_CONFIG.md path (default: ./STACK_CONFIG.md)
#
# Resolution: prefer the EXACT `| <field> |` row; else the FIRST `| <field> … |`
# row (e.g. `| Test (all) |`). Prints the command with backticks stripped.
# Prints nothing when the row is absent or is a `<configure: …>` placeholder.
#
# The old pre-commit parser (`grep -A1 '^| Test' | tail -1`) took the line AFTER
# the last `Test` row — running the wrong command (e.g. lint) → a FALSE PASS.
set -uo pipefail

field="${1:-}"
file="${2:-STACK_CONFIG.md}"

if [ -z "$field" ]; then
  echo "usage: stack-config-cmd.sh <field> [file]" >&2
  exit 2
fi
[ -f "$file" ] || exit 0

# 1) exact `| <field> |` row; 2) first `| <field> … |` row (space after the field).
row="$(grep -E "^\\| ${field} \\|" "$file" 2>/dev/null | head -1 || true)"
if [ -z "$row" ]; then
  row="$(grep -E "^\\| ${field}[[:space:]]" "$file" 2>/dev/null | head -1 || true)"
fi
[ -n "$row" ] || exit 0

# Prefer the backtick content; else the 2nd table cell.
cmd="$(printf '%s' "$row" | sed -n 's/.*`\([^`]*\)`.*/\1/p')"
if [ -z "$cmd" ]; then
  cmd="$(printf '%s' "$row" | awk -F'|' '{print $3}' | sed 's/^ *//;s/ *$//')"
fi

# A `<configure: …>` placeholder is not a command.
case "$cmd" in
  *'<configure:'*) exit 0 ;;
esac

printf '%s' "$cmd"
