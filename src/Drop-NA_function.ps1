<#
.SYNOPSIS
    Drop-NA - Drop(Remove) NA and Null Value of specified property

    Drop-NA [-p|-Property] <String[]> [[-n|-NA] <String>]

.LINK
    Shorten-PropertyName, Drop-NA, Replace-NA, Apply-Function, Add-Stats, Detect-XrsAnomaly, Plot-BarChart, Get-First, Get-Last, Select-Field, Delete-Field

#>
filter Drop-NA
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, Position=0)]
        [Alias('p')]
        [String[]] $Property,
        
        [Parameter(Mandatory=$False, Position=1)]
        [Alias('n')]
        [string] $NA = "NA",
        
        [Parameter(Mandatory=$False, ValueFromPipeline=$True)]
        [PSObject] $InputObject
    )
    [bool] $isNaFlag = $False
    foreach ( $p in $Property ){
        if (
            $_.$p -ceq "$NA" -or `
            $_.$p -eq $Null
        ){
            [bool] $isNaFlag = $True
        }
    }
    if ( $isNaFlag ){
        # pass
    } else {
        Write-Output $_
    }
}
