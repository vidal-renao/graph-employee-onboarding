<#
.SYNOPSIS
  Employee onboarding automation (DryRun by default).

.DESCRIPTION
  Reads employee data from CSV and simulates onboarding actions using a Graph abstraction layer (stub for now).
  Produces logs and a CSV report per execution.

  Mode:
    - DryRun (default): no production changes, only logs what would happen
    - Live: reserved for future real Microsoft Graph implementation

#>

[CmdletBinding()]
param (
    [string]$CsvPath   = "data/employees.sample.csv",
    [string]$OutDir    = "out",

    [ValidateSet("DryRun","Live")]
    [string]$Mode      = "DryRun",

    # Domain used to build UPNs (placeholder until you use a real tenant domain)
    [string]$UpnDomain = "company.local"
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

function Parse-Groups {
    param([string]$GroupsField)
    $g = Normalize-Text $GroupsField
    if ([string]::IsNullOrWhiteSpace($g)) { return @() }

    return ($g -split ";" | ForEach-Object { $_.Trim() } | Where-Object { $_ })
}

function Assert-UsageLocation {
    param([string]$UsageLocation)
    $u = (Normalize-Text $UsageLocation).ToUpper()
    if ($u -notmatch '^[A-Z]{2}$') {
        throw "Invalid usageLocation '$UsageLocation' (expected 2-letter code like CH/DE)"
    }
    return $u
}

function New-UpnFromName {
    param(
        [string]$FirstName,
        [string]$LastName,
        [string]$Domain
    )

    $fn = (Normalize-Text $FirstName).ToLower()
    $ln = (Normalize-Text $LastName).ToLower()

    # Simple, enterprise-style sanitization (keep letters/numbers/dot/hyphen)
    $fn = ($fn -replace '\s+', '') -replace '[^a-z0-9\-]', ''
    $ln = ($ln -replace '\s+', '') -replace '[^a-z0-9\-]', ''

    if ([string]::IsNullOrWhiteSpace($fn) -or [string]::IsNullOrWhiteSpace($ln)) {
        throw "Cannot build UPN (firstName/lastName invalid after sanitization)"
    }

    $dom = (Normalize-Text $Domain).ToLower()
    if ([string]::IsNullOrWhiteSpace($dom)) {
        throw "UpnDomain is empty"
    }

    return "$fn.$ln@$dom"
}

# -------------------------
# Init output
# -------------------------
if (-not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir | Out-Null
}

$timestamp       = (Get-Date).ToString("yyyyMMdd-HHmmss")
$Global:LogFile  = Join-Path $OutDir "onboarding-$timestamp.log"
$reportFile      = Join-Path $OutDir "onboarding-report-$timestamp.csv"

Write-Host "=== Employee Onboarding ($Mode) ===" -ForegroundColor Cyan
Write-Log -Level INFO -Message "Start. Mode=$Mode CsvPath=$CsvPath OutDir=$OutDir UpnDomain=$UpnDomain"

if (-Not (Test-Path $CsvPath)) {
    Write-Log -Level ERROR -Message "CSV not found: $CsvPath"
    exit 1
}

# -------------------------
# Load Graph layer (stub)
# -------------------------
try {
    . "$PSScriptRoot/Graph/Graph-Auth.ps1"
    . "$PSScriptRoot/Graph/Graph-Users.ps1"
    . "$PSScriptRoot/Graph/Graph-Groups.ps1"
    . "$PSScriptRoot/Graph/Graph-Licenses.ps1"
}
catch {
    Write-Log -Level ERROR -Message "Failed to load Graph layer scripts from src/Graph/. Error: $($_.Exception.Message)"
    exit 1
}

# Graph context (stub)
$graph = $null
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
$employees = Import-Csv $CsvPath

# Required fields (enterprise baseline)
$required = @("firstName","lastName","department","jobTitle","usageLocation","groups","licenseSku")

$report = New-Object System.Collections.Generic.List[object]

foreach ($emp in $employees) {
    try {
        foreach ($r in $required) {
            if (-not ($emp.PSObject.Properties.Name -contains $r) -or [string]::IsNullOrWhiteSpace($emp.$r)) {
                throw "Missing required field '$r'"
            }
        }

        $firstName     = Normalize-Text $emp.firstName
        $lastName      = Normalize-Text $emp.lastName
        $department    = Normalize-Text $emp.department
        $jobTitle      = Normalize-Text $emp.jobTitle
        $usageLocation = Assert-UsageLocation $emp.usageLocation
        $licenseSku    = Normalize-Text $emp.licenseSku

        $groupsArr = Parse-Groups $emp.groups
        if ($groupsArr.Count -eq 0) {
            throw "No groups provided (groups field is empty after parsing)"
        }

        $fullName = "$firstName $lastName"
        $upn      = New-UpnFromName -FirstName $firstName -LastName $lastName -Domain $UpnDomain

        Write-Log -Level INFO -Message "Processing: $fullName | UPN=$upn | Dept=$department | Title=$jobTitle | UsageLocation=$usageLocation"

        # Build minimal user payload (what you'd send to Graph later)
        $userPayload = @{
            userPrincipalName = $upn
            displayName       = $fullName
            givenName         = $firstName
            surname           = $lastName
            department        = $department
            jobTitle          = $jobTitle
            usageLocation     = $usageLocation
        }

        # Stub calls (DryRun)
        $null = New-GraphUser -GraphContext $graph -UserPayload $userPayload
        $null = Add-GraphUserToGroups -GraphContext $graph -UserPrincipalName $upn -Groups $groupsArr
        $null = Set-GraphUserLicense -GraphContext $graph -UserPrincipalName $upn -LicenseSku $licenseSku

        Write-Log -Level DRYRUN -Message "Would create user: $upn"
        Write-Log -Level DRYRUN -Message "Would add to groups: $($groupsArr -join ';')"
        Write-Log -Level DRYRUN -Message "Would assign license: $licenseSku"

        $report.Add([pscustomobject]@{
            status        = "OK"
            mode          = $Mode
            userPrincipalName = $upn
            employee      = $fullName
            department    = $department
            jobTitle      = $jobTitle
            usageLocation = $usageLocation
            groupsParsed  = ($groupsArr -join ";")
            licenseSku    = $licenseSku
        })
    }
    catch {
        Write-Log -Level ERROR -Message "Failed employee row ($($emp.firstName) $($emp.lastName)): $($_.Exception.Message)"
        $report.Add([pscustomobject]@{
            status        = "FAILED"
            mode          = $Mode
            employee      = "$($emp.firstName) $($emp.lastName)"
            department    = $emp.department
            groups        = $emp.groups
            licenseSku    = $emp.licenseSku
            error         = $_.Exception.Message
        })
    }
}

$report | Export-Csv -NoTypeInformation -Path $reportFile -Encoding UTF8
Write-Log -Level INFO -Message "Report exported: $reportFile"
Write-Log -Level INFO -Message "Log file: $Global:LogFile"
Write-Log -Level INFO -Message "Done."