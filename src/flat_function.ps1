<#
.SYNOPSIS
    flat - Flat columns

    Wraps space-separated input into an arbitrary
    number of columns.

    If no argument, all lines  are formatted into
    a single line.

    Inspired by:
        greymd/egzact: Generate flexible patterns on the shell - GitHub
        https://github.com/greymd/egzact

.PARAMETER Delimiter
    Field separator. -fs
    Default value is space " ".

.PARAMETER InputDelimiter
    Input field separator. -ifs
    If fs is already set, this option is primarily used.

.PARAMETER OutoputDelimiter
    Output field separator. -ofs
    If fs is already set, this option is primarily used.

.EXAMPLE
    1..9 | flat
    1 2 3 4 5 6 7 8 9

.EXAMPLE
    1..9 | flat 4
    1 2 3 4
    5 6 7 8
    9

.EXAMPLE
    echo "aiueo" | flat -fs ""
    aiu
    eo

#>
function flat {
    param (
        [Parameter(Mandatory=$False, Position=0)]
        [Alias('n')]
        [int] $Num,

        [Parameter(Mandatory=$False)]
        [Alias('fs')]
        [string] $Delimiter = ' ',

        [Parameter(Mandatory=$False)]
        [Alias('ifs')]
        [string] $InputDelimiter,

        [Parameter(Mandatory=$False)]
        [Alias('ofs')]
        [string] $OutputDelimiter,

        [parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [string[]] $InputText
    )
    begin {
        # parse option
        if (-not $Num){
            [bool] $flatFlag = $True
        } else {
            [bool] $flatFlag = $False
        }
        # set input/output delimiter
        if ( $InputDelimiter -and $OutputDelimiter ){
            [string] $iDelim = $InputDelimiter
            [string] $oDelim = $OutputDelimiter
        } elseif ( $InputDelimiter ){
            [string] $iDelim = $InputDelimiter
            [string] $oDelim = $InputDelimiter
        } elseif ( $OutputDelimiter ){
            [string] $iDelim = $Delimiter
            [string] $oDelim = $OutputDelimiter
        } else {
            [string] $iDelim = $Delimiter
            [string] $oDelim = $Delimiter
        }
        # test is iDelim -eq ''?
        if ($iDelim -eq ''){
            [bool] $emptyDelimiterFlag = $True
        } else {
            [bool] $emptyDelimiterFlag = $False
        }
        # init var
        [int] $cnt = 0
        [string] $tempLine = ''
        $tempAryList = New-Object 'System.Collections.Generic.List[System.String]'
    }
    process {
        [string] $line = [string] $_
        if ($flatFlag){
            # flatten input
            $tempAryList.Add($line)
        } else {
            if ( $emptyDelimiterFlag ){
                [string[]] $splitLine = $line.ToCharArray()
            } else {
                [string[]] $splitLine = $line.Split( $iDelim )
            }
            foreach ($s in $splitLine){
                $cnt++
                if ($cnt -lt $Num){
                    $tempAryList.Add($s)
                } else {
                    $tempAryList.Add($s)
                    [string] $tempLine = $tempAryList.ToArray() -join $oDelim
                    Write-Output $tempLine
                    $cnt = 0
                    $tempAryList = New-Object 'System.Collections.Generic.List[System.String]'
                }
            }
        }
    }
    end {
        if ($tempAryList.ToArray().Count -gt 0){
            [string] $tempLine = $tempAryList.ToArray() -join $oDelim
            Write-Output $tempLine
        }
    }
}
