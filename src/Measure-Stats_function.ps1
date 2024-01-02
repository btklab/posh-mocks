<#
.SYNOPSIS
    Measure-Stats (Alias: mstats) - Apply first record's key to each output

    Pre sort -Stable needed

.LINK
    Apply-Function

.EXAMPLE
    Import-Csv iris.csv `
        | sort species -Stable `
        | Measure-Stats sepal_length species -Sum -Average `
        | ft

    Import-Csv iris.csv `
        | sort species -Stable `
        | Apply-Function species {
            Measure-Stats sepal_length species -Sum -Average } `
        | ft

    species    Property        Sum Average
    -------    --------        --- -------
    setosa     sepal_length 250.30    5.01
    versicolor sepal_length 296.80    5.94
    virginica  sepal_length 329.40    6.59


#>
function Measure-Stats
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
                    # convert psobject to hash
                    $hash = [ordered] @{}
                    foreach ($item in $gObj.psobject.properties){
                        $hash[$item.Name] = $item.Value
                    }
                    if ( $Key ){
                        foreach ( $k in $Key){
                            $hash["$k"] = $outPropNames[$k]
                        }
                    }
                    # convert hash to psobject
                    New-Object psobject -Property $hash `
                        | Select-Object -ExcludeProperty $ExcludeProperties
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
        # convert psobject to hash
        $hash = [ordered] @{}
        foreach ($item in $gObj.psobject.properties){
            $hash[$item.Name] = $item.Value
        }
        if ( $Key ){
            foreach ( $k in $Key){
                $hash["$k"] = $outPropNames[$k]
            }
        }
        # convert hash to psobject
        New-Object psobject -Property $hash `
            | Select-Object -ExcludeProperty $ExcludeProperties
    }
}
# set alias
[String] $tmpAliasName = "mstats"
[String] $tmpCmdName   = "Measure-Stats"
[String] $tmpCmdPath = Join-Path `
    -Path $PSScriptRoot `
    -ChildPath $($MyInvocation.MyCommand.Name) `
    | Resolve-Path -Relative
if ( $IsWindows ){ $tmpCmdPath = $tmpCmdPath.Replace('\' ,'/') }
# is alias already exists?
if ((Get-Command -Name $tmpAliasName -ErrorAction SilentlyContinue).Count -gt 0){
    try {
        if ( (Get-Command -Name $tmpAliasName).CommandType -eq "Alias" ){
            if ( (Get-Command -Name $tmpAliasName).ReferencedCommand.Name -eq $tmpCmdName ){
                Set-Alias -Name $tmpAliasName -Value $tmpCmdName -PassThru `
                    | ForEach-Object{
                        Write-Host "$($_.DisplayName)" -ForegroundColor Green
                    }
            } else {
                throw
            }
        } elseif ( "$((Get-Command -Name $tmpAliasName).Name)" -match '\.exe$') {
            Set-Alias -Name $tmpAliasName -Value $tmpCmdName -PassThru `
                | ForEach-Object{
                    Write-Host "$($_.DisplayName)" -ForegroundColor Green
                }
        } else {
            throw
        }
    } catch {
        Write-Error "Alias ""$tmpAliasName ($((Get-Command -Name $tmpAliasName).ReferencedCommand.Name))"" is already exists. Change alias needed. Please edit the script at the end of the file: ""$tmpCmdPath""" -ErrorAction Stop
    } finally {
        Remove-Variable -Name "tmpAliasName" -Force
        Remove-Variable -Name "tmpCmdName" -Force
    }
} else {
    Set-Alias -Name $tmpAliasName -Value $tmpCmdName -PassThru `
        | ForEach-Object {
            Write-Host "$($_.DisplayName)" -ForegroundColor Green
        }
    Remove-Variable -Name "tmpAliasName" -Force
    Remove-Variable -Name "tmpCmdName" -Force
}
