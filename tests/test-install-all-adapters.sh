#!/usr/bin/env bash
# test-install-all-adapters.sh — `install.sh --agent all` must not abort under
# `set -e` on the FIRST adapter failure. The old
# `install_agent_adapter x || ((errors++))` idiom returns 1 from `((errors++))`
# while `errors` is 0, tripping errexit inside the function and skipping every
# remaining adapter instead of counting the error and continuing.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

# Extract just the function so the test drives it in isolation (no network, no
# real adapter installs).
FUNC="$(awk '/^install_all_adapters\(\) \{/{f=1} f{print} f&&/^\}/{exit}' "$REPO_ROOT/install.sh")"
[ -n "$FUNC" ]; check $? "install_all_adapters extracted from install.sh"

# All adapters succeed → returns 0 and reaches the end under `set -e`.
OUT_OK="$(bash -c '
  set -euo pipefail
  install_agent_adapter() { return 0; }
  eval "$1"
  install_all_adapters
  echo "rc=$?"
' _ "$FUNC" 2>&1)"; RC_OK=$?
[ "$RC_OK" -eq 0 ]; check $? "all-success run does not abort under set -e"
printf '%s\n' "$OUT_OK" | grep -q 'rc=0'; check $? "all-success run returns 0"

# C3 regression: when the FIRST adapter fails, errexit used to fire inside the
# function on `((errors++))` (returns 1 while errors is 0) and skip the rest.
# Track which adapters actually ran — the fix runs all three, then returns 1.
CALLS="$(mktemp)"
CALLS="$CALLS" bash -c '
  set -euo pipefail
  install_agent_adapter() {
    echo "$1" >> "$CALLS"
    if [ "$1" = "claude" ]; then return 1; fi
    return 0
  }
  eval "$1"
  install_all_adapters
' _ "$FUNC" >/dev/null 2>&1 || true
grep -q 'claude' "$CALLS"; check $? "failing claude adapter was attempted"
grep -q 'cursor' "$CALLS"; check $? "cursor adapter still attempted after claude fails"
grep -q 'kiro'   "$CALLS"; check $? "kiro adapter still attempted after claude fails"
rm -f "$CALLS"

# The failure is COUNTED (returns 1), not swallowed: run with errexit off.
OUT_ERR="$(bash -c '
  set +e
  install_agent_adapter() { if [ "$1" = "claude" ]; then return 1; fi; return 0; }
  eval "$1"
  install_all_adapters
  echo "rc=$?"
' _ "$FUNC" 2>&1)"
printf '%s\n' "$OUT_ERR" | grep -q 'rc=1'; check $? "one failing adapter returns 1 (counted)"

# Static guard: the increment idiom must swallow its own non-zero status.
grep -q '((errors++)) || true' "$REPO_ROOT/install.sh"; check $? "((errors++)) is guarded with || true"

exit "$fail"
