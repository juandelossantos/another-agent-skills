# ==============================================================================
# Another Agent Skills — Windows PowerShell Installer
# ==============================================================================
# One-command setup for production-grade AI agent skills on Windows.
#
# Usage:
#   .\install.ps1                           # Full install (OpenCode + Claude Code)
#   .\install.ps1 -Agent claude             # Claude Code adapter only (project files + global skills)
#   .\install.ps1 -Agent cursor             # Cursor adapter only
#   .\install.ps1 -Agent all                # All adapters
#
# The 58 custom skills in skills/ are installed globally for BOTH OpenCode
# (~/.config/opencode/skills/) and Claude Code (~/.claude/skills/, or
# $env:CLAUDE_SKILLS_DIR) every run — no per-project setup needed.
# ==============================================================================

param(
    [string]$Agent = ""
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RemoteRepo = "https://github.com/addyosmani/agent-skills.git"
$RemoteDir = "$env:USERPROFILE\.config\opencode\.agent-skills-remote"
$GlobalSkillsDir = "$env:USERPROFILE\.config\opencode\skills"
$ClaudeSkillsDir = if ($env:CLAUDE_SKILLS_DIR) { $env:CLAUDE_SKILLS_DIR } else { "$env:USERPROFILE\.claude\skills" }
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
function Install-ClaudeGlobalSkills {
    # Installs this repo's skills/ into $ClaudeSkillsDir (Claude Code's global
    # skill discovery path) tracked via a manifest file, so re-runs can safely
    # remove skills THIS TOOL previously installed but that were since deleted
    # from the repo — without ever touching unrelated skills already present
    # in that directory (e.g. other custom Claude Code skills).
    Write-Info "Installing skills globally for Claude Code..."

    $customDir = Join-Path $RepoRoot "skills"
    if (-not (Test-Path $customDir)) {
        Write-Warn "No skills directory found at $customDir. Skipping."
        return
    }

    if (-not (Test-Path $ClaudeSkillsDir)) {
        New-Item -ItemType Directory -Path $ClaudeSkillsDir -Force | Out-Null
    }

    $manifest = Join-Path $ClaudeSkillsDir ".another-agent-skills-manifest"
    $manifestNames = @()
    if (Test-Path $manifest) {
        $manifestNames = @(Get-Content $manifest | Where-Object { $_ -ne "" })
    }

    $installed = 0
    $updated = 0
    Get-ChildItem $customDir -Directory | ForEach-Object {
        $skillPath = $_.FullName
        $skillName = $_.Name
        $skillMd = Join-Path $skillPath "SKILL.md"
        if (-not (Test-Path $skillMd)) { return }

        $target = Join-Path $ClaudeSkillsDir $skillName

        if (Test-Path $target) {
            $diff = Compare-Object -ReferenceObject (Get-ChildItem $skillPath -Recurse -File | Get-FileHash) `
                                    -DifferenceObject (Get-ChildItem $target -Recurse -File | Get-FileHash) `
                                    -Property Hash -ErrorAction SilentlyContinue
            if (-not $diff) {
                if ($manifestNames -notcontains $skillName) { $manifestNames += $skillName }
                return
            }
            $backup = "$target.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
            Copy-Item -Recurse $target $backup
            Write-Warn "Backed up previous: $skillName → $(Split-Path -Leaf $backup)"
            Remove-Item -Recurse -Force $target
            $updated++
        } else {
            $installed++
        }

        Copy-Item -Recurse $skillPath $target
        if ($manifestNames -notcontains $skillName) { $manifestNames += $skillName }
    }

    # Remove skills THIS TOOL installed previously but no longer in the repo.
    # Only acts on names recorded in the manifest.
    $removed = 0
    $keep = @()
    foreach ($name in $manifestNames) {
        if (Test-Path (Join-Path $customDir $name)) {
            $keep += $name
        } else {
            $staleTarget = Join-Path $ClaudeSkillsDir $name
            if (Test-Path $staleTarget) {
                Remove-Item -Recurse -Force $staleTarget
                Write-Warn "Removed deprecated skill from Claude Code skills: $name (no longer in repo)"
                $removed++
            }
        }
    }
    Set-Content $manifest ($keep -join "`n")

    Write-Ok "Claude Code skills: $installed installed, $updated updated, $removed removed → $ClaudeSkillsDir"
}

# ------------------------------------------------------------------------------
function Configure-ClaudeHooks {
    # Wires the 3 Claude Code hooks (edit-guard, pre-flight, commit-approval)
    # into the project's .claude/settings.json so they run automatically.
    # Merges into any existing settings.json (preserves unrelated keys and the
    # user's own hooks) using native ConvertFrom-Json/ConvertTo-Json — no jq
    # dependency needed on Windows.
    Write-Info "Wiring Claude Code hooks into .claude/settings.json..."

    if ($PSVersionTable.PSVersion.Major -lt 6) {
        Write-Warn "PowerShell $($PSVersionTable.PSVersion) detected — automatic hook wiring needs PowerShell 6+ (ConvertFrom-Json -AsHashtable)."
        Write-Warn "Install PowerShell 7 (https://aka.ms/powershell) and re-run, or wire .claude/settings.json manually (see docs/AGENT-ADAPTERS.md)."
        return
    }

    $settingsDir = Join-Path (Get-Location) ".claude"
    $settingsFile = Join-Path $settingsDir "settings.json"
    if (-not (Test-Path $settingsDir)) { New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null }

    $existing = @{}
    if (Test-Path $settingsFile) {
        try {
            $existing = Get-Content $settingsFile -Raw | ConvertFrom-Json -AsHashtable
        } catch {
            Write-Warn "$settingsFile is not valid JSON — skipping automatic hook wiring."
            Write-Warn "Fix or remove it, then re-run to enable automatic hooks."
            return
        }
    }

    $hooksDir = '"$CLAUDE_PROJECT_DIR"/.claude-plugin/agent-discipline/hooks'
    $cmdEditGuard = "bash $hooksDir/edit-guard.sh"
    $cmdPreFlight = "bash $hooksDir/pre-flight.sh"
    $cmdCommitApproval = "bash $hooksDir/commit-approval.sh"

    if (-not $existing.ContainsKey("hooks")) { $existing["hooks"] = @{} }
    if (-not $existing["hooks"].ContainsKey("PreToolUse")) { $existing["hooks"]["PreToolUse"] = @() }
    if (-not $existing["hooks"].ContainsKey("PostToolUse")) { $existing["hooks"]["PostToolUse"] = @() }

    function Merge-HookGroup {
        param($Groups, [string]$Matcher, [string[]]$Commands)
        $found = @($Groups) | Where-Object { $_.matcher -eq $Matcher }
        if ($found) {
            $existingCommands = @($found[0].hooks) | ForEach-Object { $_.command }
            foreach ($cmd in $Commands) {
                if ($existingCommands -notcontains $cmd) {
                    $found[0].hooks = @($found[0].hooks) + @(@{type = "command"; command = $cmd})
                }
            }
            return $Groups
        } else {
            $newGroup = @{matcher = $Matcher; hooks = @($Commands | ForEach-Object { @{type = "command"; command = $_} })}
            return @($Groups) + @($newGroup)
        }
    }

    $existing["hooks"]["PreToolUse"] = Merge-HookGroup -Groups $existing["hooks"]["PreToolUse"] -Matcher "Edit|Write" -Commands @($cmdEditGuard)
    $existing["hooks"]["PreToolUse"] = Merge-HookGroup -Groups $existing["hooks"]["PreToolUse"] -Matcher "Bash" -Commands @($cmdPreFlight, $cmdCommitApproval)
    $existing["hooks"]["PostToolUse"] = Merge-HookGroup -Groups $existing["hooks"]["PostToolUse"] -Matcher "Edit|Write" -Commands @($cmdEditGuard)

    # commit-approval only ever cares about git commands — scope it with "if"
    # so Claude Code skips spawning it for every other Bash call (ls, npm test, ...).
    $bashGroup = @($existing["hooks"]["PreToolUse"]) | Where-Object { $_.matcher -eq "Bash" }
    if ($bashGroup) {
        $commitHook = @($bashGroup[0].hooks) | Where-Object { $_.command -eq $cmdCommitApproval }
        if ($commitHook) { $commitHook[0]["if"] = "Bash(git *)" }
    }

    $existing | ConvertTo-Json -Depth 10 | Set-Content $settingsFile
    Write-Ok "Wired 3 hooks (edit-guard, pre-flight, commit-approval) into $settingsFile"
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
            Install-ClaudeGlobalSkills
            $src = Join-Path $templateDir "CLAUDE.md"
            $dst = Join-Path (Get-Location) "CLAUDE.md"
            if (Test-Path $dst) {
                $backup = "$dst.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
                Move-Item $dst $backup -Force
                Write-Warn "Backed up existing CLAUDE.md → $backup"
            }
            Copy-Item $src $dst
            Write-Ok "Installed CLAUDE.md → $dst"

            $pluginSrc = Join-Path $RepoRoot ".claude-plugin"
            $pluginDst = Join-Path (Get-Location) ".claude-plugin"
            if (Test-Path $pluginSrc) {
                Copy-Item -Recurse -Force $pluginSrc $pluginDst
                Write-Ok "Installed .claude-plugin/ → $pluginDst"
            }

            $scriptsSrc = Join-Path $RepoRoot "scripts"
            $scriptsDst = Join-Path (Get-Location) "scripts"
            if (Test-Path $scriptsSrc) {
                if (-not (Test-Path $scriptsDst)) { New-Item -ItemType Directory -Path $scriptsDst -Force | Out-Null }
                Copy-Item (Join-Path $scriptsSrc "*.sh") $scriptsDst -Force
                Write-Ok "Installed scripts/ → $scriptsDst"
            }

            Configure-ClaudeHooks
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
    if (Test-Path $ClaudeSkillsDir) {
        $claudeManifest = Join-Path $ClaudeSkillsDir ".another-agent-skills-manifest"
        $claudeCount = if (Test-Path $claudeManifest) { (Get-Content $claudeManifest | Where-Object { $_ -ne "" }).Count } else { 0 }
        Write-Ok "Claude Code skills → $claudeCount installed at $ClaudeSkillsDir"
    } else {
        Write-Error "Claude Code skills → MISSING at $ClaudeSkillsDir"
    }

    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  1. Reload your profile: . `$PROFILE  (or open new terminal)"
    Write-Host "  2. Test OpenCode:    Get-ChildItem ~/.config/opencode/skills/"
    Write-Host "  3. Test Claude Code: Get-ChildItem ~/.claude/skills/  (auto-discovered)"
    Write-Host "  4. Use:  init-agents  (in any project)"
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
    Install-ClaudeGlobalSkills
    Update-ShellProfile
    Verify-Installation
    Write-Ok "All done!"
}

Main
