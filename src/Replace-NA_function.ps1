<#
.SYNOPSIS
    Replace-NA - Replace NA of specified property

    Replace-NA [-p|-Property] <String[]> [-f|-From <String>] -To <String>

.LINK
    Shorten-PropertyName, Drop-NA, Replace-NA, Apply-Function, Add-Stats, Detect-XrsAnomaly, Plot-BarChart, Get-First, Get-Last, Select-Field, Delete-Field

#>
filter Replace-NA
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, Position=0)]
        [Alias('p')]
        [String[]] $Property,
        
        [Parameter(Mandatory=$False)]
        [Alias('f')]
        [string] $From = "NA",
        
        [Parameter(Mandatory=$True)]
        [Alias('t')]
        [string] $To,
        
        [Parameter(Mandatory=$False, ValueFromPipeline=$True)]
        [PSObject] $InputObject
    )
    foreach ( $p in $Property ){
        if (
            $_.$p -ceq "$From" -or `
            $_.$p -eq $Null
        ){
            $_.$p = [string]($_.$p) -replace $From, $To
            Write-Debug $($_.$p)
        }
    }
    Write-Output $_
}
