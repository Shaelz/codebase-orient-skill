#Requires -Version 5.1
<#
.SYNOPSIS
    Installs the codebase-orient skill to the user-level Claude Code skills directory.

.PARAMETER Force
    Overwrite an existing installation. Without this flag the script exits if the
    destination already exists.

.EXAMPLE
    .\install-user.ps1
    .\install-user.ps1 -Force
#>
[CmdletBinding()]
param(
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceDir  = Join-Path $scriptDir '..\skills\codebase-orient'
$destDir    = Join-Path $HOME '.claude\skills\codebase-orient'

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
Write-Host "Verification:"
Write-Host "  1. Restart Claude Code if it is currently running."
Write-Host "  2. Open any project and type: /codebase-orient"
Write-Host "  3. The skill should activate and begin orienting Claude to the codebase."
