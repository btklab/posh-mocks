<#
.SYNOPSIS
    mind2pu - Generate plantuml script to draw a mind map from list data in markdown format

    Mindmapping a hierarchical structure described in
    markdown list format. Input data is represented by
    "4 spaces" followed by "-,+,*". like:

        - root
            - child1
                - child1-1
            - child2
            - child3
    
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
    
    The 1st line begins with "# ", it is considered as a title.
    Blank lines are ignored.
    Lines beginning with "//" are treated as comments.
    
    Legend can be output by writing the following:

        legend right|left
        this is legend
        end legend
    
    Fill color can be specified by prepending or postponing
    [#color] to the label. For example:

        - [#orange] label
        - label [#blue]

    With -WBS switch, output Work Breakdown Structure diagram.
    (Add @startwbs and @endwbs instead of @startuml and @enduml)

    If you replace '*' with '-', it becomes a map that extends from
    right to left. This is equivalent to specifying -RightToLeft switch.

.LINK
    pu2java, dot2gviz, pert, pert2dot, pert2gantt2pu, mind2dot, mind2pu, gantt2pu, logi2dot, logi2dot2, logi2dot3, logi2pu, logi2pu2, flow2pu


.PARAMETER Title
    insert title

.PARAMETER Scale
    default = 1.0

.PARAMETER WBS
    Output Work Breakdown Structure diagram

.PARAMETER FoldLabel
    Fold label at specified number of characters.

.PARAMETER Kinsoku
    Wrapping of character string considering japanese KINSOKU rules.
    Specify numerical value as 1 for ASCII characters
    and 2 for mulibyte characters.

    Depends on kinsoku_function.ps1


.PARAMETER RightToLeft
    Right to left graph

.EXAMPLE
    cat input.txt
    # title

    - hogehoge
        - hoge1
            - hoge2_
            - hoge2_
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
    cat input.txt | mind2pu > a.pu; pu2java a.pu | ii
    @startmindmap

    title "title"
    skinparam DefaultFontName "MS Gothic"

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
    # WBS

    + <&flag> Presidend
        + hoge
            + piyo
        + fuga
            + 1st
                + A
                + P
                + S
            + 2nd
                + T
                + E
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
        [switch]$Raw,

        [Parameter( Mandatory=$False)]
        [switch]$HandWritten,

        [Parameter( Mandatory=$False)]
        [string]$FontName,

        [Parameter( Mandatory=$False)]
        [string]$FontNameWindowsDefault = "MS Gothic",

        [Parameter( Mandatory=$False)]
        [int]$FontSize,

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
        [switch]$RightToLeft,

        [Parameter( Mandatory=$False,
            ValueFromPipeline=$True)]
        [string[]]$Text
    )

    begin{
        ## init var
        $lineCounter = 0
        $isFirstRowEqTitle = $False
        $isLegend = $False
        $readLineAry = @()
        $readLineAryNode = @()
        ## private function
        function isCommandExist ([string]$cmd) {
            try { Get-Command $cmd -ErrorAction Stop > $Null
                return $True
            } catch {
                return $False
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
            }
            $KinsokuParams.Set_Item('Expand', $True)
            $KinsokuParams.Set_Item('OffTrim', $True)
            $str = Write-Output "$str" | kinsoku @KinsokuParams
            return $str
        }
        if($RightToLeft){$repMark = '-'}
    }
    process{
        $lineCounter++
        $rdLine = [string]$_
        ## first line title
        if (($lineCounter -eq 1) -and ($rdLine -match '^# ')) {
            $fTitle = $rdLine -replace '^# ', ''
            $isFirstRowEqTitle = $True
        ## target rows are beginning with "+" or "-" or "*"
        } elseif (($rdLine -match '^\s*[-+*]+') -and (-not $isLegend)){
            $ast = $rdLine -replace '^(\s*)([-+*]+).*$','$1'
            if($WBS){
                if ( $Raw ){
                    $repMark = $rdLine -replace '^(\s*)([-+*])+.*$','$2'
                } else {
                    $repMark = '*'
                }
            } else {
                $repMark = '*'
            }
            ## Handling leading whitespace
            $ast += $repMark
            $ast = $ast -replace (' ' * $Space),"$repMark"
            $contents = $rdLine -replace '^\s*[-+*]+\s*(.*)$','$1'
            if ($contents -match '^\[#'){
                ## if color specifiacation (prefix) e.g. [#orange] contents
                $colorName = $contents -replace '^(\[#[^\]]+\])(..*)$','$1'
                $contents  = $contents -replace '^(\[#[^\]]+\])(..*)$','$2'
                $ast = $ast + $colorName.Trim()
            }elseif ($contents -match '\[#[^\]]+]$'){
                ## if color specifiacation (postfix) e.g. contents [#orange]
                $colorName = $contents -replace '^(..*)(\[#[^\]]+\])$','$2'
                $contents  = $contents -replace '^(..*)(\[#[^\]]+\])$','$1'
                $ast = $ast + $colorName.Trim()
            }
            $contents = $contents.Trim()
            ## Underscore at the end of a sentence for
            ## "plain text without borders"
            $plainTextFlag = $False
            if ($contents -match '_$'){
                $plainTextFlag = $True
                $ast = $ast -replace '$','_ '
                $contents = $contents -replace '_$',''
            } else {
                $ast = $ast -replace '$',' '
            }
            ## fold strings
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
            ## Apply kinsoku
            if (($KinsokuOnlyPlainText) -and ($plainTextFlag)) {
                $contents = execKinsoku $contents
            } elseif ($Kinsoku) {
                $contents = execKinsoku $contents
            }
            ## set node
            $readLineAryNode += $ast + $contents
        } else {
            ## is legend block?
            if (($isLegend) -and ($rdLine -match '^end *legend$')){
                $readLineAryLeg += $rdLine
                $isLegend = $false
                return
            }
            if ($isLegend){
                $readLineAryLeg += $rdLine
                return
            }
            if (($lineCounter -gt 1) -and ($rdLine -match '^legend (right|left)$')){
                $readLineAryLeg = @()
                $readLineAryLeg += $rdLine
                $isLegend = $True
                return
            }
            ## output as is
            $readLineAryNode += $rdLine
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
        if ( $readLineAryLeg.Count -gt 0 ){
            foreach ( $leg in $readLineAryLeg ){
                $readLineAry += $leg
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
