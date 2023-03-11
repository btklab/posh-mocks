<#
.SYNOPSIS
    summary - Calculate the basic statistics of a specified field

    Default, Calculate the quartile,
    Optional calculate the quartile with outlier,
    and caluculate the standard deviation

    The median of quartile is exclusive calc.
    The outlier of quartile is (Qt1st -IQR*1.5) or below,
    (Qt3rd + IQR*1.5) or higher.
    The standard deviation is divided by n-1
    (specimen standard deviation).

    Example:
        cat iris.csv | summary 1 -d ","

            Name        : sepal_length
            Count       : 150
            Mean        : 5.84333333333333
            Min         : 4.3
            Qt25%       : 5.1
            Qt50%       : 5.8
            Qt75%       : 6.4
            Max         : 7.9
            IQR         : 1.3
            IQD         : 0.65
            Sum         : 876.5
            Count-NaN   : 0
            Count-Total : 150

.LINK
    decil, percentile, summary

.PARAMETER Quartile
    calculate the quartile

.PARAMETER Outlier
    calculate the quartile with outlier

.PARAMETER StandardDeviation
    calculate standard deviation (sample standard deviation)

.EXAMPLE
    cat iris.csv | summary 1 -d ","

    Name        : sepal_length
    Count       : 150
    Mean        : 5.84333333333333
    Min         : 4.3
    Qt25%       : 5.1
    Qt50%       : 5.8
    Qt75%       : 6.4
    Max         : 7.9
    IQR         : 1.3
    IQD         : 0.65
    Sum         : 876.5
    Count-NaN   : 0
    Count-Total : 150

.EXAMPLE
    1..4 | %{ cat iris.csv | summary $_ -d "," } | ft

    Name         Count Mean  Min Qt25% Qt50% Qt75%  Max  IQR  IQD
    ----         ----- ----  --- ----- ----- -----  ---  ---  ---
    sepal_length   150 5.84 4.30  5.10  5.80  6.40 7.90 1.30 0.65
    sepal_width    150 3.06 2.00  2.80  3.00  3.30 4.40 0.50 0.25
    petal_length   150 3.76 1.00  1.60  4.35  5.10 6.90 3.50 1.75
    petal_width    150 1.20 0.10  0.30  1.30  1.80 2.50 1.50 0.75

