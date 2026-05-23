#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# OpenCode Global Skills Installer
# =============================================================================
# This script sets up global OpenCode skills on any machine.
# Run it once after cloning your dotfiles or this repository.
#
# What it does:
#   1. Clones addyosmani/agent-skills to ~/.config/opencode/.agent-skills-remote
#   2. Symlinks all skills into ~/.config/opencode/skills/
#   3. Copies your custom visual-frontend-mastery skill to the global directory
#   4. Adds/updates shell aliases and auto-update logic in ~/.zshrc
#
# Usage:
#   bash setup/install.sh
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

REMOTE_REPO="https://github.com/addyosmani/agent-skills.git"
REMOTE_DIR="${HOME}/.config/opencode/.agent-skills-remote"
GLOBAL_SKILLS_DIR="${HOME}/.config/opencode/skills"
ZSHRC="${HOME}/.zshrc"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ---------------------------------------------------------------------------
# Prerequisites
# ---------------------------------------------------------------------------
check_prerequisites() {
    info "Checking prerequisites..."

    if ! command -v git &>/dev/null; then
        error "git is required but not installed."
        exit 1
    fi

    if ! command -v bash &>/dev/null; then
        error "bash is required but not installed."
        exit 1
    fi

    # Ensure ~/.config/opencode exists
    mkdir -p "${HOME}/.config/opencode"

    ok "Prerequisites met."
}

# ---------------------------------------------------------------------------
# Step 1: Clone or update the remote agent-skills repo
# ---------------------------------------------------------------------------
setup_remote_skills() {
    info "Setting up remote agent-skills repository..."

    if [[ -d "${REMOTE_DIR}/.git" ]]; then
        warn "Remote repo already exists at ${REMOTE_DIR}. Pulling latest changes..."
        (cd "${REMOTE_DIR}" && git pull --quiet)
    else
        info "Cloning ${REMOTE_REPO} into ${REMOTE_DIR}..."
        rm -rf "${REMOTE_DIR}"
        git clone --depth=1 "${REMOTE_REPO}" "${REMOTE_DIR}"
    fi

    ok "Remote skills updated."
}

