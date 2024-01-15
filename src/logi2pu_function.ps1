<#
.SYNOPSIS
    logi2pu - Generate data for plantuml (usecase diagram) with simple format

    Convert the following input data to plantuml format.
    The rightmost column is preceded tasks.
    If there are multiple, separate them with comma.

    Usage:
        cat a.txt | logi2pu > a.pu; pu2java a.pu svg

    Reference:
        https://plantuml.com/ja/use-case-diagram
    
    Input: id, task, [prectask1, prectask2,...]
        A task-A [-]
        B task-B [A]
        C task-C [A,B]
    
    Format:
        - id task [prectask1, prectask2,...]
        - id must not contain spaces.Symbols and mutibyte characters
          can be used, but some symbols cannot be used.
        - If the first line starts with "#", it is recognized as title.
        - "note (right|left)", "legend (right|left)" is available only
          with multi-lines.
            - Therefore, the characters "note" and "legend" cannot
              be used as IDs.
        - Node gouping symbols are "-- group name --" or "## group name"
            - If increase the number of symbols, it becomes nested structure
            - When grouping, the last group contains all statements up to the
              end. But, Inserting a hyphen-only line like "--" closes all
              groups that are not closed at that line.
        - After specifying the nodes, you can manually add
          commnents to any edge. the format is as follows.
            - id --> id : commnent
        - Lines starts with "//" are treated as comment.
        - Image insert format:
            - !define icon ./icons/
            - id <img:image.png{scale=0.5}> [-]
            - id <img:image.png{scale=0.5}|label> [-]
            - icon image sources
              - https://www.opensecurityarchitecture.org/cms/library/icon-library
              - https://network.yamaha.com/support/download/tool
              - https://knowledge.sakura.ad.jp/4724/
    
    Input:
        # how to cook curry

        -- rice --
        A wash rice [-]
        note right
          this is note
        end note
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

        B --> C #line:transparent : at least\n30 minutes

        legend right
          this is legend
        end legend
    
    Output:
        @startuml
        
        title "how to cook curry"
        skinparam DefaultFontName "MS Gothic"
        skinparam roundCorner 15
        skinparam shadowing false
        
        
        'Node settings
        
        folder "rice" as G1 {
          rectangle "**A**\nwash rice" as A
        note right
          this is note
        end note
          rectangle "**B**\nsoak rice in fresh water" as B
          rectangle "**C**\ncook rice" as C
        
        }
        
        folder "curry roux" as G2 {
          rectangle "**D**\ncut vegetables" as D
          rectangle "**E**\ncut meat into cubes" as E
          rectangle "**F**\nstew vegetables and meat" as F
          rectangle "**G**\nadd curry roux and simmer" as G
        
        }
        
          rectangle "**H**\nserve on plate" as H
          rectangle "**I**\ncomplete!" as I
        
        
        'Edge settings
        A --> B
        B --> C
        D --> F
        E --> F
        F --> G
        C --> H
        G --> H
        H --> I
        
        'Edge optional settings
        B --> C #line:transparent : at least\n30 minutes
        
        legend right
          this is legend
        end legend
        
        @enduml

.LINK
    pu2java, dot2gviz, pert, pert2dot, pert2gantt2pu, mind2dot, mind2pu, gantt2pu, logi2dot, logi2dot2, logi2dot3, logi2pu, logi2pu2, flow2pu, seq2pu


.PARAMETER OutputFile
    Output file name.

.PARAMETER Title
    Insert title.

.PARAMETER IdTail
    Paste the ID ad the end of the label.
    Default: Paste the ID at the top of the label.

.PARAMETER IdDelim
    Put the specified string between the ID and the label.
    Default: "\n"

.PARAMETER OffId
    Do not put the ID on the label.
    Default: Paste the ID at the top of label.

.PARAMETER Shadow
    cast a shadow

.PARAMETER LeftToRightDirection
    left to right direction -> on

.PARAMETER BottomToTopDirection
    Reset "-->" to "-up->"

.PARAMETER RightToLeftDirection    
    left to right direction -> on
    Reset "-->" to "-up->"

