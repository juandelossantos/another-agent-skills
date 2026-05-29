#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Another Agent Skills — Global OpenCode Installer
# =============================================================================
# One-command setup for production-grade AI agent skills.
#   - 23 official skills from addyosmani/agent-skills
#   - Custom skills from this repo (e.g., frontend-web, frontend-mobile)
#   - Daily auto-update, shell aliases (Zsh/Bash/Fish), and idempotent installs.
#   - Windows: install.ps1
#
# Usage:
#   bash install.sh                        # Full skill installation
#   bash install.sh --agent claude         # Install Claude Code adapter
#   bash install.sh --agent cursor         # Install Cursor adapter
#   bash install.sh --agent all            # Install all adapters
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

REMOTE_REPO="https://github.com/addyosmani/agent-skills.git"
REMOTE_DIR="${HOME}/.config/opencode/.agent-skills-remote"
GLOBAL_SKILLS_DIR="${HOME}/.config/opencode/skills"
ZSHRC="${HOME}/.zshrc"
BASHRC="${HOME}/.bashrc"
FISH_CONFIG="${HOME}/.config/fish/config.fish"
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
install_opencode_plugin() {
    info "Installing OpenCode agent-discipline plugin..."
    local plugin_src="${SCRIPT_DIR}/.opencode/plugins/agent-discipline"
    local plugin_dst="${HOME}/.config/opencode/plugins/agent-discipline"

    if [[ ! -d "${plugin_src}" ]]; then
        warn "Plugin source not found at ${plugin_src}. Skipping."
        return 0
    fi

    mkdir -p "${HOME}/.config/opencode/plugins"

    if [[ -d "${plugin_dst}" ]]; then
        if [[ -L "${plugin_dst}" ]]; then
            rm "${plugin_dst}"
        else
            mv "${plugin_dst}" "${plugin_dst}.backup.$(date +%Y%m%d%H%M%S)"
            warn "Backed up existing plugin: ${plugin_dst}"
        fi
    fi

    cp -r "${plugin_src}" "${plugin_dst}"

    if [[ -f "${plugin_dst}/package.json" ]]; then
        info "Building plugin TypeScript..."
        (cd "${plugin_dst}" && npm install --silent 2>/dev/null && npm run build --silent 2>/dev/null || true)
    fi

    ok "Installed agent-discipline plugin → ${plugin_dst}"
}

# ---------------------------------------------------------------------------
# Zsh/Bash shell config block (same POSIX-compatible syntax)
_write_posix_block() {
    local file="$1"
    cat >> "${file}" << 'POSIX'

# >>> another-agent-skills-config
# Managed by another-agent-skills/install.sh — do not edit manually.

export ANOTHER_AGENT_SKILLS_DIR="__SCRIPT_DIR__"

# Aliases
alias init-agents='bash "$ANOTHER_AGENT_SKILLS_DIR/scripts/init-agents.sh"'
alias update-global-skills='cd "$HOME/.config/opencode/.agent-skills-remote" && git pull && cd -'

# Auto-update (max once per day)
_AAS_REMOTE="$HOME/.config/opencode/.agent-skills-remote"
_AAS_LAST="$_AAS_REMOTE/.last-auto-pull"
if [ -d "$_AAS_REMOTE" ]; then
  if [ ! -f "$_AAS_LAST" ] || [ "$(date +%Y%m%d)" != "$(cat "$_AAS_LAST")" ]; then
    (cd "$_AAS_REMOTE" && git pull --quiet &)
    date +%Y%m%d > "$_AAS_LAST"
  fi
fi
# <<< another-agent-skills-config
POSIX
    sed -i "s|__SCRIPT_DIR__|${SCRIPT_DIR}|" "${file}"
}

# Fish shell config block
_write_fish_block() {
    local file="$1"
    cat >> "${file}" << FISH

# >>> another-agent-skills-config
# Managed by another-agent-skills/install.sh — do not edit manually.

set -gx ANOTHER_AGENT_SKILLS_DIR "${SCRIPT_DIR}"

# Aliases
alias init-agents="bash \$ANOTHER_AGENT_SKILLS_DIR/scripts/init-agents.sh"
alias update-global-skills="cd \$HOME/.config/opencode/.agent-skills-remote; and git pull; and cd -"

# Auto-update (max once per day)
set -g _AAS_REMOTE \$HOME/.config/opencode/.agent-skills-remote
set -g _AAS_LAST \$_AAS_REMOTE/.last-auto-pull
if test -d \$_AAS_REMOTE
  if not test -f \$_AAS_LAST; or test (date +%Y%m%d) != (cat \$_AAS_LAST)
    cd \$_AAS_REMOTE; and git pull --quiet &
    date +%Y%m%d > \$_AAS_LAST
  end
end
# <<< another-agent-skills-config
FISH
}

