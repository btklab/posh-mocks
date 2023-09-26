<#
.SYNOPSIS
    Measure-Property (Alias: mprop) - Apply first record's key to each output

    Pre sort -Stable needed

.LINK
    Apply-Function

.EXAMPLE
    Import-Csv iris.csv `
        | sort species -Stable `
        | Measure-Property sepal_length species -Sum -Average `
        | ft

    Import-Csv iris.csv `
        | sort species -Stable `
        | Apply-Function species {
            Measure-Property sepal_length species -Sum -Average } `
        | ft

    species    Property        Sum Average
    -------    --------        --- -------
    setosa     sepal_length 250.30    5.01
    versicolor sepal_length 296.80    5.94
    virginica  sepal_length 329.40    6.59


#>
function Measure-Property
{
    [CmdletBinding()]
    Param(
        [Parameter( Mandatory=$True, Position=0 )]
        [Alias('v')]
        [string[]] $Value,
        
        [Parameter( Mandatory=$False, Position=1 )]
        [Alias('k')]
        [string[]] $Key,
        
        [Parameter( Mandatory=$False)]
        [Alias('SD')]
        [switch] $StandardDeviation,
        
        [Parameter( Mandatory=$False)]
        [switch] $Sum,
        
        [Parameter( Mandatory=$False)]
        [Alias('All')]
        [switch] $AllStats,
        
        [Parameter( Mandatory=$False)]
        [Alias('Mean')]
        [switch] $Average,
        
        [Parameter( Mandatory=$False)]
        [Alias('Max')]
        [switch] $Maximum,
        
        [Parameter( Mandatory=$False)]
        [Alias('Min')]
        [switch] $Minimum,
        
        [Parameter( Mandatory=$False)]
        [Alias('Cnt')]
        [switch] $Count,
        
        [Parameter(Mandatory=$False, ValueFromPipeline=$True)]
        [PSObject] $InputObject
    )
    #Write-Debug $hashFirstItems
    [string[]] $ExcludeProperties = @()
    $splatting = @{
        Property = $Value
    }
    if ( $Count -or $AllStats ){
        # pass
    } else {
        $ExcludeProperties += ,"Count"
    }
    if ( $Sum -or $AllStats ){
        $splatting.Set_Item("Sum", $True)
    } else {
        $ExcludeProperties += ,"Sum"
    }
    if ( $Average -or $AllStats ){
        $splatting.Set_Item("Average", $True)
    } else {
        $ExcludeProperties += ,"Average"
    }
    if ( $Maximum -or $AllStats ){
        $splatting.Set_Item("Maximum", $True)
    } else {
        $ExcludeProperties += ,"Maximum"
    }
    if ( $Minimum -or $AllStats ){
        $splatting.Set_Item("Minimum", $True)
    } else {
        $ExcludeProperties += ,"Minimum"
    }
    if ( $StandardDeviation -or $AllStats ){
        $splatting.Set_Item("StandardDeviation", $True)
    } else {
        $ExcludeProperties += ,"StandardDeviation"
    }
    if ( $AllStats ){
        $splatting.Set_Item("AllStats", $True)
    }
    # main
    [bool] $isFirstItem = $True
    [string] $oldVal = $Null
    [string] $newVal = $Null
    [int] $cnt = 0
    foreach ( $obj in $input){
        # set key strings
        if ( $Key ){
            [string] $propKeyStr = ''
            foreach ($p in $Key){
                $propKeyStr += $obj.$p
            }
            [string] $newVal = $propKeyStr
        } else {
            [string] $newVal = ''
        }
        if ( $isFirstItem ){
            $isFirstItem = $False
            $groupAry = New-Object System.Collections.ArrayList
            $groupAry.Add($obj) > $Null
            # Get Key property names
            $outPropNames = @{}
            foreach ( $k in $Key ){
                $outPropNames.Add($k, $obj.$k)
            }
        } else {
            if ( $newVal -eq $oldVal){
                $groupAry.Add($obj) > $Null
            } else {
                foreach ($gObj in @( $groupAry | Measure-Object @splatting )){
                    if ( $Key ){
                        foreach ( $k in $Key){
                            $gObj | Add-Member -NotePropertyName $k -NotePropertyValue $outPropNames[$k]
                        }
                    }
                    $gObj | Select-Object -ExcludeProperty $ExcludeProperties
                }
                # Get Key property names
                $outPropNames = @{}
                foreach ( $k in $Key ){
                    $outPropNames.Add($k, $obj.$k)
                }
                $groupAry = New-Object System.Collections.ArrayList
                $groupAry.Add($obj) > $Null
            }
        }
        [string] $oldVal = $newVal
        $cnt++
    }
    foreach ( $gObj in @( $groupAry | Measure-Object @splatting )){
            if ( $Key ){
                foreach ( $k in $Key){
                    $gObj | Add-Member -NotePropertyName $k -NotePropertyValue $outPropNames[$k]
                }
            }
            $gObj | Select-Object -ExcludeProperty $ExcludeProperties
    }
}
Set-Alias -Name mprop -Value Measure-Property

