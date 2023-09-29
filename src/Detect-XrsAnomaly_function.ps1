<#
.SYNOPSIS
    Detect-XrsAnomaly - Detect anomaly values with X-Rs control

    Anomaly detection on the console without plotting a chart.
    Using the X-Rs control chart algorithm.

        X-Rs Algorithm:

            X      = Specified property's value
            Rs     = Absolute value of the difference from the previous X
            X-Bar  = Mean of X (if -Median specified, Median of X)
            Rs-Bar = Mean of Rs

            X-CL   = X-Bar (if -Median specified, Median of X)
            X-UCL  = X-Bar + 2.659 * Rs-Bar
            X-LCL  = X-Bar - 2.659 * Rs-Bar
            Rs-UCL = 3.267 * Rs-Bar

            UCL: Upper Control Limit
            LCL: Lower Control Limit

            reference:
            Z 9020-2：2016 (ISO 7870-2：2013) 
            https://kikakurui.com/z9/Z9020-2-2016-01.html

            Table 3 - Control limits formula for X control chart
            (individual measurement value control chart)
        
        Deviation judgment is expressed as an integer
        from 0 to 7 in Property="xrs":

            0 ... No deviation
            1 ... Anomalies detected as deviation from the X-UCL line
            2 ... Anomalies detected as deviation from the Rs-UCL line
            4 ... Anomalies detected as deviation from the X-LCL line

            3 ... Detected pattern 1 + 2 = 3
            5 ... Detected pattern 1 + 4 = 5
            6 ... Detected pattern 4 + 2 = 6
            7 ... Detected pattern 1 + 2 + 4 = 7

    Options:
    
        Detect-XrsAnomaly
            [-v|-Value] <String>
                Specify property for detect anomaly value

            [-r|-RowCounter]
                Add row index property

            [-d|-Detail]
                Output all properties

            [-Detect]
                Add a property that outputs "detect" to records
                where abnormal values are detected

            [-o|-OnlyDeviationRecord]
                Output only records with detected abnormal values

.LINK
    Shorten-PropertyName, Drop-NA, Replace-NA, Apply-Function, Add-Stats, Detect-XrsAnomaly, Plot-BarChart, Get-First, Get-Last, Select-Field, Delete-Field

.EXAMPLE
    Import-Csv iris.csv `
        | Shorten-PropertyName `
        | Drop-NA "s_l" `
        | Detect-XrsAnomaly "s_l" -OnlyDeviationRecord -RowCounter `
        | ft

    s_l s_w p_l p_w species    xrs row
    --- --- --- --- -------    --- ---
    4.3 3.0 1.1 0.1 setosa       1  14
    7.0 3.2 4.7 1.4 versicolor   2  51
    7.6 3.0 6.6 2.1 virginica    1 106
    4.9 2.5 4.5 1.7 virginica    2 107
    7.3 2.9 6.3 1.8 virginica    2 108
    7.7 3.8 6.7 2.2 virginica    1 118
    7.7 2.6 6.9 2.3 virginica    1 119
    7.7 2.8 6.7 2.0 virginica    3 123
    7.4 2.8 6.1 1.9 virginica    1 131
    7.9 3.8 6.4 2.0 virginica    1 132
    7.7 3.0 6.1 2.3 virginica    1 136

.EXAMPLE
    Import-Csv iris.csv `
        | Shorten-PropertyName `
        | Drop-NA p_w `
        | sort species -Stable `
        | apply species {
            Detect-XrsAnomaly p_w -Detect -OnlyDeviationRecord } `
        | ft

    s_l s_w p_l p_w species key    xrs detect
    --- --- --- --- ------- ---    --- ------
    5.1 3.3 1.7 0.5 setosa  setosa   3 deviated
    4.8 3.4 1.9 0.2 setosa  setosa   2 deviated
    5.2 4.1 1.5 0.1 setosa  setosa   2 deviated
    5.0 3.5 1.6 0.6 setosa  setosa   3 deviated

.EXAMPLE
    # Detect anomaly values by category(species)

    Import-Csv penguins.csv `
        | Drop-NA bill_length_mm `
        | Shorten-PropertyName `
        | sort species, island -Stable `
        | Apply-Function species, island {
            Detect-XrsAnomaly b_l_m -OnlyDeviationRecord } `
        |  ft count, key, b_l_m, sex, year, xrs

    count key            b_l_m sex  year xrs
    ----- ---            ----- ---  ---- ---
    186   Gentoo, Biscoe 59.6  male 2007   3

    # Visualization by plotting bar chart
    # on the console using Plot-BarChart function

    Import-Csv penguins.csv `
        | Drop-NA bill_length_mm `
        | Shorten-PropertyName `
        | sort species -Stable `
        | Apply-Function species {
            Detect-XrsAnomaly b_l_m -Detect } `
        | Plot-BarChart b_l_m count,species,xrs,detect -w 20 -m "|" `
        | ft `
        | oss `
        | sls "deviated" -Context 3
    
    count species xrs detect   b_l_m BarChart
    ----- ------- --- ------   ----- --------
      183 Gentoo    0           47.3 |||||||||||||||
      184 Gentoo    0           42.8 ||||||||||||||
      185 Gentoo    0           45.1 |||||||||||||||
    > 186 Gentoo    3 deviated  59.6 ||||||||||||||||||||
      187 Gentoo    0           49.1 ||||||||||||||||
      188 Gentoo    0           48.4 ||||||||||||||||
      189 Gentoo    0           42.6 ||||||||||||||

