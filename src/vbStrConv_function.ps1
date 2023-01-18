<#
.SYNOPSIS
    vbStrConv - Convert strings using Microsoft.VisualBasic.VbStrConv

    Options:
    - Lowercase
    - Uppercase
    - ProperCase
    - Wide
    - Narrow
    - Hiragana
    - Katakana

.LINK
    han, zen, vbStrConv

#>
function vbStrConv {
    #Requires -Version 5.0
    param (
        [parameter(Mandatory=$False)]
        [Alias('l')]
        [switch] $Lowercase,

        [parameter(Mandatory=$False)]
        [Alias('u')]
        [switch] $Uppercase,

        [parameter(Mandatory=$False)]
        [Alias('p')]
        [switch] $ProperCase,

        [parameter(Mandatory=$False)]
        [Alias('w')]
        [switch] $Wide,

        [parameter(Mandatory=$False)]
        [Alias('n')]
        [switch] $Narrow,

        [parameter(Mandatory=$False)]
        [Alias('h')]
        [switch] $Hiragana,

        [parameter(Mandatory=$False)]
        [Alias('k')]
        [switch] $Katakana,

        [parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [string[]] $InputText
    )
    begin {
        Add-Type -AssemblyName "Microsoft.VisualBasic"
        if ($Lowercase){
            $vbConverter = [Microsoft.VisualBasic.VbStrConv]::Lowercase
        } elseif ($Uppercase){
            $vbConverter = [Microsoft.VisualBasic.VbStrConv]::Uppercase
        } elseif ($ProperCase){
            $vbConverter = [Microsoft.VisualBasic.VbStrConv]::ProperCase
        } elseif ($Wide){
            $vbConverter = [Microsoft.VisualBasic.VbStrConv]::Wide
        } elseif ($Narrow){
            $vbConverter = [Microsoft.VisualBasic.VbStrConv]::Narrow
        } elseif ($Hiragana){
            $vbConverter = [Microsoft.VisualBasic.VbStrConv]::Hiragana
        } elseif ($Katakana){
            $vbConverter = [Microsoft.VisualBasic.VbStrConv]::Katakana
        } else {
            Write-Error "please set args." -ErrorAction Stop
        }
    }
    process {
        [string] $readLine = [string] $_
        [Microsoft.VisualBasic.Strings]::StrConv($readLine, $vbConverter)
    }
}
