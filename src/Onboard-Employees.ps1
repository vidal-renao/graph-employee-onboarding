<#
.SYNOPSIS
  Employee onboarding automation (dry-run).

.DESCRIPTION
  Reads employee data from CSV and simulates onboarding actions
  such as user creation, group assignment and license assignment.
  No changes are made to production systems.

.NOTES
  Mode: Dry-run
#>

param (
    [string]$CsvPath = "data/employees.sample.csv"
)

Write-Host "=== Employee Onboarding (DRY-RUN) ===" -ForegroundColor Cyan
Write-Host "CSV path: $CsvPath"
Write-Host ""

if (-Not (Test-Path $CsvPath)) {
    Write-Error "CSV file not found: $CsvPath"
    exit 1
}

$employees = Import-Csv $CsvPath

foreach ($emp in $employees) {

    Write-Host "Processing employee:" -ForegroundColor Yellow
    Write-Host "  Name: $($emp.firstName) $($emp.lastName)"
    Write-Host "  Department: $($emp.department)"
    Write-Host "  Job title: $($emp.jobTitle)"
    Write-Host "  Usage location: $($emp.usageLocation)"
    Write-Host "  Groups: $($emp.groups)"
    Write-Host "  License: $($emp.licenseSku)"

    Write-Host "  [DRY-RUN] Would create user account"
    Write-Host "  [DRY-RUN] Would assign groups"
    Write-Host "  [DRY-RUN] Would assign license"
    Write-Host ""
}

Write-Host "Dry-run completed. No changes were made." -ForegroundColor Green
