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
# Two profiles, chosen automatically from the repository shape:
#
#   solo — a single human with push access (owner is a User, <=1 pusher). A
#          required approval would be impossible to satisfy: GitHub forbids
#          approving your own pull request. So: PRs + the `gates` check are
#          required, but approvals = 0, no code-owner review, admin enforcement
#          stays OFF (so the sole admin can still merge their own PR).
#
#   team — more than one human with push access. Full protection: strict
#          status checks, 1 required approval, code-owner review, and
#          enforce_admins ON so nobody (agent included) can route around it.
#
# LOCKOUT GUARD (mandatory): if fewer than two humans have push access, the
# solo profile is FORCED — even when `--mode team` is requested — because a
# required approval can never be given. Pass `--force-lockout-risk` to opt out
# (prints a loud warning; not recommended).
#
# CODE-OWNER GUARD (mandatory): "Require review from Code Owners" is another
# approval the author cannot give themselves. If the local CODEOWNERS lists a
# single owner, that owner's own PRs can never satisfy it, so the requirement
# is dropped (with a warning). A single *team* owner cannot be verified from
# here, so it is warned about rather than forced. Pass
# `--no-code-owner-reviews` to drop the requirement explicitly, or
# `--force-lockout-risk` to keep the risky configuration.
#
# Idempotent: it reads the current protection and skips the write if the
# desired state is already in place. Safe to re-run; it prints what it did.
#
# Usage:
#   bash scripts/setup-branch-protection.sh [--mode auto|solo|team]
#                                           [--approvals N] [--code-owner-reviews]
#                                           [--no-code-owner-reviews]
#                                           [--strict] [--enforce-admins]
#                                           [--force-lockout-risk]
#                                           [--repo OWNER/REPO] [--branch BRANCH]
#                                           [--dry-run]
#
# Requires: gh (authenticated with admin rights on the repo) and jq.
# Exit: 0 = configured/already configured/dry-run, 1 = error, 2 = usage error.
#
# Spec: PLAN.md — Phase 8 / P8.1 (docs/BRANCH-PROTECTION.md)

set -euo pipefail

BRANCH="main"
REPO_SLUG=""
DRY_RUN=false
MODE_REQUESTED="auto"
FORCE_LOCKOUT_RISK=false

# Flag overrides. Empty = not provided → keep the profile value.
OVR_APPROVALS=""
OVR_CODE_OWNER=""
OVR_STRICT=""
OVR_ENFORCE_ADMINS=""

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; BOLD=$'\033[1m'; NC=$'\033[0m'

usage() {
  cat <<'EOF'
Usage: bash scripts/setup-branch-protection.sh [options]

Options:
  --mode MODE             auto (default) | solo | team. auto detects the repo shape.
  --approvals N           Required approving reviews (overrides the profile; max 6).
  --code-owner-reviews    Require review from Code Owners (overrides the profile).
  --no-code-owner-reviews Do not require review from Code Owners.
  --strict                Require branches to be up to date before merging.
  --enforce-admins        Apply the rules to admins too (no admin bypass).
  --force-lockout-risk    Allow a config that can lock out a solo maintainer.
  --repo OWNER/REPO       Target repository (default: derived from `gh repo view`).
  --branch BRANCH         Branch to protect (default: main).
  --dry-run               Print the exact configuration without calling the API.
  -h, --help              Show this help
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)                  [ $# -ge 2 ] && [ -n "${2:-}" ] || { echo "${RED}ERROR:${NC} --repo requires a value." >&2; exit 2; }; REPO_SLUG="$2"; shift 2 ;;
    --branch)                [ $# -ge 2 ] && [ -n "${2:-}" ] || { echo "${RED}ERROR:${NC} --branch requires a value." >&2; exit 2; }; BRANCH="$2"; shift 2 ;;
    --mode)                  [ $# -ge 2 ] && [ -n "${2:-}" ] || { echo "${RED}ERROR:${NC} --mode requires a value." >&2; exit 2; }; MODE_REQUESTED="$2"; shift 2 ;;
    --approvals)             [ $# -ge 2 ] && [ -n "${2:-}" ] || { echo "${RED}ERROR:${NC} --approvals requires a value." >&2; exit 2; }; OVR_APPROVALS="$2"; shift 2 ;;
    --code-owner-reviews)    OVR_CODE_OWNER=true; shift ;;
    --no-code-owner-reviews) OVR_CODE_OWNER=false; shift ;;
    --strict)                OVR_STRICT=true; shift ;;
    --enforce-admins)        OVR_ENFORCE_ADMINS=true; shift ;;
    --force-lockout-risk)    FORCE_LOCKOUT_RISK=true; shift ;;
    --dry-run)               DRY_RUN=true; shift ;;
    -h|--help)               usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

