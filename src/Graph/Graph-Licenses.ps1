<#
.SYNOPSIS
  Graph license operations (stub).
#>

function Set-GraphUserLicense {
    [CmdletBinding()]
    param(
        [hashtable]$GraphContext,
        [string]$UserPrincipalName,
        [string]$LicenseSku
    )

    if ($GraphContext.Mode -eq "DryRun") {
        return @{
            Action = "AssignLicense"
            Result = "DRYRUN"
            UserPrincipalName = $UserPrincipalName
            LicenseSku = $LicenseSku
        }
    }

    throw "Live mode license assignment not implemented yet."
}

function Remove-GraphUserLicenses {
    [CmdletBinding()]
    param(
        [hashtable]$GraphContext,
        [string]$UserPrincipalName
    )

    if ($GraphContext.Mode -eq "DryRun") {
        return @{
            Action = "RemoveLicenses"
            Result = "DRYRUN"
            UserPrincipalName = $UserPrincipalName
        }
    }

    throw "Live mode license removal not implemented yet."
}

Export-ModuleMember -Function Set-GraphUserLicense,Remove-GraphUserLicenses