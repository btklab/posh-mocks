<# 
.SYNOPSIS
    clip2hyperlink - Create hyperlink-formula for excel from clipped files.

    Usage:
        (copy files to the clipboard and ...)

        PS> clip2hyperlink
            =HYPERLINK("C:\path\to\the\file")
    
        PS> clip2hyperlink -Leaf
            =HYPERLINK("C:\path\to\the\file","file")
    
        PS> clip2hyperlink -Parent
            =HYPERLINK("C:\path\to\the\file","the")
    
        PS> clip2hyperlink -Relative
            =HYPERLINK(".\file")
    
        PS> clip2hyperlink -Name
            =HYPERLINK("file")
    
        PS> clip2hyperlink -Name -Mark "@"
            =HYPERLINK("file","@")
    
        PS> clip2hyperlink -Name -Mark "@" -EscapeSharp
            =HYPERLINK("file:///"&SUBSTITUTE("file","#","%23"),"@")

    Options:
        [-r|-Relative]
        [-n|-Name]
        [-f|-FullName]
        [-m|-Mark] <String>
        [-d|-ReplaceDirectory <String>]
        [-l|-LinuxPath] (replace '\', '/')
        [-e|-EscapeSharp]
        [-Leaf]
        [-Parent]

.LINK
    clip2file, clip2hyperlink, clip2push, clip2shortcut, clip2img, clip2txt, clip2normalize

.EXAMPLE
    # Basic usage
    (copy files to the clipboard and ...)

    PS> clip2hyperlink
        =HYPERLINK("C:\path\to\the\file")

    PS> clip2hyperlink -Leaf
        =HYPERLINK("C:\path\to\the\file","file")

    PS> clip2hyperlink -Parent
        =HYPERLINK("C:\path\to\the\file","the")

    PS> clip2hyperlink -Relative
        =HYPERLINK(".\file")

    PS> clip2hyperlink -Name
        =HYPERLINK("file")

    PS> clip2hyperlink -Name -Mark "@"
        =HYPERLINK("file","@")

    PS> clip2hyperlink -Name -Mark "@" -EscapeSharp
        =HYPERLINK("file:///"&SUBSTITUTE("file","#","%23"),"@")

.EXAMPLE
    # Collection of file reading patterns
    (copy files to the clipboard and ...)

    # read from file-path list (text)
    PS> cat paths.txt | clip2hyperlink

    # read from file objects (this is probably useless)
    PS> ls | clip2hyperlink

    # combination with clip2file function
    PS> clip2file | clip2hyperlink

#>
function clip2hyperlink {
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
        [Alias("m")]
        [string] $Mark,
        
        [Parameter( Mandatory=$False )]
        [Alias("e")]
        [switch] $EscapeSharp,
        
        [Parameter( Mandatory=$False )]
        [switch] $Leaf,
        
        [Parameter( Mandatory=$False )]
        [switch] $Parent,
        
        [Parameter( Mandatory=$False )]
        [Alias("l")]
        [switch] $LinuxPath
    )
    ## set parts of excel formula
    if ( $EscapeSharp ){
        [string] $excelFormulaPrefix = '=HYPERLINK("file:///"&SUBSTITUTE('
        if ( $Mark ){
            [string] $excelFormulaSuffix = ',"#","%23"),"' + $Mark + '")'
        } else {
            [string] $excelFormulaSuffix = ',"#","%23"))'
        }
    } else {
        [string] $excelFormulaPrefix = '=HYPERLINK('
        if ( $Mark ){
            [string] $excelFormulaSuffix = ',"' + $Mark + '")'
        } else {
            [string] $excelFormulaSuffix = ')'
        }
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
    foreach ( $f in $sortedReadLineAry ){
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
        if ( $Leaf -and ( -not $Mark ) ){
            $lpath = Get-Item -LiteralPath $f | Split-Path -Leaf
            [string] $writeLine = $excelFormulaPrefix + """$f""" + ",""$lpath""" + $excelFormulaSuffix
        } elseif ( $Parent -and ( -not $Mark ) ){
            $lpath = Get-Item -LiteralPath $f | Split-Path -Parent | Split-Path -Leaf
            [string] $writeLine = $excelFormulaPrefix + """$f""" + ",""$lpath""" + $excelFormulaSuffix
        } else {
            [string] $writeLine = $excelFormulaPrefix + """$f""" + $excelFormulaSuffix
        }
        Write-Output $writeLine
        continue
    }
    return
}
