#!/usr/bin/env bash
# test-distribution-doc.sh — behavioral guard for docs/DISTRIBUTION.md (Phase 9).
#
# The distribution channels, the maintainer one-time manual steps (npm +
# Homebrew, including the 2026-10-06 suspension note and the TOTP requirement)
# and the release/npm/Homebrew automation must stay documented and linked from
# the README. This protects the shipped Phase 9 distribution story from silent
# drift — the failure mode this project keeps correcting (Phase 4, Phase 8.5).

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC='\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FILE="$REPO_ROOT/docs/DISTRIBUTION.md"
README="$REPO_ROOT/README.md"

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

assert "docs/DISTRIBUTION.md exists" "[ -f '$FILE' ]"

# ── Channels ──────────────────────────────────────────────────────────────────
assert "documents git clone (contributors)" "grep -q 'git clone' '$FILE'"
assert "documents the pinned curl bootstrap" "grep -q 'bootstrap.sh' '$FILE'"
assert "documents the self-contained bootstrap asset" "grep -qi 'self-contained' '$FILE'"
assert "documents the aas CLI" "grep -q 'aas install' '$FILE'"
assert "documents npm" "grep -q 'npm' '$FILE'"
assert "documents Homebrew (brew install)" "grep -q 'brew install' '$FILE'"
assert "states it never fetches from a mutable branch" "grep -qi 'mutable branch' '$FILE'"

# ── Maintainer manual steps — npm ─────────────────────────────────────────────
assert "documents the manual first npm publish" "grep -qi 'first publish' '$FILE'"
assert "documents the Trusted Publisher setup" "grep -q 'Trusted Publisher' '$FILE'"
assert "names the npm-release environment" "grep -q 'npm-release' '$FILE'"
assert "records the 2026-10-06 suspension window" "grep -q '2026-10-06' '$FILE'"
assert "requires TOTP for the CLI (passkey is browser-only)" "grep -qi 'TOTP' '$FILE'"

# ── Maintainer manual steps — Homebrew ────────────────────────────────────────
assert "documents creating the homebrew-tap repo" "grep -q 'homebrew-tap' '$FILE'"
assert "documents the HOMEBREW_TAP_TOKEN secret" "grep -q 'HOMEBREW_TAP_TOKEN' '$FILE'"

# ── Automation ────────────────────────────────────────────────────────────────
assert "documents build attestations" "grep -qi 'attestation' '$FILE'"
assert "documents OIDC trusted publishing" "grep -qi 'OIDC' '$FILE'"
assert "names the release workflow" "grep -q 'release.yml' '$FILE'"
assert "names the npm workflow" "grep -q 'npm-publish.yml' '$FILE'"
assert "documents the optional Homebrew tap step" "grep -qi 'tap' '$FILE'"

# ── Discoverability ───────────────────────────────────────────────────────────
assert "README links to docs/DISTRIBUTION.md" "grep -q 'docs/DISTRIBUTION.md' '$README'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
