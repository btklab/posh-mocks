<#
.SYNOPSIS
    lcalc2 - Column-to-column calculator
    
    Column-to-column calcurations with script block
    on space delimited stdin.

        lcalc2 {expr; expr;...} [-d "delim"] [-c|-Calculator]
    
    Auto-Skip empty row.
    Multiple expr with ";" in scriptblock.

    Built-in variables:
      $1,$2,... : Column indexes starting with 1
      $NF       : Rightmost column
      $NR       : Row number of each records

.EXAMPLE
    # Multiple expr using ";" in scriptblock

    # data
    "8.3 70","8.6 65","8.8 63"
    8.3 70
    8.6 65
    8.8 63

    # calc
    "8.3 70","8.6 65","8.8 63" `
        | lcalc2 {$1+1;$2+10}
    8.3 70 9.3 80
    8.6 65 9.6 75
    8.8 63 9.8 73

.EXAMPLE
    # Output only result

    # input
    "8.3 70","8.6 65","8.8 63"
    8.3 70
    8.6 65
    8.8 63

    # output 1
    "8.3 70","8.6 65","8.8 63" `
        | lcalc2 {$1+1; $2+10} -OnlyOutputResult
    9.3 80
    9.6 75
    9.8 73

    # output 2
    #   Put result on the left,
    #   put original field on the right,
    #   with -OnlyOutputResult and $0
    "8.3 70","8.6 65","8.8 63" `
        | lcalc2 {$1+1; $2+10; $0} -OnlyOutputResult
    9.3 80 8.3 70
    9.6 75 8.6 65
    9.8 73 8.8 63

.EXAMPLE
    # Get row number of record
    1..5 | lcalc2 {$NR}
    1 1
    2 2
    3 3
    4 4
    5 5

.EXAMPLE
    # Calculator mode

    lcalc2 -Calculator {1+1}
    2

    # calculator mode does not require
    # standard input (from pipline)

    lcalc2 -c {1+[math]::sqrt(4)}
    3

    lcalc2 -c {[math]::pi}
    3.14159265358979

    lcalc2 -c {[math]::Ceiling(1.1)}
    2

.EXAMPLE
    # Calculate average with sm2 and lcalc2 command

    ## input
    "A 1 10","B 1 10","A 1 10","C 1 10"
    A 1 10
    B 1 10
    A 1 10
    C 1 10

    ## sum up
    "A 1 10","B 1 10","A 1 10","C 1 10" `
        | sort `
        | sm2 +count 1 2 3 3
    2 A 1 20
    1 B 1 10
    1 C 1 10

    ## calc average
    "A 1 10","B 1 10","A 1 10","C 1 10" `
        | sort `
        | sm2 +count 1 2 3 3 `
        | lcalc2 {$NF/$1}
    2 A 1 20 10
    1 B 1 10 10
    1 C 1 10 10

