#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Another Agent Skills — Global OpenCode Installer
# =============================================================================
# One-command setup for production-grade AI agent skills.
#   - 23 official skills from addyosmani/agent-skills
#   - Custom skills from this repo (e.g., frontend-web, frontend-mobile)
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
BASHRC="${HOME}/.bashrc"
LOCAL_BIN="${HOME}/.local/bin"

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
            
            # Backup before overwrite
            if [[ -d "${target}" ]]; then
                if [[ -L "${target}" ]]; then
                    # Symlink to official skill → save reference for restore
                    local official_target
                    official_target="$(readlink "${target}")"
                    echo "${skill_name}:${official_target}" >> "${GLOBAL_SKILLS_DIR}/.official-backups"
                    warn "Backed up official skill reference: ${skill_name} → ${official_target}"
                else
                    # Real directory (previous custom) → make timestamped backup
                    local backup
                    backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
                    cp -r "${target}" "${backup}"
                    warn "Backed up previous: ${skill_name} → $(basename "${backup}")"
                fi
            fi
            
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

    cat >> "${ZSHRC}" << BLOCK

# >>> another-agent-skills-config
# Managed by another-agent-skills/install.sh — do not edit manually.

# Store repo path for cross-machine portability
export ANOTHER_AGENT_SKILLS_DIR="${SCRIPT_DIR}"

# Agent Skills aliases
alias update-global-skills="cd \$HOME/.config/opencode/.agent-skills-remote && git pull && cd -"

# init-agents: copies or merges Another Agent Skills rules into current project
init-agents() {
    bash "\$ANOTHER_AGENT_SKILLS_DIR/scripts/init-agents.sh"
}

# Agent Skills auto-update on terminal open (max once per day)
_AGENT_SKILLS_REMOTE="\$HOME/.config/opencode/.agent-skills-remote"
_AGENT_SKILLS_LAST_PULL="\$_AGENT_SKILLS_REMOTE/.last-auto-pull"
if [[ -d "\$_AGENT_SKILLS_REMOTE" ]]; then
  if [[ ! -f "\$_AGENT_SKILLS_LAST_PULL" ]] || [[ "\$(date +%Y%m%d)" != "\$(cat "\$_AGENT_SKILLS_LAST_PULL")" ]]; then
    (cd "\$_AGENT_SKILLS_REMOTE" && git pull --quiet &)
    date +%Y%m%d > "\$_AGENT_SKILLS_LAST_PULL"
  fi
fi
# <<< another-agent-skills-config
BLOCK

    ok "Shell configuration updated."
}

