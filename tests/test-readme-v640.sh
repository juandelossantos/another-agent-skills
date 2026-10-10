#!/usr/bin/env bash
# test-readme-v640.sh — README.md is the v6.4.0 front door: exactly one What's
# New section (v6.4.0 only), the thesis + proof, the three install channels (npm
# now live; Homebrew not planned), and links to the new Astro docs.
#
# README.md is a docs file: the TDD gate verifies it with docs-honesty, not a
# name-paired test. This suite guards the v6.4.0 front-door content.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
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

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  README v6.4.0 — one What's New, thesis, install, docs links  ║"
echo "╚══════════════════════════════════════════════════════════════╝"

# ─── Exactly ONE What's New section, and it is v6.3.0 ───
echo ""
echo "Group 1 — One What's New section (v6.4.0 only)"
assert "README.md exists" "[ -f '$FILE' ]"
assert "exactly one '## What's New' section" "[ \"\$(grep -c \"^## What's New\" '$FILE')\" -eq 1 ]"
assert "the What's New section is v6.4.0" "grep -q \"^## What's New in v6.4.0\" '$FILE'"
assert "no v6.3.0 What's New section remains" "! grep -q \"## What's New in v6.3.0\" '$FILE'"
assert "no v6.2.0 What's New section remains" "! grep -q \"## What's New in v6.2.0\" '$FILE'"
assert "no v6.1.0 What's New section remains" "! grep -q \"## What's New in v6.1.0\" '$FILE'"
assert "no v6.0.0 What's New section remains" "! grep -q \"## What's New in v6.0.0\" '$FILE'"
assert "no v5.0.0 What's New section remains" "! grep -q \"## What's New in v5.0.0\" '$FILE'"
assert "no v4.2.0 What's New section remains" "! grep -q \"## What's New in v4.2.0\" '$FILE'"
assert "no v4.1.0 What's New section remains" "! grep -q \"## What's New in v4.1.0\" '$FILE'"
assert "points to RELEASE-NOTES.md for history" "grep -q 'RELEASE-NOTES.md' '$FILE'"
assert "points to GitHub Releases for history" "grep -q 'github.com/juandelossantos/another-agent-skills/releases' '$FILE'"

# ─── Thesis + proof (like the landing) ───
echo ""
echo "Group 2 — Thesis + proof"
assert "leads with the thesis line" "grep -q 'Most skill libraries sell capability. We sell discipline you can verify.' '$FILE'"
assert "shows the L1/L2/L3 layers" "grep -q 'L1' '$FILE' && grep -q 'L2' '$FILE' && grep -q 'L3' '$FILE'"
assert "shows a real blocked commit" "grep -qi 'real blocked commit' '$FILE' && grep -q 'BLOCKED: every code change needs a matching test' '$FILE'"
assert "names the required remote gates check" "grep -qi 'required remote \`gates\`' '$FILE'"
assert "states the agent never commits or pushes" "grep -q 'never runs \`git commit\`' '$FILE'"

# ─── Badges ───
echo ""
echo "Group 3 — Badges"
assert "version badge is v6.4.0" "grep -q 'Version: v6.4.0' '$FILE'"
assert "skills badge is 58" "grep -q 'Skills: 58' '$FILE'"
assert "guides badge is 153" "grep -q 'Guides: 153' '$FILE'"
assert "license badge is MIT" "grep -q 'License: MIT' '$FILE'"
assert "multi-agent badge present" "grep -q 'Multi-agent' '$FILE'"

# ─── Install channels (three real + honest soon) ───
echo ""
echo "Group 4 — Install channels"
assert "channel 1: git clone + install.sh" "grep -q 'git clone https://github.com/juandelossantos/another-agent-skills.git' '$FILE'"
assert "channel 2: pinned curl bootstrap" "grep -q 'releases/latest/download/bootstrap.sh' '$FILE'"
assert "channel 2: checksum-verified" "grep -qi 'checksum-verified' '$FILE'"
assert "channel 3: npx (coming soon)" "grep -q 'npx @juandelossantos/another-agent-skills' '$FILE'"
assert "no brew channel (Homebrew not planned)" "! grep -q 'brew install juandelossantos/tap' '$FILE'"
assert "npm is live (no 'coming soon')" "[ \"\$(grep -ci 'coming soon' '$FILE')\" -eq 0 ] && grep -q 'npm (live)' '$FILE'"
assert "links to docs/DISTRIBUTION.md" "grep -q 'docs/DISTRIBUTION.md' '$FILE'"
assert "references the web/ project" "grep -q 'web/' '$FILE'"

# ─── New Astro docs links (marked not yet deployed) ───
echo ""
echo "Group 5 — New Astro docs links"
assert "links the new landing base URL" "grep -q 'https://juandelossantos.github.io/another-agent-skills/' '$FILE'"
assert "links the new docs home" "grep -q 'https://juandelossantos.github.io/another-agent-skills/docs/' '$FILE'"
assert "links the new skills reference" "grep -q '/docs/skills/' '$FILE'"
assert "links a tutorial" "grep -q 'first-gated-commit' '$FILE'"
assert "links llms.txt" "grep -q 'llms.txt' '$FILE'"
assert "points at the live site" "grep -q 'juandelossantos.github.io/another-agent-skills/' '$FILE'"

# ─── Multi-agent compatibility (kept, refreshed) ───
echo ""
echo "Group 6 — Multi-agent compatibility"
assert "keeps the agent compatibility matrix" "grep -q 'Agent Compatibility' '$FILE'"
assert "matrix includes Codex and Gemini CLI" "grep -q 'Codex' '$FILE' && grep -q 'Gemini CLI' '$FILE'"
assert "states install once per machine / portable" "grep -qi 'once per machine' '$FILE'"
assert "Claude Code auto path retained" "grep -q 'auto → \`~/.claude/skills/\`' '$FILE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
