<#
.SYNOPSIS
    decil - Decile analysis (Divide records about 10 equal parts)

     Create a decil analysis table from the specified field.     

        decil [-Key <n>] [-Val <n>] [-Rank] [-NoHeader]

    Input:
        cat data.txt
            Customers Sales
            AC01 6340834
            AC02 6340834
            AC03 6340834
            ・・・
            U036 6158245
            U040 6500047
            U041 6751113

    Output:
        cat data.txt | decil | Format-Table

        Name  Seg Count          Sum       Mean Ratio Cumulative-Ratio
        ----  --- -----          ---       ---- ----- ----------------
        Sales D01    57 431538439.00 7570849.81  0.14             0.14
        Sales D02    57 384099747.00 6738592.05  0.12             0.26
        Sales D03    57 382266775.00 6706434.65  0.12             0.38
        Sales D04    56 374027341.00 6679059.66  0.12             0.49
        Sales D05    56 353450955.00 6311624.20  0.11             0.60
        Sales D06    56 309655714.00 5529566.32  0.10             0.70
        Sales D07    56 303489528.00 5419455.86  0.10             0.80
        Sales D08    56 302052324.00 5393791.50  0.09             0.89
        Sales D09    56 266710113.00 4762680.59  0.08             0.98
        Sales D10    56  76811269.00 1371629.80  0.02             1.00

    The records are divided into 10 equal parts evenly, but
    in the case of surplus, the number of records in the latter half
    is different from others.

    If there is no header, specify the -noHeader option.

    Input data is required two fields. (1:key, 2:value).
    The data in the first and second row is specified by default
    (-key 1 -Val 2).

        - The input data may not be sorted
        - Input data expects to be uniquely indexed
        - Note that if the index is duplicated, you will not be grouping

    Space separated input data required by default (-delimiter ' ')
      Divided characters can be changed with -delimiter options.
      Output is object type

    (input data example)
    Customers Sales
    AC01 6340834
    AC02 6340834
    AC03 6340834
    ・・・
    U036 6158245
    U040 6500047
    U041 6751113


    $ cat data.txt | decil

    ## ref
    https://hitorimarketing.net/tools/decile-analysis.html

.LINK
    decil, percentile, summary

.PARAMETER Rank
    Add the decil category to the input data.
    All lines are output without aggregation for each decil category.
    The output type is text, not an object.

.PARAMETER Quartile
    calculate the quartile

.PARAMETER Outlier
    calculate the quartile with outlier

.PARAMETER StandardDeviation
    calculate standard deviation (sample standard deviation)


.EXAMPLE
    cat data.txt
    Customers Sales
    AC01 6340834
    AC02 6340834
    AC03 6340834
    ・・・
    U036 6158245
    U040 6500047
    U041 6751113

    PS > cat data.txt | decil | Format-Table

    Name  Seg Count          Sum       Mean Ratio Cumulative-Ratio
    ----  --- -----          ---       ---- ----- ----------------
    Sales D01    57 431538439.00 7570849.81  0.14             0.14
    Sales D02    57 384099747.00 6738592.05  0.12             0.26
    Sales D03    57 382266775.00 6706434.65  0.12             0.38
    Sales D04    56 374027341.00 6679059.66  0.12             0.49
    Sales D05    56 353450955.00 6311624.20  0.11             0.60
    Sales D06    56 309655714.00 5529566.32  0.10             0.70
    Sales D07    56 303489528.00 5419455.86  0.10             0.80
    Sales D08    56 302052324.00 5393791.50  0.09             0.89
    Sales D09    56 266710113.00 4762680.59  0.08             0.98
    Sales D10    56  76811269.00 1371629.80  0.02             1.00

