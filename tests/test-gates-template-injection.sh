#!/usr/bin/env bash
# test-gates-template-injection.sh — the shipped remote-gate template must not
# interpolate STACK_CONFIG.md commands into `run:` with `${{ }}`.
#
# STACK_CONFIG.md is repo content that a pull request can edit. Writing
# `run: ${{ steps.stack.outputs.test_cmd }}` makes GitHub substitute that value
# into the generated shell script — the documented script-injection sink
# (GitHub: "Use an intermediate environment variable"). The fix passes the value
# through `env:` and executes it as data with `bash -c`.
#
# Guards both the template and the repo's own gates workflow.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE="$REPO_ROOT/templates/gates.yml"
WORKFLOW="$REPO_ROOT/.github/workflows/gates.yml"

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

echo ""
echo "gates template — no script injection from STACK_CONFIG.md"
echo "────────────────────────────────────────────────────────"

assert "template exists" "[ -f '$TEMPLATE' ]"

# The injection sink must be gone from every `run:` line.
assert "no \${{ }} interpolation into run: (template)" \
  "! grep -qE '^[[:space:]]*run:[[:space:]]*\\\$\{\{' '$TEMPLATE'"
assert "no steps.stack.outputs in a run: line (template)" \
  "! grep -qE '^[[:space:]]*run:.*steps\\.stack\\.outputs' '$TEMPLATE'"

# The safe pattern is present: value via env, executed with bash -c.
assert "commands are passed via env: (template)" \
  "grep -q 'GATES_CMD: \${{ steps.stack.outputs.test_cmd }}' '$TEMPLATE'"
assert "commands are executed as data via bash -c (template)" \
  "grep -q 'run: bash -c \"\$GATES_CMD\"' '$TEMPLATE'"
assert "all four command steps use the env pattern (template)" \
  "[ \"\$(grep -c 'GATES_CMD: \${{ steps.stack.outputs' '$TEMPLATE')\" -eq 4 ]"

# Robustness: a missing STACK_CONFIG row must not abort the step silently.
# The parser is now the `read_cmd()` helper (B12: prefer the exact `| <field> |`
# row, else the first `| <field> … |` row) with `|| true` guards on its greps.
assert "STACK_CONFIG parsing survives an absent row (template)" \
  "[ \"\$(grep -cE 'head -1 \\|\\| true' '$TEMPLATE')\" -ge 2 ] && grep -q 'read_cmd()' '$TEMPLATE'"

# The repo's own workflow runs fixed scripts, so it must have no sink either.
assert "no \${{ }} interpolation into run: (repo workflow)" \
  "! grep -qE '^[[:space:]]*run:[[:space:]]*\\\$\{\{' '$WORKFLOW'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
