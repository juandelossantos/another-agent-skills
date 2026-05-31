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

# Append our rules footer to existing file with delimiters
# Never appends the full AGENTS_SOURCE — only the attribution footer.
# The full rules are loaded dynamically by the agent framework via skills/.
merge_into_file() {
    local target="$1"
    
    if has_our_rules "$target"; then
        ok "Another Agent Skills rules already present in $(basename "$target"). Skipping."
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

# Main logic
main() {
    # Check for updates before doing anything else
    bash "${SCRIPT_DIR}/check-update.sh" || true

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

    # Detect stack and create STACK_CONFIG.md (used by all skills)
    detect_stack_and_create_config

    # Create .sessionrc for purpose-driven sessions
    if [[ ! -f "./.sessionrc" ]]; then
        create_sessionrc
    else
        log ".sessionrc already exists. Skipping."
    fi
}

install_precommit_hook() {
    local hook_src="${SCRIPT_DIR}/project-pre-commit"
    local hook_dst="./.git/hooks/pre-commit"
    local commit_msg_src="${SCRIPT_DIR}/git-hooks/commit-msg"
    local commit_msg_dst="./.git/hooks/commit-msg"
    
    if [[ ! -f "${hook_src}" ]]; then
        warn "Project pre-commit hook source not found at ${hook_src}. Skipping."
        return 0
    fi
    
    if [[ ! -d "./.git" ]]; then
        log "No .git directory. Skipping pre-commit hook installation."
        return 0
    fi
    
    mkdir -p "./.git/hooks"
    
    if [[ -f "${hook_dst}" ]]; then
        cp "${hook_dst}" "${hook_dst}.backup.$(date +%Y%m%d%H%M%S)"
        warn "Backed up existing pre-commit hook"
    fi
    cp "${hook_src}" "${hook_dst}"
    chmod +x "${hook_dst}"
    ok "Installed lifecycle pre-commit hook (${hook_dst})"
    
    if [[ -f "${commit_msg_src}" ]]; then
        if [[ -f "${commit_msg_dst}" ]]; then
            cp "${commit_msg_dst}" "${commit_msg_dst}.backup.$(date +%Y%m%d%H%M%S)"
            warn "Backed up existing commit-msg hook"
        fi
        cp "${commit_msg_src}" "${commit_msg_dst}"
        chmod +x "${commit_msg_dst}"
        ok "Installed commit-msg hook (${commit_msg_dst})"
    fi
    
    log "Hook enforces: tests pass, build succeeds, no secrets."
    log "Commands read from STACK_CONFIG.md (stack-agnostic)."
}

main "$@"
