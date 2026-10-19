#!/usr/bin/env bash
# check-approved-tree.sh — L2: the PR head tree must match the human-approved tree.
#
# The approval artifact is a line in the PR body:
#
#   AAS-APPROVED-TREE: <git tree sha>
#
# The human writes it after reviewing the exact head commit. This step runs as
# part of the required `gates` check, so a PR whose head tree differs from the
# approved tree cannot merge. It complements the local Gate 0 (which binds the
# staged tree) with a remote check the agent cannot satisfy by editing the index.
#
# Caveat: this is only as strong as control of the PR body. The capability
# boundary (the external runner) and L3 (CODEOWNERS on this workflow) are the
# backstop. See docs/BRANCH-PROTECTION.md.
#
# Usage: PR_BODY="..." bash scripts/check-approved-tree.sh
# Exit: 0 match or not a PR, 1 missing/mismatch.

set -euo pipefail

body="${PR_BODY:-}"
if [ -z "$body" ]; then
  # Push to main, or a local run: there is no PR to approve.
  echo "check-approved-tree: no PR body (not a pull_request run), skipping."
  exit 0
fi

approved=$(printf '%s\n' "$body" \
  | sed -n 's/.*AAS-APPROVED-TREE:[[:space:]]*\([0-9a-fA-F]\{40,64\}\).*/\1/p' \
  | tail -1)

if [ -z "$approved" ]; then
  echo "check-approved-tree: missing 'AAS-APPROVED-TREE: <sha>' in the PR body."
  echo "  The human must approve the exact head tree: git rev-parse HEAD^{tree}"
  exit 1
fi

head_tree=$(git rev-parse HEAD^{tree} 2>/dev/null || true)
if [ -z "$head_tree" ]; then
  echo "check-approved-tree: cannot resolve HEAD^{tree}."
  exit 1
fi

if [ "$approved" != "$head_tree" ]; then
  echo "check-approved-tree: approved tree != PR head tree."
  echo "  approved: $approved"
  echo "  head:     $head_tree"
  echo "  Re-approve the current head and update the PR body."
  exit 1
fi

echo "check-approved-tree: PR head tree matches the approved tree ($head_tree)."
