#!/usr/bin/env bash
# test-readme-v620.sh — README.md reflects v6.2.0 (Phase 7: OpenCode v1/v2,
# Multi-Agent & Guardrails) while retaining the v6.1.0 Claude Code parity section.
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOC="$REPO_ROOT/README.md"
fail=0
grep -q "version-6.2.0" "$DOC" && echo "  ✓ version badge 6.2.0" || { echo "  ✗ badge not updated"; fail=1; }
grep -q "Latest: v6.2.0" "$DOC" && echo "  ✓ Latest line v6.2.0" || { echo "  ✗ Latest line not updated"; fail=1; }
grep -q "philosophy A" "$DOC" && echo "  ✓ philosophy A mentioned" || { echo "  ✗ missing philosophy A"; fail=1; }
exit "$fail"
