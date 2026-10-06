#!/usr/bin/env bash
# test-tdd-gate-aas-managed.sh — the TDD gate exempts AAS-managed artifacts in a
# CONSUMER project (installed copies / shims) but stays RIGOROUS in the framework
# repo (there those paths are source). Also: shim detection is content-based and
# must NOT mistake a file that merely embeds the shim template (init-agents.sh).
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GATE="$REPO_ROOT/scripts/tdd-gate.sh"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
FAIL=0
pass() { echo "  ✓ $1"; }
fail() { echo "  ✗ $1"; FAIL=1; }

# Fresh consumer repo (no framework markers).
consumer() {
  cd "$TMP" || return
  rm -rf r; mkdir r; cd r || return
  git init -q
  git config user.email t@t.t; git config user.name t
  echo base > base.txt; git add base.txt; git commit -qm base
}

# Framework repo: VERSION + scripts/git-hooks/pre-commit + SOUL.md.
framework() {
  consumer
  echo 6.3.0 > VERSION
  mkdir -p scripts/git-hooks
  printf '#!/bin/sh\ntrue\n' > scripts/git-hooks/pre-commit
  echo soul > SOUL.md
  git add -A; git commit -qm framework
}

gate_exit() { ( unset REPO_ROOT; bash "$GATE" >/dev/null 2>&1 ); echo $?; }
expect() { [ "$(gate_exit)" = "$1" ] && pass "$2" || fail "$2 (expected exit $1)"; }

# ── Consumer: AAS-managed artifacts are exempt ──
consumer
mkdir -p rules/common; echo x > rules/common/b.md; git add -A
expect 0 "consumer: rules/common/*.md exempt"

consumer
echo '# agents' > AGENTS.md; echo 6.3.0 > VERSION; echo soul > SOUL.md
mkdir -p .husky .github/workflows .aas
printf '#!/bin/sh\nexec "$_AAS_ROOT/scripts/git-hooks/pre-commit" "$@"\n' > .husky/pre-commit
echo 'name: gates' > .github/workflows/gates.yml
echo '{}' > .aas/config
git add -A
expect 0 "consumer: AGENTS.md/VERSION/SOUL.md/.husky/gates.yml/.aas exempt"

consumer
mkdir -p scripts
printf '#!/bin/sh\n_AAS_WALK=x\nexec "$_AAS_ROOT/scripts/skill-gate.sh" "$@"\n' > scripts/skill-gate.sh
git add -A
expect 0 "consumer: portable shim scripts/*.sh exempt (by content)"

consumer
mkdir -p .aas docs; printf 'docs/*\n' > .aas/tdd-ignore; echo '# d' > docs/g.md; git add -A
expect 0 "consumer: .aas/tdd-ignore exempts docs/*"

# ── Consumer: real code still blocks (the exemption is not a hole) ──
consumer
mkdir -p src; echo 'const x=1' > src/foo.ts; git add -A
expect 1 "consumer: src/foo.ts still blocks"

consumer
mkdir -p src; echo 'x=1' > src/foo.py; git add -A
expect 1 "consumer: src/foo.py still blocks"

consumer
mkdir -p lib; echo 'package x' > lib/a.go; git add -A
expect 1 "consumer: lib/a.go still blocks"

# ── Framework repo: AAS-managed paths are SOURCE → still gated ──
framework
mkdir -p rules/common; echo x > rules/common/b.md; git add -A
expect 1 "framework: rules/*.md still blocks (source)"

framework
mkdir -p scripts
printf '#!/usr/bin/env bash\n# embeds the shim template\n_AAS_WALK=x\nexec "\\$_AAS_ROOT/x"\n' > scripts/init-agents.sh
git add -A
expect 1 "framework: template-embedding file (init-agents.sh-like) still blocks"

# ── Framework repo: a REAL shim is exempt (content-based, universal) ──
framework
mkdir -p scripts
printf '#!/bin/sh\nexec "$_AAS_ROOT/scripts/x.sh" "$@"\n' > scripts/a-shim.sh
git add -A
expect 0 "framework: a real portable shim is exempt"

echo ""
[ "$FAIL" -eq 0 ] && echo "Results: ALL PASS" || echo "Results: FAILURES"
exit "$FAIL"
