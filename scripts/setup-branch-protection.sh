#!/usr/bin/env bash
# setup-branch-protection.sh — Enable remote enforcement (L2) on a branch.
# Part of another-agent-skills (github.com/juandelossantos/another-agent-skills)
#
# Local hooks are fast feedback; they are NOT authority. `.git/hooks/` is
# writable by the agent (and `core.hooksPath` can be repointed to an empty
# directory), so a gate that lives only there can be bypassed without
# `--no-verify`. This script configures the authority layer: GitHub branch
# protection + a required status check, so nothing reaches `main` without
# passing the real gates.
#
# What it enables on the target branch:
#   - Require a pull request before merging
#   - Require the `gates` status check (the .github/workflows/gates.yml job)
#   - Require review from Code Owners (see CODEOWNERS — protects the gate config)
#   - Dismiss stale pull request approvals when new commits are pushed
#   - Require conversation resolution before merging
#   - Disable force pushes
#   - Disable branch deletions
#   - Disable admin bypass (enforce_admins) so the agent cannot route around it
#
# Idempotent: it reads the current protection and skips the write if the
# desired state is already in place. Safe to re-run; it prints what it did.
#
# Usage:
#   bash scripts/setup-branch-protection.sh [--repo OWNER/REPO] [--branch BRANCH] [--dry-run]
#
# Requires: gh (authenticated with admin rights on the repo) and jq.
# Exit: 0 = configured/already configured/dry-run, 1 = error, 2 = usage error.
#
# Spec: PLAN.md — Phase 8 / P8.1 (docs/BRANCH-PROTECTION.md)

set -euo pipefail

BRANCH="main"
REPO_SLUG=""
DRY_RUN=false

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'

usage() {
  cat <<'EOF'
Usage: bash scripts/setup-branch-protection.sh [options]

Options:
  --repo OWNER/REPO   Target repository (default: derived from `gh repo view`)
  --branch BRANCH     Branch to protect (default: main)
  --dry-run           Print the exact configuration without calling the API
  -h, --help          Show this help
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)    REPO_SLUG="${2:-}"; shift 2 ;;
    --branch)  BRANCH="${2:-}"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if ! command -v gh >/dev/null 2>&1; then
  echo "${RED}ERROR:${NC} gh CLI not found. Install: https://cli.github.com/" >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "${RED}ERROR:${NC} jq not found (required to inspect and merge protection state)." >&2
  exit 1
fi

if [ -z "$REPO_SLUG" ]; then
  REPO_SLUG=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)
fi
if [ -z "$REPO_SLUG" ]; then
  echo "${RED}ERROR:${NC} cannot determine repository. Pass --repo OWNER/REPO." >&2
  exit 1
fi

ENDPOINT="repos/${REPO_SLUG}/branches/${BRANCH}/protection"

# The exact protection payload. `contexts: ["gates"]` must match the job name in
# .github/workflows/gates.yml — that string is the required check GitHub looks for.
PAYLOAD=$(cat <<'JSON'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["gates"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true,
    "required_approving_review_count": 1
  },
  "restrictions": null,
  "required_conversation_resolution": true,
  "allow_force_pushes": false,
  "allow_deletions": false
}
JSON
)

# already_matches <current-json> (stdin): true when the live protection already
# equals the desired state. GET responses wrap booleans as {"enabled": bool},
# so compare against that shape.
already_matches() {
  jq -e '
    (((.required_status_checks.contexts // []) | index("gates")) != null)
    and (.enforce_admins.enabled == true)
    and (.allow_force_pushes.enabled == false)
    and (.allow_deletions.enabled == false)
    and (.required_pull_request_reviews.dismiss_stale_reviews == true)
    and (.required_pull_request_reviews.require_code_owner_reviews == true)
    and (.required_conversation_resolution.enabled == true)
  ' >/dev/null 2>&1
}

if $DRY_RUN; then
  echo "${YELLOW}[dry-run]${NC} Branch protection would be applied to ${REPO_SLUG}@${BRANCH}"
  echo "  endpoint:            PUT https://api.github.com/${ENDPOINT}"
  echo "  required check:      gates (strict)"
  echo "  pull requests:       required + code owner review, dismiss stale reviews"
  echo "  conversations:       resolution required"
  echo "  force pushes:        disabled"
  echo "  deletions:           disabled"
  echo "  admin bypass:        disabled"
  echo ""
  echo "$PAYLOAD"
  exit 0
fi

# Read current state. 404 (not protected) yields empty output.
CURRENT=$(gh api "$ENDPOINT" 2>/dev/null || true)
if [ -n "$CURRENT" ] && printf '%s' "$CURRENT" | already_matches; then
  echo "${GREEN}✓${NC} Branch protection already configured for ${REPO_SLUG}@${BRANCH} — no change."
  echo "  required check: gates | code-owner review: on | force-push: off | deletions: off"
  exit 0
fi

echo "Applying branch protection to ${REPO_SLUG}@${BRANCH}..."
if ! printf '%s' "$PAYLOAD" | gh api -X PUT "$ENDPOINT" --input - >/dev/null; then
  echo "${RED}ERROR:${NC} failed to apply branch protection. Check gh auth and admin rights." >&2
  exit 1
fi

echo "${GREEN}✓${NC} Branch protection applied."
echo "  required check: gates | code-owner review: on | force-push: off | deletions: off"
echo "  Verify: gh api ${ENDPOINT} --jq '.required_status_checks.contexts'"
exit 0
