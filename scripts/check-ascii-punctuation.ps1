#Requires -Version 5.1
<#
.SYNOPSIS
    Scans tracked repo-maintenance text files for forbidden smart punctuation.

.DESCRIPTION
    Checks files tracked by git for em dashes, en dashes, curly quotes,
    ellipsis, non-breaking spaces, and Unicode math symbols that must not
    appear in SKILL.md files, README, CHANGELOG, scripts, or prompt snippets.

    Run this before release or broad text changes to catch regressions.

.EXAMPLE
    .\scripts\check-ascii-punctuation.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location (Join-Path $scriptDir '..')

$forbidden = [ordered]@{
    [char]0x2014 = 'em-dash'
    [char]0x2013 = 'en-dash'
    [char]0x201C = 'curly-dquote-open'
    [char]0x201D = 'curly-dquote-close'
    [char]0x2018 = 'curly-squote-open'
    [char]0x2019 = 'curly-squote-close'
    [char]0x2026 = 'ellipsis'
    [char]0x00A0 = 'non-breaking-space'
    [char]0x2264 = 'less-than-or-equal'
    [char]0x2265 = 'greater-than-or-equal'
}

$extensions = @('.md', '.txt', '.ps1', '.sh', '.yml', '.yaml', '.json', '.toml', '.ini')

$tracked = git ls-files | Where-Object {
    $ext = [System.IO.Path]::GetExtension($_)
    $extensions -contains $ext
}

$totalHits = 0

foreach ($rel in $tracked) {
    if (-not (Test-Path $rel)) { continue }
    $content = Get-Content $rel -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if (-not $content) { continue }
    $lines = $content -split "`n"
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $found = @()
        foreach ($kv in $forbidden.GetEnumerator()) {
            if ($lines[$i].Contains($kv.Key)) { $found += $kv.Value }
        }
        if ($found.Count -gt 0) {
            $totalHits++
            Write-Host "FAIL  $rel`:$($i + 1)  [$($found -join ', ')]  $($lines[$i].Trim().Substring(0, [Math]::Min(72, $lines[$i].Trim().Length)))"
        }
    }
}

Write-Host ""
if ($totalHits -eq 0) {
    Write-Host "check-ascii-punctuation: all tracked text files are clean."
    exit 0
} else {
    Write-Host "check-ascii-punctuation: $totalHits line(s) with forbidden smart punctuation. See above." -ForegroundColor Red
    exit 1
}
