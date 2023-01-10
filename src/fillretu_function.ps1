<#
.SYNOPSIS

fillretu -- 全レコードの列数を最大列数にそろえる

標準入力のみ受け付け。
欠損セルに埋められる文字列はデフォルトで"_"。
-NaN <str>で変更可能。空行も-NaN文字列で置換される
-SkipBlankで空行をスキップ

yarrなどで生成した列数不定の入力の整形に向く。

    cat data | yarr -num 1 | fillretu | tateyoko

入力を2pass（2度読み込む）
1passで全行の列数をカウント、
2passで列数そろえ。

-Max <int>で列数を指定すると
1passで処理が終了するので、少し速度が向上し、
またメモリに全行を展開しない。
最大列数以下の列数を指定するとエラーで終了。



関連: tateyoko, yarr


.DESCRIPTION
-

.PARAMETER NaN
欠損セルに埋める文字列を指定する
デフォルトで「_」

.PARAMETER Delimiter
入力データの区切り文字を指定する
デフォルトで半角スペース

.EXAMPLE
cat a.md
2018 3
2018 3
2018 3
2017 1
2017 1
2017 1
2017 1
2017 1
2022 5
2022 5

$ cat a.md | yarr num=1
2018 3 3 3
2017 1 1 1 1 1
2022 5 5

$ cat a.md | yarr num=1 | fillretu
2018 3 3 3 _ _
2017 1 1 1 1 1
2022 5 5 _ _ _

$ cat a.md | yarr num=1 | fillretu | tateyoko
2018 2017 2022
   3    1    5
   3    1    5
   3    1    _
   _    1    _
   _    1    _

#>
function fillretu {
    Param (
        [Parameter(Mandatory=$False)]
        [string] $NaN = '_',

        [Parameter(Mandatory=$False)]
        [int] $Max,

        [Parameter(Mandatory=$False)]
        [switch] $SkipBlank,

        [Parameter(Mandatory=$False)]
        [ValidateSet( ' ', ',', "\t")]
        [Alias('d')]
        [string] $Delimiter = ' ',

        [parameter(Mandatory=$False,
            ValueFromPipeline=$True)]
        [string[]] $Text
    )

    begin {
        ## init var
        [int]$maxCol = 0
        if( -not $Max){
            [string[]]$listAry = @()
            $listObj = New-Object 'System.Collections.Generic.List[System.String]'
        }
        ## pricate functions
        function FillCol {
            Param (
                [int] $MaxCnt,
                [int] $RowCnt,
                [string] $nStr = $NaN,
                [string] $Sep  = $Delimiter
            )
            [int]$diffCnt = $MaxCnt - $RowCnt
            if ($diffCnt -lt 0){
                Write-Error "指定した列数以上の列を検出。検出列数: $RowCnt > 指定列数: $MaxCnt" -ErrorAction Stop
            }
            [string]$addRstr = ($Sep + $nStr) * $diffCnt
            return $addRstr
        }
    }
    process {
        $readLine = [string]$_
        if (($SkipBlank) -and ($readLine -eq '')) {
            #pass
        }else{
            if ($readLine -eq ''){
                $readLine = "$NaN"
            }
            $splitLine = "$readLine" -Split "$Delimiter"
            ## count column
            if ($readLine -eq ''){
                $rowCnt = 0
            }else{
                $rowCnt = $splitLine.Count
            }
            ## set row
            if($Max){
                # func
                $rstr = FillCol $Max $rowCnt "$NaN" "$Delimiter"
                $writeLine = $readLine + $rstr
                Write-Output $writeLine
            }else{
                ## even
                $listObj.Add([int]$rowCnt)
                ## odd
                $listObj.Add([string]$readLine)
                ## set max col num
                if($splitLine.Count -gt $maxCol){
                  $maxCol = $splitLine.Count
                }
            }
        }
    }
    end {
        if (-not $Max){
            [int]$aryCnt = 0
            [string[]]$listAry = @()
            $listAry = $listObj.ToArray()
            foreach ($line in $listAry){
                $aryCnt++
                if($aryCnt % 2 -eq 1){
                    ## odd: create add string
                    [int]$rowCol = $line
                    $rstr = ''
                    $rstr = FillCol $maxCol $rowCol "$NaN" "$Delimiter"
                }else{
                    ## even: output line with additional columns
                    $writeLine = [string]$line + $rstr
                    Write-Output $writeLine
                }
            }
        }
    }
}
