<#
.SYNOPSIS
    list2table - Convert markdown list format to long type data

    This filter formats Markdown-style headings and lists
    into a data structure suitable for processing with
    PivotTable of spreadsheet.

    Tab delimited output by default.


.LINK
    list2table

.EXAMPLE
    cat a.md
    - aaa
    - bbb
        - bbb-2
            - bbb-3
        - bbb-2
    - ccc
        - ccc-2
        - ccc-2

    PS> cat a.md | list2table
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


    PS> cat a.md | list2table -MarkdownLv1
    title	Lv.1	Lv.1.1
    title	Lv.1	Lv.1.2
    title	Lv.2	Lv.2.1	Lv.2.1.1
    title	Lv.2	Lv.2.2
    title	Lv.3


    PS> cat a.md | list2table -MarkdownLv1 -AutoHeader
    F1      F2      F3      F4
    title   Lv.1    Lv.1.1
    title   Lv.1    Lv.1.2
    title   Lv.2    Lv.2.1  Lv.2.1.1
    title   Lv.2    Lv.2.2
    title   Lv.3


    PS> cat a.md | list2table -MarkdownLv1 | ConvertFrom-Csv -Delimiter "`t" -Header @("Lv1","lv2","lv3") | ConvertTo-Json
    [
      {
        "Lv1": "title",
        "lv2": "Lv.1",
        "lv3": "Lv.1.1"
      },
      {
        "Lv1": "title",
        "lv2": "Lv.1",
        "lv3": "Lv.1.2"
      },
      {
        "Lv1": "title",
        "lv2": "Lv.2",
        "lv3": "Lv.2.1"
      },
      {
        "Lv1": "title",
        "lv2": "Lv.2",
        "lv3": "Lv.2.2"
      },
      {
        "Lv1": "title",
        "lv2": "Lv.3",
        "lv3": null
      }
    ]

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
        [int] $MaxDepth = 20,
        
        [Parameter( Mandatory=$False)]
        [string] $NA = "-",
        
        [Parameter( Mandatory=$False,
            ValueFromPipeline=$True)]
        [string[]] $Text
    )

    begin{
        ## init var
        [int] $depthOfList = 0
        [int] $idCounter = 0
        [int] $newItemLevel = 0
        [int] $oldItemLevel = -1
        [string[]] $keyAry = 1..$MaxDepth | ForEach-Object { $NA }
        [string[]] $readLineAry = @()
        [string[]] $writeAry = @()
        ## define private functions
        function isCommandExist ([string]$cmd) {
            try { Get-Command $cmd -ErrorAction Stop > $Null
                return $True
            } catch {
                return $False
            }
        }
        function getItemLevel ([string]$rdLine){
            $whiteSpaces = $rdLine -replace '^(\s*)[-*]','$1'
            $whiteSpaceLength = $whiteSpace.Length
            $itemLevel = [math]::Floor($whiteSpaceLength / $Space)
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
    }
    process{
        [string] $rdLine = [string] $_
        if ( $MarkdownLv1 -or $MarkdownLv2 ){
            if ( $rdLine -match '^#' ) {
                ## target line is beginning with "#"
                [string] $rdLine = replaceMarkdownHeaderToList $rdLine
                $readLineAry += $rdLine
            }
        } else {
            if ( $line -match '^\s*\-|^\s*\*' ) {
                ## target line is beginning with a hyphen or asterisk
                $readLineAry += $rdLine
            }
        }
    }
    end {
        ForEach ( $line in $readLineAry ){
            $idCounter++
            ## set str
            [string] $whiteSpace = $line -replace '^(\s*)[-*].*$','$1'
            [string] $contents   = $line -replace '^\s*[-*]\s*(.*)$','$1'
            [int] $newItemLevel  = getItemLevel "$rdLine"
            if ( $newItemLevel -gt $depthOfList){
                [int] $depthOfList = $newItemLevel
            }
            if ($idCounter -eq 1){
                ## data on first line
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
                    Write-Error "error: Two or more hierarchical levels deep at once!: $rdLine" -ErrorAction Stop

                } elseif ($newItemLevel -lt $oldItemLevel){
                    ## The hierarchy has become shallower: pop
                    $writeAry += $keyAry[0..$oldItemLevel] -join $Delimiter
                    $keyAry[$newItemLevel] = $contents

                } else {
                    Write-Error "error: Ubknown error. Unable to detect hierarchy: $rdLine" -ErrorAction Stop
                }
            }
            $oldItemLevel = $newItemLevel
            $oldNodeId = $newNodeId
        }
        $writeAry += $keyAry[0..$oldItemLevel] -join $Delimiter
        if ( $AutoHeader ){
            $depthOfList++
            [string[]] $headers = 1..$depthOfList | ForEach-Object {
                Write-Output "F$_"
            }
            $headers -join $Delimiter
        }
        foreach ($wline in $writeAry){
            Write-Output $wline
        }
    }
}
