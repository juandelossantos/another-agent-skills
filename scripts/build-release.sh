#!/usr/bin/env bash
# build-release.sh — build the pinned release tarball + checksums for a tag.
#
# Usage: bash scripts/build-release.sh <vX.Y.Z> [outdir]
# Output: <outdir>/another-agent-skills-vX.Y.Z.tar.gz + <outdir>/checksums.txt
#
# The tarball carries the framework source at its ROOT (so bin/aas, install.sh,
# scripts/, templates/, skills/ are top-level) — exactly what bootstrap.sh
# extracts. Dev-only files are excluded.
#
# Asset naming is the single source of truth in scripts/lib/aas.sh
# (aas_asset_name): another-agent-skills-v<version>.tar.gz.
#
# Spec: PLAN.md — Phase 9 / P9.1

set -euo pipefail

TAG="${1:-}"
OUTDIR="${2:-dist}"

if [ -z "$TAG" ]; then
    echo "usage: bash scripts/build-release.sh <vX.Y.Z> [outdir]" >&2
    exit 2
fi

VERSION="${TAG#v}"
case "$VERSION" in
    [0-9]*.[0-9]*.[0-9]*) : ;;
    *) echo "build-release: tag must be vX.Y.Z (got '${TAG}')" >&2; exit 2 ;;
esac

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
ASSET="another-agent-skills-v${VERSION}.tar.gz"

mkdir -p "$OUTDIR"

# sha256: GNU coreutils or the BSD/macOS equivalent.
sha256_of() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1"
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1"
    else
        echo "build-release: no sha256 tool (sha256sum / shasum) found" >&2
        return 1
    fi
}

# Build from the repo root; exclude VCS + dev-only artifacts.
tar \
    --exclude='./.git' \
    --exclude='./.git/*' \
    --exclude='./node_modules' \
    --exclude='./node_modules/*' \
    --exclude='./dist' \
    --exclude='./dist/*' \
    --exclude='./.aas' \
    --exclude='./.aas/*' \
    --exclude='./tests/playwright/test-results' \
    --exclude='./.trigger-stats.json' \
    --exclude='./.trigger-stats.json.prev' \
    --exclude='./.regression-results.json' \
    --exclude='*.backup.*' \
    -czf "${OUTDIR}/${ASSET}" -C "$REPO_ROOT" .

( cd "$OUTDIR" && sha256_of "$ASSET" > checksums.txt )

echo "built ${OUTDIR}/${ASSET}"
echo "built ${OUTDIR}/checksums.txt"
