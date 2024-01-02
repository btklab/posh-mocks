<#
.SYNOPSIS
    Sort-Block (Alias: blsort) - Sort based on the title line without destroying the body of the list

    Sort the list and returns the list block by treating a line with:
    
        - a non-blank character at the beginning as a title, and
        - a line with a blank character at the beginning as a body

    Usage:
        cat list.txt | Sort-Block
    
    Params:
         [-d|-Descending]
         [-c|-CaseSensitive]
         [-u|-Unique]
         [-s|-Stable]
         [-o|-Ordinal]
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

    PS > cat list.txt | Sort-Block

    - listA
        - A-1
        - A-2
        - A-3
    - listB
        - B-1
        - B-2

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
    Sort-Object (Microsoft.PowerShell.Utility) - PowerShell
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/sort-object

#>
function Sort-Block {
    
    [CmdletBinding()]
    param (
        [Parameter( Mandatory=$False )]
        [Alias('f')]
        [String] $File,
        
        [Parameter( Mandatory=$False )]
        [String] $Delimiter = '^[^\s]',
        
        [Parameter( Mandatory=$False )]
        [Alias('d')]
        [Switch] $Descending,
        
        [Parameter( Mandatory=$False )]
        [Alias('c')]
        [Switch] $CaseSensitive,
        
        [Parameter( Mandatory=$False )]
        [Alias('u')]
        [Switch] $Unique,
        
        [Parameter( Mandatory=$False )]
        [Alias('s')]
        [Switch] $Stable,
        
        [Parameter( Mandatory=$False )]
        [Alias('o')]
        [Switch] $Ordinal,
        
        [Parameter( Mandatory=$False )]
        [Switch] $SkipBlank,
        
        [parameter( Mandatory=$False, ValueFromPipeline=$True )]
        [Object[]] $InputText
    )
    # input
    $slsOpts = @{
        Encoding = "utf8"
        Pattern = '^'
    }
    if ( $File ){
        # test path
        if ( -not (Test-Path -Path $File) ){
            Write-Error "file: $FIle is not exists." -ErrorAction Stop
        }
        # raed from specified file
        [String] $iFileName = $File
        $slsOpts.Set_Item('Path', (Get-ChildItem -Path $iFileName))
        [String[]] $readLineAry = (Select-String @slsOpts).Line
    } elseif ( $input.Count -gt 0 ) {
        # read from stdin
        [String[]] $readLineAry = ($input | Select-String @slsOpts).Line
    } else {
        Write-Error 'Input could not found.' -ErrorAction Stop
    }
    # set opts
    if ( $Descending ){
        $sortOpts = @{
            Descending = $True
        }
    } else {
        $sortOpts = @{
            Descending = $False
        }
    }
    if ( $CaseSensitive ){
        $sortOpts.Set_Item('CaseSensitive', $CaseSensitive)
    }
    if ( $Unique ){
        $sortOpts.Set_Item('Unique', $Unique)
    }
    if ( $Stable ){
        $sortOpts.Set_Item('Stable', $Stable)
    }
    if ( $Ordinal ){
        $sortOpts.Set_Item('Property', {-join ( [int[]] $_.ToCharArray()).ForEach('ToString', 'x4')} )
    }
    # init valriable
    [string] $joinRegex = $Delimiter
    Write-Debug "join regex = ""$joinRegex"""
    [string] $joinDelim = '@j@o@i@n@m@a@r@k@'
    [string] $joinedLine = ''
    [bool] $isFirstItem = $True
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
        | Sort-Object @sortOpts `
        | ForEach-Object {
            $_ -split $joinDelim
        }
}
# set alias
[String] $tmpAliasName = "blsort"
[String] $tmpCmdName   = "Sort-Block"
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