.PARAMETER Scale
    Scale of output image
    Default: Scale = 1.0

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

    e.g. #pink;line:red;line.bold;text:red

.PARAMETER OffBorder
    skinparam RectangleBorderColor #White
    skinparam RectangleBackgroundColor #White

.PARAMETER Monochrome
    skinparam monochrome true
    skinparam RectangleBorderColor #White
    skinparam RectangleBackgroundColor #White

.PARAMETER FoldLabel
    Fold the label at specified number of characters.

.PARAMETER Kinsoku
    Fold the label at the specified number of characters
    considering illegal characters.

    Specify a numeric values as 1 half-width character or
    2 full-width characters.

    Depends on kinsoku_function.ps1

.PARAMETER AddStartNode
    Add "start" node

.PARAMETER ReverseEdgeDir
    矢印の向きを反対向きにする

.PARAMETER ReverseEdgeDir
    Reverse the direction of the arrow.

.PARAMETER AddEdgeLabel
    Sequential numbering of edges(arrows).

    The header character can be changed with
    -AddEngeLabesStr option.

.EXAMPLE
    cat input.txt
    # logic tree

    Goal Making a profit for the company [ReqA, ReqB]

    -- GroupA --
    ReqA Secure sales [ActA]
    ActA Reduce the price [-]

    -- GroupB --
    ReqB Secure profits [ActB]
    ActB keep the price [-]

    ActA <-> ActB #line:red : conflict！

    PS > cat input.txt | logi2pu > a.pu; pu2java a.pu svg | ii
        @startuml

        title "logic tree"
        skinparam DefaultFontName "MS Gothic"
        skinparam roundCorner 15
        skinparam shadowing false


        'Node settings

        rectangle "**Goal**\nMaking a profit for the company" as Goal

        rectangle "GroupA" as G1 {
        '-- GroupA --
          rectangle "**ReqA**\nSecure sales" as ReqA
          rectangle "**ActA**\nReduce the price" as ActA
        }

        rectangle "GroupB" as G2 {
        '-- GroupB --
          rectangle "**ReqB**\nSecure profits" as ReqB
          rectangle "**ActB**\nkeep the price" as ActB
        }


        'Edge settings
        ReqA --> Goal
        ReqB --> Goal
        ActA --> ReqA
        ActB --> ReqB

        'Edge optional settings
        ActA <-> ActB #line:red : conflict！


        @enduml
