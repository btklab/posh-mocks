<#
.SYNOPSIS
    flow2pu - Generate activity-diagram (flowchart) from markdown-like list format

    Easy and quick flow chart creator from lists written in markdown format.

    Reference:
        plantuml activity-diagram
        https://plantuml.com/en/activity-diagram-beta

    Simple input (markdown like list):
        # How to cook curry

        0. order {Counter}
        1. cut vegetables and meats {Kitchen}
        2. fry meats
        3. fry vegetables
            + **Point**: Fry the onions until they are translucent
        4. boil meat and vegetables
            + If you have Laurel, put it in, and take the lye
        5. add roux and simmer
        6. serve on a plate {Counter}
        7. topping
            - add garam masala

    Create flowchart (activity-diagram) example:
        PS > cat a.md | flow2pu -Kinsoku 10 -KinsokuNote 20 > a.pu; pu2java a.pu svg | ii


    Format:
        Available list formats are:
            1. First step
            2. Second step
            - Third step
            + Fourth step
            * Fifth step

        Indented item treated as note block:
            1. First step
                - Indented item = note (left note)
                - Indented item = note
                - Indented item = note
            2. Second step
                + Indented item = note (right note)
                + Indented item = note
                + Indented item = note
            3. Hyphen is note left, otherwise note right
            4. Indented lists are interpreted as notes
               regardless of depth.

        Level 1 header written on the first line is the title:
        
        Level 2 headers are partitioned up to the next blank line
        or the next level 2 header

        "{ }" at the end of the list is a swimlane

            1. First step {swimlane1}
            2. Second step {swimlane2}
            3. Third step {#AntiqueWhite|swimlane3}
            4. Fourth step {swimlane2}
            5. Fifth step {swimlane1}
        
        Legend can be output by writing the following:

            legend right|left
            this is legend
            end legend
    
        Fill color can be specified by prepending [#color]
        to the label. For example:

            - [#orange] label

.LINK
    pu2java, dot2gviz, pert, pert2dot, pert2gantt2pu, mind2dot, flow2pu, gantt2pu, logi2dot, logi2dot2, logi2dot3, logi2pu, logi2pu2, flow2pu, seq2pu


.PARAMETER Title
    insert title

.PARAMETER Scale
    default = 1.0

.PARAMETER Kinsoku
    Wrapping of character string considering japanese KINSOKU rules.
    Specify numerical value as 1 for ASCII characters
    and 2 for mulibyte characters.

    Depends on kinsoku_function.ps1

.PARAMETER LegendRight
    Insert legend in bottom right

.PARAMETER LegendLeft
    Insert legend in bottom left


.EXAMPLE
    Simple input (markdown like list)
    # How to cook curry

    0. order {Counter}
    1. cut vegetables and meats {Kitchen}
    2. fry meats
    3. fry vegetables
        + **Point**: Fry the onions until they are translucent
    4. boil meat and vegetables
        + If you have Laurel, put it in, and take the lye
    5. add roux and simmer
    6. serve on a plate {Counter}
    7. topping
        - add garam masala


    # Create flowchart (activity-diagram)
    PS > cat a.md | flow2pu -Kinsoku 10 -KinsokuNote 20 > a.pu; pu2java a.pu svg | ii

.EXAMPLE
    Complex input

    # How to cook curry

    |Counter|
    start

    ## Order
    0. order

    |#LightGray|Kitchen|

    ## Preparation
    1. cut vegetables and meats

    ## Fry
    2. fry meats
    if (is there \n cumin seed?) then (yes)
    - fry cumin seed
    else (no)
    endif
    3. fry vegetables
        + **Point**
        + Fry the onions until they are translucent

    ## Boil
    4. boil meat and vegetables
        + If you have Laurel, put it in, and take the lye
    5. add roux and simmer

    |Counter|

    ## Finish
    6. serve on a plate
    7. topping
        - add garam masala
    end


    ## output activity-diagram
    PS > cat a.md | flow2pu -Kinsoku 16 -KinsokuNote 20 > a.pu; pu2java a.pu svg | ii

#>
function flow2pu {
    Param(
        [Parameter( Mandatory=$False)]
        [Alias('o')]
        [string] $OutputFile,

        [Parameter( Mandatory=$False)]
        [string] $Title,

        [Parameter( Mandatory=$False)]
        [double] $Scale,

        [Parameter( Mandatory=$False)]
        [switch] $Monochrome,

        [Parameter( Mandatory=$False)]
        [switch] $HandWritten,

        [Parameter(Mandatory=$False)]
        [regex]$Grep,

        [Parameter( Mandatory=$False)]
        [string] $FontName,

        [Parameter( Mandatory=$False)]
        [int] $FontSize,

        [Parameter( Mandatory=$False)]
        [string] $FontNameWindowsDefault = "MS Gothic",

        [Parameter( Mandatory=$False)]
        [ValidateSet(
            "none", "amiga", "aws-orange", "blueprint", "cerulean",
            "cerulean-outline", "crt-amber", "crt-green",
            "mars", "mimeograph", "plain", "sketchy", "sketchy-outline",
            "spacelab", "toy", "vibrant"
        )]
        [string] $Theme,

        [Parameter( Mandatory=$False)]
        [int] $Kinsoku,

        [Parameter( Mandatory=$False)]
        [int] $KinsokuNote,

        [Parameter( Mandatory=$False)]
        [string[]] $LegendRight,

        [Parameter( Mandatory=$False)]
        [string[]] $LegendLeft,

        [Parameter( Mandatory=$False,
            ValueFromPipeline=$True)]
        [string[]] $Text
    )

    begin{
        ## init var
        [int] $lineCounter = 0
        [bool] $isFirstRowEqTitle = $False
        [bool] $isLegend = $False
        [bool] $isNoteBlock = $False
        [bool] $isPartitionBlock = $False
        [string[]] $readLineAry = @()
        [string[]] $readLineAryNode = @()
        ## private function
        function isCommandExist ([string]$cmd) {
            try { Get-Command $cmd -ErrorAction Stop > $Null
                return $True
            } catch {
                return $False
            }
        }
        ## test and dot sourcing kinsoku command
        if ($Kinsoku -or $KinsokuNote ){
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
            }
            $KinsokuParams.Set_Item('Expand', $True)
            $KinsokuParams.Set_Item('OffTrim', $True)
            [string] $str = Write-Output "$str" | kinsoku @KinsokuParams
            return $str
        }
        function execKinsokuToNote ([string]$str){
            ## splatting
            $KinsokuParams = @{
                Width = $KinsokuNote
            }
            $KinsokuParams.Set_Item('Expand', $False)
            $KinsokuParams.Set_Item('OffTrim', $True)
            [string[]] $strAry = Write-Output "$str" | kinsoku @KinsokuParams
            return $strAry
        }
    }
    process{
        $lineCounter++
        [string] $rdLine = [string] $_
        ## first line title
        if (($lineCounter -eq 1) -and ($rdLine -match '^# ')) {
            $fTitle = $rdLine -replace '^# ', ''
            $isFirstRowEqTitle = $True
            return
        }
        ## end note block if detect empty line
        if ( $rdLine -eq '' -and $isNoteBlock){
            [bool] $isNoteBlock = $False
            $readLineAryNode += "  end note"
            $readLineAryNode += ''
            return
        }
        ## end note block if detect "^## "
        if ( $rdLine -match '^## ' -and $isNoteBlock){
            [bool] $isNoteBlock = $False
            $readLineAryNode += "  end note"
        }
        if ( $rdLine -eq '' -and $isPartitionBlock){
            [bool] $isPartitionBlock = $False
            $readLineAryNode += "}"
            $readLineAryNode += ''
            return
        }
        ## convert target block
        if (($rdLine -match '^\s*[-+*]+|^\s*[0-9]+\.') -and (-not $isLegend)){
            if ( $rdLine -match '^\s+') {
                ## note
                if ( $isNoteBlock ){
                    ## continue note block
                    [string] $noteStr = $rdLine -replace '^(\s*)[-+*]+|^\s*[0-9]+\.', '$1'
                    [string] $noteStr = $noteStr.Trim()
                    ## Apply kinsoku
                    if ($KinsokuNote) {
                        [string[]] $noteAry = execKinsokuToNote $noteStr
                        foreach ( $no in $noteAry ){
                            $readLineAryNode += "    $no"
                        }
                    } else {
                        $readLineAryNode += "    $noteStr"
                    }
                } else {
                    ## start note block
                    if ( $rdLine -match '^\s+\-'){
                        $readLineAryNode += "  note left"
                    } else {
                        $readLineAryNode += "  note right"
                    }
                    [string] $noteStr = $rdLine -replace '^(\s*)[-+*]+|^\s*[0-9]+\.', '$1'
                    [string] $noteStr = $noteStr.Trim()
                    ## Apply kinsoku
                    if ($KinsokuNote) {
                        [string[]] $noteAry = execKinsokuToNote $noteStr
                        foreach ( $no in $noteAry ){
                            $readLineAryNode += "    $no"
                        }
                    } else {
                        $readLineAryNode += "    $noteStr"
                    }
                }
                [bool] $isNoteBlock = $True
                return
            }
            ## end note block
            if ( $isNoteBlock ){
                [bool] $isNoteBlock = $False
                $readLineAryNode += "  end note"
            }
            ## target row pattern:
            ## - flow1 {swim}
            ## - [#pink] flow1
            ## - flow1 {swim}
            ## - [#pink] flow1 {swim}
            [string] $preSpaces = $rdLine -replace '^(\s*)([-+*]+|[0-9]+\.)(..*)$','$1'
            [string] $preMark   = $rdLine -replace '^(\s*)([-+*]+|[0-9]+\.)(..*)$','$2'
            [string] $contents  = $rdLine -replace '^(\s*)([-+*]+|[0-9]+\.)(..*)$','$3'
            [string] $contents  = $contents.Trim()
            if ($contents -match '\{[^\}]+\}$'){
                ## set swimLane when contents -eq '- contents {swim}'
                [string] $swimLane  = $contents -replace '^(..*)\{([^\}]+)\}$','$2'
                [string] $contents  = $contents -replace '^(..*)\{([^\}]+)\}$','$1'
                $readLineAryNode += "| $swimLane |"
            }
            if ($contents -match '^\[#'){
                ## if color specifiacation (prefix) e.g. [#orange] contents
                [string] $colorName = $contents -replace '^\[(#[^\]]+)\](..*)$','$1'
                [string] $contents  = $contents -replace '^\[(#[^\]]+)\](..*)$','$2'
            } else {
                [string] $colorName = ''
            }
            [string] $colorName = $colorName.Trim()
            [string] $contents  = $contents.Trim()
            ## Grep contents
            if ( $Grep -and $contents -match $Grep ){
                $colorName = "#pink"
            }
            ## Apply kinsoku
            if ($Kinsoku) {
                $contents = execKinsoku $contents
            }
            ## set node
            $readLineAryNode += $colorName + ':' + $contents + ';'

        } elseif ( $rdLine -match '^## '){
            ## add partition
            [string] $newPartitionName = $rdLine -replace '^## (..*)$','$1'
            [string] $newPartitionName = $newPartitionName.Trim()
            ## add swimLane
            [string] $swimLane = ''
            if ( $newPartitionName -match '\s*\{[^\}]+\}$' ){
                [string] $swimLane = $rdLine -replace '^(..*)\{([^\}]+)\}$','$2'
                [string] $newPartitionName   = $newPartitionName -replace '^(..*)\{([^\}]+)\}$','$1'
                [string] $newPartitionName   = $newPartitionName -replace '\s*$', ''
            }
            if ( $isPartitionBlock ) {
                ## close and open partition block
                [bool] $isPartitionBlock = $True
                $readLineAryNode += "}"
                if ( $swimLane -ne ''){
                    $readLineAryNode += "| $swimLane |"
                }
                $readLineAryNode += "partition ""$newPartitionName"" {"
                return
            } else {
                ## open partition block
                [bool] $isPartitionBlock = $True
                if ( $swimLane -ne ''){
                    $readLineAryNode += "| $swimLane |"
                }
                $readLineAryNode += "partition ""$newPartitionName"" {"
                return
            }
        } else {
            ## end note block if detect "^## "
            if ( $isNoteBlock){
                [bool] $isNoteBlock = $False
                $readLineAryNode += "  end note"
            }
            ## add swimLane
            if ( $rdLine -match '\s*\{[^\}]+\}$' ){
                [string] $swimLane = $rdLine -replace '^(..*)\{([^\}]+)\}$','$2'
                [string] $rdLine   = $rdLine -replace '^(..*)\{([^\}]+)\}$','$1'
                [string] $rdLine   = $rdLine -replace '\s*$', ''
                $readLineAryNode += "| $swimLane |"
            }
            ## output as is
            $readLineAryNode += $rdLine
            ## is legend block?
            if (($lineCounter -gt 1) -and ($rdLine -match '^legend (right|left)$')){
                $isLegend = $True
            }
        }
    }
    end {
        if ( $isNoteBlock ){
            ## close note block
            [bool] $isNoteBlock = $False
            $readLineAryNode += "  end note"
            $readLineAryNode += ''
        }
        if ( $isPartitionBlock ){
            ## close partition block
            [bool] $isPartitionBlock = $False
            $readLineAryNode += "}"
            $readLineAryNode += ''
        }
        ##
        ## Header
        ##
        [string[]] $readLineAryHeader = @()
        $readLineAryHeader += "@startuml"
        $readLineAryHeader += ""
        if ($Title){
            $readLineAryHeader += "title ""$Title"""
        } elseif ($isFirstRowEqTitle) {
            $readLineAryHeader += "title ""$fTitle"""
        } else {
            $readLineAryHeader += "'title none"
        }
        if ($Scale){
            $readLineAryHeader += "scale $Scale"
        }
        if($IsWindows){
            ## case  windows
            if($FontName){
                $readLineAryHeader += "skinparam defaultFontName ""$FontName"""
            } else {
                $readLineAryHeader += "skinparam defaultFontName ""$FontNameWindowsDefault"""
            }
        } else {
            ## case linux and mac
            if($FontName){
                $readLineAryHeader += "skinparam defaultFontName ""$FontName"""
            }
        }
        if ($FontSize){
            $readLineAryHeader += "skinparam defaultFontSize $FontSize"
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
            [bool] $legendFlag = $True
            [string[]] $readLineAryLegend = @()
            $readLineAryLegend += ""
            $readLineAryLegend += "legend left"
            foreach($legLine in $LegendLeft){
                $readLineAryLegend += $legLine
            }
            $readLineAryLegend += "end legend"
        }elseif($LegendRight){
            [bool] $legendFlag = $True
            [string[]] $readLineAryLegend = @()
            $readLineAryLegend += ""
            $readLineAryLegend += "legend right"
            foreach($legLine in $LegendRight){
                $readLineAryLegend += $legLine
            }
            $readLineAryLegend += "end legend"
        }else{
            $legendFlag = $False
        }

        [string[]] $readLineAryFooter = @()
        $readLineAryFooter += ""
        $readLineAryFooter += "@enduml"
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
                ## save in UTF-8 (CRLF) without BOM
                $readLineAry -Join "`r`n" `
                    | Out-File "$OutputFile" -Encoding UTF8
            } else {
                ## save in UTF-8 (LF) without BOM
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