case "$MODE_REQUESTED" in
  auto|solo|team) ;;
  *) echo "${RED}ERROR:${NC} --mode must be auto, solo or team (got '$MODE_REQUESTED')." >&2; exit 2 ;;
esac

if [ -n "$OVR_APPROVALS" ] && ! [[ "$OVR_APPROVALS" =~ ^[0-9]+$ ]]; then
  echo "${RED}ERROR:${NC} --approvals must be a non-negative integer (got '$OVR_APPROVALS')." >&2
  exit 2
fi

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

# ─── Repo-shape detection ───
# owner type: "User" or "Organization".
# push collaborators: humans with push/admin. Bots (`[bot]` logins) are not
# humans and cannot approve anything, so they are excluded — otherwise a
# single-maintainer repo with a bot collaborator would look like a team and
# the guard would not fire.
#
# Detection failures are swallowed. The safe fallback is PUSH_COUNT=1 so the
# lockout guard fires and we emit the solo-safe profile. We never want a
# transient API error to produce a config that can lock the user out.
OWNER_TYPE=""
PUSH_COUNT=1

detect_repo_shape() {
  OWNER_TYPE=$(gh api "repos/${REPO_SLUG}" 2>/dev/null | jq -r '.owner.type // empty' 2>/dev/null || true)

  local raw count
  raw=$(gh api --paginate "repos/${REPO_SLUG}/collaborators?per_page=100" 2>/dev/null || true)
  if [ -n "$raw" ]; then
    count=$(printf '%s' "$raw" | jq -s '
      [ .[] | .[]
        | select(.permissions.push == true or .permissions.admin == true)
        | select(.login | endswith("[bot]") | not)
      ] | length' 2>/dev/null || true)
    if [ -n "$count" ]; then
      PUSH_COUNT="$count"
    fi
  fi
}

detect_repo_shape

# ─── Code-owner detection ───
# "Require review from Code Owners" is an approval the author cannot give
# themselves. GitHub resolves owners from CODEOWNERS (precedence:
# .github/CODEOWNERS, CODEOWNERS, docs/CODEOWNERS). We read the local file to
# count distinct owners: with a single user owner, a PR authored by that owner
# can never satisfy the rule. CODEOWNERS_FILE overrides the lookup (tests, and
# repos that keep the file elsewhere).
CODEOWNERS_FOUND=false
USER_OWNERS=0
TEAM_OWNERS=0

code_owner_stats() {
  local f=""
  if [ -n "${CODEOWNERS_FILE:-}" ]; then
    if [ -f "$CODEOWNERS_FILE" ]; then f="$CODEOWNERS_FILE"; fi
  elif [ -f .github/CODEOWNERS ]; then
    f=".github/CODEOWNERS"
  elif [ -f CODEOWNERS ]; then
    f="CODEOWNERS"
  elif [ -f docs/CODEOWNERS ]; then
    f="docs/CODEOWNERS"
  fi
  [ -z "$f" ] && return 0
  CODEOWNERS_FOUND=true
  local tokens
  tokens=$(awk '{ sub(/#.*/, ""); for (i = 1; i <= NF; i++) if ($i ~ /^@/) print $i }' "$f" | sort -u)
  USER_OWNERS=$(printf '%s\n' "$tokens" | grep -cE '^@[^/]+$' || true)
  TEAM_OWNERS=$(printf '%s\n' "$tokens" | grep -cE '^@[^/]+/.+$' || true)
}

code_owner_stats

if [ -z "$OWNER_TYPE" ]; then
  # Detection failed (offline / no admin rights): fall back to the safe mode.
  DETECTED_MODE="solo"
elif [ "$OWNER_TYPE" = "User" ] && [ "$PUSH_COUNT" -le 1 ]; then
  DETECTED_MODE="solo"
else
  DETECTED_MODE="team"
fi

if [ "$MODE_REQUESTED" = "auto" ]; then
  SELECTED_MODE="$DETECTED_MODE"
else
  SELECTED_MODE="$MODE_REQUESTED"
fi

# ─── Profile ───
if [ "$SELECTED_MODE" = "solo" ]; then
  STRICT=false
  APPROVALS=0
  CODE_OWNER=false
  ENFORCE_ADMINS=false
else
  STRICT=true
  APPROVALS=1
  CODE_OWNER=true
  ENFORCE_ADMINS=true
fi

# ─── Flag overrides (profile first, flags second) ───
if [ -n "$OVR_APPROVALS" ];       then APPROVALS="$OVR_APPROVALS"; fi
if [ -n "$OVR_CODE_OWNER" ];      then CODE_OWNER="$OVR_CODE_OWNER"; fi
if [ -n "$OVR_STRICT" ];          then STRICT="$OVR_STRICT"; fi
if [ -n "$OVR_ENFORCE_ADMINS" ];  then ENFORCE_ADMINS="$OVR_ENFORCE_ADMINS"; fi

# ─── Lockout guard ───
# The author of a PR cannot approve it. With N humans that can push, at most
# N-1 approvals can ever be satisfied. Cap APPROVALS there; when the cap is 0
# (a single pusher) also drop code-owner review and admin enforcement, since a
# sole code owner / sole admin could otherwise be unable to merge at all.
FINAL_MODE="$SELECTED_MODE"
MAX_APPROVALS=$(( PUSH_COUNT > 0 ? PUSH_COUNT - 1 : 0 ))
if [ "$MAX_APPROVALS" -gt 6 ]; then MAX_APPROVALS=6; fi
GUARD_OVERRIDDEN=false
GUARD_RISKY_APPROVALS=false
GUARD_API_CAPPED=false
GUARD_CODE_OWNER=false
CODE_OWNER_UNVERIFIABLE=false

# GitHub caps required approvals at 6; asking for more is a 422, not a lockout.
if [ "$APPROVALS" -gt 6 ]; then
  APPROVALS=6
  GUARD_API_CAPPED=true
fi

if ! $FORCE_LOCKOUT_RISK; then
  if [ "$MAX_APPROVALS" -eq 0 ]; then
    # No second human can approve: any required approval, code-owner review,
    # or admin enforcement is unsatisfiable. Force the whole solo-safe profile.
    if [ "$SELECTED_MODE" != "solo" ] || [ "$APPROVALS" != "0" ] \
       || [ "$CODE_OWNER" != "false" ] || [ "$ENFORCE_ADMINS" != "false" ] \
       || [ "$STRICT" != "false" ]; then
      GUARD_OVERRIDDEN=true
    fi
    APPROVALS=0
    CODE_OWNER=false
    ENFORCE_ADMINS=false
    STRICT=false
    FINAL_MODE="solo"
  elif [ "$APPROVALS" -gt "$MAX_APPROVALS" ]; then
    # More approvals requested than there are other humans to give them.
    GUARD_OVERRIDDEN=true
    APPROVALS="$MAX_APPROVALS"
  fi
elif [ "$APPROVALS" -gt "$MAX_APPROVALS" ]; then
  GUARD_RISKY_APPROVALS=true
fi

# ─── Code-owner guard ───
# A sole code owner authoring a PR cannot satisfy code-owner review (GitHub
# forbids self-approval). We can prove this for a single *user* owner, so we
# force the requirement off. A single *team* owner is unverifiable from here
# (membership lives in the org API), so we warn and leave the choice to the
# user. `--force-lockout-risk` opts out entirely.
if [ "$CODE_OWNER" = "true" ] && ! $FORCE_LOCKOUT_RISK; then
  if ! $CODEOWNERS_FOUND; then
    CODE_OWNER_UNVERIFIABLE=true
  elif [ "$USER_OWNERS" -eq 1 ] && [ "$TEAM_OWNERS" -eq 0 ]; then
    GUARD_CODE_OWNER=true
    CODE_OWNER=false
  elif [ "$USER_OWNERS" -eq 0 ] && [ "$TEAM_OWNERS" -eq 1 ]; then
    CODE_OWNER_UNVERIFIABLE=true
  fi
fi

# ─── Final payload ───
PAYLOAD=$(jq -n \
  --argjson strict "$STRICT" \
  --argjson approvals "$APPROVALS" \
  --argjson code_owner "$CODE_OWNER" \
  --argjson enforce_admins "$ENFORCE_ADMINS" \
  '{
    required_status_checks: {
      strict: $strict,
      contexts: ["gates"]
    },
    enforce_admins: $enforce_admins,
    required_pull_request_reviews: {
      dismiss_stale_reviews: true,
      require_code_owner_reviews: $code_owner,
      required_approving_review_count: $approvals
    },
    restrictions: null,
    required_conversation_resolution: true,
    allow_force_pushes: false,
    allow_deletions: false
  }')

# ─── Report detection + decision ───
echo "${BOLD}Branch protection — ${REPO_SLUG}@${BRANCH}${NC}"
echo "  owner type:          ${OWNER_TYPE:-unknown}"
echo "  push collaborators:  ${PUSH_COUNT} human(s)"
echo "  detected mode:       ${DETECTED_MODE}"
echo "  requested mode:      ${MODE_REQUESTED}"
echo "  final mode:          ${FINAL_MODE}"

if [ -z "$OWNER_TYPE" ]; then
  echo "${YELLOW}NOTE:${NC} could not detect the owner type (API/gh unavailable); assuming the safe solo profile."
fi

if $GUARD_OVERRIDDEN; then
  echo ""
  echo "${YELLOW}WARNING: lockout guard engaged.${NC}"
  echo "  Only ${PUSH_COUNT} human(s) have push access to ${REPO_SLUG}; at most"
  echo "  ${MAX_APPROVALS} approval(s) can ever be satisfied (GitHub does not let you"
  echo "  approve your own pull request)."
  if [ "$MAX_APPROVALS" -eq 0 ]; then
    echo "  Forcing the solo-safe profile: approvals=0, code-owner-review=off,"
    echo "  enforce-admins=off."
  else
    echo "  Capping required approvals at ${MAX_APPROVALS} so a PR can actually be approved."
  fi
  echo "  Override with ${BOLD}--force-lockout-risk${NC} only if you understand the risk."
fi

if $FORCE_LOCKOUT_RISK && [ "$PUSH_COUNT" -le 1 ]; then
  echo ""
  echo "${RED}WARNING: --force-lockout-risk with ${PUSH_COUNT} push human(s).${NC}"
  echo "  You are about to require an approval that no other human can give."
  echo "  If this is your only admin account you will be locked out of ${BRANCH}."
fi

if $GUARD_RISKY_APPROVALS; then
  echo ""
  echo "${RED}WARNING: --force-lockout-risk allows ${APPROVALS} required approval(s)${NC}"
  echo "  but only ${PUSH_COUNT} human(s) have push access; at most ${MAX_APPROVALS} approval(s) are reachable."
fi

if $GUARD_API_CAPPED; then
  echo ""
  echo "${YELLOW}NOTE:${NC} GitHub allows at most 6 required approvals; capped at 6."
fi

if $GUARD_CODE_OWNER; then
  echo ""
  echo "${YELLOW}WARNING: code-owner guard engaged.${NC}"
  echo "  CODEOWNERS lists a single owner, so a pull request authored by that"
  echo "  owner can never satisfy 'Require review from Code Owners' (GitHub does"
  echo "  not let you approve your own pull request). Forcing code-owner review off."
  echo "  Fix: add a second code owner to CODEOWNERS, or pass"
  echo "  ${BOLD}--force-lockout-risk${NC} if you understand the risk."
fi

if $CODE_OWNER_UNVERIFIABLE; then
  echo ""
  echo "${YELLOW}WARNING: could not verify code-owner review is satisfiable.${NC}"
  if ! $CODEOWNERS_FOUND; then
    echo "  No CODEOWNERS file found locally; skipping the code-owner lockout check."
  else
    echo "  CODEOWNERS lists a single team owner; its membership cannot be checked"
    echo "  here. If the team has only one member, that member's own PRs can be blocked."
  fi
  echo "  Add a second code owner, or pass ${BOLD}--no-code-owner-reviews${NC}."
fi

if $FORCE_LOCKOUT_RISK && [ "$CODE_OWNER" = "true" ] && $CODEOWNERS_FOUND \
   && [ "$USER_OWNERS" -eq 1 ] && [ "$TEAM_OWNERS" -eq 0 ]; then
  echo ""
  echo "${RED}WARNING: --force-lockout-risk with a single code owner.${NC}"
  echo "  A pull request authored by that owner cannot satisfy code-owner review."
fi

echo ""
echo "Final payload:"
echo "$PAYLOAD"

# already_matches <current-json> (stdin): true when the live protection already
# equals the desired state. GET responses wrap booleans as {"enabled": bool},
# so compare against that shape.
already_matches() {
  jq -e \
    --argjson strict "$STRICT" \
    --argjson approvals "$APPROVALS" \
    --argjson code_owner "$CODE_OWNER" \
    --argjson enforce_admins "$ENFORCE_ADMINS" '
    (((.required_status_checks.contexts // []) | index("gates")) != null)
    and (.required_status_checks.strict == $strict)
    and (.enforce_admins.enabled == $enforce_admins)
    and (.allow_force_pushes.enabled == false)
    and (.allow_deletions.enabled == false)
    and (.required_pull_request_reviews.dismiss_stale_reviews == true)
    and (.required_pull_request_reviews.require_code_owner_reviews == $code_owner)
    and (.required_pull_request_reviews.required_approving_review_count == $approvals)
    and (.required_conversation_resolution.enabled == true)
  ' >/dev/null 2>&1
}

if $DRY_RUN; then
  echo ""
  echo "${YELLOW}[dry-run]${NC} Branch protection would be applied to ${REPO_SLUG}@${BRANCH}"
  echo "  endpoint:            PUT https://api.github.com/${ENDPOINT}"
  echo "  required check:      gates (strict=${STRICT})"
  echo "  pull requests:       required + ${APPROVALS} approval(s), code-owner-review=${CODE_OWNER}, dismiss stale reviews"
  echo "  conversations:       resolution required"
  echo "  force pushes:        disabled"
  echo "  deletions:           disabled"
  echo "  admin bypass:        $([ "$ENFORCE_ADMINS" = "true" ] && echo disabled || echo allowed)"
  echo "  (no writes made — dry run)"
  exit 0
fi

# Read current state. 404 (not protected) yields empty output.
CURRENT=$(gh api "$ENDPOINT" 2>/dev/null || true)
if [ -n "$CURRENT" ] && printf '%s' "$CURRENT" | already_matches; then
  echo ""
  echo "${GREEN}✓${NC} Branch protection already configured for ${REPO_SLUG}@${BRANCH} — no change."
  echo "  mode: ${FINAL_MODE} | check: gates | approvals: ${APPROVALS} | code-owner: ${CODE_OWNER} | admin bypass: $([ "$ENFORCE_ADMINS" = "true" ] && echo off || echo on)"
  exit 0
fi

echo ""
echo "Applying branch protection to ${REPO_SLUG}@${BRANCH}..."
if ! printf '%s' "$PAYLOAD" | gh api -X PUT "$ENDPOINT" --input - >/dev/null; then
  echo "${RED}ERROR:${NC} failed to apply branch protection. Check gh auth and admin rights." >&2
  exit 1
fi

echo "${GREEN}✓${NC} Branch protection applied."
echo "  mode: ${FINAL_MODE} | check: gates | approvals: ${APPROVALS} | code-owner: ${CODE_OWNER} | admin bypass: $([ "$ENFORCE_ADMINS" = "true" ] && echo off || echo on)"
echo "  Verify: gh api ${ENDPOINT} --jq '.required_status_checks.contexts'"
exit 0
