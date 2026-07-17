#!/usr/bin/env bash
# token-validate.sh — Detects CSS token drift against DESIGN.md (P6.3)
# Scans CSS for hex/spacing/font values not defined in DESIGN.md tokens.
# Exits 0 if drift < threshold, 1 if drift >= threshold.
#
# Usage: bash scripts/token-validate.sh
#   --design-dir <dir>    Path to project root (default: git rev-parse --show-toplevel)
#   --css-dir <dir>       Directory to scan for CSS files (default: project root)
#   --css-file <file>     Single CSS file to scan (overrides --css-dir)
#   --threshold <N>       Max drift percentage before exit 1 (default: 5)
#   --platform <name>     web|mobile|desktop|pwa (default: web)
#
# Exit: 0 = pass, 1 = drift above threshold

set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || echo '.')}"
DESIGN_DIR="$REPO_ROOT"
CSS_DIR="$REPO_ROOT"
CSS_FILE=""
THRESHOLD=5
PLATFORM="web"

# Parse args
while [ $# -gt 0 ]; do
  case "$1" in
    --design-dir) DESIGN_DIR="$2"; shift 2 ;;
    --css-dir)    CSS_DIR="$2"; shift 2 ;;
    --css-file)   CSS_FILE="$2"; shift 2 ;;
    --threshold)  THRESHOLD="$2"; shift 2 ;;
    --platform)   PLATFORM="$2"; shift 2 ;;
    *) shift ;;
  esac
done

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

DESIGN_FILE="$DESIGN_DIR/DESIGN.md"
CSS_TARGET="$CSS_FILE"
SCAN_DIR="$CSS_DIR"

# ─── Step 1: Extract tokens from DESIGN.md ───
TOKENS_FILE="$TMP/design_tokens.txt"
MATCH_FILE="$TMP/css_extracted.txt"

if [ ! -f "$DESIGN_FILE" ]; then
  echo "  ${YELLOW}−${NC} No DESIGN.md found — skipping"
  exit 0
fi

# Extract tokens: hex values + spacing values, sorted for comm
sed '/```/,/```/d' "$DESIGN_FILE" | grep -oiE '#[0-9A-Fa-f]{3,6}\b|\b[0-9]+px\b' | tr '[:upper:]' '[:lower:]' | sort -u > "$TOKENS_FILE"

DESIGN_COUNT=$(wc -l < "$TOKENS_FILE")

# ─── Step 2: Scan CSS files ───
ALLOWLIST="transparent currentColor inherit initial unset none auto 0 100% medium bold normal"

if [ -n "$CSS_TARGET" ]; then
  CSS_FILES="${CSS_DIR}/${CSS_TARGET}"
elif [ "$PLATFORM" = "web" ]; then
  CSS_FILES=$(find "$SCAN_DIR" -maxdepth 3 -name '*.css' -o -name '*.scss' -o -name '*.less' 2>/dev/null | head -20)
else
  echo "  ${YELLOW}−${NC} Platform '$PLATFORM' scanning not implemented — web only"
  CSS_FILES=$(find "$SCAN_DIR" -maxdepth 3 -name '*.css' -o -name '*.scss' 2>/dev/null | head -20)
fi

if [ -z "$CSS_FILES" ]; then
  echo "  ${YELLOW}−${NC} No CSS files found — skipping"
  exit 0
fi

# Extract hex values from CSS
for f in $CSS_FILES; do
  [ -f "$f" ] || continue
  grep -oiE '#[0-9A-Fa-f]{3,6}\b' "$f" 2>/dev/null || true
done | tr '[:upper:]' '[:lower:]' | sort -u > "$MATCH_FILE"

# Sort CSS values for comm comparison
sort -u -o "$MATCH_FILE" "$MATCH_FILE" 2>/dev/null || true

# Remove allowlist entries
for val in $ALLOWLIST; do
  sed -i "/^$val$/d" "$MATCH_FILE" 2>/dev/null || true
done

CSS_COUNT=$(wc -l < "$MATCH_FILE")

# ─── Step 3: Compare ───
UNMATCHED_IN_CSS=$(comm -23 "$MATCH_FILE" "$TOKENS_FILE" | wc -l)
UNMATCHED_IN_DESIGN=$(comm -13 "$MATCH_FILE" "$TOKENS_FILE" | wc -l)
MATCHED=$(comm -12 "$MATCH_FILE" "$TOKENS_FILE" | wc -l)

TOTAL_UNIQUE=$((CSS_COUNT + DESIGN_COUNT - MATCHED))
DRIFT_PCT=0
if [ "$TOTAL_UNIQUE" -gt 0 ]; then
  DRIFT_PCT=$(( UNMATCHED_IN_CSS * 100 / TOTAL_UNIQUE ))
fi

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  TOKEN VALIDATE                            ║"
echo "╚════════════════════════════════════════════╝"
echo ""
echo "  DESIGN.md tokens: $DESIGN_COUNT"
echo "  CSS values found: $CSS_COUNT"
echo "  Matched:          $MATCHED"
echo "  Unmatched in CSS: $UNMATCHED_IN_CSS"
echo "  Unused tokens:    $UNMATCHED_IN_DESIGN"
echo "  Drift:            ${DRIFT_PCT}% (threshold: ${THRESHOLD}%)"
echo ""

if [ "$UNMATCHED_IN_CSS" -gt 0 ]; then
  echo "  Values in CSS not in DESIGN.md:"
  comm -23 "$MATCH_FILE" "$TOKENS_FILE" | head -10 | while read -r v; do
    echo "    - $v"
  done
  echo ""
fi

if [ "$DRIFT_PCT" -ge "$THRESHOLD" ]; then
  echo "  ${RED}✗ DRIFT EXCEEDS THRESHOLD${NC}"
  exit 1
else
  echo "  ${GREEN}✓ Drift within threshold${NC}"
  exit 0
fi
