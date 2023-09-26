<#
.SYNOPSIS
    percentile - Ranking with percentile and quartile

    Calculate and ranking with percentile and quartiles on space-delimited
    data with/without headers. 

    Usage:
        cat data.txt | percentile [[-Val] <Int32[]>] [[-Key] <Int32[]>] [-Rank|-Level5] [-NoHeader] [-Cast <String>]

    Empty records are skipped.
    Input expects space-separated data with headers.
    Headers should be string, not double.
    
    Options:
        -NoHeader: No header data

    Example:
        cat iris.csv | percentile -v 1 -k 5 -fs "," | ft

            field        key        count    sum mean stdev  min Qt25 Qt50 Qt75
            -----        ---        -----    --- ---- -----  --- ---- ---- ----
            sepal_length setosa        50 250.30 5.01  0.35 4.30 4.80 5.00 5.20
            sepal_length versicolor    50 296.80 5.94  0.52 4.90 5.60 5.90 6.30
            sepal_length virginica     50 329.40 6.59  0.64 4.90 6.20 6.50 7.00

        "a".."d" | %{ $s=$_; 1..5 | %{ "$s $_" } } | percentile 2 -Level5 -NoHeader | keta

            F1 F2 percentile label
             a  1     0.0167     E
             b  1     0.0333     E
             c  1     0.0500     E
             d  1     0.0667     E
             a  2     0.1000     E
             b  2     0.1333     E
             c  2     0.1667     E
             d  2     0.2000     D
             a  3     0.2500     D
             d  3     0.3000     D
             b  3     0.3500     D
             c  3     0.4000     C
             a  4     0.4667     C
             b  4     0.5333     C
             d  4     0.6000     B
             c  4     0.6667     B
             b  5     0.7500     B
             a  5     0.8333     A
             c  5     0.9167     A
             d  5     1.0000     A


.LINK
    decil, percentile, summary

.PARAMETER Delimiter
    Input/Output field separator.
    Alias: -fs
    Default value is space " ".

.PARAMETER InputDelimiter
    Input field separator.
    Alias: -ifs
    If fs is already set, this option is primarily used.

.PARAMETER OutoputDelimiter
    Output field separator.
    Alias: -ofs
    If fs is already set, this option is primarily used.

.EXAMPLE
    ## Input
    PS > "a".."d" | %{ $s=$_; 1..5 | %{ "$s $_" } }

    a 1
    a 2
    a 3
    a 4
    a 5
    b 1
    b 2
    b 3
    b 4
    b 5
    c 1
    c 2
    c 3
    c 4
    c 5
    d 1
    d 2
    d 3
    d 4
    d 5

    ## calc summary of 2nd field
    "a".."d" | %{ $s=$_; 1..5 | %{ "$s $_" } } | percentile 2 -NoHeader

    field : F2
    count : 20
    sum   : 60
    mean  : 3
    stdev : 1.45095250022002
    min   : 1
    Qt25  : 2
    Qt50  : 3
    Qt75  : 4
    max   : 5
    IQR   : 2
    HiIQR : 7
    LoIQR : -1

    ## same as below (calc rightmost field by default)
    "a".."d" | %{ $s=$_; 1..5 | %{ "$s $_" } } | percentile -NoHeader

    ## percentile 2 -k 1 :
    ##  means summary 2nd field using 1st field as key
    "a".."d" | %{ $s=$_; 1..5 | %{ "$s $_" } } | percentile 2 -k 1 -NoHeader | ft

    field key count   sum mean stdev  min Qt25 Qt50 Qt75
    ----- --- -----   --- ---- -----  --- ---- ---- ----
    F2    a       5 15.00 3.00  1.58 1.00 1.50 3.00 4.50
    F2    b       5 15.00 3.00  1.58 1.00 1.50 3.00 4.50
    F2    c       5 15.00 3.00  1.58 1.00 1.50 3.00 4.50
    F2    d       5 15.00 3.00  1.58 1.00 1.50 3.00 4.50

    ## -k 1,2 means fields from 1st to 2nd are considered keys
    "a".."d" | %{ $s=$_; 1..5 | %{ "$s $s $_" } } | percentile 3 -k 1,2 -NoHeader | ft

    field key count   sum mean stdev  min Qt25 Qt50 Qt75
    ----- --- -----   --- ---- -----  --- ---- ---- ----
    F3    a a     5 15.00 3.00  1.58 1.00 1.50 3.00 4.50
    F3    b b     5 15.00 3.00  1.58 1.00 1.50 3.00 4.50
    F3    c c     5 15.00 3.00  1.58 1.00 1.50 3.00 4.50
    F3    d d     5 15.00 3.00  1.58 1.00 1.50 3.00 4.50

