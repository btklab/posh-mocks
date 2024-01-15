<#
.SYNOPSIS
    logi2dot - Generate data for graphviz with simple format

    Convert the following input data to graphviz format.
    The rightmost column is preceded tasks.
    If there are multiple, separate them with comma.

    Usage:
        cat a.txt | logi2dot -Kinsoku 10 > a.dot; dot2gviz a.dot svg

    Input: id, task, [prectask1, prectask2,...]
        A task-A [-]
        B task-B [A]
        C task-C [A,B]

        legend right
        this is
        reference
        end legend
    
    Format:
        - id task [prectask1, prectask2,...]
        - id must not contain spaces.Symbols and mutibyte characters
            can be used, but some symbols cannot be used.
        - If the first line starts with "#", it is recognized as title.
        - Node gouping symbols are "-- group name --" or "## group name"
            - If increase the number of symbols, it becomes nested structure
            - When grouping, the last group contains all statements up to the
              end. But, Inserting a hyphen-only line like "--" closes all
              groups that are not closed at that line.
        - After specifying the nodes, you can manually add
            commnents to any edge. the format is as follows.
            - id --> id : commnent
        - Lines starts with "//" are treated as comment.
        - "//-- dot --" will output all the following lines as is,
            without processing. this is used when you want to add
            Dot format language directly.
        - Image insert format:
            - id <img:./image.png>
            - id <img:./image.png|label>
            - icon image sources
            - https://www.opensecurityarchitecture.org/cms/library/icon-library
            - https://network.yamaha.com/support/download/tool
            - https://knowledge.sakura.ad.jp/4724/
        - legend block
            - "legend (right|left)"
            - "contents"
            - "contents"
            - "end legend"
    
    Input:
        # how to cook curry

        -- rice --
        A wash rice [-]
        B soak rice in fresh water [A]
        C cook rice [B]

        -- curry roux --
        D cut vegetables [-]
        E cut meat into cubes [-]
        F stew vegetables and meat [D,E]
        G add curry roux and simmer [F]

        --

        H serve on plate [C,G]
        I complete! [H]

        B --> C : at least\n30 minutes

        //-- dot --
        {rank=same; A, E, D};

        legend right
        this is
        legend!
        end legend
    
    Output:
        strict digraph logictree {
        
          graph [
            charset = "UTF-8";
            compound = true;
            fontname = "MS Gothic";
            label = "how to cook curry";
            labelloc = "t";
            rankdir = "TB";
            newrank = true;
          ];

          node [
            fontname = "MS Gothic";
            shape = "rectangle";
            style = "rounded,solid";
          ];

          edge [
            fontname = "MS Gothic";
            dir = forward;
          ];

          // legend subgraph
          subgraph cluster_legend {
            //peripheries=0;


          // Node settings


          subgraph cluster_G1 {
            label = "[rice]";
            shape = "Default";
            //fontsize = 11;
            labelloc = "t";
            labeljust = "l";
            color = "black";
            fontcolor = "black";
            "A" [label="A\lwash rice", shape="rectangle" ];
            "B" [label="B\lsoak rice in fresh water", shape="rectangle" ];
            "C" [label="C\lcook rice", shape="rectangle" ];

          };

          subgraph cluster_G2 {
            label = "[curry roux]";
            shape = "Default";
            //fontsize = 11;
            labelloc = "t";
            labeljust = "l";
            color = "black";
            fontcolor = "black";
            "D" [label="D\lcut vegetables", shape="rectangle" ];
            "E" [label="E\lcut meat into cubes", shape="rectangle" ];
            "F" [label="F\lstew vegetables and meat", shape="rectangle" ];
            "G" [label="G\ladd curry roux and simmer", shape="rectangle" ];

          };

          "H" [label="H\lserve on plate", shape="rectangle" ];
          "I" [label="I\lcomplete!", shape="rectangle" ];


          // Edge settings
          "A" -> "B" [style=solid];
          "B" -> "C" [style=solid];
          "D" -> "F" [style=solid];
          "E" -> "F" [style=solid];
          "F" -> "G" [style=solid];
          "C" -> "H" [style=solid];
          "G" -> "H" [style=solid];
          "H" -> "I" [style=solid];

          // Edge optional settings
          "B" -> "C" [label="at least\n30 minutes", style="solid", dir=forward];


          // Dot settings
          {rank=same; A, E, D};


          // legend block
          graph [
            labelloc="b";
            labeljust="r";
            color="white";
            label=<
            <TABLE
              BORDER="1"
              CELLBORDER="0"
              COLOR="gray15"
              BGCOLOR="gray95"
            >
            <TR><TD ALIGN="LEFT"><FONT COLOR="gray15" POINT-SIZE="11">this is</FONT></TD></TR>
            <TR><TD ALIGN="LEFT"><FONT COLOR="gray15" POINT-SIZE="11">legend!</FONT></TD></TR>
            </TABLE>>;
          ];

          };

        }

.LINK
    pu2java, dot2gviz, pert, pert2dot, pert2gantt2pu, mind2dot, mind2pu, gantt2pu, logi2dot, logi2dot2, logi2dot3, logi2pu, logi2pu2, flow2pu, seq2pu


.PARAMETER OutputFile
    Output file name.

.PARAMETER Title
    Insert title

.PARAMETER GraphType
    Specify graph type:

        digraph (default)
        graph
        strict digraph
        strict graph

.PARAMETER GraphName
    Specify graph name.

.PARAMETER IdTail
    Paste the ID ad the end of the label.
    Default: Paste the ID at the top of the label.

.PARAMETER IdDelim
    Put the specified string between the ID and the label.
    Default: "\l"

.PARAMETER OffId
    Do not put the ID on the label.
    Default: Paste the ID at the top of label.

.PARAMETER LeftToRightDirection
    Left to right diagram.

.PARAMETER RightToLeftDirection
    Right to left diagram.

.PARAMETER BottomToTopDirection
    Bottom to top diagram.

.PARAMETER FoldLabel
    Fold the label at specified number of characters.

