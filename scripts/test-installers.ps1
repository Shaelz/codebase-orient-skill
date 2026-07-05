#Requires -Version 5.1
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$helper = Join-Path $PSScriptRoot 'install-package.ps1'
$repoRoot = Split-Path -Parent $PSScriptRoot
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ("orient-installer-tests-" + [guid]::NewGuid().ToString('N'))

function Assert-Throws {
    param([scriptblock]$Action, [string]$Message)
    try { & $Action } catch { return }
    throw $Message
}

New-Item -ItemType Directory -Path $testRoot | Out-Null
try {
    foreach ($package in @('codebase-orient', 'install-codebase-orient')) {
        $source = Join-Path $repoRoot "skills\$package"
        $dest = Join-Path $testRoot "$package-dest"

        & $helper -Package $package -SourceDir $source -DestinationDir $dest
        Assert-Throws { & $helper -Package $package -SourceDir $source -DestinationDir $dest } "Normal install did not refuse existing $package destination."

        Set-Content -LiteralPath (Join-Path $dest 'extra.txt') -Value 'preserve' -NoNewline
        & $helper -Package $package -SourceDir $source -DestinationDir $dest -Force
        if (-not (Test-Path -LiteralPath (Join-Path $dest 'extra.txt'))) { throw "Overlay reinstall deleted an extra $package file." }

        & $helper -Package $package -SourceDir $source -DestinationDir $dest -Clean
        if (Test-Path -LiteralPath (Join-Path $dest 'extra.txt')) { throw "Clean reinstall retained an extra $package file." }

        Assert-Throws { & $helper -Package $package -SourceDir $source -DestinationDir $dest -Force -Clean } 'Conflicting flags were accepted.'

        Remove-Item -LiteralPath (Join-Path $dest 'SKILL.md') -Force
        New-Item -ItemType Directory -Path (Join-Path $dest 'SKILL.md') | Out-Null
        Assert-Throws { & $helper -Package $package -SourceDir $source -DestinationDir $dest -Force } 'Overlay managed type conflict was accepted.'

        Remove-Item -LiteralPath $dest -Recurse -Force
        New-Item -ItemType Directory -Path $dest | Out-Null
        Set-Content -LiteralPath (Join-Path $dest 'sentinel.txt') -Value 'keep' -NoNewline
        $badSource = Join-Path $testRoot "$package-bad-source"
        Copy-Item -LiteralPath $source -Destination $badSource -Recurse
        Add-Content -LiteralPath (Join-Path $badSource 'SKILL.md') -Value 'corrupt'
        Assert-Throws { & $helper -Package $package -SourceDir $badSource -DestinationDir $dest -Clean } 'Malformed source package was accepted.'
        if (-not (Test-Path -LiteralPath (Join-Path $dest 'sentinel.txt'))) { throw 'Source validation failure mutated the destination.' }
    }

    Write-Host 'Installer tests passed.'
}
finally {
    if (Test-Path -LiteralPath $testRoot) { Remove-Item -LiteralPath $testRoot -Recurse -Force }
}
