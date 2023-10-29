<#
.SYNOPSIS
    ysort - Sort horizontally ignoring key fields

    Usage
        ysort [[-n|-Num] <Int32>] [-Cast <String>] [-Descending] [-CaseSensitive] [-Unique] [-SkipHeader]

        PS > "key1 key2 2 4 7 1 3" | ysort -n 2
        key1 key2 1 2 3 4 7

    Roughly equivalent to the script below:

        "3 1 2 11" | %{ ("$_".Split(" ") | sort) -join " " }
        "3 1 2 11" | %{ ("$_".Split(" ") | sort { [double]$_ }) -join " " }

    The type of values to be sorted is determined by the leftmost column of the first
    record. If the type changes after 2 records, exit with an error.

    Auto detect types:
        double   [System.Double]
        datetime [System.DateTime]
        version  [System.Version]
        string   [System.String]

    Empty records are skipped.
    
    Options
        -SkipHeader: skip first record
        -Cast <datatype>: any data type can be specified.
        -Ordinal: ordinal sort

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
    "C B A" | ysort
    A B C

.EXAMPLE
    # input
    $dat = @("3 2 2 1 12 22", "123 75 12 12 22 01 87 26", "98 21 21 67 59 1")

    $dat
    3 2 2 1 12 22
    123 75 12 12 22 01 87 26
    98 21 21 67 59 1

    $dat | ysort
    1 2 2 3 12 22
    01 12 12 22 26 75 87 123
    1 21 21 59 67 98

    $dat | ysort -Unique
    1 2 3 12 22
    01 12 22 26 75 87 123
    1 21 59 67 98

    $dat | ysort -Descending
    22 12 3 2 2 1
    123 87 75 26 22 12 12 01
    98 67 59 21 21 1

    $dat | ysort -Cast double
    1 2 2 3 12 22
    01 12 12 22 26 75 87 123
    1 21 21 59 67 98

    $dat | ysort -Cast string
    1 12 2 2 22 3
    01 12 12 123 22 26 75 87
    1 21 21 59 67 98

.EXAMPLE
    # input (leftmost value is key string)
    $dat = @("ABC 2 2 3 12 22", "DEF 123 75 12 22 01", "XYZ 98 21 67 59 1")

    $dat
    ABC 2 2 3 12 22
    DEF 123 75 12 22 01
    XYZ 98 21 67 59 1

    # "-n 1" means key fields from 1 to 1, others are value fields
    # or "-n <n>" means sort by ignoring 1 to <n> fields
    $dat | ysort -n 1
    ABC 2 2 3 12 22
    DEF 01 12 22 75 123
    XYZ 1 21 59 67 98

    # If the key string is in the leftmost column,
    # it will be sorted as a string if no key field is specified.
    $dat | ysort  ## Oops! forgot to specify a key field (-n 1)!
    12 2 2 22 3 ABC
    01 12 123 22 75 DEF
    1 21 59 67 98 XYZ

