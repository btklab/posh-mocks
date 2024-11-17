<#
.SYNOPSIS
    PullOut-String (Alias: pullstr) - Pull out strings from a line

    Returns an array of two elements, the first element being
    the extracted strings, the second element being the remaining line.
    Left shortest match.

        Usage:
            $w, $l = $line | pullstr '<regex>'

        "gitcli -> gitignore" | pullstr "git"
            git
            cli -> gitignore

.LINK
    Extract-Substring, PullOut-String

.EXAMPLE
    # set line
    $line = "2024-10-23___cat1_cat2_cat3_hoge_fuga.txt"
    $line
        2024-10-23___cat1_cat2_cat3_hoge_fuga.txt
    
    # extract date
    $w, $l = $line | pullstr '[0-9]{4}\-[0-9]{2}\-[0-9]{2}'
    $w, $l
        2024-10-23
        ___cat1_cat2_cat3_hoge_fuga.txt
    
    # extract category
    $w, $l = $l | pullstr '___[^_]+_[^_]+_[^_]+' -d '^___'
    $w, $l
        cat1_cat2_cat3
        _hoge_fuga.txt

.EXAMPLE
    # set line
    $line = "https://powershell/module/about_split"

    # extract "module" strings
    $w, $l = $line | PullOut-String 'module'

    # output
    $line, $l, $w
        https://powershell/module/about_split
        https://powershell//about_split
        module

.NOTES
    about_Split - PowerShell
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_split?view=powershell-7.4
#>
function PullOut-String {

    [CmdletBinding()]
    [OutputType([String[]])]
    param (
        [Parameter( Mandatory=$True, Position=0 )]
        [Alias('s')]
        [String] $Split
        ,
        [Parameter( Mandatory=$False )]
        [Switch] $Literal
        ,
        [Parameter( Mandatory=$False )]
        [Alias('l')]
        [String[]] $Line
        ,
        [Parameter( Mandatory=$False )]
        [Alias('r')]
        [String[]] $Replace
        ,
        [Parameter( Mandatory=$False )]
        [Alias('rl')]
        [String[]] $ReplaceLine
        ,
        [Parameter( Mandatory=$False )]
        [Alias('d')]
        [String] $Delete
        ,
        [Parameter( Mandatory=$False )]
        [Alias('dl')]
        [String] $DeleteLine
        ,
        [Parameter( Mandatory=$False )]
        [Alias('o')]
        [Switch] $Object
        ,
        [Parameter( Mandatory=$False )]
        [Alias('c')]
        [Switch] $Casesensitive
        ,
        [Parameter( Mandatory=$False )]
        [Switch] $RightMostMatch
        ,
        [parameter( Mandatory=$False, ValueFromPipeline=$True )]
        [object[]] $InputText
    )
    if ( $Line.Count -gt 0 ){
        [String[]] $lines = $Line
    } else {
        [String[]] $lines = $input
    }
    foreach ( $readLine in $lines ){
        [String] $leftStr   = ''
        [String] $middleStr = ''
        [String] $rightStr  = ''
        if ( $readLine -eq '' ){
            # skip empty line
            Write-Output ''
            return
        }
        if ( $Split -eq '.' ){
            Write-Error "-Split '.' is not allowed." -ErrorAction Stop
        } elseif ( $Split -eq '^$'){
            [String] $reg = $Split
        } elseif ( $Split -match '^\^.+\$$' ){
            [String] $reg = '^(' + $($Split -replace '^.', '' -replace '.$', '') + ')$'
        } elseif ( $Split -match '^\^' ){
            [String] $reg = '^(' + $($Split -replace '^.', '') + ').*$'
        } elseif ( $Split -match '\$$' ){
            [String] $reg = '^.*?(' + $($Split -replace '.$', '') + ')$'
        } elseif ( $Split.Count -eq 1 ){
            if ( $RightMostMatch ){
                [String] $reg = '^.*(' + $Split + ').*?$'
            } else {
                [String] $reg = '^.*?(' + $Split + ').*$'
            }
        } else {
            if ( $RightMostMatch ){
                [String] $reg = '^.*(' + $Split + ').*?$'
            } else {
                [String] $reg = '^.*?(' + $Split + ').*$'
            }
        }
        Write-Debug "reg = $reg"

        if ( $Literal ){
            [String] $middleStr = $readLine.Replace($Split, '$1')
        } elseif ( $Casesensitive) {
            [String] $middleStr = $readLine -creplace $reg, '$1'
        } else {
            [String] $middleStr = $readLine -replace $reg, '$1'
        }
        if ( $middleStr -eq $readLine ){
            # not match case
            [String] $middleStr = ''
            [String] $leftStr   = $readLine
            [String] $rightStr  = '' 
            [Int] $splitCnt = 0
        } else {
            # left most split
            [String[]] $splitLine = @($readLine.Split($middleStr, 2))
            # get elements
            [Int] $splitCnt = $splitLine.Count
            [String] $leftStr  = $splitLine[0]
            [String] $rightStr = $splitLine[1..($splitLine.Count - 1)]
        }
        [String] $leftRightStr = $leftStr + $rightStr
        # replace strings
        if ( $Delete ){
            [String] $middleStr = $middleStr -replace $Delete, ''
        }
        if ( $Replace.Count -gt 0 ){
            if ( $Replace.Count -lt 2 ){
                $Replace += ''
            }
            [String] $middleStr = $midd -replace $Replace[0], $Replace[1]
        }
        # replace line
        if ( $DeleteLine ){
            [String] $leftRightStr = $leftRightStr -replace $DeleteLine, ''
        }
        if ( $ReplaceLine.Count -gt 0 ){
            if ( $ReplaceLine.Count -lt 2 ){
                $ReplaceLine += ''
            }
            [String] $leftRightStr = $leftRightStr -replace $ReplaceLine[0], $ReplaceLine[1]
        }
        #Write-Debug "$splitCnt, $($splitLine -join ' & ')"
        Write-Debug "split = $splitCnt"
        Write-Debug "left  = $leftStr"
        Write-Debug "get   = $middleStr"
        Write-Debug "right = $rightStr"
        # output
        if ( $Object ) {
            $hash = [ordered]@{}
            $hash["Get"]  = $middleStr
            $hash["Line"] = $leftRightStr
            [pscustomobject] $hash
        } else {
            [String[]] $writeArray = @($middleStr, $leftRightStr)
            Write-Output $writeArray
        }
    }
}
# set alias
[String] $tmpAliasName = "pullstr"
[String] $tmpCmdName   = "PullOut-String"
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

