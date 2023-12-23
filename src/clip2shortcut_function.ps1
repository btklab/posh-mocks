<# 
.SYNOPSIS
    clip2shortcut - Create relative-path shortcuts from clipped files.

        ## Push-Location to the directory where you want to put shortcut
        PS > pushd 'where/you/want/to/put/shortcut'
         or
        (clip 'where/you/want/to/put/shortcut')
        PS > clip2shortcut -Execute

        ## Clip files what you want to create shortcuts
        ## (able to multiple copies)

        ## Create shortcuts
        PS > clip2shortcut -FromTo -Execute
            index.html.lnk    => ..\index.html
            index.ltjruby.lnk => ..\index.ltjruby
            index.pdf.lnk     => ..\index.pdf
        
        ## Pop-Location
        PS > popd

        ## Created shortcut property example
            Target Type: Application
            Target Location: %windir%
            Target: %windir%\explorer.exe "..\tmp\a.txt"

    Usage:
        clip2shortcut
            [-loc|-Location] ...Specify directory in which to
                create shortcuts. default: current directory.
            [-home|-ReplaceHome] ...Represent home directory with tilde
            [-f|-FullName] ...Create shortcuts with absolute paths
                instead of relative paths
            [-lv|-Level] ...Specify relative path depth. Join "..\"
                for the specified number
        
        # get files as objects from clipboard
        (copy files to the clipboard and ...)
        clip2shortcut

        # read from file-path list (text)
        cat paths.txt | clip2shortcut

        # read from file objects (this is probably useless)
        ls | clip2shortcut
        
        If the link destination and source have different drive
        letters, the shortcut is created with an absolute path
        instead of a relative path.

        Raise an error and abort processing if a nonexistent file
        is specified.

.LINK
    clip2file, clip2push, clip2shortcut, clip2img, clip2txt, clip2normalize

.NOTES
    How to create a shortcut to a folder with PowerShell and Intune
    https://learn.microsoft.com/en-us/answers/questions/1163030/how-to-create-a-shortcut-to-a-folder-with-powershe

        $shell = New-Object -comObject WScript.Shell
        $shortcut = $shell.CreateShortcut("[Target location of shortcut\shortcut name.lnk]")
        $shortcut.TargetPath = "C:\Windows\Explorer.exe"
        #$shortcut.TargetPath = "%windir%\explorer.exe"
        $shortcut.Arguments = """\\machine\share\folder"""
        $shortcut.Save()

.EXAMPLE
    ## Push-Location to the directory where you want to put shortcut
    PS > pushd 'where/you/want/to/put/shortcut'
        or
    (clip 'where/you/want/to/put/shortcut')
    PS > clip2push -Execute
    PS > clip2file | push2loc -Execute

    ## Clip files what you want to create shortcuts
    ## (able to multiple copies)

    ## Create shortcuts
    PS > clip2shortcut -FromTo
        index.html.lnk    => ..\index.html
        index.ltjruby.lnk => ..\index.ltjruby
        index.pdf.lnk     => ..\index.pdf
    
    ## Pop-Location
    PS > popd

    ## Created shortcut property example
        Target Type: Application
        Target Location: %windir%
        Target: %windir%\explorer.exe "..\index.html"

#>
function clip2shortcut {
    Param(
        [Parameter( Mandatory=$False, ValueFromPipeline=$True, Position=0 )]
        [string[]] $Files,
        
        [Parameter( Mandatory=$False )]
        [Alias("loc")]
        [string] $Location,
        
        [Parameter( Mandatory=$False )]
        [Alias("home")]
        [switch] $ReplaceHome,
        
        [Parameter( Mandatory=$False )]
        [Alias("f")]
        [switch] $FullName,
        
        [Parameter( Mandatory=$False )]
        [switch] $FromTo,
        
        [Parameter( Mandatory=$False )]
        [ValidateScript({ $_ -ge 0 })]
        [Alias("lv")]
        [int] $Level,
        
        [Parameter( Mandatory=$False )]
        [Alias("e")]
        [switch] $Execute
    )
    ## private function
    function CreateShortcutRelative {
        Param(
            [Parameter( Mandatory=$True, Position=0 )]
            [string] $ShortcutLocation,

            [Parameter( Mandatory=$True, Position=1 )]
            [string] $SourcePath,

            [Parameter( Mandatory=$False)]
            [string] $Command = '%windir%\explorer.exe'
        )
        $shell = New-Object -comObject WScript.Shell
        $shortcut = $shell.CreateShortcut("$ShortcutLocation")
        $shortcut.TargetPath = $Command
        [string] $sPath = $SourcePath.Replace('"', '')
        $shortcut.Arguments = """$sPath"""
        $shortcut.Save()
    }
    ## init filepath array
    [string[]] $readLineAry = @()
    if ( $input.Count -gt 0 ){
        ## get file path from pipeline text
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
            [string[]] $readLineAry = Get-Clipboard | ForEach-Object {
                if ($_ -ne '' ) { $_.Replace('"', '')}
                }
        }
    }
    if ( -not $readLineAry ){
        Write-Error "no input file." -ErrorAction Stop
        return
    }
    ## test path
    foreach ( $f in $readLineAry ){
        if ( -not ( Test-Path -LiteralPath "$f") ){
            Write-Warning "$f is not exists." -ErrorAction Stop
            throw
        }
    }
    ## get max char length of filename
    [int] $maxCharLength = $readLineAry `
        | ForEach-Object {
            [string] $fName = (Get-Item -LiteralPath "$_").Name + ".lnk"
            [System.Text.Encoding]::GetEncoding("Shift_Jis").GetByteCount($fName)
        } `
        | Sort-Object -Descending `
        | Select-Object -First 1

    ## output text with prefix
    foreach ( $f in $readLineAry ){
        [string] $sName = (Get-Item -LiteralPath $f).Name + ".lnk"
        if ( $Location) {
            [string] $sLoc = (Resolve-Path -LiteralPath $Location).Path
        } else {
            [string] $sLoc = (Resolve-Path -LiteralPath .).Path
        }
        [string] $sLoc = Join-Path "$sLoc" "$sName"
        [string] $sPath = (Get-Item -LiteralPath $f).FullName
        ## Apply options
        if ( $FullName ){
            ## do nothing
            [string] $sPath = $sPath
        } elseif ( $ReplaceHome ){
            [string] $sPath = $sPath.Replace($HOME, '.')
        } elseif ( $Level ){
            ## manual replace with relative path symbols
            ## up to the first dirctory separator "\"
            [string] $relMark = '..\' * $Level
            [string] $sPath = $sPath -replace '^\\\\'
            [string] $sPath = $sPath -replace '^[^\\]+\\'
            [string] $sPath = Join-Path $relMark $sPath
        } else {
            ## default: Relative
            [string] $sPath =  Resolve-Path -LiteralPath $f -Relative
        }
        Write-Debug $sPath
        if ( $Execute ){
            CreateShortcutRelative "$sLoc" "$sPath"
        }
        ### display item
        #Get-Item -LiteralPath "$sLoc"
        if ( $FromTo -or -not $Execute){
            ## display from path => to path
            [int] $curCharLength = [System.Text.Encoding]::GetEncoding("Shift_Jis").GetByteCount($sName)
            [int] $padding = $maxCharLength - $curCharLength
            Write-Host -NoNewline $sName -ForegroundColor "White"
            Write-Host -NoNewline "$(" {0}=> " -f ( " " * $padding ))"
            #Write-Host -NoNewline " => "
            Write-Host $sPath -ForegroundColor "Cyan"
        } else {
            ## output as file object
            Get-Item $sLoc
        }
    }
    return
}
