<# 
.SYNOPSIS
    clip2push - Push-Location and execute commands to clipped files

    Feature: Push-Location to the directory of the file
    copied from Explorer to the clipboard. It makes easier
    to execute commands on files that located deep in the
    directory and hard to move.

    Usage:
        # Push-Location to clipoed file's parent directory
        ("copy file to the clipboard and ...")
        clip2push [-a|-Action {script}] [-p|-Pop] [-e|-Execute] [-q|-Quiet]

    Option:
        -a|-Action {scriptblock}: the commands want to run
        -p|-Pop: Pop-Location after running Push-Location (and execute -Action script)
        -e|-Execute: execute push (and command specified with -Action)
    
    Note:
        - Does not run command unless "-Execute" switch is specified.
        - If error is caught during -Action script execution,
          execute Pop-Location before exit function.

.LINK
    clip2file, clip2push, clip2shortcut, clip2img, clip2txt, clip2normalize, push2loc

.NOTES
    Push-Location (Microsoft.PowerShell.Management)
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/push-location

    Split-Path (Microsoft.PowerShell.Management)
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/split-path

    about Try Catch Finally - PowerShell
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally

    about Script Blocks - PowerShell
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_script_blocks

.EXAMPLE
    # Push-Location to clipped file's parent directory (do not execute)
    
    ("copy file to the clipboard and ...")

    PS > clip2push
    Push-Location -LiteralPath "C:/path/to/the/git/repository/posh-mocks"

.EXAMPLE
    # Push-Location to clipped file's parent directory  (do not execute)
    # and Pop-Location (return to the first directory)  (do not execute)
    
    ("copy file to the clipboard and ...")
    
    PS > clip2push -Pop
    Push-Location -LiteralPath "C:/path/to/the/git/repository/posh-mocks"
    Pop-Location

.EXAMPLE
    # Combination with "clip2file" case to git status for each clipped git directory

    ("copy file to the clipboard and ...")

    in ~/cms/drafts
    PS > clip2push -Action { git status } -Pop
        Push-Location -LiteralPath "C:/path/to/the/git/repository/rlang-mocks"
        git status
        Pop-Location
        Push-Location -LiteralPath "C:/path/to/the/git/repository/posh-mocks"
        git status
        Pop-Location
        Push-Location -LiteralPath "C:/path/to/the/git/repository/py-mocks"
        git status
        Pop-Location


    # execute command (git status foreach git repository)
    in ~/cms/drafts
    PS > clip2push -Action { git status } -Pop -Execute
        in rlang-mocks
        On branch develop
        Your branch is up to date with 'origin/develop'.

        nothing to commit, working tree clean
        in posh-mocks
        On branch develop
        Your branch is up to date with 'origin/develop'.

        nothing to commit, working tree clean
        in py-mocks
        On branch develop
        Your branch is up to date with 'origin/develop'.

        nothing to commit, working tree clean

#>
function clip2push {
    Param(
        [Parameter( Mandatory=$False, ValueFromPipeline=$True, Position=0 )]
        [string[]] $Files,
        
        [Parameter( Mandatory=$False )]
        [Alias("a")]
        [scriptblock] $Action,
        
        [Parameter( Mandatory=$False )]
        [Alias("p")]
        [switch] $Pop,
        
        [Parameter( Mandatory=$False )]
        [Alias("q")]
        [switch] $Quiet,
        
        [Parameter( Mandatory=$False )]
        [Alias("e")]
        [switch] $Execute
    )
    ## init filepath array
    [string[]] $readLineAry = @()
    if ( $input.Count -gt 0 ){
        ## get file path from pipeline
        [string[]] $readLineAry = $input `
            | ForEach-Object {
                if ( ($_ -is [System.IO.FileInfo]) -or ($_ -is [System.IO.DirectoryInfo]) ){
                    ## from filesystem object
                    [string] $oText = $_.FullName
                } elseif ( $_ -is [System.IO.FileSystemInfo] ){
                    ## from filesystem object
                    [string] $oText = $_.FullName
                } else {
                    ## from text
                    [string] $oText = $_
                }
                Write-Output $oText
            }
        [string[]] $readLineAry = ForEach ($r in $readLineAry ){
            if ( $r -ne '' ){ $r.Replace('"', '') }
        }
    } else {
        ## get filepath from clipboard
        if ( $True ){
            ### get filepath as object
            Add-Type -AssemblyName System.Windows.Forms
            [string[]] $readLineAry = [Windows.Forms.Clipboard]::GetFileDropList()
        }
        if ( -not $readLineAry ){
            ### get filepath as text
            [string[]] $readLineAry = Get-Clipboard | `
                ForEach-Object { if ($_ -ne '' ) { $_.Replace('"', '')} }
        }
    }
    if ( -not $readLineAry ){
        Write-Error "no input file." -ErrorAction Stop
    }
    ## output text with prefix
    foreach ( $f in $readLineAry ){
        Write-Debug $f.GetType()
        [string] $fPath = (Get-Item -LiteralPath $f).FullName
        if ( -not (Test-Path -LiteralPath $fPath -PathType Any)) {
            Write-Error """$f"" is not exists." -ErrorAction Stop
        }
        if ( Test-Path $fPath -PathType Container ){
            ### directory
            [string] $pushDir = $fPath
        } else {
            ### file
            [string] $pushDir = Split-Path -Path $fPath -Parent
        }
        ### push location
        if ( -not $Execute ){
            Write-Output "Push-Location -LiteralPath ""$pushDir"""
            if ( $Action ){
                [string] $ActionStr = $Action.ToString().Trim()
                Write-Output $ActionStr
            }
            if ( $Pop ){
                Write-Output "Pop-Location"
            }
            continue
        }
        ### execute command
        if ($True) {
            if ( -not $Quiet ){
                [string] $dispName =  (Get-Item -LiteralPath $pushdir).Name
                Write-Host "in $dispName" -ForegroundColor Green
            }
            Push-Location -LiteralPath "$pushDir"
            if ( $Pop -And $Action ){
                try {
                    Invoke-Command -ScriptBlock $Action -ErrorAction Stop
                } catch {
                    #pass
                } finally {
                    Pop-Location                
                }
                continue
            }
            if ( $Action ){
                Invoke-Command -ScriptBlock $Action -ErrorAction Stop
                continue
            }
            if ( $Pop ){
                Pop-Location
                continue
            }
        }
    }
    return
}
