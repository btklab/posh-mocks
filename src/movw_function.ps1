<#
.SYNOPSIS
    movw - Moving window approach

    Implementation of moving window approach.
    ref: https://www.sciencedirect.com/science/article/abs/pii/S0956713515001061


    cat iris.txt | movw -Num 1 -WindowSize 5 -AcceptableLevel 4.7 -MaxLimit 5.5 -MaxFrequency 3

    s_l AcceptableLevel MaxLimit MaxFrequency WindowSize Res
    --- --------------- -------- ------------ ---------- ---
    5.1 NaN             NaN      NaN          NaN        NaN
    4.9 NaN             NaN      NaN          NaN        NaN
    4.7 NaN             NaN      NaN          NaN        NaN
    4.6 NaN             NaN      NaN          NaN        NaN
    5.0 4.7             5.5      3            5          1
    5.4 4.7             5.5      3            5          1
    4.6 4.7             5.5      3            5          0
    5.0 4.7             5.5      3            5          1
    4.4 4.7             5.5      3            5          1
    4.9 4.7             5.5      3            5          1
    5.4 4.7             5.5      3            5          1
    4.8 4.7             5.5      3            5          1

    Corrective action is triggered by exceeding either (c) or (M):

        Limit that will start corrective measures when
        this value deviates at least once in the window

            (M) Max limit

        Levels that will start corrective measures when
        "-AcceptableLevel" deviations occur more than
        "-MaxFrequency" times in "-WindowSize" range

            (m) AcceptableLevel: a marginally acceptable level
            (n) WindowSize: moving window size
            (c) Maximum frequency (c) of all samples taken
                during the specified period (n)


    The evaluation result is output in the "Res" field.
    The meaning of the numerical value is as follows:

        0: Clear (no need to start corrective action)
        1: Over MaxFrequency (need to start corrective action)
        2: Over MaxLimit (need to start corrective action)
        3: Over MaxFrequency and over MaxLimit (same as 1, 2)

    Notes:
    
        - The moving window approach for implementing microbiological criteria
          is described.
        - The approach can be a cost-effective means to demonstrate acceptable
          performance of a food safety management system.
        - The approach is appropriate where the between-lot variability of samples
          is less than the within-lot variability.

.LINK
    movw, mave

.PARAMETER Num
    Field number to be calculated.
    Defalut: 1

.PARAMETER NoHeader
    If there is no header in the data,
    specify this option.

.PARAMETER WindowSize
    (n) Window size (number)

.PARAMETER MaxLimit
    (M) Max limit in the window

    Limit that will start corrective measures when
    this value deviates at least once in the window

.PARAMETER AcceptableLevel
    (m) AcceptableLevel in the window

    Level that will start corrective measures when
    "-AcceptableLevel" deviations occur more than
    "-MaxFrequency" times in "-WindowSize" range

.PARAMETER MaxFrequency
    (c) Max frequency permitted deviation of "-AcceptableLevel"

    Frequency that will start corrective measures when
    "-AcceptableLevel" deviations occur more than
    "-MaxFrequency" times in "-WindowSize" range

.PARAMETER ReverseLimit
    Reverses Limit. 
    Do not support the upper limit and lower limit
    at the same time

.PARAMETER OnlyResult
    Only output results


