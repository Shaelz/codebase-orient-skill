#Requires -Version 5.1
<#
.SYNOPSIS
    Compares canonical and bootstrap shared-rule blocks for drift.

.DESCRIPTION
    Extracts explicitly marked shared-rule blocks from:
    - skills/codebase-orient/SKILL.md
    - skills/install-codebase-orient/SKILL.md

    The check compares only blocks that are intended to stay synchronized.
    Bootstrap-only setup text, framework probes, discovery-order structure,
    output-doc examples, and other intentionally different sections are
    excluded by leaving them outside the shared-rule markers.

.EXAMPLE
    .\scripts\check-shared-rule-drift.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Join-Path $scriptDir '..'
Set-Location $repoRoot

$canonicalPath = Join-Path $repoRoot 'skills/codebase-orient/SKILL.md'
$bootstrapPath = Join-Path $repoRoot 'skills/install-codebase-orient/SKILL.md'

$blockIds = @(
    'when-to-use-this-skill',
    'token-aware-use-guidance',
    'normal-mode-vs-dry-run-mode',
    'confidence-labels',
    'docs-as-hypotheses-rule',
    'ci-deployment-precision-rule',
    'read-depth-heuristic',
    'cheap-artifact-glob-rule',
    'open-question-quality-rule',
    'change-surfaces-mapping-guidance',
    'no-date-only-churn-rule',
    'cross-file-consistency-rule',
    'orientation-completion-rule',
    'orientation-report-discipline',
    'project-local-specialization-rule',
    'hidden-risk-reporting-rule',
    'source-of-truth-drift-detection-rule'
)

$markerPattern = '<!-- shared-rule:(start|end):([a-z0-9-]+) -->'

function Get-LeadingWhitespaceWidth {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Line
    )

    $width = 0
    foreach ($char in $Line.ToCharArray()) {
        if ($char -eq ' ') {
            $width++
            continue
        }
        if ($char -eq "`t") {
            $width += 4
            continue
        }
        break
    }

    return $width
}

function Remove-CommonOuterIndentation {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]] $Lines
    )

    $nonBlank = @($Lines | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($nonBlank.Count -eq 0) {
        return ,$Lines
    }

    $minIndent = ($nonBlank | ForEach-Object { Get-LeadingWhitespaceWidth -Line $_ } | Measure-Object -Minimum).Minimum
    if ($minIndent -le 0) {
        return ,$Lines
    }

    $normalized = foreach ($line in $Lines) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            $line.TrimEnd()
            continue
        }

        $remaining = $minIndent
        $index = 0
        while ($remaining -gt 0 -and $index -lt $line.Length) {
            if ($line[$index] -eq ' ') {
                $remaining--
                $index++
                continue
            }
            if ($line[$index] -eq "`t") {
                if ($remaining -lt 4) {
                    break
                }
                $remaining -= 4
                $index++
                continue
            }
            break
        }
        $line.Substring($index).TrimEnd()
    }

    return ,$normalized
}

function Remove-CommonBlockquoteWrapper {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]] $Lines
    )

    $nonBlank = @($Lines | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($nonBlank.Count -eq 0) {
        return ,$Lines
    }

    $allQuoted = $true
    foreach ($line in $nonBlank) {
        if ($line -notmatch '^\s*>\s?') {
            $allQuoted = $false
            break
        }
    }

    if (-not $allQuoted) {
        return ,$Lines
    }

    $normalized = foreach ($line in $Lines) {
        $line.TrimEnd() -replace '^(\s*)>\s?', '$1'
    }

    return ,$normalized
}

function Normalize-HeadingDepth {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]] $Lines
    )

    $headingLevels = @(
        $Lines |
            ForEach-Object {
                if ($_ -match '^\s*(#{1,6})\s+') {
                    $Matches[1].Length
                }
            } |
            Where-Object { $_ -is [int] }
    )

    $baseHeadingLevel = $null
    if ($headingLevels.Count -gt 0) {
        $baseHeadingLevel = ($headingLevels | Measure-Object -Minimum).Minimum
    }

    $normalized = foreach ($line in $Lines) {
        if ($line -match '^(\s*)#{1,6}\s+(.*)$') {
            $headingLevel = ($line -replace '^(\s*)(#{1,6})\s+(.*)$', '$2').Length
            if ($null -eq $baseHeadingLevel) {
                '{0}{1} {2}' -f $Matches[1], ('#' * $headingLevel), $Matches[2].TrimEnd()
            } else {
                $relativeLevel = $headingLevel - $baseHeadingLevel + 1
                '{0}{1} {2}' -f $Matches[1], ('#' * $relativeLevel), $Matches[2].TrimEnd()
            }
        } else {
            $line.TrimEnd()
        }
    }

    return ,$normalized
}

