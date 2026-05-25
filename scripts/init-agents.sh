#!/usr/bin/env bash
# init-agents-merge.sh — Smart merge of AGENTS.md/CLAUDE.md with Another Agent Skills rules
# Part of another-agent-skills (github.com/juandelossantos/another-agent-skills)
#
# Philosophy: Our rules ADD TO your existing workflow, they do not replace it.
# If you have an existing AGENTS.md or CLAUDE.md, we merge our skill-driven
# rules into it rather than overwriting. Your project-specific context is preserved.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_SOURCE="${SCRIPT_DIR}/../AGENTS.md"
DELIMITER_BEGIN="# >>> another-agent-skills-rules"
DELIMITER_END="# <<< another-agent-skills-rules"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[init-agents]${NC} $*"; }
ok() { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }

# Detect existing agent config files
detect_target() {
    local candidates=(
        "./AGENTS.md"
        "./CLAUDE.md"
        "./.cursorrules"
        "./.claude/CLAUDE.md"
        "./.opencode/AGENTS.md"
    )
    
    for candidate in "${candidates[@]}"; do
        if [[ -f "$candidate" ]]; then
            echo "$candidate"
            return 0
        fi
    done
    
    echo ""
    return 0
}

# Check if file already contains our delimiters
has_our_rules() {
    local file="$1"
    grep -q "$DELIMITER_BEGIN" "$file" 2>/dev/null
}

# Backup existing file
backup_file() {
    local file="$1"
    local backup="${file}.backup.$(date +%Y%m%d%H%M%S)"
    cp "$file" "$backup"
    echo "$backup"
}

# Append our rules to existing file with delimiters
merge_into_file() {
    local target="$1"
    
    if has_our_rules "$target"; then
        ok "Another Agent Skills rules already present in $(basename "$target"). Skipping."
        return 0
    fi
    
    local backup
    backup=$(backup_file "$target")
    warn "Found existing $(basename "$target"). Making backup: $(basename "$backup")"
    
    cat >> "$target" << BLOCK

---

${DELIMITER_BEGIN}
# The following rules are from Another Agent Skills (github.com/juandelossantos/another-agent-skills)
# These rules ADD TO your existing workflow, they do not replace it.
# If there are conflicts between your existing rules and ours, follow BOTH:
# - Your project-specific rules take priority for project details
# - Our skill-driven rules take priority for workflow and quality
${DELIMITER_END}

BLOCK
    
    cat "$AGENTS_SOURCE" >> "$target"
    
    cat >> "$target" << BLOCK

${DELIMITER_BEGIN}
# End of Another Agent Skills rules
${DELIMITER_END}
BLOCK
    
    ok "Merged Another Agent Skills rules into $(basename "$target")"
    log "Your original content is preserved. Backup: $(basename "$backup")"
}

# Main logic
main() {
    local existing_target
    existing_target=$(detect_target)
    
    if [[ -n "$existing_target" ]]; then
        merge_into_file "$existing_target"
    else
        # No existing agent config → copy normally
        cp "$AGENTS_SOURCE" "./AGENTS.md"
        ok "Created AGENTS.md with Another Agent Skills rules"
    fi
}

main "$@"
