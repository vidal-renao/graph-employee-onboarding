<#
.SYNOPSIS
  Employee onboarding automation (dry-run).

.DESCRIPTION
  Reads employee data from CSV and simulates onboarding actions.
  Produces logs and a CSV report per execution.

.NOTES
  Mode: Dry-run (default)
#>

param (
    [string]$CsvPath = "data/employees.sample.csv",
    [string]$OutDir  = "out"
)

# --- Helpers ---
function Write-Log {
    param(
        [ValidateSet("INFO","WARN","ERROR","DRYRUN")] [string]$Level,
        [string]$Message
    )
    $line = "{0} [{1}] {2}" -f (Get-Date).ToString("s"), $Level, $Message
    Add-Content -Path $Global:LogFile -Value $line
    Write-Host $line
}

# --- Init ---
if (-not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir | Out-Null
}

$timestamp = (Get-Date).ToString("yyyyMMdd-HHmmss")
$Global:LogFile = Join-Path $OutDir "onboarding-$timestamp.log"
$reportFile = Join-Path $OutDir "onboarding-report-$timestamp.csv"

Write-Host "=== Employee Onboarding (DRY-RUN) ===" -ForegroundColor Cyan
Write-Log -Level INFO -Message "Start. CsvPath=$CsvPath OutDir=$OutDir"

if (-Not (Test-Path $CsvPath)) {
    Write-Log -Level ERROR -Message "CSV not found: $CsvPath"
    exit 1
}

$employees = Import-Csv $CsvPath

# Campos requeridos (empresa-like)
$required = @("firstName","lastName","department","jobTitle","usageLocation","groups","licenseSku")

$report = New-Object System.Collections.Generic.List[object]

foreach ($emp in $employees) {
    try {
        foreach ($r in $required) {
            if (-not ($emp.PSObject.Properties.Name -contains $r) -or [string]::IsNullOrWhiteSpace($emp.$r)) {
                throw "Missing required field '$r'"
            }
        }

        $fullName = "$($emp.firstName) $($emp.lastName)"
        Write-Log -Level INFO -Message "Processing: $fullName Dept=$($emp.department) Title=$($emp.jobTitle)"

        # Simulación de acciones (DRY-RUN)
        Write-Log -Level DRYRUN -Message "Would create user for '$fullName'"
        Write-Log -Level DRYRUN -Message "Would add to groups: $($emp.groups)"
        Write-Log -Level DRYRUN -Message "Would assign license: $($emp.licenseSku)"

        $report.Add([pscustomobject]@{
            status     = "OK"
            employee   = $fullName
            department = $emp.department
            groups     = $emp.groups
            licenseSku = $emp.licenseSku
        })
    }
    catch {
        Write-Log -Level ERROR -Message "Failed employee row ($($emp.firstName) $($emp.lastName)): $($_.Exception.Message)"
        $report.Add([pscustomobject]@{
            status     = "FAILED"
            employee   = "$($emp.firstName) $($emp.lastName)"
            department = $emp.department
            groups     = $emp.groups
            licenseSku = $emp.licenseSku
            error      = $_.Exception.Message
        })
    }
}

$report | Export-Csv -NoTypeInformation -Path $reportFile -Encoding UTF8
Write-Log -Level INFO -Message "Report exported: $reportFile"
Write-Log -Level INFO -Message "Log file: $Global:LogFile"
Write-Log -Level INFO -Message "Done. No changes were made."
