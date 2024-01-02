<#
.SYNOPSIS
    Add-Quartile (Alias: aquart) - Add quartile columns to each record

    For categorical data analysis of time series data.
    Automatically exclude NA, NaN, Null from the specified column.
    Multiple columns can be specified at once.

        Add-Quartile [-v] <col> <params>

    Params:
        [-v|-Value] <String>
        [-OutlierMultiple <Double>]
        [-All|-AllStats]
        [-AddPropertyName]
        [-Delimiter <String>]

    Default output:
        Count
        Sum
        Mean
        Sd
        Min
        Qt25
        Median
        Qt75
        Max
        Outlier

    If -AllStats specified, the following columns are added:
        IQR
        HiIQR
        LoIQR
        Confidence95

    Result of Outlier detection with IQR is expressed as
    an integer from 0 to 7 in Property="Outlier":

        0 ... Not outlier
        1 ... Detected as Outlier from the Hi-IQR line
        2 ... Detected as Outlier from the Lo-IQR line

.LINK
    Shorten-PropertyName, Drop-NA, Replace-NA, Apply-Function, Add-Quartile, Add-Stats, Detect-XrsAnomaly, Plot-BarChart, Get-First, Get-Last, Select-Field, Delete-Field

.EXAMPLE
    Import-Csv iris.csv `
        | Shorten-PropertyName `
        | Add-Quartile "s_l" `
        | select -First 1

    s_l     : 5.1
    s_w     : 3.5
    p_l     : 1.4
    p_w     : 0.2
    species : setosa
    Count   : 150
    Sum     : 876.5
    Mean    : 5.84333333333333
    Sd      : 0.828066127977863
    Min     : 4.3
    Qt25    : 5.1
    Median  : 5.8
    Qt75    : 6.4
    Max     : 7.9

.EXAMPLE
    Import-Csv iris.csv `
        | Shorten-PropertyName `
        | Add-Quartile "s_l" -AllStats `
        | select -First 1

    s_l          : 5.1
    s_w          : 3.5
    p_l          : 1.4
    p_w          : 0.2
    species      : setosa
    Count        : 150
    Sum          : 876.5
    Mean         : 5.84333333333333
    Sd           : 0.828066127977863
    Min          : 4.3
    Qt25         : 5.1
    Median       : 5.8
    Qt75         : 6.4
    Max          : 7.9
    IQR          : 1.3
    HiIQR        : 8.35
    LoIQR        : 3.15
    Confidence95 : 0

