<#
.SYNOPSIS
    han - Convert full-width kana to half-width kana using Microsoft.VisualBasic.VbStrConv

    全角文字を半角に変換
    [-k|-Kana]スイッチで全角カタカナはに変換しない
    （半角カナを全角に変換するわけではない）

    "input" | han | zen -k
    → 英数字記号を半角に、カナのみ全角に変換

.LINK
    han, zen, vbStrConv

    Regex.Replace Method (.NET 7)  - Replace(String, String, MatchEvaluator)
    https://learn.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.regex.replace
    https://learn.microsoft.com/ja-jp/dotnet/api/system.text.regularexpressions.regex.replace


.PARAMETER Kana
    Do not convert full-width(zenkaku) KANA

.EXAMPLE
"パピプペポ０１２３４５６７８９＝Ａ" | han | zen -k
パピプペポ0123456789=A

説明
==============
入力から英数字記号を半角に、カナのみ全角に変換

.EXAMPLE
"パピプペポ０１２３４５６７８９＝Ａ" | han
ﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟ0123456789=A


"パピプペポ０１２３４５６７８９＝Ａ" | han | zen
パピプペポ０１２３４５６７８９＝Ａ


"パピプペポ０１２３４５６７８９＝Ａ" | han -k
パピプペポ0123456789=A


"パピプペポ０１２３４５６７８９＝Ａ" | han -k | zen
パピプペポ０１２３４５６７８９＝Ａ

"パピプペポ０１２３４５６７８９＝Ａ" | han | zen -k
パピプペポ0123456789=A

#>
function han {
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
        $vbHankaku = [Microsoft.VisualBasic.VbStrConv]::Narrow
        #$vbZenkaku = [Microsoft.VisualBasic.VbStrConv]::Wide
        # MatchEvaluatorDelegate
        $callback = {
            [Microsoft.VisualBasic.Strings]::StrConv(
                [System.Text.RegularExpressions.Match] $args[0],
                $vbHankaku
            )
        }
        # zenkaku KANA pattern: [^ァ-ヿ゛゜。「」『』、・]+
        [regex] $pat = "[^$([regex]::Unescape('\u30a1-\u30ff\u309b\u309c\u3002\u300c\u300d\u300e\u300f\u3001\u30fb'))]+"
        Write-Debug $pat
    }
    process {
        [string] $readLine = [string] $_
        if ($Kana){
            # MatchEvaluatorDelegate
            [regex]::Replace($readLine, $pat, $callback)
        } else {
            [Microsoft.VisualBasic.Strings]::StrConv($readLine, $vbHankaku)
            #[Microsoft.VisualBasic.Strings]::StrConv($readLine, $vbZenkaku)
        }
    }
}
