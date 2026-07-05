#Requires -Version 5.1
[CmdletBinding()]
param([switch]$Force, [switch]$Clean)
$source = Join-Path $PSScriptRoot '..\skills\install-codebase-orient'
$dest = Join-Path $HOME '.claude\skills\install-codebase-orient'
& (Join-Path $PSScriptRoot 'install-package.ps1') -Package install-codebase-orient -SourceDir $source -DestinationDir $dest -Force:$Force -Clean:$Clean
Write-Host 'Invoke the bootstrap with /install-codebase-orient. Restart Claude Code if needed.'
