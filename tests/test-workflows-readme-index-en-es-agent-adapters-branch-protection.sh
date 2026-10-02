#!/usr/bin/env bash
# test-workflows-readme-index-en-es-agent-adapters-branch-protection.sh
#
# Behavioral test for the four git/GitHub workflows documented across every
# user-facing surface (Phase 8.1 enforcement delivery):
#
#   1. no-git        — independent / private, no VCS (convention-only)
#   2. local-git     — local git, no remote (L1 only)
#   3. git + GitHub  — full L1 + L2 + L3
#   4. git-later     — no git now, git (+ GitHub) later; re-run init-agents
#
# Every surface must mention all four flows, the re-run rule, and the fact that
# L2/L3 are GitHub-only. The landing's copy lives behind `workflows.*` i18n keys
# that must exist — and be identical — in BOTH i18n/en.json and i18n/es.json.
#
# Changed files this suite pairs with: README.md, index.html, i18n/en.json,
# i18n/es.json, docs/AGENT-ADAPTERS.md, docs/BRANCH-PROTECTION.md.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

README="$REPO_ROOT/README.md"
INDEX="$REPO_ROOT/index.html"
EN="$REPO_ROOT/i18n/en.json"
ES="$REPO_ROOT/i18n/es.json"
ADAPTERS="$REPO_ROOT/docs/AGENT-ADAPTERS.md"
BRANCH="$REPO_ROOT/docs/BRANCH-PROTECTION.md"

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
echo "║  GIT/GITHUB WORKFLOWS — SURFACE + i18n PARITY VERIFICATION    ║"
echo "╚══════════════════════════════════════════════════════════════╝"

# ─── Group 1: landing i18n — valid JSON + workflows.* keys in BOTH ───
echo ""
echo "Group 1 — Landing i18n (i18n/en.json + i18n/es.json)"
assert "i18n/en.json is valid JSON" "jq empty '$EN' 2>/dev/null"
assert "i18n/es.json is valid JSON" "jq empty '$ES' 2>/dev/null"

for key in label title subtitle flow1 flow2 flow3 flow4 note; do
  assert "i18n/en.json has workflows.$key" "jq -e '.workflows.$key' '$EN' >/dev/null 2>&1"
  assert "i18n/es.json has workflows.$key" "jq -e '.workflows.$key' '$ES' >/dev/null 2>&1"
done

EN_KEYS=$(jq -r '.workflows | paths(scalars) | join(".")' "$EN" 2>/dev/null | sort)
ES_KEYS=$(jq -r '.workflows | paths(scalars) | join(".")' "$ES" 2>/dev/null | sort)
assert "workflows.* key sets are identical in EN/ES" "[ '$EN_KEYS' = '$ES_KEYS' ]"

# The four flow values must be non-empty in both languages.
for key in flow1 flow2 flow3 flow4; do
  assert "i18n/en.json workflows.$key is non-empty" "[ -n \"\$(jq -r '.workflows.$key' '$EN')\" ]"
  assert "i18n/es.json workflows.$key is non-empty" "[ -n \"\$(jq -r '.workflows.$key' '$ES')\" ]"
done

# ─── Group 2: every surface states all four flows + rules ───
check_surface() {
  local label="$1" file="$2"
  assert "$label — no-git flow" "grep -qiE 'no[ -]?git' '$file'"
  assert "$label — local-git flow" "grep -qiE 'local[ -]?git' '$file'"
  assert "$label — git + GitHub flow" "grep -qiE 'git ?[+] ?github' '$file'"
  assert "$label — git-later flow" "grep -qiE 'git[ -]?later|later[ -]?git|despu[eé]s git' '$file'"
  assert "$label — re-run init-agents rule" "grep -qiE 're-?run.*init-agents|re-?ejecut.*init-agents' '$file'"
  assert "$label — L2/L3 are GitHub-only" "grep -qiE 'github-only|solo github|únicamente.*github|unicamente.*github' '$file'"
}

echo ""
echo "Group 2 — Each surface documents the four workflows"
check_surface "README.md" "$README"
check_surface "index.html" "$INDEX"
check_surface "i18n/en.json" "$EN"
check_surface "i18n/es.json" "$ES"
check_surface "docs/AGENT-ADAPTERS.md" "$ADAPTERS"
check_surface "docs/BRANCH-PROTECTION.md" "$BRANCH"

# ─── Group 3: landing wiring — section + keyed items ───
echo ""
echo "Group 3 — Landing wiring (index.html)"
assert "index.html has a #workflows section" "grep -q 'id=\"workflows\"' '$INDEX'"
assert "index.html titles it 'Works with or without GitHub'" "grep -qi 'Works with or without GitHub' '$INDEX'"
assert "index.html binds workflows.label" "grep -q 'data-i18n=\"workflows.label\"' '$INDEX'"
assert "index.html binds workflows.title" "grep -q 'data-i18n=\"workflows.title\"' '$INDEX'"
for key in flow1 flow2 flow3 flow4; do
  assert "index.html binds data-i18n=\"workflows.$key\"" "grep -q 'data-i18n=\"workflows.$key\"' '$INDEX'"
done
assert "index.html binds the L1/L2/L3 note" "grep -q 'data-i18n=\"workflows.note\"' '$INDEX'"

# ─── Group 4: doc anchors ───
echo ""
echo "Group 4 — Documentation anchors"
assert "README has a 'Git & GitHub Workflows' section" "grep -qiE '^#+ .*Git ?& ?GitHub Workflows' '$README'"
assert "AGENT-ADAPTERS has a 'No GitHub? / git later?' subsection" "grep -qiE 'No GitHub\\? ?/ ?git later\\?' '$ADAPTERS'"
assert "BRANCH-PROTECTION has a 'Without GitHub' section" "grep -qiE '^#+ .*Without GitHub' '$BRANCH'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