.EXAMPLE
    cat data.txt
    AC01 6340834
    AC02 6340834
    AC03 6340834
    ・・・
    U036 6158245
    U040 6500047
    U041 6751113

    PS > cat data.txt | decil -NoHeader | ft

    Name Seg Count          Sum       Mean Ratio Cumulative-Ratio
    ---- --- -----          ---       ---- ----- ----------------
    H2   D01    57 431538439.00 7570849.81  0.14             0.14
    H2   D02    57 384099747.00 6738592.05  0.12             0.26
    H2   D03    57 382266775.00 6706434.65  0.12             0.38
    H2   D04    56 374027341.00 6679059.66  0.12             0.49
    H2   D05    56 353450955.00 6311624.20  0.11             0.60
    H2   D06    56 309655714.00 5529566.32  0.10             0.70
    H2   D07    56 303489528.00 5419455.86  0.10             0.80
    H2   D08    56 302052324.00 5393791.50  0.09             0.89
    H2   D09    56 266710113.00 4762680.59  0.08             0.98
    H2   D10    56  76811269.00 1371629.80  0.02             1.00

    description
    =========================
    NoHeader input


.EXAMPLE
    cat data.txt
    Customers Salse
    AC01 6340834
    AC02 6340834
    AC03 6340834
    ・・・
    U036 6158245
    U040 6500047
    U041 6751113

    PS > cat .\data.txt | decil -Rank | head

    Seg Customers Sales
    D01 BZ30 9830001
    D01 CZ31 9600101
    D01 GZ96 9500965
    D01 TZ11 8998608
    D01 CZ35 8920822
    D01 EZ64 8691211
    D01 GZ87 8615511
    D01 FZ09 8614123
    D01 U022 8594501

    description
    =========================
    -Rank option

.EXAMPLE
    cat data.txt
    AC01 6340834
    AC02 6340834
    AC03 6340834
    ・・・
    U036 6158245
    U040 6500047
    U041 6751113

    PS > cat data.txt | decil -Rank | chead | ratio 3 | head

    D01 BZ30 9830001 0.0030872127736867039417159664
    D01 CZ31 9600101 0.0030150103174844539891268974
    D01 GZ96 9500965 0.0029838756385019996555041486
    D01 TZ11 8998608 0.0028261052631631841729778897
    D01 CZ35 8920822 0.0028016757709572328253828774
    D01 EZ64 8691211 0.0027295640781731753488107647
    D01 GZ87 8615511 0.0027057897156916167519817411
    D01 FZ09 8614123 0.0027053538000360764173397506
    D01 U022 8594501 0.0026991913094071049142092472
    D01 CZ84 8470022 0.0026600974009877927269611624

.EXAMPLE
    cat data.txt
    AC01 6340834
    AC02 6340834
    AC03 6340834
    ・・・
    U036 6158245
    U040 6500047
    U041 6751113

    PS > cat data.txt | self 1.1.2 2 | percentile -v2 -k 1 | ft

    key count          sum       mean      stdev        min       Qt25       Qt50       Qt75        max
    --- -----          ---       ----      -----        ---       ----       ----       ----        ---
    AC      7  44385838.00 6340834.00       0.00 6340834.00 6340834.00 6340834.00 6340834.00 6340834.00
    AS     12  76090008.00 6340834.00       0.00 6340834.00 6340834.00 6340834.00 6340834.00 6340834.00
    AT     35 189351680.00 5410048.00       0.00 5410048.00 5410048.00 5410048.00 5410048.00 5410048.00
    AX     19 102981539.00 5420081.00       0.00 5420081.00 5420081.00 5420081.00 5420081.00 5420081.00
    AY     39 211713450.00 5428550.00       0.00 5428550.00 5428550.00 5428550.00 5428550.00 5428550.00
    AZ      7  30449041.00 4349863.00 2314442.25 1010061.00 1058005.00 5320003.00 5540012.00 6700955.00
    BK      3  20250114.00 6750038.00       0.00 6750038.00 6750038.00 6750038.00 6750038.00 6750038.00
    BN      3  20102988.00 6700996.00       0.00 6700996.00 6700996.00 6700996.00 6700996.00 6700996.00
    BY      2  13400110.00 6700055.00       0.00 6700055.00 6700055.00 6700055.00 6700055.00 6700055.00
    BZ     35 206773879.00 5907825.11 1619162.40 1000011.00 5400037.00 6050994.00 6728078.00 9830001.00
    CZ     84 440046904.00 5238653.62 2053810.20  184302.00 4460063.00 5415069.00 6712544.00 9600101.00
    DZ     28 181111125.00 6468254.46  507418.13 5320011.00 6700054.00 6700877.50 6710218.00 7000941.00
    EZ     90 508248241.00 5647202.68 1751980.94 1030023.00 5325047.50 6615955.00 6710235.50 8691211.00
    FZ     84 437562510.00 5209077.50 2296385.17     541.00 5300041.00 6500022.00 6728014.00 8614123.00
    GZ     78 450971084.00 5781680.56 1760323.75  564005.00 5405041.50 6590425.00 6712534.00 9500965.00
    TZ      6  40733015.00 6788835.83 1495985.90 4608630.00 5359335.50 6611167.50 8396004.50 8998608.00
    U0     31 209930679.00 6771957.39  922852.95 3360977.00 6700811.00 6710244.00 6750023.00 8594501.00

