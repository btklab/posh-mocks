<#
.SYNOPSIS
    percentile - Ranking with percentile and quartile

    Calculate and ranking with percentile and quartiles on space-delimited
    data without headers. 

    Usage:
        cat data.txt | percentile [[-Val] <Int32>] [[-Key] <Int32[]>] [-Rank|-Level5] [-NoHeader] [-Cast <String>]

    Empty records are skipped.
    Input expects space-separated data with headers.
    Headers should be string, not double
    
    Options:
        -NoHeader: No header data

    Example:
        cat iris.csv | percentile -v 1 -k 5 -d "," | ft

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
    cat iris.csv | percentile -d "," 1 | ft

    field        count    sum mean stdev  min Qt25 Qt50 Qt75  max
    -----        -----    --- ---- -----  --- ---- ---- ----  ---
    sepal_length   150 876.50 5.84  0.83 4.30 5.10 5.80 6.40 7.90


    PS > 1..4 | %{ cat iris.csv | percentile -d "," $_ } | ft

    field        count    sum mean stdev  min Qt25 Qt50 Qt75  max
    -----        -----    --- ---- -----  --- ---- ---- ----  ---
    sepal_length   150 876.50 5.84  0.83 4.30 5.10 5.80 6.40 7.90
    sepal_width    150 458.60 3.06  0.44 2.00 2.80 3.00 3.35 4.40
    petal_length   150 563.70 3.76  1.77 1.00 1.55 4.35 5.10 6.90
    petal_width    150 179.90 1.20  0.76 0.10 0.30 1.30 1.80 2.50


    PS > 1..4 | %{ cat iris.csv | percentile -d "," -k 5 $_ } | ft

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

.LINK
    summary

.NOTES
    learn: about sort-object
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/sort-object

