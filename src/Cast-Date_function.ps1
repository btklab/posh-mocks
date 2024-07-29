<#
.SYNOPSIS
    Cast-Date - Cast all castable columns to datetime type

.EXAMPLE
    # cast string to datetime
    cat data.txt

    date version
    2020-02-26 v2.2.4
    2020-02-26 v3.0.3
    2019-11-10 v3.0.2
    2019-11-10 v3.0.1
    2019-09-18 v3.0.0
    2019-08-10 v2.2.3

    cat data.txt `
        | ConvertFrom-Csv -Delimiter " " `
        | Cast-Date

    date               version
    ----               -------
    2020/02/26 0:00:00 v2.2.4
    2020/02/26 0:00:00 v3.0.3
    2019/11/10 0:00:00 v3.0.2
    2019/11/10 0:00:00 v3.0.1
    2019/09/18 0:00:00 v3.0.0
    2019/08/10 0:00:00 v2.2.3

#>
function Cast-Date
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
                        if ( `$_.""$($oldName)"" -as [datetime] ){
                            [datetime](`$_.""$($oldName)"")
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
                        if ( `$_.""$($oldName)"" -as [datetime] ){
                            [datetime](`$_.""$($oldName)"")
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
                    if ( `$_.""$($oldName)"" -as [datetime] ){
                        [datetime](`$_.""$($oldName)"")
                    } else {
                        `$_.""$($oldName)""
                    }
                    }}
                "
        }
    }

    # invoke command strings
    $hashAry = $ReplaceComAry | ForEach-Object {
        Write-Debug $_
        Invoke-Expression -Command $_
    }
    $input | Select-Object -Property $hashAry
}
