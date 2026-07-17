#!/usr/bin/env bash
# commit-approval.sh — Manifest preview + precondition check (v4)
# Part of another-agent-skills (github.com/juandelossantos/another-agent-skills)
#
# READ-ONLY. Does NOT write DECISION_APPROVED or OVERRIDE_APPROVED.
# The agent writes those tokens after user says "yes" — this script only prints the manifest.
# The user runs git commit directly.
#
# Flow:
# 1. Agent runs tests → bash scripts/log-test-results.sh
# 2. Agent presents DECISION POINT (diff + test results + manifest)
# 3. User says "yes commit" in chat
# 4. Agent runs this script → validates + prints manifest
# 5. Agent gives user the exact command: git commit -m "message"
# 6. User runs git commit in terminal
#
# Usage: bash scripts/commit-approval.sh "commit message" --plan-approved --manifest-presented [file1 file2...]

set -euo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'

COMMIT_MSG="${1:-}"
REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || echo '.')}"

if [[ -z "$COMMIT_MSG" ]]; then
  echo -e "${RED}Error: No commit message provided.${NC}"
  exit 1
fi

# ─── Check: --plan-approved ───
PLAN_APPROVED=false
for arg in "$@"; do
  [[ "$arg" == "--plan-approved" ]] && PLAN_APPROVED=true && break
done
if [[ "$PLAN_APPROVED" == "false" ]]; then
  echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║  Missing --plan-approved flag.                            ║${NC}"
  echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
  exit 1
fi

# ─── Check: --manifest-presented ───
MANIFEST_PRESENTED=false
for arg in "$@"; do
  [[ "$arg" == "--manifest-presented" ]] && MANIFEST_PRESENTED=true && break
done
if [[ "$MANIFEST_PRESENTED" == "false" ]]; then
  echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║  Missing --manifest-presented flag.                      ║${NC}"
  echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
  exit 1
fi

# ─── Check: branch is not main (unless --allow-main) ───
ALLOW_MAIN=false
for arg in "$@"; do
  [[ "$arg" == "--allow-main" ]] && ALLOW_MAIN=true && break
done
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
if [[ "$CURRENT_BRANCH" == "main" && "$ALLOW_MAIN" == "false" ]]; then
  echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║  Commits to main require --allow-main. Use a branch+PR.   ║${NC}"
  echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
  exit 1
fi

# ─── Print manifest for user review ───
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  COMMIT MANIFEST — review before committing              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "  Message: ${COMMIT_MSG}"
echo "  Branch:  ${CURRENT_BRANCH}"
echo ""

FILES="${*:2}"
if [[ -n "$FILES" ]]; then
  echo "  Files:"
  for f in "$@"; do
    case "$f" in
      --plan-approved|--manifest-presented|--allow-main) ;;
      *) echo "    - $f" ;;
    esac
  done
fi

echo ""
echo "  ─────────────────────────────────────────────"
echo "  To commit, run this command in your terminal:"
echo ""
echo "    git commit -m \"${COMMIT_MSG}\""
echo ""
  echo "  The pre-commit hook will validate tests, build, and decision token."
  echo "  The commit-msg hook will validate TDD gate and override token if present."
echo "  ─────────────────────────────────────────────"
echo ""
exit 0
