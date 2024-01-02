<#
.SYNOPSIS
    Grep-Block (Alias: blgrep) - Grep the list while preserving parent-child relationship

    Searches the list and returns the list block by treating a line with:
    
        - a non-blank character at the beginning as a title, and
        - a line with a blank character at the beginning as a body

    Usage:
        cat list.txt | Grep-Block <regex>

    Params:
         [-c|-CaseSensitive]
         [-s|-SimpleMatch]
         [-v|-NotMatch]
         [-t|-OnlyTitle] ...Output only blocks with matching title
         [-SkipBlank]
         
         [[-f|-File] <String>]
         [[-Delimiter] <String>]


.LINK
    Sort-Ordinal, Grep-Block, Sort-Block

.EXAMPLE
    PS > cat list.txt

    - listB
        - B-1
        - B-2
    - listA
        - A-1
        - A-2
        - A-3

    PS > cat list.txt | Grep-Block 'b\-1'

    - listB
        - B-1
        - B-2
    
    PS > cat list.txt | Grep-Block 'b' -OnlyTitle

    - listB
        - B-1
        - B-2

    PS > cat list.txt | Grep-Block "B" -OnlyTitle -CaseSensitive -NotMatch

    - listA
        - A-1
        - A-2
        - A-3

.EXAMPLE
    PS > cat list.txt

    # todo
    (B) 2023-12-01 +proj This is a first ticket  @todo due:2023-12-31
    (A) 2023-12-01 +proj This is a second ticket @todo status:monthly:25
    (B) 2023-12-01 +proj This is a third ticket  @todo status:routine
    x 2023-12-10 2023-12-01 +proj This is a completed ticket @todo

    # book
    Read book [The HACCP book] +haccp @book
        this is body
        link: https://example.com/
    Read book [My book collection] +haccp @book
        link: https://example.com/

    # double hyphen behavior
    x This is done -- Delete the string after the double hyphen #tips #notice
            ...The string after the double hyphen " -- " is deleted
            from the "Act" property when the "-AsObject" option is specified
    x [the -- in the name] is ignored. #tips #notice
            ...The double hyphen " -- " in the [name] is not delete anystring
            after that.

    PS > cat list.txt | Grep-Block '\+haccp|^# '

    # todo
    # book
    Read book [The HACCP book] +haccp @book
        this is body
        link: https://example.com/
    Read book [My book collection] +haccp @book
        link: https://example.com/

    # double hyphen behavior

.EXAMPLE
    # sort list and grep block
    PS > cat list.txt

    # todo
    (B) 2023-12-01 +proj This is a first ticket  @todo due:2023-12-31
    (A) 2023-12-01 +proj This is a second ticket @todo status:monthly:25
    (B) 2023-12-01 +proj This is a third ticket  @todo status:routine
    x 2023-12-10 2023-12-01 +proj This is a completed ticket @todo

    # book
    Read book [The HACCP book] +haccp @book
        this is body
        link: https://example.com/
    Read book [My book collection] +haccp @book
        link: https://example.com/

    # double hyphen behavior
    x This is done -- Delete the string after the double hyphen #tips #notice
            ...The string after the double hyphen " -- " is deleted
            from the "Act" property when the "-AsObject" option is specified
    x [the -- in the name] is ignored. #tips #notice
            ...The double hyphen " -- " in the [name] is not delete anystring
            after that.
    
    # sort list block
    PS > cat list.txt | blsort

    (A) 2023-12-01 +proj This is a second ticket @todo status:monthly:25
    (B) 2023-12-01 +proj This is a first ticket  @todo due:2023-12-31
    (B) 2023-12-01 +proj This is a third ticket  @todo status:routine
    # book
    # double hyphen behavior
    # todo
    Read book [My book collection] +haccp @book
        link: https://example.com/

    Read book [The HACCP book] +haccp @book
        this is body
        link: https://example.com/
    x [the -- in the name] is ignored. #tips #notice
            ...The double hyphen " -- " in the [name] is not delete anystring
            after that.
    x 2023-12-10 2023-12-01 +proj This is a completed ticket @todo

    x This is done -- Delete the string after the double hyphen #tips #notice
            ...The string after the double hyphen " -- " is deleted
            from the "Act" property when the "-AsObject" option is specified

    # sort and grep list block
    PS > cat list.txt | blsort | blgrep '\+haccp|^# '

    # book
    # double hyphen behavior
    # todo
    Read book [My book collection] +haccp @book
        link: https://example.com/

    Read book [The HACCP book] +haccp @book
        this is body
        link: https://example.com/