#>
function lcalc2 {
    Param(
        [Parameter( Mandatory=$True, Position=0 )]
        [Alias('f')]
        [ScriptBlock] $Formula,

        [Parameter(Mandatory=$False)]
        [Alias('fs')]
        [string] $Delimiter = ' ',

        [Parameter(Mandatory=$False)]
        [Alias('ifs')]
        [string] $InputDelimiter,

        [Parameter(Mandatory=$False)]
        [Alias('ofs')]
        [string] $OutputDelimiter,

        [Parameter(Mandatory=$False)]
        [Alias('c')]
        [switch] $Calculator,

        [Parameter(Mandatory=$False)]
        [Alias('o')]
        [switch] $OnlyOutputResult,

        [Parameter(Mandatory=$False)]
        [Alias('s')]
        [switch] $SkipHeader,

        [parameter(
            Mandatory=$False,
            ValueFromPipeline=$True)]
        [string[]] $InputObject
    )
    begin
    {
        # init var
        [int] $NR = 0
        [int] $rowCounter = 0
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
        # test is iDelim -eq empty string?
        if ($iDelim -eq ''){
            [bool] $emptyDelimiterFlag = $True
        } else {
            [bool] $emptyDelimiterFlag = $False
        }
        # private functions
        function replaceFieldStr ([string] $str){
            $str = " " + $str
            $str = escapeDollarMarkBetweenQuotes $str
            $str = $str.Replace('$0','($self -join "$oDelim")')
            $str = $str -replace('([^\\`])\$NF','$1$self[($self.Count - 1)]')
            $str = $str -replace '([^\\`])\$(\d+)','$1$self[($2-1)]'
            $str = $str.Replace('\$','$').Replace('`$','$')
            $str = $str.Trim()
            return $str
        }
        function escapeDollarMarkBetweenQuotes ([string] $str){
            # escape "$" to "\$" between single quotes
            [bool] $escapeFlag = $False
            [string[]] $strAry = $str.GetEnumerator() | ForEach-Object {
                    [string] $char = [string] $_
                    if ($char -eq "'"){
                        if ($escapeFlag -eq $False){
                            $escapeFlag = $True
                        } else {
                            $escapeFlag = $False
                        }
                    } else {
                        if (($escapeFlag) -and ($char -eq '$')){
                            $char = '\$'
                        }
                    }
                    Write-Output $char
                }
            [string] $ret = $strAry -Join ''
            return $ret
        }
        function escapeSemiColonBetweenQuotes ([string] $str, [string] $quote = "'"){
            # delete ";" between single quotes
            [bool] $escapeFlag = $False
            [string[]] $strAry = $str.GetEnumerator() | ForEach-Object {
                    [string] $char = [string] $_
                    if ($char -eq "$quote"){
                        if ($escapeFlag -eq $False){
                            $escapeFlag = $True
                        } else {
                            $escapeFlag = $False
                        }
                    } else {
                        if (($escapeFlag) -and ($char -eq ';')){
                            $char = '_'
                        }
                    }
                    Write-Output $char
                }
            [string] $ret = $strAry -Join ''
            return $ret
        }
        function tryParseDecimal {
            param(
                [parameter(Mandatory=$True, Position=0)]
                [string] $val
            )
            [string] $val = $val.Trim()
            if ($val -match '^0[0-9]+$'){
                return $val
            }
            $decimalObject = New-Object System.Decimal
            if ($ParseBoolAndNull){
                switch -Exact ($val) {
                    "true"  { return $True }
                    "false" { return $False }
                    "yes"   { return $True }
                    "no"    { return $False }
                    "on"    { return $True }
                    "off"   { return $False }
                    "null"  { return $Null }
                    "nil"   { return $Null }
                    default {
                        #pass
                        }
                }
            }
            switch -Exact ($val) {
                {[Double]::TryParse($val.Replace('_',''), [ref] $decimalObject)} {
                    return $decimalObject
                }
                default {
                    return $val
                }
            }
        }
        # set formula
        [string] $FormulaBlockStr = $Formula.ToString().Trim()
        [string] $FormulaBlockStr = replaceFieldStr $FormulaBlockStr
        Write-Debug "Formula: $FormulaBlockStr"
        # Count field number in Formula
        [string] $FBStrForCountFieldNum = escapeSemiColonBetweenQuotes $FormulaBlockStr "'"
        [string] $FBStrForCountFieldNum = escapeSemiColonBetweenQuotes $FBStrForCountFieldNum '"'
        [int] $CountFieldNumOfFormula = $FBStrForCountFieldNum.Split(";").Count
        Write-Debug "Rep-Formula: $FBStrForCountFieldNum"
        Write-Debug "FieldCountOfFormula: [$CountFieldNumOfFormula]"
    }
    process
    {
        # set variables
        $rowCounter++
        [string] $line = [string] $_
        if ( -not $Calculator ){
            if ( $SkipHeader -and $rowCounter -eq 1 ){
                return
            }
            if ($line -eq ''){
                return
            }
            # main
            $NR++
            if ( $emptyDelimiterFlag ){
                [string[]] $tmpAry = $line.ToCharArray()
            } else {
                [string[]] $tmpAry = $line.Split( $iDelim )
            }
            #[int] $NF = $tmpAry.Count
            [object[]] $self = @()
            # output whole line
            foreach ($element in $tmpAry){
                $self += tryParseDecimal $element
            }
            if ( $OnlyOutputResult ){
                [object[]] $self2 = @()
                $self2 += Invoke-Expression -Command $FormulaBlockStr -ErrorAction Stop
                $self2 -Join "$oDelim"
            } else {
                $self += Invoke-Expression -Command $FormulaBlockStr -ErrorAction Stop
                $self -Join "$oDelim"
            }
        }
    }
    end
    {
        if( $Calculator ){
            Invoke-Expression -Command $FormulaBlockStr -ErrorAction Stop
        }
    }
}
