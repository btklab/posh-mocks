<#
.SYNOPSIS

ctail  - 行末尾から1行削除して出力する

削除する行数は最後の1行のみだが、
省メモリで処理する。

入力はパイプラインからのみ受け付け


.EXAMPLE
PS C:\> cat a.txt | ctail
a.txt の最後の 1 行を削除し残りの行を出力

#>
function ctail {

    begin
    {
        $readRowCounter = 0
        $line = ''
    }

    process
    {
        $readRowCounter++
        if($readRowCounter -ne 1){
            Write-Output $line
            $line = [string]$_
        }else{
            $line = [string]$_
        }
    }
}
