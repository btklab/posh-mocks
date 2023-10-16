<#
.SYNOPSIS
    list2table - Convert markdown list format to long type data (make it greppable!)

    This filter formats Markdown-style headings and lists into PSObject.
    In other words, make it greppable!
    
    PSObject output by default.
    With the "-Table" switch specified, output as tab-separated text
    (appropriate as a data table to be copied and pasted into Excel)

    Lists within the following markdown constructs are ignored.

        Yaml Block
        Code Block  '```' and '````'
        Fence Block ':::' and '::::'
        Quote Block
    
    With the "-Tag" switch recognizes the strings inside the brackets
    at the end of the sentence as a tag.

        PS> cat list-with-tag.md
            - title
                - Lv.1
                    - Lv.1.1 [#hashtag]
                    - Lv.1.2 [2023-07-20]
                - Lv.2
                    - Lv.2.1
                        - Lv.2.1.1
                    - Lv.2.2 [#life, #idea]
                - Lv.3

        PS> cat list-with-tag.md | list2table -Tag | ft
            Tag          F1    F2   F3     F4
            ---          --    --   --     --
            #hashtag     title Lv.1 Lv.1.1
            2023-07-20   title Lv.1 Lv.1.2
                         title Lv.2 Lv.2.1 Lv.2.1.1
            #life, #idea title Lv.2 Lv.2.2
                         title Lv.3

    With the "-TagOff" switch to treat the string inside the brackets
    at the end of the sentence as a tag and hide it.

        PS> cat list-with-tag.md | list2table -TagOff | ft
            F1    F2   F3     F4
            --    --   --     --
            title Lv.1 Lv.1.1
            title Lv.1 Lv.1.2
            title Lv.2 Lv.2.1 Lv.2.1.1
            title Lv.2 Lv.2.2
            title Lv.3.LINK
    
.LINK
    list2table, mdgrep, mdfocus

.EXAMPLE
    cat a.md
        ---
        title: title
        author: btklab
        date: 2023-07-16
        link: "https://github.com/btklab"
        ---
        
        - aaa
        - bbb
            - bbb-2
                - bbb-3
            - bbb-2
        - ccc
            - ccc-2
            - ccc-2


    PS> cat a.md | list2table
        F1  F2    F3
        --  --    --
        aaa
        bbb bbb-2 bbb-3
        bbb bbb-2
        ccc ccc-2
        ccc ccc-2


    PS> cat a.md | list2table -Table
        aaa
        bbb	bbb-2	bbb-3
        bbb	bbb-2
        ccc	ccc-2
        ccc	ccc-2


.EXAMPLE
    cat a.md
        # title
        ## Lv.1
        ### Lv.1.1
        ### Lv.1.2
        ## Lv.2
        ### Lv.2.1
        #### Lv.2.1.1
        ### Lv.2.2
        ## Lv.3


    PS> cat a.md | | list2table -MarkdownLv1
        F1    F2   F3     F4
        --    --   --     --
        title Lv.1 Lv.1.1
        title Lv.1 Lv.1.2
        title Lv.2 Lv.2.1 Lv.2.1.1
        title Lv.2 Lv.2.2
        title Lv.3


    PS> cat a.md | list2table -MarkdownLv1 -Table
        title	Lv.1	Lv.1.1
        title	Lv.1	Lv.1.2
        title	Lv.2	Lv.2.1	Lv.2.1.1
        title	Lv.2	Lv.2.2
        title	Lv.3


    PS> cat a.md | list2table -MarkdownLv1 -Table -AutoHeader
        F1      F2      F3      F4
        title   Lv.1    Lv.1.1
        title   Lv.1    Lv.1.2
        title   Lv.2    Lv.2.1  Lv.2.1.1
        title   Lv.2    Lv.2.2
        title   Lv.3


.EXAMPLE
    PS> cat a.md | list2table -MarkdownLv1 | ConvertTo-Json
    [
      {
        "F1": "title",
        "F2": "Lv.1",
        "F3": "Lv.1.1",
        "F4": null
      },
      {
        "F1": "title",
        "F2": "Lv.1",
        "F3": "Lv.1.2",
        "F4": null
      },
      {
        "F1": "title",
        "F2": "Lv.2",
        "F3": "Lv.2.1",
        "F4": "Lv.2.1.1"
      },
      {
        "F1": "title",
        "F2": "Lv.2",
        "F3": "Lv.2.2",
        "F4": null
      },
      {
        "F1": "title",
        "F2": "Lv.3",
        "F3": null,
        "F4": null
      }
    ]

.EXAMPLE
    # With the "-Tag" switch recognizes the strings inside the brackets
    # at the end of the sentence as a tag.

        PS> cat list-with-tag.md
            - title
                - Lv.1
                    - Lv.1.1 [#hashtag]
                    - Lv.1.2 [2023-07-20]
                - Lv.2
                    - Lv.2.1
                        - Lv.2.1.1
                    - Lv.2.2 [#life, #idea]
                - Lv.3

        PS> cat list-with-tag.md | list2table -Tag | ft
            Tag          F1    F2   F3     F4
            ---          --    --   --     --
            #hashtag     title Lv.1 Lv.1.1
            2023-07-20   title Lv.1 Lv.1.2
                         title Lv.2 Lv.2.1 Lv.2.1.1
            #life, #idea title Lv.2 Lv.2.2
                         title Lv.3

.EXAMPLE
    # With the "-TagOff" switch to treat the string inside the brackets
    # at the end of the sentence as a tag and hide it.

    PS> cat list-with-tag.md | list2table -TagOff | ft
        F1    F2   F3     F4
        --    --   --     --
        title Lv.1 Lv.1.1
        title Lv.1 Lv.1.2
        title Lv.2 Lv.2.1 Lv.2.1.1
        title Lv.2 Lv.2.2
        title Lv.3

#>
function list2table {
    Param(
        [Parameter( Mandatory=$False)]
        [Alias('d')]
        [string] $Delimiter = "`t",
        
        [Parameter( Mandatory=$False)]
        [int] $Space = 4,
        
        [Parameter( Mandatory=$False)]
        [Alias('m1')]
        [switch] $MarkdownLv1,
        
        [Parameter( Mandatory=$False)]
        [Alias('m2')]
        [switch] $MarkdownLv2,
        
        [Parameter( Mandatory=$False)]
        [Alias('a')]
        [switch] $AutoHeader,
        
        [Parameter( Mandatory=$False)]
        [switch] $OffOrderedNumber,
        
        [Parameter( Mandatory=$False)]
        [Alias('t')]
        [switch] $Table,
        
        [Parameter( Mandatory=$False)]
        [switch] $Tag,
        
        [Parameter( Mandatory=$False)]
        [switch] $TagOff,
        
        [Parameter( Mandatory=$False)]
        [int] $MaxDepth = 20,
        
        [Parameter( Mandatory=$False)]
        [string] $NA = "-",
        
        [Parameter( Mandatory=$False)]
        [string[]] $Header,
        
        [Parameter( Mandatory=$False,
            ValueFromPipeline=$True)]
        [string[]] $Text
    )

    begin{
        ## init var
        [int] $depthOfList  = 0
        [int] $idCounter    = 0
        [int] $newItemLevel = 0
        [int] $oldItemLevel = -1
        [string[]] $readLineAry = @()
        [string[]] $writeAry    = @()
        [string[]] $keyAry = 1..$MaxDepth | ForEach-Object { $Null }
        [object] $readLineList = New-Object 'System.Collections.Generic.List[System.String]'
        
        [int] $rowCounter = 0
        [bool] $inYamlBlock           = $False
        [bool] $inCodeBlock           = $False
        [bool] $inCodeBlock3          = $False
        [bool] $inCodeBlock4          = $False
        [bool] $inFenceBlock          = $False
        [bool] $inFenceBlock3         = $False
        [bool] $inFenceBlock4         = $False
        [bool] $inQuoteBlock          = $False
        
        ## define private functions
        function getItemLevel ([string]$wSpace){
            [int] $whiteSpaceLength = $wSpace.Length
            [int] $itemLevel = [math]::Floor($whiteSpaceLength / $Space)
            return $itemLevel
        }
        function replaceMarkdownHeaderToList ([string] $line) {
            if ( $MarkdownLv2 ){
                $line = $line -replace '^#{2} ', "$(' ' * 4 * 0 + '- ')"
                $line = $line -replace '^#{3} ', "$(' ' * 4 * 1 + '- ')"
                $line = $line -replace '^#{4} ', "$(' ' * 4 * 2 + '- ')"
                $line = $line -replace '^#{5} ', "$(' ' * 4 * 3 + '- ')"
                $line = $line -replace '^#{6} ', "$(' ' * 4 * 4 + '- ')"
            } else {
                $line = $line -replace '^#{1} ', "$(' ' * 4 * 0 + '- ')"
                $line = $line -replace '^#{2} ', "$(' ' * 4 * 1 + '- ')"
                $line = $line -replace '^#{3} ', "$(' ' * 4 * 2 + '- ')"
                $line = $line -replace '^#{4} ', "$(' ' * 4 * 3 + '- ')"
                $line = $line -replace '^#{5} ', "$(' ' * 4 * 4 + '- ')"
                $line = $line -replace '^#{6} ', "$(' ' * 4 * 5 + '- ')"
            }
            return $line
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
    }
    process{
        $rowCounter++
        [string] $rdLine = [string] $_
        
        # is Code block?
        if ( $rdLine -match '^```') {
            if ( $rdLine -match '^````') {
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
        if ( $rdLine -match '^:::' -and ( -not $inCodeBlock) ) {
            if ( $rdLine -match '^::::') {
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
        if ( $rowCounter -eq 1 -and $rdLine -match '^\-\-\-$') {
            # beginning of yaml block
            [bool] $inYamlBlock = $True
            return
        }
        if ( $inYamlBlock -and $rdLine -match '^\-\-\-$') {
            # end of yaml block
            [bool] $inYamlBlock = $False
            return
        }
        # is Quote block?
        if ( $rdLine -match '^>') {
            $inQuoteBlock = $True
        } elseif ( $inQuoteBlock ) {
            $inQuoteBlock = $False
        }
        # read line
        if ( ( -not $inCodeBlock  ) `
        -and ( -not $inFenceBlock ) `
        -and ( -not $inQuoteBlock ) `
        -and ( -not $inYamlBlock  ) ){
            ## replace tab to space
            if ( $rdLine -match "^`t+" ){
                $rdLine = $rdLine -replace "`t", $(" " * $Space)
            }
            if ( $MarkdownLv1 ){
                if ( $rdLine -match '^#' ) {
                    ## target line is beginning with "#"
                    [string] $rdLine = replaceMarkdownHeaderToList $rdLine
                    $readLineList.Add($rdLine)
                    Write-Debug $rdLine
                }
            } elseif ( $MarkdownLv2){
                if ( $rdLine -match '^##' ) {
                    ## target line is beginning with "##"
                    [string] $rdLine = replaceMarkdownHeaderToList $rdLine
                    $readLineList.Add($rdLine)
                    Write-Debug $rdLine
                }
            } else {
                if ( $rdLine -match '^\s*[-*+] |^\s*[0-9]+\. ' ) {
                    ## target line is beginning with a hyphen or asterisk
                    [string] $rdLine = replaceOrderedListToList $rdLine
                    $readLineList.Add($rdLine)
                    Write-Debug $rdLine
                }
            }
        }
    }
    end {
        [string[]] $readLineAry = $readLineList.ToArray()
        if ( $readLineAry.Length -eq 0 ){
            Write-Error "Error: No match line." -ErrorAction Stop
        }
        ForEach ( $line in $readLineAry ){
            $idCounter++
            ## set str
            [string] $whiteSpace = $line -replace '^(\s*)\- (.*)$','$1'
            [string] $contents   = $line -replace '^(\s*)\- (.*)$','$2'
            [int] $newItemLevel  = getItemLevel "$whiteSpace"
            Write-Debug $newItemLevel
            if ( $newItemLevel -gt $depthOfList){
                [int] $depthOfList = $newItemLevel
            }
            if ($idCounter -eq 1){
                ## data on first line
                if ( -not $Table ) {
                    if ( $contents -match '^#' ){
                        # Quote Input starting with "#"
                        # for ConvertFrom-CSV output
                        [string] $contents = """$contents"""
                    }
                }
                $keyAry[$newItemLevel] = $contents
            } else {
                ## data after the second line
                if ($newItemLevel -eq $oldItemLevel){
                    ## no hierarchy change: no push or pop
                    $writeAry += $keyAry[0..$newItemLevel] -join $Delimiter
                    $keyAry[$newItemLevel] = $contents

                } elseif ($newItemLevel -eq $oldItemLevel + 1){
                    ## move one level deeper: push
                    $keyAry[$newItemLevel] = $contents

                } elseif ($newItemLevel -gt $oldItemLevel + 1){
                    Write-Error "Two or more hierarchical levels deep at once!: $line" -ErrorAction Stop

                } elseif ($newItemLevel -lt $oldItemLevel){
                    ## The hierarchy has become shallower: pop
                    $writeAry += $keyAry[0..$oldItemLevel] -join $Delimiter
                    $keyAry[$newItemLevel] = $contents

                } else {
                    Write-Error "Unable to detect hierarchy: $line" -ErrorAction Stop
                }
            }
            $oldItemLevel = $newItemLevel
            $oldNodeId = $newNodeId
        }
        $writeAry += $keyAry[0..$oldItemLevel] -join $Delimiter
        ## output
        [string[]] $oAry = @()
        $depthOfList++
        if ( $Tag ){
            ## Tag output
            [string[]] $headers = @()
            [string[]] $headers += "Tag"
            if ( $Header ){
                [string[]] $headers += $Header
            } else {
                [string[]] $headers += 1..$depthOfList | ForEach-Object {
                    Write-Output "F$_"
                }
            }
        } else {
            if ( $Header ){
                [string[]] $headers += $Header
            } else {
                [string[]] $headers = 1..$depthOfList | ForEach-Object {
                    Write-Output "F$_"
                }
            }
        }
        $oAry += $headers -join $Delimiter
        function splitTagAndLine ( [string] $wline ){
            if ( $wline -match '\]$'){
                [string] $tmpLin = $wline -replace '^(.*)\s*\[([^\[]+)\]$', '$1'
                [string] $tmpTag = $wline -replace '^(.*)\s*\[([^\[]+)\]$', '$2'
                [string] $tmpLin = $tmpLin.Trim()
                [string] $tmpTag = $tmpTag.Trim()
                if ( -not $Table ){
                    if ( $tmpTag -match '^#' ){
                        [string] $tmpTag = """$tmpTag"""
                    }
                }
                [string] $res = $tmpTag + $Delimiter + $tmpLin
            } else {
                [string] $res = $Delimiter + $wline
            }
            return $res
        }
        function deleteTagFromLine ( [string] $wline ){
            if ( $wline -match '\]$'){
                [string] $tmpLin = $wline -replace '^(.*)\s*\[([^\[]+)\]$', '$1'
                [string] $tmpTag = $wline -replace '^(.*)\s*\[([^\[]+)\]$', '$2'
                [string] $tmpLin = $tmpLin.Trim()
                [string] $tmpTag = $tmpTag.Trim()
                [string] $res = $tmpLin
            } else {
                [string] $res = $wline
            }
            return $res
        }
        foreach ($wline in $writeAry){
            if ( $Tag ){
                [string] $writeLine = splitTagAndLine $wline
                $oAry += $writeLine
            } elseif ( $TagOff) {
                [string] $writeLine = deleteTagFromLine $wline
                $oAry += $writeLine
            } else {
                [string] $writeLine = $wline
                $oAry += $writeLine
            }
        }
        if ( $Table -and $AutoHeader ){
            $oAry | ForEach-Object {
                Write-Output $_
            }
        } elseif ( $Table ){
            for ($i=1; $i -lt $oAry.Count; $i++){
                Write-Output $oAry[$i]
            }
        } else {
            ## Object Output
            $oAry | ForEach-Object {
                Write-Output $_
            } | ConvertFrom-Csv -Delimiter $Delimiter
        }
    }
}
