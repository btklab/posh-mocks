<#
.SYNOPSIS
    ycalc - Calculates the numeric properties horizontally ignoring key fields

        PS > "11 12 33" | ycalc -NoHeader -Sum
        F1 F2 F3 sum
        11 12 33 56

        PS > "k1 k2 12 24 37 11 23" | ycalc -n 2 -NoHeader -Sum -Average -Minimum -Maximum
        F1 F2 F3 F4 F5 F6 F7 sum ave max min
        k1 k2 12 24 37 11 23 107 21.4 37 11

    Usage
        ycalc [[-n|-Num] <Int32>] [-Sum] [-Average] [-Mean] [-Maximum] [-Minimum] [-StandardDeviation] [-AllStats] [-NoHeader]
    
        "ycalc -n 2 -Sum":
            means ignore fields 1-2 as keys,
            sum remaining fields horizontally.
    
    Empty records are skipped.
    Input expects space-separated data with headers.
    Headers should be string, not double
    
    Options
        -NoHeader: No header data

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
    "11 12 33" | ycalc -NoHeader -Sum
    F1 F2 F3 sum
    11 12 33 56

.EXAMPLE
    "k1 k2 12 24 37 11 23" | ycalc -n 2 -NoHeader -Sum -Average -Minimum -Maximum
    F1 F2 F3 F4 F5 F6 F7 sum ave max min
    k1 k2 12 24 37 11 23 107 21.4 37 11

    # "ycalc -n 2 -Sum":
    #     means ignore fields 1-2 as keys,
    #     sum remaining fields horizontally.


.LINK
    ycalc, ycalc, fval

    Measure-Object
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/measure-object


#>
function ycalc {

    param (
        [Parameter( Mandatory=$False, Position=0 )]
        [ValidateScript({ $_ -ge 1 })]
        [Alias('n')]
        [int] $Num,
                
        [Parameter( Mandatory=$False )]
        [switch] $Sum,
        
        [Parameter( Mandatory=$False )]
        [switch] $Average,
        
        [Parameter( Mandatory=$False )]
        [switch] $Mean,
        
        [Parameter( Mandatory=$False )]
        [switch] $Maximum,
        
        [Parameter( Mandatory=$False )]
        [switch] $Minimum,
        
        [Parameter( Mandatory=$False )]
        [switch] $StandardDeviation,
        
        [Parameter( Mandatory=$False )]
        [switch] $AllStats,
        
        [Parameter( Mandatory=$False )]
        [switch] $NoHeader,
        
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
        function calcSum ( [double[]] $inputAry ){
            [double] $retVal = @(
                $inputAry | Measure-Object -Sum ).Sum
            return $retVal
        }
        function calcAverage ( [double[]] $inputAry ){
            [double] $retVal = @(
                $inputAry | Measure-Object -Average ).Average
            return $retVal
        }
        function calcMax ( [double[]] $inputAry ){
            [double] $retVal = @(
                $inputAry | Measure-Object -Maximum ).Maximum
            return $retVal
        }
        function calcMin ( [double[]] $inputAry ){
            [double] $retVal = @(
                $inputAry | Measure-Object -Minimum ).Minimum
            return $retVal
        }
        function calcStdev ( [double[]] $inputAry ){
            [double] $retVal = @(
                $inputAry | Measure-Object -StandardDeviation ).StandardDeviation
            return $retVal
        }
        function createHeader ( [string] $headerStr ){
            if ( $Sum -or $AllStats ){
                $headerStr = $headerStr + $oDelim + "sum"
            }
            if ( $Average -or $Mean -or $AllStats ){
                $headerStr = $headerStr + $oDelim + "ave"
            }
            if ( $Maximum -or $AllStats ){
                $headerStr = $headerStr + $oDelim + "max"
            }
            if ( $Minimum -or $AllStats ){
                $headerStr = $headerStr + $oDelim + "min"
            }
            if ( $StandardDeviation -or $AllStats ){
                $headerStr = $headerStr + $oDelim + "stdev"
            }
            return $headerStr
        }
        function createValFields ( [double[]] $inputAry ){
            [double[]] $tmpValAry = $inputAry
            if ( $Sum -or $AllStats ){
                [double] $tmpVal = calcSum $inputAry
                $tmpValAry += $tmpVal
            }
            if ( $Average -or $Mean -or $AllStats ){
                [double] $tmpVal = calcAverage $inputAry
                $tmpValAry += $tmpVal
            }
            if ( $Maximum -or $AllStats ){
                [double] $tmpVal = calcMax $inputAry
                $tmpValAry += $tmpVal
            }
            if ( $Minimum -or $AllStats ){
                [double] $tmpVal = calcMin $inputAry
                $tmpValAry += $tmpVal
            }
            if ( $StandardDeviation -or $AllStats ){
                [double] $tmpVal = calcStdev $inputAry
                $tmpValAry += $tmpVal
            }
            return $tmpValAry
        }
        # test opt
        [int] $psver = $PSVersionTable.PSVersion.Major
        if ( $StandardDeviation ){
            if ( $psver -lt 6 ){
                Write-Error "-StandardDeviation Beginning in PowerShell 6." -ErrorAction Stop
            }
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
        # skip empty line
        if ( $readLine -eq '' ){
            return
        }
        if ( $emptyDelimiterFlag ){
            [string[]] $splitReadLine = $readLine.ToCharArray()
        } else {
            [string[]] $splitReadLine = $readLine.Split( $iDelim )
        }
        # header
        if ( $rowCounter -eq 1 ){
            if ( $NoHeader ){
                # output header
                [string[]] $headerAry = @()
                for ( $i = 1; $i -le $splitReadLine.Count; $i++){
                    $headerAry += "F$i"
                }
                [string] $headerStr = $headerAry -join $oDelim
                [string] $headerStr = createHeader $headerStr
                Write-Output $headerStr
            } else {
                # are val fields string?
                foreach ( $f in $splitReadLine[($keyPos + 1)..($splitReadLine.Count - 1)]){
                    if ( isDouble $f ) {
                        Write-Error "Header: ""$f"" should be string." -ErrorAction Stop
                    }
                }
                # output header
                [string] $headerStr = createHeader $readLine
                Write-Output $headerStr
                return
            }
        }
        $recordCounter++
        # test opt
        testOpt $splitReadLine $keyPos
        # set key fields
        if ( $Num ) {
            [string] $keys = $splitReadLine[0..$keyPos] -join $oDelim
            [string[]] $splitReadLine = $splitReadLine[($keyPos + 1)..($splitReadLine.Count - 1)]
        }
        # set value fields
        # valType : ""double", "datetime", "string"
        if ( $recordCounter -eq 1){
            [string] $valType = parseValueField ($splitReadLine[0])
            if ( $valType -ne "double" ){
                Write-Error "Detect non ""double"" record: $recordCounter : $readLine" -ErrorAction Stop
            }
        }
        # create value fields
        [string] $valFields = @(createValFields $splitReadLine) -join $oDelim
        # test data type
        [string] $tmpValType = parseValueField ($splitReadLine[0])
        Write-Debug "$valType -> $tmpValType"
        if ( $tmpValType -ne $valType ){
            Write-Error "Different record-type detected: $recordCounter : $readLine" -ErrorAction Stop
        }
        if ( $keys ){
            [string] $writeLine = @($keys, $valFields) -join $oDelim
        } else {
            [string] $writeLine = $valFields
        }
        Write-Output $writeLine
    }
}
