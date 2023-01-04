<#
.SYNOPSIS
行数の付与

juni [-z]

 -z: ゼロ始まり

.DESCRIPTION
行数を付与する

.EXAMPLE
PS C:\>cat a.txt | juni
行数を付与する

#>
function juni {

    begin
    {
        $zeroFlag = $False
        if($args.Count -gt 0){
            if($args[0] -eq '-z'){$zeroFlag = $True}
        }
        if($zeroFlag){
            $i = -1
        }else{
            $i = 0
        }
    }

    process
    {
        $i++
        [string]$i + ' ' + [string]$_
    }
}
