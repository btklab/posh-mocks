<#
.SYNOPSIS
    kinsoku -- Japanese text wrapper
    
    入力行1行ごとに禁則処理を施す。

    「-Width <int>」で折返し文字幅を指定（全角2、半角1）
    「-Expand」でぶら下げ禁則処理ON
    「-Yoon」で「ゃゅょ」と促音「っ」禁則処理 ON（デフォルトでON）
    「-Join '\n'」で改行ポイントに'\n'を挿入。出力は改行なし
    「-AddLastChar <str>」で行末のみに任意文字列を追加

    禁則処理後、行の前後の空白は削除される。
    「-OffTrim」で行頭行末の空白を削除しない。

    thanks:
    - 禁則処理 - PyJaPDF
        - http://pyjapdf.linxs.org/home/kinsoku
    - 【WEBツール】Unicode 変換 - お便利ツール.com （unicode変換）
        - https://www.oh-benri-tools.com/tools/programming/unicode-escape-unescape
    - ArrayList
        - https://docs.microsoft.com/ja-jp/dotnet/api/system.collections.arraylist.remove?view=net-5.0

    references:
    - 禁則処理 (Sep. 10, 2022, 09:31 UTC). In Wikipedia: The Free Encyclopedia.
        - https://ja.wikipedia.org/wiki/%E7%A6%81%E5%89%87%E5%87%A6%E7%90%86
    - JISX4051:2004 日本語文書の組版方法 - kikakurui.com
        - https://kikakurui.com/x4/X4051-2004-02.html

.PARAMETER Width
    折り返し文字幅を、全角文字を2、半角文字を1として指定。
    たとえばひらがな5文字で折り返したいなら10を指定する

.PARAMETER Expand
    はみ出た文字列をぶら下げ（同じ行に出力）

.PARAMETER Yoon
    拗音と促音にも禁則処理を適用する
    デフォルトでTrue（ON）

.PARAMETER Join
    改行ポイントに任意の文字列を挿入。
    このオプションを指定した場合、出力は改行なし

.PARAMETER OffTrim
    行頭の空白を削除しない

.PARAMETER SkipTop
    行頭から任意の正規表現にマッチする文字列を無視。
    行頭にID列があるデータなどに用いる。

.PARAMETER SkipTopJoinStr
    SkipTopオプションで除外したID文字列の区切り文字を指定する。
    SkipTopオプションを指定しなかった場合、全行に任意の文字列を付与する。

.EXAMPLE
    "aa aa aa aaa aa aa, hoge fuga." | kinsoku 18
    PS > "aa aa aa aaa aa aa, hoge fuga." | kinsoku -Width 18

    aa aa aa aaa aa
    aa, hoge fuga.

    PS > "aa aa aa aaa aa aa, hoge fuga." | kinsoku 18 -Expand
    aa aa aa aaa aa aa,
    hoge fuga.

.EXAMPLE
    "あいうえおかきくけこ、さしすせそたち。" | kinsoku 20
    あいうえおかきくけ
    こ、さしすせそたち。

    PS > "あいうえおかきくけこ、さしすせそたち。" | kinsoku 22
    あいうえおかきくけこ、
    さしすせそたち。

    PS > "あいうえおかきくけこ、さしすせそたち。" | kinsoku 20 -Expand
    あいうえおかきくけこ、
    さしすせそたち。

.EXAMPLE
    "あいうえおかきくけこ、さしすせそたち。" | kinsoku 20 -Expand -Join '\n'
    あいうえおかきくけこ、\nさしすせそたち。


