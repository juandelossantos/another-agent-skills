#!/usr/bin/env bash
# test-005-native-js-plugin-agent-discipline.sh — the ADR-005 addendum records the
# dual contract, philosophy A, and the relocated source.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ADR="$REPO_ROOT/ADRs/005-native-js-plugin-agent-discipline.md"

fail=0
grep -q "Addendum (2026-09-30)" "$ADR" && echo "  ✓ addendum present" || { echo "  ✗ missing addendum"; fail=1; }
grep -q "dual contract" "$ADR" && echo "  ✓ dual contract recorded" || { echo "  ✗ missing dual contract"; fail=1; }
grep -qi "philosophy A" "$ADR" && echo "  ✓ philosophy A recorded" || { echo "  ✗ missing philosophy A"; fail=1; }
grep -q "plugins/agent-discipline/" "$ADR" && echo "  ✓ relocated source recorded" || { echo "  ✗ missing relocated source"; fail=1; }

exit "$fail"
