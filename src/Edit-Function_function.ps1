<#
.SYNOPSIS
    Edit-Function (Alias: e) - Edit my powershell scripts.

    Edit-Function
        [[-f|-Function] <String>] ...function name or alias name
        [[-e|-Editor] <String>] ...specify editor
        [-o|-AsObject] ...output only object
        [-q|-DryRun] ...what-if

    If an existing file is specified, open it in the editor

.EXAMPLE
    # Edit man2 function with default text editor
    Edit-Function -Function man2
    # or
    Edit-Function -f man2
    # or
    Edit-Function man2
    # or
    e man2

    Directory: path/to/the/posh-mocks/src

    Mode          LastWriteTime    Length Name
    ----          -------------    ------ ----
    -a---   2023/11/25     8:44     12133 man2_function.ps1

.EXAMPLE
    # Edit man2 function with specified text editor
    Edit-Function -Function man2 -Editor notepad
    # or
    Edit-Function -f man2 -e notepad
    # or
    Edit-Function man2 notepad
    # or
    e man2 notepad

.EXAMPLE
    # Output only Object (do not run editor)
    e i -o

    Directory: path/to/the/posh-mocks/src

    Mode        LastWriteTime Length Name
    ----        ------------- ------ ----
    -a--- 2023/10/27    12:00  13459 Invoke-Link_function.ps1

.EXAMPLE
    # If there are no arguments, return the function list
    e Add-*

    Matched multiple files. Please specify a single file.
    ------

    Add-Duration           Add-LineBreakEndOfFile
    Add-LineBreak          Add-Quartile
    Add-Record             Add-Stats

.EXAMPLE
    # open text with editor If an existing file is specified
    e ../bin/posh-mocks/operator.ps1

.NOTES
    Author: btklab

#>
function Edit-Function {

    [CmdletBinding()]
    param (
        [Parameter( Mandatory=$False, Position=0 )]
        [Alias('f')]
        [String] $Function,
        
        [Parameter( Mandatory=$False, Position=1 )]
        [Alias('e')]
        [String] $Editor,
        
        [Parameter( Mandatory=$False )]
        [Alias('o')]
        [Switch] $AsObject,
        
        [Parameter( Mandatory=$False )]
        [Alias('q')]
        [Switch] $DryRun
    )
    # private function
    ## is command exist?
    function isCommandExist ( [String]$cmd ) {
        try { Get-Command -Name $cmd -ErrorAction Stop > $Null
            return $True
        } catch {
            return $False
        }
    }
    # get script dir
    [string] $pwshDir = $PSScriptRoot
    [string] $pwshDir = (Resolve-Path -Path $pwshDir).Path
    Write-Debug "$pwshDir"
    # if no option, list pwsh scripts
    if ( -not $Function ){
        #Get-Item -LiteralPath $pwshDir
        #Invoke-Item -Path $pwshDir
        [String] $srcFilePath = Join-Path -Path $pwshDir -ChildPath "*_function.ps1"
        Get-ChildItem -Path $srcFilePath -File `
            | Sort-Object {
                -join ( [int[]] $_.Name.ToCharArray()).ForEach('ToString', 'x4')
            } `
            | select @{L="Name";E={$_.Name.Replace('_function.ps1','')}} `
            | Format-Wide -AutoSize
        return
    }
    # If an existing file is specified, open it in the editor
    if ( Test-Path -LiteralPath $Function ){
        if ( $Editor ){
            [string] $comStr = $Editor
            [string] $comStr = "$comStr ""$Function"""
            if ( $DryRun ){
                Write-Host "Invoke-Expression -Command $comStr -ErrorAction Stop" -ForegroundColor Yellow
            } else {
                Get-Item -LiteralPath $Function
                if ( -not $AsObject ){
                    Invoke-Expression -Command $comStr -ErrorAction Stop
                }
            }
        } else {
            if ( $DryRun ){
                Write-Host "Invoke-Item -Path $Function" -ForegroundColor Yellow
            } else {
                Get-Item -LiteralPath $Function
                if ( -not $AsObject ){
                    Invoke-Item -Path $Function
                }
            }
        }
        return
    }
    # main
    if ( -not (isCommandExist $Function) ){
        Write-Error """$Function"" function is not exists." -ErrorAction Stop
        return
    }
    [object[]] $cmdAry = Get-Command -Name $Function
    if ( $cmdAry.Count -gt 1 ){
        Write-Host ""
        Write-Host "Matched multiple files. Please specify a single file." -ForegroundColor Yellow
        Write-Host "------" -ForegroundColor Yellow
        # list function
        [String] $srcFilePath = Join-Path -Path $pwshDir -ChildPath "${Function}_function.ps1"
        Get-ChildItem -Path $srcFilePath -File `
            | Sort-Object {
                -join ( [int[]] $_.Name.ToCharArray()).ForEach('ToString', 'x4')
            } `
            | select @{L="Name";E={$_.Name.Replace('_function.ps1','')}} `
            | Format-Wide -AutoSize
    } else {
        if ( $cmdAry[0].CommandType -eq 'Alias' ){
            # resolve alias
            [String] $cmdName = $cmdAry[0].ReferencedCommand.Name
        } else {
            # get commmand name
            [String] $cmdName = $cmdAry[0].Name
        }
        # make file path
        [String] $funcFileName = $cmdName + '_function.ps1'
        [String] $funcFilePath = Join-Path -Path $pwshDir -ChildPath $funcFileName
        Write-Debug "funcpath: $funcFilePath"
        if ( -not (Test-Path -LiteralPath $funcFilePath) ){
            Write-Error "Could not found $funcFilePath" -ErrorAction Stop
        }
        if ( $Editor ){
            [string] $comStr = $Editor
            [string] $comStr = "$comStr ""$funcFilePath"""
            if ( $DryRun ){
                Write-Host "Invoke-Expression -Command $comStr -ErrorAction Stop" -ForegroundColor Yellow
            } else {
                Get-Item -LiteralPath $funcFilePath
                if ( -not $AsObject ){
                    Invoke-Expression -Command $comStr -ErrorAction Stop
                }
            }
        } else {
            if ( $DryRun ){
                Write-Host "Invoke-Item -Path $funcFilePath" -ForegroundColor Yellow
            } else {
                Get-Item -LiteralPath $funcFilePath
                if ( -not $AsObject ){
                    Invoke-Item -Path $funcFilePath
                }
            }
        }
        return
    }
}
# set alias
[String] $tmpAliasName = "e"
[String] $tmpCmdName   = "Edit-Function"
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