#>
function Detect-XrsAnomaly
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, Position=0)]
        [Alias('v')]
        [String] $Value,
        
        [Parameter(Mandatory=$False)]
        [Alias('d')]
        [switch] $Detail,
        
        [Parameter(Mandatory=$False)]
        [Alias('o')]
        [switch] $OnlyDeviationRecord,
        
        [Parameter(Mandatory=$False)]
        [Alias('r')]
        [switch] $RowCounter,
        
        [Parameter(Mandatory=$False)]
        [switch] $Detect,
        
        [Parameter(Mandatory=$False)]
        [string] $RowCounterPropertyName = "row",
        
        [Parameter(Mandatory=$False)]
        [string] $ResultPropertyName = "xrs",
        
        [Parameter(Mandatory=$False)]
        [switch] $Median,
        
        [Parameter(Mandatory=$False)]
        [switch] $ChartX,
        
        [Parameter(Mandatory=$False)]
        [switch] $ChartRs,
        
        [Parameter(Mandatory=$False, ValueFromPipeline=$True)]
        [PSObject] $InputObject
    )
    # get statistic values of X
    $HashArguments = @{
        Property = $Value
        StandardDeviation = $True
        Average = $True
    }
    if ( $Median ){
        # calculate median
        [string] $mPropName = "X_Median"
        if ( $input.Count % 2 -eq 0){
            # count even
            [int] $MedianIndex = ($input.Count / 2) - 1
            [double] $LowerMedian = $input[$MedianIndex]     | Select-Object -ExpandProperty $Value
            [double] $UpperMedian = $input[$MedianIndex + 1] | Select-Object -ExpandProperty $Value
            [double] $XMedian = ([double]$LowerMedian + [double]$UpperMedian) / 2
        } else {
            # count odd
            [int] $MedianIndex = [math]::Ceiling(($input.Count - 1) / 2)
            $XMedian = $input[$MedianIndex] | Select-Object -ExpandProperty $Value
        }
        [decimal] $XBar = $XMedian
        [decimal] $XCount = $input.Count
    } else {
        [string] $mPropName = "X_Bar"
        [object] $MeasuredData = $input | Measure-Object @HashArguments
        [decimal] $XBar = $MeasuredData.Average
        [decimal] $XCount = $MeasuredData.Count
    }
    # 1st pass
    [bool] $isFirstItem = $True
    [decimal] $oldVal = $Null
    [decimal] $newVal = $Null
    [int] $RsCount = $XCount - 1
    $listRs = New-Object 'System.Collections.Generic.List[System.decimal]'
    foreach ( $obj in $input){
        [decimal] $newVal = $obj.$Value
        if ( $isFirstItem ){
            $isFirstItem = $False
        } else {
            $listRs.Add([math]::Abs( [decimal]($newVal) - [decimal]($oldVal) ))
        }
        [decimal] $oldVal = $newVal
    }
    [decimal[]] $aryRs = $listRs.ToArray()
    [object] $RsBarAndMean = $aryRs | Measure-Object -Average -StandardDeviation
    [decimal] $RsBar = $RsBarAndMean.Average

    # 2nd pass
    [bool] $isFirstItem = $True
    [decimal] $oldVal = $Null
    [decimal] $newVal = $Null
    [int] $rowCnt = 0
    foreach ( $obj in $input){
        $rowCnt++
        [decimal] $newVal = $obj.$Value
        if ( $isFirstItem ){
            $isFirstItem = $False
            if ( $Detail -or $ChartX -or $ChartRs ){
                $obj | Add-Member -NotePropertyName $mPropName -NotePropertyValue $XBar
                $obj | Add-Member -NotePropertyName "Rs"       -NotePropertyValue $Null
                $obj | Add-Member -NotePropertyName "Rs_Bar"   -NotePropertyValue $RsBar
                $obj | Add-Member -NotePropertyName "X_UCL"    -NotePropertyValue $Null
                $obj | Add-Member -NotePropertyName "X_LCL"    -NotePropertyValue $Null
                $obj | Add-Member -NotePropertyName "Rs_UCL"   -NotePropertyValue $Null
            }
            $obj | Add-Member `
                -NotePropertyName $ResultPropertyName `
                -NotePropertyValue $Null
            if ( $RowCounter ){
                $obj | Add-Member `
                    -NotePropertyName $RowCounterPropertyName `
                    -NotePropertyValue $rowCnt
            }
            if ( $Detect ){
                # Add detect mark property
                if ($obj."$ResultPropertyName" -ne 0 -and $obj."$ResultPropertyName" -ne $Null){
                    $obj | Add-Member `
                        -NotePropertyName "detect" `
                        -NotePropertyValue "deviated"
                } else {
                    $obj | Add-Member `
                        -NotePropertyName "detect" `
                        -NotePropertyValue $Null
                }
            }
        } else {
            [decimal] $duration = [math]::Abs( [decimal]($newVal) - [decimal]($oldVal) )
            [decimal] $X_UCL  = $XBar + 2.659 * $RsBar
            [decimal] $X_LCL  = $XBar - 2.659 * $RsBar
            [decimal] $Rs_UCL = 3.267 * $RsBar
            [int] $Result = 0
            if ( $newVal -gt $X_UCL ){
                $Result = $Result + 1
            }
            if ( $Duration -gt $Rs_UCL ){
                $Result = $Result + 2
            }
            if ( $newVal -lt $X_LCL ){
                $Result = $Result + 4
            }
            if ( $Detail -or $ChartX -or $ChartRs ){
                $obj | Add-Member -NotePropertyName $mPropName -NotePropertyValue $XBar
                $obj | Add-Member -NotePropertyName "Rs"       -NotePropertyValue $Duration
                $obj | Add-Member -NotePropertyName "Rs_Bar"   -NotePropertyValue $RsBar
                $obj | Add-Member -NotePropertyName "X_UCL"    -NotePropertyValue $X_UCL
                $obj | Add-Member -NotePropertyName "X_LCL"    -NotePropertyValue $X_LCL
                $obj | Add-Member -NotePropertyName "Rs_UCL"   -NotePropertyValue $Rs_UCL
            }
            $obj | Add-Member -NotePropertyName $ResultPropertyName -NotePropertyValue $Result
            if ( $RowCounter ){
                # Add row counter property
                $obj | Add-Member -NotePropertyName $RowCounterPropertyName -NotePropertyValue $rowCnt
            }
            if ( $Detect ){
                # Add detect mark property
                if ($obj."$ResultPropertyName" -ne 0 -and $obj."$ResultPropertyName" -ne $Null){
                    $obj | Add-Member -NotePropertyName "detect" -NotePropertyValue "deviated"
                } else {
                    $obj | Add-Member -NotePropertyName "detect" -NotePropertyValue $Null
                }
            }
        }
        [decimal] $oldVal = $newVal
        # output
        if ( $OnlyDeviationRecord ){
            $obj | Where-Object {
                    $_."$ResultPropertyName" -ne 0 -and $_."$ResultPropertyName" -ne $Null }
        } elseif ( $ChartX ){
            [string[]] $outputProperties = @(
                "$Value"
                , $mPropName
                , "X_UCL"
                , "X_LCL"
                , $ResultPropertyName
            )
            $obj | Select-Object -Property $outputProperties
        } elseif ( $ChartRs ){
            [string[]] $outputProperties = @(
                "Rs"
                , "Rs_Bar"
                , "Rs_UCL"
                , $ResultPropertyName
            )
            $obj | Select-Object -Property $outputProperties
        } else {
            Write-Output $obj
        }
    }
    Write-Debug "X-UCL    : $X_UCL"
    if ( $Median ){
        Write-Debug "X-Median : $XBar"
    } else {
        Write-Debug "X-Bar    : $XBar"
    }
    Write-Debug "X-LCL    : $X_LCL"
    Write-Debug ""
    Write-Debug "Rs-UCL    : $Rs_UCL"
    Write-Debug "Rs-Bar    : $Duration"
}