#>
function decil {

    Param (
        [Parameter(Mandatory=$False, Position=0 )]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({$_ -ge 1})]
        [Alias('k')]
        [int] $Key = 1,

        [Parameter(Mandatory=$False, Position=1 )]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({$_ -ge 1})]
        [Alias('v')]
        [int] $Val = 2,

        [Parameter(Mandatory=$False, HelpMessage="delimiter")]
        [Alias('fs')]
        [string] $Delimiter = ' ',

        [Parameter(Mandatory=$False, HelpMessage="Rank")]
        [switch] $Rank,

        [Parameter(Mandatory=$False, HelpMessage="NaN String")]
        [string] $NaN = 'NaN',

        [Parameter(Mandatory=$False, HelpMessage="Skip Header")]
        [switch] $NoHeader,

        [Parameter(Mandatory=$False, HelpMessage="Quartile")]
        [switch] $Quartile = $True,

        [Parameter(Mandatory=$False, HelpMessage="Quartile Outlier")]
        [switch] $Outlier,

        [Parameter(Mandatory=$False, HelpMessage="StandardDeviation")]
        [switch] $StandardDeviation,

        [parameter(ValueFromPipeline=$true)]
        [string[]] $Text
    )

    begin
    {       
        ## init variables
        [int] $segment = 10
        [int] $rowCounter = 0
        [int] $nanCounter = 0
        [string[]] $listAry = @()
        $list = New-Object 'System.Collections.Generic.List[System.String]'
        
        ## data start row
        if($NoHeader){
            ## header off (no header)
            [int] $dataStartRow = 1
            [string] $headerName1 = 'H' + [string] $Key
            [string] $headerName2 = 'H' + [string] $Val
        }else{
            ## header on
            [int] $dataStartRow = 2
        }
    }

    process
    {
        $rowCounter++
        [string] $line = $_
        if ( $Delimiter -eq '' ){
            [string[]] $splitLine = $line.ToCharArray()
        } else {
            [string[]] $splitLine = $line.Split( $Delimiter )
        }
        
        ## tests ##################################
        ### raise error if detect empty row
        if($line -match '^$'){
            Write-Error "Detect empty row at $rowCounter" -ErrorAction Stop
        }
        ### raise error if defferent number of columns 
        if($rowCounter -eq 1){
            $retu = $splitLine.Count
        }else{
            $nowRetu = $splitLine.Count
            if($nowRetu -ne $retu){
                Write-Error "Detect defferent number of fields at $rowCounter" -ErrorAction Stop
            }
        }
        ##########################################
        
        if($rowCounter -lt $dataStartRow){
            ## get header names
            [string] $headerName1 = $splitLine[$Key - 1]
            [string] $headerName2 = $splitLine[$Val - 1]
        }else{
            [string] $newStr  = $splitLine[$Key - 1]
            [string] $newVal  = $splitLine[$Val - 1]
            [string] $newLine = $newStr + "$Delimiter" + $newVal
            
            if($newVal -eq "$NaN"){
                $nanCounter++
            }else{
                ## add element into array
                $list.Add($newLine)
                ## calc total
                if($rowCounter -eq $dataStartRow){
                    [double] $sumVal = [double] $newVal
                }else{
                    [double] $sumVal += [double] $newVal
                }
            }
        }
    } # end of process block

    end
    {
        ## Correct total nuber of lines
        if(!$NoHeader){
            $rowCounter--
        }
        
        ## data analysis
        $listAry = $list.ToArray()
        #$listAry | measure -Average -Minimum -Maximum -Sum
        $statCnt = ($listAry).Count
        $statSum = $sumVal
        
        ## Determine the range of decile division
        ## (how many lines to divide into)
        [int] $quotient = [math]::Floor($statCnt / $segment)
        [int] $remainder = $statCnt % $segment
        #[int]$decilRange = [math]::Ceiling($statCnt / $segment)
        #Write-Debug "$quotient, $remainder"
        
        ## Sort arrays in Descending order and
        ## giving decil classification
        [int] $rowCounter = 0
        [int] $endRowCounter = 0
        [int] $decilCounter = 1
        [string] $decilStrHead = 'D'
        [string] $decilStr = $decilStrHead
        $decilStr += [string]($decilCounter.ToString('00'))
        if($Rank){
            ## Output line with rank-label (decil division label)
            ## output is in text format
            $listAry `
                | Sort-Object { [double]($_.Split("$Delimiter")[1]) } -Descending `
                | ForEach-Object {
                    $rowCounter++
                    $endRowCounter++
                    
                    ## Add the number of rows by the remainders
                    if($decilCounter -le $remainder){
                        [int] $decilRange = $quotient + 1
                    }else{
                        [int] $decilRange = $quotient
                    }
                    
                    if($endRowCounter -eq 1){
                        ## output header
                        $writeLine = "Seg"
                        $writeLine += "$Delimiter" + "$headerName1"
                        $writeLine += "$Delimiter" + "$headerName2"
                        Write-Output $writeLine
                    }elseif($rowCounter % $decilRange -eq 1){
                        $decilCounter++
                        $decilStr = $decilStrHead
                        $decilStr += [string]($decilCounter.ToString('00'))
                        $rowCounter = 1
                    }
                    $writeLine = "$decilStr" + $Delimiter + [string]$_
                    Write-Output $writeLine
                }
        }else{
            ## Output total and cumulative ratio by grouping by decil division
            ## output object
            [int] $segmentCounter = 0
            [double] $segmentSumVal = 0
            [double] $sumRatio = 0
            $listAry `
                | Sort-Object { [double]($_.Split("$Delimiter")[1]) } -Descending `
                | ForEach-Object {
                    $rowCounter++
                    $endRowCounter++
                    $splitLine = "$_".Split( $Delimiter )
                    
                    ## Add the number of rows by the remainders
                    if($decilCounter -le $remainder){
                        [int]$decilRange = $quotient + 1
                    }else{
                        [int]$decilRange = $quotient
                    }
                    #Write-Output $decilRange
                    
                    if($endRowCounter -eq 1){
                        ## the 1st line initializes the data
                        $segmentCounter++
                        $segmentSumVal = [double]($splitLine[1])

                    }elseif( ($rowCounter % $decilRange -eq 0) -or ($endRowCounter -eq $statCnt) ){
                        ## Output at segment switching
                        $segmentCounter++
                        $segmentSumVal += [double]($splitLine[1])
                        [string] $decilStr = $decilStrHead
                        $decilStr += [string]($decilCounter.ToString('00'))
                        [double] $tmpRatio = $segmentSumVal / $statSum
                        $sumRatio += $tmpRatio
                        
                        ### output data
                        $outObject = [ordered]@{}
                        $outObject["Name"]    = [string] $headerName2
                        $outObject["Seg"]     = [string] $decilStr
                        $outObject["Count"]   = [int]($segmentCounter)
                        $outObject["Sum"]     = [double]($segmentSumVal)
                        $outObject["Mean"]    = [double]($segmentSumVal / $segmentCounter)
                        $outObject["Ratio"]   = [double]($tmpRatio)
                        $outObject["Cumulative-Ratio"] = $sumRatio
                        #$outObject["Count-NaN"]  = $nanCounter
                        [pscustomobject]$outObject
                        
                        ### init variables
                        $decilCounter++
                        [int] $segmentCounter = 0
                        [double] $segmentSumVal = 0
                        [int] $rowCounter = 0
                    }else{
                        ## ongoing segment
                        $segmentCounter++
                        $segmentSumVal += [double]($splitLine[1])
                    }
                }
        }
    } # end of end block
}