#>
function percentile {

    param (
        [Parameter( Mandatory=$False, Position=0 )]
        [Alias('v')]
        [int] $Val,
        
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
            if ( $Key.Count -eq 1 ){
                [int] $sKey = $Key[0] - 1
                [int] $eKey = $Key[0] - 1
            } else {
                [int] $sKey = $Key[0] - 1
                [int] $eKey = $Key[1] - 1
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
        [bool] $getValFieldFlag = $False
        [int] $rowCounter = 0
        [string] $tempLine = ''
        $tempAryList = New-Object 'System.Collections.Generic.List[System.String]'
        $tempValList = New-Object 'System.Collections.Generic.List[System.String]'
    }

    process {
        $rowCounter++
        [string] $readLine = $_.Trim()
        [string[]] $splitReadLine = $readLine -split $iDelim
        if ( $emptyDelimiterFlag ){
            # delete first and last element in $splitReadLine
            [string[]] $splitReadLine = $splitReadLine[1..($splitReadLine.Count - 2)]
        }
        if ( $readLine -eq '' ){
            # skip empty line
            return
        }
        # add header
        if ( $rowCounter -eq 1 ){
            if ( $NoHeader ){
                if ( ($Rank -or $Level5) -and ( -not $Key) ) {
                    # output header
                    [string[]] $headerAry = @()
                    for ( $i = 1; $i -le $splitReadLine.Count; $i++){
                        $headerAry += "F$i"
                    }
                    $headerAry += "percentile"
                    $headerAry += "label"
                    [string] $headerStr = $headerAry -join $oDelim
                    Write-Output $headerStr
                } else {
                    if ( $Val ){
                        [string] $headerStr = "F" + [string]($Val)
                    } else {
                        [string] $headerStr = "F" + [string]($splitReadLine.Count)
                    }
                }
            } else {
                # is header string?
                [string] $headerStr = ''
                if ( $Val ){
                    [string] $headerStr = $splitReadLine[($Val - 1)]
                } else {
                    [string] $headerStr = $splitReadLine[($splitReadLine.Count - 1)]
                }
                if ( isDouble $headerStr ){
                    Write-Error "Header: ""$headerStr"" should be string." -ErrorAction Stop
                }
                # output header
                if ( ($Rank -or $Level5) -and ( -not $Key) ) {
                    # output header
                    $splitReadLine += "percentile"
                    $splitReadLine += "label"
                    [string] $headerStr = $splitReadLine -join $oDelim
                    Write-Output $headerStr
                }
                return
            }
        }
        if ( -not $getValFieldFlag ){
            ## set number of value field
            if ( $Val ){
                [int] $sVal = $Val - 1
            } else {
                [int] $sVal = $splitReadLine.Count - 1
            }
            [bool] $getValFieldFlag = $True
        }
        try {
            $tempAryList.Add( [string] ($readLine) )
            $tempValList.Add( [double] ($splitReadLine[$sVal]) )
        } catch {
            Write-Error $Error[0] -ErrorAction Stop
        }
    }

    end {
        [double[]] $valAry =  $tempValList.ToArray()
        if ($valAry.Count -eq 0){
            return
        }
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
        $statCnt, $statMax, $statMin, $statSum, $statAvg, $statStd = GetStat $valAry

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
        Write-Debug "$sKey, $eKey, $sVal"
        [double] $sum = 0
        if ( $Key ){
            [string[]] $sortedAry = $tempAryList.ToArray() `
                | Sort-Object -Property `
                    { [string](($_ -split $iDelim)[$sKey..$eKey] -join "") },
                    { [double](($_ -split $iDelim)[$sVal]) }
        } else {
            [string[]] $sortedAry = $tempAryList.ToArray() `
                | Sort-Object -Property `
                    { [double](($_ -split $iDelim)[$sVal]) }
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
                [int[]] $posQt50 = getMedianPos $statCnt
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

        function CalcQuartile ( [string[]] $lineAry){
            $posHash = @{}
            $posHash = CalcQuartilePos $lineAry
            [int[]] $posQt25 = $posHash["posQt25"]
            [int[]] $posQt50 = $posHash["posQt50"]
            [int[]] $posQt75 = $posHash["posQt75"]
            [int] $cumCol = $sVal
            Write-Debug "$($cumCol)"
            [double] $Qt25 = ( [double](($lineAry[($posQt25[0])].split($iDelim))[$cumCol]) + [double](($lineAry[($posQt25[1])].split($iDelim))[$cumCol]) ) / 2
            [double] $Qt50 = ( [double](($lineAry[($posQt50[0])].split($iDelim))[$cumCol]) + [double](($lineAry[($posQt50[1])].split($iDelim))[$cumCol]) ) / 2
            [double] $Qt75 = ( [double](($lineAry[($posQt75[0])].split($iDelim))[$cumCol]) + [double](($lineAry[($posQt75[1])].split($iDelim))[$cumCol]) ) / 2
            [double] $IQR = $Qt75 - $Qt25
            [double] $HiIQR = $Qt75 + $OutlierMultiple * $IQR
            [double] $LoIQR = $Qt25 - $OutlierMultiple * $IQR
            return [double[]]@($Qt25, $Qt50, $Qt75, $IQR, $HiIQR, $LoIQR)
        }

        function ApplyQuartile ( [string[]] $lineAry ){
            $Qt25, $Qt50, $Qt75, $IQR, $HiIQR, $LoIQR = CalcQuartile $lineAry
            $lineAry | ForEach-Object {
                [string] $readLine = $_
                [string[]] $splitReadLine = $readLine -split $iDelim
                [double] $calcVal = [double] ($splitReadLine[($sVal)])
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
        if ( ( $Rank ) -and ( -not $Key ) ) {
            ApplyQuartile $sortedAry
            return
        }
        if ( ( $Level5 ) -and ( -not $Key ) ) {
            ApplyQuartile $sortedAry
            return
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
                [double] $LoIQR
            )
            $outObject = [ordered]@{}
            $outObject["field"]  = $valField
            if ( $keyStr -ne ''){
                $outObject["key"]  = $keyStr
            }
            if ( $Cast -eq 'int'){
                $outObject["count"]   = [int64] $statCnt
                $outObject["sum"]     = [int64] $statSum
                $outObject["mean"]     = [int64] $statAvg
                $outObject["stdev"]   = [int64] $statStd
                $outObject["min"]     = [int64] $statMin
                $outObject["Qt25"]    = [int64] $Qt25
                $outObject["Qt50"]    = [int64] $Qt50
                $outObject["Qt75"]    = [int64] $Qt75
                $outObject["max"]     = [int64] $statMax
                $outObject["IQR"]     = [int64] $IQR
                $outObject["HiIQR"]   = [int64] $HiIQR
                $outObject["LoIQR"]   = [int64] $LoIQR
            } else {
                $outObject["count"]   = [int]    $statCnt
                $outObject["sum"]     = [double] $statSum
                $outObject["mean"]     = [double] $statAvg
                $outObject["stdev"]   = [double] $statStd
                $outObject["min"]     = [double] $statMin
                $outObject["Qt25"]    = [double] $Qt25
                $outObject["Qt50"]    = [double] $Qt50
                $outObject["Qt75"]    = [double] $Qt75
                $outObject["max"]     = [double] $statMax
                $outObject["IQR"]     = [double] $IQR
                $outObject["HiIQR"]   = [double] $HiIQR
                $outObject["LoIQR"]   = [double] $LoIQR
            }
            return [pscustomobject]($outObject)
        }
        if ( $Key ){
            [string] $oldKey = ''
            [string] $nowKey = ''
            [int] $rowCounter = 0
            $sortedAry | ForEach-Object {
                $rowCounter++
                [string] $readLine = $_
                [string[]] $splitLine = $readLine -split $iDelim
                [string] $nowKey = $splitLine[$sKey..$eKey] -join $oDelim
                if ( $rowCounter -eq 1 ){
                    $keyAryList = New-Object 'System.Collections.Generic.List[System.String]'
                    $ValAryList = New-Object 'System.Collections.Generic.List[System.String]'
                    $keyAryList.Add( [string]($readLine) )
                    $valAryList.Add( [double]($splitLine[$sVal]) )
                    $oldKey = $nowKey
                    return
                }
                if ( $nowKey -eq $oldKey){
                    $keyAryList.Add( $readLine )
                    $valAryList.Add( $splitLine[$sVal] )
                } else {
                    Write-Debug "$($keyAryList.ToArray())"
                    $statCnt, $statMax, $statMin, $statSum, $statAvg, $statStd = GetStat $valAryList.ToArray()
                    $Qt25, $Qt50, $Qt75, $IQR, $HiIQR, $LoIQR = CalcQuartile $keyAryList.ToArray()
                    Write-Debug "statCnt: $statCnt"
                    Write-Debug "statMax: $statMax"
                    Write-Debug "statMin: $statMin"
                    Write-Debug "statSum: $statSum"
                    Write-Debug "statAvg: $statAvg"
                    Write-Debug "statStd: $statStd"
                    OutObject $headerStr $oldKey $statCnt $statMax $statMin $statSum $statAvg $statStd $Qt25 $Qt50 $Qt75 $IQR $HiIQR $LoIQR
                    $keyAryList = New-Object 'System.Collections.Generic.List[System.String]'
                    $ValAryList = New-Object 'System.Collections.Generic.List[System.String]'
                    $keyAryList.Add( [string]($readLine) )
                    $valAryList.Add( [double]($splitLine[$sVal]) )
                }
                $oldKey = $nowKey
            }
            if ( $keyAryList.ToArray() -ne 0 ){
                Write-Debug "$($keyAryList.ToArray())"
                $statCnt, $statMax, $statMin, $statSum, $statAvg, $statStd = GetStat $valAryList.ToArray()
                $Qt25, $Qt50, $Qt75, $IQR, $HiIQR, $LoIQR = CalcQuartile $keyAryList.ToArray()
                Write-Debug "statCnt: $statCnt"
                Write-Debug "statMax: $statMax"
                Write-Debug "statMin: $statMin"
                Write-Debug "statSum: $statSum"
                Write-Debug "statAvg: $statAvg"
                Write-Debug "statStd: $statStd"
                OutObject $headerStr $nowKey $statCnt $statMax $statMin $statSum $statAvg $statStd $Qt25 $Qt50 $Qt75 $IQR $HiIQR $LoIQR
            }
            return
        }
        if ( $True ){
            Write-Debug "statCnt: $statCnt"
            Write-Debug "statMax: $statMax"
            Write-Debug "statMin: $statMin"
            Write-Debug "statSum: $statSum"
            Write-Debug "statAvg: $statAvg"
            Write-Debug "statStd: $statStd"
            $Qt25, $Qt50, $Qt75, $IQR, $HiIQR, $LoIQR = CalcQuartile $sortedAry   
            OutObject $headerStr '' $statCnt $statMax $statMin $statSum $statAvg $statStd $Qt25 $Qt50 $Qt75 $IQR $HiIQR $LoIQR
            return
        }
    }
}