.EXAMPLE
    Import-Csv iris.csv `
        | Shorten-PropertyName `
        | Add-Quartile "s_l" -AddPropertyName `
        | select -First 1

    s_l           : 5.1
    s_w           : 3.5
    p_l           : 1.4
    p_w           : 0.2
    species       : setosa
    Count_Of_s_l  : 150
    Sum_Of_s_l    : 876.5
    Mean_Of_s_l   : 5.84333333333333
    Sd_Of_s_l     : 0.828066127977863
    Min_Of_s_l    : 4.3
    Qt25_Of_s_l   : 5.1
    Median_Of_s_l : 5.8
    Qt75_Of_s_l   : 6.4
    Max_Of_s_l    : 7.9

.EXAMPLE
    # Detect outlier
    Import-Csv iris.csv `
        | Shorten-PropertyName `
        | Add-Quartile "s_w" -AllStats `
        | ? outlier -gt 0 `
        | ft "s_w", "LoIQR", "HiIQR", "Outlier"

    s_w LoIQR HiIQR Outlier
    --- ----- ----- -------
    4.4  1.90  4.30       1

#>
function Add-Quartile
{
    [CmdletBinding()]
    Param(
        [Parameter( Mandatory=$True, Position=0 )]
        [Alias('v')]
        [string] $Value
        ,
        [Parameter( Mandatory=$False )]
        [double] $OutlierMultiple = 1.5
        ,
        [Parameter( Mandatory=$False)]
        [Alias('All')]
        [switch] $AllStats
        ,
        [Parameter( Mandatory=$False)]
        [switch] $AddPropertyName
        ,
        [Parameter( Mandatory=$False)]
        [string] $Delimiter = "_"
        ,
        [Parameter(Mandatory=$False, ValueFromPipeline=$True)]
        [PSObject] $InputObject
    )
    # init hash
    [string] $delim = $Delimiter
    if ( $AddPropertyName ){
        $strCount   = "Count"   + "${delim}Of${delim}$Value"
        $strSum     = "Sum"     + "${delim}Of${delim}$Value"
        $strMean    = "Mean"    + "${delim}Of${delim}$Value"
        $strSd      = "Sd"      + "${delim}Of${delim}$Value"
        $strMin     = "Min"     + "${delim}Of${delim}$Value"
        $strQt25    = "Qt25"    + "${delim}Of${delim}$Value"
        $strMedian  = "Median"  + "${delim}Of${delim}$Value"
        $strQt75    = "Qt75"    + "${delim}Of${delim}$Value"
        $strMax     = "Max"     + "${delim}Of${delim}$Value"
        $strIQR     = "IQR"     + "${delim}Of${delim}$Value"
        $strHiIQR   = "HiIQR"   + "${delim}Of${delim}$Value"
        $strLoIQR   = "LoIQR"   + "${delim}Of${delim}$Value"
        $strOutlier = "Outlier" + "${delim}Of${delim}$Value"
        $strConfidence95 = "Confidence95" + "Of${delim}$Value"
    } else {
        $strCount   = "Count"
        $strSum     = "Sum"
        $strMean    = "Mean"
        $strSd      = "Sd"
        $strMin     = "Min"
        $strQt25    = "Qt25"
        $strMedian  = "Median"
        $strQt75    = "Qt75"
        $strMax     = "Max"
        $strIQR     = "IQR"
        $strHiIQR   = "HiIQR"
        $strLoIQR   = "LoIQR"
        $strOutlier = "Outlier"
        $strConfidence95 = "Confidence95"
    }
    ## Output hash
    $hashStatVals = @{}
    # 1st pass : get sum, count
    [int] $rowCounter = 0
    [object] $Data = $input `
        | Where-Object {
            $_.$Value -ne $Null -and `
            $_.$Value -notmatch '^NA$|^NaN$' } `
        | Sort-Object { [double]($_.$Value) }
    # calculate median
    if ($Data.Count % 2 -eq 0) {
        # Even number of data items
        [int] $MedianIndex = ($Data.Count / 2) - 1
        [double] $LowerMedian = $Data[$MedianIndex] | Select-Object -ExpandProperty $Value
        [double] $UpperMedian = $Data[$MedianIndex + 1] | Select-Object -ExpandProperty $Value
        [double] $Median = ([double]$LowerMedian + [double]$UpperMedian) / 2
    } else {
        # Odd number of data items
        [int] $MedianIndex = [math]::Ceiling(($Data.Count - 1) / 2)
        [double] $Median = $Data[$MedianIndex] | Select-Object -ExpandProperty $Value
    }
    # Get sum, count, min, max, mean
    [object] $Stats = $Data `
        | Measure-Object -Property $Value -Minimum -Maximum -Sum -Average -StandardDeviation
    $hashStatVals["$strMedian"] = $Median
    $hashStatVals["$strCount"]  = $Stats.Count
    $hashStatVals["$strSum"]    = $Stats.Sum
    $hashStatVals["$strMean"]   = $Stats.Average
    $hashStatVals["$strMin"]    = $Stats.Minimum
    $hashStatVals["$strMax"]    = $Stats.Maximum
    $hashStatVals["$strSd"]     = $Stats.StandardDeviation
    # Calculate percentiles
    if ( $Stats.Count -eq 1 ){
        [int] $Percentile25Index = 0
        [int] $Percentile75Index = 0
    } elseif ( $Stats.Count -eq 2 ){
        [int] $Percentile25Index = 0
        [int] $Percentile75Index = 1
    } elseif ( $Stats.Count -eq 3 ){
        [int] $Percentile25Index = 1
        [int] $Percentile75Index = 1
    } elseif ( $Stats.Count -eq 4 ){
        [int] $Percentile25Index = 1
        [int] $Percentile75Index = 2
    } elseif ( $Stats.Count -eq 5 ){
        [int] $Percentile25Index = 1
        [int] $Percentile75Index = 3
    } elseif ( $Stats.Count -eq 6 ){
        [int] $Percentile25Index = 1
        [int] $Percentile75Index = 4
    } elseif ( $Stats.Count -eq 7 ){
        [int] $Percentile25Index = 1
        [int] $Percentile75Index = 5
    } elseif ( $Stats.Count -eq 8 ){
        [int] $Percentile25Index = 2
        [int] $Percentile75Index = 5
    } else {
        [int] $Percentile25Index = [math]::Ceiling(25 / 100 * $Data.Count)
        [int] $Percentile75Index = [math]::Ceiling(75 / 100 * $Data.Count)
    }
    [double] $Qt25 = $([double]($Data[$Percentile25Index].$Value))
    [double] $Qt75 = $([double]($Data[$Percentile75Index].$Value))
    [double] $IQR   = $Qt75 - $Qt25
    [double] $HiIQR = $Qt75 + $OutlierMultiple * $IQR
    [double] $LoIQR = $Qt25 - $OutlierMultiple * $IQR
    $hashStatVals["$strQt25"]  = $Qt25
    $hashStatVals["$strQt75"]  = $Qt75
    $hashStatVals["$strIQR"]   = $IQR
    $hashStatVals["$strHiIQR"] = $HiIQR
    $hashStatVals["$strLoIQR"] = $LoIQR

    #region Calculate confidence intervals
    $z = @{
        '90' = 1.645
        '95' = 1.96
        '98' = 2.326
        '99' = 2.576
    }
    [double] $Confidence95 = $z.95 * $Stats.StandardDeviation / [math]::Sqrt($Stats.Count)
    $hashStatVals["$strConfidence95"] = $Confidence95
    # 2nd pass : output each object
    if ( $AllStats ){
        [string[]] $PropAry = @(
            "$strCount",
            "$strSum",
            "$strMean",
            "$strSd",
            "$strMin",
            "$strQt25",
            "$strMedian",
            "$strQt75",
            "$strMax",
            "$strIQR",
            "$strHiIQR",
            "$strLoIQR",
            "$strConfidence95"
        )
    } else {
        [string[]] $PropAry = @(
            "$strCount",
            "$strSum",
            "$strMean",
            "$strSd",
            "$strMin",
            "$strQt25",
            "$strMedian",
            "$strQt75",
            "$strMax"
        )
    }

    foreach ( $obj in @($input | Select-Object *) ){
        if ( $obj.$Value -ne $Null -and $obj.$Value -notmatch '^NA$|^NaN$'){
            # convert psobject to hash
            $hash = [ordered] @{}
            foreach ($item in $obj.psobject.properties){
                $hash[$item.Name] = $item.Value
            }
            foreach ( $k in $PropAry ){
                #Write-Debug "$k, $($hashStatVals[$k])"
                $hash[$k] = $hashStatVals[$k]
            }
            # is value outlier?
            if ( [double]($obj.$Value) -gt $HiIQR ){
                # Outlier from Hi-IQR
                [int] $outlierIndex = 1
            } elseif ( [double]($obj.$Value) -lt $LoIQR ){
                # Outlier from Lo-IQR
                [int] $outlierIndex = 2
            } else {
                # Not Outlier
                [int] $outlierIndex = 0
            }
            $hash["$strOutlier"] = $outlierIndex
            # convert hash to psobject
            New-Object psobject -Property $hash
        }
    }
}
# set alias
[String] $tmpAliasName = "aquart"
[String] $tmpCmdName   = "Add-Quartile"
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
