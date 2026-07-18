#!/usr/bin/env bash
# design-upgrade.sh — Auto-extract design system from existing codebase
# Reads CSS vars, HTML, and framework files to generate DESIGN.md.
# Only asks 2-3 questions about what can't be extracted.
#
# Usage: bash scripts/design-upgrade.sh [--project-dir <path>]

set -uo pipefail

REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || echo '.')}"
PROJECT_DIR="$REPO_ROOT"
while [ $# -gt 0 ]; do
  case "$1" in --project-dir) PROJECT_DIR="$2"; shift 2;; *) shift;; esac
done

OUTPUT="$PROJECT_DIR/DESIGN.md"
CSS_FILE="$PROJECT_DIR/css/style.css"
HTML_FILE="$PROJECT_DIR/index.html"
PKG_FILE="$PROJECT_DIR/package.json"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  DESIGN UPGRADE                            ║"
echo "╚════════════════════════════════════════════╝"

# Helper: extract value from CSS var declaration
extract_val() { grep -oP "\s*$1:\s*\K[^;]+" "$CSS_FILE" 2>/dev/null | head -1 || true; }

# Build DESIGN.md sections
cat > "$OUTPUT" << 'HEADER'
# DESIGN.md — Auto-extracted from codebase

## Section 1: Design Principles
(extracted from codebase — review and refine)

## Section 2: Three Dials
VARIANCE: 5, MOTION: 4, DENSITY: 5

HEADER

# Section 3: Typography
FONTS=""
if [ -f "$HTML_FILE" ]; then
  FONTS=$(grep -oP 'family=\K[^"&;]+' "$HTML_FILE" 2>/dev/null | tr '+' ' ' | tr '\n' ', ' | sed 's/, $//')
fi
if [ -z "$FONTS" ]; then FONTS="system-ui (no external fonts detected)"; fi
cat >> "$OUTPUT" << FONTS
## Section 3: Typography
Display: $FONTS
Body: system-ui
Loading: $(grep -q 'fonts.googleapis\|fonts.gstatic' "$HTML_FILE" 2>/dev/null && echo "Google Fonts" || echo "system fonts")

FONTS

# Section 4: Color Palette
COLORS=""
if [ -f "$CSS_FILE" ]; then
  COLORS=$(grep -oP '#[0-9A-Fa-f]{6}' "$CSS_FILE" 2>/dev/null | sort -u | head -10 | tr '\n' ', ' | sed 's/, $//')
fi
cat >> "$OUTPUT" << COLR
## Section 4: Color Palette
$( [ -n "$COLORS" ] && echo "Extracted: $COLORS" || echo "(no color tokens detected)")

COLR

# Section 5: Spacing Scale
SPACES=""
if [ -f "$CSS_FILE" ]; then
  SPACES=$(grep -oP '\s*--space-[\w-]+:\s*\K[^;]+' "$CSS_FILE" 2>/dev/null | tr '\n' ', ' | sed 's/, $//')
fi
cat >> "$OUTPUT" << SPCS
## Section 5: Spacing Scale
$( [ -n "$SPACES" ] && echo "Extracted: $SPACES" || echo "(no spacing tokens detected)")

SPCS

# Section 6: Grid System
BPS=""
if [ -f "$CSS_FILE" ]; then
  BPS=$(grep -oP '(min|max)-width:\s*\K\d+px' "$CSS_FILE" 2>/dev/null | sort -u | tr '\n' ', ' | sed 's/, $//')
fi
cat >> "$OUTPUT" << BRKS
## Section 6: Grid System
$( [ -n "$BPS" ] && echo "Breakpoints: $BPS" || echo "(no breakpoints detected)")

BRKS

# Section 7: Motion
TRANSITIONS=""
if [ -f "$CSS_FILE" ]; then
  TRANSITIONS=$(grep -oP '\s*--transition-[\w-]+:\s*\K[^;]+' "$CSS_FILE" 2>/dev/null | tr '\n' ', ' | sed 's/, $//')
fi
cat >> "$OUTPUT" << MOTN
## Section 7: Motion
$( [ -n "$TRANSITIONS" ] && echo "Transitions: $TRANSITIONS" || echo "(no transitions detected)")
Reduced motion: $(grep -q 'prefers-reduced-motion' "$CSS_FILE" 2>/dev/null && echo "yes" || echo "not detected")

MOTN

# Detect theme
THEME="not detected"
if grep -q 'data-theme\|\.dark\|prefers-color-scheme' "$CSS_FILE" "$HTML_FILE" 2>/dev/null; then
  THEME=$(grep -o 'data-theme="[^"]*"' "$HTML_FILE" 2>/dev/null | sed 's/data-theme="//;s/"//' || echo "CSS class-based")
fi

# Detect framework
FRAMEWORK="static HTML (no framework detected)"
if [ -f "$PKG_FILE" ]; then
  if grep -q '"next"' "$PKG_FILE" 2>/dev/null; then FRAMEWORK="Next.js"
  elif grep -q '"react"' "$PKG_FILE" 2>/dev/null; then FRAMEWORK="React"
  fi
fi

# Detect platform
PLATFORM="web"
if [ -f "$PKG_FILE" ]; then
  if grep -q '"react-native\|"expo"' "$PKG_FILE" 2>/dev/null; then PLATFORM="mobile"
  elif grep -q '"tauri\|"electron"' "$PKG_FILE" 2>/dev/null; then PLATFORM="desktop"
  fi
fi

# Sections 8-12: template with gaps marked
cat >> "$OUTPUT" << MISC
## Section 8: Component Specs
(extract from HTML — review)

## Section 9: Layout Patterns
(extract from HTML structure — review)

## Section 10: Anti-Pattern Bans
(review manually — not extractable from code)

## Section 11: Accessibility Baseline
Contrast: AA recommended
(not extractable from code — user should specify)

## Section 12: Approved Artifacts
design/approved/ (if directory exists)

MISC

# Sections 13-17: Platform-specific
cat >> "$OUTPUT" << PLATFORM
## Section 13: CSS Architecture
$( [ -f "$CSS_FILE" ] && echo "CSS custom properties in :root" || echo "(no CSS detected)" )

## Section 14: Theme Implementation
$THEME

## Section 15: Component Framework
$FRAMEWORK

## Section 16: Platform Responsiveness
Platform: $PLATFORM
$( [ -n "$BPS" ] && echo "Breakpoints: $BPS" || echo "(review)" )

## Section 17: Asset Pipeline
$( [ -n "$FONTS" ] && echo "Fonts: $FONTS" || echo "(review)" )
PLATFORM

echo "  ${GREEN}✓${NC} DESIGN.md generated at $OUTPUT"
echo ""
echo "  Next steps:"
  echo "  1. Review and refine extracted sections"
  echo "  2. Run design-gate.sh --audit to validate"
  echo "  3. If redesigning, load redesign-skill to apply changes"
  echo "  4. Run design-upgrade.sh again to merge changes"
echo ""