.EXAMPLE
    ## -Rank means ranking with quartile
    ##   add cumulative-ratio and quartile-labels
    "a".."d" | %{ $s=$_; 1..5 | %{ "$s $_" } } | percentile 2 -Rank -NoHeader | keta
    F1 F2 percentile label
     a  1     0.0167   Qt1
     b  1     0.0333   Qt1
     c  1     0.0500   Qt1
     d  1     0.0667   Qt1
     a  2     0.1000   Qt1
     b  2     0.1333   Qt1
     c  2     0.1667   Qt1
     d  2     0.2000   Qt1
     a  3     0.2500   Qt2
     d  3     0.3000   Qt2
     b  3     0.3500   Qt2
     c  3     0.4000   Qt2
     a  4     0.4667   Qt3
     b  4     0.5333   Qt3
     d  4     0.6000   Qt3
     c  4     0.6667   Qt3
     b  5     0.7500   Qt4
     a  5     0.8333   Qt4
     c  5     0.9167   Qt4
     d  5     1.0000   Qt
    
    ## -Level5 means ranking by 20% cumurative ratio
    "a".."d" | %{ $s=$_; 1..5 | %{ "$s $_" } } | percentile 2 -Level5 -NoHeader | keta
    F1 F2 percentile label
     a  1     0.0167     E
     b  1     0.0333     E
     c  1     0.0500     E
     d  1     0.0667     E
     a  2     0.1000     E
     b  2     0.1333     E
     c  2     0.1667     E
     d  2     0.2000     D
     a  3     0.2500     D
     d  3     0.3000     D
     b  3     0.3500     D
     c  3     0.4000     C
     a  4     0.4667     C
     b  4     0.5333     C
     d  4     0.6000     B
     c  4     0.6667     B
     b  5     0.7500     B
     a  5     0.8333     A
     c  5     0.9167     A
     d  5     1.0000     A

.EXAMPLE
    cat iris.csv | percentile -fs "," 1 | ft

    field        count    sum mean stdev  min Qt25 Qt50 Qt75  max
    -----        -----    --- ---- -----  --- ---- ---- ----  ---
    sepal_length   150 876.50 5.84  0.83 4.30 5.10 5.80 6.40 7.90


    PS > cat iris.csv | percentile -fs "," 1,2,3,4 | ft

    field        count    sum mean stdev  min Qt25 Qt50 Qt75  max
    -----        -----    --- ---- -----  --- ---- ---- ----  ---
    sepal_length   150 876.50 5.84  0.83 4.30 5.10 5.80 6.40 7.90
    sepal_width    150 458.60 3.06  0.44 2.00 2.80 3.00 3.35 4.40
    petal_length   150 563.70 3.76  1.77 1.00 1.55 4.35 5.10 6.90
    petal_width    150 179.90 1.20  0.76 0.10 0.30 1.30 1.80 2.50

    
    PS > cat iris.csv | percentile -fs "," 1,2,3,4 -k 5 | ft

    field        key        count    sum mean stdev  min Qt25 Qt50 Qt75
    -----        ---        -----    --- ---- -----  --- ---- ---- ----
    sepal_length setosa        50 250.30 5.01  0.35 4.30 4.80 5.00 5.20
    sepal_length versicolor    50 296.80 5.94  0.52 4.90 5.60 5.90 6.30
    sepal_length virginica     50 329.40 6.59  0.64 4.90 6.20 6.50 7.00
    sepal_width  setosa        50 171.40 3.43  0.38 2.30 3.15 3.40 3.70
    sepal_width  versicolor    50 138.50 2.77  0.31 2.00 2.50 2.80 3.00
    sepal_width  virginica     50 148.70 2.97  0.32 2.20 2.80 3.00 3.20
    petal_length setosa        50  73.10 1.46  0.17 1.00 1.40 1.50 1.60
    petal_length versicolor    50 213.00 4.26  0.47 3.00 4.00 4.35 4.60
    petal_length virginica     50 277.60 5.55  0.55 4.50 5.10 5.55 5.90
    petal_width  setosa        50  12.30 0.25  0.11 0.10 0.20 0.20 0.30
    petal_width  versicolor    50  66.30 1.33  0.20 1.00 1.20 1.30 1.50
    petal_width  virginica     50 101.30 2.03  0.27 1.40 1.80 2.00 2.30

