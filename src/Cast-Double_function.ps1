<#
.SYNOPSIS
    Cast-Double - Cast all castable columns to double type

.EXAMPLE
    Import-Csv iris.csv | select -First 3 | Cast-Double | ft

    sepal_length sepal_width petal_length petal_width species
    ------------ ----------- ------------ ----------- -------
            5.10        3.50         1.40        0.20 setosa
            4.90        3.00         1.40        0.20 setosa
            4.70        3.20         1.30        0.20 setosa

#>
function Cast-Double
{
    [CmdletBinding()]
    Param(        
        [Parameter(Mandatory=$False, Position=0)]
        [String[]] $Property
        ,
        [Parameter(Mandatory=$False)]
        [String[]] $Exclude
        ,
        [Parameter(Mandatory=$False, ValueFromPipeline=$True)]
        [PSObject] $InputObject
    )
    # get all property names
    [String[]] $OldPropertyNames = ($input[0].PSObject.Properties).Name
    [String[]] $ReplaceComAry = @()
    $OldPropertyNames | ForEach-Object {
        [string] $oldName = $_
        if ( $Exclude.Count -gt 0 ){
            if ( -not $Exclude.Contains($oldName) ){
                $ReplaceComAry += "
                    @{N=""$oldName""; E={
                        if ( `$_.""$($oldName)"" -as [double] ){
                            [double](`$_.""$($oldName)"")
                        } else {
                            `$_.""$($oldName)""
                        }
                        }}
                    "
            } else {
                $ReplaceComAry += "@{N=""$oldName""; E={ `$_.""$($oldName)""}}"
            }
        } elseif ( $Property.Count -gt 0 ){
            if ( $Property.Contains($oldName) ){
                $ReplaceComAry += "
                    @{N=""$oldName""; E={
                        if ( `$_.""$($oldName)"" -as [double] ){
                            [double](`$_.""$($oldName)"")
                        } else {
                            `$_.""$($oldName)""
                        }
                        }}
                    "
            } else {
                $ReplaceComAry += "@{N=""$oldName""; E={ `$_.""$($oldName)""}}"
            }
        } else {
            $ReplaceComAry += "
                @{N=""$oldName""; E={
                    if ( `$_.""$($oldName)"" -as [double] ){
                        [double](`$_.""$($oldName)"")
                    } else {
                        `$_.""$($oldName)""
                    }
                    }}
                "
        }
    }

    # invoke command strings
    $hashAry = $ReplaceComAry | ForEach-Object { Invoke-Expression -Command $_ }
    $input | Select-Object -Property $hashAry
}
