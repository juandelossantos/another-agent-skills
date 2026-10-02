#!/usr/bin/env bash
# init-agents-merge.sh — Smart merge of AGENTS.md/CLAUDE.md with Another Agent Skills rules
# Part of another-agent-skills (github.com/juandelossantos/another-agent-skills)
#
# Philosophy: Our rules ADD TO your existing workflow, they do not replace it.
# If you have an existing AGENTS.md or CLAUDE.md, we merge our skill-driven
# rules into it rather than overwriting. Your project-specific context is preserved.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Framework resolution (P9.7). The running init-agents IS the framework tree;
# pin AAS_DIR to it when valid, then let the shared resolver handle the rest.
# Nothing here ever links a project to $SCRIPT_DIR/.. (the dev clone).
if [ -z "${AAS_DIR:-}" ] && [ -f "${SCRIPT_DIR}/../VERSION" ] && [ -d "${SCRIPT_DIR}/../scripts/git-hooks" ]; then
    AAS_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
fi
# shellcheck source=aas-resolve.sh
. "${SCRIPT_DIR}/aas-resolve.sh" 2>/dev/null || true
if [ -z "${AAS_DIR:-}" ]; then
    echo "[init-agents] ERROR: could not resolve the Another Agent Skills framework root." >&2
    echo "[init-agents] Install it (bootstrap.sh / aas install) or set ANOTHER_AGENT_SKILLS_DIR." >&2
    exit 1
fi
AGENTS_SOURCE="${AAS_DIR}/AGENTS.md"
DELIMITER_BEGIN="# >>> another-agent-skills-rules"
DELIMITER_END="# <<< another-agent-skills-rules"
AAS_CONFIG_DIR="./.aas"
AAS_BACKUP_DIR="${AAS_CONFIG_DIR}/backups"
BACKUP_KEEP=5

# Shared agent detection (detect_agents / list_agents)
# shellcheck source=agent-detect.sh
source "${SCRIPT_DIR}/agent-detect.sh"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "${BLUE}[init-agents]${NC} $*"; }
ok() { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
plan() { echo -e "${CYAN}[dry-run]${NC} would $*"; }

# Portable: check if two paths resolve to the same filesystem entry
# Uses cd+pwd -P instead of readlink -f for macOS compatibility
_same_path() {
    local src="$1" dst="$2"
    local src_abs dst_abs
    src_abs="$(cd "$(dirname "$src")" 2>/dev/null && pwd -P)/$(basename "$src")" || return 1
    dst_abs="$(cd "$(dirname "$dst")" 2>/dev/null && pwd -P)/$(basename "$dst")" || return 1
    [[ "$src_abs" = "$dst_abs" ]]
}

WITH_SELF_IMPROVEMENT=true
DRY_RUN=false
REPAIR=false
FORCE=false
WITH_SKILLS=false

usage() {
  echo "Usage: bash init-agents.sh [OPTIONS] [SUBCOMMAND]"
  echo ""
  echo "Subcommands:"
  echo "  sync-hooks                 Re-install the portable hook shims in .git/hooks/"
  echo "  check-env                  Print detected agents, the OpenCode version, and"
  echo "                             the agent-discipline plugin state"
  echo "  list-agents                Print every supported agent id"
  echo ""
  echo "Options:"
  echo "  --dry-run                  Print what would change; mutate nothing"
  echo "  --repair                   Migrate a legacy project (absolute/broken symlinks)"
  echo "                             to the portable form, without losing data"
  echo "  --force                    Allow replacing custom hooks during --repair"
  echo "  --with-skills              Copy the skills into the project (self-contained)"
  echo "  --skip-self-improvement    Skip scaffolding the self-improvement loop"
  echo "                             (By default, init-agents installs: .audit-config.json,"
  echo "                             scripts/audit-project.sh, skills/self-improvement/,"
  echo "                             PATTERNS.md, ANTI-PATTERNS.md, ADRs/, generate-adr.sh)"
  echo "  --help|-h                  Show this help"
  exit 0
}

# ─── Subcommand handling ───
SUBCOMMAND=""
for arg in "$@"; do
  case "$arg" in
    sync-hooks) SUBCOMMAND="sync-hooks" ;;
    check-env|--check-env) SUBCOMMAND="check-env" ;;
    list-agents|--list-agents) SUBCOMMAND="list-agents" ;;
    --skip-self-improvement) WITH_SELF_IMPROVEMENT=false ;;
    --dry-run) DRY_RUN=true ;;
    --repair) REPAIR=true ;;
    --force) FORCE=true ;;
    --with-skills) WITH_SKILLS=true ;;
    --help|-h) usage ;;
    *) warn "Unknown option: $arg. Run --help for usage."; exit 2 ;;
  esac
done

# ─── sync-hooks subcommand (executed after the helpers below are defined) ───

# ─── check-env subcommand ───
# Report the OpenCode version and the agent-discipline plugin state so a user on
# OpenCode v2 can tell whether their installed plugin actually loads.
if [ "$SUBCOMMAND" = "list-agents" ]; then
  list_agents
  exit 0
fi

