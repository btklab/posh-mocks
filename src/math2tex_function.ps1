<#
.SYNOPSIS
    math2tex - Add LaTeX preables to the mathematical and chemical formula in LaTex format.

    Add LaTeX preables to the mathematical and chemical formula in LaTex format.
    By using this function with the "tinytex" (Execute-TinyTex) command,
    you can generate a PDF file containing only mathematical or chemical
    formula.

.PARAMETER ja
    Specify this when the formula contains
    Japanese characters.

.PARAMETER DocumentClass
    Specify the document class. "standalone"
    cannot be specified if Japanese is included.

.EXAMPLE
    echo '\ce{2H + O2 -> H2O}' | math2tex > a.tex; tinytex a.tex | ii
        \documentclass[varwidth,crop,border=1pt]{standalone}
        \usepackage{amsmath}
        \usepackage{amssymb}
        \usepackage{amsfonts}
        \usepackage[version=4]{mhchem}
        \begin{document}
          $\ce{2H + O2 -> H2O}$
        \end{document}

.LINK
    Execute-TinyTex (Alias: tinytex), math2tex, pdf2svg

.NOTES
    Easy Copy Mathjax
        https://easy-copy-mathjax.nakaken88.com/en/

#>
function math2tex {

    [CmdletBinding()]
    param (
        [Parameter( Mandatory=$False, Position=0 )]
        [String[]] $Formula,
        
        [Parameter( Mandatory=$False )]
        [Alias('f')]
        [String] $File,
        
        [Parameter( Mandatory=$False )]
        [Alias('d')]
        [ValidateSet("standalone", "report", "article", "minimal", "book", "slides", "letter", "beamer")]
        [String] $DocumentClass = "standalone",
        
        [Parameter( Mandatory=$False )]
        [Switch] $NoChem,
        
        [Parameter( Mandatory=$False )]
        [Switch] $ja,
        
        [Parameter( Mandatory=$False )]
        [Switch] $Huge,
        
        [Parameter( Mandatory=$False )]
        [Switch] $Large,
        
        [Parameter( Mandatory=$False )]
        [Int] $mhchemVersion = 4,
        
        [Parameter( Mandatory=$False )]
        [Int] $MarginPt = 1,
        
        [parameter( Mandatory=$False, ValueFromPipeline=$True )]
        [object[]] $InputText
    )
    # get formula
    if ( $Formula.Count -gt 0 ){
        [String[]] $fList = $Formula
    } elseif ( $File ){
        [String[]] $fList = Get-Content -Path $File -Encoding UTF8
    } else {
        [String[]] $fList = $input
    }
    if ( $DocumentClass -eq 'standalone' -and $fList.Count -gt 1 ){
        #pass
    }
    if ( $DocumentClass -eq 'standalone' -and $ja ){
        Write-Error "-ja could not specify with standalone." -ErrorAction Stop
    }
    if ( $DocumentClass -eq 'standalone' ){
        if ( $fList[0] -notmatch '^\s*\$' ){
            $fList[0] = '$' + $fList[0]
        }
        if ( $fList[0] -notmatch '\$\s*$' ){
            $fList[0] = $fList[0] + '$'
        }
    }
    $tempAryList = New-Object 'System.Collections.Generic.List[System.String]'
    if ( $DocumentClass -eq 'standalone'){
        $tempAryList.Add("\documentclass[varwidth,crop,border=$(${MarginPt})pt]{standalone}")
    } elseif ( $ja -and $DocumentClass -eq 'report'){
        $tempAryList.Add("\documentclass{ltjsarticle}")
    } else {
        $tempAryList.Add("\documentclass{$DocumentClass}")
    }
    if ( $True ){
        $tempAryList.Add('\usepackage{amsmath}')
        $tempAryList.Add('\usepackage{amssymb}')
        $tempAryList.Add('\usepackage{amsfonts}')
    }
    if ( $ja ){
        $tempAryList.Add('\usepackage[no-math]{fontspec}')
        #$tempAryList.Add('\usepackage[ipa]{luatexja-preset}')
        $tempAryList.Add('\usepackage[haranoaji,nfssonly]{luatexja-preset}')
    }
    if ( -not $NoChem ){
        $tempAryList.Add("\usepackage[version=$mhchemVersion]{mhchem}")
    }
    if ( $True ){
        $tempAryList.Add('\begin{document}')
    }
    if ( $DocumentClass -ne 'standalone' -and $Huge ){
        $tempAryList.Add('\Huge')
    }
    if ( $DocumentClass -ne 'standalone' -and $Large ){
        $tempAryList.Add('\LARGE')
    }
    if ( $True ){
        foreach ( $f in $fList ){
            $tempAryList.Add("  $f")
        }
        $tempAryList.Add('\end{document}')
    }
    [string[]] $tempLineAry = $tempAryList.ToArray()
    Write-Output $tempLineAry
}
## set alias
#[String] $tmpAliasName = "alias"
#[String] $tmpCmdName   = "math2tex"
#[String] $tmpCmdPath = Join-Path `
#    -Path $PSScriptRoot `
#    -ChildPath $($MyInvocation.MyCommand.Name) `
#    | Resolve-Path -Relative
#if ( $IsWindows ){ $tmpCmdPath = $tmpCmdPath.Replace('\' ,'/') }
## is alias already exists?
#if ((Get-Command -Name $tmpAliasName -ErrorAction SilentlyContinue).Count -gt 0){
#    try {
#        if ( (Get-Command -Name $tmpAliasName).CommandType -eq "Alias" ){
#            if ( (Get-Command -Name $tmpAliasName).ReferencedCommand.Name -eq $tmpCmdName ){
#                Set-Alias -Name $tmpAliasName -Value $tmpCmdName -PassThru `
#                    | ForEach-Object{
#                        Write-Host "$($_.DisplayName)" -ForegroundColor Green
#                    }
#            } else {
#                throw
#            }
#        } elseif ( "$((Get-Command -Name $tmpAliasName).Name)" -match '\.exe$') {
#            Set-Alias -Name $tmpAliasName -Value $tmpCmdName -PassThru `
#                | ForEach-Object{
#                    Write-Host "$($_.DisplayName)" -ForegroundColor Green
#                }
#        } else {
#            throw
#        }
#    } catch {
#        Write-Error "Alias ""$tmpAliasName ($((Get-Command -Name $tmpAliasName).ReferencedCommand.Name))"" is already exists. Change alias needed. Please edit the script at the end of the file: ""$tmpCmdPath""" -ErrorAction Stop
#    } finally {
#        Remove-Variable -Name "tmpAliasName" -Force
#        Remove-Variable -Name "tmpCmdName" -Force
#    }
#} else {
#    Set-Alias -Name $tmpAliasName -Value $tmpCmdName -PassThru `
#        | ForEach-Object {
#            Write-Host "$($_.DisplayName)" -ForegroundColor Green
#        }
#    Remove-Variable -Name "tmpAliasName" -Force
#    Remove-Variable -Name "tmpCmdName" -Force
#}
