<#
.SYNOPSIS
    Get-Last - Get the last row of the same key

    Get the last row of the same key from input.
    Case-insensitive

        Get-Last <key>,<key>,...

.LINK
    Shorten-PropertyName, Drop-NA, Replace-NA, Apply-Function, Add-Stats, Detect-XrsAnomaly, Plot-BarChart, Get-First, Get-Last, Select-Field, Delete-Field

.EXAMPLE
    Import-Csv -Path data.csv

    no   ten     date     v1 v2 v3 v4 v5
    --   ---     ----     -- -- -- -- --
    0001 Store_A 20060201 91 59 20 76 54
    0001 Store_A 20060202 46 39 8  5  21
    0001 Store_A 20060203 82 0  23 84 10
    0002 Store_B 20060201 30 50 71 36 30
    0002 Store_B 20060202 78 13 44 28 51
    0002 Store_B 20060203 58 71 20 10 6
    0003 Store_C 20060201 82 79 16 21 80
    0003 Store_C 20060202 50 2  33 15 62
    0003 Store_C 20060203 52 91 44 9  0
    0004 Store_D 20060201 60 89 33 18 6
    0004 Store_D 20060202 95 60 35 93 76
    0004 Store_D 20060203 92 56 83 96 75

    # Get-First:
    # Get the first record of the same key
    Import-Csv -Path data.csv `
        | Sort-Object -Property "no", "ten", "date" -Stable `
        | Get-First -Property "no", "ten" `
        | Format-Table

    no   ten     date     v1 v2 v3 v4 v5
    --   ---     ----     -- -- -- -- --
    0001 Store_A 20060201 91 59 20 76 54
    0002 Store_B 20060201 30 50 71 36 30
    0003 Store_C 20060201 82 79 16 21 80
    0004 Store_D 20060201 60 89 33 18 6

    # Get-Last:
    # Get the last record of the same key
    Import-Csv -Path data.csv `
        | Sort-Object -Property "no", "ten", "date" -Stable `
        | Get-Last -Property "no", "ten" `
        | Format-Table

    no   ten     date     v1 v2 v3 v4 v5
    --   ---     ----     -- -- -- -- --
    0001 Store_A 20060203 82 0  23 84 10
    0002 Store_B 20060203 58 71 20 10 6
    0003 Store_C 20060203 52 91 44 9  0
    0004 Store_D 20060203 92 56 83 96 75


#>
function Get-Last
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
    foreach ( $obj in @($input | Select-Object * ) ){
        [string] $propKeyStr = ''
        foreach ($p in $Property){
            $propKeyStr += $obj.$p
        }
        [string] $newVal = $propKeyStr
        if ( $isFirstItem ){
            $isFirstItem = $False
        } else {
            if ( $newVal -eq $oldVal){
                # pass
            } else {
                $preItem
            }
        }
        [string] $oldVal = $newVal
        $preItem = $obj
    }
    $preItem
}
