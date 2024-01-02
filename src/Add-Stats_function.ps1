<#
.SYNOPSIS
    Add-Stats (Alias: astat) - Add statistics columns to each record

    For categorical data analysis of time series data.
    Automatically exclude NA, NaN, Null from the specified column.
    Multiple columns can be specified at once.

        Add-Stats [-v] <col>,<col>,... <params>

    Params:
        [-Cnt|-Count]
        [-Sum]
        [-Mean|-Average]
        [-Max|-Maximum]
        [-Min|-Minimum]
        [-SD|-StandardDeviation]
        [-All|-AllStats]
        [-Rs] ...Absolute value of deviation
                 from previous record

    Example:
        1..5 `
            | %{ "$_,$_" } `
            | addt "v1,v2" `
            | ConvertFrom-Csv `
            | Add-Stats v1,v2 -Sum -Mean `
            | ft

        v1 v2 Mean_Of_v1 Mean_Of_v2 Sum_Of_v1 Sum_Of_v2
        -- -- ---------- ---------- --------- ---------
        1  1        3.00       3.00     15.00     15.00
        2  2        3.00       3.00     15.00     15.00
        3  3        3.00       3.00     15.00     15.00
        4  4        3.00       3.00     15.00     15.00
        5  5        3.00       3.00     15.00     15.00

.LINK
    Shorten-PropertyName, Drop-NA, Replace-NA, Apply-Function, Add-Stats, Add-Quartile, Detect-XrsAnomaly, Plot-BarChart, Get-First, Get-Last, Select-Field, Delete-Field

.EXAMPLE
    # Adds the sum and average value for each category (species)
    # of the values in the specified column (sl = sepal_length)
    Import-Csv iris.csv `
        | Shorten-PropertyName -v `
        | Drop-NA sl `
        | sort species -Stable `
        | Apply-Function species {
            Add-Stats sl -Sum -Mean `
            | select -First 3 } `
        | ft

    sl  sw  pl  pw  species    key        Mean_Of_sl Sum_Of_sl
    --  --  --  --  -------    ---        ---------- ---------
    5.1 3.5 1.4 0.2 setosa     setosa           5.01    250.30
    4.9 3.0 1.4 0.2 setosa     setosa           5.01    250.30
    4.7 3.2 1.3 0.2 setosa     setosa           5.01    250.30
    7.0 3.2 4.7 1.4 versicolor versicolor       5.94    296.80
    6.4 3.2 4.5 1.5 versicolor versicolor       5.94    296.80
    6.9 3.1 4.9 1.5 versicolor versicolor       5.94    296.80
    6.3 3.3 6.0 2.5 virginica  virginica        6.59    329.40
    5.8 2.7 5.1 1.9 virginica  virginica        6.59    329.40
    7.1 3.0 5.9 2.1 virginica  virginica        6.59    329.40

.EXAMPLE
    # Adds the sum and average value and
    # Detext X-Rs control deviation and
    # Calculate Deviation from the average value
    # For each record
    Import-Csv iris.csv `
        | Shorten-PropertyName -v `
        | Drop-NA sl `
        | sort species -Stable `
        | Add-Stats sl -Sum -Mean `
        | select *, @{N="DevFromMean";E={$_."sl" - $_."Mean_Of_sl"}} `
        | Detect-XrsAnomaly sl -OnlyDeviationRecord `
        | ft
        
    sl  sw  pl  pw  species    Mean_Of_sl Sum_Of_sl DevFromMean xrs
    --  --  --  --  -------    ---------- --------- ----------- ---
    4.3 3.0 1.1 0.1 setosa           5.84    876.50       -1.54   4
    7.0 3.2 4.7 1.4 versicolor       5.84    876.50        1.16   2
    7.6 3.0 6.6 2.1 virginica        5.84    876.50        1.76   1
    4.9 2.5 4.5 1.7 virginica        5.84    876.50       -0.94   2
    7.3 2.9 6.3 1.8 virginica        5.84    876.50        1.46   2
    7.7 3.8 6.7 2.2 virginica        5.84    876.50        1.86   1
    7.7 2.6 6.9 2.3 virginica        5.84    876.50        1.86   1
    7.7 2.8 6.7 2.0 virginica        5.84    876.50        1.86   3
    7.4 2.8 6.1 1.9 virginica        5.84    876.50        1.56   1
    7.9 3.8 6.4 2.0 virginica        5.84    876.50        2.06   1
    7.7 3.0 6.1 2.3 virginica        5.84    876.50        1.86   1

