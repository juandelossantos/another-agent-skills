# bootstrap.ps1 — thin Windows wrapper for Another Agent Skills (P9.7).
#
# POSIX-first: this does NOT reimplement any gate. It locates Git Bash and
# delegates to bootstrap.sh, which does the real (pinned, integrity-verified)
# install. Requirement: Git for Windows — https://git-scm.com/download/win
#
# Usage:
#   .\bootstrap.ps1 --version v6.3.0
#   .\bootstrap.ps1 --dry-run
#   .\bootstrap.ps1 --uninstall

param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Args
)

$ErrorActionPreference = "Stop"

function Find-GitBash {
    $candidates = @(
        "$env:ProgramFiles\Git\bin\bash.exe",
        "${env:ProgramFiles(x86)}\Git\bin\bash.exe",
        "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe"
    )
    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path $candidate)) { return $candidate }
    }
    $cmd = Get-Command bash.exe -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return $null
}

$bash = Find-GitBash
if (-not $bash) {
    Write-Host "[ERROR] Git for Windows (Git Bash) is required: https://git-scm.com/download/win" -ForegroundColor Red
    exit 1
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
& $bash "$scriptDir/bootstrap.sh" @Args
exit $LASTEXITCODE
