<#
.SYNOPSIS
    zen - Convert half-width kana to full-width kana using Microsoft.VisualBasic.VbStrConv

    全角文字を半角に変換する
    [-k|-Kana]スイッチで半角カタカナのみ全角カタカナに変換

    "input" | han | zen -k
    → 英数字記号を半角に、カナのみ全角に変換

    Regex.Replace Method (.NET 7)  - Replace(String, String, MatchEvaluator)
      - https://learn.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.regex.replace
      - https://learn.microsoft.com/ja-jp/dotnet/api/system.text.regularexpressions.regex.replace

.LINK
    han, zen, vbStrConv


.PARAMETER Kana
    Convert only half-width kana to full-width kana

.EXAMPLE
    "パピプペポ０１２３４５６７８９＝Ａ" | han | zen -k
    パピプペポ0123456789=A

    説明
    ==============
    入力から英数字記号を半角に、カナのみ全角に変換


.EXAMPLE
    "パピプペポ０１２３４５６７８９＝Ａ" | han
    ﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟ0123456789=A

    PS > "パピプペポ０１２３４５６７８９＝Ａ" | han | zen
    パピプペポ０１２３４５６７８９＝Ａ

    PS > "パピプペポ０１２３４５６７８９＝Ａ" | han -k
    パピプペポ0123456789=A

    PS > "パピプペポ０１２３４５６７８９＝Ａ" | han -k | zen
    パピプペポ０１２３４５６７８９＝Ａ

    PS > "パピプペポ０１２３４５６７８９＝Ａ" | han -k | zen -k
    パピプペポ0123456789=A

#>
function zen {
    #Requires -Version 5.0
    param (
        [Parameter(Mandatory=$False)]
        [Alias('k')]
        [switch] $Kana,
        [parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [string[]] $InputText
    )
    begin {
        Add-Type -AssemblyName "Microsoft.VisualBasic"
        Add-Type -AssemblyName "System.Text.RegularExpressions"
        #$vbHankaku = [Microsoft.VisualBasic.VbStrConv]::Narrow
        $vbZenkaku = [Microsoft.VisualBasic.VbStrConv]::Wide
        # MatchEvaluatorDelegate
        $callback = {
            [Microsoft.VisualBasic.Strings]::StrConv(
                [System.Text.RegularExpressions.Match] $args[0],
                $vbZenkaku
            )
        }
        # zenkaku KANA pattern: [｡-ﾟ]+
        [regex] $pat = "[$([regex]::Unescape('\uff61-\uff9f'))]+"
        Write-Debug $pat
    }
    process {
        [string] $readLine = [string] $_
        if ($Kana){
            # MatchEvaluatorDelegate
            [regex]::Replace($readLine, $pat, $callback)
        } else {
            [Microsoft.VisualBasic.Strings]::StrConv($readLine, $vbZenkaku)
        }
    }
}
