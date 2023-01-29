<#
.SYNOPSIS
    table2md - Convert tab and csv delimited tables to markdown table format

    Convert tab-separated-values(TSV) and comma-separated-values(CSV)
    to markdown table format.

        cat a.csv | table2md -Delimiter "," -Caption "title"

    Tab delimited by default (-Delimiter "`t")

    If there is no input specification in the standard input and the
    first argument, try to use the clipboard value.

    Input csv/tsc data accept only with header.

    It is assumed to be used for copy and convert data from an
    Excel table. However, line breaks in cells and merged cell cannot
    be converted well.

    Note:
        - For csv and tscv data, cells with only numbers, hyphens adn dots
          are automatically aligned to the right.

        - Some columns with units are also right aligned. Units can be
          specified with -Units "unit1", "unit2",....
          (Default -Units " kg"," ml", " CFU", "RLU", etc...)

.LINK
    md2import, table2md, md2tex, md2html

.EXAMPLE
    cat iris.tsv | table2md -Caption "title" | keta -l

    Table: title

    | s_l  | s_w  | p_l  | p_w  | species |
    | ---: | ---: | ---: | ---: | :---    |
    | 5.1  | 3.5  | 1.4  | 0.2  | setosa  |
    | 4.9  | 3.0  | 1.4  | 0.2  | setosa  |
    | 4.7  | 3.2  | 1.3  | 0.2  | setosa  |
    | 4.6  | 3.1  | 1.5  | 0.2  | setosa  |
    | 5.0  | 3.6  | 1.4  | 0.2  | setosa  |

.EXAMPLE
    cat a.tsv | table2md -Units "CFU","kg" | head -n 15

    | s_l  | s_w     | p_l    | p_w  | species |
    | ---: | ---:    | ---:   | ---: | :---    |
    | 5.1  | 3.5 CFU | 1.4 kg | 0.2  | setosa  |
    | 4.9  | 3.0 CFU | 1.4 kg | 0.2  | setosa  |
    | 4.7  | 3.2 CFU | 1.3 kg | 0.2  | setosa  |
    | 4.6  | 3.1 CFU | 1.5 kg | 0.2  | setosa  |
    | 5.0  | 3.6 CFU | 1.4 kg | 0.2  | setosa  |

    # Some columns with units are also right aligned. Units can be
    # specified with -Units "unit1", "unit2",....
    # (Default -Units " kg"," ml", " CFU", "RLU", etc...)
#>
function table2md {
    Param(
        [parameter(Mandatory=$False)]
        [string[]]$Units,

        [parameter(Mandatory=$False)]
        [string[]]$DefaultUnits = @(" kg"," g"," cm"," mm"," m"," CFU"," RLU"," ml"," L"," %"," ％"),

        [Parameter(Mandatory=$False)]
        [ValidateSet( " ", ",", "\t")]
        [Alias("d")]
        [string] $Delimiter = "\t",

        [Parameter(Mandatory=$False)]
        [Alias("c")]
        [string] $Caption,

        [parameter(Mandatory=$False,
          ValueFromPipeline=$true)]
        [string[]]$Text
    )
    # private functions
    function isNumeric ($token){
        $double = New-Object System.Double
        if ([Double]::TryParse($token.ToString().Replace('"',''), [ref]$double)) {
            return $True
        } else {
            return $False
        }
    }
    function isNumericAndUnit ($val){
        $uflag = $False
        if($Units){
            foreach($uni in $Units){
                [regex]$reg = $uni + '$'
                if($val -match $reg){
                    $uflag = $True
                }
            }
        }
        return $uflag
    }
    function isNumericAndDefaultUnit ($val){
        $uflag = $False
        if($DefaultUnits){
            foreach($uni in $DefaultUnits){
                [regex]$reg = $uni + '$'
                if($val -match $reg){
                  $uflag = $True
                }
            }
        }
        return $uflag
    }
    function parseTable {
        Param (
            [string[]] $readLines
        )
        [string[]] $retAry = @()
        ## set option (e.g. caption="caption")
        if($Caption){
             $retAry += ,"Table: $Caption"
             $retAry += ,"" }
        ## replace delimiter to pipe
        [int] $rcnt = 0
        foreach ($csvLine in $readLines) {
            $rcnt++
            if($rcnt -eq 2){
                ## align right if colitem is numeric
                $csvColHeader = ''
                $csvColAry = $csvLine -split "$Delimiter"
                foreach ($csvCol in $csvColAry){
                    $csvCol = $csvCol.Trim()
                    if(isNumeric $csvCol){
                        ## numeric
                        $csvColHeader += "| ---: "
                    }elseif(isNumericAndUnit $csvCol){
                        ## numeric and unit
                        $csvColHeader += "| ---: "
                    }elseif(isNumericAndDefaultUnit $csvCol){
                        ## numeric and unit
                        $csvColHeader += "| ---: "
                    }else{
                        ## strings
                        $csvColHeader += "| :--- "
                    }
                }
                $retAry += ,$($csvColHeader + "|")
            }
            $csvLine = $csvLine.Replace('"','')
            $csvLine = $csvLine -replace "$Delimiter",' | '
            $csvLine = $csvLine -replace '^','| '
            $csvLine = $csvLine -replace '$',' |'
            $retAry += ,$csvLine
        }
        return $retAry
    }
    $readListHeader = New-Object 'System.Collections.Generic.List[System.String]'
    $readList       = New-Object 'System.Collections.Generic.List[System.String]'
    [bool] $headerFlag = $False
    [bool] $tableFlag  = $False
    if ($input.Count -ne 0){
      [string[]] $inAry = $input
    } else {
      [string[]] $inAry = Get-ClipBoard
    }
    foreach ($line in $inAry){
        if ($line -match "$Delimiter"){
            $tableFlag = $True
        }
        if (-not $tableFlag){
            $headerFlag = $True
            $readListHeader.Add($line)
        } else {
          if ($line -ne ''){
            $readList.Add($line)
          }
        }
    }
    ## Output header
    if ($headerFlag){
        [string[]]$readHeaders = @()
        [string[]] $readHeaders = $readListHeader.ToArray()
        foreach ($rHeader in $readHeaders){
          Write-Output $rHeader
        }
    }
    ## Output markdown table
    if ($tableFlag){
        [string[]]$readLines = @()
        [string[]] $readLines = $readList.ToArray()
        parseTable $readLines
    }
}
