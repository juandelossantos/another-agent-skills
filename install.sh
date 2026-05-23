#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Another Agent Skills — Global OpenCode Installer
# =============================================================================
# One-command setup for production-grade AI agent skills.
#   - 23 official skills from addyosmani/agent-skills
#   - Custom skills from this repo (e.g., visual-frontend-mastery)
#   - Daily auto-update, shell aliases, and idempotent installs.
#
# Usage:
#   bash install.sh
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

REMOTE_REPO="https://github.com/addyosmani/agent-skills.git"
REMOTE_DIR="${HOME}/.config/opencode/.agent-skills-remote"
GLOBAL_SKILLS_DIR="${HOME}/.config/opencode/skills"
ZSHRC="${HOME}/.zshrc"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ---------------------------------------------------------------------------
check_prerequisites() {
    info "Checking prerequisites..."
    if ! command -v git &>/dev/null; then
        error "git is required but not installed. Aborting."
        exit 1
    fi
    if ! command -v bash &>/dev/null; then
        error "bash is required but not installed. Aborting."
        exit 1
    fi
    mkdir -p "${HOME}/.config/opencode"
    ok "Prerequisites met."
}

# ---------------------------------------------------------------------------
setup_remote_skills() {
    info "Setting up official agent-skills repository..."
    if [[ -d "${REMOTE_DIR}/.git" ]]; then
        warn "Remote repo already exists. Pulling latest changes..."
        (cd "${REMOTE_DIR}" && git pull --quiet)
    else
        info "Cloning ${REMOTE_REPO} into ${REMOTE_DIR}..."
        rm -rf "${REMOTE_DIR}"
        git clone --depth=1 "${REMOTE_REPO}" "${REMOTE_DIR}"
    fi
    ok "Official skills updated."
}

# ---------------------------------------------------------------------------
link_remote_skills() {
    info "Linking official skills into global directory..."
    mkdir -p "${GLOBAL_SKILLS_DIR}"
    find "${GLOBAL_SKILLS_DIR}" -maxdepth 1 -type l ! -exec test -e {} \; -delete 2>/dev/null || true

    local count=0
    for skill_path in "${REMOTE_DIR}/.opencode/skills"/*/; do
        if [[ -d "${skill_path}" ]]; then
            local skill_name
            skill_name="$(basename "${skill_path}")"
            local target="${GLOBAL_SKILLS_DIR}/${skill_name}"
            if [[ -L "${target}" ]]; then rm "${target}"; fi
            if [[ -d "${target}" && ! -L "${target}" ]]; then continue; fi
            ln -s "${skill_path}" "${target}"
            ((count++)) || true
        fi
    done
    ok "Linked ${count} official skills."
}

# ---------------------------------------------------------------------------
install_custom_skills() {
    info "Installing custom skills from this repo..."
    local custom_dir="${SCRIPT_DIR}/skills"
    if [[ ! -d "${custom_dir}" ]]; then
        warn "No custom skills directory found at ${custom_dir}. Skipping."
        return 0
    fi

    for skill_path in "${custom_dir}"/*/; do
        if [[ -f "${skill_path}/SKILL.md" ]]; then
            local skill_name
            skill_name="$(basename "${skill_path}")"
            local target="${GLOBAL_SKILLS_DIR}/${skill_name}"
            rm -rf "${target}"
            cp -r "${skill_path}" "${target}"
            ok "Installed custom skill: ${skill_name}"
        fi
    done
}

# ---------------------------------------------------------------------------
update_shell_config() {
    info "Updating shell configuration (${ZSHRC})..."
    if [[ ! -f "${ZSHRC}" ]]; then
        warn "${ZSHRC} not found. Creating it."
        touch "${ZSHRC}"
    fi

    local backup="${ZSHRC}.backup.$(date +%Y%m%d%H%M%S)"
    cp "${ZSHRC}" "${backup}"
    ok "Backup created: ${backup}"

    local tmpfile
    tmpfile="$(mktemp)"
    awk '/# >>> another-agent-skills-config/{found=1; next} /# <<< another-agent-skills-config/{found=0; next} !found{print}' "${ZSHRC}" > "${tmpfile}"
    mv "${tmpfile}" "${ZSHRC}"

    cat >> "${ZSHRC}" << 'BLOCK'

# >>> another-agent-skills-config
# Managed by another-agent-skills/install.sh — do not edit manually.

# Agent Skills aliases
alias init-agents="cp /home/juandelossantos/dev/personal/another-agent-skills/AGENTS.md ./AGENTS.md"
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
# <<< another-agent-skills-config
BLOCK

    ok "Shell configuration updated."
}

# ---------------------------------------------------------------------------
verify_installation() {
    info "Verifying installation..."
    local total_skills
    total_skills="$(find "${GLOBAL_SKILLS_DIR}" -maxdepth 1 -mindepth 1 | wc -l)"

    echo ""
    echo "========================================"
    echo "  Another Agent Skills — Setup Complete"
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
    echo "To update manually:  update-global-skills"
    echo "========================================"
}

# ---------------------------------------------------------------------------
main() {
    echo ""
    echo "Another Agent Skills — Global Installer"
    echo "======================================"
    echo ""
    check_prerequisites
    setup_remote_skills
    link_remote_skills
    install_custom_skills
    update_shell_config
    verify_installation
    ok "All done!"
}

main "$@"
