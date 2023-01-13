<#
.SYNOPSIS

sm2 - sum up

半角スペース区切りの標準入力から指定列の合計を算出（サムアップ）

sm2 [+count] <k1> <k2> <s1> <s2>

    +count: 合計した行数を最左列に出力

<k1>列から<k2>列をキーとして<s1>列から<s2>列までを合計する。
ファイルのキーの事前ソートが必要。
大文字小文字を区別しない。


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
        [boolean] $countFlag   = $False
        [boolean] $dentakuFlag = $False

        # キーの格納
        if($args[0] -like '+count'){
            if($args.Count -lt 5){
                Write-Error "引数が足りません." -ErrorAction Stop
            }else{
                $countFlag = $true
                $k1 = [int]$args[1] - 1
                $k2 = [int]$args[2] - 1
                $s1 = [int]$args[3] - 1
                $s2 = [int]$args[4] - 1
            }
        }else{
            if($args.Count -lt 4){
                Write-Error "引数が足りません." -ErrorAction Stop
            }else{
                $k1 = [int]$args[0] - 1
                $k2 = [int]$args[1] - 1
                $s1 = [int]$args[2] - 1
                $s2 = [int]$args[3] - 1
                        }
        }
        if(($k1 -lt 0) -or ($k2 -lt 0)){$dentakuFlag = $true}
        #Write-Output $countFlag,$dentakuFlag,$k1,$k2,$s1,$s2

        # 行数カウンタ
        [int] $readRow = 0

        # キー数カウンタ
        [int] $keyCount = 0

        # 値格納用配列の作成
        $sumHash = @{}
        $lastSumHash = @{}
        [boolean] $skipSubKeyFlag = $False

        # その他変数の初期化
        [int] $rowCounter = 0
        [int] $keyCount   = 0
        [string] $writeLine = ''
        [string] $writeKey  = ''
        [string] $writeVal  = ''
        [string] $lastkey   = ''
    }

    process
    {
        # 電卓モード
        if($dentakuFlag){
            $splitLine = $_ -Split " "
            $rowCounter++
            # valuesディクショナリの生成
            for($i = $s1; $i -le $s2; $i++){
                $sumHash["$i"] += [decimal]$splitLine[$i]
            }
        }else{
        # キー毎足し算モード
            $readRow++
            $splitLine = $_ -Split " "

            #keyの生成
            $key = ''
            for($i = $k1; $i -le $k2; $i++){
                $key = [string]$key + ' ' + [string]$splitLine[$i]
            }
            $key = $key.Trim()

            # keyが変化したら小計出力およびカウントリセット
            if(($key -ne $lastkey) -and ($readRow -gt 1)){
                $writeKey = ''
                $writeKey = [string]$lastkey
                $writeVal = ''
                for($i = $s1; $i -le $s2; $i++){
                    $writeVal = [string]$writeVal + " " + [string]$lastSumHash["$i"]
                    $sumHash["$i"] = 0
                }
                $writeLine = [string]$writeKey + [string]$writeVal
                if($countFlag){
                    $writeLine = [string]$keyCount + ' ' + $writeLine
                    Write-Output "$writeLine"
                }else{
                    Write-Output "$writeLine"
                }
                $keyCount = 0
                $writeLine = ''
            }

            #valuesの合計
            for($i = $s1; $i -le $s2; $i++){
                $sumHash["$i"] += [decimal]$splitLine[$i]
                $lastSumHash["$i"] = $sumHash["$i"]
            }
            $lastkey = $key

            # キー数カウントアップ
            $keyCount += 1
        }
    } # end of process block

    end
    {

        # 電卓モード
        if($dentakuFlag){
        for($i = $s1; $i -le $s2; $i++){
            $writeVal = [string]$writeVal + ' ' + [string]$sumHash["$i"]
        }
        $writeLine = [string]$writeVal.Trim()
        if($countFlag){
            $writeLine = [string]$rowCounter + ' ' + $writeLine
            Write-Output "$writeLine"
        }else{
            Write-Output "$writeLine"
        }
        }else{
        # キー毎足し算モード
        # ヘッダスキップありなし共通
        $writeKey = ''
        $writeKey = [string]$lastkey
        $writeVal = ''
        for($i = $s1; $i -le $s2; $i++){
            $writeVal = [string]$writeVal + " " + [string]$lastSumHash["$i"]
        }
        $writeLine = [string]$writeKey + [string]$writeVal
        if($countFlag){
            $writeLine = [string]$keyCount + ' ' + $writeLine
            Write-Output "$writeLine"
        }else{
            Write-Output "$writeLine"
        }
        }
    }
}
