#Requires -Version 5.1
<#
.SYNOPSIS
    Installs the codebase-orient skill into the current project's .agents/skills directory.

    Run this from the root of the project where you want to install the skill.

.PARAMETER Force
    Overwrite an existing installation. Without this flag the script exits if the
    destination already exists.

.EXAMPLE
    .\path\to\install-codex-project.ps1
    .\path\to\install-codex-project.ps1 -Force
#>
[CmdletBinding()]
param(
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceDir  = Join-Path $scriptDir '..\skills\codebase-orient'
$destDir    = Join-Path (Get-Location) '.agents\skills\codebase-orient'

$sourceDir = (Resolve-Path $sourceDir).Path

Write-Host "Source : $sourceDir"
Write-Host "Dest   : $destDir"

if (Test-Path $destDir) {
    if (-not $Force) {
        Write-Error "Destination already exists: $destDir`nRe-run with -Force to overwrite."
        exit 1
    }
    Write-Host "[-Force] Overwriting existing installation."
}

if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}

Copy-Item -Path (Join-Path $sourceDir '*') -Destination $destDir -Recurse -Force
Write-Host "  Copied skill contents."

Write-Host ""
Write-Host "Installation complete."
Write-Host ""
Write-Host "Optional: to track only the skill file in git (not other .agents internals),"
Write-Host "add the following to your project .gitignore:"
Write-Host ""
Write-Host "  # Ignore all .agents internals except the skill"
Write-Host "  .agents/*"
Write-Host "  !.agents/skills/"
Write-Host "  !.agents/skills/codebase-orient/"
Write-Host "  !.agents/skills/codebase-orient/SKILL.md"
Write-Host ""
Write-Host "Next step:"
Write-Host "  1. Open this project in Codex."
Write-Host "  2. Codex should detect the installed skill automatically."
Write-Host "  3. If codebase-orient does not appear, restart Codex."
Write-Host "  4. In Codex CLI/IDE, run /skills or type `$ to mention/select"
Write-Host "     codebase-orient, then ask it to orient the repo."
