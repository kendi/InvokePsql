#Requires -Version 4.0

function InitializeConfiguration
{
    Write-Debug "Start configuration initialize."

    $Script:InvokePsql = [ordered]@{}
    $InvokePsql.psql = [pscustomobject] @{
        Name = 'InvokePsql';
        ProviderPath = 'C:\Program Files (x86)\pgAdmin III\1.18\psql.exe';
    }

    $InvokePsql.Keys | select { "$_ : {0}" -f $InvokePsql[$_] } | Write-Debug

    Write-Debug "End configuration initialize."
}

function Initialize
{
    [CmdletBinding()] param()

    InitializeConfiguration
}

# Start module initialize

Write-Verbose 'Loading Invoke-Psql.psm1'

. $PSScriptRoot\Invoke-Psql.ps1
. $PSScriptRoot\Invoke-NewProcess.ps1

Export-ModuleMember -Function *

Initialize -Verbose
