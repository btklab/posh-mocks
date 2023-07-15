<#
.SYNOPSIS
    conv - Convolution operation or find N-gram of text
    
    Convolution operation with the specified number of columns
    for each input record. Instead of just wrapping lines, each
    lines shifts the previous line to the left by one element.

    Default field separator is space.
    
    Usage
        conv <num> [-fs DELIMITER] [-r] [-f]
    
    Option
        -r : output number of record in the left column
        -f : output number of fields in the left column
        -fs : input/output field separator
        -ifs : input field separator
        -ofs : output field separator
        -nfs : field separator for only "-r" and "-f" option
    
    Examples
        @(1..10) -join " " | conv 3
        1 2 3
        2 3 4
        3 4 5
        4 5 6
        5 6 7
        6 7 8
        7 8 9
        8 9 10
    
        # N-gram of text
        "にわにはにわにわとりがいる" | conv -fs '' 2
        にわ
        わに
        には
        はに
        にわ
        わに
        にわ
        わと
        とり
        りが
        がい
        いる


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
    @(1..10) -join " " | conv 3
    PS > 1..10 | flat | conv 3
    1 2 3
    2 3 4
    3 4 5
    4 5 6
    5 6 7
    6 7 8
    7 8 9
    8 9 10

.EXAMPLE
    # N-gram of text
    Write-Output "にわにはにわにわとりがいる" | conv -fs '' 2
    にわ
    わに
    には
    はに
    にわ
    わに
    にわ
    わと
    とり
    りが
    がい
    いる

    # output -n (NumOfRecord), and -f (NumOfField)
    Write-Output "にわにはにわにわとりがいる" | conv -fs '' 2 -r -f
    1 1 にわ
    1 2 わに
    1 3 には
    1 4 はに
    1 5 にわ
    1 6 わに
    1 7 にわ
    1 8 わと
    1 9 とり
    1 10 りが
    1 11 がい
    1 12 いる

.LINK
    Inspired by greymd/egzact: Generate flexible patterns on the shell - GitHub
    License: The MIT License (MIT): Copyright (c) 2016 Yasuhiro, Yamada
    uri: https://github.com/greymd/egzact
    
    Qiita:greymd, 2016/05/12, accessed 2017/11/13
    uri: https://qiita.com/greymd/items/3515869d9ed2a1a61a49

.NOTES
    Author: btklab
    Website: https://github.com/btklab/posh-mocks

#>
function conv {

    param (
        [Parameter( Mandatory=$True, Position=0 )]
        [Alias('n')]
        [ValidateScript({ $_ -gt 0 })]
        [int] $Num,
        
        [Parameter( Mandatory=$False )]
        [Alias('r')]
        [switch] $NumberOfRecord,
        
        [Parameter( Mandatory=$False )]
        [Alias('f')]
        [switch] $NumberOfField,
        
        [Parameter( Mandatory=$False )]
        [Alias('fs')]
        [string] $Delimiter = ' ',
        
        [Parameter( Mandatory=$False )]
        [Alias('ifs')]
        [string] $InputDelimiter,
        
        [Parameter( Mandatory=$False )]
        [Alias('ofs')]
        [string] $OutputDelimiter,
        
        [Parameter( Mandatory=$False )]
        [Alias('nfs')]
        [string] $NumberDelimiter = ' ',
        
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

        # init variables
        [int] $rowCounter = 0
        [string] $tempLine = ''
    }

    process {
        $rowCounter++
        [string] $readLine = [string] $_
        if ( $readLine -eq '' ){
            # skip empty line
            [string[]] $writeLineAry = @()
            if ( $NumberOfRecord ){
                $writeLineAry += [string] $rowCounter
            }
            if ( $NumberOfField ){
                $writeLineAry += '0'
            }
            if ( $writeLineAry.Count -gt 0){
                $writeLineAry += ''
                [string] $writeLine = $writeLineAry -join $NumberDelimiter
                Write-Output $writeLine
            } else {
                Write-Output ''
            }
            return
        }
        if ( $emptyDelimiterFlag ){
            [string[]] $splitReadLine = $readLine.ToCharArray()
        } else {
            [string[]] $splitReadLine = $readLine.Split( $iDelim )
        }
        [int] $sField = 0
        [int] $eField = $splitReadLine.Count - $Num
        if ( ($eField -lt 1) ) {
            [string[]] $writeLineAry = @()
            $writeLineAry += [string] $rowCounter
            $writeLineAry += "1"
            $writeLineAry += $readLine
            [string] $writeLine = $writeLineAry -join $NumberDelimiter
            Write-Output $writeLine
            return
        }
        # output conv
        for ( $i=0; $i -le $eField; $i++ ) {
            [string[]] $writeLineAry = @()
            if ( $NumberOfRecord ){
                $writeLineAry += [string] $rowCounter
            }
            if ( $NumberOfField ){
                $writeLineAry += [string] ($i + 1)
            }
            if ( $writeLineAry.Count -gt 0){
                $writeLineAry += $splitReadLine[$i..($i+$Num-1)] -join $oDelim
                [string] $writeLine = $writeLineAry -join $NumberDelimiter
                Write-Output $writeLine
            } else {
                [string] $writeLine = $splitReadLine[$i..($i+$Num-1)] -join $oDelim
                Write-Output $writeLine
            }
        }
    }

}