if [ "$SUBCOMMAND" = "check-env" ]; then
  GLOBAL_DIR="${AGENT_SKILLS_DIR:-${HOME}/.config/opencode}"
  PLUGINS_DIR="${GLOBAL_DIR}/plugins"

  DETECTED_AGENTS="$(detect_agents | paste -sd, -)"
  echo "agents=${DETECTED_AGENTS:-none}"

  # Per-agent version — what the installer gates on.
  while IFS= read -r _a; do
    [ -z "${_a}" ] && continue
    _v="$(agent_version "$(agent_binary "${_a}")")"
    echo "agent:${_a}=${_v}"
    _n="$(agent_support_note "${_a}" "${_v}")"
    [ -n "${_n}" ] && warn "${_n}"
  done <<< "$(detect_agents)"

  OC_VERSION=""
  if command -v opencode >/dev/null 2>&1; then
    OC_VERSION="$(opencode --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  fi
  echo "opencode=${OC_VERSION:-not-found}"

  if [ -d "${PLUGINS_DIR}/agent-discipline" ]; then
    if [ -f "${PLUGINS_DIR}/agent-discipline/plugin.json" ] \
       || [ -d "${PLUGINS_DIR}/agent-discipline/src" ] \
       || [ -d "${PLUGINS_DIR}/agent-discipline/dist" ]; then
      echo "agent-discipline=legacy"
      warn "Legacy agent-discipline plugin detected at ${PLUGINS_DIR}/agent-discipline (v1-only artifacts)."
      warn "Fix: bash install.sh --plugin-only"
    else
      echo "agent-discipline=dual-contract"
    fi
  else
    echo "agent-discipline=not-installed"
  fi

  if [ -d "${PLUGINS_DIR}" ]; then
    DUPLICATES="$(find "${PLUGINS_DIR}" -maxdepth 1 -type d -name 'agent-discipline*' 2>/dev/null | wc -l | tr -d ' ')"
  else
    # No plugins dir yet (fresh machine): zero duplicates. Guard the find —
    # `set -o pipefail` + a missing dir would otherwise abort --check-env.
    DUPLICATES=0
  fi
  if [ "${DUPLICATES}" -gt 1 ]; then
    echo "agent-discipline-duplicates=${DUPLICATES}"
    warn "${DUPLICATES} agent-discipline dirs found — only one should load. Fix: bash install.sh --plugin-only"
  fi

  exit 0
fi

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

# Backup existing file under .aas/backups/ and prune old copies (P9.8).
backup_file() {
    local file="$1"
    local base
    base="$(basename "$file")"
    local backup="${AAS_BACKUP_DIR}/${base}.$(date +%Y%m%d%H%M%S)"
    if [ "$DRY_RUN" = true ]; then
        plan "back up ${file} → ${backup}"
        echo "$backup"
        return 0
    fi
    mkdir -p "$AAS_BACKUP_DIR"
    cp "$file" "$backup"
    # Prune: keep only the newest BACKUP_KEEP copies of this file.
    ls -1t "${AAS_BACKUP_DIR}/${base}."* 2>/dev/null | tail -n +"$((BACKUP_KEEP + 1))" | while IFS= read -r old; do
        rm -f "$old"
    done
    echo "$backup"
}

# Append our rules footer to existing file with delimiters
# Never appends the full AGENTS_SOURCE — only the attribution footer.
# The full rules are loaded dynamically by the agent framework via skills/.
merge_into_file() {
    local target="$1"
    
    if has_our_rules "$target"; then
        ok "Another Agent Skills rules already present in $(basename "$target"). Skipping."
        return 0
    fi

    if [ "$DRY_RUN" = true ]; then
        plan "back up $(basename "$target") and append the AAS rules footer"
        return 0
    fi

    local backup
    backup=$(backup_file "$target")
    warn "Found existing $(basename "$target"). Making backup: $(basename "$backup")"
    
    cat >> "$target" << 'FOOTER'

---

# >>> another-agent-skills-rules
# The following rules are from Another Agent Skills (github.com/juandelossantos/another-agent-skills)
# These rules ADD TO your existing workflow, they do not replace it.
# If there are conflicts between your existing rules and yours, follow BOTH:
# - Your project-specific rules take priority for project details
# - Our skill-driven rules take priority for workflow and quality
# <<< another-agent-skills-rules

FOOTER
    
    ok "Merged Another Agent Skills rules into $(basename "$target")"
    log "Your original content is preserved. Backup: $(basename "$backup")"
}