#>
function summary{

  Param (
    [Parameter(
     Mandatory=$False,
     Position=0,
     HelpMessage="column number")]
    [int] $Num = 1,

    [Parameter(
     Mandatory=$False,
     HelpMessage="delimiter")]
    [string] $Delimiter = ' ',

    [Parameter(
     Mandatory=$False,
     HelpMessage="NaN String")]
    [string] $NaN = 'NaN',

    [Parameter(
     Mandatory=$False,
     HelpMessage="Skip Header")]
    [switch] $noHeader,

    [Parameter(
     Mandatory=$False,
     HelpMessage="Quartile")]
    [switch] $Quartile = $True,

    [Parameter(
     Mandatory=$False,
     HelpMessage="Quartile Outlier")]
    [switch] $Outlier,

    [Parameter(
     Mandatory=$False,
     HelpMessage="StandardDeviation")]
    [switch] $StandardDeviation,

    [parameter(
      Mandatory=$False,
      ValueFromPipeline=$true)]
    [string[]] $Text
  )

  begin
  {
      ## init variables
      [int] $rowCounter = 0
      [int] $nanCounter = 0
      [string[]]$listAry = @()
      $list = New-Object 'System.Collections.Generic.List[System.String]'
      if($noHeader){
          $dataStartRow = 1
          $headerName = 'H' + [string]$Num
      }else{
          $dataStartRow = 2
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
    if($line -match '^$'){
        Write-Error "Detect empty row at $rowCounter" -ErrorAction Stop
    }
    if($rowCounter -eq 1){
        $retu = $splitLine.Count
    }else{
        $nowRetu = $splitLine.Count
        if($nowRetu -ne $retu){
            Write-Error "Detect defferent fields at $rowCounter" -ErrorAction Stop
        }
    }
    ##########################################

    if($rowCounter -lt $dataStartRow){
        ## get header name
        $headerName = [string]($splitLine[$Num-1])
    }else{
        [string]$newVal = $splitLine[$Num-1]
        if($newVal -eq "$NaN"){
            $nanCounter++
        }else{
            $list.Add($newVal)
    
            ## get max and min
            if($rowCounter -eq $dataStartRow){
                [double]$maxVal = [double]$newVal
                [double]$minVal = [double]$newVal
                [double]$sumVal = [double]$newVal
            }else{
                [double]$sumVal += [double]$newVal
                if([double]$newVal -gt [double]$maxVal){
                    [double]$maxVal = [double]$newVal
                }
                if([double]$newVal -lt [double]$minVal){
                    [double]$minVal = [double]$newVal
                }
            }
        }
    }
  } # end of process block

  end
  {
    ## fix row counter
    if(!$noHeader){
        $rowCounter--
    }

    ## data analysis
    $listAry = $list.ToArray()
    #Write-Output "$headerName $($listAry)"

    $statCnt = ($listAry).Count
    $statMin = $minVal
    $statMax = $maxVal
    $statSum = $sumVal
    $statMean = $statSum / $statCnt
    $statQt25 = "None"
    $statQt50 = "None"
    $statQt75 = "None"
    $statIQR = "None"
    $statIQD = "None"
    $statStd = "None"
    $statVar = "None"
    #$listAry | measure -Average -Minimum -Maximum -Sum

    ## calc Quartile
    if($Quartile -and (!$StandardDeviation) ){
        [string[]]$qtListAry = @()
        $qtList = New-Object 'System.Collections.Generic.List[System.String]'

        $listAry `
            | Sort-Object    { [double]$_ } `
            | Foreach-Object { $qtList.Add($_) }

        $qtListAry = $qtList.ToArray()
        $qtListCount = $qtList.Count

        ## test
        if($qtListCount -le 3){
            Write-Error "The number of valid data is less than 3." -ErrorAction Stop
        }

        if($qtListCount % 2 -eq 1){
            ## If the number of valid counts is odd
            ### Qt50%
            [int]$getIndexQt50 = ($qtListCount - 1) / 2
            [double]$statQt50 = $qtListAry[$getIndexQt50]
            if($getIndexQt50 % 2 -eq 1){
                ### odd to odd pattern
                #### Qt25%
                [int]$getIndexQt25 = [math]::Floor($getIndexQt50 / 2)
                [double]$statQt25 = $qtListAry[$getIndexQt25]
                #### Qt75%
                [int]$getIndexQt75 = [math]::Ceiling($getIndexQt50 / 2)
                [int]$getIndexQt75 += $getIndexQt50
                [double]$statQt75 = $qtListAry[$getIndexQt75]
            }else{
                ### odd to even pattern
                [int]$tmpQuotient = ($qtListCount - 1) / 2
                #### Qt25%
                [int]$getIndex1 = $tmpQuotient / 2
                [int]$getIndex2 = $getIndex1 - 1
                [double]$statQt25 = ([double]($qtListAry[$getIndex1]) + [double]($qtListAry[$getIndex2])) / 2
                #### Qt75%
                [int]$getIndex1 = $tmpQuotient / 2 + $tmpQuotient
                [int]$getIndex2 = $getIndex1 + 1
                [double]$statQt75 = ([double]($qtListAry[$getIndex1]) + [double]($qtListAry[$getIndex2])) / 2
            }
            ### quartile range
            [double]$statIQR = $statQt75 - $statQt25
            ### quartile deviation
            [double]$statIQD = $statIQR / 2
        }else{
            ## If the number of valid counts is even
            ### Qt50%
            [int]$getIndex1 = $qtListCount / 2
            [int]$getIndex2 = $qtListCount / 2 - 1
            [double]$statQt50 = ( [double]($qtListAry[($getIndex1)]) + [double]($qtListAry[($getIndex2)]) ) / 2
            if( ($qtListCount / 2) % 2 -eq 1){
                ### even to odd pattern
                #### Qt25%
                [int]$getIndex1 = [math]::Floor($qtListCount / 2 / 2)
                [double]$statQt25 = $qtListAry[$getIndex1]
                #### Qt75%
                [int]$getIndex1 += $qtListCount / 2
                [double]$statQt75 = $qtListAry[$getIndex1]
            }else{
                ### even to even pattern
                [int]$tmpQuotient = $qtListCount / 2
                #### Qt25%
                [int]$getIndex1 = $tmpQuotient / 2
                [int]$getIndex2 = $getIndex1 - 1
                [double]$statQt25 = ([double]($qtListAry[$getIndex1]) + [double]($qtListAry[$getIndex2])) / 2
                #### Qt75%
                [int]$getIndex1 = $tmpQuotient / 2 + $tmpQuotient
                [int]$getIndex2 = $getIndex1 - 1
                [double]$statQt75 = ([double]($qtListAry[$getIndex1]) + [double]($qtListAry[$getIndex2])) / 2
            }
            ### quartile range
            [double]$statIQR = $statQt75 - $statQt25

            ### quartile deviation
            [double]$statIQD = $statIQR / 2
        }

        ## output data
        if(!($Outlier)){
            ## Quartiles without considering outliers
            $outObject = [ordered]@{}
            $outObject["Name"]  = $headerName
            $outObject["Count"] = $statCnt
            $outObject["Mean"] = $statMean
            $outObject["Min"] = $statMin
            $outObject["Qt25%"] = $statQt25
            $outObject["Qt50%"] = $statQt50
            $outObject["Qt75%"] = $statQt75
            $outObject["Max"] = $statMax
            $outObject["IQR"] = $statIQR
            $outObject["IQD"] = $statIQD
            $outObject["Sum"] = $sumVal
            $outObject["Count-NaN"]   = $nanCounter
            $outObject["Count-Total"] = $rowCounter
            [pscustomobject]$outObject
        }else{
            ## Quartiles considering outliers
            ### Lower outlier and maximum value detection
            [double]$statIQR_min = $statQt25 - ($statIQR * 1.5)
            $minOutlierAry = @()
            for($i = 0; $i -lt $qtListCount; $i++){
                if([double]$qtListAry[$i] -le $statIQR_min){
                    ## if it is an outlier, add to the outlier array
                    $minOutlierAry += $qtListAry[$i]
                }else{
                    ## if not an outlier, update the maximum value and exit loop
                    $statMin = $qtListAry[$i]
                    break
                }
            }

            ### Upper outlier and maximum value detection
            [double]$statIQR_max = $statQt75 + ($statIQR * 1.5)
            $maxOutlierAry = @()
            for($i = $qtListCount - 1; $i -ge 0; $i--){
                if([double]$qtListAry[$i] -ge $statIQR_max){
                    ## if it is an outlier, add to the outlier array
                    $maxOutlierAry += $qtListAry[$i]
                }else{
                    ## if not an outlier, update the maximum value and exit loop
                    $statMax = $qtListAry[$i]
                    break
                }
            }
            #Write-Output $maxOutlierAry

            $countOutlier = $minOutlierAry.Count + $maxOutlierAry.Count
            if($minOutlierAry.Count -eq 0){
                $minOutlierAry = "None"
            }
            if($maxOutlierAry.Count -eq 0){
                $maxOutlierAry = "None"
            }
            
            ### Output
            $outObject = [ordered]@{}
            $outObject["Name"]  = [string] $headerName
            $outObject["Count"] = [int] $statCnt
            $outObject["Count-Outlier"] = [int] $countOutlier
            $outObject["Mean"]          = [double] $statMean
            $outObject["Outlier-Min"]   = [double] $minOutlierAry
            $outObject["Min"]           = [double] $statMin
            $outObject["Qt25%"]         = [double] $statQt25
            $outObject["Qt50%"]         = [double] $statQt50
            $outObject["Qt75%"]         = [double] $statQt75
            $outObject["Max"]           = [double] $statMax
            $outObject["Outlier-Max"]   = [double] $maxOutlierAry
            $outObject["IQR"]           = [double] $statIQR
            $outObject["Sum"]           = [double] $sumVal
            $outObject["Count-NaN"]   = [int] $nanCounter
            $outObject["Count-Total"] = [int] $rowCounter
            [pscustomobject]$outObject
        }
    }

    ## calc standard deviation
    if($StandardDeviation){
        $stdNum = $statCnt - 1 #n-1
        $stdMean = $statMean
        $stdVal = 0
        ## calculate the variance
        $listAry `
            | Foreach-Object { $stdVal += [math]::Pow([double]($_) - $stdMean, 2) }
        
        [double] $statVar = $stdVal / $stdNum
        [double] $statStd = [math]::Sqrt($statVar)

        ## output data
        $outObject = [ordered]@{}
        $outObject["Name"]  = [string] $headerName
        $outObject["Count"] = [int] $statCnt
        $outObject["Mean"]  = [double] $statMean
        $outObject["Min"]   = [double] $statMin
        $outObject["Max"]   = [double] $statMax
        $outObject["Var"]   = [double] $statVar
        $outObject["Std"]   = [double] $statStd
        $outObject["Sum"]   = [double] $sumVal
        $outObject["Count-NaN"]   = [int] $nanCounter
        $outObject["Count-Total"] = [int] $rowCounter
        [pscustomobject]$outObject
    }


  } # end of end block

}
