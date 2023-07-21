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
    To output both title and body, adding `-e|-Expand` option.

    Case insensitive.

    The number signs (#) written in the following block is ignored.
    Code blocks only support 3 and 4 backquote characters.
    Fence blocks only support 3 and 4 colon characters.

        Yaml Block
        Code Block  '```' and '````'
        Fence Block ':::' and '::::'
        Quote Block
        CustomCommentBlock:
            The language-specific comment block symbol can be
            specified with -CustomCommentBlock "begin", "end" option.

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

        PS > cat README.md | mdgrep seq2pu -Level 4 -e
            # output contents in "#### seq2pu section"
    

    The "-List" switch parses the list structure instead of
    the header structure. An example, this is used to focus on
    a specific block in a list-structured outliner.

    Input:
        PS> cat a.md
        - title
            - Lv.1
                - Lv.1.1
                - Lv.1.2
            - Lv.2
                - Lv.2.1
                    - Lv.2.1.1
                - Lv.2.2
            - Lv.3
    
    Output:
        PS> cat a.md | mdgrep -List .
             - Lv.1
                 - Lv.1.1
                 - Lv.1.2
             - Lv.2
                 - Lv.2.1
                     - Lv.2.1.1
                 - Lv.2.2
             - Lv.3



.LINK
    mdgrep, mdgrep2, mdsort, mdsort2, mdparag, list2table, mdfocus


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

    # Search sectoin title and contents,
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

    $markdown | mdgrep . -Expand
    $markdown | mdgrep . -e
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
    PS > $markdown | mdgrep hoge1 -e
        ## HACCP
        hoge1
        ### Books
        fuga1
        ### Articles
        piyo1


    PS > $markdown | mdgrep hoge1 -NotMatch -e
    PS > $markdown | mdgrep hoge1 -v -e
        ## Computer
        hoge2
        ### Books
        fuga2
        ### Articles
        piyo2


    PS > $markdown | mdgrep haccp -MatchOnlyTitle -e
    PS > $markdown | mdgrep haccp -t -e
        ## HACCP
        hoge1
        ### Books
        fuga1
        ### Articles
        piyo1

.EXAMPLE
    # invert match
        PS > $markdown | mdgrep haccp -MatchOnlyTitle -NotMatch -e
        PS > $markdown | mdgrep haccp -t -v -e
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
    PS > $markdown | mdgrep fuga -Level 3 -e
    PS > $markdown | mdgrep fuga -l 3 -e
        ### Books
        fuga1
        ### Books
        fuga2

.EXAMPLE
    # Output parent sections
    PS > $markdown | mdgrep fuga -Level 3 -OutputParentSection -e
    PS > $markdown | mdgrep fuga -l 3 -p -e
        # My favorite links
        ## HACCP
        ### Books
        fuga1
        ## Computer
        ### Books
        fuga2


    # Note that the "-p|OutputParentSection" option
    #   outputs the titles regardless of matches.
    PS > $markdown | mdgrep fuga2 -Level 3 -p -e
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

    PS > cat README.md | mdgrep seq2pu -Level 4 -e
        # output contents in "#### seq2pu section"

.EXAMPLE
    # get function from markdown-heading like ps1 scriptfile
    PS > cat a.ps1
        ## isCommandExist - is command exists?
        function isCommandExist ([string]$cmd) {
            ### test command
            try { Get-Command $cmd -ErrorAction Stop > $Null
                return $True
            } catch {
                return $False
            }
        }
        ## Celsius2Fahrenheit - convert Celsius to Fahrenheit
        function Celsius2Fahrenheit ( [float] $C ){
            ### calc
            return $($C * 1.8 + 32)
        }
        ## Fahrenheit2Celsius - convert Fahrenheit to Celsius
        function Fahrenheit2Celsius ( [float] $F ){
            ### calc
            return $(( $F - 32 ) / 1.8)
        }
        ## Get-UIBufferSize - get terminal width
        function Get-UIBufferSize {
            ### calc
            return (Get-Host).UI.RawUI.BufferSize
        }
        # main
        ...


    PS > cat a.ps1 | mdgrep
        ## isFileExists - is file exists?
        ## isCommandExist - is command exists?
        ## Celsius2Fahrenheit - convert Celsius to Fahrenheit
        ## Fahrenheit2Celsius - convert Fahrenheit to Celsius
        ## Get-UIBufferSize - get terminal width


    PS > cat a.ps1 | mdgrep celsius2 -MatchOnlyTitle -Expand
    PS > cat a.ps1 | mdgrep celsius2 -t -e
        ## Celsius2Fahrenheit - convert Celsius to Fahrenheit
        function Celsius2Fahrenheit ( [float] $C ){
            return $($C * 1.8 + 32)
        }


    # IgnoreLeadingSpaces option treat '^space' + '## ...' as header
    PS > cat a.ps1 | mdgrep -IgnoreLeadingSpaces
    PS > cat a.ps1 | mdgrep -i
        ## isCommandExist - is command exists?
            ### test command
        ## Celsius2Fahrenheit - convert Celsius to Fahrenheit
            ### calc
        ## Fahrenheit2Celsius - convert Fahrenheit to Celsius
            ### calc
        ## Get-UIBufferSize - get terminal width
            ### calc

    PS > cat a.ps1 | mdgrep -Level 3 -IgnoreLeadingSpaces
    PS > cat a.ps1 | mdgrep -l 3 -i
        ### test command
        ### calc
        ### calc
        ### calc
    
    PS > cat a.ps1 | mdgrep -Level 3 -IgnoreLeadingSpaces test
    PS > cat a.ps1 | mdgrep -l 3 -i test
        ### test command
    
    PS > cat a.ps1 | mdgrep -Level 3 -IgnoreLeadingSpaces test -Expand
    PS > cat a.ps1 | mdgrep -l 3 -i test -e
        ### test command
        try { Get-Command $cmd -ErrorAction Stop > $Null
            return $True
        } catch {
            return $False
        }
    }


