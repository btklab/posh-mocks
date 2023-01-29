<#
.SYNOPSIS
    tex2pdf - Compile tex to pdf

        tex2pdf [tex_file]

.EXAMPLE
    tex2pdf a.tex

#>
function tex2pdf {
    Param(
        [Parameter(Mandatory=$True, Position=0)]
        [string] $file,

        [Parameter(Mandatory=$False)]
        [switch] $lualatex,

        [Parameter(Mandatory=$False)]
        [switch] $uplatex
    )
    # is command exist?
    function isCommandExist ([string]$cmd) {
        try { Get-Command $cmd -ErrorAction Stop | Out-Null
            return $True
        } catch {
            return $False
        }
    }
    if ($lualatex){
        if ( -not (isCommandExist "lualatex")){
            Write-Error 'could not find "lualatex"' -ErrorAction Stop
        }
    } else {
        if ( -not (isCommandExist "uplatex")){
            Write-Error 'could not find "uplatex"' -ErrorAction Stop
        }
    }
    # is .tex file exist?
        if( -not (Test-Path -LiteralPath "$file")){
            Write-Error "could not open $file" -ErrorAction Stop
        }
        [string] $fileFullPath = (Get-Item -LiteralPath "$file").FullName 
        [string] $fileBaseName = (Get-Item -LiteralPath "$file").BaseName
        [string] $fileName = Split-Path "$fileFullPath" -Leaf 
        if("$fileName" -notmatch '\.tex$'){
            Write-Error 'please set .tex file' -ErrorAction Stop
        }
    # compile
    if ($lualatex){
        lualatex "$fileBaseName.tex"
    } else {
        uplatex "$fileBaseName.tex"
        uplatex "$fileBaseName.tex"
        dvipdfmx -o "$fileBaseName.pdf" "$fileBaseName.dvi"
    }
    Invoke-Item "$fileBaseName.pdf"
}