.PARAMETER Kinsoku
    Fold the label at the specified number of characters
    considering illegal characters.

    Specify a numeric values as 1 half-width character or
    2 full-width characters.

    Depends on kinsoku_function.ps1


.PARAMETER LayoutEngine
    Specify layout engine

        dot (default)
        circo
        fdp
        neato
        osage
        sfdp
        twopi
        patchwork

.PARAMETER Grep
    Change the shape and color of nodes that match
    a regular expressin.

    Used in combination with -GrepShape and -GrepColor
    switch.

.PARAMETER GrepShape
    Specify the shape of the matched nodes in the -Grep option

.PARAMETER GrepColor
    Specify the color of the matched nodes in the -Grep option

    Default: pink

.PARAMETER AddStartNode
    Add "start" node

.PARAMETER ReverseEdgeDir
    Reverse the direction of the arrow.

.PARAMETER AddEdgeLabel
    Sequential numbering of edges(arrows).

    The header character can be changed with
    -AddEngeLabesStr option.

.EXAMPLE
    cat input.txt
    # logic tree

    Goal Making a profit for the company  [ReqA, ReqB]

    -- GroupA --
    ReqA Secure sales [ActA]
    ActA Reduce the price [-]

    -- GroupB --
    ReqB Secure profits [ActB]
    ActB keep the price [-]

    --

    ActA <-> ActB: conflict！

    //-- dot --
    {rank=same; ActA, ActB};


    PS > cat input.txt | logi2dot -Kinsoku 10 -BottomToTopDirection > a.dot; dot2gviz a.dot svg

.EXAMPLE
    cat curry.txt
    # how to cook curry

    -- rice --
    A wash rice [-]
    B soak rice in fresh water [A]
    C cook rice [B]

    -- curry roux --
    D cut vegetables [-]
    E cut meat into cubes [-]
    F stew vegetables and meat [D,E]
    G add curry roux and simmer [F]

    --

    H serve on plate [C,G]
    I complete! [H]

    B --> C : at least\n30 minutes

    //-- dot --
    {rank=same; A, E, D};

    legend right
    this is
    legend!
    end legend


    PS > cat curry.txt | logi2dot -Kinsoku 10 -BottomToTopDirection > a.dot ; dot2gviz a.dot svg | ii

