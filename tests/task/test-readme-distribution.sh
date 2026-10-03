#!/usr/bin/env bash
# test-readme-distribution.sh — Content check for README.md: the Phase-9
# pinned one-liner install + `aas` CLI are documented (the distribution channel
# is discoverable, not just present in the repo).

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FILE="$REPO_ROOT/README.md"

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

assert "documents the pinned one-liner install" "grep -q 'releases/latest/download/bootstrap.sh' '$FILE'"
assert "documents the aas install command" "grep -q 'aas install --agents auto' '$FILE'"
assert "documents aas doctor" "grep -q 'aas doctor' '$FILE'"
assert "documents aas upgrade" "grep -q 'aas upgrade' '$FILE'"
assert "documents aas uninstall" "grep -q 'aas uninstall' '$FILE'"
assert "states the install is checksum-verified" "grep -qi 'checksum-verified' '$FILE'"
assert "documents --dry-run" "grep -q -- '--dry-run' '$FILE'"
assert "links to docs/DISTRIBUTION.md" "grep -q 'docs/DISTRIBUTION.md' '$FILE'"
assert "mentions the npm channel" "grep -q 'npx @juandelossantos/another-agent-skills' '$FILE'"
assert "mentions the Homebrew channel" "grep -q 'brew install juandelossantos/tap/another-agent-skills' '$FILE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
