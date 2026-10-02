#!/usr/bin/env bash
# test-setup-branch-protection.sh — asserts scripts/setup-branch-protection.sh
# exists, is idempotent, talks to the GitHub API via `gh api`, and requires the
# "gates" status check + code-owner review on main. Also asserts the gate
# configuration itself is protected in CODEOWNERS (L3 integrity).
#
# Spec: PLAN.md — Phase 8 / P8.1 + P8.3

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$REPO_ROOT/scripts/setup-branch-protection.sh"
CO="$REPO_ROOT/CODEOWNERS"

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
echo "setup-branch-protection.sh — remote enforcement (L2/L3)"
echo "────────────────────────────────────────────────────────"

# ── Static contract ──
assert "script exists" "[ -f '$SCRIPT' ]"
assert "script is valid bash" "bash -n '$SCRIPT'"
assert "uses gh api" "grep -q 'gh api' '$SCRIPT'"
assert "targets the branch protection endpoint" "grep -qF '/branches/\${BRANCH}/protection' '$SCRIPT'"
assert "requires the 'gates' status check" "grep -qF '\"gates\"' '$SCRIPT'"
assert "requires a pull request" "grep -q 'required_pull_request_reviews' '$SCRIPT'"
assert "dismisses stale reviews" "grep -q 'dismiss_stale_reviews' '$SCRIPT'"
assert "requires code owner review" "grep -q 'require_code_owner_reviews' '$SCRIPT'"
assert "requires conversation resolution" "grep -q 'required_conversation_resolution' '$SCRIPT'"
assert "disables force pushes" "grep -q 'allow_force_pushes' '$SCRIPT'"
assert "disables deletions" "grep -q 'allow_deletions' '$SCRIPT'"
assert "no hardcoded GitHub token" "! grep -qE '(GITHUB_TOKEN|ghp_[A-Za-z0-9]{10,})' '$SCRIPT'"

# ── Dry-run is safe and informative ──
DRY_FILE=$(mktemp)
if bash "$SCRIPT" --repo testowner/testrepo --branch main --dry-run > "$DRY_FILE" 2>&1; then
  DRY_RC=0
else
  DRY_RC=$?
fi
assert "dry-run exits 0" "[ $DRY_RC -eq 0 ]"
assert "dry-run prints the protection endpoint" "grep -qF 'branches/main/protection' '$DRY_FILE'"
assert "dry-run prints the gates required check" "grep -qF 'gates' '$DRY_FILE'"
assert "dry-run does not mutate (no PUT executed)" "! grep -q 'gh api -X PUT' '$DRY_FILE'"
rm -f "$DRY_FILE"

# ── Idempotency against a stateful mock gh ──
MOCK_DIR=$(mktemp -d)
STATE_DIR=$(mktemp -d)
cat > "$MOCK_DIR/gh" <<'MOCK'
#!/usr/bin/env bash
state="${MOCK_GH_STATE:?}"
mkdir -p "$state"
printf '%s\n' "$*" >> "$state/calls"
if [ "${1:-}" = "repo" ]; then
  echo "testowner/testrepo"
  exit 0
fi
if [ "${1:-}" = "api" ]; then
  method="GET"; endpoint=""
  shift
  while [ $# -gt 0 ]; do
    case "$1" in
      -X|--method) method="$2"; shift 2;;
      --input) shift; cat > "$state/last_input" 2>/dev/null || true; shift;;
      -H|--header|-f|--raw-field|--field) shift 2;;
      *) endpoint="$1"; shift;;
    esac
  done
  if [ "$method" = "GET" ]; then
    if [ -f "$state/protected" ]; then cat "$state/protection.json"; exit 0; fi
    echo "gh: Not Found (HTTP 404)" >&2; exit 1
  fi
  if [ "$method" = "PUT" ]; then
    cat > "$state/protection.json" <<'JSON'
{"required_status_checks":{"strict":true,"contexts":["gates"]},"enforce_admins":{"enabled":true},"required_pull_request_reviews":{"dismiss_stale_reviews":true,"require_code_owner_reviews":true,"required_approving_review_count":1},"required_conversation_resolution":{"enabled":true},"allow_force_pushes":{"enabled":false},"allow_deletions":{"enabled":false}}
JSON
    touch "$state/protected"
    echo '{"ok":true}'
    exit 0
  fi
fi
exit 1
MOCK
chmod +x "$MOCK_DIR/gh"

run1=$(MOCK_GH_STATE="$STATE_DIR" PATH="$MOCK_DIR:$PATH" bash "$SCRIPT" --repo testowner/testrepo --branch main 2>&1); rc1=$?
run2=$(MOCK_GH_STATE="$STATE_DIR" PATH="$MOCK_DIR:$PATH" bash "$SCRIPT" --repo testowner/testrepo --branch main 2>&1); rc2=$?

assert "first run exits 0" "[ $rc1 -eq 0 ]"
assert "second run exits 0 (idempotent)" "[ $rc2 -eq 0 ]"
assert "second run reports already configured" "echo \"\$run2\" | grep -qi 'already'"
PUT_COUNT=$(grep -c -- '-X PUT' "$STATE_DIR/calls" 2>/dev/null || true)
PUT_COUNT=${PUT_COUNT:-0}
assert "PUT applied exactly once across two runs" "[ '$PUT_COUNT' -eq 1 ]"
assert "PUT targets branches/main/protection" "grep -q 'branches/main/protection' '$STATE_DIR/calls'"
assert "PUT sent the gates required check" "grep -q 'gates' '$STATE_DIR/last_input'"
assert "PUT requires code owner review" "grep -q 'require_code_owner_reviews' '$STATE_DIR/last_input'"
assert "PUT disables force pushes" "grep -q 'allow_force_pushes' '$STATE_DIR/last_input'"
rm -rf "$MOCK_DIR" "$STATE_DIR"

# ── L3: gate configuration is protected by CODEOWNERS ──
assert "CODEOWNERS exists" "[ -f '$CO' ]"
assert "CODEOWNERS protects .github/workflows/" "grep -qF '.github/workflows/' '$CO'"
assert "CODEOWNERS protects scripts/git-hooks/" "grep -qF 'scripts/git-hooks/' '$CO'"
assert "CODEOWNERS protects scripts/tdd-gate.sh" "grep -qF 'scripts/tdd-gate.sh' '$CO'"
assert "CODEOWNERS protects scripts/edit-guard.sh" "grep -qF 'scripts/edit-guard.sh' '$CO'"
assert "CODEOWNERS protects scripts/*gate*" "grep -qF 'scripts/*gate*' '$CO'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
