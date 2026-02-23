<#
.SYNOPSIS
  Graph group operations (stub).
#>

function Add-GraphUserToGroups {
    [CmdletBinding()]
    param(
        [hashtable]$GraphContext,
        [string]$UserPrincipalName,
        [string[]]$Groups
    )

    if ($GraphContext.Mode -eq "DryRun") {
        return @{
            Action = "AddToGroups"
            Result = "DRYRUN"
            UserPrincipalName = $UserPrincipalName
            Groups = $Groups
        }
    }

    throw "Live mode group assignment not implemented yet."
}

function Remove-GraphUserFromGroups {
    [CmdletBinding()]
    param(
        [hashtable]$GraphContext,
        [string]$UserPrincipalName
    )

    if ($GraphContext.Mode -eq "DryRun") {
        return @{
            Action = "RemoveFromGroups"
            Result = "DRYRUN"
            UserPrincipalName = $UserPrincipalName
        }
    }

    throw "Live mode group removal not implemented yet."
}