.EXAMPLE
    cat iris.csv | sed 's;,; ;g' | head -n 20

    s_l s_w p_l p_w species
    5.1 3.5 1.4 0.2 setosa
    4.9 3.0 1.4 0.2 setosa
    4.7 3.2 1.3 0.2 setosa
    4.6 3.1 1.5 0.2 setosa
    5.0 3.6 1.4 0.2 setosa
    5.4 3.9 1.7 0.4 setosa
    4.6 3.4 1.4 0.3 setosa
    5.0 3.4 1.5 0.2 setosa
    4.4 2.9 1.4 0.2 setosa
    4.9 3.1 1.5 0.1 setosa
    5.4 3.7 1.5 0.2 setosa
    4.8 3.4 1.6 0.2 setosa
    4.8 3.0 1.4 0.1 setosa
    4.3 3.0 1.1 0.1 setosa
    5.8 4.0 1.2 0.2 setosa
    5.7 4.4 1.5 0.4 setosa
    5.4 3.9 1.3 0.4 setosa
    5.1 3.5 1.4 0.3 setosa
    5.7 3.8 1.7 0.3 setosa

    PS > cat iris.csv | sed 's;,; ;g' | movw -WindowSize 5 -AcceptableLevel 4.7 -MaxLimit 5.5 -MaxFrequency 3

    s_l s_w p_l p_w species AcceptableLevel MaxLimit MaxFrequency WindowSize Res
    5.1 3.5 1.4 0.2 setosa NaN NaN NaN NaN NaN
    4.9 3.0 1.4 0.2 setosa NaN NaN NaN NaN NaN
    4.7 3.2 1.3 0.2 setosa NaN NaN NaN NaN NaN
    4.6 3.1 1.5 0.2 setosa NaN NaN NaN NaN NaN
    5.0 3.6 1.4 0.2 setosa 4.7 5.5 3 5 1
    5.4 3.9 1.7 0.4 setosa 4.7 5.5 3 5 1
    4.6 3.4 1.4 0.3 setosa 4.7 5.5 3 5 0
    5.0 3.4 1.5 0.2 setosa 4.7 5.5 3 5 1
    4.4 2.9 1.4 0.2 setosa 4.7 5.5 3 5 1
    4.9 3.1 1.5 0.1 setosa 4.7 5.5 3 5 1
    5.4 3.7 1.5 0.2 setosa 4.7 5.5 3 5 1
    4.8 3.4 1.6 0.2 setosa 4.7 5.5 3 5 1
    4.8 3.0 1.4 0.1 setosa 4.7 5.5 3 5 1
    4.3 3.0 1.1 0.1 setosa 4.7 5.5 3 5 1
    5.8 4.0 1.2 0.2 setosa 4.7 5.5 3 5 3
    5.7 4.4 1.5 0.4 setosa 4.7 5.5 3 5 3
    5.4 3.9 1.3 0.4 setosa 4.7 5.5 3 5 3
    5.1 3.5 1.4 0.3 setosa 4.7 5.5 3 5 3
    5.7 3.8 1.7 0.3 setosa 4.7 5.5 3 5 3

.EXAMPLE
    # -Num 2 approaches the 2nd row of input data
    cat ..\DATASETS\iris.csv | sed 's;,; ;g' | movw -Num 2 -WindowSize 5 -AcceptableLevel 4.7 -MaxLimit 5.5 -MaxFrequency 3

    s_l s_w p_l p_w species AcceptableLevel MaxLimit MaxFrequency WindowSize Res
    5.1 3.5 1.4 0.2 setosa NaN NaN NaN NaN NaN
    4.9 3.0 1.4 0.2 setosa NaN NaN NaN NaN NaN
    4.7 3.2 1.3 0.2 setosa NaN NaN NaN NaN NaN
    4.6 3.1 1.5 0.2 setosa NaN NaN NaN NaN NaN
    5.0 3.6 1.4 0.2 setosa 4.7 5.5 3 5 0
    5.4 3.9 1.7 0.4 setosa 4.7 5.5 3 5 0
    4.6 3.4 1.4 0.3 setosa 4.7 5.5 3 5 0
    5.0 3.4 1.5 0.2 setosa 4.7 5.5 3 5 0
    4.4 2.9 1.4 0.2 setosa 4.7 5.5 3 5 0
    4.9 3.1 1.5 0.1 setosa 4.7 5.5 3 5 0
    5.4 3.7 1.5 0.2 setosa 4.7 5.5 3 5 0
    4.8 3.4 1.6 0.2 setosa 4.7 5.5 3 5 0
    4.8 3.0 1.4 0.1 setosa 4.7 5.5 3 5 0
    4.3 3.0 1.1 0.1 setosa 4.7 5.5 3 5 0
    5.8 4.0 1.2 0.2 setosa 4.7 5.5 3 5 0
    5.7 4.4 1.5 0.4 setosa 4.7 5.5 3 5 0
    5.4 3.9 1.3 0.4 setosa 4.7 5.5 3 5 0
    5.1 3.5 1.4 0.3 setosa 4.7 5.5 3 5 0
    5.7 3.8 1.7 0.3 setosa 4.7 5.5 3 5 0

