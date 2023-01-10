<#
.SYNOPSIS
文字列をリバースする
入力はパイプのみ受け付け

rev

.EXAMPLE
PS C:\>Write-Output あいうえお | rev
おえういあ

#>
filter rev {
    [string[]] $str = ([string]$_).ToCharArray()
    [string] $ret = [string]::join("",$str[($str.Length - 1)..0])
    return $ret
}
