<#
.SYNOPSIS

lcalc - Column-to-column calculator

半角スペース区切りの標準入力における列同士の計算

lcalc [-d] 'expr; expr;...'

    ";"で区切ることで複数の計算式を指定可能。

    計算列の指定
      $1,$2,... : 列指定は$記号+列数
      $0        : 全列指定
      $NF       : 最終列のみこのように書くことができる。
                  ただし$NF-1とは書けない点に注意。

     短縮形で使用できる関数
      丸め       : round($1,num)
      平方根     : sqrt($1)
      べき乗     : pow($1,2)
      絶対値     : abs($1)
      対数       : log($1)
      対数base=2 : log2($1)
      常用対数   : log10($1)
      パイ       : PI


.EXAMPLE
"8.3 70","8.6 65","8.8 63"
8.3 70
8.6 65
8.8 63

"8.3 70","8.6 65","8.8 63" | lcalc '$1+1;$2/10'
9.3 7
9.6 6.5
9.8 6.3

.EXAMPLE
lcalc -d '1+1'
2

# calculator mode does not require
# standard input (from pipline)

lcalc -d '1+sqrt(4)'
3

lcalc -d 'pi'
3.14159265358979

# 短縮形で使用できる関数以外の関数も使用できる
lcalc -d '[math]::Ceiling(1.1)'
2

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
function lcalc {

    begin
    {
        if($args.Count -lt 1){ throw "引数が不足しています." }
        if($args.Count -eq 1){$exStr = $args[0]; $dflag = $false}
        if($args[0] -eq "-d"){$exStr = $args[1]; $dflag = $true}
        
        # 引数を列指定文字列に変換
        $tmpScript = $exStr -replace ' ',''
        $tmpScript = $tmpScript -replace 'round\(','[decimal][math]::round('
        $tmpScript = $tmpScript -replace 'PI','[decimal][math]::PI'
        $tmpScript = $tmpScript -replace 'abs\(','[decimal][math]::abs('
        
        $tmpScript = $tmpScript -replace 'log\(','[decimal][math]::log('
        $tmpScript = $tmpScript -replace 'log10\(','[decimal][math]::log10('
        $tmpScript = $tmpScript -replace 'log2\(','[decimal][math]::log2('
        $tmpScript = $tmpScript -replace 'pow\(','[decimal][math]::pow('
        $tmpScript = $tmpScript -replace 'sqrt\(','[decimal][math]::sqrt('
        
        $tmpScript = $tmpScript -replace '(\d+(\.\d+)?)','[decimal]$1'
        $tmpScript = $tmpScript -replace '\$\[decimal\](\d+)','[decimal]$splitLine[$1-1]'
        $tmpScript = $tmpScript.Replace('[decimal]$splitLine[0-1]','[string]$_')
        $tmpScript = $tmpScript -replace 'log\[decimal\]10','log10'
        $tmpScript = $tmpScript -replace 'log\[decimal\]2\((.*?)\)','log($1, 2)'
        
        $tmpScript = $tmpScript -replace '\$NF','[decimal]$splitLine[$splitLine.Count-1]'
        #Write-Output $tmpScript;
        
        $splitTmp = $tmpScript.Split(";")
        #Write-Output $splitTmp.Count
    }

    process
    {
        if(!($dflag)){
            [string]$writeLine = ''
            [string[]]$splitLine = $_ -Split ' '
            for($i=0;$i -lt $splitTmp.Count; $i++){
                [string]$tmpWriteLine = Invoke-Expression $splitTmp[$i]
                $writeLine += ' ' + $tmpWriteLine
            }
            $writeLine = $writeLine.Trim()
            Write-Output $writeLine
            $writeLine = ''
        }
    }

    end
    {
        if($dflag -eq $true){ Invoke-Expression $tmpScript}
    }
}
