<#
.SYNOPSIS
    seq2pu - Generate sequence-diagram from markdown-like list format

    Easy and quick sequence-diagram creator from lists written in
    markdown-like format.

    Reference:
        plantuml sequence-diagram
        https://plantuml.com/en/sequence-diagram

    Simple input (markdown like list):
        # How to cook curry

        Actor Alice as Alice
        box "in the kitchen"
        Participant Bob as Bob #white
        end box

        ## init

        0. Alice ->o Bob : order
        1. Bob --> Alice : cut vegetables and meats
        2. Alice -> Bob : fry meats
        3. Alice <- Alice : fry vegetables
            + **Point**
            + Fry the onions until they are translucent
        4. Alice -> Bob : boil meat and vegetables
            + If you have Laurel, put it in, and take the lye
        5. Bob --> Alice : add roux and simmer
        6. Alice -> Bob : serve on a plate
        7. Bob --> Alice : topping
            - add garam masala
    
    Create sequence-diagram example:
        cat a.md | seq2pu -KinsokuNote 24 -ResponseMessageBelowArrow > a.pu; pu2java a.pu svg | ii

    Format:
        Available list formats are:
            1. First step
            2. Second step
            - Third step
            + Fourth step
            * Fifth step

        Indented list treated as note block:
            1. First step
                - Indented item = note (left note)
                - Indented item = note
                - Activate key (parse as-is)
            2. Second step
                + Indented item = note (right note)
                + Indented item = note
                + Indented item = note
            3. Hyphen is note left, otherwise note right
            4. Indented lists are interpreted as a note regardless
               of the nesting depth, but if a keyword is included
               at the beginning of the line, output as-is as a
               plantuml statement.

        Indented list starting with the following keywords is
        interpreted as a plantuml statement as-is.

            Keywords:
                "activate"
                "deactivate"
                "destroy"
                "ref"
                "return"
                "..."

        Level 1 header written on the first line is the title.
        
        Level 2 headers divide diagram into logical steps

            ## section
                into
            == section ==

        Legend can be output by writing the following:

            legend right|left
              this is legend
            end legend

.LINK
    pu2java, dot2gviz, pert, pert2dot, pert2gantt2pu, mind2dot, gantt2pu, logi2dot, logi2dot2, logi2dot3, logi2pu, logi2pu2, seq2pu

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
    "Simple input (markdown like list):"

    # How to cook curry

    Actor Alice as Alice
    box "in the kitchen"
    Participant Bob as Bob #white
    end box

    ## init

    0. Alice ->o Bob : order
    1. Bob --> Alice : cut vegetables and meats
    2. Alice -> Bob : fry meats
    3. Alice <- Alice : fry vegetables
        + **Point**
        + Fry the onions until they are translucent
    4. Alice -> Bob : boil meat and vegetables
        + If you have Laurel, put it in, and take the lye
    5. Bob --> Alice : add roux and simmer
    6. Alice -> Bob : serve on a plate
    7. Bob --> Alice : topping
        - add garam masala
    
    # Create sequence-diagram:
    PS > cat a.md | seq2pu -KinsokuNote 24 -ResponseMessageBelowArrow > a.pu; pu2java a.pu svg | ii

.EXAMPLE
    "Complex input"

    # How to cook curry

    Actor Alice as Alice
    box "in the kitchen"
    Participant Bob as Bob #white
    end box

    ## init

    0. Alice ->o Bob : order
        - Activate Alice #gold
        - ref over Alice, Bob : recipe of curry

    1. Bob --> Alice : cut vegetables and meats

    2. Alice -> Bob : fry meats

    3. Alice <- Alice : fry vegetables
        + **Point**
        + Fry the onions until they are translucent
        - Deactivate Alice

        alt Laurel out of stock

    4. Alice -> Bob : boil meat and vegetables

        else Laurel in stock

    4. Alice -> Bob : boil meat and vegetables and Laurel
        + If you have Laurel, put it in, and take the lye

        end

    5. Bob --> Alice : add roux and simmer

        ...

    6. Alice -> Bob : serve on a plate

        ...5 minutes later...


    7. Bob --> Alice : topping
        - return bye
        - add garam masala

    # Create sequence-diagram:
    PS > cat a.md | seq2pu -KinsokuNote 24 -ResponseMessageBelowArrow > a.pu; pu2java a.pu svg | ii

