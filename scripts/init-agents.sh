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

# Create .sessionrc with purpose-driven defaults
# This enables per-project session configuration
# Used by AGENTS.md Rule 3 (Lifecycle) for purpose-driven skill routing
create_sessionrc() {
    local purpose="development"
    local user_profile="$HOME/.config/opencode/user-profile.json"
    
    if [[ -f "$user_profile" ]]; then
        local detected_purpose
        detected_purpose=$(jq -r '.session_defaults.default_purpose // "development"' "$user_profile" 2>/dev/null)
        if [[ -n "$detected_purpose" && "$detected_purpose" != "null" ]]; then
            purpose="$detected_purpose"
        fi
    fi
    
    cat > "./.sessionrc" << EOF
{
  "purpose": "$purpose",
  "skills_active": [],
  "mutation_approval": "manual",
  "notes": "Session configuration for this project. NOT git-tracked."
}
EOF
    
    ok "Created .sessionrc with purpose: $purpose"
    log "Add .sessionrc to .gitignore to keep it local-only."
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
    
    # Install pre-commit hook for Rule 12 mechanical enforcement
    install_precommit_hook
    
    # Create .sessionrc for purpose-driven sessions
    if [[ ! -f "./.sessionrc" ]]; then
        create_sessionrc
    else
        log ".sessionrc already exists. Skipping."
    fi
}

install_precommit_hook() {
    local hook_src="${SCRIPT_DIR}/git-hooks/pre-commit"
    local hook_dst="./.git/hooks/pre-commit"
    
    if [[ ! -f "${hook_src}" ]]; then
        warn "Pre-commit hook source not found at ${hook_src}. Skipping."
        return 0
    fi
    
    if [[ ! -d "./.git" ]]; then
        log "No .git directory. Skipping pre-commit hook installation."
        return 0
    fi
    
    mkdir -p "./.git/hooks"
    cp "${hook_src}" "${hook_dst}"
    chmod +x "${hook_dst}"
    ok "Installed pre-commit hook (${hook_dst})"
    log "Commits now require .git/COMMIT_APPROVED token from Commit Manifest Protocol."
}

main "$@"
