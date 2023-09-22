<#
.SYNOPSIS
    Plot-BarChart - Plot Barchart on the console

        Plot-BarChart

            [-v|-Value] <String>
                Specify value property for plot barchart

            [[-k|-Key] <String[]>] (Optional)
                Specify puroperties to output

            [-w|-Width <Int32>] (Optional)
                Specify the maximum length of the chart from 1 to 100
                default 100

            [-m|-Mark <String>] (Optional)
                Specify the chart string

            [-MaxValue <Int32>] (Optional)
                Specify the maximum value of the chart manually

    Value property accept positive integers or positive decimals.
    Negavive values are considered zero.

    Output all properties by default. If -Key <property,property,...>
    specified, you can filter only required property.

    The maximum length (width) of the bar chart drawing area is as follows:

        (chart available area) =
            (Console width) - (Property width exclude barchart property)

    If specify the "-w|-Width <int 1-100>" option, the maximum width of
    the bar chart strings will be relative to the above width of 100.

    The maximum value of the graph is automatically obtained from the
    specified property.
    If you specify the -MaxValue <int> option, the maximum value will be
    set to the specified value.

.LINK
    Shorten-PropertyName, Drop-NA, Replace-NA, Apply-Function, Add-Stats, Detect-XrsAnomaly, Plot-BarChart, Get-First, Get-Last, Select-Field, Delete-Field

    Add-MovingWindow, Get-Histogram