.EXAMPLE
    # Empty value control (empty record detection/removal/replacement)

    # input (include empty value field)
    PS > "a".."d" | %{ $s=$_; 1..5 | %{ "$s,$_" } } | %{ $_ -replace ',5$',',' }
        a,1
        a,2
        a,3
        a,4
        a,
        b,1
        b,2
        b,3
        b,4
        b,
        c,1
        c,2
        c,3
        c,4
        c,
        d,1
        d,2
        d,3
        d,4
        d,

    # detect empty line and stop processing (use -isEmpty option)
    PS > "a".."d" | %{ $s=$_; 1..5 | %{ "$s,$_" } } | %{ $_ -replace ',5$',',' } | percentile -fs "," -NoHeader -isEmpty
        percentile: Detect "Empty" : a,

    # fill empty values with "NaN" (use -FillNaN option)
    PS > "a".."d" | %{ $s=$_; 1..5 | %{ "$s,$_" } } | %{ $_ -replace ',5$',',' } | percentile -fs "," -NoHeader -FillNaN

        field : F2
        count : 20
        sum   : NaN
        mean  : NaN
        stdev : NaN
        min   : NaN
        Qt25  : 1
        Qt50  : 2
        Qt75  : 3
        max   : 4


.EXAMPLE
    # NaN control (Missing value detection/removal/replacement)

    PS > "a".."d" | %{ $s=$_; 1..5 | %{ "$s $_" } } | %{ $_ -replace '5$','NaN' }
        a 1
        a 2
        a 3
        a 4
        a NaN
        b 1
        b 2
        b 3
        b 4
        b NaN
        c 1
        c 2
        c 3
        c 4
        c NaN
        d 1
        d 2
        d 3
        d 4
        d NaN

    PS > "a".."d" | %{ $s=$_; 1..5 | %{ "$s $_" } } | %{ $_ -replace '5$','NaN' } | percentile 2 -NoHeader

        field : F2
        count : 20
        sum   : NaN
        mean  : NaN
        stdev : NaN
        min   : NaN
        Qt25  : 1
        Qt50  : 2
        Qt75  : 3
        max   : 4

    # Output "NaN" information (use -Detail option)
    PS > "a".."d" | %{ $s=$_; 1..5 | %{ "$s $_" } } | %{ $_ -replace '5$','NaN' } | percentile 2 -NoHeader -Detail

        field      : F2
        count      : 20
        sum        : NaN
        mean       : NaN
        stdev      : NaN
        min        : NaN
        Qt25       : 1
        Qt50       : 2
        Qt75       : 3
        max        : 4
        IQR        : 2
        HiIQR      : 6
        LoIQR      : -2
        NaN        : 4
        DropNaN    : 0
        FillNaN    : 0
        ReplaceNaN : 0

    # Detect "NaN" and stop processing (use -isNaN option)
    PS > "a".."d" | %{ $s=$_; 1..5 | %{ "$s $_" } } | %{ $_ -replace '5$','NaN' } | percentile 2 -NoHeader -isNaN
        percentile: Detect "NaN" : a NaN

    # Drop "NaN" (use -DropNaN option)
    PS > "a".."d" | %{ $s=$_; 1..5 | %{ "$s $_" } } | %{ $_ -replace '5$','NaN' } | percentile 2 -NoHeader -DropNaN -Detail

        field      : F2
        count      : 16
        sum        : 40
        mean       : 2.5
        stdev      : 1.15470053837925
        min        : 1
        Qt25       : 1
        Qt50       : 2.5
        Qt75       : 4
        max        : 4
        IQR        : 3
        HiIQR      : 8.5
        LoIQR      : -3.5
        NaN        : 4
        DropNaN    : 4
        FillNaN    : 0
        ReplaceNaN : 0


    # Replace "NaN" (use -ReplaceNaN option)
    PS > "a".."d" | %{ $s=$_; 1..5 | %{ "$s $_" } } | %{ $_ -replace '5$','NaN' } | percentile 2 -NoHeader -ReplaceNaN 0 -Detail

        field      : F2
        count      : 20
        sum        : 40
        mean       : 2
        stdev      : 1.45095250022002
        min        : 0
        Qt25       : 1
        Qt50       : 2
        Qt75       : 3
        max        : 4
        IQR        : 2
        HiIQR      : 6
        LoIQR      : -2
        NaN        : 4
        DropNaN    : 0
        FillNaN    : 0
        ReplaceNaN : 4

.NOTES
    learn: about sort-object
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/sort-object

