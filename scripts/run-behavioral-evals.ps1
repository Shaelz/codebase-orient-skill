#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ForwardArgs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$nodeScript = Join-Path $scriptDir 'run-behavioral-evals.mjs'

if (-not (Test-Path -LiteralPath $nodeScript)) {
    throw "Missing Node harness script: $nodeScript"
}

$nodeCommand = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeCommand) {
    throw 'Unable to find node.exe on PATH.'
}

& $nodeCommand.Source $nodeScript @ForwardArgs
exit $LASTEXITCODE
