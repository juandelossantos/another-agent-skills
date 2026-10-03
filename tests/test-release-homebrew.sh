#!/usr/bin/env bash
# test-release-homebrew.sh — asserts the Homebrew tap step in
# .github/workflows/release.yml (Phase 9 / P9.6) is token-gated, skips cleanly
# when the token is absent (the release must never break), generates the formula
# with scripts/build-brew-formula.sh, pushes it into the tap's Formula/, and
# never references a mutable branch. Static analysis only — no network.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WF="$REPO_ROOT/.github/workflows/release.yml"

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

echo ""
echo "release.yml — Homebrew tap step"
echo "───────────────────────────────"

[ -f "$WF" ]; check $? "release.yml exists"

# ── Step present + generates the formula ─────────────────────────────────────
grep -qi 'homebrew' "$WF"; check $? "has a Homebrew step"
grep -q 'scripts/build-brew-formula.sh' "$WF"; check $? "generates the formula via scripts/build-brew-formula.sh"

# ── Token-gated (secrets are not allowed in `if:`; detect presence into an
#    output, then gate on it — and scope the token to the steps that need it) ──
grep -q 'HOMEBREW_TAP_TOKEN: ${{ secrets.HOMEBREW_TAP_TOKEN }}' "$WF"; check $? "token comes from the HOMEBREW_TAP_TOKEN secret"
grep -qE "if:.*steps\.tap\.outputs\.enabled == 'true'" "$WF"; check $? "step is gated on the detected token"

# ── Skips cleanly when the token is absent (release unaffected) ──────────────
grep -q 'HOMEBREW_TAP_TOKEN not set' "$WF"; check $? "prints a skip notice when the token is absent"
grep -q 'exit 0' "$WF"; check $? "skips with exit 0 (release unaffected)"

# ── Tap push ─────────────────────────────────────────────────────────────────
grep -q 'juandelossantos/homebrew-tap' "$WF"; check $? "defaults to juandelossantos/homebrew-tap"
grep -q 'vars.HOMEBREW_TAP_REPO' "$WF"; check $? "tap repo is overridable via a repo variable"
grep -q 'Formula/another-agent-skills.rb' "$WF"; check $? "copies the formula into Formula/"
grep -q 'x-access-token' "$WF"; check $? "authenticates the clone with the token"
grep -q 'git push' "$WF"; check $? "pushes the updated formula"

# ── Ordering: after the release assets are published ─────────────────────────
PUB_LINE="$(grep -n 'Publish the GitHub Release' "$WF" | head -1 | cut -d: -f1)"
BREW_LINE="$(grep -n 'name: Update Homebrew tap' "$WF" | head -1 | cut -d: -f1)"
[ -n "$PUB_LINE" ] && [ -n "$BREW_LINE" ] && [ "$BREW_LINE" -gt "$PUB_LINE" ]; check $? "Homebrew step runs after the release is published"

# ── Never a mutable ref ──────────────────────────────────────────────────────
! grep -qE 'releases/download/main|/main/' "$WF"; check $? "never fetches from main"
! grep -qE 'push +origin +[^ ]*main' "$WF"; check $? "never pushes to a literal main branch"

echo ""
echo "Results: ${fail} failed"
[ "$fail" -gt 0 ] && exit 1
exit 0
