#!/usr/bin/env bash
# test-bootstrap-ps1.sh — bootstrap.ps1 is a thin Windows wrapper (P9.7).
#
# It must locate Git Bash and delegate to bootstrap.sh, and must NOT
# reimplement any gate in PowerShell. Windows requirement: Git for Windows.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PS1="$REPO_ROOT/bootstrap.ps1"

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
echo "BOOTSTRAP.PS1 — thin Git Bash wrapper"
echo "─────────────────────────────────────"

assert "bootstrap.ps1 exists" "[ -f '$PS1' ]"
assert "locates Git Bash" "grep -qi 'bash.exe' '$PS1'"
assert "delegates to bootstrap.sh" "grep -q 'bootstrap.sh' '$PS1'"
assert "documents the Git for Windows requirement" "grep -qi 'Git for Windows' '$PS1'"
assert "does not reimplement gates (no checksum/sha in PowerShell)" \
  "! grep -qiE 'sha256|checksum|Get-FileHash' '$PS1'"
assert "is thin (< 60 lines)" "[ \$(wc -l < '$PS1') -lt 60 ]"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
