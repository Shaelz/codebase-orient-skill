#Requires -Version 5.1
<#
.SYNOPSIS
    Installs the codebase-orient skill into the current project's .claude/skills directory.

    Run this from the root of the project where you want to install the skill.

.PARAMETER Force
    Overwrite an existing installation. Without this flag the script exits if the
    destination already exists.

.EXAMPLE
    .\path\to\install-project.ps1
    .\path\to\install-project.ps1 -Force
#>
[CmdletBinding()]
param(
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceDir  = Join-Path $scriptDir '..\skills\codebase-orient'
$destDir    = Join-Path (Get-Location) '.claude\skills\codebase-orient'

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

Get-ChildItem -Path $sourceDir -File | ForEach-Object {
    $dest = Join-Path $destDir $_.Name
    Copy-Item -Path $_.FullName -Destination $dest -Force
    Write-Host "  Copied: $($_.Name)"
}

Write-Host ""
Write-Host "Installation complete."
Write-Host ""
Write-Host "Optional: to track only the skill file in git (not other .claude internals),"
Write-Host "add the following to your project .gitignore:"
Write-Host ""
Write-Host "  # Ignore all .claude internals except the skill"
Write-Host "  .claude/"
Write-Host "  !.claude/skills/"
Write-Host "  !.claude/skills/codebase-orient/"
Write-Host "  !.claude/skills/codebase-orient/SKILL.md"
Write-Host ""
Write-Host "Note: this script does not touch .claude/settings.local.json."
