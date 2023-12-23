<# 
.SYNOPSIS
    clip2normalize - Text normalizer for japanese on windows

    Make half-width kana and full-width alphanumeric mixed text
    as clean as possible.

    Usage:
        clip2normalize
            [-max|-MaxLineBreaks <Int32>]
            [-a|-JoinAll]
            [-j|-Join <String>]
            [-t|-Trim]    

        # get text from clipboard
        (copy text to the clipboard and ...)
        clip2normalize

        # read from pipeline (text-object)
        cat a.txt | clip2normalize

    Default replacement rules:
        leading full-width bullet to hyphen + space
        leading number + (dot) + spaces to number + dot + space
        trim trailing white-spaces

    Optional replacement rules:
        [-max|-MaxLineBreaks <int>]
            ...Maximum number of consecutive blank lines (default=1)
        [a|-JoinAll] ...Join all line into one line
        [-j|-Join <string>] ...Join line with any string
        [-t|-Trim] ...Trim leading and trailing white-spaces

    Dependencies:
        han, zen
        
.LINK
    clip2file, clip2push, clip2shortcut, clip2img, clip2txt, clip2normalize

.EXAMPLE
    cat a.txt
        ■　ｽﾏﾎ等から確認する場合
        １　あいうえお
        ２　かきくけこ
        ３　ａｂｃｄｅ

    ("copy text to clipboard and...")
    clip2normalize
        ■ スマホ等から確認する場合
        1. あいうえお
        2. かきくけこ
        3. abcde

#>
function clip2normalize {
    Param(        
        [Parameter( Mandatory=$False )]
        [Alias("max")]
        [int] $MaxLineBreaks = 1,
        
        [Parameter( Mandatory=$False )]
        [Alias("t")]
        [switch] $Trim,
        
        [Parameter( Mandatory=$False )]
        [Alias("a")]
        [switch] $JoinAll,
        
        [Parameter( Mandatory=$False )]
        [Alias("j")]
        [string] $Join,
        
        [Parameter( Mandatory=$False, ValueFromPipeline=$True, Position=0 )]
        [string[]] $Text
    )
    ## is command exist?
    function isCommandExist ([string]$cmd) {
        try { Get-Command $cmd -ErrorAction Stop > $Null
            return $True
        } catch {
            return $False
        }
    }
    if ( -not (isCommandExist "han" ) ){
        Write-Error "could not found ""han"" command." -ErrorAction Stop
    }
    if ( -not (isCommandExist "zen" ) ){
        Write-Error "could not found ""zen"" command." -ErrorAction Stop
    }
    ## private function
    function replaceSymbols ( [string] $line ) {
        [string] $tmpLine = $line
        ### remove trailing whitespaces
        [string] $tmpLine = $tmpLine -replace '\s*$', ''
        ### replace leading full-width bullet to hyphen + space
        [string] $tmpLine = $tmpLine -replace '^(\s*)・','$1- '
        ### replace half-width kana to full-width kana
        [string] $tmpLine = $tmpLine | han | zen -k
        ### replace leading number + (dot) + spaces to numper + dot + space
        [string] $tmpLine = $tmpLine -replace '^(\s*)([0-9]+)(\.)* +', '$1$2. '
        ### trim spaces
        if ( $Trim ){ [string] $tmpLine = $tmpLine.Trim() }
        return $tmpLine
    }
    ## init filepath array
    [string[]] $readLineAry = @()
    if ( $input.Count -gt 0 ){
        ### get text from pipeline
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
    } else {
        ### get text from clipboard
        [string[]] $readLineAry = Get-Clipboard
    }
    if ( -not $readLineAry ){
        Write-Error "no input file." -ErrorAction Stop
    }
    ## output text with prefix
    [int] $lineBreaks = 0
    [string[]] $outLineAry = foreach ( $line in $readLineAry ){
            if ( $line -match '^\s*$' ){
                ### parse empty line
                $lineBreaks++
                if ( $lineBreaks -le $MaxLineBreaks ){
                    ### output empty line
                    Write-Output ''
                }
                continue
            } else {
                ### output line
                #### init linebreak counter
                [int] $lineBreaks = 0
                #### replace symbols
                [string] $writeLine = replaceSymbols $line
                Write-Output $writeLine
                continue
            }
        }
    ## output
    if ( $JoinAll ){
        $outLineAry -Join ""
    } elseif ( $Join ){
        $outLineAry -Join "$Join"
    } else {
        $outLineAry | ForEach-Object { 
            Write-Output "$_"
        }
    }
    return
}
