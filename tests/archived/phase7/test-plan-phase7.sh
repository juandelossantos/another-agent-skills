#!/usr/bin/env bash
# test-plan-phase7.sh — asserts PLAN.md carries the Phase 7 multi-agent addendum
# and the Phase 8 / prioritization sections.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PLAN="$REPO_ROOT/PLAN.md"

if [ ! -f "$PLAN" ]; then
  echo "  ✗ PLAN.md not found: $PLAN"
  exit 1
fi

fail=0
require() {
  if grep -qF "$1" "$PLAN"; then
    echo "  ✓ $2"
  else
    echo "  ✗ $2"
    fail=1
  fi
}

require "## Phase 7: OpenCode v1/v2 Plugin Compatibility" "Phase 7 heading present"
require "### P7 Addendum" "P7 multi-agent addendum present"
require "P7.5" "P7.5 (agent detection) present"
require "P7.6" "P7.6 (all skills) present"
require "P7.7" "P7.7 (guardrails per agent) present"
require "P7.8" "P7.8 (reconcile port with v6) present"
require "P7.9" "P7.9 (compat matrix + tests) present"
require "## Phase 8: Remote Enforcement" "Phase 8 heading present"
require "## Priorización de Pendientes" "prioritization section present"

exit "$fail"
