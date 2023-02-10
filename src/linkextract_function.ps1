<#
.SYNOPSIS
    linkextract - Extract links from html
    
    If the link starts with "http" or "www", it is interpreted as uri,
    otherwise interpreted as local html file.
    
    Operation:
        For uri:
            (Invoke-WebRequest $uri).Links.href
    
        For file:
            $reg = [Regex]'href="(http|www\.)[^"]+"'
            $reg.Matches( $_ ) | ForEach-Object { $_.Value }
    
    -AddUri : Outputs specified uri in the 1st column, the external uri in the 2nd column
    -ExcludeUris <reg>,<reg>,... : allows to specify links to exclude
    -Recurse is not implemented.
    
    By piping to the "linkcheck" command, you can check link-alive.
        ls docs/*.html | linkextract | linkcheck -VerboseOutput
        ls docs/*.html | linkextract -AddUri | linkcheck -Header -VerboseOutput
    
    If you specify a directory, search for the "index.html" under it.
        ls index.html -Recurse | Split-Path -Parent | linkextract -AddUri
        ./docs/posts/haccp_7_principles https://pandoc.org/

.LINK
    linkcheck

.PARAMETER Html
    Specify uri or html-file you want to get href.

.PARAMETER AddUri
    Outputs specified uri in the 1st column,
    the external uri in the 2nd column.

.PARAMETER ExcludeUris
    Specify links to exclude separated by commas.

.EXAMPLE
    linkextract index.html
    https://www.google.com/
    https://translate.google.co.jp/?hl=ja
    https://www.deepl.com/translator
    www.microsoft.com/unknownhost

.EXAMPLE
    linkextract index.html -AddUri
    index.html https://www.google.com/
    index.html https://translate.google.co.jp/?hl=ja
    index.html https://www.deepl.com/translator
    index.html www.microsoft.com/unknownhost

.EXAMPLE
    linkextract ./docs/*.html
    https://www.google.com/
    https://translate.google.co.jp/?hl=ja
    https://www.deepl.com/translator
    www.microsoft.com/unknownhost

.EXAMPLE
    ls docs/*.html | linkextract | linkcheck
    No broken links.

.EXAMPLE
    ls docs/index.html | linkextract
    https://www.google.com/
    https://translate.google.co.jp/?hl=ja
    https://www.deepl.com/translator
    www.microsoft.com/unknownhost

.EXAMPLE
    ls docs/*.html | linkextract -AddUri
    ./docs/index.html https://www.google.com/
    ./docs/index.html https://translate.google.co.jp/?hl=ja
    ./docs/index.html https://www.deepl.com/translator
    ./docs/index.html https://pandoc.org/

.EXAMPLE
    ls docs/*.html | linkextract -AddUri | linkcheck -Header -VerboseOutput
    [ok] ./docs/index.html https://www.google.com/
    [ok] ./docs/index.html https://translate.google.co.jp/?hl=ja
    [ok] ./docs/index.html https://www.deepl.com/translator
    [ok] ./docs/index.html https://pandoc.org/


.EXAMPLE
    linkcheck (linkextract index.html) -VerboseOutput
    [ok] https://www.google.com/
    [ok] https://translate.google.co.jp/?hl=ja
    [ok] https://www.deepl.com/translator
    [ok] https://pandoc.org/
    No broken links.

.EXAMPLE
    linkcheck (linkextract a.html | sed 's;tra;hoge;') -VerboseOutput
    [ok] https://www.google.com/
    [ng] https://hogenslate.google.co.jp/?hl=ja
    [ng] https://www.deepl.com/hogenslator
    [ok] https://pandoc.org/
    Detect broken links.
    [ng] https://hogenslate.google.co.jp/?hl=ja
    [ng] https://www.deepl.com/hogenslator

#>
function linkextract {
    Param(
        [parameter(
            Mandatory=$True,
            Position=0,
            ValueFromPipeline=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]] $Html,

        [parameter(Mandatory=$False)]
        [regex[]] $ExcludeUris = 'z{99}',

        [parameter(Mandatory=$False)]
        [switch] $DelIndexHtml,

        [parameter(Mandatory=$False)]
        [switch] $AddUri
    )
    # private functions
    function AddUriHeader ([string]$aStr, [string]$aUri){
        if ($AddUri){
            if ($DelIndexHtml){
                $aStr = $aStr -replace '(/|\\)index.html$', ''
            }
            [string]$o = ("$aStr $aUri").Trim()
        } else {
            [string]$o = $aUri
        }
        return $o
    }
    function GetHrefsFromFiles ([string]$htmlFile, [regex]$exReg) {
        [string[]]$retAry = @()
        $relHtmlFile = (Resolve-Path -Path $htmlFile -Relative).Replace('\','/')
        if((Get-Item $relHtmlFile).PSIsContainer){
            # if directory, add index.html end of path
            $htmlFile = Join-Path $relHtmlFile "index.html"
        }
        Get-Content $htmlFile -Encoding UTF8 | ForEach-Object {
            # extract "href" element
            $reg = [Regex]'href="(http|www\.)[^"]+"'
            $reg.Matches($_) | ForEach-Object {
                # extract contents in double quote
                $splitLine = $_.Value -Split '"'
                [string]$targetUri = $splitLine[1]
                if ($targetUri -notmatch $exReg){
                    $targetUri = AddUriHeader $relHtmlFile $targetUri
                    $retAry += ,"$targetUri"
                }
            }
        }
        return $retAry
    }
    function GetHrefsFromUris ([string]$uri, [regex]$exReg){
        if($uri -notmatch $exReg){
            [string[]]$retAry = @()
            (Invoke-WebRequest $uri).Links.href | ForEach-Object {
                $targetUri = AddUriHeader $uri $_
                $retAry += ,"$targetUri"
            }
        }
        return $retAry
    }
    # set uri
    if($input){
        [string[]]$src = $input
    } else {
        [string[]]$src = $Html
    }
    # set exclue regex
    [regex]$exReg = $ExcludeUris -Join '|'
    #write-host $exreg
    # main
    foreach ($uri in $src) {
        if ($uri -match '^http|^www\.'){
            # case: uri
            GetHrefsFromUris "$uri" $exReg
        } elseif ($uri -match '^file:///'){
            $f = $uri -replace '^file:///',''
            GetHrefsFromFiles "$f" $exReg
        } else {
            # case: html file
            GetHrefsFromFiles "$uri" $exReg
        }
    }
}