#>
function seq2pu {
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

        [Parameter( Mandatory=$False)]
        [switch] $AutoActivate,

        [Parameter(Mandatory=$False)]
        [regex]$Grep,

        [Parameter( Mandatory=$False)]
        [string] $FontName,

        [Parameter( Mandatory=$False)]
        [string] $FontNameWindowsDefault = "MS Gothic",

        [Parameter( Mandatory=$False)]
        [int] $FontSize,

        [Parameter( Mandatory=$False)]
        [ValidateSet(
            "none", "amiga", "aws-orange", "blueprint", "cerulean",
            "cerulean-outline", "crt-amber", "crt-green",
            "mars", "mimeograph", "plain", "sketchy", "sketchy-outline",
            "spacelab", "toy", "vibrant"
        )]
        [string] $Theme,

        [Parameter( Mandatory=$False)]
        [ValidateSet( "right", "left", "center" )]
        [string] $SequenceMessageAlign,

        [Parameter( Mandatory=$False)]
        [switch] $ResponseMessageBelowArrow,

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
        [string[]] $readLineAry = @()
        [string[]] $readLineAryNode = @()
        [string[]] $ignoreKeywords = @(
            "note",
            "activate",
            "deactivate",
            "destroy",
            "ref",
            "return"
        )
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
        if ( $rdLine -match '^\s*$' -and $isNoteBlock){
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
        ## convert target block
        if (($rdLine -match '^\s*[-+*]+|^\s*[0-9]+\.') -and (-not $isLegend)){
            if ( $rdLine -match '^\s+') {
                ## note
                if ( $isNoteBlock ){
                    ## continue note block
                    ## ignore keywords
                    [string] $noteStr = $rdLine -replace '^\s+[-+*]+|^\s+[0-9]+\.', ''
                    [string] $noteStr = $noteStr.Trim()
                    [string] $noteKey = $noteStr -replace '^([^ ]+) .*$', '$1'
                    Write-Debug "noteKey: $noteKey"
                    foreach ( $ik in $ignoreKeywords ){
                        if ( $noteKey -eq $ik){
                            ## output as-is
                            [bool] $isNoteBlock = $False
                            $readLineAryNode += "  end note"
                            $readLineAryNode += "  $noteStr"
                            return
                        }
                    }
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
                    ## ignore keywords
                    [string] $noteStr = $rdLine -replace '^\s*[-+*]+|^\s*[0-9]+\.', ''
                    [string] $noteStr = $noteStr.Trim()
                    [string] $noteKey = $noteStr -replace '^([^ ]+) .*$', '$1'
                    Write-Debug "noteKey: $noteKey"
                    foreach ( $ik in $ignoreKeywords ){
                        if ( $noteKey -eq $ik){
                            ## output as-is
                            $readLineAryNode += "  $noteStr"
                            return
                        }
                    }
                    if ( $rdLine -match '^\s+\-'){
                        $readLineAryNode += "  note left"
                    } else {
                        $readLineAryNode += "  note right"
                    }
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
            ## - 1. Alice -> Bob : order
            [string] $contents  = $rdLine -replace '^(\s*)([-+*]+|[0-9]+\.)(..*)$','$3'
            [string[]] $splitContents = $contents -split ':', 2, "simplematch"
            if ( $splitContents.Count -ne 2 ){
                Write-Error "Missing separator "":"" in $rdLine" -ErrorAction Stop
            }
            [string] $sequence = $splitContents[0].Trim()
            [string] $contents = $splitContents[1].Trim()
            ## Grep contents
            if ( $Grep -and $contents -match $Grep ){
                $colorName = "#pink"
            }
            ## Apply kinsoku
            if ($Kinsoku) {
                $contents = execKinsoku $contents
            }
            ## set node
            $readLineAryNode += $sequence + ' : ' + $contents

        } elseif ( $rdLine -match '^## '){
            ## add partition
            [string] $newPartitionName = $rdLine -replace '^## (..*)$','$1'
            [string] $newPartitionName = $newPartitionName.Trim()
            $readLineAryNode += "== $newPartitionName =="
            return
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
        if ($SequenceMessageAlign){
            $readLineAryHeader += "skinparam sequenceMessageAlign $SequenceMessageAlign"
        }
        if ($ResponseMessageBelowArrow){
            $readLineAryHeader += "skinparam responseMessageBelowArrow true"
        }
        if ($AutoActivate) {
            $readLineAryHeader += "autoactivate on"
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
