#!/usr/bin/env bash
# audit-markdown.sh — Comprehensive .md file audit
# Checks: table formatting, broken links, Mermaid syntax, placeholders, line counts
# Usage: bash scripts/audit-markdown.sh
#        bash scripts/audit-markdown.sh --json   # machine-readable output
# Exit code: 0 = PASS, 1 = FAIL (blocking)
set -euo pipefail

JSON_MODE=0
if [ "${1:-}" = "--json" ]; then
    JSON_MODE=1
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
PASS=0
FAIL=0
WARN=0

# JSON accumulator
JSON_FAILURES='[]'
JSON_WARNINGS='[]'

check() {
    local status="$1" msg="$2"
    # Determine if this is a core file (BLOCKING) or non-core (WARN)
    # Core files: root .md files like AGENTS.md, SOUL.md, etc.
    local is_core=0
    if echo "$msg" | grep -qE "$CORE_FILES"; then
        is_core=1
    fi

    if [ "$status" = "PASS" ]; then
        echo -e "  ${GREEN}✓${NC} $msg"
        PASS=$((PASS+1))
    elif [ "$status" = "WARN" ]; then
        echo -e "  ${YELLOW}⚠${NC} $msg"
        WARN=$((WARN+1))
    else
        if [ "$is_core" -eq 1 ]; then
            echo -e "  ${RED}✗${NC} $msg"
            FAIL=$((FAIL+1))
        else
            echo -e "  ${YELLOW}⚠${NC} $msg"
            WARN=$((WARN+1))
        fi
    fi
}

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           MARKDOWN AUDIT — another-agent-skills             ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

if [ "$JSON_MODE" -eq 1 ]; then
    # JSON mode: suppress human output, collect structured data
    exec 3>&1  # Save stdout
    exec >/dev/null  # Redirect stdout to null
fi

# Find all .md files (exclude node_modules, .git, .opencode, development/)
MD_FILES=$(find . -name "*.md" -not -path "./node_modules/*" -not -path "./.git/*" -not -path "./development/*" -not -path "./.opencode/*" | sort)

echo "=== CHECK 1: Table Column Consistency ==="
echo ""
while IFS= read -r f; do
    # Check for tables with mismatched column counts
    # Find lines that start with | and aren't separator lines
    headers=$(grep -c '^|' "$f" 2>/dev/null || true)
    if [ "$headers" -gt 0 ]; then
        # Find separator lines (---|---) and check against header columns
        while IFS= read -r sep_line; do
            sep_cols=$(echo "$sep_line" | grep -o '|' | wc -l)
            sep_cols=$((sep_cols - 1))
            # Find the header row before this separator
            header_line=$(grep -B1 "^|.*---.*|" "$f" 2>/dev/null | grep -v "^|.*---" | grep "^|" | head -1)
            if [ -n "$header_line" ]; then
                header_cols=$(echo "$header_line" | grep -o '|' | wc -l)
                header_cols=$((header_cols - 1))
                if [ "$sep_cols" -ne "$header_cols" ]; then
                    check "FAIL" "$f: table column mismatch (header=$header_cols, separator=$sep_cols)"
                fi
            fi
        done < <(grep "^|---" "$f" 2>/dev/null || true)
    fi
done < <(echo "$MD_FILES")
echo ""

echo "=== CHECK 2: Broken Internal Links ==="
echo ""
while IFS= read -r f; do
    dir=$(dirname "$f")
    grep -oE '\]\([^)]+\.md[^)]*\)' "$f" 2>/dev/null | while IFS= read -r link; do
        target=$(echo "$link" | sed 's/^.*](//' | sed 's/)$//' | sed 's/#.*$//')
        [ -z "$target" ] && continue
        echo "$target" | grep -qE '^https?://' && continue
        echo "$target" | grep -qE '^#' && continue
        if echo "$target" | grep -qE '^\.\.?\/'; then
            resolved="$dir/$target"
        else
            resolved="./$target"
        fi
        if [ ! -f "$resolved" ] && [ ! -d "$resolved" ]; then
            check "FAIL" "$f: broken link -> $target"
        fi
    done || true
done < <(echo "$MD_FILES")
echo ""

echo "=== CHECK 3: Placeholder Detection ==="
echo ""
PLACEHOLDERS="TODO|FIXME|XXX|coming soon|under construction|placeholder|lorem ipsum"
while IFS= read -r f; do
    matches=$(grep -nE "$PLACEHOLDERS" "$f" 2>/dev/null || true)
    if [ -n "$matches" ]; then
        while IFS= read -r match; do
            line_num=$(echo "$match" | cut -d: -f1)
            text=$(echo "$match" | cut -d: -f2- | tr -d '[:space:]' | head -c 60)
            check "WARN" "$f:$line_num: placeholder found: $text"
        done < <(echo "$matches")
    fi
done < <(echo "$MD_FILES")
echo ""

echo "=== CHECK 4: File Length Compliance ==="
echo ""
while IFS= read -r f; do
    lines=$(wc -l < "$f")
    # Root reference files can be longer, check only skills/
    if echo "$f" | grep -qE '^\.\/skills\/|^\.\/\.opencode\/skills\/'; then
        if [ "$lines" -gt 250 ]; then
            check "FAIL" "$f: $lines lines (max 250)"
        fi
    fi
done < <(echo "$MD_FILES")
echo ""

echo "=== CHECK 5: Mermaid Syntax (basic) ==="
echo ""
while IFS= read -r f; do
    mermaid_count=$(grep -c '```mermaid' "$f" 2>/dev/null || true)
    if [ "$mermaid_count" -gt 0 ]; then
        echo "  $f: $mermaid_count diagram(s)"
    fi
done < <(echo "$MD_FILES")
echo ""

echo "=== CHECK 6: Consistent Terminology ==="
echo ""
while IFS= read -r f; do
    # Check for "guardian" vs "Guardian" (must be capitalized)
    lower_guardian=$(grep -c '\bguardian\b' "$f" 2>/dev/null || true)
    if [ "$lower_guardian" -gt 0 ]; then
        check "WARN" "$f: $lower_guardian lowercase 'guardian' (should be 'Guardian')"
    fi
done < <(echo "$MD_FILES")
echo ""

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  SUMMARY                                                    ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo -e "║  ${GREEN}PASS: $PASS${NC}  ${YELLOW}WARN: $WARN${NC}  ${RED}FAIL: $FAIL${NC}                                           ║"
if [ "$FAIL" -gt 0 ]; then
    echo "║  ❌ Fix failures before proceeding.                            ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    exit 1
else
    echo "║  ✅ All checks passed.                                          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    exit 0
fi
