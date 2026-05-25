# ==============================================================================
# Another Agent Skills — Windows PowerShell Installer
# ==============================================================================
# One-command setup for production-grade AI agent skills on Windows.
#
# Usage:
#   .\install.ps1                           # Full install
#   .\install.ps1 -Agent claude             # Claude Code adapter only
#   .\install.ps1 -Agent cursor             # Cursor adapter only
#   .\install.ps1 -Agent all                # All adapters
# ==============================================================================

param(
    [string]$Agent = ""
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RemoteRepo = "https://github.com/addyosmani/agent-skills.git"
$RemoteDir = "$env:USERPROFILE\.config\opencode\.agent-skills-remote"
$GlobalSkillsDir = "$env:USERPROFILE\.config\opencode\skills"
$LocalBin = "$env:USERPROFILE\.local\bin"

function Write-Info  { Write-Host "[INFO] $args" -ForegroundColor Blue }
function Write-Ok    { Write-Host "[OK] $args" -ForegroundColor Green }
function Write-Warn  { Write-Host "[WARN] $args" -ForegroundColor Yellow }
function Write-Error { Write-Host "[ERROR] $args" -ForegroundColor Red }

# ------------------------------------------------------------------------------
function Check-Prerequisites {
    Write-Info "Checking prerequisites..."

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error "Git is required. Install from https://git-scm.com/downloads"
        exit 1
    }

    if (-not (Test-Path "$env:USERPROFILE\.config\opencode")) {
        New-Item -ItemType Directory -Path "$env:USERPROFILE\.config\opencode" -Force | Out-Null
    }

    Write-Ok "Prerequisites met."
}

# ------------------------------------------------------------------------------
function Setup-RemoteSkills {
    Write-Info "Setting up official agent-skills repository..."

    if (Test-Path "$RemoteDir\.git") {
        Write-Warn "Remote repo exists. Pulling latest..."
        Push-Location $RemoteDir
        git pull --quiet
        Pop-Location
    } else {
        Write-Info "Cloning $RemoteRepo ..."
        if (Test-Path $RemoteDir) { Remove-Item -Recurse -Force $RemoteDir }
        git clone --depth=1 $RemoteRepo $RemoteDir
    }

    Write-Ok "Official skills updated."
}

# ------------------------------------------------------------------------------
function Link-RemoteSkills {
    Write-Info "Linking official skills..."

    if (-not (Test-Path $GlobalSkillsDir)) {
        New-Item -ItemType Directory -Path $GlobalSkillsDir -Force | Out-Null
    }

    Get-ChildItem "$RemoteDir\.opencode\skills\*" -Directory | ForEach-Object {
        $name = $_.Name
        $target = Join-Path $GlobalSkillsDir $name

        if (Test-Path $target) {
            if ((Get-Item $target).LinkType -eq "SymbolicLink") {
                Remove-Item -Force $target
            } else {
                # Back up existing directory
                $backup = "$target.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
                Move-Item $target $backup
                Write-Warn "Backed up $name → $backup"
            }
        }

        New-Item -ItemType Junction -Path $target -Target $_.FullName -Force | Out-Null
    }

    Write-Ok "Official skills linked."
}

# ------------------------------------------------------------------------------
function Install-CustomSkills {
    Write-Info "Installing custom skills..."

    $customDir = Join-Path $RepoRoot "skills"
    if (-not (Test-Path $customDir)) {
        Write-Warn "No custom skills directory found. Skipping."
        return
    }

    Get-ChildItem $customDir -Directory | ForEach-Object {
        $skillPath = $_.FullName
        $skillName = $_.Name
        $skillMd = Join-Path $skillPath "SKILL.md"

        if (Test-Path $skillMd) {
            $target = Join-Path $GlobalSkillsDir $skillName

            if (Test-Path $target) {
                $backup = "$target.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
                Move-Item $target $backup -Force
                Write-Warn "Backed up $skillName → $backup"
            }

            Copy-Item -Recurse $skillPath $target
            Write-Ok "Installed custom skill: $skillName"
        }
    }
}

# ------------------------------------------------------------------------------
function Update-ShellProfile {
    Write-Info "Updating PowerShell profile..."

    $profileDir = Split-Path -Parent $PROFILE
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }

    $envVars = @"
# >>> another-agent-skills-config
# Managed by install.ps1 — do not edit manually.

`$env:ANOTHER_AGENT_SKILLS_DIR = "$RepoRoot"

function init-agents {
    & "`$env:ANOTHER_AGENT_SKILLS_DIR\scripts\init-agents.sh"
}