# ---------------------------------------------------------------------------
# Step 2: Symlink all skills from remote into global skills dir
# ---------------------------------------------------------------------------
link_remote_skills() {
    info "Linking remote skills into global directory..."

    mkdir -p "${GLOBAL_SKILLS_DIR}"

    # Remove broken symlinks first
    find "${GLOBAL_SKILLS_DIR}" -maxdepth 1 -type l ! -exec test -e {} \; -delete 2>/dev/null || true

    # Create/update symlinks
    local count=0
    for skill_path in "${REMOTE_DIR}/.opencode/skills"/*/; do
        if [[ -d "${skill_path}" ]]; then
            local skill_name
            skill_name="$(basename "${skill_path}")"
            local target="${GLOBAL_SKILLS_DIR}/${skill_name}"

            # Remove existing symlink or empty dir to avoid conflicts
            if [[ -L "${target}" ]]; then
                rm "${target}"
            elif [[ -d "${target}" && ! -L "${target}" ]]; then
                # If a real directory exists (e.g., visual-frontend-mastery), keep it
                continue
            fi

            ln -s "${skill_path}" "${target}"
            ((count++)) || true
        fi
    done

    ok "Linked ${count} remote skills."
}

# ---------------------------------------------------------------------------
# Step 3: Install custom visual-frontend-mastery skill
# ---------------------------------------------------------------------------
install_custom_skill() {
    info "Installing custom visual-frontend-mastery skill..."

    local custom_skill_src="${REPO_ROOT}/setup/opencode/visual-frontend-mastery"
    local custom_skill_dest="${GLOBAL_SKILLS_DIR}/visual-frontend-mastery"

    if [[ ! -f "${custom_skill_src}/SKILL.md" ]]; then
        error "Custom skill not found at ${custom_skill_src}/SKILL.md"
        exit 1
    fi

    # Remove existing symlink or dir
    rm -rf "${custom_skill_dest}"
    cp -r "${custom_skill_src}" "${custom_skill_dest}"

    ok "Custom skill installed at ${custom_skill_dest}."
}

# ---------------------------------------------------------------------------
# Step 4: Update ~/.zshrc with aliases and auto-update
# ---------------------------------------------------------------------------
update_shell_config() {
    info "Updating shell configuration (${ZSHRC})..."

    if [[ ! -f "${ZSHRC}" ]]; then
        warn "${ZSHRC} not found. Creating it..."
        touch "${ZSHRC}"
    fi

    # Backup
    local backup="${ZSHRC}.backup.$(date +%Y%m%d%H%M%S)"
    cp "${ZSHRC}" "${backup}"
    ok "Backup created: ${backup}"

    # Remove old block if present (idempotent)
    local tmpfile
    tmpfile="$(mktemp)"
    awk '/# >>> opencode-skills-config/{found=1; next} /# <<< opencode-skills-config/{found=0; next} !found{print}' "${ZSHRC}" > "${tmpfile}"
    mv "${tmpfile}" "${ZSHRC}"

    # Append new block
    cat >> "${ZSHRC}" << 'BLOCK'

# >>> opencode-skills-config
# Managed by agent-skills/setup/install.sh — do not edit manually.

# Agent Skills aliases
alias init-agents="cp $HOME/.config/opencode/.agent-skills-remote/AGENTS.md ./AGENTS.md"
alias update-global-skills="cd $HOME/.config/opencode/.agent-skills-remote && git pull && cd -"

# Agent Skills auto-update on terminal open (max once per day)
_AGENT_SKILLS_REMOTE="$HOME/.config/opencode/.agent-skills-remote"
_AGENT_SKILLS_LAST_PULL="$_AGENT_SKILLS_REMOTE/.last-auto-pull"
if [[ -d "$_AGENT_SKILLS_REMOTE" ]]; then
  if [[ ! -f "$_AGENT_SKILLS_LAST_PULL" ]] || [[ "$(date +%Y%m%d)" != "$(cat "$_AGENT_SKILLS_LAST_PULL")" ]]; then
    (cd "$_AGENT_SKILLS_REMOTE" && git pull --quiet &)
    date +%Y%m%d > "$_AGENT_SKILLS_LAST_PULL"
  fi
fi
# <<< opencode-skills-config
BLOCK

    ok "Shell configuration updated."
}

# ---------------------------------------------------------------------------
# Step 5: Verification
# ---------------------------------------------------------------------------
verify_installation() {
    info "Verifying installation..."

    local total_skills
    total_skills="$(find "${GLOBAL_SKILLS_DIR}" -maxdepth 1 -mindepth 1 | wc -l)"

    echo ""
    echo "========================================"
    echo "  OpenCode Global Skills Setup"
    echo "========================================"
    echo ""
    echo "Remote repo:     ${REMOTE_DIR}"
    echo "Global skills:   ${GLOBAL_SKILLS_DIR}"
    echo "Total skills:    ${total_skills}"
    echo ""

    if [[ -d "${GLOBAL_SKILLS_DIR}/visual-frontend-mastery" ]]; then
        ok "visual-frontend-mastery  → INSTALLED"
    else
        error "visual-frontend-mastery  → MISSING"
    fi

    if [[ -L "${GLOBAL_SKILLS_DIR}/frontend-ui-engineering" ]]; then
        ok "frontend-ui-engineering  → LINKED"
    else
        warn "frontend-ui-engineering  → NOT LINKED"
    fi

    echo ""
    echo "Next steps:"
    echo "  1. Run:  source ${ZSHRC}"
    echo "  2. Test: ls ~/.config/opencode/skills/"
    echo "  3. Use:  init-agents  (in any project to copy AGENTS.md)"
    echo ""
    echo "To update skills manually:  update-global-skills"
    echo "========================================"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
    echo ""
    echo "OpenCode Global Skills Installer"
    echo "================================"
    echo ""

    check_prerequisites
    setup_remote_skills
    link_remote_skills
    install_custom_skill
    update_shell_config
    verify_installation

    ok "Installation complete!"
}

main "$@"