.EXAMPLE
    # -OnlyResult output only result field
    cat iris.csv `
        | sed 's;,; ;g' `
        | movw `
            -WindowSize 5 `
            -AcceptableLevel 4.7 `
            -MaxLimit 5.5 `
            -MaxFrequency 3 `
            -OnlyResult

    s_l s_w p_l p_w species Res
    5.1 3.5 1.4 0.2 setosa NaN
    4.9 3.0 1.4 0.2 setosa NaN
    4.7 3.2 1.3 0.2 setosa NaN
    4.6 3.1 1.5 0.2 setosa NaN
    5.0 3.6 1.4 0.2 setosa 1
    5.4 3.9 1.7 0.4 setosa 1
    4.6 3.4 1.4 0.3 setosa 0
    5.0 3.4 1.5 0.2 setosa 1
    4.4 2.9 1.4 0.2 setosa 1
    4.9 3.1 1.5 0.1 setosa 1
    5.4 3.7 1.5 0.2 setosa 1
    4.8 3.4 1.6 0.2 setosa 1
    4.8 3.0 1.4 0.1 setosa 1
    4.3 3.0 1.1 0.1 setosa 1
    5.8 4.0 1.2 0.2 setosa 3
    5.7 4.4 1.5 0.4 setosa 3
    5.4 3.9 1.3 0.4 setosa 3
    5.1 3.5 1.4 0.3 setosa 3
    5.7 3.8 1.7 0.3 setosa 3

.EXAMPLE
    # -ReverseLimit reverses Limit. 
    # In this case, -MaxLimit is the acceptable limit
    cat iris.csv `
        | sed 's;,; ;g' `
        | head -n 20 `
        | movw -Num 1 `
               -WindowSize 5 `
               -AcceptableLevel 4.7 `
               -MaxLimit 4.5 `
               -MaxFrequency 3 `
               -OnlyResult `
               -ReverseLimit

    s_l s_w p_l p_w species Res
    5.1 3.5 1.4 0.2 setosa NaN
    4.9 3.0 1.4 0.2 setosa NaN
    4.7 3.2 1.3 0.2 setosa NaN
    4.6 3.1 1.5 0.2 setosa NaN
    5.0 3.6 1.4 0.2 setosa 0
    5.4 3.9 1.7 0.4 setosa 0
    4.6 3.4 1.4 0.3 setosa 0
    5.0 3.4 1.5 0.2 setosa 0
    4.4 2.9 1.4 0.2 setosa 2
    4.9 3.1 1.5 0.1 setosa 2
    5.4 3.7 1.5 0.2 setosa 2
    4.8 3.4 1.6 0.2 setosa 2
    4.8 3.0 1.4 0.1 setosa 2
    4.3 3.0 1.1 0.1 setosa 2
    5.8 4.0 1.2 0.2 setosa 2
    5.7 4.4 1.5 0.4 setosa 2
    5.4 3.9 1.3 0.4 setosa 2
    5.1 3.5 1.4 0.3 setosa 2
    5.7 3.8 1.7 0.3 setosa 0

