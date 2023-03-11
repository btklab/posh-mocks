<#
.SYNOPSIS
    rev2 - Reverse columns

    Reverse columns separated by space.
    Do not reverse strings in columns.

    Accepts only input from pipeline

    Usage:
        rev2 [-e]
    
    Option:
        -e: (echo) 入力データも出力する

    Reference:
        https://qiita.com/greymd/items/3515869d9ed2a1a61a49
        Qiita:greymd, 2016/05/12, accessed 2017/11/13

.LINK
    rev, rev2, stair, cycle


.EXAMPLE
    "01 02 03" | rev2
    03 02 01

.EXAMPLE
    "01 02 03" | rev2 -e
    01 02 03
    03 02 01

#>
function rev2 {
    Param(
        [parameter(Mandatory=$False)]
        [Alias('e')]
        [switch] $echo,

        [parameter(Mandatory=$False)]
        [Alias('d')]
        [string] $Delimiter = " ",

        [parameter(Mandatory=$False,
            ValueFromPipeline=$True)]
        [string[]]$Text
    )
    process {
        [string] $readLine = "$_".Trim()
        if ( $Delimiter -eq '' ){
            [string[]] $splitReadLine = $readLine.ToCharArray()
        } else {
            [string[]] $splitReadLine = $readLine.Split( $Delimiter )
        }
        if($echo){ Write-Output $readLine }
        [string] $writeLine = [string]::join($Delimiter, $splitReadLine[($splitReadLine.Count - 1)..0])
        Write-Output $writeLine
    }
}
