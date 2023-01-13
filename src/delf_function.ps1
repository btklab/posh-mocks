<#
.SYNOPSIS

delf - delete fields

半角スペース区切りの標準入力から指定列のみ削除する
最終列を'NF'で指定することもできる

delf <num> <num>...

.EXAMPLE
"1 2 3","4 5 6","7 8 9" | delf 1 2
3
6
9

delete field 1 and 2

.EXAMPLE
"1 2 3 4 5","6 7 8 9 10" | delf 1 NF-1
2 3 5
7 8 10

delete field 1 and 2nd field from right

#>
function delf {

    begin
    {
        # init var
        $writeLine = ''
        $getLineExp = ''

        if($args.Count -lt 1){
            Write-Error "invalid args." -ErrorAction Stop}

        foreach($item in $args){
            if($item -match "NF"){
                $item = $item -replace 'NF', '$splitLine.Count-1'
                $item = $item -replace '(..*)', '($1)'
            }else{
                $item = [int] $item - 1
            }
            $getLineExp = $getLineExp + ' ' + '($i -ne ' + [string]$item + ')'
        }
        $getLineExp = $getLineExp -replace '\) \(', ') -and ('
    }

    process
    {
        [string] $line = [string] $_
        [string[]] $splitLine = $line -Split ' '
        for($i=0;$i -lt $splitLine.Count;$i++){
            $ifExp = Invoke-Expression "$getLineExp"
            if($ifExp){$writeLine += ' ' + [string]$splitLine[$i]}
        }
        [string] $writeLine = $writeLine.Trim()
        Write-Output $writeLine
        $writeLine = ''
    }
}