.EXAMPLE
    # error example

    # sort data type detected from first record
    # input (second record type (string) is different fron first (double))
    $dat = @("3 2 2 1 12 22", "ABC 75 12 12 22 01 87 26", "98 21 21 67 59 1")

    $dat
    3 2 2 1 12 22
    ABC 75 12 12 22 01 87 26
    98 21 21 67 59 1

    # so the following raises an error and stop processing
    $dat | ysort
    1 2 2 3 12 22
    Sort-Object: C:\Users\btklab\cms\drafts\ysort_function.ps1:152
    Line |
     152 |                  | Sort-Object { [double] $_ } `
         |                    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         | Cannot convert value "ABC" to type "System.Double". Error: "The input string 'ABC' was not in a correct format."
    ysort: Different record type detected: 2 : ABC 75 12 12 22 01 87 26


.EXAMPLE
    # version sort example
    "192.1.3.2 192.11.3.1 192.2.3.5" | ysort

    "192.1.3.2 192.11.3.1 192.2.3.5" | ysort -Cast version
    192.1.3.2 192.2.3.5 192.11.3.1

.EXAMPLE
    # datetime sort example
    "2021-4-10 2021-4-1 2021-4-5" | ysort
    2021-4-1 2021-4-5 2021-4-10

    "2021/4/10 2021/4/1 2021/4/5" | ysort -Cast datetime
    2021-4-1 2021-4-5 2021-4-10

.EXAMPLE
    # specified delimiter
    "ABC321" | ysort -n 3 -fs ""
    ABC123

.EXAMPLE
    # ordinal sort

    "abc1 Abc2 abc3 Abc4" | ysort
    abc1 Abc2 abc3 Abc4

    "abc1 Abc2 abc3 Abc4" | ysort -Ordinal
    Abc2 Abc4 abc1 abc3

.LINK
    ysort, ycalc

#>
function ysort {

    param (
        [Parameter( Mandatory=$False, Position=0 )]
        [ValidateScript({ $_ -ge 1 })]
        [Alias('n')]
        [int] $Num,
        
        [Parameter( Mandatory=$False )]
        [ValidateSet(
            "string",
            "int",
            "double",
            "decimal",
            "version",
            "datetime"
        )]
        [string] $Cast,
        
        [Parameter( Mandatory=$False )]
        [switch] $Descending,
        
        [Parameter( Mandatory=$False )]
        [switch] $CaseSensitive,
        
        [Parameter( Mandatory=$False )]
        [switch] $Unique,
        
        [Parameter( Mandatory=$False )]
        [switch] $SkipHeader,
        
        [Parameter( Mandatory=$False )]
        [switch] $Ordinal,
        
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
        function testOpt ( [string[]] $lineAry, $keyPos ){
            if ( $keyPos -ne -1 ){
                if ( ($keyPos + 1) -ge $lineAry.Count ){
                    Write-Error "-Num must be set less than field nubmer: $($lineAry.Count)" -ErrorAction Stop
                }
            }
            return
        }
        function parseValueField {
            param(
                [parameter(Mandatory=$True, Position=0)]
                [string] $Token
            )
            $Token = $Token.Trim()
            $double = New-Object System.Double
            $version = New-Object System.Version
            $datetime = New-Object System.DateTime
            switch -Exact ( $Token.ToString() ) {
                {[Double]::TryParse( $Token.Replace('_',''), [ref] $double )} {
                    return "double"
                    break
                }
                {[Datetime]::TryParse( $Token, [ref] $datetime )} {
                    return "datetime"
                    break
                }
                {[Version]::TryParse( $Token, [ref] $version )} {
                    return "version"
                    break
                }
                default {
                    return "string"
                    break
                }
            }
        }
        function sortByStringOrdinal ( [string[]] $splitReadLine ){
            [string] $sortedVals = @($splitReadLine `
                | Sort-Object {
                    -join ( [int[]] $_.ToCharArray()).ForEach('ToString', 'x4')
                } `
                -Descending:$Descending `
                -CaseSensitive:$CaseSensitive `
                -Unique:$Unique `
                ) -join $oDelim
            return $sortedVals
        }
        function sortByString ( [string[]] $splitReadLine ){
            [string] $sortedVals = @($splitReadLine `
                | Sort-Object { [string] $_ } `
                    -Descending:$Descending `
                    -CaseSensitive:$CaseSensitive `
                    -Unique:$Unique `
                    ) -join $oDelim
            return $sortedVals
        }
        function sortByInt ( [string[]] $splitReadLine ){
            [string] $sortedVals = @($splitReadLine `
                | Sort-Object { [int] $_ } `
                    -Descending:$Descending `
                    -Unique:$Unique `
                    ) -join $oDelim
            return $sortedVals
        }
        function sortByDouble ( [string[]] $splitReadLine ){
            [string] $sortedVals = @($splitReadLine `
                | Sort-Object { [double] $_ } `
                    -Descending:$Descending `
                    -Unique:$Unique `
                    ) -join $oDelim
            return $sortedVals
        }
        function sortByDatetime ( [string[]] $splitReadLine ){
            [string] $sortedVals = @($splitReadLine `
                | Sort-Object { [datetime] $_ } `
                    -Descending:$Descending `
                    -Unique:$Unique `
                    ) -join $oDelim
            return $sortedVals
        }
        function sortByVersion ( [string[]] $splitReadLine ){
            [string] $sortedVals = @($splitReadLine `
                | Sort-Object { [version] $_ } `
                    -Descending:$Descending `
                    -Unique:$Unique `
                    ) -join $oDelim
            return $sortedVals
        }
        function sortByDecimal ( [string[]] $splitReadLine ){
            [string] $sortedVals = @($splitReadLine `
                | Sort-Object { [decimal] $_ } `
                    -Descending:$Descending `
                    -Unique:$Unique `
                    ) -join $oDelim
            return $sortedVals
        }
        # init variables
        [int] $rowCounter = 0
        [int] $recordCounter = 0
        if ( $Num ){
            [int] $keyPos = $Num - 1
        } else {
            [int] $keyPos = -1
        }
    }

    process {
        $rowCounter++
        [string] $readLine = [string] $_
        # skip header
        if ( $SkipHeader -and $rowCounter -eq 1 ){
            return
        }
        # skip empty line
        if ( $readLine -eq '' ){
            return
        }
        $recordCounter++
        if ( $emptyDelimiterFlag ){
            [string[]] $splitReadLine = $readLine.ToCharArray()
        } else {
            [string[]] $splitReadLine = $readLine.Split( $iDelim )
        }
        # test opt
        testOpt $splitReadLine $keyPos
        # set key fields
        [string] $keys = ''
        if ( $Num ) {
            [string] $keys = $splitReadLine[0..$keyPos] -join $oDelim
            [string[]] $splitReadLine = $splitReadLine[($keyPos + 1)..($splitReadLine.Count - 1)]
        }
        # set value fields
        # valType : ""double", "datetime", "string"
        if ( $recordCounter -eq 1){
            [string] $valType = parseValueField ($splitReadLine[0])
        }
        if ( $Cast ){
            # cast
            switch -Exact ( $Cast ){
                "int" {
                    [string] $sortedVals = sortByInt $splitReadLine; break
                }
                "double" {
                    [string] $sortedVals = sortByDouble $splitReadLine; break
                }
                "datetime" {
                    [string] $sortedVals = sortByDatetime $splitReadLine; break
                }
                "version" {
                    [string] $sortedVals = sortByVersion $splitReadLine; break
                }
                "decimal" {
                    [string] $sortedVals = sortByDecimal $splitReadLine; break
                }
                "string" {
                    if ( $Ordinal ){
                        [string] $sortedVals = sortByStringOrdinal $splitReadLine; break
                    } else {
                        [string] $sortedVals = sortByString $splitReadLine; break
                    }
                }
                default {
                    Write-Error "Parse error value field: $($splitReadLine[0])" -ErrorAction Stop
                }
            }
        } else {
            # auto parse
            switch -Exact ( $valType ){
                "double" {
                    Write-Debug 'val type: double'
                    [string] $sortedVals = sortByDouble $splitReadLine; break
                }
                "datetime" {
                    Write-Debug 'val type: datetime'
                    [string] $sortedVals = sortByDatetime $splitReadLine; break
                }
                "version" {
                    Write-Debug 'val type: verstion'
                    [string] $sortedVals = sortByVersion $splitReadLine; break
                }
                "string" {
                    Write-Debug 'val type: string'
                    if ( $Ordinal ){
                        [string] $sortedVals = sortByStringOrdinal $splitReadLine; break
                    } else {
                        [string] $sortedVals = sortByString $splitReadLine; break
                    }
                }
                default {
                    Write-Error "Parse error value field: $($splitReadLine[0])" -ErrorAction Stop
                }
            }
        }
        # test data type
        [string] $tmpValType = parseValueField ($splitReadLine[0])
        if ( $tmpValType -ne $valType ){
            Write-Error "Different record type detected: $recordCounter : $readLine" -ErrorAction Stop
        }
        if ( $keys ){
            [string] $writeLine = @($keys, $sortedVals) -join $oDelim
        } else {
            [string] $writeLine = $sortedVals
        }
        Write-Output $writeLine
    }
}
