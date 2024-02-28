<#
.SYNOPSIS
    math2tex (Alias: chem2tex) - Add LaTeX preables to the mathematical and chemical formula in LaTex format.

    Add LaTeX preables to the mathematical and chemical formula in LaTex format.
    By using this function with the "tinytex" (Execute-TinyTeX) command,
    you can generate a PDF file containing only mathematical or chemical
    formula.

    References:
        amsmath
            - https://ftp.kddilabs.jp/CTAN/macros/latex/required/amsmath/amsldoc.pdf

        physics
            - https://ftp.jaist.ac.jp/pub/CTAN/macros/latex/contrib/physics/physics.pdf
            
        siunitx
            - https://ftp.yz.yamagata-u.ac.jp/pub/CTAN/macros/latex/contrib/siunitx/siunitx.pdf
            - http://www.yamamo10.jp/yamamoto/comp/latex/make_doc/unit/index.php

        mhchem
            - https://ctan.org/pkg/mhchem
            - http://www.yamamo10.jp/yamamoto/comp/latex/make_doc/chemistry/index.php
            - https://doratex.hatenablog.jp/entry/20131203/1386068127

        chemfig
            - https://www.ctan.org/pkg/chemfig
            - https://doratex.hatenablog.jp/entry/20141212/1418393703

        luatexja
            - https://ctan.org/pkg/luatexja

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
        \usepackage{chemfig}
        \begin{document}
          $\ce{2H + O2 -> H2O}$
        \end{document}

.LINK
    Execute-TinyTeX (Alias: tinytex), math2tex, pdf2svg

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
        [Switch] $AddDollars,
        
        [Parameter( Mandatory=$False )]
        [Switch] $AddBrackets,
        
        [Parameter( Mandatory=$False )]
        [Switch] $NoMhchem,
        
        [Parameter( Mandatory=$False )]
        [Switch] $NoChemfig,
        
        [Parameter( Mandatory=$False )]
        [Switch] $NoSiunitx,
        
        [Parameter( Mandatory=$False )]
        [Switch] $NoPhysics,
        
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
        Write-Error "-ja could not specify with DocumentClass.standalone." -ErrorAction Stop
    }
    if ( $AddDollars ){
        if ( $fList[0] -notmatch '^\s*\$' ){
            $fList[0] = '$' + $fList[0]
        }
        if ( $fList[0] -notmatch '\$\s*$' ){
            $fList[0] = $fList[0] + '$'
        }
    }
    if ( $AddBrackets ){
        $fList[0] = '\[' + $fList[0] + '\]'
    }
    $tempAryList = New-Object 'System.Collections.Generic.List[System.String]'
    if ( $DocumentClass -eq 'standalone'){
        $tempAryList.Add("\documentclass[varwidth,crop,border=$(${MarginPt})pt]{standalone}")
    } elseif ( $ja ){
        $tempAryList.Add("\documentclass[lualatex,ja=standard,jafont=haranoaji]{bxjsarticle}")
    } else {
        $tempAryList.Add("\documentclass{$DocumentClass}")
    }
    if ( $True ){
        $tempAryList.Add('\usepackage{amsmath}')
        $tempAryList.Add('\usepackage{amssymb}')
        $tempAryList.Add('\usepackage{amsfonts}')
    }
    if ( $ja ){
        $tempAryList.Add('\usepackage{luatexja}')
        $tempAryList.Add('%\usepackage[no-math]{luatexja-fontspec}')
        #$tempAryList.Add('\usepackage[no-math]{fontspec}')
        #$tempAryList.Add('\usepackage[ipa]{luatexja-preset}')
        #$tempAryList.Add('\usepackage[haranoaji,nfssonly]{luatexja-preset}')
    }
    if ( -not $NoMhchem ){
        $tempAryList.Add("\usepackage[version=$mhchemVersion]{mhchem}")
    }
    if ( -not $NoChemfig ){
        $tempAryList.Add("\usepackage{chemfig}")
    }
    if ( -not $NoPhysics ){
        $tempAryList.Add("\usepackage{physics}")
    }
    if ( -not $NoSiunitx ){
        $tempAryList.Add("\usepackage{siunitx}")
        $tempAryList.Add("\AtBeginDocument{\RenewCommandCopy\qty\SI}")

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
# set alias
[String] $tmpAliasName = "chem2tex"
[String] $tmpCmdName   = "math2tex"
[String] $tmpCmdPath = Join-Path `
    -Path $PSScriptRoot `
    -ChildPath $($MyInvocation.MyCommand.Name) `
    | Resolve-Path -Relative
if ( $IsWindows ){ $tmpCmdPath = $tmpCmdPath.Replace('\' ,'/') }
# is alias already exists?
if ((Get-Command -Name $tmpAliasName -ErrorAction SilentlyContinue).Count -gt 0){
    try {
        if ( (Get-Command -Name $tmpAliasName).CommandType -eq "Alias" ){
            if ( (Get-Command -Name $tmpAliasName).ReferencedCommand.Name -eq $tmpCmdName ){
                Set-Alias -Name $tmpAliasName -Value $tmpCmdName -PassThru `
                    | ForEach-Object{
                        Write-Host "$($_.DisplayName)" -ForegroundColor Green
                    }
            } else {
                throw
            }
        } elseif ( "$((Get-Command -Name $tmpAliasName).Name)" -match '\.exe$') {
            Set-Alias -Name $tmpAliasName -Value $tmpCmdName -PassThru `
                | ForEach-Object{
                    Write-Host "$($_.DisplayName)" -ForegroundColor Green
                }
        } else {
            throw
        }
    } catch {
        Write-Error "Alias ""$tmpAliasName ($((Get-Command -Name $tmpAliasName).ReferencedCommand.Name))"" is already exists. Change alias needed. Please edit the script at the end of the file: ""$tmpCmdPath""" -ErrorAction Stop
    } finally {
        Remove-Variable -Name "tmpAliasName" -Force
        Remove-Variable -Name "tmpCmdName" -Force
    }
} else {
    Set-Alias -Name $tmpAliasName -Value $tmpCmdName -PassThru `
        | ForEach-Object {
            Write-Host "$($_.DisplayName)" -ForegroundColor Green
        }
    Remove-Variable -Name "tmpAliasName" -Force
    Remove-Variable -Name "tmpCmdName" -Force
}
