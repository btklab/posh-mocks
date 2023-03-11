<#
.SYNOPSIS
    fillretu - Align records to the maximum number of columns

    Pipline input is only accepted.

    The default string to be filled iin missing cell is "_".
    It can be changed with "-NaN <str>". Brank lines are also 
    repalced with the "-NaN" string.

    Skip blank lines with "-SkipBrank" switch.

    this command suitable for formatting input with
    an indefinite number of columns.

        cat data | yarr -num 1 | fillretu | tateyoko

    Input is passed twice.
    1st pass: count the number of columns in all rows.
    2nd pass: align the nubmer of columns with "NaN" string.

.LINK
    tateyoko, yarr

.PARAMETER NaN
    Specify the string to fill in the missing cells.
    Default: "_"

.PARAMETER Delimiter
    Specify the delimiter for input data.
    Default: " "

.EXAMPLE
cat dat.txt
2018 3
2018 3
2018 3
2017 1
2017 1
2017 1
2017 1
2017 1
2022 5
2022 5

PS > cat dat.txt | grep . | yarr
2018 3 3 3
2017 1 1 1 1 1
2022 5 5

PS > cat dat.txt | grep . | yarr | fillretu
2018 3 3 3 _ _
2017 1 1 1 1 1
2022 5 5 _ _ _

PS > cat dat.txt | grep . | yarr | fillretu -NaN 0
2018 3 3 3 0 0
2017 1 1 1 1 1
2022 5 5 0 0 0

PS > cat dat.txt | yarr | fillretu | tateyoko | keta
2018 2017 2022
   3    1    5
   3    1    5
   3    1    _
   _    1    _
   _    1    _

#>
function fillretu {
    Param (
        [Parameter(Mandatory=$False)]
        [string] $NaN = '_',
        
        [Parameter(Mandatory=$False)]
        [int] $Max,
        
        [Parameter(Mandatory=$False)]
        [switch] $SkipBlank,

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
        ## init var
        [int]$maxCol = 0
        if( -not $Max){
            [string[]]$listAry = @()
            $listObj = New-Object 'System.Collections.Generic.List[System.String]'
        }
        ## pricate functions
        function FillCol {
            Param (
                [int] $MaxCnt,
                [int] $RowCnt,
                [string] $nStr = $NaN,
                [string] $Sep
            )
            [int]$diffCnt = $MaxCnt - $RowCnt
            if ($diffCnt -lt 0){
                Write-Error "Incorrect column number is specified: $RowCnt > $MaxCnt" -ErrorAction Stop
            }
            [string[]] $rstrAry = @()
            for ($i=1; $i -le $diffCnt; $i++){
                $rstrAry += $nStr
            }
            [string]$addRstr = $rstrAry -join $oDelim
            #[string]$addRstr = ($Sep + $nStr) * $diffCnt
            return $addRstr
        }
    }
    process {
        [string] $readLine = [string] $_
        if (($SkipBlank) -and ($readLine -eq '')) {
            #pass
        } else {
            if ( $readLine -eq '' ){
                $readLine = "$NaN"
            }
            if ( $emptyDelimiterFlag ){
                [string[]] $splitLine = $readLine.ToCharArray()
            } else {
                [string[]] $splitLine = $readLine.Split( $iDelim )
            }
            ## count columns
            if ( $readLine -eq '' ){
                [int] $rowCnt = 0
            } else {
                [int] $rowCnt = $splitLine.Count
            }
            ## set row
            if( $Max ){
                # func
                [string] $rstr = FillCol $Max $rowCnt $NaN $oDelim
                if ( $rstr -ne '' ){
                    $splitLine += $rstr
                }
                [string] $writeLine = $splitLine -join $oDelim
                Write-Output $writeLine
            } else {
                ## even
                $listObj.Add( [int] $rowCnt )
                ## odd
                $listObj.Add( [string] $readLine )
                ## set max col num
                if($splitLine.Count -gt $maxCol){
                    $maxCol = $splitLine.Count
                }
            }
        }
    }
    end {
        if (-not $Max){
            [int] $aryCnt = 0
            [string[]] $listAry = @()
            $listAry = $listObj.ToArray()
            foreach ( $line in $listAry ){
                $aryCnt++
                if($aryCnt % 2 -eq 1){
                    ## odd: create add string
                    [int] $rowCol = $line
                    $rstr = ''
                    $rstr = FillCol $maxCol $rowCol $NaN $oDelim
                }else{
                    ## even: output line with additional columns
                    [string[]] $splitLine = $line.Split( $iDelim )
                    if ( $rstr -ne ''){
                        $splitLine += $rstr
                    }
                    [string] $writeLine = $splitLine -join $oDelim
                    Write-Output $writeLine
                }
            }
        }
    }
}