.EXAMPLE
    # Practical example:
    # Sorting and searching a word dictionary

    PS > cat word-meanings.txt

    reciprocal
        - As an adjective, it means "inversely related",
            "opposite", or "mutually corresponding".
        - As a noun, it can refer to a pair of numbers
            whose product is 1 in mathematics.
        - In physiology, it can describe a phenomenonin
            which one group of muscles is excited and another
            is inhibited.
        - In genetics, it can refer to a pair of crosses in
            which the male and female parent are switched in
            the second cross.

        from Definition of RECIPROCAL - merriam-webster.com
            https://www.merriam-webster.com/dictionary/reciprocal

    mutual
        - Directed by each toward the other or the others.
        - Having the same feelings one for the other.
        - Shared in common.
        - Joint to their mutual advantage.
        - Of or relating to a plan whereby the members of an
            organization share in the profits and expenses.

        from Definition of MUTUAL - merriam-webster.com
            https://www.merriam-webster.com/dictionary/mutual
    
    # sort block
    PS > cat word-meanings.txt | blsort

    mutual
        - Directed by each toward the other or the others.
        - Having the same feelings one for the other.
        - Shared in common.
        - Joint to their mutual advantage.
        - Of or relating to a plan whereby the members of an
                organization share in the profits and expenses.

            from Definition of MUTUAL - merriam-webster.com
                https://www.merriam-webster.com/dictionary/mutual

    reciprocal
        - As an adjective, it means "inversely related",
                "opposite", or "mutually corresponding".
        - As a noun, it can refer to a pair of numbers
                whose product is 1 in mathematics.
        - In physiology, it can describe a phenomenonin
                which one group of muscles is excited and another
                is inhibited.
        - In genetics, it can refer to a pair of crosses in
                which the male and female parent are switched in
                the second cross.

        from Definition of RECIPROCAL - merriam-webster.com
                https://www.merriam-webster.com/dictionary/reciprocal
    
    # output only blocks containing "m" in the title line
    PS > cat word-meanings.txt | blsort | blgrep "m" -OnlyTitle

    mutual
        - Directed by each toward the other or the others.
        - Having the same feelings one for the other.
        - Shared in common.
        - Joint to their mutual advantage.
        - Of or relating to a plan whereby the members of an
                organization share in the profits and expenses.

            from Definition of MUTUAL - merriam-webster.com
                https://www.merriam-webster.com/dictionary/mutual

