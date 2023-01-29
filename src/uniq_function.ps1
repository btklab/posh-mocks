<#
.SYNOPSIS
    uniq - Report or omit repeated lines
    
    Equivalent to "sort -u" (Sort-Object -Unique [-CaseSensitive])
    Case insensitive.
    Pre-Sort required.

    Usage:
        cat data | uniq [-c|-d]
          -c: count duplicate
          -d: output only duplicated records

.EXAMPLE
    cat a.txt
    A 1 10
    B 1 10
    A 1 10
    C 1 10

    PS > cat a.txt | sort | uniq
    A 1 10
    B 1 10
    C 1 10

    PS > cat a.txt | sort -u
    A 1 10
    B 1 10
    C 1 10

    # if you don't pre-sort,
    # you get unexpected results.
    PS > cat a.txt | uniq
    A 1 10
    B 1 10
    A 1 10
    C 1 10

.EXAMPLE
    PS > cat a.txt | sort | uniq -c
    2 A 1 10
    1 B 1 10
    1 C 1 10

.EXAMPLE
    PS > cat a.txt | sort | uniq -d
    A 1 10

#>
function uniq {

    begin
    {
        [bool] $countFlag      = $False
        [bool] $duplicatedFlag = $False
        if( [string]($args[0]) -eq '-c' ){ $countFlag      = $True }
        if( [string]($args[0]) -eq '-d' ){ $duplicatedFlag = $True }
        [int] $readCounter = 0
        [int] $uniqCounter = 0
        [string] $lastKey = ''
        [string] $Delimiter = ' '
    }
    process
    {
        $readCounter++
        [string] $key = [string] $_
        if( $readCounter -gt 1 ){
            if( $countFlag ){
                if( "$key" -ne "$lastKey" ){
                    Write-Output ([string]$uniqCounter + $Delimiter + $lastKey)
                    [int]$uniqCounter = 0
                }
            } elseif ( $duplicatedFlag ){
                if( "$key" -ne "$lastKey" ){
                    if($uniqCounter -ge 2){
                        Write-Output $lastKey
                    }
                    [int]$uniqCounter = 0
                }
            } else {
                if( "$key" -ne "$lastKey" ){
                    Write-Output $lastKey
                }
            }
        }
        [string] $lastKey = $key;
        $uniqCounter++;
    }
    end
    {
        if($countFlag){
            Write-Output ([string]$uniqCounter + $Delimiter + $lastKey)
        } elseif ( $duplicatedFlag ){
            if( $uniqCounter -ge 2 ){
                Write-Output $lastKey
            }
        } else {
            Write-Output $lastKey
        }
    }
}