#>
function logi2pu {
    Param(
        [Parameter(Mandatory=$False)]
        [Alias('o')]
        [string]$OutputFile,

        [Parameter(Mandatory=$False)]
        [string]$Title,

        [Parameter(Mandatory=$False)]
        [switch]$LeftToRightDirection,

        [Parameter(Mandatory=$False)]
        [switch]$BottomToTopDirection,

        [Parameter(Mandatory=$False)]
        [switch]$RightToLeftDirection,

        [Parameter(Mandatory=$False)]
        [switch]$ReverseEdgeDir,

        [Parameter(Mandatory=$False)]
        [switch]$IdTail,

        [Parameter(Mandatory=$False)]
        [string]$IdDelim = '\n',

        [Parameter(Mandatory=$False)]
        [switch]$OffId,

        [Parameter(Mandatory=$False)]
        [switch]$Shadow,

        [Parameter(Mandatory=$False)]
        [double]$Scale,

        [Parameter(Mandatory=$False)]
        [regex]$Grep,

        [Parameter(Mandatory=$False)]
        [ValidateSet(
            "actor", "agent", "artifact", "boundary",
            "card", "cloud", "component", "control",
            "database", "entity", "file", "folder",
            "frame", "interface", "node", "package",
            "queue", "stack", "rectangle", "storage",
            "usecase")]
        [string]$GrepShape = "rectangle",

        [Parameter(Mandatory=$False)]
        [string]$GrepColor = 'pink',

        [Parameter(Mandatory=$False)]
        [switch]$Monochrome,

        [Parameter(
            Mandatory=$False)]
        [switch]$OffBorder,

        [Parameter(Mandatory=$False)]
        [switch]$HandWritten,

        [Parameter(Mandatory=$False)]
        [string]$FontName,

        [Parameter(Mandatory=$False)]
        [string]$FontNameWindowsDefault = "MS Gothic",

        [Parameter(Mandatory=$False)]
        [int]$FontSize,

        [Parameter( Mandatory=$False)]
        [ValidateSet(
            "none", "amiga", "aws-orange", "blueprint", "cerulean",
            "cerulean-outline", "crt-amber", "crt-green",
            "mars", "mimeograph", "plain", "sketchy", "sketchy-outline",
            "spacelab", "toy", "vibrant"
        )]
        [string]$Theme,

        [Parameter(Mandatory=$False)]
        [ValidateSet(
            "actor", "agent", "artifact", "boundary",
            "card", "cloud", "component", "control",
            "database", "entity", "file", "folder",
            "frame", "interface", "node", "package",
            "queue", "stack", "rectangle", "storage",
            "usecase")]
        [string]$NodeShape = "rectangle",

        [Parameter(Mandatory=$False)]
        [ValidateSet(
            "actor", "agent", "artifact", "boundary",
            "card", "cloud", "component", "control",
            "database", "entity", "file", "folder",
            "frame", "interface", "node", "package",
            "queue", "stack", "rectangle", "storage",
            "usecase")]
        [string]$NodeShapeFirst,

        [Parameter(Mandatory=$False)]
        [ValidateSet(
            "artifact", "card", "cloud", "component", "database",
            "file", "folder", "frame", "hexagon", "node",
            "package", "queue", "rectangle", "stack", "storage")]
        [string]$GroupShape = "folder",

        [Parameter(Mandatory=$False)]
        [int]$FoldLabel,

        [Parameter(Mandatory=$False)]
        [int]$Kinsoku,

        [Parameter(Mandatory=$False)]
        [string]$KinsokuDelim = '\n',

        [Parameter(Mandatory=$False)]
        [switch]$OffRoundCorner,

        [Parameter(Mandatory=$False)]
        [switch]$AddStartNode,

        [Parameter(Mandatory=$False)]
        [switch]$AddEdgeLabel,

        [Parameter(Mandatory=$False)]
        [string]$AddEdgeLabelStr = "e",

        [Parameter( Mandatory=$False)]
        [string]$Spaces = '  ',

        [Parameter(Mandatory=$False,
            ValueFromPipeline=$True)]
        [string[]]$Text
    )

    begin{
        ## init var
        [string] $wspace            = ''
        [string] $edgeJoinDelim     = "@e@d@g@e@"
        [int] $addEdgeLabelCounter  = 0
        [int] $lineCounter          = 0
        [int] $groupCounter         = 0
        [int] $nodeCounter          = 0
        [int] $oldItemLevel         = 0
        [int] $newItemLevel         = 0
        [string[]] $readLineAry     = @()
        [string[]] $readLineAryNode = @()
        $readLineAryNode += ''
        $readLineAryNode += "'Node settings"
        if($AddStartNode){
            $readLineAryNode += $wspace + "$NodeShape ""start"" as start"
        }
        [string[]] $readLineAryEdge = @()
        $readLineAryEdge += ''
        $readLineAryEdge += "'Edge settings"
        [string[]] $readLineAryEdgeOpt = @()
        $readLineAryEdgeOpt += ''
        $readLineAryEdgeOpt += "'Edge optional settings"
        ## flags
        [bool] $isFirstRowEqTitle = $False
        [bool] $NodeBlockFlag     = $True  # Loading node
        [bool] $NodeGroupFlag     = $False # Loading node group
        [bool] $EdgeBlockFlag     = $False # Loading edge block
        [bool] $RawBlockFlag      = $False # Loading note block
        ## set private function
        function isCommandExist ([string]$cmd) {
            try { Get-Command $cmd -ErrorAction Stop > $Null
                return $True
            } catch {
                return $False
            }
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
            ## "<img:" tag output as-is
            if($str -notmatch '<img:'){
                $str = Write-Output "$str" | kinsoku @KinsokuParams
            }
            return $str
        }
        function parseImageNode ([string]$rdLine){
            ## "id <img:image.png|label> [prec]" convert to
            ## "id <img:image.png>\nlabel [prec]"
            $rdLine = $rdLine -Replace '<img:(..*)\|(..*)>','<img:$1>\n$2'
            return $rdLine
        }
        function parseNode ([string]$rdLine, [string]$nodeSpaces = $Spaces){
            $nodeKey  = $rdLine -replace '^([^ ]+?) (..*) +\[(..*)\]\s*$','$1'
            $nodeVal  = $rdLine -replace '^([^ ]+?) (..*) +\[(..*)\]\s*$','$2'
            $nodeKey  = $nodeKey.Trim()
            $nodeVal  = $nodeVal.Trim()
            $nodeKeyVal = "$nodeKey $nodeVal"
            if($FoldLabel){
                ## fold label
                $regStr = '('
                $regStr += '.' * $FoldLabel
                $regStr += ')'
                $reg = [regex]$regStr
                $nodeVal = $nodeVal -Replace $reg,'$1\n'
                $nodeVal = $nodeVal -Replace '\\n$',''
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
                $labelKey = "**$nodeKey**" + $IdDelim
                $nodeLabel = "$labelKey" + $nodeVal
            } elseif ($IdTail) {
                ## key at tail
                #$labelKey = "**【$nodeKey】**"
                $labelKey = "**[$nodeKey]**"
                $nodeLabel = $nodeVal + "\n\n...$labelKey"
            } else {
                ## key at head
                $labelKey = "**$nodeKey**."
                $nodeLabel = "$labelKey" + $nodeVal
            }
            if (($NodeShapeFirst) -and ($nodeCounter -eq 1)){
                ## Given the shape of the first node
                $nShape = $NodeShapeFirst
                $nColor = ''
                if ($Grep){
                    if ($nodeKeyVal -match $Grep){
                        $nColor = "#" + $GrepColor
                    }
                }
            } elseif ($Grep) {
                if ($nodeKeyVal -match $Grep){
                    ## Reshape only matched nodes
                    $nShape = $GrepShape
                    $nColor = "#" + $GrepColor
                } else {
                    $nShape = $NodeShape
                    $nColor = ''
                }
            } else {
                ## default node shape
                $nShape = $NodeShape
                $nColor = ''
            }
            $nodeStr = $nodeSpaces + "$nShape ""$nodeLabel"" as $nodeKey $nColor"
            $nodeStr = $nodeStr -Replace '  *$',''
            return $nodeStr
        }
        function parseEdge ([string]$rdLine) {
            [string[]]$retStrAry = @()
            if ( $rdLine -notmatch '\[' ){
                Write-Error "Invalid task specification." -ErrorAction Stop
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
                    $retStrAry += "$from --> $($to.Trim())"
                } else {
                    ## if no "start" node is specified, nothing is output.
                    $retStrAry += ''
                }
            } elseif ($dPrec -match ','){
                ## if the preceding task is separated by commas,
                ## the process branches ito multiple.
                [string[]] $splitId = $dPrec.Split(',')
                for($j = 0; $j -lt $splitId.Count; $j++){
                    [string] $from = [string]($splitId[$j])
                    [string] $to   = $dId
                    $retStrAry += "$($from.Trim()) --> $($to.Trim())"
                }
            } else {
                ## if the preceding task is not separated by comma,
                ## there is only one preceding task.
                $from = $dPrec
                $to   = $dId
                $retStrAry += "$($from.Trim()) --> $($to.Trim())"
            }
            return $($retStrAry -Join "$edgeJoinDelim")
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
            [string] $res = $Spaces * ($iLevel - 1) + "}"
            return $res
        }
    }
    process{
        $lineCounter++
        [string] $rdLine = [string] $_
        if ( $rdLine -match '^(\-)+ [^-]'){
            [string] $rdLine = replaceHyphensToSharps $rdLine
        }
        Write-Debug $rdLine
        if (($lineCounter -eq 1) -and ($rdLine -match '^# ')) {
            ## treat first line as title
            $fTitle = $rdLine -replace '^# ', ''
            $isFirstRowEqTitle = $true
            return
        }
        if ($rdLine -match "^\![di]|^skinparam|^'") {
            ## skip line beginning with "!" or "skinparam"
            ## e.g. !define, !include
            $readLineAryNode += $rdLine
            return
        }
        ## Node grouping mode = ON
        ## from "## GroupName" to the next blank line.
        if ( ($rdLine -match '^##+') -and ($NodeBlockFlag)){
            ## get group name
            $NodeGroupFlag = $True
            $groupCounter++
            $groupId = "G" + [string]$groupCounter
            [string] $groupName = $rdLine -replace '^##+\s*',''
            [string] $groupName = $groupName.Trim()
            ## get itemlevel
            [int] $newItemLevel = getItemLevel $rdLine
            Write-Debug "ItemLevel: old = $oldItemLevel, new = $newItemLevel"
            if ($newItemLevel -eq $oldItemLevel){
                [string] $wspace = $Spaces * ($newItemLevel - 1)
                ## close parenthesis
                $readLineAryNode += closeParenthesisForLevel $oldItemLevel
                $readLineAryNode += ''
            } elseif ($newItemLevel -gt $oldItemLevel){
                [string] $wspace = $Spaces * ($newItemLevel - 1)
            } elseif ($newItemLevel -lt $oldItemLevel){
                [string] $wspace = $Spaces * ($newItemLevel -1)
                for ( $i=$oldItemLevel; $i -ge $newItemLevel; $i--){
                    $readLineAryNode += closeParenthesisForLevel $i
                }
                $readLineAryNode += ''
            } else {
                Write-Error "error: Unknown error. Unable to detect hierarchy: $rdLine" -ErrorAction Stop
            }
            if ( ($Grep) -and ($groupName -match $Grep) ){
                $readLineAryNode += $wspace + "$GroupShape ""$groupName"" as $groupId #$GrepColor {"
            } else {
                $readLineAryNode += $wspace + "$GroupShape ""$groupName"" as $groupId {"
            }
            [int] $oldItemLevel = $newItemLevel
            return
        }
        ## Output line starting with "note" or "legend" as-is
        if ($rdLine -match '^legend'){
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
            if ($rdLine -match '^legend$'){
                $rdLine = 'legend right'
            }
            $RawBlockFlag = $True
        }
        if ($rdLine -match '^note'){
            if ($rdLine -match '^note$'){
                $rdLine = 'note right'
            }
            $RawBlockFlag = $True
        }
        ## if "<--" or "-->" of "<->" appears,
        ## When line starting with "end" appears,
        ## RowBlock mode ends.
        if ($rdLine -match '^end (note|legend)$'){
            $RawBlockFlag = $False
        }
        # end of node block,
        # start of edge block
        if ($rdLine -match ' \<[-.~=]{2} | [-.~=]{2}\> | \<[-.~=]+\> '){
            $NodeBlockFlag = $False
            $EdgeBlockFlag = $True
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
                $NodeGroupFlag = $False
            }
        }
        ## if "--" appears, call closeParenthesis
        if ("$rdLine".Trim() -match '^(\-)+$'){
            ## close group if not closed
            if ( $oldItemLevel -ne 0) {
                ## close parenthesis
                for ( $i=$oldItemLevel; $i -ge 1; $i--){
                    $readLineAryNode += closeParenthesisForLevel $i
                }
                Write-Debug "ItemLevel: old = $oldItemLevel, new = $newItemLevel"
                [int] $oldItemLevel = 0
                [int] $newItemLevel = 0
                $NodeGroupFlag = $False
            }
            return
        }
        ## Node block reading mode
        if ($NodeBlockFlag){
            if ($RawBlockFlag){
                ## RawBlock reading mode
                ## output as-is
                $readLineAryNode += $wspace + $rdLine
            } elseif ($rdLine -match '^\s*$'){
                ## Skip blank line
                $readLineAryNode += ''
            } elseif ($rdLine -match '^//'){
                ## Output comment
                $readLineAryNode += $rdLine -replace '^//',"'"
            } elseif ($rdLine -match '^end (note|legend)$'){
                ## Output as-is if line beginning with "end"
                $readLineAryNode += $wspace + $rdLine
            } elseif ($rdLine -match '<img:'){
                ## Image node dedicated processing
                $nodeCounter++
                $rdLine = parseImageNode $rdLine
                $readLineAryNode += $wspace + $rdLine
            } else {
                ## Read node
                $nodeCounter++
                ## key is the leftmost column,
                ## the others are the value
                $splitLine = $rdLine.Split(' ')
                if ($splitLine.Count -lt 2){
                    Write-Error "Insufficient columns: $rdLine" -ErrorAction Stop
                }
                if ( $NodeGroupFlag ){
                    [string] $nSpaces = $Spaces * ($newItemLevel)
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
                        if (($BottomToTopDirection) -or ($RightToLeftDirection)){
                            ## For Bottom -> Top, Right -> Left,
                            ## rewrite the edge from "-->" to "-up->"
                            $tmpStr = $tmpStr -replace ' \-\-> ',' -up-> '
                        }
                        if ($ReverseEdgeDir){
                            $tmpStr = $tmpStr -replace ' \-\-> ',' <-- '
                            $tmpStr = $tmpStr -replace ' \-up\-> ',' <-up- '
                        }
                        if ($AddEdgeLabel){
                            ## Generate edge label
                            $addEdgeLabelCounter++
                            $tmpEdgeLabel = $AddEdgeLabelStr + [string]$addEdgeLabelCounter
                            $tmpStr = $tmpStr + ' : ' + $tmpEdgeLabel
                        }
                        $readLineAryEdge += $tmpStr
                    }
                }
            }
            return
        }
        ## Edge block reading mode
        ## Output as-is
        if ($EdgeBlockFlag){
            if ($RawBlockFlag){
                $readLineAryEdgeOpt += $rdLine
            } else {
                if ( $rdLine -match '^(..*)\-\-\>(..*):(..*)$' ){
                    $readLineAryEdgeOpt += $rdLine
                } elseif ( $rdLine -match '^\s*//' ){
                    [string] $rdLine = $rdLine -replace '^\s*//',"'"
                    $readLineAryEdgeOpt += $rdLine
                } else {
                    $readLineAryEdgeOpt += $rdLine
                }
            }
            return
        }

    }
    end {
        ## close group if not closed
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
        ##
        ## Header
        ##
        $readLineAryHeader = @()
        $readLineAryHeader += "@startuml"
        $readLineAryHeader += ""
        if ($Title){
            $readLineAryHeader += "title ""$Title"""
        } elseif ($isFirstRowEqTitle) {
            $readLineAryHeader += "title ""$fTitle"""
        } else {
            $readLineAryHeader += "'title none"
        }
        if (($LeftToRightDirection) -or ($RightToLeftDirection)){
            $readLineAryHeader += "left to right direction"
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
        if ($FontSize){
            $readLineAryHeader += "skinparam defaultFontSize $FontSize"
        }
        if (!$OffRoundCorner){
            $readLineAryHeader += "skinparam roundCorner 15"
        }
        if ($Monochrome){
            $readLineAryHeader += "skinparam monochrome true"
            $readLineAryHeader += "skinparam ArrowColor #Black"
            $readLineAryHeader += "skinparam NoteBorderColor #Black"
            $readLineAryHeader += "skinparam NoteBackgroundColor #White"
            $readLineAryHeader += "skinparam RectangleBorderColor #Black"
            $readLineAryHeader += "skinparam RectangleBackgroundColor #White"
        }
        if ($OffBorder) {
            $readLineAryHeader += "skinparam RectangleBorderColor #White"
            $readLineAryHeader += "skinparam RectangleBackgroundColor #White"
        }
        if ($Shadow){
            $readLineAryHeader += "skinparam shadowing true"
        } else {
            $readLineAryHeader += "skinparam shadowing false"
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
        $readLineAryFooter = @()
        $readLineAryFooter += ""
        $readLineAryFooter += "@enduml"
        ## output
        foreach ($lin in $readLineAryHeader){
            $readLineAry += $lin
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
