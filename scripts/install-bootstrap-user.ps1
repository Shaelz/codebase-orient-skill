#Requires -Version 5.1
<#
.SYNOPSIS
    Installs the install-codebase-orient bootstrap skill to the user-level Claude Code skills directory.

.DESCRIPTION
    Copies skills/install-codebase-orient/ to $HOME\.claude\skills\install-codebase-orient\.
    Once installed, the skill can be invoked from any project with /install-codebase-orient.

.PARAMETER Force
    Overwrite an existing installation. Without this flag the script exits if the
    destination already exists.

.EXAMPLE
    .\install-bootstrap-user.ps1
    .\install-bootstrap-user.ps1 -Force
#>
[CmdletBinding()]
param(
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceDir = Join-Path $scriptDir '..\skills\install-codebase-orient'
$destDir   = Join-Path $HOME '.claude\skills\install-codebase-orient'

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
Write-Host "Note: this is the bootstrap skill (install-codebase-orient), not the"
Write-Host "orientation skill (codebase-orient). The bootstrap skill runs a first-pass"
Write-Host "orientation and generates .claude/skills/codebase-orient/ inside a project."
Write-Host "To install the orientation skill itself, use install-user.ps1 instead."
Write-Host ""
Write-Host "Verification:"
Write-Host "  1. Restart Claude Code if it is currently running."
Write-Host "  2. Open any project and type: /install-codebase-orient"
Write-Host "  3. The skill will orient Claude and generate docs/ai/ and"
Write-Host "     .claude/skills/codebase-orient/SKILL.md inside the project."