# Detect project stack and create STACK_CONFIG.md
# This provides commands to all skills (git-workflow, test-driven, etc.)
detect_stack_and_create_config() {
    if [[ -f "./STACK_CONFIG.md" ]]; then
        log "STACK_CONFIG.md already exists. Skipping."
        return 0
    fi

    local stack_type="unknown"
    local framework=""
    local runtime=""
    local test_cmd=""
    local lint_cmd=""
    local typecheck_cmd=""
    local build_cmd=""
    local dev_cmd=""
    local lockfile=""
    local auto_detected=false

    # === UNIVERSAL LOCKFILE DETECTION ===
    # Lockfiles are universal indicators of an ecosystem.
    # We detect the ecosystem from the lockfile, not from hardcoded stack names.

    if [[ -f "package-lock.json" ]] || [[ -f "yarn.lock" ]] || [[ -f "pnpm-lock.yaml" ]] || [[ -f "bun.lockb" ]]; then
        stack_type="node"
        runtime="node"
        lockfile="package-lock.json"
        [[ -f "yarn.lock" ]] && lockfile="yarn.lock"
        [[ -f "pnpm-lock.yaml" ]] && lockfile="pnpm-lock.yaml"
        [[ -f "bun.lockb" ]] && lockfile="bun.lockb"
        auto_detected=true
    elif [[ -f "Cargo.lock" ]]; then
        stack_type="rust"
        runtime="cargo"
        lockfile="Cargo.lock"
        auto_detected=true
    elif [[ -f "poetry.lock" ]] || [[ -f "Pipfile.lock" ]]; then
        stack_type="python"
        runtime="python"
        lockfile="poetry.lock"
        [[ -f "Pipfile.lock" ]] && lockfile="Pipfile.lock"
        auto_detected=true
    elif [[ -f "go.sum" ]]; then
        stack_type="go"
        runtime="go"
        lockfile="go.sum"
        auto_detected=true
    elif [[ -f "Gemfile.lock" ]]; then
        stack_type="ruby"
        runtime="ruby"
        lockfile="Gemfile.lock"
        auto_detected=true
    elif [[ -f "pubspec.lock" ]]; then
        stack_type="dart"
        runtime="dart"
        lockfile="pubspec.lock"
        auto_detected=true
    fi

    # === CONFIG FILE DETECTION (fallback if no lockfile) ===
    # Config files without lockfiles still indicate an ecosystem.

    if [[ "$auto_detected" == false ]]; then
        if [[ -f "package.json" ]]; then
            stack_type="node"
            runtime="node"
            auto_detected=true
        elif [[ -f "Cargo.toml" ]]; then
            stack_type="rust"
            runtime="cargo"
            auto_detected=true
        elif [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]] || [[ -f "requirements.txt" ]]; then
            stack_type="python"
            runtime="python"
            auto_detected=true
        elif [[ -f "go.mod" ]]; then
            stack_type="go"
            runtime="go"
            auto_detected=true
        elif [[ -f "Gemfile" ]]; then
            stack_type="ruby"
            runtime="ruby"
            auto_detected=true
        elif [[ -f "pubspec.yaml" ]]; then
            stack_type="dart"
            runtime="dart"
            auto_detected=true
        elif [[ -f "Package.swift" ]]; then
            stack_type="swift"
            runtime="swift"
            auto_detected=true
        elif [[ -f "CMakeLists.txt" ]] || [[ -f "Makefile" ]] || [[ -f "build.gradle" ]] || [[ -f "pom.xml" ]]; then
            # Generic build systems — we know it's a project, but not which language
            stack_type="generic"
            auto_detected=true
        fi
    fi

    # === FRAMEWORK DETECTION (Node.js only, for now) ===

    if [[ "$stack_type" == "node" ]] && [[ -f "package.json" ]]; then
        if grep -q '"next"' package.json 2>/dev/null; then framework="next.js"
        elif grep -q '"react"' package.json 2>/dev/null; then framework="react"
        elif grep -q '"vue"' package.json 2>/dev/null; then framework="vue"
        elif grep -q '"svelte"' package.json 2>/dev/null; then framework="svelte"
        elif grep -q '"angular"' package.json 2>/dev/null; then framework="angular"
        elif grep -q '"express"' package.json 2>/dev/null; then framework="express"
        elif grep -q '"hono"' package.json 2>/dev/null; then framework="hono"
        elif grep -q '@nestjs' package.json 2>/dev/null; then framework="nestjs"
        fi
    fi

    # === AUTO-EXTRACT COMMANDS (for known ecosystems) ===

    if [[ "$stack_type" == "node" ]] && [[ -f "package.json" ]]; then
        test_cmd=$(node -e "const p=require('./package.json'); console.log(p.scripts?.test||'')" 2>/dev/null || echo "")
        lint_cmd=$(node -e "const p=require('./package.json'); console.log(p.scripts?.lint||'')" 2>/dev/null || echo "")
        build_cmd=$(node -e "const p=require('./package.json'); console.log(p.scripts?.build||'')" 2>/dev/null || echo "")
        dev_cmd=$(node -e "const p=require('./package.json'); console.log(p.scripts?.dev||'')" 2>/dev/null || echo "")
        if grep -q '"typescript"' package.json 2>/dev/null || [[ -f "tsconfig.json" ]]; then
            typecheck_cmd="npx tsc --noEmit"
        fi
        [[ -z "$test_cmd" ]] && test_cmd="npm test"
        [[ -z "$lint_cmd" ]] && lint_cmd="npm run lint"
        [[ -z "$build_cmd" ]] && build_cmd="npm run build"
    fi

    if [[ "$stack_type" == "rust" ]]; then
        test_cmd="cargo test"
        lint_cmd="cargo clippy"
        typecheck_cmd="cargo check"
        build_cmd="cargo build"
        dev_cmd="cargo run"
    fi

    if [[ "$stack_type" == "python" ]]; then
        if grep -q "pytest" pyproject.toml 2>/dev/null || [[ -f "pytest.ini" ]] || [[ -f "conftest.py" ]]; then
            test_cmd="pytest"
        else
            test_cmd="python -m pytest"
        fi
        if command -v ruff &>/dev/null; then lint_cmd="ruff check"; else lint_cmd="flake8"; fi
        typecheck_cmd="mypy ."
        build_cmd="python -m build"
    fi

    if [[ "$stack_type" == "go" ]]; then
        test_cmd="go test ./..."
        lint_cmd="golangci-lint run"
        typecheck_cmd="go vet ./..."
        build_cmd="go build ./..."
        dev_cmd="go run ."
    fi

    if [[ "$stack_type" == "ruby" ]]; then
        test_cmd="bundle exec rspec"
        lint_cmd="rubocop"
        typecheck_cmd="solargraph check"
        build_cmd="bundle exec rake build"
        dev_cmd="bundle exec rails server"
    fi

    if [[ "$stack_type" == "dart" ]]; then
        test_cmd="dart test"
        lint_cmd="dart analyze"
        typecheck_cmd="dart analyze"
        build_cmd="dart build exe"
        dev_cmd="dart run"
    fi

    if [[ "$stack_type" == "swift" ]]; then
        test_cmd="swift test"
        lint_cmd="swiftlint"
        typecheck_cmd="swift build"
        build_cmd="swift build"
        dev_cmd="swift run"
    fi

    # === ASK USER FOR UNKNOWN STACKS ===
    # If we couldn't detect the stack, ask the developer.
    # This is aligned with Rule 0c: Think Before Coding — ask, don't guess.

    if [[ "$auto_detected" == false ]]; then
        log "Could not detect your project's stack automatically."
        log "I'll create STACK_CONFIG.md with placeholders. You can configure commands manually."
        echo ""
    fi

    # === GENERATE STACK_CONFIG.md ===

    cat > "./STACK_CONFIG.md" << EOF