# ---------------------------------------------------------------------------
_update_single_shell_config() {
    local file="$1"
    local name="$2"
    local writer="$3"

    if [[ ! -f "${file}" ]]; then
        warn "${file} not found. Creating it."
        mkdir -p "$(dirname "${file}")"
        touch "${file}"
    fi

    local backup="${file}.backup.$(date +%Y%m%d%H%M%S)"
    cp "${file}" "${backup}"
    ok "Backed up ${name} → $(basename "${backup}")"

    local tmpfile
    tmpfile="$(mktemp)"
    awk '/# >>> another-agent-skills-config/{found=1; next} /# <<< another-agent-skills-config/{found=0; next} !found{print}' "${file}" > "${tmpfile}"
    mv "${tmpfile}" "${file}"

    "${writer}" "${file}"
    ok "${name} configuration updated."
}

update_shell_config() {
    info "Detecting shell configurations..."

    # Always update ~/.local/bin PATH (shell-agnostic)
    for rc in "${ZSHRC}" "${BASHRC}"; do
        if [[ -f "${rc}" ]]; then
            if ! grep -q "export PATH=.*${LOCAL_BIN}" "${rc}" 2>/dev/null; then
                echo "export PATH=\"${LOCAL_BIN}:\$PATH\"" >> "${rc}"
                ok "Added ${LOCAL_BIN} to PATH in $(basename "${rc}")"
            fi
        fi
    done

    # Update detected shell config files
    local count=0
    if [[ -f "${ZSHRC}" ]] || [[ "${SHELL:-}" == */zsh ]]; then
        _update_single_shell_config "${ZSHRC}" "Zsh (.zshrc)" _write_posix_block
        ((count++))
    fi
    if [[ -f "${BASHRC}" ]] || [[ "${SHELL:-}" == */bash ]]; then
        _update_single_shell_config "${BASHRC}" "Bash (.bashrc)" _write_posix_block
        ((count++))
    fi
    if [[ -f "${FISH_CONFIG}" ]] || [[ "${SHELL:-}" == */fish ]]; then
        _update_single_shell_config "${FISH_CONFIG}" "Fish (config.fish)" _write_fish_block
        ((count++))
    fi

    if [[ "${count}" -eq 0 ]]; then
        # Fallback: always update .zshrc
        _update_single_shell_config "${ZSHRC}" "Zsh (.zshrc)" _write_posix_block
        ok "No shell config detected. Created default .zshrc."
    fi

    ok "Shell configuration updated (${count} file(s))."
}

