#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Package,
    [Parameter(Mandatory = $true)][string]$SourceDir,
    [Parameter(Mandatory = $true)][string]$DestinationDir,
    [switch]$Force,
    [switch]$Clean
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($Force -and $Clean) {
    throw 'Conflicting flags: select overlay reinstall (-Force) or clean reinstall (-Clean), not both.'
}

$inventoryPath = Join-Path $PSScriptRoot 'package-inventory.tsv'

function Get-PackageInventory {
    param([string]$PackageName)

    $entries = foreach ($line in Get-Content -LiteralPath $inventoryPath) {
        if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith('#')) { continue }
        $parts = $line -split "`t"
        if ($parts.Count -ne 4) { throw "Malformed inventory line: $line" }
        if ($parts[0] -eq $PackageName) {
            [pscustomobject]@{ Path = $parts[1]; Digest = $parts[2]; Newlines = $parts[3] }
        }
    }
    if (-not $entries) { throw "No inventory entry found for package: $PackageName" }
    return @($entries)
}

function Get-NormalizedDigest {
    param([string]$Path, [string]$NewlinePolicy)

    if ($NewlinePolicy -ne 'lf') { throw "Unsupported newline policy: $NewlinePolicy" }
    $content = [IO.File]::ReadAllText($Path).Replace("`r`n", "`n").Replace("`r", "`n")
    $bytes = [Text.Encoding]::UTF8.GetBytes($content)
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return (($sha.ComputeHash($bytes) | ForEach-Object ToString x2) -join '') }
    finally { $sha.Dispose() }
}

function Assert-Package {
    param([string]$Root, [object[]]$Entries, [string]$Label)

    if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
        throw "$Label package directory is missing: $Root"
    }
    foreach ($entry in $Entries) {
        $path = Join-Path $Root $entry.Path
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "$Label package is missing managed file: $($entry.Path)"
        }
        $actual = Get-NormalizedDigest -Path $path -NewlinePolicy $entry.Newlines
        if ($actual -ne $entry.Digest) {
            throw "$Label package content mismatch: $($entry.Path)"
        }
    }
}

function Copy-ManagedFiles {
    param([string]$From, [string]$To, [object[]]$Entries)

    foreach ($entry in $Entries) {
        $source = Join-Path $From $entry.Path
        $target = Join-Path $To $entry.Path
        if (Test-Path -LiteralPath $target -PathType Container) {
            throw "Managed path is a directory but must be a file: $($entry.Path)"
        }
        $parent = Split-Path -Parent $target
        if (-not (Test-Path -LiteralPath $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        Copy-Item -LiteralPath $source -Destination $target -Force
    }
}

function Get-ExtraFiles {
    param([string]$Root, [object[]]$Entries)

    $managed = @{}
    foreach ($entry in $Entries) { $managed[$entry.Path.Replace('\', '/')] = $true }
    foreach ($file in Get-ChildItem -LiteralPath $Root -Recurse -File -Force) {
        $relative = $file.FullName.Substring($Root.TrimEnd('\', '/').Length).TrimStart('\', '/').Replace('\', '/')
        if (-not $managed.ContainsKey($relative)) { $relative }
    }
}

$entries = Get-PackageInventory -PackageName $Package
$SourceDir = (Resolve-Path -LiteralPath $SourceDir).Path
$destinationExists = Test-Path -LiteralPath $DestinationDir

Write-Host "Source : $SourceDir"
Write-Host "Dest   : $DestinationDir"

# Source validation is deliberately before any destination mutation.
Assert-Package -Root $SourceDir -Entries $entries -Label 'Source'

if ($destinationExists -and -not $Force -and -not $Clean) {
    throw "Destination already exists: $DestinationDir`nSelect -Force for overlay reinstall or -Clean for clean reinstall."
}

if ($Force) {
    if (-not (Test-Path -LiteralPath $DestinationDir -PathType Container)) {
        throw "Overlay reinstall destination must be a directory: $DestinationDir"
    }
    Copy-ManagedFiles -From $SourceDir -To $DestinationDir -Entries $entries
    Assert-Package -Root $DestinationDir -Entries $entries -Label 'Installed'
    $extras = @(Get-ExtraFiles -Root $DestinationDir -Entries $entries)
    Write-Host 'Overlay reinstall complete.'
    if ($extras.Count -gt 0) {
        Write-Host 'Extra destination files were preserved:'
        $extras | ForEach-Object { Write-Host "  $_" }
    }
    return
}

$parent = Split-Path -Parent $DestinationDir
if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
$leaf = Split-Path -Leaf $DestinationDir
$stage = Join-Path $parent ".$leaf.stage.$([guid]::NewGuid().ToString('N'))"
$backup = Join-Path $parent ".$leaf.backup.$([guid]::NewGuid().ToString('N'))"
$movedExisting = $false

try {
    New-Item -ItemType Directory -Path $stage | Out-Null
    Copy-ManagedFiles -From $SourceDir -To $stage -Entries $entries
    Assert-Package -Root $stage -Entries $entries -Label 'Staged'

    if ($destinationExists) {
        Move-Item -LiteralPath $DestinationDir -Destination $backup
        $movedExisting = $true
    }
    Move-Item -LiteralPath $stage -Destination $DestinationDir
    Assert-Package -Root $DestinationDir -Entries $entries -Label 'Installed'
    if ($movedExisting) { Remove-Item -LiteralPath $backup -Recurse -Force }
}
catch {
    if ($movedExisting -and -not (Test-Path -LiteralPath $DestinationDir) -and (Test-Path -LiteralPath $backup)) {
        Move-Item -LiteralPath $backup -Destination $DestinationDir
    }
    throw
}
finally {
    if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage -Recurse -Force }
}

if ($Clean) { Write-Host 'Clean reinstall complete.' }
else { Write-Host 'Installation complete.' }