.EXAMPLE
    "ID0001:あああああ、いいいいい、ううううう" | kinsoku 10 -Expand
    ID0001:ああ
    あああ、い
    いいいい、
    ううううう


    PS > "ID0001:あああああ、いいいいい、ううううう" | kinsoku 10 -Expand -SkipTop 'ID....:'
    ID0001:あああああ、
    いいいいい、
    ううううう


    PS > "ID0001:あああああ、いいいいい、ううううう" | kinsoku 10 -Expand -SkipTop 'ID....:' -SkipTopJoinStr '\n'
    ID0001:\nあああああ、
    いいいいい、
    ううううう

    PS > "ID0001:あああああ、いいいいい、ううううう" | kinsoku 10 -Expand -SkipTop 'ID....:' -SkipTopJoinStr '\n' -Join '\n'
    ID0001:\nあああああ、\nいいいいい、\nううううう

    PS > "ID0001:あああああ、いいいいい、ううううう" | kinsoku 10 -Expand -SkipTop 'ID....:' -SkipTopJoinStr '\n' -Join '\n' -AddLastChar '\r\n'
    ID0001:\nあああああ、\nいいいいい、\nううううう\r\n

    説明
    ===============
    -SkipTop 'ID....:'で、ID文字列はノーカウント。
    先頭にIDがあり、それをカウントしたくない場合などに使う。