# ---------------------------------------------------------------------------
create_global_scripts() {
    info "Creating global executable scripts..."
    
    # Ensure ~/.local/bin exists
    mkdir -p "${LOCAL_BIN}"
    
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
    echo "  1. Reload your shell: source ~/.zshrc (Zsh), source ~/.bashrc (Bash),"
    echo "     or exec fish (Fish). Or open a new terminal."
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
AGENT_USAGE="Usage: bash install.sh --agent {claude|cursor|kiro|all}"

install_agent_adapter() {
    local agent="$1"
    local template_dir="${SCRIPT_DIR}/templates"
    local dest=""

    if [[ ! -d "${template_dir}" ]]; then
        error "Templates directory not found at ${template_dir}"
        return 1
    fi

    case "${agent}" in
        claude)
            info "Installing Claude Code adapter..."
            # Copy CLAUDE.md
            dest="${PWD}/CLAUDE.md"
            if [[ ! -f "${template_dir}/CLAUDE.md" ]]; then
                error "Template CLAUDE.md not found in ${template_dir}"
                return 1
            fi
            if [[ -f "${dest}" ]]; then
                cp "${dest}" "${dest}.backup.$(date +%Y%m%d%H%M%S)"
                warn "Backed up existing CLAUDE.md"
            fi
            cp "${template_dir}/CLAUDE.md" "${dest}"
            ok "Installed CLAUDE.md → ${dest}"
            # Copy Claude plugin
            if [[ -d "${SCRIPT_DIR}/.claude-plugin" ]]; then
                cp -r "${SCRIPT_DIR}/.claude-plugin" "${PWD}/"
                ok "Installed .claude-plugin/ → ${PWD}/"
            fi
            # Copy scripts/ (required by hooks)
            if [[ -d "${SCRIPT_DIR}/scripts" ]]; then
                if [[ ! -d "${PWD}/scripts" ]]; then
                    mkdir -p "${PWD}/scripts"
                fi
                cp "${SCRIPT_DIR}/scripts/"*.sh "${PWD}/scripts/"
                chmod +x "${PWD}/scripts/"*.sh
                ok "Installed scripts/ → ${PWD}/scripts/"
            fi
            ;;
        cursor)
            info "Installing Cursor adapter..."
            # Copy .cursorrules
            dest="${PWD}/.cursorrules"
            if [[ ! -f "${template_dir}/.cursorrules" ]]; then
                error "Template .cursorrules not found in ${template_dir}"
                return 1
            fi
            if [[ -f "${dest}" ]]; then
                cp "${dest}" "${dest}.backup.$(date +%Y%m%d%H%M%S)"
                warn "Backed up existing .cursorrules"
            fi
            cp "${template_dir}/.cursorrules" "${dest}"
            ok "Installed .cursorrules → ${dest}"
            # Copy Cursor plugin
            if [[ -d "${SCRIPT_DIR}/.cursor-plugin" ]]; then
                cp -r "${SCRIPT_DIR}/.cursor-plugin" "${PWD}/"
                ok "Installed .cursor-plugin/ → ${PWD}/"
            fi
            # Copy scripts/ (required by hooks)
            if [[ -d "${SCRIPT_DIR}/scripts" ]]; then
                if [[ ! -d "${PWD}/scripts" ]]; then
                    mkdir -p "${PWD}/scripts"
                fi
                cp "${SCRIPT_DIR}/scripts/"*.sh "${PWD}/scripts/"
                chmod +x "${PWD}/scripts/"*.sh
                ok "Installed scripts/ → ${PWD}/scripts/"
            fi
            ;;
        kiro)
            info "Installing Kiro adapter..."
            # Copy Kiro hooks config
            if [[ -d "${SCRIPT_DIR}/.kiro" ]]; then
                mkdir -p "${PWD}/.kiro"
                cp -r "${SCRIPT_DIR}/.kiro/hooks" "${PWD}/.kiro/"
                ok "Installed .kiro/hooks/ → ${PWD}/.kiro/"
            else
                warn "Kiro hooks directory not found"
            fi
            # Copy scripts/ (required by hooks)
            if [[ -d "${SCRIPT_DIR}/scripts" ]]; then
                if [[ ! -d "${PWD}/scripts" ]]; then
                    mkdir -p "${PWD}/scripts"
                fi
                cp "${SCRIPT_DIR}/scripts/"*.sh "${PWD}/scripts/"
                chmod +x "${PWD}/scripts/"*.sh
                ok "Installed scripts/ → ${PWD}/scripts/"
            fi
            ;;
        *)
            echo "${AGENT_USAGE}"
            echo ""
            echo "  claude   Install CLAUDE.md + .claude-plugin/ (Claude Code adapter)"
            echo "  cursor   Install .cursorrules + .cursor-plugin/ (Cursor adapter)"
            echo "  kiro     Install .kiro/hooks/ (Kiro adapter)"
            echo "  all      Install all adapters"
            return 1
            ;;
    esac
}

install_all_adapters() {
    local errors=0
    install_agent_adapter claude || ((errors++))
    install_agent_adapter cursor || ((errors++))
    install_agent_adapter kiro || ((errors++))
    return "${errors}"
}

# ---------------------------------------------------------------------------
main() {
    local current_version
    current_version=$(cat "${SCRIPT_DIR}/VERSION" 2>/dev/null || echo "dev")
    echo ""
    echo "Another Agent Skills — Global Installer"
    echo "======================================"
    echo "  v${current_version}"
    echo ""
    check_prerequisites
    setup_remote_skills
    link_remote_skills
    install_custom_skills
    install_opencode_plugin
    update_shell_config
    create_global_scripts
    verify_installation
    ok "All done!"
}

# Agent-only mode
if [[ "${1:-}" == "--agent" ]]; then
    if [[ -z "${2:-}" ]]; then
        echo "${AGENT_USAGE}"
        exit 1
    fi
    echo ""
    echo "Another Agent Skills — Agent Adapter Installer"
    echo "=============================================="
    echo ""
    if [[ "$2" == "all" ]]; then
        install_all_adapters
    else
        install_agent_adapter "$2"
    fi
    _agent_rc=$?
    if [[ "${_agent_rc}" -eq 0 ]]; then
        echo ""
        echo "========================================"
        echo "  Agent Adapter — Setup Complete"
        echo "========================================"
        echo ""
        echo "To remove, delete the copied file from your project root."
    fi
    exit "${_agent_rc}"
fi

main "$@"
