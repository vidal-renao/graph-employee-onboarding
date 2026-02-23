<#
.SYNOPSIS
  Graph user operations (stub).
#>

function New-GraphUser {
    [CmdletBinding()]
    param(
        [hashtable]$GraphContext,
        [hashtable]$UserPayload
    )

    if ($GraphContext.Mode -eq "DryRun") {
        return @{
            Action = "CreateUser"
            Result = "DRYRUN"
            Payload = $UserPayload
        }
    }

    throw "Live mode user creation not implemented yet."
}

function Disable-GraphUser {
    [CmdletBinding()]
    param(
        [hashtable]$GraphContext,
        [string]$UserPrincipalName
    )

    if ($GraphContext.Mode -eq "DryRun") {
        return @{
            Action = "DisableUser"
            Result = "DRYRUN"
            UserPrincipalName = $UserPrincipalName
        }
    }

    throw "Live mode user disable not implemented yet."
}

function Revoke-GraphUserSessions {
    [CmdletBinding()]
    param(
        [hashtable]$GraphContext,
        [string]$UserPrincipalName
    )

    if ($GraphContext.Mode -eq "DryRun") {
        return @{
            Action = "RevokeSessions"
            Result = "DRYRUN"
            UserPrincipalName = $UserPrincipalName
        }
    }

    throw "Live mode session revoke not implemented yet."
}

Export-ModuleMember -Function New-GraphUser,Disable-GraphUser,Revoke-GraphUserSessions