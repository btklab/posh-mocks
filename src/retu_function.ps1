<#
.SYNOPSIS

retu - Count column number

半角スペース区切り入力の列数を出力。
同じ列数の場合は、重複を削除して列数を出力。
列数が変化するごとに列数を出力する。
空行はゼロを出力。
すべての行の列数が同じか否かを検知するのにつかう。


すべての列数が同じ場合、重複が削除され、
列数が1行だけ出力される。

"a".."z" | retu
1

列数が変化するごとに列数を出力する。
"a a","b b b","c c c","d d" | retu
2
3
2

-cスイッチですべての行に列数をくっつけて出力。
"a a","b b b","c c c","d d" | retu -c
2 a a
3 b b b
3 c c c
2 d d


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

.EXAMPLE
cat a.txt | retu -c
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

.EXAMPLE
cat a.txt | retu
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
        [string] $line = $_
        [string[]] $splitLine = $line -Split "$Delimiter"
        if($Count){
            $cnt = $splitLine.Count
            if($line -match '^$'){
                $cnt = 0
            }
            [string] $writeLine = [string] $cnt + [string] $Delimiter + [string] $line
            Write-Output $writeLine
        }else{
            $rowCounter++
            if($rowCounter -eq 1){
                # set first col num
                if($line -match '^$'){
                    $lastColNum = 0
                } else {
                    $lastColNum = $splitLine.Count
                }
            }else{
                # compare col num
                if($line -match '^$'){
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
