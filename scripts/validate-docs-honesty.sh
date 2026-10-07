#!/usr/bin/env bash
# validate-docs-honesty.sh — Phase 13 S2: verify that documentation is HONEST.
#
# A doc must not cite repo paths (in backticks) that do not exist, nor link to
# internal `.md` files that do not resolve. These are the real bugs Phase 13
# fixes: the startup Protocol citing a non-existent path, and the Gate 11 remedy
# citing a script that is not installed.
#
# The link / placeholder checks mirror scripts/universal-audit.sh, scoped to the
# given files so the TDD gate can block on a single dishonest doc.
#
# Usage: bash scripts/validate-docs-honesty.sh [--root DIR] FILE...
# Exit codes: 0 = PASS, 1 = FAIL (a cited path / link does not resolve)
set -uo pipefail
set -f   # no pathname expansion — backtick tokens are data, never globs

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'

ROOT=""
STRICT=0
FILES=()
while [ $# -gt 0 ]; do
  case "$1" in
    --root) ROOT="${2:-}"; shift 2 ;;
    --strict) STRICT=1; shift ;;
    -h|--help) echo "Usage: bash scripts/validate-docs-honesty.sh [--root DIR] [--strict] FILE..."; exit 0 ;;
    *) FILES+=("$1"); shift ;;
  esac
done

if [ -z "$ROOT" ]; then
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi
ROOT="$(cd "$ROOT" 2>/dev/null && pwd)" || { echo "validate-docs-honesty: bad --root"; exit 2; }

[ ${#FILES[@]} -eq 0 ] && exit 0

# Extensions that mark a backtick word as a repo path.
EXT_RE='\.(md|markdown|txt|adoc|sh|bash|zsh|ts|tsx|js|mjs|cjs|jsx|py|rs|go|rb|dart|swift|kt|kts|java|cc|cpp|hpp|h|c|html|htm|css|scss|less|json|jsonc|yaml|yml|toml|xml|svg|csv|lock|cfg|ini|env|example)$'

FAIL=0; WARN=0
fail() { echo -e "  ${RED}✗${NC} $1"; FAIL=$((FAIL + 1)); }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; WARN=$((WARN + 1)); }

# Does a cited path resolve? Try absolute, repo-root-relative, doc-relative, ~/.
path_exists() {
  local p="$1" docdir="$2"
  [ -z "$p" ] && return 0
  case "$p" in '~/'*) [ -e "$HOME/${p#~/}" ] && return 0 ;; esac
  [ -e "$p" ] && return 0
  [ -e "$ROOT/$p" ] && return 0
  [ -n "$docdir" ] && [ -e "$ROOT/$docdir/$p" ] && return 0
  return 1
}

# Is a backtick word a repo path? Only REPO-relative paths: path-safe characters
# (no globs, braces, vars, URLs), a `/` separator, a known extension, and a first
# segment that is a REAL directory of this repo — so paths that describe another
# project's layout (`.claude/`, `architecture/`, …) are skipped. Bare filenames
# cited by name are not paths; `~/` and absolute paths are env-specific.
is_path_word() {
  local w="$1" seg
  [ -z "$w" ] && return 1
  echo "$w" | grep -qE '^[A-Za-z0-9._/-]+$' || return 1   # path-safe chars only
  echo "$w" | grep -qE '^/|^~' && return 1                # absolute / home → env-specific
  case "$w" in ./*) w="${w#./}" ;; esac
  echo "$w" | grep -qE '/' || return 1                    # require a directory separator
  echo "$w" | grep -qE "$EXT_RE" || return 1              # ...and a known extension
  seg="${w%%/*}"
  [ -d "$ROOT/$seg" ] || return 1                         # first segment must be a real dir
  return 0
}

for f in "${FILES[@]}"; do
  [ -f "$f" ] || f="$ROOT/$f"   # accept paths relative to --root
  [ -f "$f" ] || continue
  docdir="$(dirname "$f")"; [ "$docdir" = "." ] && docdir=""

  # ── CHECK 1: cited repo paths exist ──
  # Advisory by default (docs legitimately describe other projects' layouts and
  # future artifacts); --strict promotes a missing cited path to a BLOCK.
  while IFS= read -r tok; do
    tok="${tok#\`}"; tok="${tok%\`}"
    # shellcheck disable=SC2086
    for w in $tok; do
      w="${w%[.,;:]}"
      is_path_word "$w" || continue
      if ! path_exists "$w" "$docdir"; then
        if [ "$STRICT" = "1" ]; then
          fail "$f: cites a path that does not exist: \`$w\`"
        else
          warn "$f: cites a path that does not exist: \`$w\`"
        fi
      fi
    done
  done < <(grep -oE '`[^`]+`' "$f" 2>/dev/null || true)

  # ── CHECK 2: internal .md links resolve (doc-relative, fence-aware) ──
  while IFS= read -r link; do
    [ -z "$link" ] && continue
    target="$(echo "$link" | sed 's/^.*](//; s/)$//; s/#.*$//')"
    [ -z "$target" ] && continue
    echo "$target" | grep -qE '^https?://' && continue
    echo "$target" | grep -qE '^#' && continue
    case "$target" in
      /*) resolved="$target" ;;
      *) resolved="$ROOT/$docdir/$target" ;;   # markdown links are doc-relative
    esac
    [ -e "$resolved" ] || fail "$f: broken internal link -> $target"
  done < <(awk '
    /^```/ { match($0, /^`+/); fl=RLENGTH; info=substr($0, fl+1); gsub(/^[ \t]+|[ \t]+$/, "", info)
      if (!b) { b=1; o=fl } else if (info=="" && fl>=o) { b=0; o=0 }
      next }
    !b { print }
  ' "$f" 2>/dev/null | sed 's/`[^`]*`//g' | grep -oE '\]\([^)]+\.md[^)]*\)' || true)

  # ── CHECK 3: placeholders (non-blocking) ──
  while IFS=$'\t' read -r ln line; do
    [ -z "$ln" ] && continue
    warn "$f:$ln: placeholder found"
  done < <(awk '
    /^```/ { match($0, /^`+/); fl=RLENGTH; info=substr($0, fl+1); gsub(/^[ \t]+|[ \t]+$/, "", info)
      if (!b) { b=1; o=fl } else if (info=="" && fl>=o) { b=0; o=0 }
      next }
    !b && $0 ~ /TODO:|FIXME:|XXX|coming soon|under construction|lorem ipsum/ { printf "%d\t%s\n", NR, $0 }
  ' "$f" 2>/dev/null || true)
done

if [ "$FAIL" -gt 0 ]; then
  echo -e "  ${RED}❌ docs-honesty: $FAIL issue(s).${NC}"
  exit 1
fi
exit 0
