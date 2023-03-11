<#
.SYNOPSIS
    sm2 - sum up

    Calculate the total of the specified column from the input
    separated by space.
    
        sm2 [+count] <k1> <k2> <s1> <s2>
        +count: Output the total number of rows in the
                leftmost column.

    Consider columns <k1> to <k2> as keys, and
    sum <s1> to <s2> column by column. 

    If zero is specified for key such as sm2 0 0 2 3,
    all rows from 2nd column to 3rd column are summed.

.EXAMPLE
    "A 1 10","B 1 10","A 1 10","C 1 10"
    A 1 10
    B 1 10
    A 1 10
    C 1 10
    
    # Sort by key column before connecting pipeline to sm2 command
    "A 1 10","B 1 10","A 1 10","C 1 10" | sort | sm2 1 2 3 3
    A 1 20
    B 1 10
    C 1 10
    
    # Result if you forget to sort
    "A 1 10","B 1 10","A 1 10","C 1 10" | sm2 1 2 3 3
    A 1 10
    B 1 10
    A 1 10
    C 1 10

.EXAMPLE
    "A 1 10","B 1 10","A 1 10","C 1 10"
    A 1 10
    B 1 10
    A 1 10
    C 1 10

    # +count option
    "A 1 10","B 1 10","A 1 10","C 1 10" | sort | sm2 +count 1 2 3 3
    2 A 1 20
    1 B 1 10
    1 C 1 10

.EXAMPLE
    "A 1 10","B 1 10","A 1 10","C 1 10"
    A 1 10
    B 1 10
    A 1 10
    C 1 10

    # calculator mode
    "A 1 10","B 1 10","A 1 10","C 1 10" | sm2 0 0 2 2
    4

.EXAMPLE
    # calc average with sm2 and lcalc command

    ## input
    "A 1 10","B 1 10","A 1 10","C 1 10"
    A 1 10
    B 1 10
    A 1 10
    C 1 10

    ## sum up
    "A 1 10","B 1 10","A 1 10","C 1 10" | sort | sm2 +count 1 2 3 3
    2 A 1 20
    1 B 1 10
    1 C 1 10

    ## calc average
    "A 1 10","B 1 10","A 1 10","C 1 10" | sort | sm2 +count 1 2 3 3 | lcalc '$0;$NF/$1'
    2 A 1 20 10
    1 B 1 10 10
    1 C 1 10 10

#>
function sm2 {

    begin
    {
        # parse opt
        [bool] $countFlag   = $False
        [bool] $dentakuFlag = $False
        if( [string]($args[0]) -eq '+count' ){
            if( $args.Count -lt 5 ){
                Write-Error "Insufficient args." -ErrorAction Stop
            }else{
                $countFlag = $True
                $k1 = [int]($args[1]) - 1
                $k2 = [int]($args[2]) - 1
                $s1 = [int]($args[3]) - 1
                $s2 = [int]($args[4]) - 1
            }
        }else{
            if($args.Count -lt 4){
                Write-Error "Insufficient args." -ErrorAction Stop
            }else{
                $k1 = [int]($args[0]) - 1
                $k2 = [int]($args[1]) - 1
                $s1 = [int]($args[2]) - 1
                $s2 = [int]($args[3]) - 1
            }
        }
        if( ($k1 -lt 0) -or ($k2 -lt 0) ){
            $dentakuFlag = $True
        }
        # init var
        # row counter
        [int] $readRow = 0
        # key numner counter
        [int] $keyCount = 0
        # dictionary
        $sumHash     = @{}
        $lastSumHash = @{}
        [bool] $skipSubKeyFlag = $False
        # etc
        [int] $rowCounter = 0
        [int] $keyCount   = 0
        [string] $writeLine = ''
        [string] $writeKey  = ''
        [string] $writeVal  = ''
        [string] $lastkey   = ''
        [string] $Delimiter = ' '
    }

    process
    {
        # calculator mode
        if($dentakuFlag){
            if ( $Delimiter -eq '' ){
                [string[]] $splitLine = "$_".ToCharArray()
            } else {
                [string[]] $splitLine = "$_".Split( $Delimiter )
            }
            $rowCounter++
            # create values dictionary
            for($i = $s1; $i -le $s2; $i++){
                $sumHash["$i"] += [decimal]($splitLine[$i])
            }
        }else{
        # sum up mode per key
            $readRow++
            if ( $Delimiter -eq '' ){
                [string[]] $splitLine = "$_".ToCharArray()
            } else {
                [string[]] $splitLine = "$_".Split( $Delimiter )
            }

            # create key
            [string] $key = ''
            for($i = $k1; $i -le $k2; $i++){
                $key += ' ' + [string]($splitLine[$i])
            }
            $key = $key.Trim()

            # subtotal output and count reset
            # when key changes
            if(($key -ne $lastkey) -and ($readRow -gt 1)){
                [string] $writeKey = $lastkey
                [string] $writeVal = ''
                for($i = $s1; $i -le $s2; $i++){
                    $writeVal += $Delimiter + [string]($lastSumHash["$i"])
                    $sumHash["$i"] = 0
                }
                [string] $writeLine = [string]$writeKey + [string]$writeVal
                if($countFlag){
                    [string] $writeLine = [string]$keyCount + $Delimiter + $writeLine
                    Write-Output "$writeLine"
                }else{
                    Write-Output "$writeLine"
                }
                [int] $keyCount = 0
                [string] $writeLine = ''
            }

            # sum up values per column
            for($i = $s1; $i -le $s2; $i++){
                $sumHash["$i"] += [decimal]($splitLine[$i])
                $lastSumHash["$i"] = $sumHash["$i"]
            }
            [string] $lastkey = $key

            # count up key number
            $keyCount += 1
        }
    } # end of process block

    end
    {

        # calcurator mode
        if($dentakuFlag){
            [string] $writeVal =[string]$sumHash["$s1"]
            for($i = $s1 + 1; $i -le $s2; $i++){
                [string] $writeVal += $Delimiter + [string]($sumHash["$i"])
            }
            [string] $writeLine = $writeVal
            if($countFlag){
                $writeLine = [string]$rowCounter + $Delimiter + $writeLine
                Write-Output "$writeLine"
            }else{
                Write-Output "$writeLine"
            }
        }else{
            # sum up mode per key
            [string] $writeKey = $lastkey
            [string] $writeVal = ''
            for($i = $s1; $i -le $s2; $i++){
                [string] $writeVal += $Delimiter + [string]($lastSumHash["$i"])
            }
            [string] $writeLine = [string]$writeKey + [string]$writeVal
            if($countFlag){
                [string] $writeLine = [string]$keyCount + $Delimiter + $writeLine
                Write-Output "$writeLine"
            }else{
                Write-Output "$writeLine"
            }
        }
    }
}
