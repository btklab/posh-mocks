<#
.SYNOPSIS
    mdfocus - A multiline oriented searcher for markdown list format

    Markdown list block searcher.
    A wrapper script for "mdgrep".

    By default, search for elements at list level 2 and below
    and return the entire level 2 block if matches.

    Lists within the following markdown constructs are ignored.

        Yaml Block
        Code Block  '```' and '````'
        Fence Block ':::' and '::::'
        Quote Block
    
.LINK
    mdgrep, mdgrep2, mdsort, mdsort2, mdparag, list2table, mdfocus

.EXAMPLE
    cat a.md
        ---
        title: title
        author: btklab
        date: 2023-07-16
        link: "https://github.com/btklab"
        ---

        - title
            - Lv.1
                - Lv.1.1
                - Lv.1.2
            - Lv.2
                - Lv.2.1
                    - Lv.2.1.1
                - Lv.2.2
            - Lv.3

    PS> cat a.md | mdfocus 'Lv\.2'
        - Lv.2
            - Lv.2.1
                - Lv.2.1.1
            - Lv.2.2


    PS> cat a.md | mdfocus 'Lv\.2' | list2table
        -       Lv.2    Lv.2.1  Lv.2.1.1
        -       Lv.2    Lv.2.2

#>
function mdfocus {

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
        
        [Parameter( Mandatory=$False)]
        [switch] $OffOrderedNumber,
        
        [Parameter( Mandatory=$False)]
        [int] $Space = 4,
        
        [Parameter( Mandatory=$False )]
        [string[]] $CustomCommentBlock,
        
        [parameter( Mandatory=$False, ValueFromPipeline=$True )]
        [string[]] $InputText
    )
    # private function
    function isCommandExist ([string]$cmd) {
        try { Get-Command $cmd -ErrorAction Stop > $Null
            return $True
        } catch {
            return $False
        }
    }
    ## test command
    if ( -not (isCommandExist "mdgrep") ){
        Write-Error "mdgrep is not found." -ErrorAction Stop
    }
    ## set splatting
    $splatting = @{
        Grep = $Grep
        Level = $Level
        MatchOnlyTitle = $MatchOnlyTitle
        Expand = $Expand
        NotMatch = $NotMatch
        OffOrderedNumber = $OffOrderedNumber
        Space = $Space
        CustomCommentBlock = $CustomCommentBlock
    }
    $splatting.Set_Item('List', $True)
    $splatting.Set_Item('OutputParentSection', $OutputParentSection)
    ## execute command
    $input | mdgrep @splatting
}