.NOTES
    Select-String (Microsoft.PowerShell.Utility) - PowerShell
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/select-string
#>
function Grep-Block {
    
    [CmdletBinding()]
    param (
        [Parameter( Mandatory=$True, Position=0 )]
        [Alias('g')]
        [String[]] $Grep,
        
        [Parameter( Mandatory=$False, Position=1 )]
        [Alias('f')]
        [String] $File,
        
        [Parameter( Mandatory=$False )]
        [String] $Delimiter = '^[^\s]',
        
        [Parameter( Mandatory=$False )]
        [Alias('c')]
        [Switch] $CaseSensitive,
        
        [Parameter( Mandatory=$False )]
        [Alias('s')]
        [Switch] $SimpleMatch,
        
        [Parameter( Mandatory=$False )]
        [Alias('v')]
        [Switch] $NotMatch,
        
        [Parameter( Mandatory=$False )]
        [Alias('t')]
        [Switch] $OnlyTitle,
        
        [Parameter( Mandatory=$False )]
        [Switch] $SkipBlank,
        
        [parameter( Mandatory=$False, ValueFromPipeline=$True )]
        [object[]] $InputText
    )
    # input
    if ( $File ){
        # test path
        if ( -not (Test-Path -Path $File) ){
            Write-Error "file: $FIle is not exists." -ErrorAction Stop
        }
        # raed from specified file
        [String[]] $readLineAry = @(Get-Content -Path $File -Encoding utf8)
    } elseif ( $input.Count -gt 0 ) {
        # read from stdin
        [String[]] $readLineAry = @($input)
    } else {
        Write-Error 'Input could not found.' -ErrorAction Stop
    }
    # set opts
    $slsOpts = @{
        Encoding = "utf8"
        Pattern  = $Grep
    }
    if ( $CaseSensitive ){
        $slsOpts.Set_Item('CaseSensitive', $CaseSensitive)
    }
    if ( $SimpleMatch ){
        $slsOpts.Set_Item('SimpleMatch', $SimpleMatch)
    }
    if ( $NotMatch ){
        $slsOpts.Set_Item('NotMatch', $NotMatch)
    }
    # init valriable
    [string] $joinRegex   = $Delimiter
    [string] $joinDelim   = '@j@o@i@n@m@a@r@k@'
    [string] $joinedLine  = ''
    [bool]   $isFirstItem = $True
    Write-Debug "join regex = ""$joinRegex"""
    # private functions
    function isMatchWhole {
        param (
            [String] $testStr,
            $slsOptsDict
        )
        $matchedStrings = $testStr | Select-String @slsOptsDict
        if ( $matchedStrings -ne $Null ) {
            return $True
        } else {
            return $False
        }
    }
    function isMatchOnlyTitle {
        param (
            [String] $testStr,
            $slsOptsDict,
            [String] $splitRegex
        )
        [String[]] $splitAry = $testStr -split $splitRegex
        # test title line
        [String] $testedTitleLine = $splitAry[0]
        $matchedStrings = $testedTitleLine | Select-String @slsOptsDict
        if ( $matchedStrings -ne $Null ) {
            return $True
        } else {
            return $False
        }
    }
    # main
    $readLineAry `
        | ForEach-Object `
            -Process {
                [string] $line = [string] $_
                if ( $SkipBlank -and $line -eq '' ){
                    return
                }
                if ( ($line -match $joinRegex) -and ($line -ne '') ){
                    if ( $isFirstItem ){
                        # set variable
                        $isFirstItem = $False
                        [string] $joinedLine = $line
                    } else {
                        # output and set variable
                        Write-Output $joinedLine
                        [string] $joinedLine = $line
                    }
                } else {
                    # join line
                    $joinedLine = $joinedLine + $joinDelim + $line
                }
            } `
            -End {
                Write-Output $joinedLine
            } `
        | ForEach-Object {
            if ( $OnlyTitle ){
                # output only blocks with matching title
                if ( isMatchOnlyTitle "$_" $slsOpts $joinDelim ){
                    [String[]] $writeAry = "$_" -split $joinDelim
                    Write-Output $writeAry
                }
            } else {
                # output only blocks with matching title and body
                if ( isMatchWhole "$_" $slsOpts ){
                    [String[]] $writeAry = "$_" -split $joinDelim
                    Write-Output $writeAry
                }
            }
        }
}
# set alias
[String] $tmpAliasName = "blgrep"
[String] $tmpCmdName   = "Grep-Block"
[String] $tmpCmdPath = Join-Path `
    -Path $PSScriptRoot `
    -ChildPath $($MyInvocation.MyCommand.Name) `
    | Resolve-Path -Relative
if ( $IsWindows ){ $tmpCmdPath = $tmpCmdPath.Replace('\' ,'/') }
# is alias already exists?
if ((Get-Command -Name $tmpAliasName -ErrorAction SilentlyContinue).Count -gt 0){
    try {
        if ( (Get-Command -Name $tmpAliasName).CommandType -eq "Alias" ){
            if ( (Get-Command -Name $tmpAliasName).ReferencedCommand.Name -eq $tmpCmdName ){
                Set-Alias -Name $tmpAliasName -Value $tmpCmdName -PassThru `
                    | ForEach-Object{
                        Write-Host "$($_.DisplayName)" -ForegroundColor Green
                    }
            } else {
                throw
            }
        } elseif ( "$((Get-Command -Name $tmpAliasName).Name)" -match '\.exe$') {
            Set-Alias -Name $tmpAliasName -Value $tmpCmdName -PassThru `
                | ForEach-Object{
                    Write-Host "$($_.DisplayName)" -ForegroundColor Green
                }
        } else {
            throw
        }
    } catch {
        Write-Error "Alias ""$tmpAliasName ($((Get-Command -Name $tmpAliasName).ReferencedCommand.Name))"" is already exists. Change alias needed. Please edit the script at the end of the file: ""$tmpCmdPath""" -ErrorAction Stop
    } finally {
        Remove-Variable -Name "tmpAliasName" -Force
        Remove-Variable -Name "tmpCmdName" -Force
    }
} else {
    Set-Alias -Name $tmpAliasName -Value $tmpCmdName -PassThru `
        | ForEach-Object {
            Write-Host "$($_.DisplayName)" -ForegroundColor Green
        }
    Remove-Variable -Name "tmpAliasName" -Force
    Remove-Variable -Name "tmpCmdName" -Force
}
