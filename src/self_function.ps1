<#
.SYNOPSIS

self - select fields

半角スペース区切りの標準入力から任意の列のみ抽出する。
すべての列は'0'で、最終列は'NF'で指定することもできる

1.2.3と指定すると、1列目の2文字目から3文字を切り出し
切り出し文字数が対象文字数よりも多い場合は切り取れる範囲のみ切り出し。

self <num> <num>...

.EXAMPLE
"1 2 3","4 5 6","7 8 9" | self 1 3
1 3
4 6
7 9

# select field 1 and 3

.EXAMPLE
 "123 456 789","223 523 823" | self 2.2.2
56
23

# select entire line and add 2nd field,
# and cut out 2 characters from the 2nd character in the 2nd field

.EXAMPLE
"123 456 789","223 523 823" | self 0 2.2.2
123 456 789 56
223 523 823 23

# select the 1st field from the leftmost field and
# select the 2nd field from the rightmost field(=NF)

.EXAMPLE
"1 2 3 4 5","6 7 8 9 10" | self 1 NF-1
1 4
6 9

1列目と右から2列目を出力

#>
function self {

    begin
    {
        if($args.Count -lt 1){
            Write-Error "invalid args." -ErrorAction Stop}

        # init var
        $getLineExp = ''

        # 引数を列指定文字列に変換
        foreach($a in $args){
            $repdot2space = $a -replace '\.', ' '
            $tmpindividualarg = $repdot2space -Split ' '
            # 列指定文字の生成：NFは最終列
            if($tmpindividualarg[0] -match "NF"){
                $getColNum = $tmpindividualarg[0] -replace 'NF', '$splitLine.Count-1'
                $getColNum = $getColNum -replace '(..*)', '($1)'
            }elseif([int]$tmpindividualarg[0] -eq 0){
                $getColNum = '@@@'
            }else{
                $getColNum = [int]$tmpindividualarg[0] - 1
            }
            #Write-Output $getColNum;

            if($tmpindividualarg.Count -eq 2){
                $substrStartNum = [int]$tmpindividualarg[1] - 1
                $substrEndNum = '$([int]$splitLine[' + [string]$getColNum + '].Length - 1)'
            }
            if($tmpindividualarg.Count -eq 3){
                $substrStartNum = [int]$tmpindividualarg[1] - 1
                $substrEndNum = [int]$tmpindividualarg[2] + $substrStartNum - 1
            }

            # 列指定文字列のセット
            if($tmpindividualarg.Count -eq 1){
                $getLineExp = [string]$getLineExp + " " + '[string]$splitLine[' + [string]$getColNum + ']'
            }else{
                $getLineExp = [string]$getLineExp + ' ' + '[string]$(([string]$splitLine[' + [string]$getColNum + '])[' + [string]$substrStartNum + '..' + [string]$substrEndNum + '] -Join "")'
            }
        }
        $getLineExp = $getLineExp -replace '\] \[string', '] + " " + [string'
        $getLineExp = $getLineExp -replace '\) \[string', ') + " " + [string'
        # 引数が0の場合は行全体を出力
        $getLineExp = $getLineExp -replace '\[string\]\$splitLine\[@@@\]', '$line'
        $getLineExp = $getLineExp.Trim()
    }

    process
    {
        [string] $line = [string] $_
        [string[]] $splitLine = $line -Split ' '
        [string] $writeLine = Invoke-Expression $getLineExp
        Write-Output $writeLine
    }
}
