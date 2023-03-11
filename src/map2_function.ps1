<#
.SYNOPSIS
    map2 - Cross tabulation of long-type data

    Input data must be preprocessed to ensure unique keys
    and no header line.

    Usage:
        map2 -n <n>[,<m>]

        Means: Interpret the <n> columns from the left of the
        input data as vertical-key-fields (vkey), <m> columns
        from there as horizontal-key-fields (hkey), and the rest
        as values-fields.

        e.g. map2 -n 2,1 means:
          Cross tablate the 2 columns from the left as vertical-key,
          1 column as horizontal-key, and the rest as value.

        Missing values are filled with 0. (Completion characters
        can be changed with "-NaN <str/num>" option)
    
    Input data example1: (Case: vkey1, vkey2, hkey, value)
        cat data.txt

        location-A store-A target-A 1
        location-A store-B target-B 2
        location-A store-C target-C 3
        location-B store-A target-A 4
        location-B store-B target-B 5
        location-B store-C target-C 6
        location-C store-A target-A 7
        location-C store-B target-B 8
        location-C store-C target-C 9
    
    Output example1:
        cat data.txt | map2 -n 2,1 | keta

                 *       * target-A target-B target-C
        location-A store-A        1        0        0
        location-A store-B        0        2        0
        location-A store-C        0        0        3
        location-B store-A        4        0        0
        location-B store-B        0        5        0
        location-B store-C        0        0        6
        location-C store-A        7        0        0
        location-C store-B        0        8        0
        location-C store-C        0        0        9

    Input data example2: (Case: vkey, hkey, value1, value2)
        cat data.txt

        location-1 target-1 1 10
        location-1 target-2 2 20
        location-1 target-3 3 30
        location-2 target-1 4 40
        location-2 target-2 5 50
        location-2 target-3 6 60
        location-3 target-1 7 70
        location-3 target-2 8 80
        location-3 target-3 9 90
    
    Output example2: ("A".."Z" is given according to the number of value-columns)
        cat data.txt | map2 -n 1,1 | keta

                 * * target-1 target-2 target-3
        location-1 A        1        2        3
        location-1 B       10       20       30
        location-2 A        4        5        6
        location-2 B       40       50       60
        location-3 A        7        8        9
        location-3 B       70       80       90

        cat data.txt | map2 -n 1,1 -yarr | keta
                 * target-1 target-1 target-2 target-2 target-3 target-3
                 *        a        b        a        b        a        b
        location-1        1       10        2       20        3       30
        location-2        4       40        5       50        6       60
        location-3        7       70        8       80        9       90


    Inspired by Open-usp-Tukubai - GitHub
      - Url: https://github.com/usp-engineers-community/Open-usp-Tukubai
      - License: The MIT License (MIT): Copyright (C) 2011-2022 Universal Shell Programming Laboratory
      - Command: map


.EXAMPLE
    # Input data example1: (Case: vkey1, vkey2, hkey, value)

    cat data.txt
    loc-A store-A tar-A 1
    loc-A store-B tar-B 2
    loc-A store-C tar-C 3
    loc-B store-A tar-A 4
    loc-B store-B tar-B 5
    loc-B store-C tar-C 6
    loc-C store-A tar-A 7
    loc-C store-B tar-B 8
    loc-C store-C tar-C 9
    
    # Output:
    cat data.txt | map2 -n 2,1 | keta
        *       * tar-A tar-B tar-C
    loc-A store-A     1     0     0
    loc-A store-B     0     2     0
    loc-A store-C     0     0     3
    loc-B store-A     4     0     0
    loc-B store-B     0     5     0
    loc-B store-C     0     0     6
    loc-C store-A     7     0     0
    loc-C store-B     0     8     0
    loc-C store-C     0     0     9

