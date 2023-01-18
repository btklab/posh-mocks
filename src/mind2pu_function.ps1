<#
.SYNOPSIS

mind2pu - Generate plantuml script to draw a mind map from list data in markdown format

markdown形式のリストデータからマインドマップを描画するplantumlスクリプトを生成する

マークダウンのリスト形式で記述された階層構造をマインドマップ化する
入力データは「半角スペース4つ」に「-,+,*」で階層構造を表す

文末にアンダースコア「_」を入れると、枠なし文字列になる
-Space 2 とすると、ハイフンの前の半角スペースは2つとして認識する

空行は無視、
「//」で始まる行はコメントとみなして無視

一行目かつ「# 」で始まる場合は、タイトルとみなす。

-WBSスイッチでWork Breakdown Structure形式の図を出力
@startuml,@endumlの代わりに@startwbs, @endwbsを先頭と末尾に追加

mindmapでleft sideやright sideと指定すると、要素の左右方向を制御できる
（mind2puのみ。mind2dotではコメントアウトされる）

"*"マークを"-"に置換する（sed 's;\*;-;g'）と、
右から左方向に伸びるマップになる
これは-RightToLeftスイッチを指定した場合と等価。

塗りつぶし色は[#color]をラベルに前置または後置で指定できる。
たとえば、- [#red] label または- label [#red]

＊＊＊

PS> cat input.txt
# title 

- hogehoge
    - hoge1
        - [#orange] hoge2
        - hoge2 [#red]
        - hoge2_

    - hogepiyo
        - hoge2_
        - hoge2_
        - hoge2_

    - fugafuga
    - fuga1
        - fuga1-2
            - fuga2
    - fuga3_

cat input.txt | mind2pu
cat input.txt | mind2pu -o a.pu; pu2java a.pu | ii

## output -- plantUMLスクリプト
@startmindmap a

'title none
skinparam DefaultFontName "BIZ UDPGothic"
'skinparam monochrome true
'skinparam handwritten true

* hogehoge
** hoge1
***_ hoge2
***_ hoge2
***_ hoge2
** hogepiyo
***_ hoge2
***_ hoge2
***_ hoge2
** fugafuga
** fuga1
*** fuga1-2
**** fuga2
**_ fuga3

@endmindmap

.LINK
    pu2java, dot2gviz, pert, pert2dot, pert2gantt2pu, mind2dot, mind2pu, gantt2pu, logi2dot, logi2dot2, logi2dot3, logi2pu, logi2pu2, flow2pu

.PARAMETER OutputFile
出力するファイル名

.PARAMETER Title
図にタイトルを挿入する

.PARAMETER Scale
出力する図の大きさ
デフォルト=1.0

.PARAMETER Monochrome
白黒

.PARAMETER WBS
Work Breakdown Structure形式の出力

.PARAMETER HandWritten
手書き風

.PARAMETER FoldLabel
指定文字数で強制的に折り返し。
（指定文字数ごとに"\n"を挿入）

.PARAMETER FoldLabelOnlyPlainText
プレーンテキストのみ折り返し

.PARAMETER Kinsoku
禁則文字を考慮した
折り返し文字数の指定
半角1文字、全角2文字として数値を指定
kiosoku_function.ps1に依存

.PARAMETER KinsokuOnlyPlainText
禁則文字を考慮し
プレーンテキストのみ折り返し
半角1文字、全角2文字として数値を指定
kiosoku_function.ps1に依存

.PARAMETER LegendRight
右下に参考文献を挿入

.PARAMETER LegendLeft
左下に参考文献を挿入

.PARAMETER RightToLeft
左に向かって伸ばす

.EXAMPLE
PS> cat input.txt
# title

- hogehoge
    - hoge1
        - hoge2_
        - hoge2_
        - hoge2_

//comment

    - hogepiyo
        - hoge2_
        - hoge2_
        - hoge2_

    - fugafuga
    - fuga1
        - fuga1-2
            - fuga2
    - fuga3_

cat input.txt | mind2pu
cat input.txt | mind2pu -o a.pu; pu2java a.pu | ii

## output -- plantUMLスクリプト
@startmindmap a

'title none
skinparam DefaultFontName "BIZ UDPGothic"
'skinparam monochrome true
'skinparam handwritten true

* hogehoge
** hoge1
***_ hoge2
***_ hoge2
***_ hoge2
** hogepiyo
***_ hoge2
***_ hoge2
***_ hoge2
** fugafuga
** fuga1
*** fuga1-2
**** fuga2
**_ fuga3

@endmindmap

.EXAMPLE
cat wbs.md | mind2pu -WBS | Tee-Object -FilePath a.pu ; pu2java a.pu -OutputFileType svg | ii
# WBSの例

+ <&flag>社長
    + 業務本部
        + 総務部
            + SO
            + SO
            + SO
        + 営業部
            + EI
        + 物流
            + LOGI
    + 生産本部
        + 1st
            + A
            + P
            + S
        + 2nd
            + T
            + E
    + 研究所
        - ISO
        + LAB
            + LAB
            + QC
#>
function mind2pu {
    Param(
        [Parameter( Mandatory=$False)]
        [Alias('o')]
        [string]$OutputFile,

        [Parameter( Mandatory=$False)]
        [int]$Space = 4,

        [Parameter( Mandatory=$False)]
        [string]$Title,

        [Parameter( Mandatory=$False)]
        [double]$Scale,

        [Parameter( Mandatory=$False)]
        [switch]$Monochrome,

        [Parameter( Mandatory=$False)]
        [switch]$WBS,

        [Parameter( Mandatory=$False)]
        [switch]$HandWritten,

        [Parameter( Mandatory=$False)]
        [string]$FontName,

        [Parameter( Mandatory=$False)]
        [string]$FontNameWindowsDefault = "Meiryo",

        [Parameter( Mandatory=$False)]
        [ValidateSet(
            "none", "amiga", "aws-orange", "blueprint", "cerulean",
            "cerulean-outline", "crt-amber", "crt-green",
            "mars", "mimeograph", "plain", "sketchy", "sketchy-outline",
            "spacelab", "toy", "vibrant"
        )]
        [string]$Theme,

        [Parameter( Mandatory=$False)]
        [int]$FoldLabel,

        [Parameter( Mandatory=$False)]
        [int]$FoldLabelOnlyPlainText,

        [Parameter( Mandatory=$False)]
        [int]$Kinsoku,

        [Parameter( Mandatory=$False)]
        [int]$KinsokuOnlyPlainText,

        [Parameter( Mandatory=$False)]
        [string[]]$LegendRight,

        [Parameter( Mandatory=$False)]
        [string[]]$LegendLeft,

        [Parameter( Mandatory=$False)]
        [switch]$RightToLeft,

        [Parameter( Mandatory=$False,
            ValueFromPipeline=$True)]
        [string[]]$Text
    )

    begin{
        ## init var
        $lineCounter = 0
        $isFirstRowEqTitle = $false
        $isLegend = $false
        $readLineAry = @()
        $readLineAryNode = @()
        ## test and dot sourcing kinsoku command
        if ($Kinsoku){
            $scrPath = Join-Path $PSScriptRoot "kinsoku_function.ps1"
            if (-not (Test-Path -LiteralPath $scrPath)){
                Write-Error "kinsoku command could not found." -ErrorAction Stop
            }
            . $scrPath
        }
        ## private function
        function execKinsoku ([string]$str){
            ## splatting
            $KinsokuParams = @{
                Width = $Kinsoku
                Join = '\n'
            }
            $KinsokuParams.Set_Item('Expand', $true)
            $KinsokuParams.Set_Item('OffTrim', $true)
            $str = Write-Output "$str" | kinsoku @KinsokuParams
            return $str
        }
        if($RightToLeft){$repMark = '-'}
    }
    process{
        $lineCounter++
        $rdLine = [string]$_
        ## 一行目をタイトルとみなす場合
        if (($lineCounter -eq 1) -and ($rdLine -match '^# ')) {
            $fTitle = $rdLine -replace '^# ', ''
            $isFirstRowEqTitle = $true
        ## "+","-","*"で始まる行がターゲット
        } elseif (($rdLine -match '^\s*[-+*]+') -and (-not $isLegend)){
            ## set str
            $ast = $rdLine -replace '^(\s*)([-+*]+).*$','$1'
            if($WBS){
                $repMark = $rdLine -replace '^(\s*)([-+*]+).*$','$2'
            } else {
                $repMark = '*'
            }
            ## 先頭の空白の処理
            $ast += $repMark
            $ast = $ast -replace (' ' * $Space),"$repMark"
            $contents = $rdLine -replace '^\s*[-+*]+\s*(.*)$','$1'
            if ($contents -match '^\[#'){
                ## 色指定がある場合（前置） - [#orange] contents
                $colorName = $contents -replace '^(\[#[^\]]+\])(..*)$','$1'
                $contents  = $contents -replace '^(\[#[^\]]+\])(..*)$','$2'
                $ast = $ast + $colorName.Trim()
            }elseif ($contents -match '\[#[^\]]+]$'){
                ## 色指定がある場合（後置） - contents [#orange]
                $colorName = $contents -replace '^(..*)(\[#[^\]]+\])$','$2'
                $contents  = $contents -replace '^(..*)(\[#[^\]]+\])$','$1'
                $ast = $ast + $colorName.Trim()
            }
            $contents = $contents.Trim()
            ## 文末にアンダースコアで枠なし文字列
            $plainTextFlag = $False
            if ($contents -match '_$'){
                $plainTextFlag = $True
                $ast = $ast -replace '$','_ '
                $contents = $contents -replace '_$',''
            } else {
                $ast = $ast -replace '$',' '
            }
            ## コンテンツを指定文字数で折り返し
            if (($FoldLabelOnlyPlainText) -and ($plainTextFlag)) {
                $regStr = '('
                $regStr += '.' * $FoldLabelOnlyPlainText
                $regStr += ')'
                $reg = [regex]$regStr
                $contents = $contents -Replace $reg,'$1\n'
                $contents = $contents -Replace '\\n$',''
                $contents = $contents -Replace '$','\n'
            } elseif ($FoldLabel) {
                $regStr = '('
                $regStr += '.' * $FoldLabel
                $regStr += ')'
                $reg = [regex]$regStr
                $contents = $contents -Replace $reg,'$1\n'
                $contents = $contents -Replace '\\n$',''
                $contents = $contents -Replace '$','\n'
            }
            ## 値の折り返し（禁則処理あり）
            if (($KinsokuOnlyPlainText) -and ($plainTextFlag)) {
                $contents = execKinsoku $contents
            } elseif ($Kinsoku) {
                $contents = execKinsoku $contents
            }
            ## ノードのセット
            $readLineAryNode += $ast + $contents
        } else {
            ## それ以外はそのまま出力
            $readLineAryNode += $rdLine
            ## 参考文献か？
            if (($lineCounter -gt 1) -and ($rdLine -match '^legend (right|left)$')){
                $isLegend = $true
            }
        }
    }
    end {
        ##
        ## Header
        ##
        $readLineAryHeader = @()
        if ($WBS) {
            $readLineAryHeader += "@startwbs"
            $readLineAryHeader += ""
        } else {
            $readLineAryHeader += "@startmindmap"
            $readLineAryHeader += ""
        }
        if ($Title){
            $readLineAryHeader += "title $Title"
        } elseif ($isFirstRowEqTitle) {
            $readLineAryHeader += "title $fTitle"
        } else {
            $readLineAryHeader += "'title none"
        }
        if ($Scale){
            $readLineAryHeader += "scale $Scale"
        }
        if($IsWindows){
            ## case  windows
            if($FontName){
                $readLineAryHeader += "skinparam DefaultFontName ""$FontName"""
            } else {
                $readLineAryHeader += "skinparam DefaultFontName ""$FontNameWindowsDefault"""
            }
        } else {
            ## case linux and mac
            if($FontName){
                $readLineAryHeader += "skinparam DefaultFontName ""$FontName"""
            }
        }
        if ($Monochrome){
            $readLineAryHeader += "skinparam monochrome true"
        }
        if ($HandWritten) {
            $readLineAryHeader += "skinparam handwritten true"
        }
        if ($Theme) {
            $readLineAryHeader += "!theme $Theme"
        }
        $readLineAryHeader += ""
        ##
        ## Footer
        ##
        if($LegendLeft){
            $legendFlag = $True
            $readLineAryLegend = @()
            $readLineAryLegend += ""
            $readLineAryLegend += "legend left"
            foreach($legLine in $LegendLeft){
                $readLineAryLegend += $legLine
            }
            $readLineAryLegend += "end legend"
        }elseif($LegendRight){
            $legendFlag = $True
            $readLineAryLegend = @()
            $readLineAryLegend += ""
            $readLineAryLegend += "legend right"
            foreach($legLine in $LegendRight){
                $readLineAryLegend += $legLine
            }
            $readLineAryLegend += "end legend"
        }else{
            $legendFlag = $False
        }

        $readLineAryFooter = @()
        $readLineAryFooter += ""
        if ($WBS) {
            $readLineAryFooter += "@endwbs"
        } else {
            $readLineAryFooter += "@endmindmap"
        }
        ## output
        foreach ($lin in $readLineAryHeader){
            $readLineAry += $lin
        }
        foreach ($lin in $readLineAryNode){
            $readLineAry += $lin
        }
        if($legendFlag){
            foreach ($lin in $readLineAryLegend){
                $readLineAry += $lin
            }
        }
        foreach ($lin in $readLineAryFooter){
            $readLineAry += $lin
        }
        if($OutputFile){
            if($IsWindows){
                ## BOMなしUTF-8(CRLF)形式で保存
                $readLineAry -Join "`r`n" `
                    | Out-File "$OutputFile" -Encoding UTF8
            } else {
                ## BOMなしUTF-8(LF)形式で保存
                $readLineAry -Join "`n" `
                    | Out-File "$OutputFile" -Encoding UTF8
            }
            Get-Item $OutputFile
        }else{
            ## 標準出力
            foreach($rdStr in $readLineAry){
                Write-Output $rdStr
            }
        }
    }
}