# Stack Configuration

**Detected:** ${stack_type}${framework:+ (${framework})}${runtime:+ — ${runtime}}
**Auto-detected:** ${auto_detected}
**Generated by:** init-agents (another-agent-skills)

## Commands

| Action | Command |
|---|---|
| Test | \`${test_cmd:-<configure: what command runs your tests?>}\` |
| Lint | \`${lint_cmd:-<configure: what command lints your code?>}\` |
| Type check | \`${typecheck_cmd:-<configure: what command checks types?>}\` |
| Build | \`${build_cmd:-<configure: what command builds your project?>}\` |
| Dev | \`${dev_cmd:-<configure: what command starts your dev server?>}\` |

## Lockfile

${lockfile:+\`${lockfile}\` detected}
${lockfile:-No lockfile detected}

## How to Configure

If any command shows \`<configure: ...>\`, edit this file and replace with your actual command.
Skills (git-workflow, test-driven, etc.) read this file for project-specific behavior.

## Re-detect

After changing your project setup, re-run:
\`\`\`bash
rm STACK_CONFIG.md && bash init-agents.sh
\`\`\`
EOF

    ok "Created STACK_CONFIG.md (${stack_type}${framework:+ — ${framework}})"
    if [[ "$auto_detected" == false ]]; then
        warn "Stack not auto-detected. Please configure commands in STACK_CONFIG.md."
    else
        log "Skills will read this file for project-specific commands."
    fi
}
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

# ─── Git / GitHub detection ───
# Enforcement delivery must be honest: a remote-gate workflow is only useful
# when the project is a git repo with a GitHub remote. Never install a dead
# workflow or print impossible instructions.
has_git() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

has_github_remote() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 1
    git remote -v 2>/dev/null | grep -q 'github\.com'
}

# Install the remote-gate workflow (L2 authority) from STACK_CONFIG.md
install_gates_workflow() {
    local dst=".github/workflows/gates.yml"
    local src="${AAS_DIR}/templates/gates.yml"

    # Only install when the project can actually use it. Without git there are
    # no local hooks; without a GitHub remote there is no L2 authority to run it.
    if ! has_git; then
        log "No git repository — skipping remote gate workflow (${dst})."
        return 0
    fi
    if ! has_github_remote; then
        log "No GitHub remote — skipping remote gate workflow (${dst})."
        return 0
    fi

    # Don't overwrite an existing gates workflow
    if [[ -f "$dst" ]]; then
        log "gates.yml already exists. Skipping."
        return 0
    fi

    if [[ ! -d ".github/workflows" ]]; then
        mkdir -p ".github/workflows"
    fi

    if [[ -f "$src" ]]; then
        cp "$src" "$dst"
        ok "Installed remote gate workflow (${dst})"
        log "Its 'gates' job is the required status check. Turn on the remote"
        log "layer with: bash scripts/setup-branch-protection.sh"
    else
        warn "gates template not found at ${src}. Skipping."
    fi
}

# Install self-improvement loop artifacts (--with-self-improvement flag)
install_self_improvement() {
    local stack_type="generic"
    # Simple stack detection (subset of detect_stack_and_create_config logic)
    if [[ -f "package-lock.json" ]] || [[ -f "yarn.lock" ]] || [[ -f "pnpm-lock.yaml" ]] || [[ -f "bun.lockb" ]] || [[ -f "package.json" ]]; then
        stack_type="node"
    elif [[ -f "Cargo.lock" ]] || [[ -f "Cargo.toml" ]]; then
        stack_type="rust"
    elif [[ -f "poetry.lock" ]] || [[ -f "Pipfile.lock" ]] || [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]] || [[ -f "requirements.txt" ]]; then
        stack_type="python"
    elif [[ -f "go.sum" ]] || [[ -f "go.mod" ]]; then
        stack_type="go"
    fi

    log "Stack detected: ${stack_type}"

    # Generate .audit-config.json with stack-aware defaults
    if [[ ! -f ".audit-config.json" ]]; then
        local excludes='"node_modules/**", ".git/**"'
        local core='"^README\\.md$", "^CONTRIBUTING\\.md$"'
        case "$stack_type" in
            node)   excludes='"node_modules/**", ".git/**", "dist/**", "build/**", "coverage/**"' ;;
            python) excludes='"__pycache__/**", ".venv/**", "*.egg-info/**", ".git/**", ".mypy_cache/**"' ;;
            rust)   excludes='"target/**", ".git/**"' ;;
            go)     excludes='"vendor/**", ".git/**"' ;;
            *)      excludes='"node_modules/**", ".git/**"' ;;
        esac
        cat > ".audit-config.json" <<CONFIG
{
  "project_name": "$(basename "$(pwd)")",
  "include_patterns": ["**/*.md"],
  "exclude_patterns": [${excludes}],
  "core_files": [${core}],
  "max_file_length": 250,
  "length_check_paths": ["docs/"],
  "checks": {
    "tables": true,
    "links": true,
    "placeholders": true,
    "file_length": true,
    "mermaid": true,
    "terminology": false
  },
  "terminology_rules": {}
}
CONFIG
        ok "Created .audit-config.json (${stack_type})"
    else
        log ".audit-config.json already exists. Skipping."
    fi

    # Create scripts/audit-project.sh as a portable shim (P9.7). Never a symlink
    # to the dev clone; a legacy absolute symlink is replaced.
    local aud_dst="scripts/audit-project.sh"
    if [ -L "$aud_dst" ]; then
        [ "$DRY_RUN" = true ] || rm -f "$aud_dst"
        write_shim "$aud_dst" "scripts/universal-audit.sh" "../.aas/aas-resolve.sh"
    elif [ -e "$aud_dst" ]; then
        warn "${aud_dst} — exists locally, preserved"
    else
        write_shim "$aud_dst" "scripts/universal-audit.sh" "../.aas/aas-resolve.sh"
    fi

    # Generate ADR script (portable shim)
    local adr_dst="scripts/generate-adr.sh"
    if [ -L "$adr_dst" ]; then
        [ "$DRY_RUN" = true ] || rm -f "$adr_dst"
        write_shim "$adr_dst" "scripts/generate-adr.sh" "../.aas/aas-resolve.sh"
    elif [ -e "$adr_dst" ]; then
        warn "${adr_dst} — exists locally, preserved"
    else
        write_shim "$adr_dst" "scripts/generate-adr.sh" "../.aas/aas-resolve.sh"
    fi

    # Determine skill install path based on agent config
    local skill_dest_dir="skills"
    local agent_config
    agent_config=$(detect_target)
    if echo "$agent_config" | grep -q '.claude/'; then
        skill_dest_dir=".claude/skills"
    elif echo "$agent_config" | grep -q '.opencode/'; then
        skill_dest_dir=".opencode/skills"
    fi

    # Copy self-improvement skill (SKILL.md + guides)
    local skill_src="${AAS_DIR}/skills/self-improvement"
    local skill_dst="${skill_dest_dir}/self-improvement"
    if [[ -d "$skill_src" ]]; then
        if [[ -e "$skill_dst" ]] || [[ -L "$skill_dst" ]]; then
            warn "Self-improvement skill — exists locally, preserved"
        elif _same_path "$skill_src" "$skill_dst"; then
            warn "Self-improvement skill — source and destination are the same. Skipping."
        else
            if [ "$DRY_RUN" = true ]; then
                plan "copy self-improvement skill → ${skill_dst}/"
            else
                mkdir -p "$skill_dest_dir"
                cp -r "$skill_src" "$skill_dst" && ok "Installed self-improvement skill → ${skill_dst}/" || warn "Self-improvement skill — could not copy"
            fi
        fi
    else
        warn "Self-improvement skill not found at ${skill_src}. Skipping."
    fi

    # Copy PATTERNS.md and ANTI-PATTERNS.md (plain copies — never symlinks)
    for pair in "${AAS_DIR}/PATTERNS.md:PATTERNS.md" "${AAS_DIR}/ANTI-PATTERNS.md:ANTI-PATTERNS.md"; do
        local src="${pair%%:*}"
        local dst="${pair##*:}"
        [ -f "$src" ] || continue
        if [ -L "$dst" ]; then
            if [ "$DRY_RUN" = true ]; then
                plan "replace legacy symlink ${dst} with a copy"
            else
                rm -f "$dst"
                cp "$src" "$dst" && ok "Replaced legacy symlink ${dst} with a copy"
            fi
        elif [ -f "$dst" ]; then
            :
        else
            if [ "$DRY_RUN" = true ]; then
                plan "copy ${dst}"
            else
                cp "$src" "$dst" && ok "Copied ${dst}"
            fi
        fi
    done

    # Create ADRs/ directory
    if [ "$DRY_RUN" = true ]; then
        [ -d "ADRs" ] || plan "create ADRs/ directory"
    else
        mkdir -p "ADRs"
        ok "Created ADRs/ directory"
    fi

    # Warn if jq is not available
    if ! command -v jq &>/dev/null; then
        warn "jq not found. Required for --json audit output."
        warn "  Install: apt install jq / brew install jq / choco install jq"
    fi
}

# Main logic
main() {
    # Check for updates before doing anything else
    bash "${SCRIPT_DIR}/check-update.sh" || true

    # Non-blocking drift advisory + legacy detection (P9.8).
    aas_drift_notice
    detect_legacy || true

    if [ "$DRY_RUN" = true ]; then
        run_dry_run
        return 0
    fi

    # Migrate a legacy project before the normal (idempotent) install.
    if [ "$REPAIR" = true ]; then
        repair_legacy
    fi

    local existing_target
    existing_target=$(detect_target)
    local is_new_project=false

    if [[ -n "$existing_target" ]]; then
        merge_into_file "$existing_target"
    else
        # No existing agent config → copy normally
        cp "$AGENTS_SOURCE" "./AGENTS.md"
        ok "Created AGENTS.md with Another Agent Skills rules"
        is_new_project=true
    fi

    # Install the portable hook shims (resolve $AAS_DIR, delegate)
    install_hook_shims

    # Write .aas/config + copy the resolver (no framework symlinks in the project)
    install_framework_refs

    # Detect stack and create STACK_CONFIG.md (used by all skills)
    detect_stack_and_create_config

    # Scaffold self-improvement loop if requested
    if [[ "$WITH_SELF_IMPROVEMENT" == true ]]; then
        install_self_improvement
    fi

    # Copy skills into the project for a self-contained setup (optional)
    if [[ "$WITH_SKILLS" == true ]]; then
        install_with_skills
    fi

    # Install the remote-gate workflow (L2 authority layer)
    install_gates_workflow

    # Create .sessionrc for purpose-driven sessions
    if [[ ! -f "./.sessionrc" ]]; then
        create_sessionrc
    else
        log ".sessionrc already exists. Skipping."
    fi

    # Show next steps
    if [[ "$WITH_SELF_IMPROVEMENT" == true ]]; then
        show_next_steps "$is_new_project" "$existing_target" "true"
    else
        show_next_steps "$is_new_project" "$existing_target" "false"
    fi
}

show_next_steps() {
    local is_new="$1"
    local target_file="$2"
    local with_si="${3:-false}"
    local stack="unknown"
    [[ -f "./STACK_CONFIG.md" ]] && stack=$(grep -oP '(?<=Detected: ).*' ./STACK_CONFIG.md 2>/dev/null | head -1 || echo "unknown")
    [[ "$stack" == "unknown" ]] && stack="your stack"
    local target_name="AGENTS.md"
    [[ -n "$target_file" ]] && target_name=$(basename "$target_file")

    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    if [[ "$is_new" == "true" ]]; then
        echo "║  NEW PROJECT — READY TO GO                               ║"
    else
        echo "║  PROJECT UPDATED — RULES MERGED                          ║"
    fi
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""

    # --- INSTALLED (new files created) ---
    echo "  INSTALLED:"
    if [[ "$is_new" == "true" ]]; then
        echo "    ✓ AGENTS.md — skill-driven rules and lifecycle"
    else
        echo "    ✓ ${target_name} — skill-driven rules merged"
    fi
    [[ -f "./STACK_CONFIG.md" ]] && echo "    ✓ STACK_CONFIG.md — ${stack}"
    [[ -f "./.sessionrc" ]] && echo "    ✓ .sessionrc — purpose-driven sessions"
    [[ -f "./.github/workflows/gates.yml" ]] && echo "    ✓ .github/workflows/gates.yml — remote gate (required check)"
    [[ -f "./.git/hooks/pre-commit" ]] && echo "    ✓ pre-commit hook — lifecycle enforcement"
    [[ -f "./.git/hooks/commit-msg" ]] && echo "    ✓ commit-msg hook — TDD gate (v6)"
    echo ""

    # --- FRAMEWORK (resolved from the machine install; nothing duplicated) ---
    echo "  FRAMEWORK (resolved, not duplicated):"
    echo "    ✓ .aas/config — pins the framework version"
    echo "    ✓ .aas/aas-resolve.sh — portable resolver"
    [[ -f "./.git/hooks/pre-commit" ]] && echo "    ✓ .git/hooks/pre-commit — portable shim → \$AAS_DIR"
    [[ -f "./.git/hooks/commit-msg" ]] && echo "    ✓ .git/hooks/commit-msg — portable shim → \$AAS_DIR"
    if [ -n "${AAS_DIR:-}" ]; then
        echo "    ✓ framework root: ${AAS_DIR}"
    fi
    echo ""

    # --- REMOTE LAYER (L2 authority) ---
    # Be honest about what is actually available: never point at a remote layer
    # that this project cannot use.
    if has_git && has_github_remote && [[ -f "./.github/workflows/gates.yml" ]]; then
        echo "  REMOTE ENFORCEMENT (L2 — the authority):"
        echo "    Local hooks are fast feedback; they are writable. The required"
        echo "    'gates' status check is what actually decides. Turn it on with:"
        echo "      bash scripts/setup-branch-protection.sh --dry-run   # preview"
        echo "      bash scripts/setup-branch-protection.sh             # apply"
        echo "    Why local ≠ authority: docs/BRANCH-PROTECTION.md"
        echo ""
    elif ! has_git; then
        echo "  ENFORCEMENT — convention-only (no git repository):"
        echo "    No git repository: enforcement is convention-only. Run \`git init\`"
        echo "    and re-run init-agents to enable local hooks; add a GitHub remote"
        echo "    for remote enforcement."
        echo ""
    else
        echo "  ENFORCEMENT — local only (L1 hooks active):"
        echo "    Local git only: L1 (hooks) is active. Remote enforcement (L2) needs"
        echo "    a GitHub remote — \`git remote add origin …\` then re-run init-agents."
        echo ""
    fi

    # --- SELF-IMPROVEMENT LOOP (--with-self-improvement flag) ---
    if [[ "$with_si" == "true" ]]; then
        echo "  SELF-IMPROVEMENT LOOP:"
        [[ -f "./.audit-config.json" ]] && echo "    ✓ .audit-config.json — stack-aware audit config"
        [[ -f "./scripts/audit-project.sh" ]] && echo "    ✓ scripts/audit-project.sh — audit wrapper"
        [[ -d "./skills/self-improvement" ]] || [[ -d "./.claude/skills/self-improvement" ]] || [[ -d "./.opencode/skills/self-improvement" ]] && echo "    ✓ self-improvement skill — loop orchestrator + guides"
        [[ -f "./PATTERNS.md" ]] && echo "    ✓ PATTERNS.md — workflow patterns"
        [[ -f "./ANTI-PATTERNS.md" ]] && echo "    ✓ ANTI-PATTERNS.md — anti-patterns"
        [[ -d "./ADRs" ]] && echo "    ✓ ADRs/ — architecture decision records"
        [[ -f "./scripts/generate-adr.sh" ]] && echo "    ✓ scripts/generate-adr.sh — ADR generator"
        echo ""
        echo "  Try these prompts:"
        echo "    • \"run self-improvement loop\" — full audit → fix → ADR cycle"
        echo "    • \"audit the project\" — quick quality check"
        echo "    • \"bash scripts/audit-project.sh --json\" — raw audit output"
        echo ""
    fi

    # --- NEXT STEPS ---
    echo "  Next steps:"
    echo "    1. Open this project in OpenCode"
    echo "    2. The agent loads skills automatically when it detects a task"
    echo ""
    echo "  Try these prompts:"
    echo "    • \"Add a login page\" → loads frontend-web skill"
    echo "    • \"Set up an API\" → loads backend-api-mastery skill"
    echo "    • \"Review my code\" → loads code-review-and-quality skill"
    echo "    • \"What's the health of this project?\" → loads project-health-check"
    echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
# Portable project layer (P9.7): .aas/config + resolver copy + hook shims.
# Nothing here creates an absolute symlink to the framework or the dev clone.
# ─────────────────────────────────────────────────────────────────────────────

framework_version() {
    cat "${AAS_DIR}/VERSION" 2>/dev/null | tr -d '[:space:]' || true
}

aas_drift_notice() {
    if type _aas_resolve_drift_notice >/dev/null 2>&1; then
        _aas_resolve_drift_notice || true
    fi
}

# Legacy detection (P9.8): AAS artifacts but no .aas/config version marker.
detect_legacy() {
    [ -f "${AAS_CONFIG_DIR}/config" ] && return 0
    local found=""
    if [ -f "./AGENTS.md" ] && grep -q "$DELIMITER_BEGIN" ./AGENTS.md 2>/dev/null; then
        found="AGENTS.md marker"
    elif [ -f "./STACK_CONFIG.md" ]; then
        found="STACK_CONFIG.md"
    elif find . -maxdepth 3 -type l \( -path './scripts/*' -o -name 'SOUL.md' -o -name 'VERSION' \) 2>/dev/null | grep -q .; then
        found="framework symlinks"
    fi
    [ -n "$found" ] || return 0
    warn "Legacy AAS project detected (${found}) with no version marker."
    log  "  Next: 'bash scripts/init-agents.sh --dry-run' then 'bash scripts/init-agents.sh --repair'"
    return 0
}

# Write a 2-3 line portable shim that resolves $AAS_DIR and delegates.
#   shim            path of the shim to write
#   delegate        path relative to $AAS_DIR of the real script
#   resolver_rel    path from the shim's dir to .aas/aas-resolve.sh
write_shim() {
    local shim="$1" delegate="$2" resolver_rel="$3"
    if [ "$DRY_RUN" = true ]; then
        plan "install portable shim ${shim} → \$AAS_DIR/${delegate}"
        return 0
    fi
    mkdir -p "$(dirname "$shim")"
    cat > "$shim" <<SHIM
#!/bin/sh
# AAS shim — portable, no absolute paths. Resolves the installed framework and
# delegates. A machine without AAS is never blocked.
_AAS_HERE=\$(cd "\$(dirname "\$0")" 2>/dev/null && pwd)
_AAS_ROOT="\${AAS_DIR:-\${ANOTHER_AGENT_SKILLS_DIR:-}}"
if [ -z "\$_AAS_ROOT" ] && command -v aas >/dev/null 2>&1; then
  _AAS_ROOT="\$(aas --dir 2>/dev/null || true)"
fi
if [ -z "\$_AAS_ROOT" ] && [ -f "\$_AAS_HERE/${resolver_rel}" ]; then
  SCRIPT_DIR="\$_AAS_HERE"
  . "\$_AAS_HERE/${resolver_rel}" 2>/dev/null || true
  _AAS_ROOT="\${AAS_DIR:-}"
fi
if [ -z "\$_AAS_ROOT" ]; then
  # Inside the framework source tree? Use it, so a fresh clone of the framework
  # repo works without installing anything (walk up for VERSION + the hook).
  _AAS_WALK="\$_AAS_HERE"
  while [ -n "\$_AAS_WALK" ] && [ "\$_AAS_WALK" != "/" ]; do
    if [ -f "\$_AAS_WALK/VERSION" ] && [ -f "\$_AAS_WALK/scripts/git-hooks/pre-commit" ]; then
      _AAS_ROOT="\$_AAS_WALK"; break
    fi
    _AAS_WALK=\$(dirname "\$_AAS_WALK")
  done
fi
if [ -z "\$_AAS_ROOT" ]; then
  echo "AAS: framework not found — run 'aas install' or set ANOTHER_AGENT_SKILLS_DIR" >&2
  exit 0
fi
exec "\$_AAS_ROOT/${delegate}" "\$@"
SHIM
    chmod +x "$shim"
    ok "Installed portable shim: ${shim}"
}

install_one_hook_shim() {
    local dst="$1" delegate="$2" force="${3:-false}"
    if [ -L "$dst" ]; then
        if [ "$DRY_RUN" = true ]; then
            plan "replace legacy symlink ${dst} with a portable shim"
        else
            rm -f "$dst"
        fi
    elif [ -f "$dst" ]; then
        if [ "$FORCE" = true ] || [ "$force" = true ]; then
            backup_file "$dst" >/dev/null
            warn "Replacing custom hook ${dst} (backup in ${AAS_BACKUP_DIR}/)"
        else
            warn "${dst} exists (custom hook) — preserved. Use --force to replace."
            return 0
        fi
    fi
    write_shim "$dst" "$delegate" "../../.aas/aas-resolve.sh"
}

install_hook_shims() {
    local force="${1:-false}"
    if [ ! -d "./.git" ]; then
        log "No .git directory. Skipping hook shims."
        return 0
    fi
    install_one_hook_shim "./.git/hooks/pre-commit" "scripts/git-hooks/pre-commit" "$force"
    install_one_hook_shim "./.git/hooks/commit-msg" "scripts/git-hooks/commit-msg" "$force"
}

write_aas_config() {
    local agents
    agents="$(detect_agents 2>/dev/null | paste -sd, - || true)"
    cat > "${AAS_CONFIG_DIR}/config" <<CONFIG
{
  "version": "$(framework_version)",
  "agents": "${agents}",
  "initialized": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
CONFIG
}

# .aas/aas-resolve.sh and .aas/config are committed so a clone stays portable;
# only the local backups are ignored.
ensure_gitignore() {
    [ -f "./.gitignore" ] || return 0
    if [ "$DRY_RUN" = true ]; then
        grep -qF ".aas/backups/" .gitignore 2>/dev/null || plan "add .aas/backups/ to .gitignore"
        grep -qF "*.backup.*" .gitignore 2>/dev/null || plan "add *.backup.* to .gitignore"
        return 0
    fi
    if ! grep -qF ".aas/backups/" .gitignore 2>/dev/null; then
        printf '\n# Another Agent Skills — local backups (framework)\n.aas/backups/\n' >> .gitignore
    fi
    if ! grep -qF "*.backup.*" .gitignore 2>/dev/null; then
        printf '*.backup.*\n' >> .gitignore
    fi
}

# The framework source repo is not a "project": it must not get a .aas/ project
# layer. Its hooks self-resolve via the source-tree walk in the shim.
is_framework_repo() {
    [ -f "./VERSION" ] && [ -f "./scripts/git-hooks/pre-commit" ] && [ -f "./SOUL.md" ]
}

install_framework_refs() {
    if is_framework_repo; then
        log "Framework source repo detected — skipping the .aas/ project layer (not needed here)."
        return 0
    fi
    if [ "$DRY_RUN" = true ]; then
        plan "write ${AAS_CONFIG_DIR}/config (version $(framework_version))"
        plan "copy scripts/aas-resolve.sh → ${AAS_CONFIG_DIR}/aas-resolve.sh"
        ensure_gitignore
        return 0
    fi
    mkdir -p "$AAS_CONFIG_DIR"
    write_aas_config
    if [ -f "${AAS_DIR}/scripts/aas-resolve.sh" ]; then
        cp "${AAS_DIR}/scripts/aas-resolve.sh" "${AAS_CONFIG_DIR}/aas-resolve.sh"
    else
        warn "aas-resolve.sh not found in the framework; shims will fall back to PATH/env."
    fi
    ensure_gitignore
    ok "Wrote ${AAS_CONFIG_DIR}/config and ${AAS_CONFIG_DIR}/aas-resolve.sh"
}

# --with-skills: copy the framework skills into the project (self-contained).
install_with_skills() {
    local skill_dest_dir="skills"
    local agent_config
    agent_config=$(detect_target)
    if echo "$agent_config" | grep -q '.claude/'; then
        skill_dest_dir=".claude/skills"
    elif echo "$agent_config" | grep -q '.opencode/'; then
        skill_dest_dir=".opencode/skills"
    fi
    if [ "$DRY_RUN" = true ]; then
        plan "copy framework skills into ${skill_dest_dir}/ (--with-skills)"
        return 0
    fi
    mkdir -p "$skill_dest_dir"
    local copied=0 skill_path name
    for skill_path in "${AAS_DIR}/skills"/*/; do
        [ -f "${skill_path}/SKILL.md" ] || continue
        name="$(basename "$skill_path")"
        [ -e "${skill_dest_dir}/${name}" ] && continue
        cp -r "$skill_path" "${skill_dest_dir}/${name}" && copied=$((copied + 1))
    done
    ok "Copied ${copied} skill(s) into ${skill_dest_dir}/ (--with-skills)"
}

# --repair (P9.8): drop absolute/broken framework symlinks. The normal install
# then recreates the portable form. Team docs and custom files are untouched.
repair_legacy() {
    log "Repairing legacy project (non-destructive)..."
    local paths=(
        "rules/common"
        "SOUL.md"
        "AGENTS-EXTENDED.md"
        "VERSION"
        "PATTERNS.md"
        "ANTI-PATTERNS.md"
        "scripts/audit-project.sh"
        "scripts/generate-adr.sh"
    )
    local s
    for s in skill-gate.sh edit-guard.sh task-manifest.sh pre-flight.sh \
             commit-approval.sh pr-review-checklist.sh design-gate.sh skill-lint.sh \
             setup-branch-protection.sh tdd-gate.sh; do
        paths+=("scripts/${s}")
    done
    local p target
    for p in "${paths[@]}"; do
        [ -L "$p" ] || continue
        target="$(readlink "$p" 2>/dev/null || true)"
        case "$target" in
            /*) rm -f "$p"; warn "Removed absolute symlink ${p} → ${target}" ;;
            *)  if [ ! -e "$p" ]; then rm -f "$p"; warn "Removed broken symlink ${p}"; fi ;;
        esac
    done
    # Hook symlinks are replaced by the normal install; custom real hooks need --force.
    if [ -L "./.git/hooks/pre-commit" ]; then rm -f "./.git/hooks/pre-commit"; fi
    if [ -L "./.git/hooks/commit-msg" ]; then rm -f "./.git/hooks/commit-msg"; fi
    return 0
}

# --dry-run: print exactly what would change and mutate nothing.
run_dry_run() {
    log "DRY RUN — no changes will be made."
    local target
    target="$(detect_target)"
    if [ -n "$target" ]; then
        if has_our_rules "$target"; then
            plan "leave $(basename "$target") (AAS rules already present)"
        else
            plan "back up $(basename "$target") and append the AAS rules footer"
        fi
    else
        plan "create AGENTS.md"
    fi
    if [ -d "./.git" ]; then
        plan "install portable hook shims (.git/hooks/pre-commit, commit-msg)"
    else
        plan "skip hook shims (no .git directory)"
    fi
    plan "write .aas/config (version $(framework_version))"
    plan "copy scripts/aas-resolve.sh → .aas/aas-resolve.sh"
    [ -f "./STACK_CONFIG.md" ] || plan "create STACK_CONFIG.md"
    [ -f "./.sessionrc" ] || plan "create .sessionrc"
    if has_git && has_github_remote; then
        [ -f "./.github/workflows/gates.yml" ] || plan "install .github/workflows/gates.yml"
    fi
    if [ "$WITH_SELF_IMPROVEMENT" == true ]; then
        plan "scaffold the self-improvement loop"
    fi
    if [ "$WITH_SKILLS" == true ]; then
        plan "copy framework skills into the project (--with-skills)"
    fi
    ensure_gitignore
    log "Dry run complete — nothing changed."
}

# ─── sync-hooks subcommand ───
if [ "$SUBCOMMAND" = "sync-hooks" ]; then
    if [ ! -d "./.git" ]; then
        warn "No .git directory found. Run from a git repository."
        exit 1
    fi
    install_framework_refs
    install_hook_shims true
    log "Hooks synced. Re-run 'bash scripts/init-agents.sh sync-hooks' after changing hooks."
    exit 0
fi

main "$@"
