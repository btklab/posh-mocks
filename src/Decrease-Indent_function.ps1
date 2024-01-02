<#
.SYNOPSIS
    Decrease-Indent (Alias: dind) - Decrease the total indent
    
    Decrease the total indent by one based on
    the indent of the first line. 

    When copying code, you no longer need to measure
    and remove unnecessary indentation.

    Input:
        Read from clipboard by default.
        Pipeline input also available.

.EXAMPLE
    # Code with extra indentation at the beginning of each lines
    PS > Get-Clipboard
        foreach ( $line in $inputLines ){
            $rowCounter++
            if ( $getIndent -eq $True ){
                # decrease indent for each line
                [String] $writeLine = $line -replace $reg, ''
                Write-Output $writeLine
                continue
            }
        }

    PS > # Decrease indent for each line
    PS > Decrease-Indent
    foreach ( $line in $inputLines ){
        $rowCounter++
        if ( $getIndent -eq $True ){
            # decrease indent for each line
            [String] $writeLine = $line -replace $reg, ''
            Write-Output $writeLine
            continue
        }
    }

#>
function Decrease-Indent {
    param (
        [Parameter( Mandatory=$False, ValueFromPipeline=$True)]
        [String[]] $InputObjects,
        
        [Parameter( Mandatory=$False )]
        [Int] $Skip = 0
    )
    if ( $input.Count -ne 0 ){
        [String[]] $inputLines = $input
    } else {
        [String[]] $inputLines = Get-ClipBoard
    }
    Write-Debug "$($input.Count)"
    if ( $inputLines.Count -eq 0 ){
        Write-Error "No input." -ErrorAction Stop
        return
    }
    [Int] $rowCounter = 0
    [Bool] $getIndent = $False
    [String] $decIndent = ''
    foreach ( $line in $inputLines ){
        $rowCounter++
        Write-Debug "line: $line"
        if ( ($rowCounter -eq ($Skip + 1)) -and ($getIndent -eq $False) ){
            # get indent
            if ( $line -match '^(\s+).*$'){
                [String] $decIndent = $line -replace '^(\s+).*$', '$1'
                [String] $reg = '^' + $decIndent
                [String] $writeLine = $line -replace $reg, ''
                Write-Output $writeLine
                $getIndent = $True
            } else {
                [String] $reg = ''
                [String] $writeLine = $line
                Write-Output $writeLine
                $getIndent = $True
            }
            continue
        }
        if ( $getIndent -eq $True ){
            # decrease indent for each line
            if ( $reg -ne '' ){
                [String] $writeLine = $line -replace $reg, ''
            } else {
                [String] $writeLine = $line
            }
            Write-Output $writeLine
            continue
        }
        # do nothing
        [String] $writeLine = $line
        Write-Output $writeLine
        continue
    }
    Write-Debug """regex: $reg"""
    Write-Debug """$decIndent"""
}
# set alias
[String] $tmpAliasName = "dind"
[String] $tmpCmdName   = "Decrease-Indent"
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