#>
function percentile {

    param (
        [Parameter( Mandatory=$False, Position=0 )]
        [Alias('v')]
        [int[]] $Val,
        
        [Parameter( Mandatory=$False, Position=1 )]
        [Alias('k')]
        [int[]] $Key,
        
        [Parameter( Mandatory=$False )]
        [Alias('fs')]
        [string] $Delimiter = ' ',
        
        [Parameter( Mandatory=$False )]
        [Alias('ifs')]
        [string] $InputDelimiter,
        
        [Parameter( Mandatory=$False )]
        [Alias('ofs')]
        [string] $OutputDelimiter,
        
        [Parameter( Mandatory=$False )]
        [switch] $NoHeader,
        
        [Parameter( Mandatory=$False )]
        [switch] $Rank,
        
        [Parameter( Mandatory=$False )]
        [double] $OutlierMultiple = 1.5,
        
        [Parameter( Mandatory=$False )]
        [switch] $OffHumanReadable,
        
        [Parameter( Mandatory=$False )]
        [string] $Cast = 'double',
        
        [Parameter( Mandatory=$False )]
        [switch] $Level5,
        
        [Parameter( Mandatory=$False )]
        [switch] $Ascending,
        
        [Parameter( Mandatory=$False )]
        [switch] $DropNaN,
        
        [Parameter( Mandatory=$False )]
        [switch] $FillNaN,
        
        [Parameter( Mandatory=$False )]
        [switch] $isNaN,
        
        [Parameter( Mandatory=$False )]
        [switch] $isEmpty,
        
        [Parameter( Mandatory=$False )]
        [string] $ReplaceNaN,
        
        [Parameter( Mandatory=$False )]
        [Alias('d')]
        [switch] $Detail,
        
        [parameter( Mandatory=$False, ValueFromPipeline=$True )]
        [string[]] $InputText
    )

    begin {
        # set input/output delimiter
        if ( $InputDelimiter -and $OutputDelimiter ){
            [string] $iDelim = $InputDelimiter
            [string] $oDelim = $OutputDelimiter
        } elseif ( $InputDelimiter ){
            [string] $iDelim = $InputDelimiter
            [string] $oDelim = $InputDelimiter
        } elseif ( $OutputDelimiter ){
            [string] $iDelim = $Delimiter
            [string] $oDelim = $OutputDelimiter
        } else {
            [string] $iDelim = $Delimiter
            [string] $oDelim = $Delimiter
        }
        # test is iDelim -eq ''?
        if ($iDelim -eq ''){
            [bool] $emptyDelimiterFlag = $True
        } else {
            [bool] $emptyDelimiterFlag = $False
        }
        # set number of key fields
        if ( $Key ){
            if ( $Rank -or $Level5 ){
                Write-Error "-Key option cannot be used with -Rank or -Level5 options." -ErrorAction Stop
            }
            if ( $Key.Count -eq 1 ){
                [int] $sKey = $Key[0] - 1
                [int] $eKey = $Key[0] - 1
            } else {
                [int] $sKey = $Key[0] - 1
                [int] $eKey = $Key[1] - 1
            }
        }
        if ( $Rank -or $Level5 ){
            if ( $Val.Count -gt 1 ){
                Write-Error "Specify a single value column when -Val using with the -Rank or -Level5 options." -ErrorAction Stop
            }
        }
        # private function
        function isDouble {
            param(
                [parameter(Mandatory=$True, Position=0)]
                [string] $Token
            )
            $Token = $Token.Trim()
            $double = New-Object System.Double
            switch -Exact ( $Token.ToString() ) {
                {[Double]::TryParse( $Token.Replace('_',''), [ref] $double )} {
                    return $True
                }
                default {
                    return $False
                }
            }
        }
        # init variables
        [int] $rowCounter = 0
        [string] $tempLine = ''
        $tempAryList = New-Object 'System.Collections.Generic.List[System.String]'
    }

    process {
        [string] $readLine = $_.Trim()
        if ( $readLine -eq '' ){
            # skip empty line
            return
        }
        if ( $emptyDelimiterFlag ){
            [string[]] $splitReadLine = $readLine.ToCharArray()
        } else {
            [string[]] $splitReadLine = $readLine.Split( $iDelim )
        }
        $rowCounter++
        # add header
        if ( $rowCounter -eq 1 ){
            # set value fields
            if ( -not $Val ){
                [int[]] $vFields = @($splitReadLine.Count - 1)
            } else {
                [int[]] $vFields = foreach ($v in $Val) { $v - 1 }
            }
            if ( $NoHeader ){
                # output header
                [string[]] $headerAry = @()
                for ( $i = 1; $i -le $splitReadLine.Count; $i++){
                    $headerAry += "F$i"
                }
                if ( ($Rank -or $Level5) -and ( -not $Key) ) {
                    $headerAry += "percentile"
                    $headerAry += "label"
                    [string] $headerStr = $headerAry -join $oDelim
                    Write-Output $headerStr
                }
            } else {
                # set headers into array
                [string[]] $headerAry = $splitReadLine
                # test value field
                foreach ( $v in $vFields ){
                    [string] $vStr = $headerAry[$v]
                    if ( isDouble $vStr ){
                        Write-Error "Header: ""$vStr"" should be string." -ErrorAction Stop
                    }
                }
                # output header
                if ( ($Rank -or $Level5) -and ( -not $Key) ) {
                    # output header
                    $headerAry += "percentile"
                    $headerAry += "label"
                    [string] $headerStr = $headerAry -join $oDelim
                    Write-Output $headerStr
                }
                return
            }
        }
        try {
            $tempAryList.Add( [string] ($readLine) )
        } catch {
            Write-Error $Error[0] -ErrorAction Stop
        }
    }

    end {
        # statistics
        function GetStat ( [double[]] $valAry){
            $measureStat = $valAry | Measure-Object -AllStats
            [int]    $statCnt = $measureStat.Count
            [double] $statMax = $measureStat.Maximum
            [double] $statMin = $measureStat.Minimum
            [double] $statSum = $measureStat.Sum
            [double] $statAvg = $measureStat.Average
            [double] $statStd = $measureStat.StandardDeviation
            return [double[]]@($statCnt, $statMax, $statMin, $statSum, $statAvg, $statStd)
        }

        # private function
        function getMedianPos ( [int] $cnt ){
            [int[]] $pos = @(0, 0)
            if ( $cnt -lt 1  ){
                Write-Error "Number of records should greater equal 5." -ErrorAction Stop
            }
            if ( $cnt % 2 -eq 0 ){
                ## even
                [int[]] $pos = @( ($cnt / 2 - 1), ($cnt / 2) )
            } else {
                ## odd
                [int[]] $pos = @( ([math]::Floor($cnt/2)), ([math]::Floor($cnt/2)) )
            }
            return $pos
        }

        # sort by key, value
        function getSortedAry ([string[]] $lineAry, [int] $vField) {
            [double] $sumVal  = 0
            [int] $countNaN   = 0
            [int] $countDropNaN = 0
            [int] $countReplaceNaN = 0
            [int] $countFillNaN    = 0
            if ( $Key ){
                [string[]] $sortedAry = $lineAry `
                    | ForEach-Object {
                        [string[]] $tmpSplitAry = "$_".Split( $iDelim )
                        # treat empty item
                        if ( [string]($tmpSplitAry[$vField]) -eq '' ){
                            # isEmpty
                            if ( $isEmpty ){
                                Write-Error "Detect ""Empty"" : $_" -ErrorAction Stop
                            }
                            # fill NaN
                            if ( $FillNaN ){
                                $countFillNaN++
                                $tmpSplitAry[$vField] = 'NaN'
                            }
                        }
                        # treat NaN
                        if ( [string]($tmpSplitAry[$vField]) -eq 'NaN' ){
                            if ( $isNaN ){
                                Write-Error "Detect ""NaN"" : $_" -ErrorAction Stop
                            }
                            # count NaN
                            $countNaN++
                            # drom NaN
                            if ( $DropNaN ){
                                $countDropNaN++; return
                            }
                            # replace NaN
                            if ( $ReplaceNaN ){
                                $countReplaceNaN++ 
                                $tmpSplitAry[$vField] = ($tmpSplitAry[$vField]).Replace('NaN', $ReplaceNaN)
                            }
                        }
                        $sumVal += [double]($tmpSplitAry[$vField])
                        [string] $writeLine = $tmpSplitAry -join $iDelim
                        Write-Output $writeLine
                        } `
                    | Sort-Object -Property `
                        { [string](("$_".Split( $iDelim ))[$sKey..$eKey] -join "") },
                        { [double](("$_".Split( $iDelim ))[$vField]) }
                return $sortedAry, $sumVal, $countNaN
            } else {
                [string[]] $sortedAry = $lineAry `
                    | ForEach-Object {
                        [string[]] $tmpSplitAry = "$_".Split( $iDelim )
                        # treat empty item
                        if ( [string]($tmpSplitAry[$vField]) -eq '' ){
                            # isEmpty
                            if ( $isEmpty ){
                                Write-Error "Detect ""Empty"" : $_" -ErrorAction Stop
                            }
                            # fill NaN
                            if ( $FillNaN ){
                                $countFillNaN++
                                $tmpSplitAry[$vField] = 'NaN'
                            }
                        }
                        # treat NaN
                        if ( [string]($tmpSplitAry[$vField]) -eq 'NaN' ){
                            if ( $isNaN ){
                                Write-Error "Detect ""NaN"" : $_" -ErrorAction Stop
                            }
                            # count NaN
                            $countNaN++
                            # drom NaN
                            if ( $DropNaN ){ 
                                $countDropNaN++; return
                            }
                            # replace NaN
                            if ( $ReplaceNaN ){
                                $countReplaceNaN++
                                $tmpSplitAry[$vField] = ($tmpSplitAry[$vField]).Replace('NaN', $ReplaceNaN)
                            }
                        }
                        $sumVal += [double]($tmpSplitAry[$vField])
                        [string] $writeLine = $tmpSplitAry -join $iDelim
                        Write-Output $writeLine
                        } `
                    | Sort-Object -Property `
                        { [double](("$_".Split( $iDelim ))[$vField]) }
                return $sortedAry, $sumVal, $countNaN, $countDropNaN, $countFillNaN, $countReplaceNaN
            }
        }

        # calc quartile
        function CalcQuartilePos ( [string[]] $lineAry ){
            if ( $lineAry.Count -eq 1 ){
                [int[]] $posQt25 = @(0, 0)
                [int[]] $posQt50 = @(0, 0)
                [int[]] $posQt75 = @(0, 0)
            } elseif ( $lineAry.Count -eq 2 ){
                [int[]] $posQt25 = @(0, 1)
                [int[]] $posQt50 = @(0, 1)
                [int[]] $posQt75 = @(0, 1)
            } elseif ( $lineAry.Count -eq 3 ){
                [int[]] $posQt25 = @(0, 0)
                [int[]] $posQt50 = @(1, 1)
                [int[]] $posQt75 = @(2, 2)
            } elseif ( $lineAry.Count -eq 4 ){
                [int[]] $posQt25 = @(0, 0)
                [int[]] $posQt50 = @(1, 2)
                [int[]] $posQt75 = @(3, 3)
            } else {
                [int[]] $posQt50 = getMedianPos $lineAry.Count
                [string[]] $tmpQt25 = $lineAry[0..($posQt50[0]-1)]
                [string[]] $tmpQt75 = $lineAry[($posQt50[1]+1)..($lineAry.Count - 1)]
                [int[]] $posQt25 = getMedianPos $tmpQt25.Count
                [int[]] $posQt75 = @( ($posQt50[1]+$posQt25[0]+1), ($posQt50[1]+$posQt25[1]+1) )
            }
            Write-Debug "posQt25: $($posQt25 -join ',')"
            Write-Debug "posQt50: $($posQt50 -join ',')"
            Write-Debug "posQt75: $($posQt75 -join ',')"
            $posHash = @{
                posQt25 = @($posQt25)
                posQt50 = @($posQt50)
                posQt75 = @($posQt75)
            }
            return $posHash
        }

        function CalcQuartile ( [string[]] $lineAry, $vField){
            $posHash = @{}
            $posHash = CalcQuartilePos $lineAry
            [int[]] $posQt25 = $posHash["posQt25"]
            [int[]] $posQt50 = $posHash["posQt50"]
            [int[]] $posQt75 = $posHash["posQt75"]
            [int] $cumCol = $vField
            Write-Debug "$($cumCol)"
            [double] $Qt25 = ( [double](($lineAry[($posQt25[0])].Split($iDelim))[$cumCol]) + [double](($lineAry[($posQt25[1])].Split($iDelim))[$cumCol]) ) / 2
            [double] $Qt50 = ( [double](($lineAry[($posQt50[0])].Split($iDelim))[$cumCol]) + [double](($lineAry[($posQt50[1])].Split($iDelim))[$cumCol]) ) / 2
            [double] $Qt75 = ( [double](($lineAry[($posQt75[0])].Split($iDelim))[$cumCol]) + [double](($lineAry[($posQt75[1])].Split($iDelim))[$cumCol]) ) / 2
            [double] $IQR = $Qt75 - $Qt25
            [double] $HiIQR = $Qt75 + $OutlierMultiple * $IQR
            [double] $LoIQR = $Qt25 - $OutlierMultiple * $IQR
            return [double[]]@($Qt25, $Qt50, $Qt75, $IQR, $HiIQR, $LoIQR)
        }

        function ApplyQuartile ( [string[]] $lineAry, [int] $vField, [double] $statSum ){
            [double] $sum = 0
            $Qt25, $Qt50, $Qt75, $IQR, $HiIQR, $LoIQR = CalcQuartile $lineAry $vField
            $lineAry | ForEach-Object {
                [string] $readLine = $_
                [string[]] $splitReadLine = $readLine.Split( $iDelim )
                [double] $calcVal = [double] ($splitReadLine[($vField)])
                [double] $sum += $calcVal
                [double] $cum = $sum / $statSum
                $splitReadLine += $cum.ToString('#,0.0000')
                if ($Level5){
                    if ( $cum -lt 0.2 ){
                        $splitReadLine += 'E'
                    } elseif ( $cum -lt 0.4 ) {
                        $splitReadLine += 'D'
                    } elseif ( $cum -lt 0.6 ) {
                        $splitReadLine += 'C'
                    } elseif ( $cum -lt 0.8 ) {
                        $splitReadLine += 'B'
                    } else {
                        $splitReadLine += 'A'
                    }
                } else {
                    # IQR
                    if ( $calcVal -lt $LoIQR ){
                        $splitReadLine += 'Outlier-Lo'
                    } elseif ( $calcVal -le $Qt25 ) {
                        $splitReadLine += 'Qt1'
                    } elseif ( $calcVal -le $Qt50 ) {
                        $splitReadLine += 'Qt2'
                    } elseif ( $calcVal -le $Qt75 ) {
                        $splitReadLine += 'Qt3'
                    } elseif ( $calcVal -le $HiIQR ) {
                        $splitReadLine += 'Qt4'
                    } else {
                        $splitReadLine += 'Outlier-Hi'
                    }
                }
                [string] $writeLine = $splitReadLine -join $oDelim
                Write-Output $writeLine
            }
        }

        function OutObject {
            param (
                [string] $valField,
                [string] $keyStr,
                [int] $statCnt,
                [double] $statMax,
                [double] $statMin,
                [double] $statSum,
                [double] $statAvg,
                [double] $statStd,
                [double] $Qt25,
                [double] $Qt50,
                [double] $Qt75,
                [double] $IQR,
                [double] $HiIQR,
                [double] $LoIQR,
                [int] $NaNCnt,
                [int] $countDropNaN,
                [int] $countFillNaN,
                [int] $countReplaceNaN
            )
            $outObject = [ordered]@{}
            if ( $valField -ne '' ) {
                $outObject["field"]  = $valField
            }
            if ( $keyStr -ne '' ){
                $outObject["key"]  = $keyStr
            }
            if ( $Cast -eq 'int' ){
                $outObject["count"]   = [int64] $statCnt
                $outObject["sum"]     = [int64] $statSum
                $outObject["mean"]    = [int64] $statAvg
                $outObject["stdev"]   = [int64] $statStd
                $outObject["min"]     = [int64] $statMin
                $outObject["Qt25"]    = [int64] $Qt25
                $outObject["Qt50"]    = [int64] $Qt50
                $outObject["Qt75"]    = [int64] $Qt75
                $outObject["max"]     = [int64] $statMax
                if ( $Detail ){
                    $outObject["IQR"]        = [int64] $IQR
                    $outObject["HiIQR"]      = [int64] $HiIQR
                    $outObject["LoIQR"]      = [int64] $LoIQR
                    $outObject["NaN"]        = [int] $NaNCnt
                    $outObject["DropNaN"]    = [int] $countDropNaN
                    $outObject["FillNaN"]    = [int] $countFillNaN
                    $outObject["ReplaceNaN"] = [int] $countReplaceNaN
                }
            } else {
                $outObject["count"]   = [int]    $statCnt
                $outObject["sum"]     = [double] $statSum
                $outObject["mean"]    = [double] $statAvg
                $outObject["stdev"]   = [double] $statStd
                $outObject["min"]     = [double] $statMin
                $outObject["Qt25"]    = [double] $Qt25
                $outObject["Qt50"]    = [double] $Qt50
                $outObject["Qt75"]    = [double] $Qt75
                $outObject["max"]     = [double] $statMax
                if ( $Detail ){
                    $outObject["IQR"]        = [double] $IQR
                    $outObject["HiIQR"]      = [double] $HiIQR
                    $outObject["LoIQR"]      = [double] $LoIQR
                    $outObject["NaN"]        = [int] $NaNCnt
                    $outObject["DropNaN"]    = [int] $countDropNaN
                    $outObject["FillNaN"]    = [int] $countFillNaN
                    $outObject["ReplaceNaN"] = [int] $countReplaceNaN
                }
            }
            return [pscustomobject]($outObject)
        }

        # main
        [string[]] $tmpAry = $tempAryList.ToArray()
        if ($tmpAry.Count -eq 0){
            return
        }
        if ( ( $Rank ) -and ( -not $Key ) ) {
            try {
                [string[]] $sortedAry, $sumVal, $countNaN, $countDropNaN, $countFillNaN, $countReplaceNaN = getSortedAry $tmpAry $vFields[0]
            } catch {
                Write-Error $Error[0] -ErrorAction Stop
            }
            ApplyQuartile $sortedAry $vFields[0] $sumVal
            return
        }
        if ( ( $Level5 ) -and ( -not $Key ) ) {
            try {
                [string[]] $sortedAry, $sumVal, $countNaN, $countDropNaN, $countFillNaN, $countReplaceNaN = getSortedAry $tmpAry $vFields[0]
            } catch {
                Write-Error $Error[0] -ErrorAction Stop
            }
            ApplyQuartile $sortedAry $vFields[0] $sumVal
            return
        }
        foreach ( $vField in $vFields ) {
            try {
                [string[]] $sortedAry, $sumVal, $countNaN, $countDropNaN, $countFillNaN, $countReplaceNaN = getSortedAry $tmpAry $vField
            } catch {
                Write-Error $Error[0] -ErrorAction Stop
            }
            if ( $Key ){
                [string] $oldKey = ''
                [string] $nowKey = ''
                [int] $rowCounter = 0
                $sortedAry | ForEach-Object {
                    $rowCounter++
                    [string] $readLine = $_
                    [string[]] $splitLine = $readLine.Split( $iDelim )
                    [string] $nowKey = $splitLine[$sKey..$eKey] -join $oDelim
                    if ( $rowCounter -eq 1 ){
                        $keyAryList = New-Object 'System.Collections.Generic.List[System.String]'
                        $ValAryList = New-Object 'System.Collections.Generic.List[System.String]'
                        $keyAryList.Add( [string]($readLine) )
                        $valAryList.Add( [double]($splitLine[$vField]) )
                        $oldKey = $nowKey
                        return
                    }
                    if ( $nowKey -eq $oldKey){
                        $keyAryList.Add( $readLine )
                        $valAryList.Add( $splitLine[$vField] )
                    } else {
                        Write-Debug "$($keyAryList.ToArray())"
                        $statCnt, $statMax, $statMin, $statSum, $statAvg, $statStd = GetStat $valAryList.ToArray()
                        $Qt25, $Qt50, $Qt75, $IQR, $HiIQR, $LoIQR = CalcQuartile $keyAryList.ToArray() $vField
                        Write-Debug "statCnt: $statCnt"
                        Write-Debug "statMax: $statMax"
                        Write-Debug "statMin: $statMin"
                        Write-Debug "statSum: $statSum"
                        Write-Debug "statAvg: $statAvg"
                        Write-Debug "statStd: $statStd"
                        OutObject $headerAry[$vField] $oldKey $statCnt $statMax $statMin $statSum $statAvg $statStd $Qt25 $Qt50 $Qt75 $IQR $HiIQR $LoIQR $countNaN $countDropNaN $countFillNaN $countReplaceNaN
                        $keyAryList = New-Object 'System.Collections.Generic.List[System.String]'
                        $ValAryList = New-Object 'System.Collections.Generic.List[System.String]'
                        $keyAryList.Add( [string]($readLine) )
                        $valAryList.Add( [double]($splitLine[$vField]) )
                    }
                    $oldKey = $nowKey
                }
                if ( $keyAryList.ToArray() -ne 0 ){
                    Write-Debug "$($keyAryList.ToArray())"
                    $statCnt, $statMax, $statMin, $statSum, $statAvg, $statStd = GetStat $valAryList.ToArray()
                    $Qt25, $Qt50, $Qt75, $IQR, $HiIQR, $LoIQR = CalcQuartile $keyAryList.ToArray() $vField
                    Write-Debug "statCnt: $statCnt"
                    Write-Debug "statMax: $statMax"
                    Write-Debug "statMin: $statMin"
                    Write-Debug "statSum: $statSum"
                    Write-Debug "statAvg: $statAvg"
                    Write-Debug "statStd: $statStd"
                    OutObject $headerAry[$vField] $nowKey $statCnt $statMax $statMin $statSum $statAvg $statStd $Qt25 $Qt50 $Qt75 $IQR $HiIQR $LoIQR $countNaN $countDropNaN $countFillNaN $countReplaceNaN
                }
                continue
            }
            if ( $True ){
                Write-Debug "statCnt: $statCnt"
                Write-Debug "statMax: $statMax"
                Write-Debug "statMin: $statMin"
                Write-Debug "statSum: $statSum"
                Write-Debug "statAvg: $statAvg"
                Write-Debug "statStd: $statStd"
                try {
                    [string[]] $sortedAry, $sumVal, $countNaN, $countDropNaN, $countFillNaN, $countReplaceNaN = getSortedAry $tmpAry $vField
                } catch {
                    Write-Error $Error[0] -ErrorAction Stop
                }
                $statCnt, $statMax, $statMin, $statSum, $statAvg, $statStd = GetStat @(
                    $sortedAry | ForEach-Object {
                        ("$_".Split( $iDelim ))[$vField]
                    }
                )
                $Qt25, $Qt50, $Qt75, $IQR, $HiIQR, $LoIQR = CalcQuartile $sortedAry $vField
                OutObject $headerAry[$vField] '' $statCnt $statMax $statMin $statSum $statAvg $statStd $Qt25 $Qt50 $Qt75 $IQR $HiIQR $LoIQR $countNaN $countDropNaN $countFillNaN $countReplaceNaN
                continue
            }
        }
    }
}
