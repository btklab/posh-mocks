<#
.SYNOPSIS
    lcalc - Column-to-column calculator
    
    Column-to-column calcurations on space delimited
    standart input.
    
    lcalc [-d] 'expr; expr;...'

    Multiple expressions can be specified by separating
    expr with ";".

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
        if( $args.Count -lt 1 ){
            Write-Error "Insufficient args." -ErrorAction Stop
        }
        if( $args.Count -eq 1 ){
            [string] $exStr = $args[0]
            [bool] $dflag = $False
        }
        if( [string]($args[0]) -eq "-d" ){
            if( $args.Count -lt 2 ){
                Write-Error "Insufficient args." -ErrorAction Stop
            }
            $exStr = $args[1]
            $dflag = $True
        }
        
        # Convert expr
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
        
        $splitTmp = $tmpScript.Split(";")

        # init var
        [string] $Delimiter = ' '
    }
    process
    {
        if( -not ($dflag) ){
            [string] $writeLine = ''
            [string] $readLine = [string] $_
            if ( $Delimiter -eq ''){
                [string[]] $splitLine = $readLine.ToCharArray()
            } else {
                [string[]] $splitLine = $readLine.Split( $Delimiter )
            }
            for( $i=0;$i -lt $splitTmp.Count; $i++ ){
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
        if( $dflag ){
            Invoke-Expression $tmpScript
        }
    }
}