.EXAMPLE
    # grep changelog example
    
    PS > cat changelog.txt
    # changelog
    
    ## 2023-04-07 hoge
    
    - hoge1
    - hoge2
    - hoge3
    
    
    ## 2023-04-08 fuga
    
    - fuga1
    - fuga2
    - fuga3
    
    # changelog2
    
    ## 2023-04-09 piyo
    
    - piyo1
    - piyo2
    - piyo3
    
    
    PS > cat changelog.txt | mdgrep fuga
    ## 2023-04-08 fuga
    
    PS > cat changelog.txt | mdgrep fuga -Expand
    ## 2023-04-08 fuga
    
    - fuga1
    - fuga2
    - fuga3
    

#>
function mdgrep {

    param (
        [Parameter( Mandatory=$False, Position=0 )]
        [Alias('g')]
        [string] $Grep = ".",
        
        [Parameter( Mandatory=$False )]
        [ValidateRange(1,6)]
        [Alias('l')]
        [int] $Level = 2,
        
        [Parameter( Mandatory=$False )]
        [Alias('t')]
        [switch] $MatchOnlyTitle,
        
        [Parameter( Mandatory=$False )]
        [Alias('e')]
        [switch] $Expand,
        
        [Parameter( Mandatory=$False )]
        [Alias('p')]
        [switch] $OutputParentSection,
        
        [Parameter( Mandatory=$False )]
        [Alias('v')]
        [switch] $NotMatch,
        
        [Parameter( Mandatory=$False )]
        [Alias('i')]
        [switch] $IgnoreLeadingSpaces,
        
        [Parameter( Mandatory=$False )]
        [switch] $Bar,
        
        [Parameter( Mandatory=$False )]
        [switch] $List,
        
        [Parameter( Mandatory=$False)]
        [switch] $OffOrderedNumber,
        
        [Parameter( Mandatory=$False)]
        [int] $Space = 4,
        
        [Parameter( Mandatory=$False )]
        [string[]] $CustomCommentBlock,
        
        [parameter( Mandatory=$False, ValueFromPipeline=$True )]
        [string[]] $InputText
    )

    begin {
        # init variables
        [int] $rowCounter = 0
        [int] $secLevel   = 0
        [string] $stat = 'init'
        [bool] $inYamlBlock           = $False
        [bool] $inCodeBlock           = $False
        [bool] $inCodeBlock3          = $False
        [bool] $inCodeBlock4          = $False
        [bool] $inFenceBlock          = $False
        [bool] $inFenceBlock3         = $False
        [bool] $inFenceBlock4         = $False
        [bool] $inQuoteBlock          = $False
        [bool] $isSection             = $False
        [bool] $matchFlag             = $False
        if ( $CustomCommentBlock ){
            if ( $CustomCommentBlock.Count -ne 2 ){
                Write-Error "-CustomCommmentBlock option requires 2 specifications, a begin symbol and an end symbol" -ErrorAction Stop
            }
            [bool] $inCustomCommentBlock  = $False
            [string] $cunstomCommentBlockBegin = '^\s*' + $CustomCommentBlock[0] + '$'
            [string] $cunstomCommentBlockEnd   = '^\s*' + $CustomCommentBlock[1] + '$'
        } else {
            [bool] $inCustomCommentBlock  = $False
        }
        $tempAryList = New-Object 'System.Collections.Generic.List[System.String]'

        # private function
        function replaceSecToNum ( [string] $section ){
            if ( $section.Trim() -match '^#{1} ') { return 1 }
            if ( $section.Trim() -match '^#{2} ') { return 2 }
            if ( $section.Trim() -match '^#{3} ') { return 3 }
            if ( $section.Trim() -match '^#{4} ') { return 4 }
            if ( $section.Trim() -match '^#{5} ') { return 5 }
            if ( $section.Trim() -match '^#{6} ') { return 6 }
        }
        function replaceOrderedListToList ( [string] $line ){
            [string] $line = $line -replace '^(\s*)[-*+] ', '$1- '
            if ( $OffOrderedNumber ){
                [string] $line = $line -replace '^(\s*)([0-9]+\.) ','$1- '
            } else {
                [string] $line = $line -replace '^(\s*)([0-9]+\.) ','$1- $2 '
            }
            return $line
        }
        function getItemLevel ([string]$wSpace){
            [int] $whiteSpaceLength = $wSpace.Length
            [int] $itemLevel = [math]::Floor($whiteSpaceLength / $Space)
            $itemLevel++
            return $itemLevel
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
        # is Custom comment block?
        if ( $CustomCommentBlock ){
            if ( $readLine -match $cunstomCommentBlockBegin ){
                if ( ( -not $inCodeBlock ) -and ( -not $inFenceBlock ) ) {
                    # fence block level 3
                    if ( $inCustomCommentBlock ){
                        # out of comment block
                        [bool] $inCustomCommentBlock = $False
                    } else {
                        [bool] $inCustomCommentBlock = $True
                    }
                }
            }
            if ( $readLine -match $cunstomCommentBlockEnd ){
                if ( ( -not $inCodeBlock ) -and ( -not $inFenceBlock ) ) {
                    # fence block level 3
                    if ( -not $inCustomCommentBlock ){
                        Write-Warning "Could not find comment block beginning symbol: $($CustomCommentBlock[0])" -ErrorAction Stop
                    }
                    # out of comment block
                    [bool] $inCustomCommentBlock = $False
                }
            }
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
        if ( ( -not $inCodeBlock ) `
        -and ( -not $inFenceBlock ) `
        -and ( -not $inQuoteBlock ) `
        -and ( -not $inCustomCommentBlock ) `
        -and ( -not $inYamlBlock ) ){
            ## replace tab to space
            if ( $readLine -match "^`t+" ){
                $readLine = $readLine -replace "`t", $(" " * $Space)
            }
            if ( $List ){
                ## grep markdown lists
                [string] $readLine = replaceOrderedListToList $readLine
                if ( $readLine -match '^\s*\- '){
                    [bool] $isSection = $True
                    [string] $whiteSpace = $readLine -replace '^(\s*)\- (.*)$','$1'
                    [int] $secLevel = getItemLevel $whiteSpace
                }
            } else {
                ## grep markdown headers
                if ( $IgnoreLeadingSpaces ){
                    if ( $readLine -match '^\s*#{1,6} [^ ]+'){
                        [bool] $isSection = $True
                        [int] $secLevel = replaceSecToNum $readLine
                    }
                } else {
                    if ( $readLine -match '^#{1,6} [^ ]+'){
                        [bool] $isSection = $True
                        [int] $secLevel = replaceSecToNum $readLine
                    }
                }
                if ( $Bar ){
                    $readLine = $readLine -replace '# ','| ' -replace '#','    '
                }
            }
            Write-Debug "$secLevel $readLine"
        }
        #Write-Debug "$inCodeBlock, $inFenceBlock, $inQuoteBlock, $inYamlBlock, $readLine"
        #Write-Debug "$isSection, $secLevel, $Level, $stat, $matchFlag, $inCodeBlock, $readLine"
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
                if ( $Expand ){
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
