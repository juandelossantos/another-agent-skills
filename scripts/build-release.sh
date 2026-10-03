#!/usr/bin/env bash
# build-release.sh — build the pinned release tarball + checksums for a tag.
#
# Usage: bash scripts/build-release.sh <vX.Y.Z> [outdir]
# Output: <outdir>/another-agent-skills-vX.Y.Z.tar.gz + <outdir>/checksums.txt
#
# The tarball carries the framework source at its ROOT (so bin/aas, install.sh,
# scripts/, templates/, skills/ are top-level) — exactly what bootstrap.sh
# extracts. It is built from the TRACKED content at the tag (git archive), never
# from the working tree: a working-tree build would leak untracked files (local
# config, secrets, node_modules) and untracked symlinks — including symlinks
# that escape the extraction root, which the installer's tarball guard refuses.
# When the tag is not present locally, HEAD is used (a warning is printed).
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

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$REPO_ROOT" ] || ! git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "build-release: not inside a git work tree — a release must be built from a checkout" >&2
    exit 2
fi
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

# Resolve the ref to archive: the tag when present, else HEAD.
REF=""
if git -C "$REPO_ROOT" rev-parse -q --verify "refs/tags/${TAG}^{commit}" >/dev/null 2>&1; then
    REF="$TAG"
elif git -C "$REPO_ROOT" rev-parse -q --verify "${TAG}^{commit}" >/dev/null 2>&1; then
    REF="$TAG"
else
    REF="HEAD"
    echo "build-release: tag ${TAG} not found locally — building tracked content at HEAD" >&2
fi

# Materialize tracked content at $REF, then tar it. Excludes are belt-and-braces
# (git archive already omits .git and untracked files).
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/aas-release.XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT
git -C "$REPO_ROOT" archive --format=tar "$REF" | tar -x -C "$STAGE"

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
    -czf "${OUTDIR}/${ASSET}" -C "$STAGE" .

# Stable-name, self-contained bootstrap asset for the documented one-liner
# (`curl .../releases/latest/download/bootstrap.sh | bash`). It inlines
# scripts/lib/aas.sh and drops the sibling-source lines, so it has no external
# dependency and works when piped — where BASH_SOURCE is unavailable.
BUNDLE="${OUTDIR}/bootstrap.sh"
{
    printf '#!/usr/bin/env bash\n'
    tail -n +2 "$REPO_ROOT/scripts/lib/aas.sh"
    awk 'NR == 1 { next }
         /^SCRIPT_DIR=/ { next }
         /^[[:space:]]*source .*scripts\/lib\/aas\.sh/ { next }
         { print }' "$REPO_ROOT/bootstrap.sh"
} > "$BUNDLE"
chmod +x "$BUNDLE"

( cd "$OUTDIR" && sha256_of "$ASSET" > checksums.txt && sha256_of bootstrap.sh >> checksums.txt )

echo "built ${OUTDIR}/${ASSET}"
echo "built ${OUTDIR}/bootstrap.sh"
echo "built ${OUTDIR}/checksums.txt"