# ---------------------------------------------------------------------------
create_global_scripts() {
    info "Creating global executable scripts..."
    
    # Ensure ~/.local/bin exists
    mkdir -p "${LOCAL_BIN}"
    
    # Ensure ~/.local/bin is in PATH for Zsh
    if [[ -f "${ZSHRC}" ]]; then
        if ! grep -q "export PATH=.*${LOCAL_BIN}" "${ZSHRC}"; then
            echo "export PATH=\"${LOCAL_BIN}:\$PATH\"" >> "${ZSHRC}"
            ok "Added ${LOCAL_BIN} to PATH in ${ZSHRC}"
        fi
    fi
    
    # Ensure ~/.local/bin is in PATH for Bash
    if [[ -f "${BASHRC}" ]]; then
        if ! grep -q "export PATH=.*${LOCAL_BIN}" "${BASHRC}"; then
            echo "export PATH=\"${LOCAL_BIN}:\$PATH\"" >> "${BASHRC}"
            ok "Added ${LOCAL_BIN} to PATH in ${BASHRC}"
        fi
    fi
    
    # Create init-agents executable
    cat > "${LOCAL_BIN}/init-agents" << 'EXEC_SCRIPT'
#!/usr/bin/env bash
# init-agents — Global wrapper for Another Agent Skills
# Created by install.sh. Works in any shell (Bash, Zsh, Fish, etc.)

set -euo pipefail

# Find the another-agent-skills repo
# Priority: 1) ANOTHER_AGENT_SKILLS_DIR env var, 2) ~/.config/opencode/.agent-skills-remote, 3) common locations
SKILLS_REPO=""

if [[ -n "${ANOTHER_AGENT_SKILLS_DIR:-}" && -d "${ANOTHER_AGENT_SKILLS_DIR}" ]]; then
    SKILLS_REPO="${ANOTHER_AGENT_SKILLS_DIR}"
fi

# Fallback: search common locations
if [[ -z "${SKILLS_REPO}" ]]; then
    for candidate in \
        "${HOME}/another-agent-skills" \
        "${HOME}/.config/opencode/another-agent-skills" \
        "${HOME}/.local/share/another-agent-skills" \
        "${HOME}/workspace/another-agent-skills" \
        "${HOME}/projects/another-agent-skills"; do
        if [[ -d "${candidate}" && -f "${candidate}/scripts/init-agents.sh" ]]; then
            SKILLS_REPO="${candidate}"
            break
        fi
    done
fi

if [[ -z "${SKILLS_REPO}" ]]; then
    echo "ERROR: Cannot find another-agent-skills repository." >&2
    echo "Please set ANOTHER_AGENT_SKILLS_DIR to the repo path:" >&2
    echo "  export ANOTHER_AGENT_SKILLS_DIR=/path/to/another-agent-skills" >&2
    exit 1
fi

# Run the actual init-agents script
bash "${SKILLS_REPO}/scripts/init-agents.sh"
EXEC_SCRIPT
    chmod +x "${LOCAL_BIN}/init-agents"
    ok "Created ${LOCAL_BIN}/init-agents"
    
    # Create update-global-skills executable
    cat > "${LOCAL_BIN}/update-global-skills" << 'EXEC_SCRIPT'
#!/usr/bin/env bash
# update-global-skills — Global wrapper for Another Agent Skills
# Created by install.sh. Works in any shell.

set -euo pipefail

_REMOTE="${HOME}/.config/opencode/.agent-skills-remote"

if [[ -d "${_REMOTE}" ]]; then
    echo "Pulling latest changes from addyosmani/agent-skills..."
    (cd "${_REMOTE}" && git pull)
    echo "Done."
else
    echo "ERROR: Remote repo not found at ${_REMOTE}" >&2
    echo "Run install.sh to set up." >&2
    exit 1
fi
EXEC_SCRIPT
    chmod +x "${LOCAL_BIN}/update-global-skills"
    ok "Created ${LOCAL_BIN}/update-global-skills"
    
    # Add current session PATH if not present
    if [[ ":${PATH}:" != *":${LOCAL_BIN}:"* ]]; then
        export PATH="${LOCAL_BIN}:${PATH}"
        ok "Added ${LOCAL_BIN} to current session PATH"
    fi
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

    for skill_name in engineering-fundamentals frontend-web frontend-pwa frontend-mobile frontend-desktop backend-api-mastery fullstack-shipping spec-driven-development git-init-and-versioning architecture-analysis dev-environment-audit project-health-check project-metrics user-onboarding; do
        if [[ -d "${GLOBAL_SKILLS_DIR}/${skill_name}" ]]; then
            ok "${skill_name} → INSTALLED"
        else
            error "${skill_name} → MISSING"
        fi
    done

    if [[ -L "${GLOBAL_SKILLS_DIR}/frontend-ui-engineering" ]]; then
        ok "frontend-ui-engineering  → LINKED"
    else
        warn "frontend-ui-engineering  → NOT LINKED"
    fi

    echo ""
    echo ""
    echo "Next steps:"
    echo "  1. Run:  source ${ZSHRC}   (or open a new terminal)"
    echo "  2. Test: ls ~/.config/opencode/skills/"
    echo "  3. Use:  init-agents  (in any project — works in any shell)"
    echo ""
    echo "Global scripts installed:"
    echo "  ${LOCAL_BIN}/init-agents         → Initialize agent rules in any project"
    echo "  ${LOCAL_BIN}/update-global-skills → Pull latest skill updates"
    echo ""
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
    create_global_scripts
    verify_installation
    ok "All done!"
}

main "$@"
