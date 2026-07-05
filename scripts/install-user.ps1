#Requires -Version 5.1
[CmdletBinding()]
param([switch]$Force, [switch]$Clean)
$source = Join-Path $PSScriptRoot '..\skills\codebase-orient'
$dest = Join-Path $HOME '.claude\skills\codebase-orient'
& (Join-Path $PSScriptRoot 'install-package.ps1') -Package codebase-orient -SourceDir $source -DestinationDir $dest -Force:$Force -Clean:$Clean
Write-Host 'Invoke with /codebase-orient. Restart Claude Code if needed.'
