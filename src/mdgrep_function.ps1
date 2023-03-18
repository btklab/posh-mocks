<#
.SYNOPSIS
    mdgrep - A multiline oriented searcher for markdown
    
    mdgrep searches for PATTERNS in each 2nd level section.
    if PATTERNS found in section title or contents, mdgrep
    returns the entire section title and body, instead of
    returns the single-line like grep does.
    
    Applicable to all text files using Markdown heading syntax
    with number signs (#) in front of a word or phrase.

    By default, output only the section titles that matches PATTERN.
    To utput both title and body, adding `-o|-VerboseOutput` option.

    Case insensitive.

    The number signs (#) written in the following block is ignored.
    Code blocks only support 3 and 4 backquote characters.
    Fence blocks only support 3 and 4 colon characters.

        Yaml Block
        Code Block  '``' and '````'
        Fence Block ':::' and '::::'
        Quote Block

    PS > cat README.md | mdgrep seq2pu -Level 3
        ### Plot chart and graph
        #### [dot2gviz] - Wrapper for Graphviz:dot command
        #### [pu2java] - Wrapper for plantuml.jar command
        #### [gantt2pu] - Visualizatoin tool of DANDORI-chart (setup-chart) for PlantUML.
        #### [mind2dot] - Generate graphviz script to draw a mind map from list data in markdown format
        #### [mind2pu] - Generate plantuml script to draw a mind map from list data in markdown format
        #### [logi2dot] - Generate data for graphviz with simple format
        #### [logi2pu] - Generate data for PlantUML (usecase diagram) with simple format
        #### [seq2pu] - Generate sequence-diagram from markdown-like list format
        #### [flow2pu] - Generate activity-diagram (flowchart) from markdown-like list format

    PS > cat README.md | mdgrep seq2pu -Level 4
        #### [seq2pu] - Generate sequence-diagram from markdown-like list format

    PS > cat README.md | mdgrep seq2pu -Level 4 -o
        # output contents in "#### seq2pu section"

.LINK
    mdgrep, mdgrep2, mdsort, mdsort2, mdparag


.EXAMPLE
    # input markdown
    $markdown = @(
        "# My favorite links",
        "abstract",
        "## HACCP",
        "hoge1",
        "### Books",
        "fuga1",
        "### Articles",
        "piyo1",
        "## Computer",
        "hoge2",
        "### Books",
        "fuga2",
        "### Articles",
        "piyo2"
    )

    # Search sectoin title and contens,
    # and output matched section titles.
    # Sections below heading level 2 are
    # searched by default
    PS > $markdown | mdgrep .
        ## HACCP
        ### Books
        ### Articles
        ## Computer
        ### Books
        ### Articles

    $markdown | mdgrep . -VerboseOutput
    $markdown | mdgrep . -o
        ## HACCP
        hoge1
        ### Books
        fuga1
        ### Articles
        piyo1
        ## Computer
        hoge2
        ### Books
        fuga2
        ### Articles
        piyo2

.EXAMPLE
    # grep section title and paragraph
    PS > $markdown | mdgrep hoge1 -o
        ## HACCP
        hoge1
        ### Books
        fuga1
        ### Articles
        piyo1


    PS > $markdown | mdgrep hoge1 -NotMatch -o
    PS > $markdown | mdgrep hoge1 -v -o
        ## Computer
        hoge2
        ### Books
        fuga2
        ### Articles
        piyo2


    PS > $markdown | mdgrep haccp -MatchOnlyTitle -o
    PS > $markdown | mdgrep haccp -t -o
        ## HACCP
        hoge1
        ### Books
        fuga1
        ### Articles
        piyo1

.EXAMPLE
    # invert match
        PS > $markdown | mdgrep haccp -MatchOnlyTitle -NotMatch -o
        PS > $markdown | mdgrep haccp -t -v -o
        ## Computer
        hoge2
        ### Books
        fuga2
        ### Articles
        piyo2

    PS > $markdown | mdgrep Books -MatchOnlyTitle
    PS > $markdown | mdgrep Books -t
        # not match because of grep only level2 section

.EXAMPLE
    # change section level to grep
    PS > $markdown | mdgrep fuga -Level 3 -o
    PS > $markdown | mdgrep fuga -l 3 -o
        ### Books
        fuga1
        ### Books
        fuga2

.EXAMPLE
    # Output parent sections
    PS > $markdown | mdgrep fuga -Level 3 -OutputParentSection -o
    PS > $markdown | mdgrep fuga -l 3 -p -o
        # My favorite links
        ## HACCP
        ### Books
        fuga1
        ## Computer
        ### Books
        fuga2


    # Note that the "-p|OutputParentSection" option
    #   outputs the titles regardless of matches.
    PS > $markdown | mdgrep fuga2 -Level 3 -p -o
        # My favorite links
        ## HACCP
        ## Computer
        ### Books
        fuga2

.EXAMPLE
    # Another example of parsing a text file with
    # Markdown-heading syntax applied.
    PS > cat README.md | mdgrep seq2pu -Level 3
        ### Plot chart and graph
        #### [dot2gviz] - Wrapper for Graphviz:dot command
        #### [pu2java] - Wrapper for plantuml.jar command
        #### [gantt2pu] - Visualizatoin tool of DANDORI-chart (setup-chart) for PlantUML.
        #### [mind2dot] - Generate graphviz script to draw a mind map from list data in markdown format
        #### [mind2pu] - Generate plantuml script to draw a mind map from list data in markdown format
        #### [logi2dot] - Generate data for graphviz with simple format
        #### [logi2pu] - Generate data for PlantUML (usecase diagram) with simple format
        #### [seq2pu] - Generate sequence-diagram from markdown-like list format
        #### [flow2pu] - Generate activity-diagram (flowchart) from markdown-like list format

    PS > cat README.md | mdgrep seq2pu -Level 4
    #### [seq2pu] - Generate sequence-diagram from markdown-like list format

    PS > cat README.md | mdgrep seq2pu -Level 4 -o
    # output contents in "#### seq2pu section"

#>
function mdgrep {

    param (
        [Parameter( Mandatory=$False, Position=0 )]
        [Alias('g')]
        [string] $Grep,
        
        [Parameter( Mandatory=$False )]
        [ValidateRange(1,6)]
        [Alias('l')]
        [int] $Level = 2,
        
        [Parameter( Mandatory=$False )]
        [Alias('t')]
        [switch] $MatchOnlyTitle,
        
        [Parameter( Mandatory=$False )]
        [Alias('o')]
        [switch] $VerboseOutput,
        
        [Parameter( Mandatory=$False )]
        [Alias('p')]
        [switch] $OutputParentSection,
        
        [Parameter( Mandatory=$False )]
        [Alias('v')]
        [switch] $NotMatch,
        
        [parameter( Mandatory=$False, ValueFromPipeline=$True )]
        [string[]] $InputText
    )

    begin {
        # init variables
        [int] $rowCounter = 0
        [int] $secLevel   = 0
        [string] $stat = 'init'
        [bool] $inYamlBlock   = $False
        [bool] $inCodeBlock   = $False
        [bool] $inCodeBlock3  = $False
        [bool] $inCodeBlock4  = $False
        [bool] $inFenceBlock  = $False
        [bool] $inFenceBlock3 = $False
        [bool] $inFenceBlock4 = $False
        [bool] $inQuoteBlock  = $False
        [bool] $isSection     = $False
        [bool] $matchFlag     = $False
        $tempAryList = New-Object 'System.Collections.Generic.List[System.String]'

        # private function
        function replaceSecToNum ( [string] $section ){
            if ( $section -match '^#{1} ') { return 1 }
            if ( $section -match '^#{2} ') { return 2 }
            if ( $section -match '^#{3} ') { return 3 }
            if ( $section -match '^#{4} ') { return 4 }
            if ( $section -match '^#{5} ') { return 5 }
            if ( $section -match '^#{6} ') { return 6 }
        }
    }

    process {
        $rowCounter++
        [string] $readLine = [string] $_
        # is Code block?
        if ( $readLine -match '^```') {
            if ( $readLine -match '^````') {
                # code chunk level 4
                if ( $inCodeBlock4 ){ 
                    # out of codeblock
                    [bool] $inCodeBlock4 = $False
                } else {
                    [bool] $inCodeBlock4 = $True
                }
            } else {
                # code chunk level 3
                if ( $inCodeBlock3 ){
                    # out of codeblock
                    [bool] $inCodeBlock3 = $False
                } else {
                    [bool] $inCodeBlock3 = $True
                }
            }
        }
        if ( ( -not $inCodeBlock3) -and ( -not $inCodeBlock4) ) {
            [bool] $inCodeBlock = $False
        } else {
            [bool] $inCodeBlock = $True
        }
        # is Fence block?
        if ( $readLine -match '^:::' -and ( -not $inCodeBlock) ) {
            if ( $readLine -match '^::::') {
                # fence block level 4
                if ( $inFenceBlock4 ){
                    # out of fenceblock
                    [bool] $inFenceBlock4 = $False
                } else {
                    [bool] $inFenceBlock4 = $True
                }   
            } else {
                # fence block level 3
                if ( $inFenceBlock3 ){
                    # out of fenceblock
                    [bool] $inFenceBlock3 = $False
                } else {
                    [bool] $inFenceBlock3 = $True
                }   
            }
        }
        if ( ( -not $inFenceBlock3) -and ( -not $inFenceBlock4) ) {
            [bool] $inFenceBlock = $False
        } else {
            [bool] $inFenceBlock = $True
        }
        # is Yaml block?
        if ( $rowCounter -eq 1 -and $readLine -match '^\-\-\-$') {
            # beginning of yaml block
            [bool] $inYamlBlock = $True
            return
        }
        if ( $inYamlBlock -and $readLine -match '^\-\-\-$') {
            # end of yaml block
            [bool] $inYamlBlock = $False
            return
        }
        # is Quote block?
        if ( $readLine -match '^>') {
            $inQuoteBlock = $True
        } elseif ( $inQuoteBlock ) {
            $inQuoteBlock = $False
        }
        # get section level as int
        [bool] $isSection = $False
        if ( (-not $inCodeBlock) `
        -and (-not $inFenceBlock) `
        -and (-not $inQuoteBlock) `
        -and (-not $inYamlBlock) ){
            if ( $readLine -match '^#'){
                [bool] $isSection = $True
                [int] $secLevel = replaceSecToNum $readLine
            }
        }
        #Write-Debug "$inCodeBlock, $inFenceBlock, $inQuoteBlock, $inYamlBlock, $readLine"
        Write-Debug "$isSection, $secLevel, $Level, $stat, $matchFlag, ,$inCodeBlock, $readLine"
        # if section
        if ( $isSection ){
            [bool] $isSection = $False
            if ( $secLevel -gt $Level ){
                # child section
                # keep grep
                if ( $stat -eq 'active' ){
                    if ( -not $MatchOnlyTitle) {
                        if ( $readLine -match "$Grep" ){ $matchFlag = $True }
                    }
                    $tempAryList.Add( $readLine )
                }
                return
            } elseif ( $secLevel -eq $Level ) {
                # if section level number -eq $Level
                if ( $stat -eq 'init' ){
                    # first match
                    # init
                    [string] $stat = "active"
                    $matchFlag = $False
                    $tempAryList = New-Object 'System.Collections.Generic.List[System.String]'
                    $tempAryList.Add( $readLine )
                    if ( $readLine -match "$Grep" ){ $matchFlag = $True }
                    return
                } elseif ( $stat -eq 'active' ){
                    # invert match flag
                    if ( $NotMatch ){
                        if ( $matchFlag ){ $matchFlag = $False } else { $matchFlag = $True }
                    }
                    if ( $matchFlag ){
                        # match
                        # output
                        [string[]] $tempLineAry = $tempAryList.ToArray()
                        foreach ( $tempLine in $tempLineAry ){
                            Write-Output $tempLine
                        }
                        # init
                        [string] $stat = "active"
                        $matchFlag = $False
                        $tempAryList = New-Object 'System.Collections.Generic.List[System.String]'
                        $tempAryList.Add( $readLine )
                        if ( $readLine -match "$Grep" ){ $matchFlag = $True }
                        return
                    } else {
                        # not match
                        # init
                        [string] $stat = "active"
                        $matchFlag = $False
                        $tempAryList = New-Object 'System.Collections.Generic.List[System.String]'
                        $tempAryList.Add( $readLine )
                        if ( $readLine -match "$Grep" ){ $matchFlag = $True }
                        return
                    }
                } else {
                    # pass
                }
            } elseif ( $secLevel -lt $Level ){
                # parent section
                if ( $stat -eq 'active'){
                    # invert match flag
                    if ( $NotMatch ){
                        if ( $matchFlag ){ $matchFlag = $False } else { $matchFlag = $True }
                    }
                    if ( $matchFlag ){
                        # match
                        # output
                        [string[]] $tempLineAry = $tempAryList.ToArray()
                        foreach ( $tempLine in $tempLineAry ){
                            Write-Output $tempLine
                        }
                    }
                }
                # init
                [string] $stat = "init"
                $matchFlag = $False
                $tempAryList = New-Object 'System.Collections.Generic.List[System.String]'
                if ( $OutputParentSection ){
                    Write-Output $readLine
                }
            }
        } else {
            # if paragraph
            if ( $stat -eq 'active' ){
                if (-not $MatchOnlyTitle ){
                    if ( $readLine -match "$Grep" ){ $matchFlag = $True }
                }
                if ( $VerboseOutput ){
                    $tempAryList.Add( $readLine )
                }
            } else {
                # pass
            }
        }
    }

    end {
        if ($tempAryList.ToArray().Count -gt 0){
            # invert match flag
            if ( $NotMatch ){
                if ( $matchFlag ){ $matchFlag = $False } else { $matchFlag = $True }
            }
            if ( $matchFlag ) {
                [string[]] $tempLineAry = $tempAryList.ToArray()
                foreach ( $tempLine in $tempLineAry ){
                    Write-Output $tempLine
                }
            }
        }
    }
}