function update-global-skills {
    Push-Location "$env:USERPROFILE\.config\opencode\.agent-skills-remote"
    git pull --quiet
    Pop-Location
}
# <<< another-agent-skills-config
"@

    # Remove existing block
    if (Test-Path $PROFILE) {
        $content = Get-Content $PROFILE -Raw
        $pattern = "(?s)# >>> another-agent-skills-config.*?# <<< another-agent-skills-config"
        if ($content -match $pattern) {
            $content = $content -replace $pattern, ""
            Set-Content $PROFILE $content
            Write-Warn "Removed existing config block from PowerShell profile"
        }

        # Backup
        $backup = "$PROFILE.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Copy-Item $PROFILE $backup
        Write-Ok "Profile backed up → $backup"
    }

    Add-Content $PROFILE "`n$envVars"
    Write-Ok "PowerShell profile updated."
}

# ------------------------------------------------------------------------------
function Install-AgentAdapter {
    param([string]$AgentName)

    $templateDir = Join-Path $RepoRoot "templates"
    if (-not (Test-Path $templateDir)) {
        Write-Error "Templates directory not found."
        return 1
    }

    switch ($AgentName) {
        "claude" {
            $src = Join-Path $templateDir "CLAUDE.md"
            $dst = Join-Path (Get-Location) "CLAUDE.md"
            if (Test-Path $dst) {
                $backup = "$dst.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
                Move-Item $dst $backup -Force
                Write-Warn "Backed up existing CLAUDE.md → $backup"
            }
            Copy-Item $src $dst
            Write-Ok "Installed CLAUDE.md → $dst"
        }
        "cursor" {
            $src = Join-Path $templateDir ".cursorrules"
            $dst = Join-Path (Get-Location) ".cursorrules"
            if (Test-Path $dst) {
                $backup = "$dst.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
                Move-Item $dst $backup -Force
                Write-Warn "Backed up existing .cursorrules → $backup"
            }
            Copy-Item $src $dst
            Write-Ok "Installed .cursorrules → $dst"
        }
        "all" {
            Install-AgentAdapter "claude"
            Install-AgentAdapter "cursor"
        }
        default {
            Write-Host "Usage: .\install.ps1 -Agent {claude|cursor|all}"
            return 1
        }
    }

    return 0
}

# ------------------------------------------------------------------------------
function Verify-Installation {
    Write-Info "Verifying installation..."

    $totalSkills = (Get-ChildItem $GlobalSkillsDir -Directory).Count

    Write-Host ""
    Write-Host "========================================"
    Write-Host "  Another Agent Skills — Setup Complete"
    Write-Host "========================================"
    Write-Host ""
    Write-Host "Remote repo:     $RemoteDir"
    Write-Host "Global skills:   $GlobalSkillsDir"
    Write-Host "Total skills:    $totalSkills"
    Write-Host ""

    $skillNames = @(
        "engineering-fundamentals", "frontend-web", "frontend-pwa",
        "frontend-mobile", "frontend-desktop", "backend-api-mastery",
        "fullstack-shipping", "spec-driven-development", "git-init-and-versioning",
        "architecture-analysis", "dev-environment-audit", "project-health-check",
        "project-metrics", "user-onboarding", "multi-agent-orchestration"
    )

    foreach ($name in $skillNames) {
        $path = Join-Path $GlobalSkillsDir $name
        if (Test-Path $path) {
            Write-Ok "$name → INSTALLED"
        } else {
            Write-Error "$name → MISSING"
        }
    }

    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  1. Reload your profile: . `$PROFILE  (or open new terminal)"
    Write-Host "  2. Test: Get-ChildItem ~/.config/opencode/skills/"
    Write-Host "  3. Use:  init-agents  (in any project)"
    Write-Host ""
    Write-Host "Global functions:"
    Write-Host "  init-agents          → Initialize agent rules in any project"
    Write-Host "  update-global-skills → Pull latest skill updates"
    Write-Host ""
    Write-Host "Note: For best experience, install OpenCode or use agent adapters:"
    Write-Host "  .\install.ps1 -Agent claude"
    Write-Host "  .\install.ps1 -Agent cursor"
    Write-Host "========================================"
}

# ------------------------------------------------------------------------------
function Main {
    Write-Host ""
    Write-Host "Another Agent Skills — Windows Installer"
    Write-Host "========================================"
    Write-Host ""

    if ($Agent) {
        $rc = Install-AgentAdapter $Agent
        if ($rc -eq 0) {
            Write-Host ""
            Write-Host "========================================"
            Write-Host "  Agent Adapter — Setup Complete"
            Write-Host "========================================"
            Write-Host ""
        }
        exit $rc
    }

    Check-Prerequisites
    Setup-RemoteSkills
    Link-RemoteSkills
    Install-CustomSkills
    Update-ShellProfile
    Verify-Installation
    Write-Ok "All done!"
}

Main
