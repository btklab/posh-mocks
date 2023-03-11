<#
.SYNOPSIS
    fval - Format values of specified column
    
    fval [-f|-Format] <String> [[-n|-Num] <Int32[]>] [-SkipHeader]

    "-n <n>[<m>]" means format the values in columns from <n> to <m>

    Example
        PS > "1111 2222 3333" | fval '#,0.0' 2, 3
        1111 2,222.0 3,333.0

.PARAMETER Delimiter
    Input/Output field separator.
    Alias: -fs
    Default value is space " ".

.PARAMETER InputDelimiter
    Input field separator.
    Alias: -ifs
    If fs is already set, this option is primarily used.

.PARAMETER OutoputDelimiter
    Output field separator.
    Alias: -ofs
    If fs is already set, this option is primarily used.

.EXAMPLE
    "1111 2222 3333" | fval '#,0.0' 2, 3
    1111 2,222.0 3,333.0

.LINK
    ysort, ycalc, fval

    Understanding PowerShell and Basic String Formatting
    https://devblogs.microsoft.com/scripting/understanding-powershell-and-basic-string-formatting/


#>
function fval {

    param (
        [Parameter( Mandatory=$True, Position=0 )]
        [Alias('f')]
        [string] $Format,
        
        [Parameter( Mandatory=$False, Position=1 )]
        [Alias('n')]
        [int[]] $Num = @(1, 1),
        
        [Parameter( Mandatory=$False )]
        [switch] $SkipHeader,
        
        [Parameter( Mandatory=$False )]
        [Alias('fs')]
        [string] $Delimiter = ' ',
        
        [Parameter( Mandatory=$False )]
        [Alias('ifs')]
        [string] $InputDelimiter,
        
        [Parameter( Mandatory=$False )]
        [Alias('ofs')]
        [string] $OutputDelimiter,
        
        [parameter( Mandatory=$False, ValueFromPipeline=$True )]
        [string[]] $InputText
    )

    begin {
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
        # private functions
        function isDouble {
            param(
                [parameter(Mandatory=$True, Position=0)]
                [string] $Token
            )
            $Token = $Token.Trim()
            $double = New-Object System.Double
            switch -Exact ( $Token.ToString() ) {
                {[Double]::TryParse( $Token.Replace('_',''), [ref] $double )} {
                    return $True
                }
                default {
                    return $False
                }
            }
        }
        # init variables
        [int] $rowCounter = 0
        if ( $Num.Count -lt 2){
            [int] $sCol = $Num[0]
            [int] $eCol = $Num[0]
        } else {
            [int] $sCol = $Num[0]
            [int] $eCol = $Num[1]
        }
    }

    process {
        $rowCounter++
        [string] $readLine = [string] $_
        if ( $SkipHeader -and $rowCounter -eq 1 ){
            Write-Output $readLine
            return
        }
        if ( $readLine -eq '' ){
            # skip empty line
            return
        }
        if ( $emptyDelimiterFlag ){
            [string[]] $splitReadLine = $readLine.ToCharArray()
        } else {
            [string[]] $splitReadLine = $readLine.Split( $iDelim )
        }
        [string[]] $tmpAry = @()
        [int] $aryCounter = 0
        foreach ( $item in $splitReadLine ){
            $aryCounter++
            if ( $aryCounter -ge $sCol -and $aryCounter -le $eCol ){
                if ( -not (isDouble $item) ){
                    Write-Error "Detect non ""double"" record: $readLine" -ErrorAction Stop
                }
                $tmpAry += ([double]($item)).ToString( $Format )
            } else {
                $tmpAry += $item
            }
        }
        [string] $writeLine = $tmpAry -join $oDelim
        Write-Output $writeLine
    }
}