.EXAMPLE
    # Input data example2: (Case: vkey, hkey, value1, value2)

    cat data.txt
    loc-1 tar-1 1 10
    loc-1 tar-2 2 20
    loc-1 tar-3 3 30
    loc-2 tar-1 4 40
    loc-2 tar-2 5 50
    loc-2 tar-3 6 60
    loc-3 tar-1 7 70
    loc-3 tar-2 8 80
    loc-3 tar-3 9 90

    # Output: ("A".."Z" is given according to the number of value-columns)

    cat data.txt | map2 -n 1,1 | keta

        * * tar-1 tar-2 tar-3
    loc-1 A     1     2     3
    loc-1 B    10    20    30
    loc-2 A     4     5     6
    loc-2 B    40    50    60
    loc-3 A     7     8     9
    loc-3 B    70    80    90

    cat data.txt | map2 -n 1,1 -yarr | keta
        * tar-1 tar-1 tar-2 tar-2 tar-3 tar-3
        *     a     b     a     b     a     b
    loc-1     1    10     2    20     3    30
    loc-2     4    40     5    50     6    60
    loc-3     7    70     8    80     9    90

#>
function map2 {
  Param (
    [Parameter( Position=0, Mandatory=$False,
     HelpMessage="key field")]
     [ValidateNotNullOrEmpty()]
    [Alias('n')]
    [int[]] $Num = @(1,1),

    [Parameter(Mandatory=$False)]
    [Alias('fs')]
    [string] $Delimiter = ' ',

    [Parameter(Mandatory=$False)]
    [Alias('ifs')]
    [string] $InputDelimiter,

    [Parameter(Mandatory=$False)]
    [Alias('ofs')]
    [string] $OutputDelimiter,

    [Parameter( Mandatory=$false)]
    [Alias('y')]
    [switch] $yarr,

    [Parameter( Mandatory=$false)]
    [string] $NaN = '0',

    [Parameter( Mandatory=$false)]
    [string] $UpperLeftMark = '*',

    [Parameter(
      ValueFromPipeline=$true)]
    [string[]] $Text
  )

  begin
  {
    ## test "-Num <n>,<m>" option
    ## if only <n> is specified, set <m> = 1
    if($Num.Count -eq 1){$Num += ,1}

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
        Write-Error "Could not set empty delimiter." -ErrorAction Stop
    }

    ## Get number of vertical and horizontal key fields
    [int] $tateKeyNum = $Num[0]
    [int] $yokoKeyNum = $Num[1]
    [int] $tateYokoKeycolNum = $tateKeyNum + $yokoKeyNum
    [string[]]$tateKeyAry     = @()
    [string[]]$yokoKeyAry     = @()
    [string[]]$tateYokoKeyAry = @()
    [string[]]$dataAry        = @()

    $tateKeyList     = New-Object 'System.Collections.Generic.List[System.String]'
    $yokoKeyList     = New-Object 'System.Collections.Generic.List[System.String]'
    $tateYokoKeyList = New-Object 'System.Collections.Generic.List[System.String]'
    $dataList        = New-Object 'System.Collections.Generic.List[System.String]'

    ## init var
    [int] $RowCounter = 0
    [int] $MaxDataColNum = 1
    [string] $writeLine = ''

    ## column names when there are multiple value fields
    ## (26 items from A to Z)
    [string[]] $tateDataColStr = @("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")
    [string[]] $yokoDataColStr = @("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
  }

  process
  {
    ## 1st Pass: get vertical and horizontal key fields
    $RowCounter++
    [string] $readLine = [string] $_
    [string[]] $splitLine = $readLine.Split( $iDelim )

    ## count number of fields
    ## error if all row fields are not the same
    if($RowCounter -eq 1){
      $allColCount = @($splitLine).Count
    }else{
      if($allColCount -ne @($splitLine).Count){
        Write-Error "$RowCounter : The number of columns is uneven." -ErrorAction Stop
      }
    }

    ## test number of vertical and horizontal fields
    if(@($splitLine).Count -le $tateYokoKeycolNum){
      Write-Error "$RowCounter : The number of columns is uneven." -ErrorAction Stop
    }

    ## get maximum number of fields
    $dataColNum = @($splitLine).Count - $tateYokoKeycolNum
    if($dataColNum -gt $MaxDataColNum){
      $MaxDataColNum = $dataColNum
    }

    if($MaxDataColNum -gt $tateDataColStr.Count){
      Write-Error "$RowCounter : The number of columns is uneven." -ErrorAction Stop
    }

    ## set vertical and horizontal keys
    [int] $tmpStartNum = 0
    [int] $tmpEndNum   = $tateKeyNum - 1
    [string]$tateKeyStr = @($splitLine)[$tmpStartNum..$tmpEndNum] -Join $oDelim
    $tateKeyList.Add($tateKeyStr)

    [int] $tmpStartNum = $tateKeyNum
    [int] $tmpEndNum   = $tateKeyNum + $yokoKeyNum - 1
    [string]$yokoKeyStr = @($splitLine)[$tmpStartNum..$tmpEndNum] -Join $oDelim
    $yokoKeyList.Add($yokoKeyStr)

    [int] $tmpStartNum = $tateKeyNum + $yokoKeyNum
    [int] $tmpEndNum   = $tateKeyNum + $yokoKeyNum + $dataColNum - 1
    [string]$dataStr = @($splitLine)[$tmpStartNum..$tmpEndNum] -Join $oDelim
    $dataList.Add($dataStr)

    [int] $tmpStartNum = 0
    [int] $tmpEndNum   = $tateKeyNum + $yokoKeyNum - 1
    [string]$tateYokoKeyStr = @($splitLine)[$tmpStartNum..$tmpEndNum] -Join $oDelim
    $tateYokoKeyList.Add($tateYokoKeyStr)
  }

  end
  {
    ## set array
    [string[]] $tateKeyAry     = $tateKeyList.ToArray()
    [string[]] $yokoKeyAry     = $yokoKeyList.ToArray()
    [string[]] $tateYokoKeyAry = $tateYokoKeyList.ToArray()
    [string[]] $dataAry        = $dataList.ToArray()

    ## get uniq keys
    [string[]] $uniqTateKey = @()
    [string[]] $uniqTateKey = $tateKeyAry | Sort-Object {[string]$_} -Unique

    [string[]] $uniqYokoKey = @()
    [string[]] $uniqYokoKey = $yokoKeyAry | Sort-Object {[string]$_} -Unique

    ## output header part
    [string] $tateKeyHeader = $UpperLeftMark
    [string] $tateKeyHeader += "$($oDelim + '*')" * ($tateKeyNum - 1)

    if($MaxDataColNum -gt 1){
      if( $yarr ){
        # pass
      }else{
        [string] $tateKeyHeader += $oDelim + '*'
      }
    }

    ### main header
    if( $yarr ){
      # yarr
      for($o = 0; $o -lt $yokoKeyNum; $o++){
        for($n = 0; $n -lt @($uniqYokoKey).Count; $n++){
          [string[]] $tmpYokoAry = (@($uniqYokoKey)[$n]).Split( $oDelim )
          if($n -eq 0){
            [string] $tmpHeader = $tateKeyHeader
            [string] $tmpHeader += ($oDelim + @($tmpYokoAry)[$o]) * $MaxDataColNum
          }else{
            [string] $tmpHeader += ($oDelim + @($tmpYokoAry)[$o]) * $MaxDataColNum
          }
        }
        Write-Output $tmpHeader
      }
      [string] $tmpYarrHeader = ''
      for($p = 0; $p -lt $MaxDataColNum; $p++){
        [string] $tmpYarrHeader += $oDelim + @($yokoDataColStr)[$p]
      }
      [string] $tmpYarrHeader *= @($uniqYokoKey).Count
      [string] $tmpYarrHeader = $tateKeyHeader + $tmpYarrHeader
      Write-Output $tmpYarrHeader
    }else{
      # not -yarr
      for($o = 0; $o -lt $yokoKeyNum; $o++){
        for($n = 0; $n -lt @($uniqYokoKey).Count; $n++){
          [string[]] $tmpYokoAry = (@($uniqYokoKey)[$n]).Split( $oDelim )
          if($n -eq 0){
            [string] $tmpHeader = $tateKeyHeader
            [string] $tmpHeader += $oDelim + @($tmpYokoAry)[$o]
          }else{
            [string] $tmpHeader += $oDelim + @($tmpYokoAry)[$o]
          }
        }
        Write-Output $tmpHeader
      }
    }

    ## output value part
    $list = New-Object 'System.Collections.Generic.List[System.String]'
    for($i = 0; $i -lt @($uniqTateKey).Count; $i++){
      for($j = 0; $j -lt @($uniqYokoKey).Count; $j++){
        #$uniqTateKey[$i]
        [string] $tmpKeyStr = [string]@($uniqTateKey)[$i] + [string]$oDelim + [string]@($uniqYokoKey)[$j]
        $list.Add($tmpKeyStr)
      }
    }
    [string[]] $OutputTateYokoKey = @()
    [string[]] $OutputTateYokoKey = $list.ToArray()

    ## is exist output key?
    [string[]]$OutputVal = @()
    [int] $tmpRowCounter = 0
    [int] $hitCounter = 0
    [int] $outputColCounter = 0
    [int] $outputColCounterLimit = @($uniqYokoKey).Count

    ## first, enumerate all combination of
    ## vertical and horizontal keys
    for($k = 0; $k -lt @($OutputTateYokoKey).Count; $k++){
      [string] $outputKey = [string]@($OutputTateYokoKey)[$k]

      ### is there a corresponding data line for v/h key combinations
      ### True if key exists
      [bool] $keyFindFlag = $False

      for($m = $tmpRowCounter; $m -lt $RowCounter; $m++){
        #$tateYokoKeyAry.GetType().Name
        [string] $tmpTateYokoKey = [string]@($tateYokoKeyAry)[$m]

        #### corresponding key combination found
        if([string]$tmpTateYokoKey -eq [string]$outputKey){
          [bool] $keyFindFlag = $True
          $tmpRowCounter++
          [int] $hitCounter = $m
          Break
        }

        if([string]$tmpTateYokoKey -gt [string]$outputKey){
          [bool] $keyFindFlag = $False
          Break
        }
      }

      ## $k : output key counter
      ## $hitCounter : ipnut key counter
      ## $MaxDataColNum : number of value field conter

      ### output value part
      $outputColCounter++

      if( $yarr ){
        ### output vertical key
        [string] $tmpHeader = [string]@($tateKeyAry)[$hitCounter] -Join $oDelim

        ### create value part
        if($keyFindFlag){
          ### exist key combination
          [string] $writeLine += $oDelim + @($dataAry)[$hitCounter]
          [bool] $keyFindFlag = $False
        }else{
          ### not exist key combination
          [string] $writeLine += ($oDelim + $NaN) * $MaxDataColNum
        }

        ### output value part
        if($outputColCounter -eq $outputColCounterLimit){
          [string] $writeLine = $tmpHeader + $writeLine
          Write-Output $writeLine
          [string] $writeLine = ''
          [int] $outputColCounter = 0
        }
      }else{
        ## $tateDataColStr: A-Z string array for multiple value fields

        ### outpput vertical key
        [string] $tmpHeader = [string]@($tateKeyAry)[$hitCounter] -Join $oDelim

        ### create value part
        if($keyFindFlag){
          ### exist key combination
          [string] $writeLine += $oDelim + @($dataAry)[$hitCounter]
        }else{
          ### not exist key combination
          [string] $writeLine += ($oDelim + $NaN) * $MaxDataColNum
        }

        ### output value part
        if($outputColCounter -eq $outputColCounterLimit){

          if($MaxDataColNum -eq 1){
            #### if there is only 1 value field
            [string] $writeLine = $tmpHeader + $writeLine
            Write-Output $writeLine
          }else{
            #### if there is multiple value fields
            [string] $tmpWriteLine = ''
            [string[]] $SplitWriteLine = $writeLine.Split( $oDelim )
            #$SplitWriteLine

            #### since the data array is in one column,
            #### separate line are output for each horizontal key
            for($i = 0; $i -lt $dataColNum; $i++){
              for($j = $i; $j -lt $dataColNum * @($uniqYokoKey).Count; $j += $dataColNum ){
                [string] $tmpWriteLine += $oDelim + @($SplitWriteLine)[$j+1]
              }
              [string] $writeLine = [string]$tmpHeader + $oDelim + @($tateDataColStr)[$i] + [string]$tmpWriteLine
              Write-Output $writeLine
              [string] $writeLine = ''
              [string] $tmpWriteLine = ''
            }
          }
          [int] $outputColCounter = 0
          [string] $writeLine = ''
          [bool] $keyFindFlag = $False
        }
      }
    }
  }
}
