<#
.SYNOPSIS
    Edit-Function (Alias: edit) - Edit my powershell scripts.

    Edit-Function
        [[-f|-Function] <String>] ...function name or alias
        [[-e|-Editor] <String>] ...specify editor
        [-o|-AsObject] ...output only object
        [-q|-DryRun] ...what-if

.EXAMPLE
    # Edit man2 function with default text editor
    Edit-Function -Function man2
    # or
    Edit-Function -f man2
    # or
    Edit-Function man2
    # or
    edit man2

    Directory: path/to/the/posh-mocks/src

    Mode                 LastWriteTime         Length Name
    ----                 -------------         ------ ----
    -a---          2023/11/25     8:44          12133 man2_function.ps1

.EXAMPLE
    # Edit man2 function with specified text editor
    Edit-Function -Function man2 -Editor notepad
    # or
    Edit-Function -f man2 -e notepad
    # or
    Edit-Function man2 notepad
    # or
    edit man2 notepad

.EXAMPLE
    # Output only Object (do not run editor)
    edit i -o

    Directory: path/to/the/posh-mocks/src

    Mode        LastWriteTime Length Name
    ----        ------------- ------ ----
    -a--- 2023/10/27    12:00  13459 Invoke-Link_function.ps1

.EXAMPLE
    # If there are no arguments, return the function directory
    edit

    Directory: path/to/the/posh-mocks

    Mode                 LastWriteTime         Length Name
    ----                 -------------         ------ ----
    d-r--          2023/11/25     8:17                src

.EXAMPLE
    # open function directory with explorer
    edit | ii

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
    # Open directory when nothing specified
    if ( -not $Function ){
        Get-Item -LiteralPath $pwshDir
        #Invoke-Item -Path $pwshDir
        return
    }
    if ( -not (isCommandExist $Function) ){
        Write-Error """$Function"" function is not exists." -ErrorAction Stop
        return
    }
    [object[]] $cmdAry = Get-Command -Name $Function
    if ( $cmdAry.Count -ne 1 ){
        Write-Host "Matched multiple files. Please specify a single file." -ForegroundColor Yellow
        Write-Host "------" -ForegroundColor Yellow
        # get full name
        foreach ($cmd in $cmdAry ){
            if ( $cmd.CommandType -eq 'Alias' ){
                # resolve alias
                Write-Host "* $($cmd.ReferencedCommand.Name)" -ForegroundColor Yellow
            } else {
                # get commmand name
                Write-Host "* $($cmd.Name)" -ForegroundColor Yellow
            }
        }
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
Set-Alias -Name "edit" -Value "Edit-Function" -PassThru | Select-Object "DisplayName"
