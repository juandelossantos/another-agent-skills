#!/usr/bin/env bash
# check-gate-remedies.sh — B15 guard: every script a gate message tells the user
# to run (`Run: bash scripts/<name>.sh`, `Run 'bash scripts/<name>.sh'`,
# `Run \`bash scripts/<name>.sh\``) must be installed in the project by
# init-agents as a portable shim. Otherwise the remediation is not executable —
# the exact B15 failure class, caught automatically.
#
# Usage: bash scripts/check-gate-remedies.sh [--root DIR]
# Exit codes: 0 = every cited remedy is installed, 1 = a cited remedy is missing.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
while [ $# -gt 0 ]; do
  case "$1" in
    --root) REPO_ROOT="${2%/}"; shift 2 ;;
    *) shift ;;
  esac
done
cd "$REPO_ROOT" || { echo "FAIL: cannot cd to $REPO_ROOT"; exit 1; }

# Files whose "Run ..." lines are remediation instructions for the user's project.
SCAN_FILES=(
  scripts/git-hooks/pre-commit
  scripts/git-hooks/commit-msg
  STEERING-GUIDE.md
  scripts/validate-health-check.sh
  scripts/validate-skill-table.sh
  scripts/generate-health-check.sh
)

# The shims init-agents installs: its two constants + the audit/ADR helpers
# (single source of truth is scripts/init-agents.sh). Split into one name per line.
INSTALLED="$(grep -hE '^AAS_(LEGACY|VALIDATOR)_SCRIPTS=' scripts/init-agents.sh 2>/dev/null \
  | sed -E 's/^[^=]+="//; s/"[[:space:]]*$//') audit-project.sh generate-adr.sh"
INSTALLED="$(printf '%s\n' "$INSTALLED" | tr ' ' '\n' | sed '/^[[:space:]]*$/d')"

CITED=""
for f in "${SCAN_FILES[@]}"; do
  [ -f "$f" ] || continue
  CITED="$CITED$(grep -nE '[Rr]un[^"]*scripts/[a-z0-9-]+\.sh' "$f" 2>/dev/null \
    | grep -oE 'scripts/[a-z0-9-]+\.sh' | sed 's#scripts/##')"$'\n'
done
CITED="$(printf '%s\n' "$CITED" | sed '/^[[:space:]]*$/d' | sort -u)"

FAIL=0
while IFS= read -r name; do
  [ -n "$name" ] || continue
  if printf '%s\n' "$INSTALLED" | grep -qxF "$name"; then
    echo "  ✓ $name is installed by init-agents"
  else
    echo "  ✗ $name is cited as a remedy but NOT installed by init-agents"
    FAIL=1
  fi
done <<< "$CITED"

if [ "$FAIL" -eq 1 ]; then
  echo "FAIL: a gate remedy references a script not installed in the project"
  exit 1
fi
echo "PASS: every cited gate remedy is installed by init-agents"
exit 0
