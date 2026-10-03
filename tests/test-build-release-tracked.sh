#!/usr/bin/env bash
# test-build-release-tracked.sh — scripts/build-release.sh must build the
# release from TRACKED content at the tag, not from the working tree.
#
# A working-tree build leaks untracked files (local config, secrets) and
# untracked symlinks into a release asset. Untracked symlinks can escape the
# extraction root, which the installer's aas_guard_tarball refuses — so a
# locally built release would not install. This pins both properties.
#
# Hermetic: a throwaway git repo under a temp dir; no network.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD="$REPO_ROOT/scripts/build-release.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

R="$TMP/repo"; mkdir -p "$R/bin" "$R/skills/foo"
git -C "$R" init -q
git -C "$R" config user.email t@t.com
git -C "$R" config user.name T
git -C "$R" config commit.gpgsign false

# Tracked content, including a legitimate in-root relative symlink.
printf '1.2.3\n' > "$R/VERSION"
printf '#!/usr/bin/env bash\necho aas\n' > "$R/bin/aas"; chmod +x "$R/bin/aas"
: > "$R/skills/foo/SKILL.md"
mkdir -p "$R/.opencode/skills" "$R/scripts/lib"
ln -s ../../skills/foo "$R/.opencode/skills/foo"
# build-release also emits a self-contained bootstrap.sh from these two files.
cp "$REPO_ROOT/bootstrap.sh" "$R/bootstrap.sh"
cp "$REPO_ROOT/scripts/lib/aas.sh" "$R/scripts/lib/aas.sh"
git -C "$R" add -A && git -C "$R" commit -q -m "release content"

# Untracked pollution that must NOT appear in the asset.
printf 'TOP-SECRET\n' > "$R/leaked-secret.txt"
ln -s ../../../../etc "$R/escape-link"
ln -s /etc/passwd "$R/abs-link"

OUT="$TMP/out"
( cd "$R" && bash "$BUILD" v1.2.3 "$OUT" ) > "$TMP/build.log" 2>&1; RC=$?
[ "$RC" -eq 0 ]; check $? "build-release exits 0 in a git repo (got rc=$RC)"

ASSET="$OUT/another-agent-skills-v1.2.3.tar.gz"
[ -f "$ASSET" ]; check $? "tarball written"

LIST="$TMP/list.txt"
tar -tzf "$ASSET" > "$LIST" 2>/dev/null || true
grep -qE '^\./bin/aas$' "$LIST"; check $? "tracked bin/aas is included"
grep -qE '^\./\.opencode/skills/foo$' "$LIST"; check $? "tracked in-root symlink is included"
! grep -q 'leaked-secret' "$LIST"; check $? "untracked file is NOT included"
! grep -qE '^\./(escape-link|abs-link)$' "$LIST"; check $? "untracked escaping symlink is NOT included"

# The resulting asset must satisfy the installer's tarball guard.
( cd "$REPO_ROOT" && . scripts/lib/aas.sh && aas_guard_tarball "$ASSET" ) > "$TMP/guard.log" 2>&1; RC=$?
[ "$RC" -eq 0 ]; check $? "built asset passes aas_guard_tarball (got rc=$RC)"

exit "$fail"
