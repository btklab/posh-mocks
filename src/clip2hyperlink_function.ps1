<# 
.SYNOPSIS
    clip2hyperlink - Create hyperlink-formula for excel from clipped files.

    Usage:
        (copy files to the clipboard and ...)

        PS> clip2hyperlink
            =HYPERLINK("C:\path\to\the\file")
    
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

    Notes:
        # get files as objects from clipboard
        (copy files to the clipboard and ...)
        clip2hyperlink

        # read from file-path list (text)
        cat paths.txt | clip2hyperlink

        # read from file objects (this is probably useless)
        ls | clip2hyperlink

        # combination with clip2file function
        clip2file | clip2hyperlink

.LINK
    clip2file, clip2hyperlink, clip2push, clip2shortcut, clip2img, clip2txt, clip2normalize

.EXAMPLE
    # Basic usage
    (copy files to the clipboard and ...)

    PS> clip2hyperlink
        =HYPERLINK("C:\path\to\the\file")
 
    PS> clip2hyperlink -Mark "@"
        =HYPERLINK("C:\path\to\the\file","@")
 
    PS> clip2hyperlink -Mark "@" -EscapeSharp
        =HYPERLINK("file:///"&SUBSTITUTE("C:\path\to\the\file","#","%23"),"@")

.EXAMPLE
    # Collection of file reading patterns
    (copy files to the clipboard and ...)

    PS> clip2hyperlink
        =HYPERLINK("C:\path\to\the\file")

    PS> clip2hyperlink -Relative
        =HYPERLINK(".\file")

    PS> clip2hyperlink -Name
        =HYPERLINK("file")

    PS> clip2hyperlink -Name -Mark "@"
        =HYPERLINK("file","@")

    PS> clip2hyperlink -Name -Mark "@" -EscapeSharp
        =HYPERLINK("file:///"&SUBSTITUTE("file","#","%23"),"@")

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
        [string[]] $readLineAry = $input
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
        [string] $writeLine = $excelFormulaPrefix + """$f""" + $excelFormulaSuffix
        Write-Output $writeLine
        continue
    }
    return
}
