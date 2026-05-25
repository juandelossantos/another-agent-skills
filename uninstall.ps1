# ==============================================================================
# Another Agent Skills — Windows Uninstaller (PowerShell)
# ==============================================================================
# Removes shell config blocks, global skills, and remote repo.
#
# Usage:
#   .\uninstall.ps1
# ==============================================================================

$ErrorActionPreference = "Stop"

$GlobalSkillsDir = "$env:USERPROFILE\.config\opencode\skills"
$RemoteDir = "$env:USERPROFILE\.config\opencode\.agent-skills-remote"

function Write-Info  { Write-Host "[INFO] $args" -ForegroundColor Blue }
function Write-Ok    { Write-Host "[OK] $args" -ForegroundColor Green }
function Write-Warn  { Write-Host "[WARN] $args" -ForegroundColor Yellow }
function Write-Error { Write-Host "[ERROR] $args" -ForegroundColor Red }

# ------------------------------------------------------------------------------
function Remove-ShellConfig {
    Write-Info "Removing PowerShell profile config block..."

    if (-not (Test-Path $PROFILE)) {
        Write-Info "No PowerShell profile found. Skipping."
        return
    }

    $content = Get-Content $PROFILE -Raw
    $pattern = "(?s)# >>> another-agent-skills-config.*?# <<< another-agent-skills-config"

    if ($content -notmatch $pattern) {
        Write-Info "No config block found in profile. Skipping."
        return
    }

    $backup = "$PROFILE.uninstall.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Copy-Item $PROFILE $backup
    Write-Ok "Profile backed up → $backup"

    $newContent = $content -replace $pattern, ""
    Set-Content $PROFILE $newContent
    Write-Ok "Removed config block from PowerShell profile."
}

# ------------------------------------------------------------------------------
function Remove-GlobalSkills {
    Write-Info "Removing global skills..."

    if (Test-Path $GlobalSkillsDir) {
        Remove-Item -Recurse -Force $GlobalSkillsDir
        Write-Ok "Removed $GlobalSkillsDir"
    } else {
        Write-Info "Skills directory not found. Skipping."
    }
}

# ------------------------------------------------------------------------------
function Remove-RemoteRepo {
    Write-Info "Removing remote skill repository..."

    if (Test-Path $RemoteDir) {
        Remove-Item -Recurse -Force $RemoteDir
        Write-Ok "Removed $RemoteDir"
    } else {
        Write-Info "Remote repository not found. Skipping."
    }
}

# ------------------------------------------------------------------------------
function Main {
    Write-Host ""
    Write-Host "Another Agent Skills — Windows Uninstaller"
    Write-Host "=========================================="
    Write-Host ""

    Write-Host "This will remove:"
    Write-Host "  - PowerShell profile config block"
    Write-Host "  - Global skills directory"
    Write-Host "  - Remote repo clone"
    Write-Host ""
    Write-Host "It will NOT remove:"
    Write-Host "  - Your user profile (~/.config/opencode/user-profile.json)"
    Write-Host ""

    $reply = Read-Host "Uninstall? [y/N]"
    if ($reply -notmatch '^(y|Y|yes|sí)$') {
        Write-Host "Aborted."
        exit 0
    }

    Remove-ShellConfig
    Remove-GlobalSkills
    Remove-RemoteRepo

    Write-Host ""
    Write-Host "========================================"
    Write-Host "  Uninstall Complete"
    Write-Host "========================================"
    Write-Host ""
    Write-Host "To also remove your user profile:"
    Write-Host "  Remove-Item ~/.config/opencode/user-profile.json"
    Write-Host ""
    Write-Host "To reinstall, run .\install.ps1 from the repo."
    Write-Ok "All done!"
}

Main
