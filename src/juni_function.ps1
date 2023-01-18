<#
.SYNOPSIS
行数の付与

juni [-z]

 -z: ゼロ始まり


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
            [int] $i = -1
        }else{
            [int] $i = 0
        }
    }

    process
    {
        $i++
        Write-Output "$i $_"
    }
}