#>
function movw {
    Param(
        [Parameter(Mandatory=$False, Position=0)]
        [int] $Num = 1,

        [Parameter(Mandatory=$True)]
        [Alias('n')]
        [int] $WindowSize,

        [Parameter(Mandatory=$True)]
        [Alias('a')]
        [double] $AcceptableLevel,

        [Parameter(Mandatory=$True)]
        [Alias('M')]
        [double] $MaxLimit,

        [Parameter(Mandatory=$True)]
        [Alias('c')]
        [double] $MaxFrequency,

        [Parameter(Mandatory=$False)]
        [switch] $ReverseLimit,

        [Parameter(Mandatory=$False)]
        [switch] $OnlyResult,

        [Parameter(Mandatory=$False)]
        [switch] $NoHeader,

        [Parameter(Mandatory=$False)]
        [Alias('d')]
        [string] $Delimiter = ' ',

        [Parameter(Mandatory=$False)]
        [string] $NaN = 'NaN',

        [parameter(Mandatory=$False,
            ValueFromPipeline=$True)]
        [string[]] $Text
    )

    begin{
        ## init var
        [int] $rowCounter = 0
        [int] $datCol = $Num - 1
        [int] $mwCounter = 0
        [string[]] $mwAry = @()
        ## test option
        if ($MaxFrequency -gt $WindowSize ){
            Write-Error "-MaxFrequency should be smaller integer than -WindowSize" -ErrorAction Stop
        }
        if ($ReverseLimit){
            if ($AcceptableLevel -lt $MaxLimit ){
                Write-Error "-MaxLimit should be smaller than -AcceptableLevel" -ErrorAction Stop
            }
        }else{
            if ($AcceptableLevel -gt $MaxLimit ){
                Write-Error "-MaxLimit should be larger than -AcceptableLevel" -ErrorAction Stop
            }
        }
        ## private function
        function getWriteLine ([string]$readLine, [string[]]$lineAry){
            [bool] $maxLimitFlag = $False
            [bool] $acceptableLevelFlag = $False
            [int] $acceptableLevelCount = 0
            for($i = 0; $i -lt $lineAry.Count; $i++){
                ## check MaxLimit and acceptableLevel
                if ($ReverseLimit){
                    if([double]($lineAry[$i]) -lt $MaxLimit){ $maxLimitFlag = $True}
                    if([double]($lineAry[$i]) -lt $AcceptableLevel){ $acceptableLevelCount++}
                }else{
                    if([double]($lineAry[$i]) -gt $MaxLimit){ $maxLimitFlag = $True}
                    if([double]($lineAry[$i]) -gt $AcceptableLevel){ $acceptableLevelCount++}
                }
            }
            ## calc acceptableLevelCount
            if ($acceptableLevelCount -ge $MaxFrequency){ $acceptableLevelFlag = $True }
            ## output: 0:OK, 1:over Frequency, 2:over MaxLimit, 3:1and2
            [int] $outLevel = 0
            if ($acceptableLevelFlag){ $outLevel += 1 }
            if ($maxLimitFlag){ $outLevel += 2 }
            [string[]] $outputResAry = @()
            $outputResAry += [string]$readLine
            if( -not $OnlyResult ){
                $outputResAry += [string]$AcceptableLevel
                $outputResAry += [string]$MaxLimit
                $outputResAry += [string]$MaxFrequency
                $outputResAry += [string]$WindowSize
            }
            $outputResAry += [string]$outLevel
            $writeLine = $outputResAry -Join $Delimiter
            return $writeLine
        }
    }
    process{
        $rowCounter++
        [string] $writeLine = ''
        [string] $readLine = $_
        if( -not $NoHeader -and ($rowCounter -eq 1)){
            ## add header
            [string[]] $headerAry = @()
            $headerAry += $readLine
            if ( -not $OnlyResult ){
                $headerAry += "AcceptableLevel"
                $headerAry += "MaxLimit"
                $headerAry += "MaxFrequency"
                $headerAry += "WindowSize"
            }
            $headerAry += "Res"
            [string] $writeLine = $headerAry -Join $Delimiter
            Write-Output $writeLine
        }else{
            ## calc movin window
            $mwCounter++
            if ( $Delimiter -eq '' ){
                [string[]] $splitLine = $readLine.ToCharArray()
            } else {
                [string[]] $splitLine = $readLine.Split( $Delimiter )
            }
            # add elements to the array up to the number of
            # designated lines
            if($mwCounter -lt $WindowSize){
                [string[]] $writeLineAry = @()
                $writeLineAry += $readLine
                if( -not $OnlyResult ){
                    $writeLineAry += $NaN
                    $writeLineAry += $NaN
                    $writeLineAry += $NaN
                    $writeLineAry += $NaN
                }
                $writeLineAry += $NaN
                [string] $writeLine = $writeLineAry -Join $Delimiter
                Write-Output $writeLine
                $mwAry += $splitLine[$datCol]
            }
            # add an array element at the specified number of lines
            # and output the moving avarage value
            if($mwCounter -eq $WindowSize){
                $mwAry += $splitLine[$datCol]
                [string] $writeLine = getWriteLine $readLine $mwAry
                Write-Output $writeLine
            }
            # after the specified number of lines,
            # the moving  avarage is output while
            # replacing the elements in the array
            if($mwCounter -gt $WindowSize){
                [string[]] $tmpAry = @()
                for ($j = 1; $j -lt $WindowSize; $j++){
                    $tmpAry += $mwAry[$j]
                }
                $tmpAry += $splitLine[$datCol]
                [string] $writeLine = getWriteLine $readLine $tmpAry
                Write-Output $writeLine
                $mwAry = $tmpAry
            }
        }
    }
    end{
        ## pass
    }
}