function Trim-OuterBlankLines {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]] $Lines
    )

    $start = 0
    $end = $Lines.Count - 1

    while ($start -le $end -and [string]::IsNullOrWhiteSpace($Lines[$start])) {
        $start++
    }
    while ($end -ge $start -and [string]::IsNullOrWhiteSpace($Lines[$end])) {
        $end--
    }

    if ($start -gt $end) {
        return @('')
    }

    return ,($Lines[$start..$end])
}

function Get-SharedRuleBlockRecords {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    $raw = Get-Content -Raw -Encoding UTF8 $Path
    $markerMatches = [regex]::Matches($raw, $markerPattern)

    $records = New-Object System.Collections.Generic.List[object]
    $startIds = New-Object System.Collections.Generic.List[string]
    $endIds = New-Object System.Collections.Generic.List[string]
    $topologyErrors = New-Object System.Collections.Generic.List[string]
    $openBlock = $null

    foreach ($match in $markerMatches) {
        $markerType = $match.Groups[1].Value
        $markerId = $match.Groups[2].Value

        if ($markerType -eq 'start') {
            $startIds.Add($markerId)

            if ($null -ne $openBlock) {
                $topologyErrors.Add(
                    "nested start marker in ${Path}: saw start:$markerId before closing start:$($openBlock.Id)"
                )
            }

            $openBlock = [pscustomobject]@{
                Id = $markerId
                StartMarkerIndex = $match.Index
                ContentStartIndex = $match.Index + $match.Length
            }
            continue
        }

        $endIds.Add($markerId)

        if ($null -eq $openBlock) {
            $topologyErrors.Add(
                "orphan end marker in ${Path}: end:$markerId has no matching start"
            )
            continue
        }

        if ($openBlock.Id -ne $markerId) {
            $topologyErrors.Add(
                "mismatched end marker in ${Path}: opened start:$($openBlock.Id) but closed end:$markerId"
            )
            $openBlock = $null
            continue
        }

        $rawContent = $raw.Substring($openBlock.ContentStartIndex, $match.Index - $openBlock.ContentStartIndex) -replace "`r", ''
        $lines = $rawContent -split "`n"
        $trimmed = Trim-OuterBlankLines -Lines $lines
        $deindented = Remove-CommonOuterIndentation -Lines $trimmed
        $unquoted = Remove-CommonBlockquoteWrapper -Lines $deindented
        $normalizedLines = Normalize-HeadingDepth -Lines $unquoted

        $records.Add([pscustomobject]@{
            Id = $markerId
            NormalizedContent = ($normalizedLines -join "`n")
        })

        $openBlock = $null
    }

    if ($null -ne $openBlock) {
        $topologyErrors.Add(
            "unclosed start marker in ${Path}: start:$($openBlock.Id) has no matching end"
        )
    }

    if ($startIds.Count -ne $endIds.Count -or $startIds.Count -ne $records.Count) {
        $topologyErrors.Add(
            "marker topology mismatch in ${Path}: start markers=$($startIds.Count), end markers=$($endIds.Count), complete blocks=$($records.Count)"
        )
    }

    return [pscustomobject]@{
        Path = $Path
        Records = $records
        StartIds = @($startIds)
        EndIds = @($endIds)
        Errors = @($topologyErrors)
    }
}

function Write-BlockDiff {
    param(
        [Parameter(Mandatory = $true)]
        [string] $BlockId,
        [Parameter(Mandatory = $true)]
        [string] $CanonicalContent,
        [Parameter(Mandatory = $true)]
        [string] $BootstrapContent
    )

    $canonicalTemp = New-TemporaryFile
    $bootstrapTemp = New-TemporaryFile
    try {
        Set-Content -LiteralPath $canonicalTemp -Value $CanonicalContent -Encoding UTF8
        Set-Content -LiteralPath $bootstrapTemp -Value $BootstrapContent -Encoding UTF8
        Write-Host "FAIL  shared-rule block drift: $BlockId" -ForegroundColor Red
        & git diff --no-index -- $canonicalTemp $bootstrapTemp
    } finally {
        Remove-Item -LiteralPath $canonicalTemp, $bootstrapTemp -ErrorAction SilentlyContinue
    }
}

$canonicalResult = Get-SharedRuleBlockRecords -Path $canonicalPath
$bootstrapResult = Get-SharedRuleBlockRecords -Path $bootstrapPath

$failed = $false

