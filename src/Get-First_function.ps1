<#
.SYNOPSIS
    Get-First - Get the first row of the same key

    Get the first row of the same key from input.
    Case-insensitive
    
        Get-Firest <key>,<key>,...

.LINK
    Shorten-PropertyName, Drop-NA, Replace-NA, Apply-Function, Add-Stats, Detect-XrsAnomaly, Plot-BarChart, Get-First, Get-Last, Select-Field, Delete-Field

.EXAMPLE
    Import-Csv data.csv

    no   ten    date     v1 v2 v3 v4 v5
    --   ---    ----     -- -- -- -- --
    0001 新橋店 20060201 91 59 20 76 54
    0001 新橋店 20060202 46 39 8  5  21
    0001 新橋店 20060203 82 0  23 84 10
    0002 池袋店 20060201 30 50 71 36 30
    0002 池袋店 20060202 78 13 44 28 51
    0002 池袋店 20060203 58 71 20 10 6
    0003 新宿店 20060201 82 79 16 21 80
    0003 新宿店 20060202 50 2  33 15 62
    0003 新宿店 20060203 52 91 44 9  0
    0004 上野店 20060201 60 89 33 18 6
    0004 上野店 20060202 95 60 35 93 76
    0004 上野店 20060203 92 56 83 96 75

    # Get-First:
    # Get the first record of the same key
    Import-Csv data.csv `
        | sort no,tendate -Stable `
        | Get-First no,ten `
        | ft

    no   ten    date     v1 v2 v3 v4 v5
    --   ---    ----     -- -- -- -- --
    0001 新橋店 20060201 91 59 20 76 54
    0002 池袋店 20060201 30 50 71 36 30
    0003 新宿店 20060201 82 79 16 21 80
    0004 上野店 20060201 60 89 33 18 6

    # Get-Last:
    # Get the last record of the same key
    Import-Csv data.csv `
        | sort no,ten,date -Stable `
        | Get-Last no,ten `
        | ft

    no   ten    date     v1 v2 v3 v4 v5
    --   ---    ----     -- -- -- -- --
    0001 新橋店 20060203 82 0  23 84 10
    0002 池袋店 20060203 58 71 20 10 6
    0003 新宿店 20060203 52 91 44 9  0
    0004 上野店 20060203 92 56 83 96 75

#>
function Get-First
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, Position=0)]
        [Alias('p')]
        [String[]] $Property,
        
        [Parameter(Mandatory=$False, ValueFromPipeline=$True)]
        [PSObject] $InputObject
    )
    [bool] $isFirstItem = $True
    [string] $oldVal = $Null
    [string] $newVal = $Null
    foreach ( $obj in $input ){
        [string] $propKeyStr = ''
        foreach ($p in $Property){
            $propKeyStr += $obj.$p
        }
        [string] $newVal = $propKeyStr
        if ( $isFirstItem ){
            $isFirstItem = $False
            $obj
        } else {
            if ( $newVal -eq $oldVal){
                # pass
            } else {
                $obj
            }
        }
        [string] $oldVal = $newVal
    }
}
