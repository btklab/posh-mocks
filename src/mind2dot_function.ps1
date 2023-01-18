<#
.SYNOPSIS

mind2dot - Generate graphviz script to draw a mind map from list data in markdown format

markdown形式のリストデータからマインドマップを描画するgraphvizスクリプトを生成する

マークダウンのリスト形式で記述された階層構造をマインドマップ化する。
入力データは「半角スペース4つ」に「ハイフン」で階層構造を表す
文末にアンダースコア「_」を入れると、枠なし文字列になる
-Space 2 とすると、ハイフンの前の半角スペースは2つとして認識する

空行は無視する、
「//」で始まる行はコメントとみなして無視する
改行は\nでセンタリング、\lで左寄せ、\rで右寄せ

一行目かつ「# 」で始まる場合は、タイトルとみなす。
-FirstNodeShapeオプションで、最初のノードの形状を指定できる

波かっこ{.*}で始まり、終わる行はオプションとみなす。
    {rank=same; ID0001,ID0002}などの制御を追加できる。

以下のように書けば参考文献を出力できる。

    legend right|left
    参考文献
    end legend

塗りつぶし色は[#color]をラベルに前置または後置で指定できる。
たとえば、- [#red] label または- label [#red]

-SolarizedDark, -SolarizedLightスイッチで
Solarizedカラースキーマを適用する

CREDIT:
 Solarized color palette from:
    - https://github.com/altercation/solarized
    - http://ethanschoonover.com/solarized
    - License: MIT License Copyright (c) 2011 Ethan Schoonover

＊＊＊

PS> cat input.txt
# title

- hogehoge
    - hoge1
        - [#red] hoge2
        - hoge3 [#red]
        - hoge4_

    - hogepiyo
        - hoge2_
        - hoge2_
        - hoge2_

    - fugafuga
    - fuga1
        - fuga1-2
            - fuga2
    - fuga3_

{rank=same; "[問題]",ID0001}
{rank=same; "[対策案]",ID0002,ID0004}
{rank=same; "[懸念点]",ID0003,ID0005}

cat input.txt | mind2dot
cat input.txt | mind2dot -o a.dot; dot2gviz a.dot png | ii

## output -- GraphViz用dot（一部抜粋）
  // set node
"ID0001" [label="hogehoge", shape="box"];
"ID0002" [label="hoge1", shape="box"];
"ID0003" [label="hoge2", shape="plaintext"];
"ID0004" [label="hoge2", shape="plaintext"];
"ID0005" [label="hoge2", shape="plaintext"];
"ID0006" [label="hogepiyo", shape="box"];
"ID0007" [label="hoge2", shape="plaintext"];
"ID0008" [label="hoge2", shape="plaintext"];
"ID0009" [label="hoge2", shape="plaintext"];
"ID0010" [label="fugafuga", shape="box"];
"ID0011" [label="fuga1", shape="box"];
"ID0012" [label="fuga1-2", shape="box"];
"ID0013" [label="fuga2", shape="box"];
"ID0014" [label="fuga3", shape="plaintext"];

 // set edge
"ID0001" -> "ID0002" [style="solid"];
"ID0002" -> "ID0003" [style="solid"];
"ID0002" -> "ID0004" [style="solid"];
"ID0002" -> "ID0005" [style="solid"];
"ID0001" -> "ID0006" [style="solid"];
"ID0006" -> "ID0007" [style="solid"];
"ID0006" -> "ID0008" [style="solid"];
"ID0006" -> "ID0009" [style="solid"];
"ID0001" -> "ID0010" [style="solid"];
"ID0001" -> "ID0011" [style="solid"];
"ID0011" -> "ID0012" [style="solid"];
"ID0012" -> "ID0013" [style="solid"];
"ID0001" -> "ID0014" [style="solid"];

// set option
{rank=same; "[問題]",ID0001}
{rank=same; "[対策案]",ID0002,ID0004}
{rank=same; "[懸念点]",ID0003,ID0005}


.LINK
    pu2java, dot2gviz, pert, pert2dot, pert2gantt2pu, mind2dot, mind2pu, gantt2pu, logi2dot, logi2dot2, logi2dot3, logi2pu, logi2pu2, flow2pu


.PARAMETER OutputFile
出力するファイル名

.PARAMETER GraphType
グラフのタイプ。
  graph (default)
  digraph
  strict graph
  strict digraph

.PARAMETER LeftToRight
左→右に流れるように変える
デフォルトで上→下

.PARAMETER ReverseEdge
矢印の向きを反対向きにする

.PARAMETER DotFile
追加設定の書かれたdotファイルを読み込み

.PARAMETER NodeShape
Nodeの形状を指定。
デフォルトで"ellipse"（楕円）

.PARAMETER FirstNodeShape
最初のNodeの形状を指定。
デフォルトで"ellipse"（楕円）

.PARAMETER OffRounded
Nodeの角を丸くするのを解除。

.PARAMETER Title
図にタイトルを挿入する

.PARAMETER FontName
フォント名を指定。
デフォルトで"Meiryo"

.PARAMETER FoldLabel
指定文字数で強制的に折り返し。
（指定文字数ごとに"\l"を挿入）

.PARAMETER Kinsoku
禁則文字を考慮した
折り返し文字数の指定
半角1文字、全角2文字として数値を指定
kiosoku_function.ps1に依存

.PARAMETER SkipTop

kinsokuフィルタで、
文字数カウントをスキップする行頭文字をセット。
デフォルトで色指定をスキップ：

 SkipTop = '\[#[^]]+\] '


.PARAMETER LegendFontSize
凡例のフォントサイズを指定。
デフォルトで11

.EXAMPLE
cat a.md
# What flavor would you like?

- Flavors
    - Chocolate
        - Ice cream_
        - Cake_
    - Strawberry
        - Ice cream_
        - Cake_
    - Vanilla
        - Ice cream_
        - Cake_

legend right
this is legend
end legend

cat a.md | mind2dot
graph mindmap {
 // graph settings
 graph [
  charset = "UTF-8";
  fontname = "Meiryo";
  label = "What flavor would you like?\n\n";
  labelloc = "t";
  labeljust = "c";
  layout = "dot";
  rankdir = "LR";
  newrank = true;
  overlap = "false";
 ];
 // node settings
 node [
  fontname = "Meiryo";
  shape = "plaintext";
  style = "rounded";
 ];
 // edge settings
 edge [
  fontname = "Meiryo";
 ];

 subgraph cluster_legend {


 // set node
"ID0001" [label="Flavors", shape="box" ];
"ID0002" [label="Chocolate", shape="box" ];
"ID0003" [label="Ice cream", shape="plaintext" ];
"ID0004" [label="Cake", shape="plaintext" ];
"ID0005" [label="Strawberry", shape="box" ];
"ID0006" [label="Ice cream", shape="plaintext" ];
"ID0007" [label="Cake", shape="plaintext" ];
"ID0008" [label="Vanilla", shape="box" ];
"ID0009" [label="Ice cream", shape="plaintext" ];
"ID0010" [label="Cake", shape="plaintext" ];

 // set edge
"ID0001" -- "ID0002" [style="solid"];
"ID0002" -- "ID0003" [style="solid"];
"ID0002" -- "ID0004" [style="solid"];
"ID0001" -- "ID0005" [style="solid"];
"ID0005" -- "ID0006" [style="solid"];
"ID0005" -- "ID0007" [style="solid"];
"ID0001" -- "ID0008" [style="solid"];
"ID0008" -- "ID0009" [style="solid"];
"ID0008" -- "ID0010" [style="solid"];

 // set option

 graph [
   labelloc="b";
   labeljust="r";
   color="white";
   label=<
   <TABLE
       BORDER="1"
       CELLBORDER="0"
       COLOR="gray15"
       BGCOLOR="grey95"
   >
   <TR><TD ALIGN="LEFT"><FONT COLOR="gray15" POINT-SIZE="11">this is legend</FONT></TD></TR>
   </TABLE>>;
 ];

 };

}

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

// set option
{rank=same; "[問題]",ID0001}
{rank=same; "[対策案]",ID0002,ID0004}
{rank=same; "[懸念点]",ID0003,ID0005}


cat input.txt | mind2dot
cat input.txt | mind2dot -o a.dot; dot2gviz a.dot png | ii

## output -- GraphViz用dot（一部抜粋）
  // set node
"ID0001" [label="hogehoge", shape="box"];
"ID0002" [label="hoge1", shape="box"];
"ID0003" [label="hoge2", shape="plaintext"];
"ID0004" [label="hoge2", shape="plaintext"];
"ID0005" [label="hoge2", shape="plaintext"];
"ID0006" [label="hogepiyo", shape="box"];
"ID0007" [label="hoge2", shape="plaintext"];
"ID0008" [label="hoge2", shape="plaintext"];
"ID0009" [label="hoge2", shape="plaintext"];
"ID0010" [label="fugafuga", shape="box"];
"ID0011" [label="fuga1", shape="box"];
"ID0012" [label="fuga1-2", shape="box"];
"ID0013" [label="fuga2", shape="box"];
"ID0014" [label="fuga3", shape="plaintext"];

 // set edge
"ID0001" -> "ID0002" [style="solid"];
"ID0002" -> "ID0003" [style="solid"];
"ID0002" -> "ID0004" [style="solid"];
"ID0002" -> "ID0005" [style="solid"];
"ID0001" -> "ID0006" [style="solid"];
"ID0006" -> "ID0007" [style="solid"];
"ID0006" -> "ID0008" [style="solid"];
"ID0006" -> "ID0009" [style="solid"];
"ID0001" -> "ID0010" [style="solid"];
"ID0001" -> "ID0011" [style="solid"];
"ID0011" -> "ID0012" [style="solid"];
"ID0012" -> "ID0013" [style="solid"];
"ID0001" -> "ID0014" [style="solid"];

// set option
{rank=same; "[問題]",ID0001}
{rank=same; "[対策案]",ID0002,ID0004}
{rank=same; "[懸念点]",ID0003,ID0005}

.EXAMPLE
cat a.md | mind2dot -LayoutEngine twopi > a.dot; dot2gviz a.dot svg | ii

説明
============
-LayoutEngine twopiで、上下左右方向に広がるマインドマップになる。
デフォルトのdotは、上下または左右方向のみ。


#>
function mind2dot {
    Param(
        [Parameter( Mandatory=$False)]
        [Alias('o')]
        [string]$OutputFile,

        [Parameter( Mandatory=$False)]
        [int]$Space = 4,

        [Parameter( Mandatory=$False)]
        [ValidateSet(
            "digraph", "graph",
            "strict graph", "strict digraph")]
        [string]$GraphType = "graph",

        [Parameter( Mandatory=$False)]
        [switch]$TopToBottom,

        [Parameter( Mandatory=$False)]
        [Alias('r')]
        [switch]$ReverseEdge,

        [Parameter( Mandatory=$False)]
        [Alias('f')]
        [string]$DotFile,

        [Parameter( Mandatory=$False)]
        [ValidateSet(
            "Default", "record",
            "box","polygon","ellipse","oval",
            "circle","point","egg","triangle",
            "plaintext","plain","diamond","trapezium",
            "parallelogram","house","pentagon","hexagon",
            "septagon","octagon","doublecircle","doubleoctagon",
            "tripleoctagon","invtriangle","invtrapezium","invhouse",
            "Mdiamond","Msquare","Mcircle","rect",
            "rectangle","square","star","none",
            "underline","cylinder","note","tab",
            "folder","box3d","component","promoter",
            "cds","terminator","utr","primersite",
            "restrictionsite","fivepoverhang","threepoverhang","noverhang",
            "assembly","signature","insulator","ribosite",
            "rnastab","proteasesite","proteinstab","rpromoter",
            "rarrow","larrow","lpromoter")]
        [string]$NodeShape = 'box',

        [Parameter( Mandatory=$False)]
        [string]$NodeFillColor,

        [Parameter( Mandatory=$False)]
        [ValidateSet(
            "Default", "record",
            "box","polygon","ellipse","oval",
            "circle","point","egg","triangle",
            "plaintext","plain","diamond","trapezium",
            "parallelogram","house","pentagon","hexagon",
            "septagon","octagon","doublecircle","doubleoctagon",
            "tripleoctagon","invtriangle","invtrapezium","invhouse",
            "Mdiamond","Msquare","Mcircle","rect",
            "rectangle","square","star","none",
            "underline","cylinder","note","tab",
            "folder","box3d","component","promoter",
            "cds","terminator","utr","primersite",
            "restrictionsite","fivepoverhang","threepoverhang","noverhang",
            "assembly","signature","insulator","ribosite",
            "rnastab","proteasesite","proteinstab","rpromoter",
            "rarrow","larrow","lpromoter")]
        [string]$FirstNodeShape,

        [Parameter( Mandatory=$False)]
        [string]$FirstNodeFillColor,

        [Parameter( Mandatory=$False)]
        [switch]$OffRounded,

        [Parameter( Mandatory=$False)]
        [string]$Title,

        [Parameter( Mandatory=$False)]
        [ValidateSet( "t","b","l","r")]
        [string]$TitleLoc = "t",

        [Parameter( Mandatory=$False)]
        [ValidateSet( "l","r","c")]
        [string]$TitleJust = "c",

        [Parameter( Mandatory=$False)]
        [string]$FontName,

        [Parameter( Mandatory=$False)]
        [string]$FontNameWindowsDefault = "Meiryo",

        [Parameter( Mandatory=$False)]
        [double]$FontSize,

        [Parameter( Mandatory=$False)]
        [string]$FontColor,

        [Parameter( Mandatory=$False)]
        [int]$FoldLabel,

        [Parameter( Mandatory=$False)]
        [int]$Kinsoku,

        [Parameter( Mandatory=$False)]
        [ValidateSet(
            "circo", "dot", "fdp", "neato",
            "osage", "sfdp", "twopi", "patchwork")]
        [string] $LayoutEngine = "dot",

        [Parameter( Mandatory=$False)]
        [string]$Delimiter = ' ',

        [Parameter( Mandatory=$False)]
        [int]$LegendFontSize = 11,

        [Parameter( Mandatory=$False)]
        [switch]$SolarizedDark,

        [Parameter( Mandatory=$False)]
        [switch]$SolarizedLight,

        [Parameter( Mandatory=$False)]
        [int]$PenWidth,

        [Parameter( Mandatory=$False)]
        [string]$SkipTop = '\[#[^]]+\]\s*',

        [Parameter( Mandatory=$False,
            ValueFromPipeline=$True)]
        [string[]]$Text
    )

    begin{
        ## init var
        $lineCounter = 0
        $isFirstRowEqTitle = $false
        $isLegend = $false
        $isLegendLeft = $false
        $isLegendRight = $false
        $idCounter = 0
        $newItemLevel = 0
        $oldItemLevel = -1
        $readLineAry = @()
        $readLineAryNode = @()
        $readLineAryNode += ''
        $readLineAryNode += ' // set node'
        $readLineAryEdge = @()
        $readLineAryEdge += ''
        $readLineAryEdge += ' // set edge'
        $readLineAryOpt = @()
        $readLineAryOpt += ''
        $readLineAryOpt += ' // set option'
        # Solarized color palette from
        # https://github.com/altercation/solarized
        # http://ethanschoonover.com/solarized
        # License: MIT License Copyright (c) 2011 Ethan Schoonover
        [string] $colDarkGrayBlue = '#002b36'
        [string] $colYellow       = '#b58900'
        [string] $colOrange       = '#cb4b16'
        [string] $colViolet       = '#6c71c4'
        [string] $colRed          = '#dc322f'
        [string] $colBlue         = '#268bd2'
        [string] $colMagenta      = '#d33682'
        [string] $colCyan         = '#2aa198'
        [string] $colGreen        = '#859900'
        [string] $colGray         = '#939393'
        [string] $colSolWhite     = '#fdf6e3'
        [string] $colSolBlack     = '#073642'
        [string] $colWhite        = '#ffffff'
        [string] $colBlack        = '#000000'
        ## Set color scheme
        if ($SolarizedDark -or $SolarizedLight){
            [bool] $schemeFlag = $True
        } else {
            [bool] $schemeFlag = $False
        }
        [int] $numberOfColors = 10
        if ($SolarizedDark){
            [string] $bgColor   = $colDarkGrayBlue
            [string] $txtColor  = $colSolWhite
            [string] $initColor = $colSolWhite
        } elseif ($SolarizedLight){
            [string] $bgColor   = $colSolWhite
            [string] $txtColor  = $colSolBlack
            [string] $initColor = $colSolBlack
        } else {
            [string] $bgColor = ""
            [string] $txtColor = ""
        }
        [string[]] $colorSolarized = @(
            $initColor,
            $colOrange,
            $colBlue,
            $colGreen,
            $colMagenta,
            $colViolet,
            $colYellow,
            $colRed,
            $colCyan,
            $colGray
        )
        if ($FontColor){
            [string] $txtColor = $FontColor
        }
        ## define private functions
        function getItemLevel ([string]$rdLine){
            $whiteSpaces = $rdLine -replace '^(\s*)[-*]','$1'
            $whiteSpaceLength = $whiteSpace.Length
            $itemLevel = [math]::Floor($whiteSpaceLength / $Space)
            return $itemLevel
        }
        function setNodeStr ([string]$nodeId, [string]$nodeLabel, [bool]$plainTextFlag, [int]$scColNum){
            ## 色指定がある場合
            [string]$colorName = ''
            if ($nodeLabel -match '^\[#'){
                ## 色指定がある場合（前置） - [#orange] contents
                $colorName = $nodeLabel -replace '^\[#([^\]]+)\](..*)$','$1'
                $colorName = $colorName.Trim()
                $nodeLabel = $nodeLabel -replace '^\[#([^\]]+)\](..*)$','$2'
                $nodeLabel = $nodeLabel.Trim()
            }elseif ($nodeLabel -match '\[#[^\]]+]$'){
                ## 色指定がある場合（後置） - contents [#orange]
                $colorName = $nodeLabel -replace '^(..*)\[#([^\]]+)\]$','$2'
                $colorName = $colorName.Trim()
                $nodeLabel = $nodeLabel -replace '^(..*)\[#([^\]]+)\]$','$1'
                $nodeLabel = $nodeLabel.Trim()
            }
            ## "E" [label="肉を切る", shape="box"];
            [string] $nodeId    = """$nodeId"""
            [string] $nodeLabel = """$nodeLabel"""
            if ($plainTextFlag){
                $nShape = '"plaintext"'
            } elseif (($FirstNodeShape) -and ($nodeID -eq '"ID0001"')){
                $nShape = """$FirstNodeShape"""
            } else {
                $nShape = """$NodeShape"""
            }
            if($OffRounded){
                $nStyleOpt = ", style=""filled"""
            }else{
                $nStyleOpt = ", style=""filled, rounded"""
            }
            if ($colorName -ne ''){
                $fillColorOpt = "$nStyleOpt, fillcolor=""$colorName"""
            }elseif (($FirstNodeFillColor) -and ($nodeID -eq '"ID0001"')){
                $fillColorOpt = "$nStyleOpt, fillcolor=""$FirstNodeFillColor"""
            } else {
                $fillColorOpt = ''
            }
            if ($scColNum -gt -1){
                ## set color scheme
                $fillColorOpt += ", color=""$($colorSolarized[$scColNum])"""
            }
            return "$nodeId [label=$nodeLabel, shape=$nShape $fillColorOpt];"
        }
        function setEdgeStr ([string]$leftId, [string]$rightId, [int]$scColNum){
            ## "A" -> "B" [style="solid"];
            [string] $leftId  = """$leftId"""
            [string] $rightId = """$rightId"""
            [string] $opts = 'style="solid"'
            if ($scColNum -gt -1){
                ## set color scheme
                $opts += ", color=""$($colorSolarized[$scColNum])"""
            }
            if($GraphType -match 'digraph'){
                return "$leftId -> $rightId [$($opts)];"
            }else{
                return "$leftId -- $rightId [$($opts)];"
            }
        }
        ## test and dot sourcing kinsoku command
        if ($Kinsoku){
            $scrPath = Join-Path $PSScriptRoot "kinsoku_function.ps1"
            if (-not (Test-Path -LiteralPath $scrPath)){
                Write-Error "kinsoku command could not found." -ErrorAction Stop
            }
            . $scrPath
        }
        function execKinsoku ([string]$str){
            ## splatting
            $KinsokuParams = @{
                Width = $Kinsoku
                Join = '\n'
                SkipTop = "$SkipTop"
            }
            $KinsokuParams.Set_Item('Expand', $true)
            $KinsokuParams.Set_Item('OffTrim', $true)
            ## 入力文字列・デリミタはクオーティングで安全にくるむこと
            $str = Write-Output "$str" | kinsoku @KinsokuParams
            $str = $str + '\n'
            return $str
        }
        ##
        ## Stack & Queue functions
        ##
        $psStackAry = [string[]]@() ## スタック配列
        $psStackMaxSize = 10  ## スタック配列の最大サイズ（10階層まで）
        $psStackTop = 0       ## スタック配列の先頭を表すポインタ
        function stackInit {
            $psStackTop = 0
            $psStackAry = [string[]]@()
            1..$psStackMaxSize | %{ $psStackAry += "-"}
            return $psStackTop, $psStackAry
        }
        function isStackEmpty {
            return $psStackTop -eq 0
        }
        function isStackFull {
            return $psStackTop -eq $psStackMaxSize
        }
        function psStackPush ([string]$val) {
            # push (top を進めて要素を格納)
            if (isStackFull){throw "error: stack is full."}
            $psStackAry[$psStackTop] = $val
            $psStackTop++
            return $psStackTop, $psStackAry
        }
        function psStackPop {
            # pop (top をデクリメントして、top の位置にある要素を返す)
            if (isStackEmpty){throw "error: stack is empty."}
            $psStackTop--
            $ret = $psStackAry[$psStackTop]
            return $psStackTop, $ret
        }
        function psStackGetVal {
            # topを増減せずに、topの位置にある要素を返す
            return $psStackAry[$psStackTop-1]
        }
        ## init stack
        $psStackTop, $psStackAry = stackInit
    }
    process{
        $lineCounter++
        $plainTextFlag = $False
        $rdLine = [string]$_
        ## ignore
        if ($rdLine -match '^\s*left side$') {$rdLine = '//' + $rdLine}
        if ($rdLine -match '^\s*right side$'){$rdLine = '//' + $rdLine}
        ## 一行目をタイトルとみなす場合
        if (($lineCounter -eq 1) -and ($rdLine -match '^# ')) {
            $fTitle = $rdLine -replace '^# ', ''
            $fTitle = $fTitle + '\n\n'
            $isFirstRowEqTitle = $true
        }
        ## ハイフンもしくはアスタリスクで始まる行がターゲット
        if (($rdLine -match '^\s*\-|^\s*\*') -and (-not $isLegend)){
            ## set node id
            $idCounter++
            $newNodeId = "ID" + $idCounter.Tostring("0000")
            ## set str
            $whiteSpace = $rdLine -replace '^(\s*)[-*].*$','$1'
            $contents   = $rdLine -replace '^\s*[-*]\s*(.*)$','$1'
            ## 文末にアンダースコアで枠なし文字列
            if ($contents -match '_$'){
                $plainTextFlag = $True
                $contents = $contents -replace '_$',''
            }
            ## コンテンツを指定文字数で折り返し
            if($FoldLabel){
                $regStr = '('
                $regStr += '.' * $FoldLabel
                $regStr += ')'
                $reg = [regex]$regStr
                $contents = $contents -Replace $reg,'$1\l'
                $contents = $contents -Replace '\\l$',''
                $contents = $contents + '\l'
            }
            ## 値の折り返し（禁則処理あり）
            if ($Kinsoku) {
                $contents = execKinsoku $contents
            }
            ## 階層の変化に応じてノードIDをスタック（push & pop）
            $newItemLevel = getItemLevel "$rdLine"
            ## カラースキーマのセット
            if ($schemeFlag){
                if ($newItemLevel -eq 0){
                    [int] $colorIndex = 0
                    [int] $colorNum = 0
                } elseif ($newItemLevel -eq 1){
                    $colorIndex++
                    $colorNum = $colorIndex % $numberOfColors
                }
            } else {
                [int] $colorNum = -1
            }
            if ($idCounter -eq 1){
                ## 1行目のデータ
                $readLineAryNode += setNodeStr $newNodeId $contents $plainTextFlag $colorNum
                $parentId = 'None'
            } else {
                ## 2行目以降のデータ
                if ($newItemLevel -eq $oldItemLevel){
                    ## 階層変化なし: pushもpopもしない
                    $readLineAryNode += setNodeStr $newNodeId $contents $plainTextFlag $colorNum
                    if ($parentId -ne 'None'){
                        $readLineAryEdge += setEdgeStr $parentId $newNodeId $colorNum
                    }

                } elseif ($newItemLevel -eq $oldItemLevel + 1){
                    ## 一つ深い階層へ移動: push
                    $readLineAryNode += setNodeStr $newNodeId $contents $plainTextFlag $colorNum
                    $parentId = $oldNodeId
                    $psStackTop, $psStackAry = psStackPush $parentId ## スタックに親IDをpush
                    $readLineAryEdge += setEdgeStr $parentId $newNodeId $colorNum

                } elseif ($newItemLevel -gt $oldItemLevel + 1){
                    #Write-Output "$oldItemLevel, $newItemLevel"
                    throw "error: 階層レベルが2つ以上一気に深くなりました: $rdLine"

                } elseif ($newItemLevel -lt $oldItemLevel){
                    ## 階層が浅くなった: pop
                    $readLineAryNode += setNodeStr $newNodeId $contents $plainTextFlag $colorNum
                    ## 浅くなった階層レベル分の回数だけpop
                    $diffLevel = $oldItemLevel - $newItemLevel
                    for ($i = 1; $i -le $diffLevel; $i++){
                        $psStackTop, $ret = psStackPop
                    }
                    #Write-Output "$psStackAry"
                    if (!(isStackEmpty)){
                        $parentId = psStackGetVal
                        $readLineAryEdge += setEdgeStr $parentId $newNodeId $colorNum
                    }

                } else {
                    throw "error: 不明なエラー。階層検知できず: $rdLine "
                }
            }
            $oldItemLevel = $newItemLevel
            $oldNodeId = $newNodeId
        }
        $plainTextFlag = $False
        ## オプション文字列の取得（"{"始まりの行）
        if ($rdLine -match '^\{..*\}$'){
            $readLineAryOpt += $rdLine }
        ## legend文字列の取得
        if (($isLegend) -and ($rdLine -match '^end *legend$')){
            $isLegend = $false
        }
        if ($isLegend){
            $readLineAryLeg += $rdLine
        }
        if (($lineCounter -gt 1) -and ($rdLine -match '^legend right$')){
            $readLineAryLeg = @()
            $isLegendRight = $true
            $isLegend = $true
        }
        if (($lineCounter -gt 1) -and ($rdLine -match '^legend left$')){
            $readLineAryLeg = @()
            $isLegendLeft = $true
            $isLegend = $true
        }
    }
    end {
        ##
        ## Header
        ##
        $readLineAryHeader = @()
        $readLineAryHeader += "$GraphType mindmap {"
        #$readLineAryHeader += "strict digraph logicktree {"
        $readLineAryHeader += ' // graph settings'
        $readLineAryHeader += ' graph ['
        $readLineAryHeader += '  charset = "UTF-8";'
        if($IsWindows){
            ## case  windows
            if($FontName){
                $readLineAryHeader += "  fontname = ""$FontName"";"
            } else {
                $readLineAryHeader += '  fontname = "' + $FontNameWindowsDefault + '";'
            }
        } else {
            ## case linux and mac
            if($FontName){
                $readLineAryHeader += '  fontname = "' + $FontName + '";'
            }
        }
        if($FontSize){
            $readLineAryHeader += "  fontsize = $FontSize;"
        }
        if ($Title){
            $TitleStr = $Title + '\n\n'
            $readLineAryHeader += "  label = ""$TitleStr"";"
            $readLineAryHeader += "  labelloc = ""$TitleLoc"";"
            $readLineAryHeader += "  labeljust = ""$TitleJust"";"
        } elseif ($isFirstRowEqTitle) {
            $readLineAryHeader += "  label = ""$fTitle"";"
            $readLineAryHeader += "  labelloc = ""$TitleLoc"";"
            $readLineAryHeader += "  labeljust = ""$TitleJust"";"
        }
        $readLineAryHeader += "  layout = ""$LayoutEngine"";"
        if($TopToBottom){
            $readLineAryHeader += '  rankdir = "TB";'
        } else {
            $readLineAryHeader += '  rankdir = "LR";'
        }
        $readLineAryHeader += '  newrank = true;'
        $readLineAryHeader += '  overlap = "false";'
        if($LayoutEngine -eq 'twopi'){
            $readLineAryHeader += '  dir = "None";'
        }
        if ($schemeFlag){
            ## color scheme settings
            $readLineAryHeader += ''
            if($SolarizedDark){
                $readLineAryHeader += "  bgcolor = ""$bgColor"";"
                $readLineAryHeader += "  fontcolor = ""$txtColor"";"
            }
            if($SolarizedLight){
                $readLineAryHeader += "  bgcolor = ""$bgColor"";"
                $readLineAryHeader += "  fontcolor = ""$txtColor"";"
            }
        }
        $readLineAryHeader += ' ];'
        ## node settings #################################
        $readLineAryHeader += ' // node settings'
        $readLineAryHeader += ' node ['
        if($IsWindows){
            ## case  windows
            if($FontName){
                $readLineAryHeader += "  fontname = ""$FontName"";"
            } else {
                $readLineAryHeader += '  fontname = "' + $FontNameWindowsDefault + '";'
            }
        } else {
            ## case linux and mac
            if($FontName){
                $readLineAryHeader += '  fontname = "' + $FontName + '";'
            }
        }
        if($FontSize){
            $readLineAryHeader += "  fontsize = $FontSize;"
        }
        $readLineAryHeader += "  shape = ""plaintext"";"
        if ((-not $OffRounded) -and ($NodeFillColor)){
            $readLineAryHeader += '  style = "rounded, filled";'
            $readLineAryHeader += "  fillcolor = ""$NodeFillColor"";"
        } elseif (-not $OffRounded){
            $readLineAryHeader += '  style = "rounded";'
        } elseif ($NodeFillColor){
            $readLineAryHeader += '  style = "filled";'
            $readLineAryHeader += "  fillcolor = ""$NodeFillColor"";"
        }
        ## color scheme settings
        if ($SolarizedDark){
            $readLineAryHeader += "  fontcolor = ""$colSolWhite"" ;"
        }
        if ($SolarizedLight){
            $readLineAryHeader += "  fontcolor = ""$colSolBlack"" ;"
        }
        if ($PenWidth){
            $readLineAryHeader += "  penwidth = $PenWidth ;"
        } elseif ($schemeFlag){
            $readLineAryHeader += "  penwidth = 2;"
        }
        $readLineAryHeader += ' ];'
        ## edge settings #################################
        $readLineAryHeader += ' // edge settings'
        $readLineAryHeader += ' edge ['
        if($IsWindows){
            ## case  windows
            if($FontName){
                $readLineAryHeader += "  fontname = ""$FontName"";"
            } else {
                $readLineAryHeader += '  fontname = "' + $FontNameWindowsDefault + '";'
            }
        } else {
            ## case linux and mac
            if($FontName){
                $readLineAryHeader += '  fontname = "' + $FontName + '";'
            }
        }
        if($FontSize){
            $readLineAryHeader += "  fontsize = $FontSize;"
        }
        if($GraphType -match 'digraph'){
            if($ReverseEdge){
                $readLineAryHeader += "  dir = ""back"";"
            } else {
                $readLineAryHeader += "  dir = ""forward"";"
            }
        }
        ## color scheme settings
        if ($PenWidth){
            $readLineAryHeader += "  penwidth = $PenWidth ;"
        } elseif ($schemeFlag){
            $readLineAryHeader += "  penwidth = 2;"
        }
        $readLineAryHeader += ' ];'
        ##
        ## Footer
        ##
        $readLineAryFooter = @()
        $readLineAryFooter += '}'
        foreach ($lin in $readLineAryHeader){
            $readLineAry += $lin
        }

        # insert legend
        if(($isLegendLeft) -or ($isLegendRight)){
            $readLineAry += ""
            $readLineAry += " subgraph cluster_legend {"
            $readLineAry += "   peripheries=0;"
            $readLineAry += ""
        }

        foreach ($lin in $readLineAryNode){
            $readLineAry += $lin
        }
        foreach ($lin in $readLineAryEdge){
            $readLineAry += $lin
        }
        foreach ($lin in $readLineAryOpt){
            $readLineAry += $lin
        }

        if ($DotFile){
            $readLineAry += ''
            $readLineAry += ' // read another dot file'
            Get-Content $DotFile -Encoding utf8 `
                | ForEach-Object { $readLineAry += $_}
        }

      # insert legend
        if(($isLegendLeft) -or ($isLegendRight)){
            if($isLegendRight){$lloc = "r"}
            if($isLegendLeft) {$lloc = "l"}
            $readLineAry += ""
            $readLineAry += " graph ["
            $readLineAry += "   labelloc=""b"";"
            $readLineAry += "   labeljust=""$lloc"";"
            $readLineAry += "   color=""white"";"
            $readLineAry += "   label=<"
            $readLineAry += "   <TABLE"
            $readLineAry += "       BORDER=""1"""
            $readLineAry += "       CELLBORDER=""0"""
            #$readLineAry += "       CELLSPACING=""6"""
            $readLineAry += "       COLOR=""gray15"""
            $readLineAry += "       BGCOLOR=""grey95"""
            $readLineAry += "   >"
            function parseTableStr ([string]$lin){
                $ret = $lin
                $ret = $ret -replace '\*\*\*([^\*]+)\*\*\*', '<I><B>$1</B></I>'
                $ret = $ret -replace   '\*\*([^\*]+)\*\*',      '<B>$1</B>'
                $ret = $ret -replace     '\*([^\*]+)\*',        '<I>$1</I>'
                $ret = $ret -replace     '\~([^\~]+)\~',      '<SUB>$1</SUB>'
                $ret = $ret -replace     '\^([^\^]+)\^',      '<SUP>$1</SUP>'
                return $ret
            }
            foreach ($lin in $readLineAryLeg){
                if($lin -eq ''){
                    $legLine = "   <TR><TD></TD></TR>"
                }else{
                    $legLine = "   <TR><TD ALIGN=""LEFT""><FONT COLOR=""gray15"" POINT-SIZE=""$LegendFontSize"">"
                    $legLine += parseTableStr "$lin"
                    $legLine += "</FONT></TD></TR>"
                }
                $readLineAry += $legLine
            }
            $readLineAry += "   </TABLE>>;"
            $readLineAry += " ];"
            $readLineAry += ""
            $readLineAry += " };"
            $readLineAry += ""
        }

        foreach ($lin in $readLineAryFooter){
            $readLineAry += $lin
        }

        ## output
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
