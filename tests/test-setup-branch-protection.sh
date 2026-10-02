#!/usr/bin/env bash
# test-setup-branch-protection.sh — asserts scripts/setup-branch-protection.sh
# auto-detects the repo shape, selects the solo/team profile, enforces the
# lockout guard, stays idempotent, and keeps dry-run side-effect free. Also
# asserts the gate configuration itself is protected in CODEOWNERS (L3).
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

# ── Mocked gh: repo-shape detection + a stateful protection store ──
MOCK_DIR=$(mktemp -d)
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
      --paginate) shift;;
      --jq) shift 2;;
      -H|--header|-f|--raw-field|--field) shift 2;;
      *) endpoint="$1"; shift;;
    esac
  done
  case "$endpoint" in
    *"/collaborators"*)
      cat "$state/collaborators.json" 2>/dev/null || echo '[]'
      exit 0;;
  esac
  if [ "$endpoint" = "repos/testowner/testrepo" ]; then
    printf '{"owner":{"type":"%s"}}\n' "${MOCK_OWNER_TYPE:-User}"
    exit 0
  fi
  if [ "$method" = "GET" ]; then
    if [ -f "$state/protected" ]; then cat "$state/protection.json"; exit 0; fi
    echo "gh: Not Found (HTTP 404)" >&2; exit 1
  fi
  if [ "$method" = "PUT" ]; then
    jq '{
      required_status_checks: {strict: .required_status_checks.strict, contexts: .required_status_checks.contexts},
      enforce_admins: {enabled: .enforce_admins},
      required_pull_request_reviews: {
        dismiss_stale_reviews: .required_pull_request_reviews.dismiss_stale_reviews,
        require_code_owner_reviews: .required_pull_request_reviews.require_code_owner_reviews,
        required_approving_review_count: .required_pull_request_reviews.required_approving_review_count
      },
      required_conversation_resolution: {enabled: .required_conversation_resolution},
      allow_force_pushes: {enabled: .allow_force_pushes},
      allow_deletions: {enabled: .allow_deletions}
    }' "$state/last_input" > "$state/protection.json"
    touch "$state/protected"
    echo '{"ok":true}'
    exit 0
  fi
fi
exit 1
MOCK
chmod +x "$MOCK_DIR/gh"

# collaborators_json <n> — n humans with push access.
collaborators_json() {
  local n="$1" out="[" i=1
  while [ "$i" -le "$n" ]; do
    [ "$i" -gt 1 ] && out="${out},"
    out="${out}{\"login\":\"user${i}\",\"permissions\":{\"admin\":false,\"push\":true}}"
    i=$((i + 1))
  done
  echo "${out}]"
}

# run_mock <state> <owner-type> <n-collaborators> [args...] — stdout is the run.
run_mock() {
  local state="$1" owner="$2" collabs="$3"; shift 3
  collaborators_json "$collabs" > "$state/collaborators.json"
  MOCK_GH_STATE="$state" MOCK_OWNER_TYPE="$owner" PATH="$MOCK_DIR:$PATH" \
    bash "$SCRIPT" --repo testowner/testrepo --branch main "$@" 2>&1
}

# ── Solo profile: User owner + 1 human → no approval required ──
S1=$(mktemp -d)
out1=$(run_mock "$S1" User 1); rc1=$?
A1=$(jq -r '.required_pull_request_reviews.required_approving_review_count' "$S1/last_input")
CO1=$(jq -r '.required_pull_request_reviews.require_code_owner_reviews' "$S1/last_input")
EA1=$(jq -r '.enforce_admins' "$S1/last_input")
ST1=$(jq -r '.required_status_checks.strict' "$S1/last_input")
assert "solo (User, 1 human): exits 0" "[ $rc1 -eq 0 ]"
assert "solo: approvals = 0" "[ '$A1' = '0' ]"
assert "solo: code-owner review off" "[ '$CO1' = 'false' ]"
assert "solo: enforce_admins off" "[ '$EA1' = 'false' ]"
assert "solo: strict off" "[ '$ST1' = 'false' ]"
assert "solo: still requires the gates check" "jq -e '(.required_status_checks.contexts | index(\"gates\")) != null' '$S1/last_input' >/dev/null"
assert "solo: reports final mode solo" "echo \"\$out1\" | grep -qi 'final mode: *solo'"

# ── Team profile: Organization owner + 3 humans → 1 approval + code owners ──
S2=$(mktemp -d)
out2=$(run_mock "$S2" Organization 3); rc2=$?
A2=$(jq -r '.required_pull_request_reviews.required_approving_review_count' "$S2/last_input")
CO2=$(jq -r '.required_pull_request_reviews.require_code_owner_reviews' "$S2/last_input")
EA2=$(jq -r '.enforce_admins' "$S2/last_input")
ST2=$(jq -r '.required_status_checks.strict' "$S2/last_input")
assert "team (Org, 3 humans): exits 0" "[ $rc2 -eq 0 ]"
assert "team: approvals = 1" "[ '$A2' = '1' ]"
assert "team: code-owner review on" "[ '$CO2' = 'true' ]"
assert "team: enforce_admins on" "[ '$EA2' = 'true' ]"
assert "team: strict on" "[ '$ST2' = 'true' ]"
assert "team: reports final mode team" "echo \"\$out2\" | grep -qi 'final mode: *team'"

