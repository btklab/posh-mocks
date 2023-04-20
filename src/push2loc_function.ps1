<#
.SYNOPSIS
    push2loc - Push-Location and execute commands to clipped files

    Feature: Push-Location to the directory of the file
    copied from Explorer to the clipboard. It makes easier
    to execute commands on files that located deep in the
    directory and hard to move.

    Usage:
        ("copy file to the clipboard and ...")
        clip2file | push2loc [-a|-Action {script}] [-p|-Pop] [-e|-Execute] [-q|-Quiet]

    Option:
        "-a|-Action" {scriptblock}: the commands want to run
        "-p|-Pop": Pop-Location after running Push-Location (and execute -Action script)
        "-e|-Execute": execute push (and command specified with -Action)
    
    Note:
        - Does not run command unless "-Execute" switch is specified.
        - If error is caught during -Action script execution,
          execute Pop-Location before exit function.

.LINK
    clip2file, clip2img, clip2txt, clip2push, push2loc

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
    ("copy file to the clipboard and ...") (do not run)
    clip2file | push2loc -Action { cat a.md } -Pop
        Push-Location -LiteralPath "C:/path/to/the/location"
        cat a.md
        Pop-Location

    ## execute command by using "-e|-Execute" switch
    clip2file | push2loc -Action { cat a.md } -Pop -Execute

.EXAMPLE
    # Combination with "clip2file" case to only pushd to clipped file location

    ("copy file to the clipboard on explorer and ...")

    in ~/cms/drafts
    PS > clip2file

            Directory: C:/path/to/the/location

        Mode                 LastWriteTime         Length Name
        ----                 -------------         ------ ----
        -a---          2023/02/17    23:45           8079 index.qmd


    in ~/cms/drafts
    PS > clip2file | push2loc
        Push-Location -LiteralPath "C:/path/to/the/location"

    in ~/cms/drafts
    PS > clip2file | push2loc -Execute

    in C:/path/to/the/location
    PS > # pushd to clipped file location

.EXAMPLE
    # Combination with "clip2file" case to pushd and execute command and popd

    ("copy file to the clipboard and ...")

    in ~/cms/drafts
    PS > clip2file
    
            Directory: C:/path/to/the/location
    
        Mode                 LastWriteTime         Length Name
        ----                 -------------         ------ ----
        -a---          2023/02/17    23:45           8079 index.qmd


    PS >  clip2file | push2loc
        Push-Location -LiteralPath "C:/path/to/the/location"

    PS > clip2file | push2loc -Action { quarto render index.qmd --to html } -Pop
        Push-Location -LiteralPath "C:/path/to/the/location"
        quarto render index.qmd --to html
        Pop-Location

    PS >  clip2file | push2loc -Action { quarto render index.qmd --to html } -Pop  -Execute
        ("execute quarto command and popd")

.EXAMPLE
    # Combination with "clip2file" case to git status for each clipped git directory

    ("copy file to the clipboard and ...")

    in ~/cms/drafts
    PS > clip2file

            Directory: C:/path/to/the/git/repository

        Mode                 LastWriteTime         Length Name
        ----                 -------------         ------ ----
        d-r--          2023/03/21    14:06                rlang-mocks
        d-r--          2023/03/21    14:06                posh-mocks
        d-r--          2023/03/21    14:06                py-mocks


    in ~/cms/drafts
    PS > clip2file | push2loc -Action { git status } -Pop
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
    PS > clip2file | push2loc -Action { git status } -Pop -Execute
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
function push2loc {
    param (
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
    ## test input
    if ( $input.Count -lt 1 ){
        Write-Error "file-objects not found from stdin." -ErrorAction Stop
        return
    }
    [object[]] $fObj = $input
    ## replace / remove symbols
    foreach ( $f in $fObj ){
        Write-Debug $f.GetType()
        [string] $fPath = $f.FullName
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
        if ( $True ) {
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
