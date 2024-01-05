<#
.SYNOPSIS
    mind2dot - Generate graphviz script to draw a mindmap from list data in markdown format

    Mindmapping the hierarchical structure described in
    makdown list format.

    The hierarchical structure is expressed as
    "4 spaces" and "hyphen" like:

        - root
            - child1
                - child1-1
            - child2
            - child3
    
    Underscore "_" at the end of a sentence, makes it
    a string without frame (as plaintext.) like:

        - root
            - this is plain text_
    
    You can change the plaintext shape with -TerminalShape <shape> option
    
    The 1st line begins with "# ", it is considered as a title.
    Blank lines are ignored.
    Lines beginning with "//" are treated as comments.
    
    With "\n" newline are centered
    With "\l" newline are left-aligned
    With "\r" newline are right-aligned

    Lines wrapped in braces"{.*}" are treated as option,
    and will be output without modification. like:

        {rank=same; ID0001,ID0002}

    Legend can be output by writing the following:

        legend right|left
        this is legend
        end legend
    
    Fill color can be specified by prepending or postponing
    [#color] to the label. For example:

        - [#orange] label
        - label [#blue]

    -SolarizedDark, -SolarizedLight switch to apply the
    Solarized color schema.

        CREDIT:
        Solarized color palette from:
            - https://github.com/altercation/solarized
            - http://ethanschoonover.com/solarized
            - License: MIT License Copyright (c) 2011 Ethan Schoonover

.LINK
    pu2java, dot2gviz, pert, pert2dot, pert2gantt2pu, mind2dot, mind2pu, gantt2pu, logi2dot, logi2dot2, logi2dot3, logi2pu, logi2pu2, flow2pu, seq2pu


.PARAMETER GraphType
    graph (default)
    digraph
    strict graph
    strict digraph

.PARAMETER ReverseEdge
    Invert edge direction.

.PARAMETER DotFile
    Reads a DOT file with additional settings.

.PARAMETER NodeShape
    Specify the node shape.
    Default: ellipse

.PARAMETER FirstNodeShape
    Specify the first node shape.
    Default: "ellipse"

.PARAMETER OffRounded
    Release rounding of node corners.

.PARAMETER Title
    Insert title

.PARAMETER FontName
    Set fontname
    Default: "MS Gothic"

.PARAMETER FoldLabel
    Fold label at specified number of characters.

.PARAMETER Kinsoku
    Wrapping of character string considering japanese KINSOKU rules.
    Specify numerical value as 1 for ASCII characters
    and 2 for mulibyte characters.

    Depends on kinsoku_function.ps1

.PARAMETER SkipTop
    Set the character at the beginning of the line to
    skip character count in the kinsoku filter.

    Default: SkipTop = '\[#[^]]+\] '
            (Skip color symbol)

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

    PS > cat a.md | mind2dot
    graph mindmap {
     // graph settings
     graph [
      charset = "UTF-8";
      fontname = "MS Gothic";
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
      fontname = "MS Gothic";
      shape = "plaintext";
      style = "rounded";
     ];
     // edge settings
     edge [
      fontname = "MS Gothic";
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
    cat input.txt
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
    {rank=same; "[problem]",ID0001}
    {rank=same; "[countermeasure]",ID0002,ID0004}
    {rank=same; "[risks]",ID0003,ID0005}


    PS > cat input.txt | mind2dot
    PS > cat input.txt | mind2dot > a.dot; dot2gviz a.dot png | ii
    ## output
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
    {rank=same; "[problem]",ID0001}
    {rank=same; "[countermeasure]",ID0002,ID0004}
    {rank=same; "[risks]",ID0003,ID0005}

.EXAMPLE
    cat a.md | mind2dot -LayoutEngine twopi > a.dot; dot2gviz a.dot svg | ii

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
        [switch]$RightToLeft,

        [Parameter( Mandatory=$False)]
        [switch]$BottomToTop,

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
        [string]$TerminalShape = "plaintext",

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
        [string]$FontNameWindowsDefault = "MS Gothic",

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

        [Parameter( Mandatory=$False)]
        [switch]$Concentrate,

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
        function isCommandExist ([string]$cmd) {
            try { Get-Command $cmd -ErrorAction Stop > $Null
                return $True
            } catch {
                return $False
            }
        }
        function getItemLevel ([string]$wSpace){
            [int] $whiteSpaceLength = $wSpace.Length
            [int] $itemLevel = [math]::Floor($whiteSpaceLength / $Space)
            return $itemLevel
        }
        function setNodeStr ([string]$nodeId, [string]$nodeLabel, [bool]$plainTextFlag, [int]$scColNum){
            ## if a color is specified
            [string]$colorName = ''
            if ($nodeLabel -match '^\[#'){
                ## prefix - [#orange] contents
                $colorName = $nodeLabel -replace '^\[#([^\]]+)\](..*)$','$1'
                $colorName = $colorName.Trim()
                $nodeLabel = $nodeLabel -replace '^\[#([^\]]+)\](..*)$','$2'
                $nodeLabel = $nodeLabel.Trim()
            }elseif ($nodeLabel -match '\[#[^\]]+]$'){
                ## post placement - contents [#orange]
                $colorName = $nodeLabel -replace '^(..*)\[#([^\]]+)\]$','$2'
                $colorName = $colorName.Trim()
                $nodeLabel = $nodeLabel -replace '^(..*)\[#([^\]]+)\]$','$1'
                $nodeLabel = $nodeLabel.Trim()
            }
            ## "E" [label="label", shape="box"];
            [string] $nodeId    = """$nodeId"""
            [string] $nodeLabel = """$nodeLabel"""
            if ($plainTextFlag){
                $nShape = """$TerminalShape"""
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
            if( $GraphType -match 'digraph' ) {
                return "$leftId -> $rightId [$($opts)];"
            } else {
                return "$leftId -- $rightId [$($opts)];"
            }
        }
        ## test and dot sourcing kinsoku command
        if ($Kinsoku){
            if ( isCommandExist "kinsoku" ){
                #pass
            } else {
                $scrPath = Join-Path $PSScriptRoot "kinsoku_function.ps1"
                if (-not (Test-Path -LiteralPath $scrPath)){
                    Write-Error "kinsoku command could not found." -ErrorAction Stop
                }
                . $scrPath
            }
        }
        function execKinsoku ([string]$str){
            ## splatting
            $KinsokuParams = @{
                Width = $Kinsoku
                Join = '\n'
                SkipTop = "$SkipTop"
            }
            $KinsokuParams.Set_Item('Expand', $True)
            $KinsokuParams.Set_Item('OffTrim', $True)
            $str = Write-Output "$str" | kinsoku @KinsokuParams
            $str = $str + '\n'
            return $str
        }
        ##
        ## Stack & Queue functions
        ##
        $psStackAry = [string[]]@() ## stack array
        $psStackMaxSize = 10  ## maximum stack array size (up to 10 levels)
        $psStackTop = 0       ## pointer to the beginning of the stack array
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
            # push (advances top to store element)
            if (isStackFull){
                Write-Error "error: stack is full." -ErrorAction Stop
            }
            $psStackAry[$psStackTop] = $val
            $psStackTop++
            return $psStackTop, $psStackAry
        }
        function psStackPop {
            # pop (decrements top and returns the element at top position)
            if (isStackEmpty){
                Write-Error "error: stack is empty." -ErrorAction Stop
            }
            $psStackTop--
            $ret = $psStackAry[$psStackTop]
            return $psStackTop, $ret
        }
        function psStackGetVal {
            # return the element at the top position without
            # increasing or decreasing top
            return $psStackAry[$psStackTop-1]
        }
        ## init stack
        $psStackTop, $psStackAry = stackInit
    }
    process{
        $lineCounter++
        [bool] $plainTextFlag = $False
        [string] $rdLine = [string] $_
        ## ignore
        if ($rdLine -match '^\s*left side$') {$rdLine = '//' + $rdLine}
        if ($rdLine -match '^\s*right side$'){$rdLine = '//' + $rdLine}
        ## is the 1st line is title?
        if (($lineCounter -eq 1) -and ($rdLine -match '^# ')) {
            $fTitle = $rdLine -replace '^# ', ''
            $fTitle = $fTitle + '\n\n'
            $isFirstRowEqTitle = $True
        }
        ## target line is beginning with a hyphen or asterisk
        if (($rdLine -match '^\s*\-|^\s*\*') -and (-not $isLegend)){
            ## set node id
            $idCounter++
            $newNodeId = "ID" + $idCounter.Tostring("0000")
            ## set str
            $whiteSpace = $rdLine -replace '^(\s*)[-*].*$','$1'
            $contents   = $rdLine -replace '^\s*[-*]\s*(.*)$','$1'
            ## plain text if line ends in underscore
            if ($contents -match '_$'){
                $plainTextFlag = $True
                $contents = $contents -replace '_$',''
            }
            ## fold label
            if($FoldLabel){
                $regStr = '('
                $regStr += '.' * $FoldLabel
                $regStr += ')'
                $reg = [regex]$regStr
                $contents = $contents -Replace $reg,'$1\l'
                $contents = $contents -Replace '\\l$',''
                $contents = $contents + '\l'
            }
            ## wrap with kinsoku
            if ($Kinsoku) {
                $contents = execKinsoku $contents
            }
            ## stack node IDs as hierarchy changes (push & pop)
            [int] $newItemLevel = getItemLevel "$whiteSpace"
            ## set color scheme
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
                ## data on first line
                $readLineAryNode += setNodeStr $newNodeId $contents $plainTextFlag $colorNum
                $parentId = 'None'
            } else {
                ## data after the second line
                if ($newItemLevel -eq $oldItemLevel){
                    ## no hierarchy change: no push or pop
                    $readLineAryNode += setNodeStr $newNodeId $contents $plainTextFlag $colorNum
                    if ($parentId -ne 'None'){
                        $readLineAryEdge += setEdgeStr $parentId $newNodeId $colorNum
                    }

                } elseif ($newItemLevel -eq $oldItemLevel + 1){
                    ## move one level deeper: push
                    $readLineAryNode += setNodeStr $newNodeId $contents $plainTextFlag $colorNum
                    $parentId = $oldNodeId
                    $psStackTop, $psStackAry = psStackPush $parentId ## push parent ID to stack
                    $readLineAryEdge += setEdgeStr $parentId $newNodeId $colorNum

                } elseif ($newItemLevel -gt $oldItemLevel + 1){
                    Write-Error "error: Two or more hierarchical levels deep at once!: $rdLine" -ErrorAction Stop

                } elseif ($newItemLevel -lt $oldItemLevel){
                    ## The hierarchy has become shallower: pop
                    $readLineAryNode += setNodeStr $newNodeId $contents $plainTextFlag $colorNum
                    ## pop as many times as the hierarchical level
                    ## that has become shallower.
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
                    Write-Error "error: Unknown error. Unable to detect hierarchy: $rdLine" -ErrorAction Stop
                }
            }
            $oldItemLevel = $newItemLevel
            $oldNodeId = $newNodeId
        }
        $plainTextFlag = $False
        ## get options (lines beginning with "{")
        if ($rdLine -match '^\{..*\}$'){
            $readLineAryOpt += $rdLine }
        ## acquisition of legend strings
        if (($isLegend) -and ($rdLine -match '^end *legend$')){
            $isLegend = $false
        }
        if ($isLegend){
            $readLineAryLeg += $rdLine
        }
        if (($lineCounter -gt 1) -and ($rdLine -match '^legend right$')){
            $readLineAryLeg = @()
            $isLegendRight = $True
            $isLegend = $True
        }
        if (($lineCounter -gt 1) -and ($rdLine -match '^legend left$')){
            $readLineAryLeg = @()
            $isLegendLeft = $True
            $isLegend = $True
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
        if( $TopToBottom ){
            $readLineAryHeader += '  rankdir = "TB";'
        } elseif( $RightToLeft ){
            $readLineAryHeader += '  rankdir = "RL";'
        } elseif( $BottomToTop ){
            $readLineAryHeader += '  rankdir = "BT";'
        } else {
            $readLineAryHeader += '  rankdir = "LR";'
        }
        $readLineAryHeader += '  newrank = true;'
        $readLineAryHeader += '  overlap = "false";'
        if ( $Concentrate ){
            $readLineAryHeader += '  concentrate = true;'
        }
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
            if ( $SolarizedDark ){
                $readLineAry += "       COLOR=""$colGray"""
                $readLineAry += "       BGCOLOR=""$colDarkGrayBlue"""
            } elseif ( $SolarizedLight ) {
                $readLineAry += "       COLOR=""gray15"""
                $readLineAry += "       BGCOLOR=""$colSolWhite"""
            } else {
                $readLineAry += "       COLOR=""gray15"""
                $readLineAry += "       BGCOLOR=""grey25"""
            }
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
                    if ( $SolarizedDark ){
                        $legLine = "   <TR><TD ALIGN=""LEFT""><FONT COLOR=""$colSolWhite"" POINT-SIZE=""$LegendFontSize"">"
                    } elseif ( $SolarizedLight ){
                        $legLine = "   <TR><TD ALIGN=""LEFT""><FONT COLOR=""$colSolBlack"" POINT-SIZE=""$LegendFontSize"">"
                    } else {
                        $legLine = "   <TR><TD ALIGN=""LEFT""><FONT COLOR=""gray15"" POINT-SIZE=""$LegendFontSize"">"
                    }
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
                ## save as UTF-8 (CRLF) without BOM
                $readLineAry -Join "`r`n" `
                    | Out-File "$OutputFile" -Encoding UTF8
            } else {
                ## save as UTF-8 (LF) without BOM
                $readLineAry -Join "`n" `
                    | Out-File "$OutputFile" -Encoding UTF8
            }
            Get-Item $OutputFile
        }else{
            ## standard output
            foreach($rdStr in $readLineAry){
                Write-Output $rdStr
            }
        }
    }
}
