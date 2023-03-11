<#
.SYNOPSIS
    retu - Count number of columns

    Count number of columns separated by space.

    Output the number of columns each time when
    it changes. If the number of columns is the
    same as the previous row, remove the duplicates.
    So this command is useful for detecting whether
    all rows have the same number of columns or not.

    Empty row output zero.

    PS > "a".."z" | retu
    1

    PS > "a a","b b b","c c c","d d" | retu
    2
    3
    2

    PS > "a a","b b b","c c c","d d" | retu -c
    2 a a
    3 b b b
    3 c c c
    2 d d

.LINK
    gyo, retu

.EXAMPLE
    10..20 | retu
    1

.EXAMPLE
    10..20 | retu -c
    1 10
    1 11
    1 12
    1 13
    1 14
    1 15
    1 16
    1 17
    1 18
    1 19
    1 20

.EXAMPLE
    cat a.txt
    2018 1
    2018 2 9
    2018 3
    2017 1
    2017 2
    2017 3
    2017 4
    2017 5 6
    2022 1
    2022 2

    PS > cat a.txt | retu -c
    2 2018 1
    3 2018 2 9
    2 2018 3
    2 2017 1
    2 2017 2
    2 2017 3
    2 2017 4
    3 2017 5 6
    2 2022 1
    2 2022 2

    PS > cat a.txt | retu
    2
    3
    2
    3
    2
#>
function retu {
    Param(
        [Parameter(Mandatory=$False)]
        [Alias('c')]
        [switch] $Count,

        [Parameter(Mandatory=$False)]
        [Alias('d')]
        [string] $Delimiter = ' ',

        [parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [string[]] $Text
    )

    begin
    {
        [int] $colNum     = 0
        [int] $lastColNum = 0
        [int] $rowCounter = 0
    }

    process
    {
        [string] $readLine = $_
        if ( $Delimiter -eq '' ){
            [string[]] $splitLine = $readLine.ToCharArray()
        } else {
            [string[]] $splitLine = $readLine.Split( $Delimiter )
        }
        if($Count){
            [int] $cnt = $splitLine.Count
            if($readLine -match '^$'){
                $cnt = 0
            }
            if ( $Delimiter -eq '' ){
                [string] $writeLine = [string] $cnt + " " + [string] $readLine
            } else {
                [string] $writeLine = [string] $cnt + [string] $Delimiter + [string] $readLine
            }
            Write-Output $writeLine
        }else{
            $rowCounter++
            if($rowCounter -eq 1){
                # set first col num
                if($readLine -match '^$'){
                    $lastColNum = 0
                } else {
                    $lastColNum = $splitLine.Count
                }
            }else{
                # compare col num
                if($readLine -match '^$'){
                    $colNum = 0
                } else {
                    $colNum = $splitLine.Count
                }
                # output if col-num changed
                if($colNum -ne $lastColNum){
                    Write-Output $lastColNum
                }
                $lastColNum = $colNum
            }
        }
    }

    end
    {
        if(-not $Count){
            Write-Output $lastColNum
        }
    }
}