# ── Lockout guard: --mode team but only 1 human → forced solo + warning ──
S3=$(mktemp -d)
out3=$(run_mock "$S3" Organization 1 --mode team); rc3=$?
A3=$(jq -r '.required_pull_request_reviews.required_approving_review_count' "$S3/last_input")
CO3=$(jq -r '.required_pull_request_reviews.require_code_owner_reviews' "$S3/last_input")
EA3=$(jq -r '.enforce_admins' "$S3/last_input")
assert "guard (--mode team, 1 human): exits 0" "[ $rc3 -eq 0 ]"
assert "guard: approvals forced to 0" "[ '$A3' = '0' ]"
assert "guard: code-owner review forced off" "[ '$CO3' = 'false' ]"
assert "guard: enforce_admins forced off" "[ '$EA3' = 'false' ]"
assert "guard: final mode forced solo" "echo \"\$out3\" | grep -qi 'final mode: *solo'"
assert "guard: prints a lockout warning" "echo \"\$out3\" | grep -qi 'lockout guard'"
assert "guard: explains self-approval is impossible" "echo \"\$out3\" | grep -qi 'approve your own'"

# ── --force-lockout-risk: explicit opt-in allows the risky team config ──
S4=$(mktemp -d)
out4=$(run_mock "$S4" Organization 1 --mode team --force-lockout-risk); rc4=$?
A4=$(jq -r '.required_pull_request_reviews.required_approving_review_count' "$S4/last_input")
EA4=$(jq -r '.enforce_admins' "$S4/last_input")
assert "--force-lockout-risk: exits 0" "[ $rc4 -eq 0 ]"
assert "--force-lockout-risk: risky approvals = 1" "[ '$A4' = '1' ]"
assert "--force-lockout-risk: enforce_admins on" "[ '$EA4' = 'true' ]"
assert "--force-lockout-risk: prints a loud warning" "echo \"\$out4\" | grep -qi 'force-lockout-risk'"

# ── Flag overrides (profile first, flags second) ──
S5=$(mktemp -d)
run_mock "$S5" Organization 3 --approvals 2 --strict --code-owner-reviews --enforce-admins >/dev/null
A5=$(jq -r '.required_pull_request_reviews.required_approving_review_count' "$S5/last_input")
assert "--approvals N overrides the profile" "[ '$A5' = '2' ]"

# ── Guard: code-owner review with 1 human is also unsatisfiable ──
S5b=$(mktemp -d)
out5b=$(run_mock "$S5b" User 1 --mode solo --code-owner-reviews); rc5b=$?
CO5b=$(jq -r '.required_pull_request_reviews.require_code_owner_reviews' "$S5b/last_input")
assert "guard: code-owner review forced off for 1 human" "[ '$CO5b' = 'false' ]"
assert "guard: warns when code-owner review is unsatisfiable" "echo \"\$out5b\" | grep -qi 'lockout guard'"

# ── Guard: over-large --approvals is capped to reachable reviewers (N-1) ──
S5c=$(mktemp -d)
out5c=$(run_mock "$S5c" Organization 3 --approvals 5); rc5c=$?
A5c=$(jq -r '.required_pull_request_reviews.required_approving_review_count' "$S5c/last_input")
assert "guard: --approvals 5 with 3 humans capped to 2" "[ '$A5c' = '2' ]"
assert "guard: explains the approvals cap" "echo \"\$out5c\" | grep -qi 'Capping required approvals'"

# ── Dry-run: prints the plan, makes no PUT ──
S6=$(mktemp -d)
out6=$(run_mock "$S6" User 1 --dry-run); rc6=$?
assert "dry-run exits 0" "[ $rc6 -eq 0 ]"
assert "dry-run prints the protection endpoint" "echo \"\$out6\" | grep -qF 'branches/main/protection'"
assert "dry-run prints the gates required check" "echo \"\$out6\" | grep -qF 'gates'"
assert "dry-run prints the final payload" "echo \"\$out6\" | grep -q 'required_status_checks'"
assert "dry-run does not mutate (no PUT executed)" "! grep -q -- '-X PUT' '$S6/calls'"

# ── Idempotency against the stateful mock gh ──
S7=$(mktemp -d)
run1=$(run_mock "$S7" User 1); rc7a=$?
run2=$(run_mock "$S7" User 1); rc7b=$?
assert "first run exits 0" "[ $rc7a -eq 0 ]"
assert "second run exits 0 (idempotent)" "[ $rc7b -eq 0 ]"
assert "second run reports already configured" "echo \"\$run2\" | grep -qi 'already'"
PUT_COUNT=$(grep -c -- '-X PUT' "$S7/calls" 2>/dev/null || true)
PUT_COUNT=${PUT_COUNT:-0}
assert "PUT applied exactly once across two runs" "[ '$PUT_COUNT' -eq 1 ]"
assert "PUT targets branches/main/protection" "grep -q 'branches/main/protection' '$S7/calls'"
assert "PUT sent the gates required check" "grep -q 'gates' '$S7/last_input'"
assert "PUT disables force pushes" "grep -q 'allow_force_pushes' '$S7/last_input'"
assert "PUT requires conversation resolution" "grep -q 'required_conversation_resolution' '$S7/last_input'"

rm -rf "$MOCK_DIR" "$S1" "$S2" "$S3" "$S4" "$S5" "$S5b" "$S5c" "$S6" "$S7"

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