#>
function kinsoku {
    Param(
        [parameter(Mandatory=$True, Position=0)]
        [Alias('w')]
        [int]$Width,

        [parameter(Mandatory=$False)]
        [Alias('e')]
        [switch]$Expand,

        [parameter(Mandatory=$False)]
        [Alias('y')]
        [switch]$Yoon = $True,

        [parameter(Mandatory=$False)]
        [Alias('j')]
        [string]$Join,

        [parameter(Mandatory=$False)]
        [switch]$OffTrim,

        [parameter(Mandatory=$False)]
        [string]$SkipTop,

        [parameter(Mandatory=$False)]
        [string]$SkipTopJoinStr = '',

        [parameter(Mandatory=$False)]
        [string]$AddLastChar,

        [parameter(Mandatory=$False,
            ValueFromPipeline=$True)]
        [string[]]$Text
    )
    begin {
        # set prohibited characters at the beginning
        ## prohibited characters at the end of line
        ### left parenthesis '([｛〔〈《「『【〘〖〝‘“｟«([〔（'
        [string] $leftParenthesis  = '\u0028\u005b\uff5b\u3014\u3008\u300a\u300c\u300e\u3010\u3018\u3016\u301d\u2018\u201c\uff5f\u00ab\u0028\u005b\u3014\uff08'
        ### alphabets'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
        [string] $sequenceAlphabets = '\u0041\u0042\u0043\u0044\u0045\u0046\u0047\u0048\u0049\u004a\u004b\u004c\u004d\u004e\u004f\u0050\u0051\u0052\u0053\u0054\u0055\u0056\u0057\u0058\u0059\u005a\u0061\u0062\u0063\u0064\u0065\u0066\u0067\u0068\u0069\u006a\u006b\u006c\u006d\u006e\u006f\u0070\u0071\u0072\u0073\u0074\u0075\u0076\u0077\u0078\u0079\u007a'
        ### numbers '0123456789'
        [string] $sequenceNumbers = '\u0030\u0031\u0032\u0033\u0034\u0035\u0036\u0037\u0038\u0039'

        ### convert to char array
        [string] $kEnd  = $leftParenthesis
        [string] $kEnd += $sequenceAlphabets
        [string] $kEnd += $sequenceNumbers
        [string] $kEnd = [regex]::Unescape($kEnd)
        [string[]] $kinsokuLastChars = $kEnd.ToCharArray()

        ## prohibited characters at the beginning of line

        ### right parenthesis ',)]｝、〕〉》」』】〙〗〟’”｠»)]〕）'
        [string] $rightParenthesis  = '\u002c\u0029\u005d\uff5d\u3001\u3015\u3009\u300b\u300d\u300f\u3011\u3019\u3017\u301f\u2019\u201d\uff60\u00bb\u0029\u005d\u3015\uff09'
        ### dakuon '゛゜'
        [string] $letterDakuon = '\u309b\u309c'
        ### question marks and exclamation marks '？！?!‼⁇⁈⁉'
        [string] $questionMarks = '\uff1f\uff01\u003f\u0021\u203c\u2047\u2048\u2049'
        ### hyphens "‐゠–〜"
        [string] $hyphens = '\u2010\u30a0\u2013\u301c'
        ### 中点・句読点 '・･：:；;。．、，.,､'
        [string] $middleDotAndFullStop = '\u30fb\uff65\uff1a\u003a\uff1b\u003b\u3002\uff0e\u3001\uff0c\u002e\u002c\uff64'
        ### repeat symbol 'ヽヾー々〻'
        [string] $repeatSymbols = '\u30fd\u30fe\u30fc\u3005\u303b'
        ### 分離禁止文字 '—…‥〳〴〵'
        [string] $nonSeparableCharacters = '\u2014\u2026\u2025\u3033\u3034\u3035'
        ### 後置省略記号 '°¢′″‰℃ℓ％㏋'
        [string] $postfixAbbreviations = '\u00b0\u00a2\u2032\u2033\u2030\u2103\u2113\uff05\u33cb'
        ### 前置省略記号 '¥£$＃€№'
        [string] $prefixAbbreviations = '\u00a5\u00a3\u0024\uff03\u20ac\u2116'

        ### 拗音・促音
        #### 小文字ひらがな 'ぁぃぅぇぉっゃゅょゎゕゖ'
        [string] $letterHiraganaSmall  = '\u3041\u3043\u3045\u3047\u3049\u3063\u3083\u3085\u3087\u308e\u3095\u3096'
        #### 小文字カタカナ 'ァィゥェォッャュョヮヵヶ'
        [string] $letterKatakanaSmall  = '\u30a1\u30a3\u30a5\u30a7\u30a9\u30c3\u30e3\u30e5\u30e7\u30ee\u30f5\u30f6'
        #### 小文字カタカナ 'ㇰㇱㇲㇳㇴㇵㇶㇷㇸㇹㇺㇻㇼㇽㇾㇿ'
        [string] $letterKatakanaExtended = '\u31f0\u31f1\u31f2\u31f3\u31f4\u31f5\u31f6\u31f7\u31f8\u31f9\u31fa\u31fb\u31fc\u31fd\u31fe\u31ff'

        ## convert to char array
        [string] $kTop  = $rightParenthesis
        [string] $kTop += $letterDakuon
        [string] $kTop += $questionMarks
        [string] $kTop += $hyphens
        [string] $kTop += $middleDotAndFullStop
        [string] $kTop += $repeatSymbols
        [string] $kTop += $nonSeparableCharacters
        [string] $kTop += $postfixAbbreviations
        [string] $kTop += $prefixAbbreviations
        if ($Yoon){
            [string] $kTop += $letterHiraganaSmall
            [string] $kTop += $letterKatakanaExtended
        }
        [string] $kTop = [regex]::Unescape($kTop)
        [string[]] $kinsokuFirstChars = $kTop.ToCharArray()

        # debug
        Write-Debug "kinsoku-top-letters: $($kinsokuFirstChars -Join '')`n"
        Write-Debug "kinsoku-end-letters: $($kinsokuLastChars  -Join '')`n"

        # private function
        function isKinsokuFirstChars ([string] $c){
            [string[]]$charAry = $c.ToCharArray()
            [string] $firstChar = $charAry[0]
            if ($kinsokuFirstChars.Contains($firstChar)){
                return $True
            } else {
                return $False
            }
        }
        function isKinsokuLastChars ([string] $c){
            [string[]]$charAry = $c.ToCharArray()
            [string] $lastChar = $charAry[-1]
            if ($kinsokuLastChars.Contains($lastChar)){
                return $True
            } else {
                return $False
            }
        }
        function countChar ([string] $c) {
            if ($c -eq ''){
                [int] $charWidth = 0
            } else {
                [int] $charWidth = [System.Text.Encoding]::GetEncoding("Shift_Jis").GetByteCount($c)
            }
            return $charWidth
        }
        function joinKinsokuLastChars ([string[]] $lineChars){
                [string[]] $outputLines = @()
                [string] $tmpChar = ''
                foreach ($c in $lineChars){
                    if (isKinsokuLastChars $c){
                        $tmpChar += $c
                    }elseif ($tmpChar -eq '') {
                        $outputLines += $c
                    } else {
                        $tmpChar += $c
                        $outputLines += $tmpChar
                        $tmpChar = ''
                    }
                }
                if ($tmpChar -ne ''){
                    $outputLines += $tmpChar
                }
                return $outputLines
        }
        function joinKinsokuFirstChars ([string[]] $lineChars){
                [string[]] $outputLines = @()
                [string[]] $lineCharsRev = $lineChars[($lineChars.Count-1)..0]
                foreach ($c in $lineCharsRev){
                    if (isKinsokuFirstChars $c){
                        $tmpChar = $c + $tmpChar
                    }elseif ($tmpChar -eq '') {
                        $outputLines += $c
                    } else {
                        $tmpChar = $c + $tmpChar
                        $outputLines += $tmpChar
                        $tmpChar = ''
                    }
                }
                if ($tmpChar -ne ''){
                    $outputLines += $tmpChar
                }
                $outputLines = $outputLines[($outputLines.Count-1)..0]
                return $outputLines
        }
        function getNextChars ([string[]] $lineChars, [int]$pos){
            if ($pos -eq $lineChars.Count - 1){
                return
            } else {
                return $lineChars[$pos]
            }
        }
        ## main function
        function applyKinsoku {
            Param(
                [string] $line
            )
            if (($SkipTop) -and ($line -match "^$SkipTop")){
                [regex]  $reg     = "^($SkipTop)(..*)`$"
                [string] $preLine = $line -replace $reg,'$1'
                [string] $line    = $line -replace $reg,'$2'
            } else {
                [string] $preLine = ''
            }
            if ($AddLastChar){
                [string] $postLine = $AddLastChar
            } else {
                [string] $postLine = ''
            }
            # init var
            [string[]] $outputLines = @()
            [string]   $outputLine  = $preLine + $SkipTopJoinStr
            [bool]  $isExpand    = $False
            [bool]  $isResidual  = $False
            [int]      $lineWidthTotal = 0
            # line characters into array
            [string[]] $lineChars = $line.ToCharArray()
            [int] $lineWidth = countChar $line
            # create charset
            if ($lineWidth -eq 0){
                # empty line
                $outputLines += $outputLine + $line + $postLine
                return $outputLines
            }
            if ($lineWidth -le $Width) {
                $outputLines += $outputLine + $line + $postLine
                return $outputLines
            }
            # main
            ## 行末禁則文字を次の文字と連結して文字列アレイに代入
            $lineChars = joinKinsokuLastChars $lineChars
            ## 行頭禁則文字を前の文字と連結して文字列アレイに代入
            $lineChars = joinKinsokuFirstChars $lineChars
            ## 所定文字数になるまで文字アレイの各要素を連結
            ## 所定文字数に達したら出力アレイに格納
            for ($pos=0; $pos -lt $lineChars.Count; $pos++){
                [string] $c = $lineChars[$pos]
                $lineWidthTotal += countChar $c
                if ($pos -eq $lineChars.Count - 1){
                    $c = $c + $postLine
                }
                if ($Width -lt 2){
                    $outputLines += $c
                } elseif ($lineWidthTotal -eq $Width){
                    # output line
                    $outputLine += $c
                    $outputLines += $outputLine
                    # init vars
                    $lineWidthTotal = 0
                    $outputLine = ''
                    $isResidual = $False
                } elseif ($lineWidthTotal -gt $Width){
                    if ($Expand){
                        # output line
                        $outputLine += $c
                        $outputLines += $outputLine
                        # init vars
                        $lineWidthTotal = 0
                        $outputLine = ''
                        $isResidual = $False
                    } else {
                        # output line
                        $outputLines += $outputLine
                        # init vars
                        $lineWidthTotal = countChar $c
                        $outputLine = $c
                        $isResidual = $True
                    }
                } else {
                    $outputLine += $c
                    $isResidual = $True
                }
            }
            if ($isResidual){
                $outputLines += $outputLine
            }
            return $outputLines
        }
    }
    process {
        [string] $readLine = [string] $_
        [string[]] $outputLines = applyKinsoku $readLine
        if ($Join){
            $outputLines -join "$Join"
        } else {
            foreach ($l in $outputLines){
                if ($OffTrim){
                    Write-Output "$l"
                } else {
                    Write-Output "$l".Trim()
                }
            }
        }
    }
}
