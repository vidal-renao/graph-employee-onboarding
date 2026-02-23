<#
.SYNOPSIS
  Employee offboarding automation (DryRun by default).

.DESCRIPTION
  Reads users from CSV and simulates offboarding actions using a Graph abstraction layer (stub for now).
  Produces logs and a CSV report per execution.

  Mode:
    - DryRun (default): no production changes, only logs what would happen
    - Live: reserved for future real Microsoft Graph implementation

#>

[CmdletBinding()]
param (
    [string]$CsvPath = "data/offboarding.sample.csv",
    [string]$OutDir  = "out",

    [ValidateSet("DryRun","Live")]
    [string]$Mode    = "DryRun"
)

# -------------------------
# Helpers
# -------------------------
function Write-Log {
    param(
        [ValidateSet("INFO","WARN","ERROR","DRYRUN")] [string]$Level,
        [string]$Message
    )
    $line = "{0} [{1}] {2}" -f (Get-Date).ToString("s"), $Level, $Message
    Add-Content -Path $Global:LogFile -Value $line
    Write-Host $line
}

function Normalize-Text {
    param([string]$Value)
    if ($null -eq $Value) { return "" }
    return $Value.Trim()
}

function Parse-Bool {
    param([string]$Value)
    $v = (Normalize-Text $Value).ToLower()
    return ($v -eq "true" -or $v -eq "1" -or $v -eq "yes" -or $v -eq "y")
}

# -------------------------
# Init output
# -------------------------
if (-not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir | Out-Null
}

$timestamp      = (Get-Date).ToString("yyyyMMdd-HHmmss")
$Global:LogFile = Join-Path $OutDir "offboarding-$timestamp.log"
$reportFile     = Join-Path $OutDir "offboarding-report-$timestamp.csv"

Write-Host "=== Employee Offboarding ($Mode) ===" -ForegroundColor Cyan
Write-Log -Level INFO -Message "Start. Mode=$Mode CsvPath=$CsvPath OutDir=$OutDir"

if (-Not (Test-Path $CsvPath)) {
    Write-Log -Level ERROR -Message "CSV not found: $CsvPath"
    exit 1
}

# -------------------------
# Load Graph layer (stub) - robust for CI/Linux
# -------------------------
try {
    $graphPath = Join-Path $PSScriptRoot "Graph"
    if (-not (Test-Path $graphPath)) { throw "Graph path not found: $graphPath" }

    $graphFiles = @(
        "Graph-Auth.ps1",
        "Graph-Users.ps1",
        "Graph-Groups.ps1",
        "Graph-Licenses.ps1"
    )

    foreach ($file in $graphFiles) {
        $fullPath = Join-Path $graphPath $file
        if (-not (Test-Path $fullPath)) { throw "Graph module missing: $fullPath" }
        . $fullPath
    }
}
catch {
    Write-Log -Level ERROR -Message "Failed to load Graph layer scripts from src/Graph/. Error: $($_.Exception.Message)"
    exit 1
}

# Graph context (stub)
try {
    $graph = Connect-GraphContext -Mode $Mode
    Write-Log -Level INFO -Message "Graph context initialized. Mode=$($graph.Mode)"
}
catch {
    Write-Log -Level ERROR -Message "Graph context init failed: $($_.Exception.Message)"
    exit 1
}

# For now, Live mode is not implemented in stub modules
if ($Mode -eq "Live") {
    Write-Log -Level ERROR -Message "Live mode is not implemented yet. Use -Mode DryRun."
    exit 1
}

# -------------------------
# Read CSV and process
# -------------------------
$users = Import-Csv $CsvPath

$required = @("userPrincipalName","removeGroups","removeLicenses")
$report = New-Object System.Collections.Generic.List[object]

foreach ($u in $users) {
    try {
        foreach ($r in $required) {
            if (-not ($u.PSObject.Properties.Name -contains $r) -or [string]::IsNullOrWhiteSpace($u.$r)) {
                throw "Missing required field '$r'"
            }
        }

        $upn = Normalize-Text $u.userPrincipalName
        if ([string]::IsNullOrWhiteSpace($upn)) { throw "userPrincipalName is empty after normalization" }

        $removeGroups   = Parse-Bool $u.removeGroups
        $removeLicenses = Parse-Bool $u.removeLicenses
        $notes          = Normalize-Text $u.notes

        Write-Log -Level INFO -Message "Processing: UPN=$upn removeGroups=$removeGroups removeLicenses=$removeLicenses"

        # Stub calls (DryRun)
        $null = Disable-GraphUser -GraphContext $graph -UserPrincipalName $upn
        $null = Revoke-GraphUserSessions -GraphContext $graph -UserPrincipalName $upn

        Write-Log -Level DRYRUN -Message "Would disable user: $upn"
        Write-Log -Level DRYRUN -Message "Would revoke active sessions: $upn"

        if ($removeGroups) {
            $null = Remove-GraphUserFromGroups -GraphContext $graph -UserPrincipalName $upn
            Write-Log -Level DRYRUN -Message "Would remove from groups: $upn"
        }

        if ($removeLicenses) {
            $null = Remove-GraphUserLicenses -GraphContext $graph -UserPrincipalName $upn
            Write-Log -Level DRYRUN -Message "Would remove licenses: $upn"
        }

        $report.Add([pscustomobject]@{
            status            = "OK"
            mode              = $Mode
            userPrincipalName = $upn
            removeGroups      = $removeGroups
            removeLicenses    = $removeLicenses
            notes             = $notes
        })
    }
    catch {
        Write-Log -Level ERROR -Message "Failed user row ($($u.userPrincipalName)): $($_.Exception.Message)"
        $report.Add([pscustomobject]@{
            status            = "FAILED"
            mode              = $Mode
            userPrincipalName = $u.userPrincipalName
            error             = $_.Exception.Message
        })
    }
}

$report | Export-Csv -NoTypeInformation -Path $reportFile -Encoding UTF8
Write-Log -Level INFO -Message "Report exported: $reportFile"
Write-Log -Level INFO -Message "Log file: $Global:LogFile"
Write-Log -Level INFO -Message "Done."