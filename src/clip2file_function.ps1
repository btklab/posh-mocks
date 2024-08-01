<# 
.SYNOPSIS
    clip2file - Get files copied to the clipboard as an objects

    Converts the clipped files to an object, making it easier to
    link with file operation cmdlets via a pipeline.
    Such as Copy-Item, Move-Item, Rename-Item, etc...

    As a feature, you can operate files in other directories while
    staying in the current directory by copying files to the clipboard.

    If "-UrlDecode" switch is specified or the path starts with "file:///",
    the path will be Urldecoded before begin retrieved.

    Usage:
        clip2file
            [-r|-Relative]
            [-n|-Name]
            [-f|-FullName]
            [-d|-ReplaceDirectory <String>]
            [-t|-AsText]
            [-l|-LinuxPath] (replace '\', '/')
            [-u|-UrlDecode]

        # get files as objects from clipboard
        (copy files to the clipboard and ...)
        clip2file

        # read from file-path list (text)
        cat paths.txt | clip2file

        # read from file objects (this is probably useless)
        ls | clip2file

        # in each case the result is follows:

            Mode         LastWriteTime  Length Name
            ----         -------------  ------ ----
            -a---  2023/01/22    15:32    2198 clipwatch_function.ps1
            -a---  2023/04/03     0:25    2604 clip2file_function.ps1
            -a---  2023/04/02    23:09    4990 clip2img_function.ps1
            -a---  2023/04/03     0:11    2114 clip2txt_function.ps1
        
        # combination with Move-Item / Copy-Item / Rename-Item
        PS > clip2file | mv -Destination ./hoge/ [-Force]
        PS > clip2file | cp -Destination ./hoge/
        PS > clip2file | Rename-Item -NewName { $_.Name -replace '^', (Get-Date).ToString('yyyy-MM-dd-') } -WhatIf

.LINK
    clip2file, clip2push, clip2shortcut, clip2img, clip2txt, clip2normalize

.EXAMPLE
    clip2file

    Mode         LastWriteTime  Length Name
    ----         -------------  ------ ----
    -a---  2023/01/22    15:32    2198 clipwatch_function.ps1
    -a---  2023/04/03     0:25    2604 clip2file_function.ps1
    -a---  2023/04/02    23:09    4990 clip2img_function.ps1
    -a---  2023/04/03     0:11    2114 clip2txt_function.ps1

    # move/copy/rename clipped files
    PS > clip2file | Move-Item -Destination ~/hoge/ [-Force]
    PS > clip2file | Copy-Item -Destination ~/hoge/
    PS > clip2file | Rename-Item -NewName { $_.Name -replace '^', (Get-Date).ToString('yyyy-MM-dd-') } -WhatIf

.EXAMPLE
    clip2file -Name
    PS > clip2file -Name | Set-Clipboard

        clip2txt_function.ps1
        clipwatch_function.ps1
        clip2file_function.ps1
        clip2img_function.ps1

    PS > clip2file -Name -ReplaceDirectory "/img/2023/" -l

        /img/2023/clip2txt_function.ps1
        /img/2023/clipwatch_function.ps1
        /img/2023/clip2file_function.ps1
        /img/2023/clip2img_function.ps1

#>
function clip2file {
    Param(
        [Parameter( Mandatory=$False, ValueFromPipeline=$True, Position=0 )]
        [string[]] $Files,
        
        [Parameter( Mandatory=$False )]
        [Alias("r")]
        [switch] $Relative,
        
        [Parameter( Mandatory=$False )]
        [Alias("n")]
        [switch] $Name,
        
        [Parameter( Mandatory=$False )]
        [Alias("f")]
        [switch] $FullName,
        
        [Parameter( Mandatory=$False )]
        [Alias("d")]
        [string] $ReplaceDirectory,
        
        [Parameter( Mandatory=$False )]
        [Alias("t")]
        [switch] $AsText,
        
        [Parameter( Mandatory=$False )]
        [Alias("u")]
        [switch] $UrlDecode,
        
        [Parameter( Mandatory=$False )]
        [Alias("l")]
        [switch] $LinuxPath
    )
    ## parse option
    [bool] $outputTextFlag = $False
    if ( $AsText    ){ $outputTextFlag = $True }
    if ( $Name      ){ $outputTextFlag = $True }
    if ( $FullName  ){ $outputTextFlag = $True }
    if ( $Relative  ){ $outputTextFlag = $True }
    if ( $LinuxPath ){ $outputTextFlag = $True }
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
    } elseif ( $Files.Count -gt 0 ){
        ## get filepath from option
        [string[]] $readLineAry = $Files | `
            ForEach-Object { (Get-Item -LiteralPath $_).FullName }
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
    ## test
    if ( -not $readLineAry ){
        Write-Error "no input file." -ErrorAction Stop
    }
    ## sort file paths
    [string[]] $sortedReadLineAry = $readLineAry | Sort-Object
    ## output text with prefix
    [object[]] $obj = foreach ( $f in $sortedReadLineAry ){
        if ( ( $f -match '^file:///' ) -or ( $UrlDecode ) ){
            [string] $f = [uri]::UnEscapeDataString( $($f -replace '^file:///', '') )
        }
        if ( $outputTextFlag ){
            if ( $Relative ){
                [string] $f = Resolve-Path -LiteralPath $f -Relative
            }
            if ( $FullName ){
                [string] $f = (Get-Item -LiteralPath $f).FullName
            }
            if ( $Name -or $ReplaceDirectory ){
                [string] $f = (Get-Item -LiteralPath $f).Name
                if ( $ReplaceDirectory ){ [string] $f = Join-Path $ReplaceDirectory $f }
            }
            if ( $LinuxPath ){ [string] $f = "$f".Replace('\', '/') }
            [string] $writeLine = $f
            Write-Output $writeLine
            continue
        }
        Get-Item -LiteralPath $f
    }
    if ( $True ){
        $obj
    }
    return
}