foreach ($fileInfo in @(
    @{ Label = 'canonical'; Result = $canonicalResult },
    @{ Label = 'bootstrap'; Result = $bootstrapResult }
)) {
    foreach ($validationError in $fileInfo.Result.Errors) {
        Write-Host "FAIL  $validationError" -ForegroundColor Red
        $failed = $true
    }

    $startUnexpected = @($fileInfo.Result.StartIds | Where-Object { $blockIds -notcontains $_ } | Sort-Object -Unique)
    if ($startUnexpected.Count -gt 0) {
        Write-Host "FAIL  unexpected $($fileInfo.Label) start block ids in $($fileInfo.Result.Path): $($startUnexpected -join ', ')" -ForegroundColor Red
        $failed = $true
    }

    $endUnexpected = @($fileInfo.Result.EndIds | Where-Object { $blockIds -notcontains $_ } | Sort-Object -Unique)
    if ($endUnexpected.Count -gt 0) {
        Write-Host "FAIL  unexpected $($fileInfo.Label) end block ids in $($fileInfo.Result.Path): $($endUnexpected -join ', ')" -ForegroundColor Red
        $failed = $true
    }

    $ids = @($fileInfo.Result.Records | ForEach-Object { $_.Id })
    $unexpected = @($ids | Where-Object { $blockIds -notcontains $_ } | Sort-Object -Unique)
    if ($unexpected.Count -gt 0) {
        Write-Host "FAIL  unexpected $($fileInfo.Label) complete block ids in $($fileInfo.Result.Path): $($unexpected -join ', ')" -ForegroundColor Red
        $failed = $true
    }

    $duplicates = @(
        $ids |
            Group-Object |
            Where-Object { $_.Count -gt 1 } |
            Sort-Object Name
    )
    if ($duplicates.Count -gt 0) {
        $duplicateText = $duplicates | ForEach-Object { '{0} (x{1})' -f $_.Name, $_.Count }
        Write-Host "FAIL  duplicate $($fileInfo.Label) complete block ids in $($fileInfo.Result.Path): $($duplicateText -join ', ')" -ForegroundColor Red
        $failed = $true
    }

    $startDuplicates = @(
        $fileInfo.Result.StartIds |
            Group-Object |
            Where-Object { $_.Count -gt 1 } |
            Sort-Object Name
    )
    if ($startDuplicates.Count -gt 0) {
        $duplicateText = $startDuplicates | ForEach-Object { '{0} (x{1})' -f $_.Name, $_.Count }
        Write-Host "FAIL  duplicate $($fileInfo.Label) start marker ids in $($fileInfo.Result.Path): $($duplicateText -join ', ')" -ForegroundColor Red
        $failed = $true
    }

    $endDuplicates = @(
        $fileInfo.Result.EndIds |
            Group-Object |
            Where-Object { $_.Count -gt 1 } |
            Sort-Object Name
    )
    if ($endDuplicates.Count -gt 0) {
        $duplicateText = $endDuplicates | ForEach-Object { '{0} (x{1})' -f $_.Name, $_.Count }
        Write-Host "FAIL  duplicate $($fileInfo.Label) end marker ids in $($fileInfo.Result.Path): $($duplicateText -join ', ')" -ForegroundColor Red
        $failed = $true
    }
}

$canonicalMap = @{}
foreach ($record in $canonicalResult.Records) {
    if (-not $canonicalMap.ContainsKey($record.Id)) {
        $canonicalMap[$record.Id] = $record
    }
}

$bootstrapMap = @{}
foreach ($record in $bootstrapResult.Records) {
    if (-not $bootstrapMap.ContainsKey($record.Id)) {
        $bootstrapMap[$record.Id] = $record
    }
}

foreach ($blockId in $blockIds) {
    if (-not $canonicalMap.ContainsKey($blockId)) {
        Write-Host "FAIL  missing canonical block: $blockId" -ForegroundColor Red
        $failed = $true
    }
    if (-not $bootstrapMap.ContainsKey($blockId)) {
        Write-Host "FAIL  missing bootstrap block: $blockId" -ForegroundColor Red
        $failed = $true
    }
}

if ($failed) {
    exit 1
}

foreach ($blockId in $blockIds) {
    if ($canonicalMap[$blockId].NormalizedContent -ne $bootstrapMap[$blockId].NormalizedContent) {
        $failed = $true
        Write-BlockDiff -BlockId $blockId -CanonicalContent $canonicalMap[$blockId].NormalizedContent -BootstrapContent $bootstrapMap[$blockId].NormalizedContent
    } else {
        Write-Host "PASS  shared-rule block: $blockId"
    }
}

if ($failed) {
    Write-Host ''
    Write-Host 'check-shared-rule-drift: shared-rule drift found. See diff above.' -ForegroundColor Red
    exit 1
}

Write-Host ''
Write-Host 'check-shared-rule-drift: all shared-rule blocks are synchronized.'