#>
function logi2dot {
    Param(
        [Parameter(Mandatory=$False)]
        [Alias('o')]
        [string]$OutputFile,

        [Parameter(Mandatory=$False)]
        [string]$Title,

        [Parameter(Mandatory=$False)]
        [Alias('l')]
        [ValidateSet(
            "circo", "dot", "fdp", "neato",
            "osage", "sfdp", "twopi", "patchwork")]
        [string]$LayoutEngine,

        [Parameter(Mandatory=$False)]
        [ValidateSet(
            "digraph", "graph",
            "strict graph", "strict digraph")]
        [string]$GraphType = "strict digraph",

        [Parameter(Mandatory=$False)]
        [string]$GraphName = "logictree",

        [Parameter(Mandatory=$False)]
        [double]$FontSize,

        [Parameter(Mandatory=$False)]
        [ValidateSet("t", "b", "l", "r")]
        [string]$TitleLoc = "t",

        [Parameter(Mandatory=$False)]
        [ValidateSet("l", "r", "c")]
        [string]$TitleJust,

        [Parameter(Mandatory=$False)]
        [switch]$LeftToRightDirection,

        [Parameter(Mandatory=$False)]
        [switch]$RightToLeftDirection,

        [Parameter(Mandatory=$False)]
        [switch]$BottomToTopDirection,

        [Parameter(Mandatory=$False)]
        [switch]$IdTail,

        [Parameter(Mandatory=$False)]
        [string]$IdDelim = '\l',

        [Parameter(Mandatory=$False)]
        [switch]$OffId,

        [Parameter(Mandatory=$False)]
        [switch]$ReverseEdgeDir,

        [Parameter(Mandatory=$False)]
        [string]$FontName,

        [Parameter(Mandatory=$False)]
        [string]$FontNameWindowsDefault = "MS Gothic",

        [Parameter(Mandatory=$False)]
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
        [string]$NodeShape = "rectangle",

        [Parameter(Mandatory=$False)]
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
        [string]$NodeShapeFirst,

        [Parameter(Mandatory=$False)]
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
        [string]$GroupShape = "Default",

        [Parameter(Mandatory=$False)]
        [double]$NodeWidth,

        [Parameter(Mandatory=$False)]
        [double]$NodeHeight,

        [Parameter(Mandatory=$False)]
        [int]$FoldLabel,

        [Parameter(Mandatory=$False)]
        [int]$Kinsoku,

        [Parameter(Mandatory=$False)]
        [string]$KinsokuDelim = '\l',

        [Parameter(Mandatory=$False)]
        [switch]$OffRoundCorner,

        [Parameter(Mandatory=$False)]
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
        [string]$GrepShape = "rectangle",

        [Parameter(Mandatory=$False)]
        [regex]$Grep,

        [Parameter(Mandatory=$False)]
        [string]$GrepColor = "pink",

        [Parameter(Mandatory=$False)]
        [switch]$AddStartNode,

        [Parameter(Mandatory=$False)]
        [switch]$AddEdgeLabel,

        [Parameter(Mandatory=$False)]
        [string]$AddEdgeLabelStr = "e",

        [Parameter(Mandatory=$False)]
        [string]$AddEdgeLabelFontsize,

        [Parameter( Mandatory=$False)]
        [int]$LegendFontSize = 11,

        [Parameter( Mandatory=$False)]
        [string]$Spaces = '  ',

        [Parameter( Mandatory=$False)]
        [string[]]$GroupLabelLoc = @("t","l"),

        [Parameter( Mandatory=$False)]
        [string]$GroupLineColor = "black",

        [Parameter( Mandatory=$False)]
        [string]$GroupFontColor = "black",

        [Parameter( Mandatory=$False)]
        [string]$GroupLineStyle,

        [Parameter( Mandatory=$False)]
        [string]$GroupLabelPrefix = "[",

        [Parameter( Mandatory=$False)]
        [string]$GroupLabelSuffix = "]",

        [Parameter( Mandatory=$False)]
        [switch]$Concentrate,

        [Parameter(Mandatory=$False,
            ValueFromPipeline=$True)]
        [string[]]$Text
    )

    begin{
        ## init var
        [string] $edgeJoinDelim = "@e@d@g@e@"
        [int] $addEdgeLabelCounter = 0
        [int] $lineCounter         = 0
        [int] $groupCounter        = 0
        [int] $nodeCounter         = 0
        [int] $oldItemLevel        = 0
        [int] $newItemLevel        = 0
        [string[]] $readLineAry     = @()
        [string[]] $readLineAryNode = @()
        $readLineAryNode += ''
        $readLineAryNode += $Spaces + "// Node settings"
        if($AddStartNode){
            $readLineAryNode += ' "start" [label="start"];'
        }
        [string[]] $readLineAryEdge = @()
        $readLineAryEdge += ''
        $readLineAryEdge += $Spaces + "// Edge settings"
        [string[]]$readLineAryEdgeOpt = @()
        $readLineAryEdgeOpt += ''
        $readLineAryEdgeOpt += $Spaces + "// Edge optional settings"
        [string[]]$readLineAryDot = @()
        $readLineAryDot += ''
        $readLineAryDot += $Spaces + "// Dot settings"
        $wspace = $Spaces * 1
        ## flags
        [bool] $isFirstRowEqTitle  = $False
        [bool] $NodeBlockFlag      = $True  # Loading node
        [bool] $NodeGroupFlag      = $False # Loading node group
        [bool] $EdgeBlockFlag      = $False # Loading edge block
        [bool] $DotBlockFlag       = $False # Loading dot source
        [bool] $LegendBlockFlag    = $False # Parse legend block
        [bool] $LegendBlockEndFlag = $False # Parse legend block
        [bool] $LegendBlockFirstLine = $False # Parse legend block
        ## private function
        # is command exist?
        function isCommandExist ([string]$cmd) {
            try { Get-Command $cmd -ErrorAction Stop > $Null
                return $True
            } catch {
                return $False
            }
        }
        function GetEdgeStr ([string]$lkey,[string]$edge, [string]$rkey, [string]$label, [string]$opt, [string]$sp){
            $tmpEdgeStr = $sp + """$lkey"" -> ""$rkey"" ["
            ## set label
            if ($label -ne 'None'){
                $label = $label -replace '^\s+',''
                $label = $label -replace '\s+$',''
                $tmpEdgeStr += "label=""$label"", "
            }
            ## set edge direction
            switch -Exact ($edge)
            {
                '<->' { $tmpEdgeStr += "style=""solid"", dir=both"; break }
                '-->' { $tmpEdgeStr += "style=""solid"", dir=forward"; break }
                '<--' { $tmpEdgeStr += "style=""solid"", dir=back"; break }
                '<.>' { $tmpEdgeStr += "style=""dashed"", dir=both"; break }
                '..>' { $tmpEdgeStr += "style=""dashed"", dir=forward"; break }
                '<..' { $tmpEdgeStr += "style=""dashed"", dir=back"; break }
                default {
                    Write-Error "error: incrrect edge: $edge" -ErrorAction Stop
                }
            }
            ## set option
            if  ($opt -ne 'None'){
                $splitOpt = $opt.Split(',')
                foreach ($op in $splitOpt){
                    $tmpEdgeStr += ", $op"
                }
            }
            $tmpEdgeStr += "];"
            return $tmpEdgeStr
        }
        ## test and dot sourcing kinsoku command
        if ( $Kinsoku ){
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
                Join = "$KinsokuDelim"
            }
            $KinsokuParams.Set_Item('Expand', $true)
            $KinsokuParams.Set_Item('OffTrim', $true)
            $str = Write-Output "$str" | kinsoku @KinsokuParams
            $str = $str + "$KinsokuDelim"
            return $str
        }
        function parseImageNode ([string]$str){
            ## A <img:./image.png> [prec,prec,...]
            ## ↓
            ## "A" [label=<<table border="0"><tr><td><img src="./image.png" /></td></tr></table>>, shape="none"];
            ##
            ## A <img:./image.png|labelA>
            ## ↓
            ## "A" [label=<<table border="0"><tr><td><img src="./image.png" /></td></tr><tr><td><font>labelA</font></td></tr></table>>, shape="none"];
            $rdLine = $str
            if ($rdLine -match '<img:'){
                $nodeKey  = $rdLine -replace '^([^ ]+?) (..*) +\[(..*)\]\s*$','$1'
                $nodeVal  = $rdLine -replace '^([^ ]+?) (..*) +\[(..*)\]\s*$','$2'
                $nodeVal  = $nodeVal.Trim()
                if ($OffId){
                    $nodeVal = $nodeVal -Replace '<img:(..*?)\|>','<<table border="0"><tr><td><img src="$1" /></td></tr></table>>, shape="none"'
                    $nodeVal = $nodeVal -Replace '<img:(..*?)\|(..*)>','<<table border="0"><tr><td><img src="$1" /></td></tr><tr><td><font>$2</font></td></tr></table>>, shape="none"'
                    $nodeVal = $nodeVal -Replace '<img:(..*?)>','<<table border="0"><tr><td><img src="$1" /></td></tr></table>>, shape="none"'
                } else {
                    $nodeVal = $nodeVal -Replace '<img:(..*?)\|>','<<table border="0"><tr><td><img src="$1" /></td></tr><tr><td><font>@@@AddIdHere@@@</font></td></tr></table>>, shape="none"'
                    $nodeVal = $nodeVal -Replace '<img:(..*?)\|(..*)>','<<table border="0"><tr><td><img src="$1" /></td></tr><tr><td><font>@@@AddIdHere@@@:$2</font></td></tr></table>>, shape="none"'
                    $nodeVal = $nodeVal -Replace '<img:(..*?)>','<<table border="0"><tr><td><img src="$1" /></td></tr><tr><td><font>@@@AddIdHere@@@</font></td></tr></table>>, shape="none"'
                    $nodeVal = $nodeVal -Replace '@@@AddIdHere@@@',"$nodeKey"
                }
                $rdLine = """$nodeKey"" [label=$nodeVal];"
            }
            return $rdLine
        }
        function parseNode ([string]$rdLine, [string]$nodeSpaces = $Spaces){
            $nodeKey  = $rdLine -replace '^([^ ]+?) (..*) +\[(..*)\]\s*$','$1'
            $nodeVal  = $rdLine -replace '^([^ ]+?) (..*) +\[(..*)\]\s*$','$2'
            $nodeKey  = $nodeKey.Trim()
            $nodeVal  = $nodeVal.Trim()
            $nodeKeyVal = "$nodeKey $nodeVal"
            if ($nodeVal -match '\{..*\}'){
                ## Optional brackets
                $nodeOpt = $nodeVal -replace '^(..*)\s*\{(..*)\}$','$2'
                $nodeVal = $nodeVal -replace '^(..*)\s*\{(..*)\}$','$1'
            } else {
                $nodeOpt = ''
            }
            if($FoldLabel){
                ## fold label
                $regStr = '('
                $regStr += '.' * $FoldLabel
                $regStr += ')'
                $reg = [regex]$regStr
                $nodeVal = $nodeVal -Replace $reg,'$1\l'
                $nodeVal = $nodeVal -Replace '$','\l'
                $nodeVal = $nodeVal -Replace '\\l\\l$','\l'
            }
            if ($Kinsoku) {
                ## fold label with kinsoku processing
                $nodeVal = execKinsoku $nodeVal
            }
            ## set node id into label strings
            if ($OffId){
                $nodeLabel = $nodeVal
            } elseif ((!$IdTail) -and ($IdDelim)){
                ## key at head with dot.
                $labelKey = "$nodeKey" + $IdDelim
                $nodeLabel = "$labelKey" + $nodeVal
            } elseif ($IdTail) {
                ## key at tail
                #$labelKey = "**【$nodeKey】**"
                $labelKey = "[$nodeKey]"
                $nodeLabel = $nodeVal + "\l\l$labelKey\r"
            } else {
                ## key at head
                $labelKey = "$nodeKey."
                $nodeLabel = "$labelKey" + $nodeVal
            }
            if (($NodeShapeFirst) -and ($nodeCounter -eq 1)){
                ## Given the shape of the first node
                $nShape = $NodeShapeFirst
                $nColor = ''
                if($Grep){
                    if($nodeKeyVal -match $Grep){
                        $nColor = ", style=""solid,filled"", fillcolor=""$GrepColor"""
                    }
                }
            } elseif ($Grep) {
                if ($nodeKeyVal -match $Grep){
                    ## Reshape only matched nodes
                    $nShape = $GrepShape
                    $nColor = ", style=""solid,filled"", fillcolor=""$GrepColor"""
                } else {
                    $nShape = $NodeShape
                    $nColor = ''
                }
            } else {
                ## default node shape
                $nShape = $NodeShape
                $nColor = ''
            }
            $retStr += $nodeSpaces + """$nodeKey"" [label=""$nodeLabel"", shape=""$nShape""$nColor $nodeOpt];"
            return $retStr
        }
        function parseEdge ([string]$rdLine) {
            [string[]]$retStrAry = @()
            if ( $rdLine -notmatch '\[' ){
                Write-Error "Invalid task specification: $rdLine" -ErrorAction Stop
            }
            $dId    = $rdLine -replace '^([^ ]+?) (..*) +\[(..*)\]\s*$','$1'
            $dName  = $rdLine -replace '^([^ ]+?) (..*) +\[(..*)\]\s*$','$2'
            $dPrec  = $rdLine -replace '^([^ ]+?) (..*) +\[(..*)\]\s*$','$3'
            $dId    = $dId.Trim()
            $dName  = $dName.Trim()
            if($dPrec -eq '-'){
                ## start point if prec = "-"
                if($AddStartNode){
                    $from = [string]'start'
                    $to   = [string]($dId)
                    $retStrAry += $Spaces + """$from"" -> ""$to"";"
                } else {
                    ## if no "start" node is specified, nothing is output.
                    $retStrAry += ''
                }
            } elseif ($dPrec -match ','){
                ## if the preceding task is separated by commas,
                ## the process branches ito multiple.
                $splitId = $dPrec.Split(',')
                for($j = 0; $j -lt $splitId.Count; $j++){
                    $from = ($splitId[$j]).Trim()
                    $to   = $dId
                    $retStrAry += $Spaces + """$from"" -> ""$to"" [style=solid];"
                }
            } else {
                ## if the preceding task is not separated by comma,
                ## there is only one preceding task.
                $from = $dPrec.Trim()
                $to   = $dId
                $retStrAry += $Spaces + """$from"" -> ""$to"" [style=solid];"
            }
            return $($retStrAry -Join "$edgeJoinDelim")
        }
        function parseTableStr ([string]$lin){
            [string] $ret = $lin
            [string] $ret = $ret -replace '\*\*\*([^\*]+)\*\*\*', '<I><B>$1</B></I>'
            [string] $ret = $ret -replace   '\*\*([^\*]+)\*\*',      '<B>$1</B>'
            [string] $ret = $ret -replace     '\*([^\*]+)\*',        '<I>$1</I>'
            [string] $ret = $ret -replace     '\~([^\~]+)\~',      '<SUB>$1</SUB>'
            [string] $ret = $ret -replace     '\^([^\^]+)\^',      '<SUP>$1</SUP>'
            return $ret
        }
        function replaceHyphensToSharps ( [string]$lin ){
            [string] $hyphens = $lin -replace '^(\-+) (.*)$', '$1'
            [string] $hyphens = $hyphens -replace '\-', '#'
            [string] $grpName = $lin -replace '^(\-+) (.*)$', '$2'
            [string] $grpName = $grpName -replace '\s*(\-)+', ''
            [string] $ret = "$hyphens $grpName"
            return $ret
        }
        function getItemLevel ([string]$lin){
            [string] $sharps = $lin -replace '^(##+) (.*)$', '$1'
            [int] $itemLevel = $sharps.Length - 1
            return $itemLevel
        }
        function closeParenthesisForLevel ([int]$iLevel){
            [string] $res = $Spaces * ($iLevel - 0) + "};"
            return $res
        }
    }
    process {
        $lineCounter++
        [string] $rdLine = [string] $_
        if ( $rdLine -match '^(\-)+ [^-]'){
            [string] $rdLine = replaceHyphensToSharps $rdLine
        }
        Write-Debug $rdLine
        if (($lineCounter -eq 1) -and ($rdLine -match '^# ')) {
            ## treat first line as title
            [string] $fTitle = $rdLine -replace '^# ', ''
            [bool] $isFirstRowEqTitle = $True
            return
        }
        ## reading mode switch
        ## if "//-- Dot --" appears,
        ## following lines are output as-is (without processing)
        if ($rdLine -match '^//\-\-\s*[Dd][Oo][tT]'){
            [bool] $DotBlockFlag  = $True
            [bool] $NodeBlockFlag = $False
            [bool] $EdgeBlockFlag = $False
            return
        }
        ## Node grouping mode = ON
        ## from "## GroupName" to the next blank line.
        if ( ($rdLine -match '^##+') -and ( -not $DotBlockFlag) ) {
            ## get group name
            [bool] $NodeGroupFlag = $True
            $groupCounter++
            [string] $groupId = "G" + [string] $groupCounter
            [string] $groupName = $rdLine -replace '^##+\s*',''
            [string] $groupName = $groupName.Trim()
            if ($groupName -match '\{..*\}'){
                ## Additional options with brackets
                $groupOpt  = $groupName -replace '^(..*)\s*\{(..*)\}$','$2'
                $groupName = $groupName -replace '^(..*)\s*\{(..*)\}$','$1'
            } else {
                $groupOpt = ''
            }
            $groupName = $groupName.Trim()
            ## get itemlevel
            [int] $newItemLevel = getItemLevel $rdLine
            Write-Debug "ItemLevel: old = $oldItemLevel, new = $newItemLevel"
            if ($newItemLevel -eq $oldItemLevel){
                ## close parenthesis
                $readLineAryNode += closeParenthesisForLevel $oldItemLevel
                [string] $wspace = $Spaces * ($newItemLevel)
            } elseif ($newItemLevel -gt $oldItemLevel){
                [string] $wspace = $Spaces * ($newItemLevel)
            } elseif ($newItemLevel -lt $oldItemLevel){
                for ( $i=$oldItemLevel; $i -ge $newItemLevel; $i--){
                    $readLineAryNode += closeParenthesisForLevel $i
                }
                $readLineAryNode += ''
                [string] $wspace = $Spaces * ($newItemLevel)
            } else {
                Write-Error "error: Unknown error. Unable to detect hierarchy: $rdLine" -ErrorAction Stop
            }
            $readLineAryNode += ""
            $readLineAryNode += "$wspace" + "subgraph cluster_$groupId {"
            if ( $GroupLabelPrefix -ne '' ){
                [string] $groupName = $GroupLabelPrefix + $groupName
            }
            if ( $GroupLabelSuffix -ne '' ){
                [string] $groupName = $groupName + $GroupLabelSuffix
            }
            $readLineAryNode += "$wspace" + $Spaces + "label = ""$groupName"";"
            $readLineAryNode += "$wspace" + $Spaces + "shape = ""$GroupShape"";"
            $readLineAryNode += "$wspace" + $Spaces + "//fontsize = 11;"
            $readLineAryNode += "$wspace" + $Spaces + "labelloc = ""$($GroupLabelLoc[0])"";"
            $readLineAryNode += "$wspace" + $Spaces + "labeljust = ""$($GroupLabelLoc[1])"";"
            $readLineAryNode += "$wspace" + $Spaces + "color = ""$GroupLineColor"";"
            $readLineAryNode += "$wspace" + $Spaces + "fontcolor = ""$GroupFontColor"";"
            if ( ($Grep) -and ($groupName -match $Grep )){
                if ( $GroupLineStyle ){
                    $readLineAryNode += "$wspace" + $Spaces + "style = ""$GroupLineStyle,filled"";"
                } else {
                    $readLineAryNode += "$wspace" + $Spaces + "style = ""solid,filled"";"
                }
                $readLineAryNode += "$wspace" + $Spaces + "fillcolor = ""$GrepColor"";"
            } elseif ( $GroupLineStyle ){
                $readLineAryNode += "$wspace" + $Spaces + "style = ""$GroupLineStyle"";"
            }
            if ($groupOpt -ne ''){
                $readLineAryNode += "$wspace" + "$groupOpt;"
            }
            [int] $oldItemLevel = $newItemLevel
            return
        }
        ## if "legend" appears, begin legend block
        if ($rdLine -eq "legend right" -or $rdLine -eq "legend left"){
            ## close group if not closed
            if ( $oldItemLevel -ne 0) {
                ## close parenthesis
                for ( $i=$oldItemLevel; $i -ge 1; $i--){
                    $readLineAryNode += closeParenthesisForLevel $i
                }
                $readLineAryNode += ''
                [bool] $NodeGroupFlag = $False
                Write-Debug "ItemLevel: old = $oldItemLevel, new = $newItemLevel"
                [int] $oldItemLevel = 0
                [int] $newItemLevel = 0
            }
            [bool] $DotBlockFlag         = $False
            [bool] $NodeBlockFlag        = $False
            [bool] $EdgeBlockFlag        = $False
            [bool] $LegendBlockFlag      = $True
            [bool] $LegendBlockFirstLine = $True
            if ($rdLine -eq "legend left"){
                [string] $lloc = "l"
            } else {
                [string] $lloc = "r"
            }
            ## init var
            [string[]] $readLineAryLegend = @()
            $readLineAryLegend += ""
            $readLineAryLegend += $Spaces * 1 + "// legend block"
            $readLineAryLegend += $Spaces * 1 + "graph ["
            if ( $BottomToTopDirection ){
                $readLineAryLegend += $Spaces * 2 + "labelloc=""t"";"
            } else {
                $readLineAryLegend += $Spaces * 2 + "labelloc=""b"";"
            }
            $readLineAryLegend += $Spaces * 2 + "labeljust=""$lloc"";"
            $readLineAryLegend += $Spaces * 2 + "color=""white"";"
            $readLineAryLegend += $Spaces * 2 + "label=<"
            $readLineAryLegend += $Spaces * 2 + "<TABLE"
            $readLineAryLegend += $Spaces * 3 + "BORDER=""1"""
            $readLineAryLegend += $Spaces * 3 + "CELLBORDER=""0"""
            #$readLineAryLegend += $Spaces * 3 + "CELLSPACING=""6"""
            $readLineAryLegend += $Spaces * 3 + "COLOR=""gray15"""
            $readLineAryLegend += $Spaces * 3 + "BGCOLOR=""gray95"""
            $readLineAryLegend += $Spaces * 2 + ">"
        }
        ## if "<--" or "-->" of "<->" appears,
        # end of node block,
        # start of edge block
        if (($rdLine -match ' \<[-.]{2} | [-.]{2}\> | \<[-.]\> ') -and ( -not $DotBlockFlag)){
            ## close group if not closed
            if ( $oldItemLevel -ne 0) {
                ## close parenthesis
                for ( $i=$oldItemLevel; $i -ge 1; $i--){
                    $readLineAryNode += closeParenthesisForLevel $i
                }
                $readLineAryNode += ''
                Write-Debug "ItemLevel: old = $oldItemLevel, new = $newItemLevel"
                [int] $oldItemLevel = 0
                [int] $newItemLevel = 0
                [bool] $NodeGroupFlag = $False
            }
            [bool] $NodeBlockFlag = $False
            [bool] $EdgeBlockFlag = $True
        }
        ## if "--" appears, call closeParenthesis
        if ("$rdLine".Trim() -match '^\-+$'){
            ## close group if not closed
            if ( $oldItemLevel -ne 0) {
                ## close parenthesis
                for ( $i=$oldItemLevel; $i -ge 1; $i--){
                    $readLineAryNode += closeParenthesisForLevel $i
                }
                Write-Debug "ItemLevel: old = $oldItemLevel, new = $newItemLevel"
                [int] $oldItemLevel = 0
                [int] $newItemLevel = 0
                [bool] $NodeGroupFlag = $False
            }
            return
        }
        ## Node block reading mode
        if (($NodeBlockFlag) -and ( -not $DotBlockFlag)) {
            if ($rdLine -match '^\s*$'){
                ## skip blank line
                $readLineAryNode += ''
            } elseif ($rdLine -match '^//'){
                ## output comment as-is
                $readLineAryNode += $wspace + $rdLine
            } elseif ($rdLine -match '<img:'){
                ## Image node dedicated processing
                $nodeCounter++
                $rdLine = parseImageNode $rdLine
                $readLineAryNode += "$wspace $rdLine"
            } else {
                ## Read node
                $nodeCounter++
                ## key is the leftmost column,
                ## the others are the value
                $splitLine = $rdLine.Split(' ')
                if ($splitLine.Count -lt 2){
                    Write-Error "Insufficient columns: $rdLine" -ErrorAction Stop
                }
                ## set spaecs
                if ( $NodeGroupFlag ){
                    [string] $nSpaces = $Spaces * ($newItemLevel + 1)
                } else {
                    [string] $nSpaces = $Spaces * 1
                }
                $readLineAryNode += parseNode $rdLine $nSpaces
                ## Parse edge
                $parsedEdgeStr = parseEdge $rdLine
                $splitEdgeAry = $parsedEdgeStr.Split( $edgeJoinDelim )
                for ($i = 0; $i -lt $splitEdgeAry.Count; $i++){
                    $tmpStr = [string]($splitEdgeAry[$i])
                    if ($tmpStr -ne ''){
                        if ($AddEdgeLabel){
                            ## Generate edge label
                            $addEdgeLabelCounter++
                            $tmpEdgeLabel = $AddEdgeLabelStr + [string]$addEdgeLabelCounter
                            $tmpStr = $tmpStr -replace '\];$',", label=""$tmpEdgeLabel""];"
                            if($AddEdgeLabelFontsize){
                                $tmpStr = $tmpStr -replace '\];$',", fontsize=$AddEdgeLabelFontsize];"
                            }
                        }
                        $readLineAryEdge += $tmpStr
                    }
                }
            }
            return
        }
        ## Edge block reading mode
        ##   e.g. A --> B : label
        ##   "A" -> "B" [label="label", style="solid", dir=both];
        if ($EdgeBlockFlag){
            ## set header spaces
            $edgeSpace = $Spaces * 1
            if ($rdLine -match '^\s*$'){
                ## skip blank line
                $readLineAryEdgeOpt += $rdLine
            } elseif ($rdLine -match '^\s*//'){
                ## skip comment line
                $readLineAryEdgeOpt += $wspace + $rdLine
            } elseif ( $rdLine -match '^\s*([^ ]+)\s+([-><.]+)\s+([^ ]+)\s*:\s*(..*)\s*\{(..*)\}\s*$') {
                ## case: "A" --> "B" : comment {option}
                $lkey  = $rdLine -replace '^\s*([^ ]+)\s+([-><.]+)\s+([^ ]+)\s*:\s*(..*)\s*\{(..*)\}\s*$','$1'
                $edge  = $rdLine -replace '^\s*([^ ]+)\s+([-><.]+)\s+([^ ]+)\s*:\s*(..*)\s*\{(..*)\}\s*$','$2'
                $rkey  = $rdLine -replace '^\s*([^ ]+)\s+([-><.]+)\s+([^ ]+)\s*:\s*(..*)\s*\{(..*)\}\s*$','$3'
                $label = $rdLine -replace '^\s*([^ ]+)\s+([-><.]+)\s+([^ ]+)\s*:\s*(..*)\s*\{(..*)\}\s*$','$4'
                $opt   = $rdLine -replace '^\s*([^ ]+)\s+([-><.]+)\s+([^ ]+)\s*:\s*(..*)\s*\{(..*)\}\s*$','$5'
                $readLineAryEdgeOpt += GetEdgeStr $lkey $edge $rkey $label $opt $edgeSpace
            } elseif ( $rdLine -match '^\s*([^ ]+)\s+([-><.]+)\s+([^ ]+)\s*[: ]\s*\{(..*)\}\s*$'){
                ## case: "A" --> "B" : {option}
                $lkey  = $rdLine -replace '^\s*([^ ]+)\s+([-><.]+)\s+([^ ]+)\s*:\s*\{(..*)\}\s*$','$1'
                $edge  = $rdLine -replace '^\s*([^ ]+)\s+([-><.]+)\s+([^ ]+)\s*:\s*\{(..*)\}\s*$','$2'
                $rkey  = $rdLine -replace '^\s*([^ ]+)\s+([-><.]+)\s+([^ ]+)\s*:\s*\{(..*)\}\s*$','$3'
                $label = "None"
                $opt   = $rdLine -replace '^\s*([^ ]+)\s+([-><.]+)\s+([^ ]+)\s*:\s*\{(..*)\}\s*$','$4'
                $readLineAryEdgeOpt += GetEdgeStr $lkey $edge $rkey $label $opt $edgeSpace
            } elseif ( $rdLine -match '^\s*([^ ]+)\s+([-><.]+)\s+([^ ]+)\s*:\s*(..*)\s*$'){
                ## case: "A" --> "B" : comment
                $lkey  = $rdLine -replace '^\s*([^ ]+)\s+([-><.]+)\s+([^ ]+)\s*:\s*(..*)\s*$','$1'
                $edge  = $rdLine -replace '^\s*([^ ]+)\s+([-><.]+)\s+([^ ]+)\s*:\s*(..*)\s*$','$2'
                $rkey  = $rdLine -replace '^\s*([^ ]+)\s+([-><.]+)\s+([^ ]+)\s*:\s*(..*)\s*$','$3'
                $label = $rdLine -replace '^\s*([^ ]+)\s+([-><.]+)\s+([^ ]+)\s*:\s*(..*)\s*$','$4'
                $opt   = "None"
                $readLineAryEdgeOpt += GetEdgeStr $lkey $edge $rkey $label $opt $edgeSpace
            } elseif ( $rdLine -match '^\s*([^ ]+)\s+([-><.]+)\s+([^ ]+)\s*$'){
                ## case "A" --> "B"
                $lkey = $rdLine -replace '^\s*([^ ]+)\s+([-><.]+)\s+([^ ]+)\s*$','$1'
                $edge = $rdLine -replace '^\s*([^ ]+)\s+([-><.]+)\s+([^ ]+)\s*$','$2'
                $rkey = $rdLine -replace '^\s*([^ ]+)\s+([-><.]+)\s+([^ ]+)\s*$','$3'
                $label = "None"
                $opt   = "None"
                $readLineAryEdgeOpt += GetEdgeStr $lkey $edge $rkey $label $opt $edgeSpace
            } else {
                Write-Error "parse error: invalid edge specification: $rdLine" -ErrorAction Stop
            }
            return
        }
        ## Dot block reading mode
        ## as-is output
        if ($DotBlockFlag){
            ## close group if not closed
            if ( $oldItemLevel -ne 0) {
                ## close parenthesis
                for ( $i=$oldItemLevel; $i -ge 1; $i--){
                    $readLineAryNode += closeParenthesisForLevel $i
                }
                $readLineAryNode += ''
                Write-Debug "ItemLevel: old = $oldItemLevel, new = $newItemLevel"
                [int] $oldItemLevel = 0
                [int] $newItemLevel = 0
                [bool] $NodeGroupFlag = $False
            }
            if ($rdLine -eq ''){
                $readLineAryDot += $rdLine
            } else {
                $readLineAryDot += $wspace + $rdLine
            }
            return
        }
        ## Legend block reading mode
        ## as-is output
        if ($LegendBlockFlag){
            if ( $LegendBlockFirstLine ){
                #pass
                $LegendBlockFirstLine = $False
            } elseif ($rdLine.Trim() -eq "end legend"){
                [bool] $LegendBlockEndFlag = $True
                $readLineAryLegend += $Spaces * 2 + "</TABLE>>;"
                $readLineAryLegend += $Spaces * 1 + "];"
                $readLineAryLegend += ""
                # Close legend
                $readLineAryLegend += $Spaces * 1 + "};"
                $readLineAryLegend += ""
            } elseif ($rdLine -eq ''){
                $readLineAryLegend += $Spaces * 2 + "<TR><TD></TD></TR>"
            } else {
                [string] $legLine = $Spaces * 2 + "<TR><TD ALIGN=""LEFT""><FONT COLOR=""gray15"" POINT-SIZE=""$LegendFontSize"">"
                [string] $legLine += parseTableStr $rdLine
                [string] $legLine += "</FONT></TD></TR>"
                $readLineAryLegend += $legLine
            }
            return
        }
    }
    end {
        ## test is group block closed?
        if ( $oldItemLevel -ne 0) {
            ## close parenthesis
            for ( $i=$oldItemLevel; $i -ge 1; $i--){
                $readLineAryNode += closeParenthesisForLevel $i
            }
            $readLineAryNode += ''
            [int] $oldItemLevel = 0
            [int] $newItemLevel = 0
            Write-Debug "ItemLevel: old = $oldItemLevel, new = $newItemLevel"
        }
        ## test legend block
        if ( $LegendBlockFlag){
            if ( -not $LegendBlockEndFlag ){
                Write-Error "legend block is not closed. write ""legend end"" end of block." -ErrorAction Stop
            }
        }
        ##
        ## Header
        ##
        $readLineAryHeader = @()
        $readLineAryHeader += "$GraphType $GraphName {"

        ## graph settings #################################
        $readLineAryHeader += ''
        $readLineAryHeader += $Spaces * 1 + 'graph ['
        $readLineAryHeader += $Spaces * 2 + 'charset = "UTF-8";'
        $readLineAryHeader += $Spaces * 2 + 'compound = true;'
        if($IsWindows){
            ## case  windows
            if($FontName){
                $readLineAryHeader += $Spaces * 2 + 'fontname = "' + $FontName + '";'
            } else {
                $readLineAryHeader += $Spaces * 2 + 'fontname = "' + $FontNameWindowsDefault + '";'
            }
        } else {
            ## case linux and mac
            if($FontName){
                $readLineAryHeader += $Spaces * 2 + 'fontname = "' + $FontName + '";'
            }
        }
        if($FontSize){
            $readLineAryHeader += $Spaces * 2 + 'fontsize = ' + [string]$FontSize + ';'
        }
        if($Title){
            $readLineAryHeader += $Spaces * 2 + 'label = "' + $Title + '";'
        } elseif ($isFirstRowEqTitle) {
            $readLineAryHeader += $Spaces * 2 + 'label = "' + $fTitle + '";'
        }
        if($TitleLoc){
            $readLineAryHeader += $Spaces * 2 + 'labelloc = "' + $TitleLoc + '";'
        }
        if($TitleJust){
            $readLineAryHeader += $Spaces * 2 + 'labeljust = "' + $TitleJust + '";'
        }
        if($LayoutEngine){
            $readLineAryHeader += $Spaces * 2 + 'layout = "' + $LayoutEngine + '";'
        }
        if($LeftToRightDirection){
            $readLineAryHeader += $Spaces * 2 + 'rankdir = "LR";'
        } elseif ($RightToLeftDirection){
            $readLineAryHeader += $Spaces * 2 + 'rankdir = "RL";'
        } elseif ($BottomToTopDirection){
            $readLineAryHeader += $Spaces * 2 + 'rankdir = "BT";'
        } else {
            $readLineAryHeader += $Spaces * 2 + 'rankdir = "TB";'
        }
        $readLineAryHeader += $Spaces * 2 + 'newrank = true;'
        if ( $Concentrate ){
            $readLineAryHeader += $Spaces * 2 + 'concentrate = true;'
        }
        $readLineAryHeader += $Spaces * 1 + '];'

        ## node settings #################################
        $readLineAryHeader += ''
        $readLineAryHeader += $Spaces * 1 + 'node ['
        if($IsWindows){
            ## case  windows
            if($FontName){
                $readLineAryHeader += $Spaces * 2 + 'fontname = "' + $FontName + '";'
            } else {
                $readLineAryHeader += $Spaces * 2 + 'fontname = "' + $FontNameWindowsDefault + '";'
            }
        } else {
            ## case linux and mac
            if($FontName){
                $readLineAryHeader += $Spaces * 2 + 'fontname = "' + $FontName + '";'
            }
        }
        if($FontSize){
            $readLineAryHeader += $Spaces * 2 + 'fontsize = ' + [string]$FontSize + ';'
        }
        if($NodeShape -ne 'Default'){
            $readLineAryHeader += $Spaces * 2 + 'shape = "' + $NodeShape + '";'
            if (!$OffRoundCorner) {
                $readLineAryHeader += $Spaces * 2 + 'style = "rounded,solid";'
            } else {
                $readLineAryHeader += $Spaces * 2 + 'style = "solid";'
            }
        }
        if($NodeWidth){
            $readLineAryHeader += $Spaces * 2 + 'width = ' + [string]$NodeWidth + ';'
        }
        if($NodeHeight){
            $readLineAryHeader += $Spaces * 2 + 'height = ' + [string]$NodeHeight + ';'
        }
        $readLineAryHeader += $Spaces * 1 + '];'

        ## edge settings #################################
        $readLineAryHeader += ''
        $readLineAryHeader += $Spaces * 1 + 'edge ['
        if($IsWindows){
            ## case  windows
            if($FontName){
                $readLineAryHeader += $Spaces * 2 + 'fontname = "' + $FontName + '";'
            } else {
                $readLineAryHeader += $Spaces * 2 + 'fontname = "' + $FontNameWindowsDefault + '";'
            }
        } else {
            ## case linux and mac
            if($FontName){
                $readLineAryHeader += $Spaces * 2 + 'fontname = "' + $FontName + '";'
            }
        }
        if($FontSize){
            $readLineAryHeader += $Spaces * 2 + 'fontsize = ' + [string]$FontSize + ';'
        }
        if($ReverseEdgeDir){
            $readLineAryHeader += $Spaces * 2 + 'dir = back;'
        } else {
            $readLineAryHeader += $Spaces * 2 + 'dir = forward;'
        }
        $readLineAryHeader += $Spaces * 1 + '];'

        ##
        ## Footer
        ##
        $readLineAryFooter = @()
        $readLineAryFooter += "}"
        ## output
        foreach ($lin in $readLineAryHeader){
            $readLineAry += $lin
        }
        if ( $LegendBlockFlag ){
            $readLineAry += ""
            $readLineAry += $Spaces * 1 + "// legend subgraph"
            $readLineAry += $Spaces * 1 + "subgraph cluster_legend {"
            $readLineAry += $Spaces * 2 + "//peripheries=0;"
            $readLineAry += ""
        }
        foreach ($lin in $readLineAryNode){
            $readLineAry += $lin
        }
        foreach ($lin in $readLineAryEdge){
            $readLineAry += $lin
        }
        foreach ($lin in $readLineAryEdgeOpt){
            $readLineAry += $lin
        }
        foreach ($lin in $readLineAryDot){
            $readLineAry += $lin
        }
        if ( $LegendBlockFlag ){
            foreach ($lin in $readLineAryLegend){
                $readLineAry += $lin
            }
        }
        foreach ($lin in $readLineAryFooter){
            $readLineAry += $lin
        }
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
            ## stdout
            foreach($rdStr in $readLineAry){
                Write-Output $rdStr
            }
        }
    }
}
