#!/usr/bin/env bash
# test-npm-readme.sh — asserts the npm wrapper README documents the wrapper's
# contract: no framework payload, pinned + checksum-verified install, and the
# `aas-npm` bin. Phase 9 / P9.5.
#
# v6.4.3: the README is a product page, not a changelog. Only the current
# release section is allowed; durable behaviour lives in unversioned sections.
# The generic rule is enforced for both READMEs by test-readme-no-changelog.sh.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FILE="$REPO_ROOT/npm/README.md"
V="$(tr -d '[:space:]' < "$REPO_ROOT/VERSION")"

PASSED=0; FAILED=0; TOTAL=0
assert() {
  local name="$1" condition="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$condition"; then echo "  ✓ $name"; PASSED=$((PASSED + 1)); else echo "  ✗ $name"; FAILED=$((FAILED + 1)); fi
}

echo ""
echo "npm/README.md — wrapper docs"
echo "─────────────────────────────"

assert "README exists" "[ -f '$FILE' ]"
assert "documents the npx install command" "grep -q 'npx @juandelossantos/another-agent-skills install' '$FILE'"
assert "states it ships no framework payload" "grep -qi 'no framework payload' '$FILE'"
assert "documents the aas-npm bin" "grep -q 'aas-npm' '$FILE'"
assert "documents --version" "grep -q -- '--version' '$FILE'"
assert "documents --dry-run" "grep -q -- '--dry-run' '$FILE'"
assert "documents sha256 verification" "grep -qi 'sha256' '$FILE'"
assert "documents the pinned release (never main)" "grep -qi 'never fetches from' '$FILE'"
assert "documents Node >= 18" "grep -qE 'Node.js >= 18|Node.js ≥ 18' '$FILE'"
assert "documents Trusted Publishing (OIDC)" "grep -qi 'Trusted Publishing' '$FILE'"

echo ""
echo "Release sections (only the current one)"
assert "documents the current release (v$V)" "grep -qi \"^## What's new in v$V\" '$FILE'"
assert "ships the update command" "grep -q 'aas upgrade' '$FILE'"
assert "links the previous releases" "grep -q 'Previous releases' '$FILE'"
assert "links RELEASE-NOTES.md" "grep -q 'RELEASE-NOTES.md' '$FILE'"
assert "links GitHub Releases" "grep -q 'github.com/juandelossantos/another-agent-skills/releases' '$FILE'"

echo ""
echo "Durable behaviour (unversioned sections)"
assert "documents the L2 approved tree" "grep -q 'AAS-APPROVED-TREE' '$FILE'"
assert "documents one-time approval" "grep -qi 'One-time approval' '$FILE'"
assert "documents the capability runner" "grep -q 'agent-runner.sh' '$FILE'"
assert "states bash 3.2+ is supported" "grep -q 'Bash 3.2+' '$FILE'"

echo ""
echo "Results: ${PASSED} passed, ${FAILED} failed, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
