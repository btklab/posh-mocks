<#
.SYNOPSIS
    rev - Reverse strings

    Reverse strings within a line.

.LINK
    rev, rev2

.EXAMPLE
    "aiueo" | rev
    oeuia

#>
filter rev {
    [string[]] $str = ([string]$_).ToCharArray()
    [string] $ret = [string]::join("",$str[($str.Length - 1)..0])
    return $ret
}