.EXAMPLE
    1..10 `
        | addt val `
        | ConvertFrom-Csv `
        | Plot-BarChart v -w 10 -m "|"

    val  BarChart
      -  --------
      1  |
      2  ||
      3  |||
      4  ||||
      5  |||||
      6  ||||||
      7  |||||||
      8  ||||||||
      9  |||||||||
      10 ||||||||||

.EXAMPLE
    cat iris.csv `
        | sed 's;([^,])[^,]+..._;$1_;g' `
        | sed 's;(_.)[^,]+;$1;g' `
        | head `
        | ConvertFrom-Csv `
        | Plot-BarChart s_l -w 40 -m "|" `
        | ft

    s_w p_l p_w species s_l BarChart
    --- --- --- ------- --- --------
    3.5 1.4 0.2 setosa  5.1 |||||||||||||||||||||||||||||||||||||
    3.0 1.4 0.2 setosa  4.9 ||||||||||||||||||||||||||||||||||||
    3.2 1.3 0.2 setosa  4.7 ||||||||||||||||||||||||||||||||||
    3.1 1.5 0.2 setosa  4.6 ||||||||||||||||||||||||||||||||||
    3.6 1.4 0.2 setosa  5.0 |||||||||||||||||||||||||||||||||||||
    3.9 1.7 0.4 setosa  5.4 ||||||||||||||||||||||||||||||||||||||||
    3.4 1.4 0.3 setosa  4.6 ||||||||||||||||||||||||||||||||||
    3.4 1.5 0.2 setosa  5.0 |||||||||||||||||||||||||||||||||||||
    2.9 1.4 0.2 setosa  4.4 ||||||||||||||||||||||||||||||||

.EXAMPLE
    # using Import-Excel module
    Import-Excel iris.xlsx `
        | Drop-NA sepal_length `
        | Shorten-PropertyName `
        | Plot-BarChart s_l -m "|" -w 20 `
        | ft

     s_w  p_l  p_w species  s_l BarChart
     ---  ---  --- -------  --- --------
    3.50 1.40 0.20 setosa  5.10 ||||||||||||
    3.00 1.40 0.20 setosa  4.90 ||||||||||||
    3.20 1.30 0.20 setosa  4.70 |||||||||||
    3.10 1.50 0.20 setosa  4.60 |||||||||||
    3.60 1.40 0.20 setosa  5.00 ||||||||||||
    3.90 1.70 0.40 setosa  5.40 |||||||||||||
    ...

.EXAMPLE
    ls ./tmp/ -File `
        | Plot-BarChart Length Name,Length -Mark "|" -w 40 `
        | ft

    Name  Length BarChart
    ----  ------ --------
    a.dot   2178 |||||||||
    a.md     209 |
    a.pu     859 |||
    a.svg   8842 ||||||||||||||||||||||||||||||||||||||||

.EXAMPLE
    cat iris.csv `
        | histogram -d "," -BIN_WIDTH .3 `
        | ConvertFrom-Csv `
        | Plot-BarChart Count sepal_length,Count -w 10 -Mark "@" `
        | ConvertTo-Csv -Delimiter " " `
        | chead `
        | sed 's;";;g' `
        | sed 's;@;| ;g' `
        | tateyoko `
        | tac `
        | keta

    output:
                      |
                      |
              |       |
              |       |
              |       |
              |       |   |       |  |
              |       |   |   |   |  |
      |       |   |   |   |   |   |  |
      |   |   |   |   |   |   |   |  |   |
      |   |   |   |   |   |   |   |  |   |   |   |   |
      9   7  25  11  28  15  13  14 15   6   2   4   1
    4.6 4.9 5.2 5.5 5.8 6.1 6.4 6.7  7 7.3 7.6 7.9 8.2

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
function Plot-BarChart {

    [CmdletBinding()]
    [OutputType('PSCustomObject')]
    param (
        [Parameter( Mandatory=$True, Position=0 )]
        [Alias('v')]
        [string] $Value,
        
        [Parameter( Mandatory=$False, Position=1 )]
        [Alias('k')]
        [string[]] $Key,
        
        [Parameter( Mandatory=$False )]
        [Alias('w')]
        [int] $Width,
        
        [Parameter( Mandatory=$False )]
        [int] $MaxValue,
        
        [Parameter( Mandatory=$False )]
        [Alias('m')]
        [string] $Mark,
        
        [Parameter( Mandatory=$False )]
        [Alias('n')]
        [string] $Name = "BarChart",
        
        [Parameter( Mandatory=$False )]
        [switch] $Percentile,
        
        [Parameter( Mandatory=$False )]
        [switch] $PercentileFromBar,
        
        [parameter( Mandatory=$False, ValueFromPipeline=$True )]
        [array] $InputObject
    )
    function Get-UIBufferSize {
        return (Get-Host).UI.RawUI.BufferSize
    }
    function Get-LineWidth {
        param (
            [Parameter(Mandatory=$True)]
            [string] $Line
        )
        [int] $lineWidth = 0
        $enc = [System.Text.Encoding]::GetEncoding("Shift_JIS")
        [int] $lineWidth = $enc.GetByteCount($Line)
        return $lineWidth
    }
    # Get console width
    [int] $ConsoleWidth = (Get-UIBufferSize).Width
    Write-Debug "Console width = $ConsoleWidth"
    # Get Property MaxValue
    $HashArguments = @{
        Property = $Value
        Maximum = $True
        Minimum = $True
        Average = $True
    }
    [object] $mObj = $input | Measure-Object @HashArguments
    if ( $MaxValue ){
        # Manually set max value of value property
        [decimal] $PropertyMaxValue = $MaxValue
    } else {
        [decimal] $PropertyMaxValue = $mObj.Maximum
    }
    Write-Debug "Property Max = $PropertyMaxValue"
    if ( $PercentileFromBar ){
        [decimal] $PropertyMeanValue  = $mObj.Average
        Write-Debug "Property Mean = $PropertyMeanValue"
    }
    if ( $PercentileFromMin ){
        [decimal] $PropertyMinValue  = $mObj.Minimum
        Write-Debug "Property Min = $PropertyMinValue"
    }
    # Create output property array
    # exclude soecified value property
    [bool] $isValuePropertyExist = $False
    [String[]] $KeyHeaders = ($input[0].PSObject.Properties).Name `
        | ForEach-Object {
            if ( $_ -eq $Value ){
                [bool] $isValuePropertyExist = $True
            }
            if ( $Key ){
                if ( ($Key -contains $_) -and -not ($_ -eq $Value) ){
                    Write-Output $_
                }
            } else {
                if ( $_ -ne $Value ){
                    Write-Output $_
                }
            }
        }
    # test is exist value property
    if ( -not $isValuePropertyExist ){
        Write-Error "Property: $Value is not exists." -ErrorAction Stop
    }
    # set specified value property
    $KeyHeaders += $Value
    Write-Debug "KeyHeaders = $($KeyHeaders -join ', ')"
    # 1st pass: Get KeyProperty maximum width
    # get the longer string length of property name and value
    $hash = @{}
    foreach ( $kh in $KeyHeaders ){
        if ( $kh -ne $Value ){ $hash[$kh] = 0 }
    }
    foreach ( $obj in @($input | Select-Object -Property $KeyHeaders)){
        foreach ( $k in $KeyHeaders ){
            # get length of property name 
            [int] $headLineWidth = Get-LineWidth($k)
            # get length of each property value
            if ( [string]($obj.$k) -eq '' -or $obj.$k -eq $Null ){
                [int] $propLineWidth = 0
            } else {
                [int] $propLineWidth = Get-LineWidth($obj.$k)
            }
            # get the longer string length of property name and value
            if ( $propLineWidth -gt $headLineWidth ){
                # case: property value longer than neme
                if ( $propLineWidth -gt $hash[$k] ){
                    $hash[$k] = $propLineWidth
                }
            } else {
                # case: property name longer than value
                if ( $headLineWidth -gt $hash[$k] ){
                    $hash[$k] = $headLineWidth
                }
            }
        }
    }
    # calculate key property maximum width
    ## Set a space between properties
    [int] $KeyMaxWidth = $KeyHeaders.Count
    ## Add the maximum string width for each property
    foreach ( $k in $hash.keys ){
        $KeyMaxWidth += [int]($hash[$k])
        Write-Debug "$k, $($hash[$k])"
    }
    Write-Debug "KeyMaxWidth = $KeyMaxWidth"
    # get available chart area (console with)
    [int] $MaxRange = $ConsoleWidth - $KeyMaxWidth - 2
    if ( $Percentile -or $PercentileFromBar ){
        [string] $PercentilePropName = "Percent"
        $MaxRange = $MaxRange - ("$PercentilePropName".Length)
    }
    if ( $Width ){
        [int] $MaxRange = $Width
    }
    if ( $MaxRange -lt 1 ){
        [int] $MaxRange = 1
    }
    Write-Debug "MaxRange = $MaxRange"
    # 2nd pass
    ## set bar chart string
    if ( $Mark ){
        [string] $BarCharactor = $Mark
    } else {
        [string] $BarCharactor = [char] 9608
    }
    ## plot barchart
    foreach ( $obj in @($input | Select-Object -Property $KeyHeaders) ){
        [decimal] $Ratio = [decimal]($obj.$Value) / [decimal]($PropertyMaxValue)
        [int] $BarLength = [math]::Floor($MaxRange * $Ratio)
        if ( $BarLength -le 0 ){
            $BarLength = 0
        } elseif ( $BarLength -lt 1 ){
            $BarLength = 1
        }
        Write-Debug "$BarLength / $MaxRange"
        [string] $BarStrings = $BarCharactor * $BarLength
        #[string] $BarStrings = " " * ($BarLength - 1) + $BarCharactor
        if ( $Percentile ){
            $obj | Add-Member `
                -NotePropertyName "$PercentilePropName" `
                -NotePropertyValue $("{0:0.0000}" -f $Ratio)
        } elseif ( $PercentileFromBar ){
            $obj | Add-Member `
                -NotePropertyName "$PercentilePropName" `
                -NotePropertyValue $("{0:0.0000}" -f $($obj.$Value / $PropertyMeanValue))
        } elseif ( $PercentileFromMin ){
            $obj | Add-Member `
                -NotePropertyName "$PercentilePropName" `
                -NotePropertyValue $("{0:0.0000}" -f $($obj.$Value / $PropertyMinValue))
        }
        if ( $True ){
            $obj | Add-Member `
                -NotePropertyName $Name `
                -NotePropertyValue $BarStrings
        }
        $obj
    }
}