#>
function Add-Stats
{
    [CmdletBinding()]
    Param(
        [Parameter( Mandatory=$True, Position=0 )]
        [Alias('v')]
        [string[]] $Value,
        
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
        
        [Parameter( Mandatory=$False)]
        [switch] $Rs,
        
        [Parameter( Mandatory=$False)]
        [Alias('SD')]
        [switch] $StandardDeviation,
        
        [Parameter( Mandatory=$False)]
        [string] $Delimiter = "_",
        
        [Parameter(Mandatory=$False, ValueFromPipeline=$True)]
        [PSObject] $InputObject
    )
    # init variables
    # property name prefix for storing statistics per column
    [string] $delim = $Delimiter
    $hashPrePropName = @{
        NewVal = "NewVal" + "${delim}Of${delim}"
        OldVal = "OldVal" + "${delim}Of${delim}"
        OldMax = "OldMax" + "${delim}Of${delim}"
        OldMin = "OldMin" + "${delim}Of${delim}"
        Cnt    = "Count"  + "${delim}Of${delim}"
        Sum    = "Sum"    + "${delim}Of${delim}"
        Mean   = "Mean"   + "${delim}Of${delim}"
        Max    = "Max"    + "${delim}Of${delim}"
        Min    = "Min"    + "${delim}Of${delim}"
        Sd     = "Sd"     + "${delim}Of${delim}"
        Var    = "Var"    + "${delim}Of${delim}"
        DivAndSqr = "DivAndSqr" + "${delim}Of${delim}"
        Rs     = "Rs"     + "${delim}Of${delim}"
        RsCnt  = "RsCnt"  + "${delim}Of${delim}"
        RsSum  = "RsSum"  + "${delim}Of${delim}"
        RsBar  = "RsBar"  + "${delim}Of${delim}"
    }
    [string[]] $ExcludeProperties = @()
    if ( $Count -or $AllStats ){
        # pass
    } else {
        foreach ( $val in $Value ){
            $ExcludeProperties += ,$($hashPrePropName["Cnt"] + "$val")
        }
    }
    if ( $Sum -or $AllStats ){
        # pass
    } else {
        foreach ( $val in $Value ){
            $ExcludeProperties += ,$($hashPrePropName["Sum"] + "$val")
        }
    }
    if ( $Average -or $AllStats ){
        # pass
    } else {
        foreach ( $val in $Value ){
            $ExcludeProperties += ,$($hashPrePropName["Mean"] + "$val")
        }
    }
    if ( $Maximum -or $AllStats ){
        # pass
    } else {
        foreach ( $val in $Value ){
            $ExcludeProperties += ,$($hashPrePropName["Max"] + "$val")
        }
    }
    if ( $Minimum -or $AllStats ){
        # pass
    } else {
        foreach ( $val in $Value ){
            $ExcludeProperties += ,$($hashPrePropName["Min"] + "$val")
        }
    }
    if ( $Rs ){
        # pass
    } else {
        foreach ( $val in $Value ){
            $ExcludeProperties += ,$($hashPrePropName["Rs"]    + "$val")
            $ExcludeProperties += ,$($hashPrePropName["RsCnt"] + "$val")
            $ExcludeProperties += ,$($hashPrePropName["RsBar"] + "$val")
            $ExcludeProperties += ,$($hashPrePropName["RsSum"] + "$val")
        }
    }
    if ( $StandardDeviation -or $AllStats ){
        # pass
    } else {
        foreach ( $val in $Value ){
            $ExcludeProperties += ,$($hashPrePropName["Sd"] + "$val")
            $ExcludeProperties += ,$($hashPrePropName["Var"] + "$val")
        }
    }
    if ( $AllStats ){
        # pass
    }
    # main
    # init hash
    ## Output hash
    $hashStatVals = @{}
    ## Temporary data storing hash (do not outputh)
    $hashCalcVals = @{}
    foreach ( $val in $Value ){
        # for calculation only
        $hashCalcVals.Add($( $hashPrePropName["IsFirstItem"] + "$val"), [bool] $True)
        $hashCalcVals.Add($( $hashPrePropName["NewVal"] + "$val"), [decimal] 0)
        $hashCalcVals.Add($( $hashPrePropName["OldVal"] + "$val"), [decimal] 0)
        $hashCalcVals.Add($( $hashPrePropName["OldMax"] + "$val"), [decimal] 0)
        $hashCalcVals.Add($( $hashPrePropName["OldMin"] + "$val"), [decimal] 0)
        # for output
        $hashStatVals.Add($( $hashPrePropName["Cnt"]   + "$val"), [int] 0)
        $hashStatVals.Add($( $hashPrePropName["Sum"]   + "$val"), [decimal] 0)
        $hashStatVals.Add($( $hashPrePropName["Mean"]  + "$val"), [decimal] 0)
        $hashStatVals.Add($( $hashPrePropName["Max"]   + "$val"), [decimal] 0)
        $hashStatVals.Add($( $hashPrePropName["Min"]   + "$val"), [decimal] 0)
        if ( $StandardDeviation -or $AllStats ){
            $hashCalcVals.Add($( $hashPrePropName["DivAndSqr"] + "$val"), [decimal] 0)

            $hashStatVals.Add($( $hashPrePropName["Var"]  + "$val"), [decimal] 0)
            $hashStatVals.Add($( $hashPrePropName["Sd"]   + "$val"), [decimal] 0)
        }
        if ( $Rs ){
            $hashStatVals.Add($( $hashPrePropName["RsCnt"] + "$val"), [int] 0)
            $hashStatVals.Add($( $hashPrePropName["RsSum"] + "$val"), [decimal] 0)
            $hashStatVals.Add($( $hashPrePropName["RsBar"] + "$val"), [decimal] 0)
        }
    }
    # 1st pass : get sum, count
    [int] $rowCounter = 0
    [object[]] $iObj = $input | Select-Object *
    $iObj = foreach ( $obj in $iObj ){
        $rowCounter++
        # convert psobject to hash
        $hash = [ordered] @{}
        foreach ($item in $obj.psobject.properties){
            $hash[$item.Name] = $item.Value
        }
        foreach ( $val in $Value ){
            if ( ($obj.$val -ne $Null) -and ($obj.$val -notmatch '^NA$|^NaN$') ){
                [decimal] $newVal = $obj.$val
                # is first item?
                [bool] $isFirstItem = $hashCalcVals[$($hashPrePropName["IsFirstItem"] + "$val")]
                if ( $isFirstItem ){
                    $hashCalcVals[$($hashPrePropName["OldVal"] + "$val")] = $newVal
                    $hashCalcVals[$($hashPrePropName["OldMax"] + "$val")] = $newVal
                    $hashCalcVals[$($hashPrePropName["OldMin"] + "$val")] = $newVal
                    [decimal] $oldVal = $newVal
                } else {
                    [decimal] $oldVal = $hashCalcVals[$($hashPrePropName["OldVal"] + "$val")]
                }
                # count
                $hashStatVals[$($hashPrePropName["Cnt"] + "$val")] += 1
                # sum
                $hashStatVals[$($hashPrePropName["Sum"] + "$val")] += $newVal
                # max
                [decimal] $oldMax = $hashCalcVals[$($hashPrePropName["OldMax"] + "$val")]
                if ( $newVal -ge $oldMax ){
                    $hashStatVals[$($hashPrePropName["Max"] + "$val")] = $newVal
                    # set $oldVal = $newVal
                    $hashCalcVals[$($hashPrePropName["OldMax"] + "$val")] = $newVal
                }
                # min
                [decimal] $oldMin = $hashCalcVals[$($hashPrePropName["OldMin"] + "$val")]
                if ( $newVal -le $oldMin ){
                    $hashStatVals[$($hashPrePropName["Min"] + "$val")] = $newVal
                    # set $oldVal = $newVal
                    $hashCalcVals[$($hashPrePropName["OldMin"] + "$val")] = $newVal
                }
                if ( $Rs ){
                    # Rs abs(new - pre)
                    if ( $isFirstItem ){
                        [string] $hKey = $($hashPrePropName["Rs"] + "$val")
                        $hash["$hKey"] = $Null
                    } else {
                        $hashStatVals[$($hashPrePropName["RsCnt"] + "$val")] += 1
                        [decimal] $subVal = $newVal - $oldVal
                        [decimal] $subAbs = [math]::Abs($subVal)
                        $hashStatVals[$($hashPrePropName["RsSum"] + "$val")] += $subAbs
                        [string] $hKey = $($hashPrePropName["Rs"] + "$val")
                        $hash["$hKey"] = $subAbs
                    }
                }
                # set $oldVal = $newVal
                $hashCalcVals[$($hashPrePropName["OldVal"] + "$val")] = $newVal
                # disable first item flag
                $hashCalcVals[$($hashPrePropName["IsFirstItem"] + "$val")] = $False
            } else {
                # pass
                #Write-Error "Detected NaN:$rowCounter : $val : $($obj.$val)" -ErrorAction Stop
            }
        }
        # convert hash to psobject
        New-Object psobject -Property $hash
    }
    # calculate mean, stdev
    foreach ( $val in $Value ){
        # calculate sum, count
        [decimal] $tSum = $hashStatVals[$($hashPrePropName["Sum"] + "$val")]
        [decimal] $tCnt = $hashStatVals[$($hashPrePropName["Cnt"] + "$val")]
        if ( $tCnt -eq 0 ){
            # avoid devided by zero
            $hashStatVals[$($hashPrePropName["Mean"] + "$val")] = "NA"
        } else {
            [decimal] $tMean = $tSum / $tCnt
            $hashStatVals[$($hashPrePropName["Mean"] + "$val")] = $tMean
        }
        #$hashStatVals[$($hashPrePropName["Std"] + "$val")] = 0
        if ( $Rs ){
            # calculate RsBar
            [decimal] $RsSum = $hashStatVals[$($hashPrePropName["RsSum"] + "$val")]
            [decimal] $RsCnt = $hashStatVals[$($hashPrePropName["RsCnt"] + "$val")]
            if ( $RsCnt -eq 0 ){
                # avoid devided by zero
                $hashStatVals[$($hashPrePropName["RsBar"] + "$val")] = "NA"
            } else {
                [decimal] $RsBar = $RsSum / $RsCnt
                $hashStatVals[$($hashPrePropName["RsBar"] + "$val")] = $RsBar
            }
            Write-Debug "Rs Sum, Cnt, Bar: $RsSum, $RsCnt, $RsBar"
        }
        Write-Debug "Sum, Cnt, Bar: $tSum, $tCnt, $tMean"
    }
    if ( $StandardDeviation -or $AllStats ){
        foreach ( $obj in $iObj ){
            foreach ( $val in $Value ){
                if ( ($obj.$val -ne $Null) -and ($obj.$val -notmatch '^NA$|^NaN$') ){
                    # calculate the deviations of each data point from the mean,
                    # and square the result of each:
                    [decimal] $sdVal  = [decimal]($obj.$val)
                    [decimal] $sdMean = [decimal]($hashStatVals[$($hashPrePropName["Mean"] + "$val")])
                    [decimal] $sdDivAndSqr = [math]::Pow(($sdVal - $sdMean), 2)
                    $hashCalcVals[$($hashPrePropName["DivAndSqr"] + "$val")] += $sdDivAndSqr
                }
            }
        }
        # calculate variance
        foreach ( $val in $Value ){
            [decimal] $sdDivAndSqrSum = $hashCalcVals[$($hashPrePropName["DivAndSqr"] + "$val")]
            [int] $sdCnt = $hashStatVals[$($hashPrePropName["Cnt"] + "$val")]
            if ( $sdCnt -eq 0 ){
                # avoid devided by zero
                [decimal] $sdVariance = "NA"
            } else {
                [decimal] $sdVariance = $sdDivAndSqrSum / $sdCnt
                [decimal] $sdStdev = [math]::Sqrt($sdVariance)
            }
            $hashStatVals[$($hashPrePropName["Var"] + "$val")] = $sdVariance
            $hashStatVals[$($hashPrePropName["Sd"]  + "$val")] = $sdStdev
            Write-Debug "Cnt, Variance, Stdev: $sdCnt, $sdVariance, $sdStdev"
        }
    }
    # 2nd pass : output each object
    foreach ( $obj in $iObj ){
        # convert psobject to hash
        $hash = [ordered] @{}
        foreach ($item in $obj.psobject.properties){
            $hash[$item.Name] = $item.Value
        }
        foreach ( $k in @($hashStatVals.Keys | Sort-Object)  ){
            #Write-Debug "$k, $($hashStatVals[$k])"
            $hash["$k"] = $hashStatVals[$k]
        }
        New-Object psobject -Property $hash `
            | Select-Object -ExcludeProperty $ExcludeProperties
    }
}
# set alias
[String] $tmpAliasName = "astat"
[String] $tmpCmdName   = "Add-Stats"
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
