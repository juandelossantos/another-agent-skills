#!/usr/bin/env bash
# generate-skill-pages.sh — Generate individual skill HTML pages from SKILL.md
# Part of another-agent-skills docs system
#
# Usage: bash scripts/generate-skill-pages.sh
# Reads: skills/*/SKILL.md
# Writes: docs/skill/<name>.html

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="${REPO_ROOT}/skills"
OUTPUT_DIR="${REPO_ROOT}/docs/skill"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok() { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*"; }

# Create output directory
mkdir -p "$OUTPUT_DIR"

# HTML template function
generate_html() {
    local name="$1"
    local description="$2"
    local content="$3"
    local guides="$4"
    local lines="$5"

    cat << HTMLEOF
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${name} — Another Agent Skills</title>
<meta name="description" content="${description}">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Newsreader:opsz,wght@6..72,400;6..72,600;6..72,700&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="../css/style.css?v=2">
<link rel="stylesheet" href="../css/docs.css">
</head>
<body>
<a href="#main" class="skip-link">Skip to content</a>

<header class="header" id="top">
  <nav class="header__nav container">
    <a href="../../index.html" class="header__logo"><span class="header__logo-text">Another Agent Skills</span></a>
    <ul class="header__links">
      <li><a href="../../index.html">Home</a></li>
      <li><a href="../index.html">Docs</a></li>
      <li><a href="https://github.com/juandelossantos/another-agent-skills" target="_blank" rel="noopener">GitHub →</a></li>
    </ul>
    <div class="header__controls">
      <button class="header__control header__lang" data-action="lang">ES</button>
      <button class="header__control header__theme" data-action="theme">☾</button>
    </div>
  </nav>
</header>

<main class="docs" id="main">
  <aside class="docs__sidebar">
    <p class="sidebar__title">Docs</p>
    <nav>
      <ul class="sidebar__nav">
        <li><a href="../index.html" class="sidebar__link">Overview</a></li>
        <li><a href="../getting-started.html" class="sidebar__link">Getting Started</a></li>
        <li><a href="../lifecycle.html" class="sidebar__link">Lifecycle</a></li>
        <li><a href="../skills.html" class="sidebar__link sidebar__link--active">Skills</a></li>
        <li><a href="../enforcement.html" class="sidebar__link">Enforcement</a></li>
        <li><a href="../philosophy.html" class="sidebar__link">Philosophy</a></li>
        <li><a href="../design-review.html" class="sidebar__link">Design Review</a></li>
        <li><a href="../rules.html" class="sidebar__link">Rules</a></li>
        <li><a href="../agents.html" class="sidebar__link">Agents</a></li>
        <li><a href="../customization.html" class="sidebar__link">Customization</a></li>
      </ul>
    </nav>
  </aside>

  <div class="docs__content">
    <div class="docs__breadcrumb"><a href="../index.html">Docs</a> <span>›</span> <a href="../skills.html">Skills</a> <span>›</span> ${name}</div>

    <h1>${name}</h1>
    <p style="color: var(--text-secondary); font-size: 1.1rem;">${description}</p>

    <div style="display: flex; gap: var(--space-md); margin-bottom: var(--space-xl); flex-wrap: wrap;">
      <span class="skill-card__badge">${lines} lines</span>
${guides}
    </div>

    <div class="docs__skill-content">
${content}
    </div>

    <div class="docs__nav">
      <a href="../skills.html" class="docs__nav-link">
        <span class="docs__nav-label">← Back</span>
        <span class="docs__nav-title">Skills Catalog</span>
      </a>
    </div>
  </div>

  <aside class="docs__toc">
    <p class="toc__title">On this page</p>
    <ul class="toc__list"></ul>
  </aside>
</main>

<script src="../js/docs.js"></script>
</body>
</html>
HTMLEOF
}

# Process each skill
count=0
for skill_dir in "${SKILLS_DIR}"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_file="${skill_dir}SKILL.md"
    [ -f "$skill_file" ] || continue

    name=$(basename "$skill_dir")

    # Extract description from frontmatter
    description=$(sed -n '/^description:/,/^---/p' "$skill_file" | grep -v "^description:" | grep -v "^---" | head -1 | sed 's/^  //' | sed 's/^> //' | xargs 2>/dev/null || true)

    # Fallback description if empty
    if [ -z "$description" ]; then
        description="Skill: ${name}"
    fi

    # Count lines
    lines=$(wc -l < "$skill_file")

    # Check for guides
    guides=""
    guide_count=0
    for guide in "${skill_dir}"*-GUIDE.md "${skill_dir}"guides/*.md; do
        [ -f "$guide" ] || continue
        guide_name=$(basename "$guide" .md)
        guides="${guides}      <span class=\"skill-card__badge\">guide: ${guide_name}</span>
"
        guide_count=$((guide_count + 1))
    done

    # Extract content (skip frontmatter, convert markdown-like to HTML)
    content=$(sed '1,/^---$/d' "$skill_file" | sed '1,/^---$/d' | \
        sed 's/^## \(.*\)/<h2 id="\L\1">\1<\/h2>/g' | \
        sed 's/^### \(.*\)/<h3>\1<\/h3>/g' | \
        sed 's/^#### \(.*\)/<h4>\1<\/h4>/g' | \
        sed 's/^\*\*\(.*\)\*\*/<strong>\1<\/strong>/g' | \
        sed 's/`\(.*\)`/<code>\1<\/code>/g' | \
        sed 's/^- \(.*\)/<li>\1<\/li>/g' | \
        sed '/^<li>/s/^/<ul>\n/; /^<\/li>/{n;s/^$/<\/ul>/}' | \
        sed 's/^> \(.*\)/<blockquote>\1<\/blockquote>/g' | \
        sed '/^$/s/^/<br>/')

    # Generate HTML
    output_file="${OUTPUT_DIR}/${name}.html"
    generate_html "$name" "$description" "$content" "$guides" "$lines" > "$output_file"

    count=$((count + 1))
    ok "${name} (${lines} lines, ${guide_count} guides)"
done

echo ""
ok "Generated ${count} skill pages in ${OUTPUT_DIR}/"
