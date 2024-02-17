<#
.SYNOPSIS
    Execute-TinyTex (Alias: tinytex) -- Execute Rscript -e "tinytex::lualatex('a.tex')"

    Compiler for .tex file using tinytex.

.PARAMETER ReInstall
    If you see an error message "Remote repository newer than local",
    it means it is time for you to upgrade (reinstall) TinyTeX manually

        library(tinytex)
        tinytex::reinstall_tinytex()

.EXAMPLE
    # Compile a.tex to a.pdf
    tinytex -f a.tex
        Rscript --vanilla --slave -e "library(tinytex);" -e "tinytex::lualatex('a.tex');"

.EXAMPLE
    # Search and Install package
    tinytex -SearchPackage "/times.sty"

        tlmgr.pl: package repository https://mirror.ctan.org/systems/texlive/tlnet (verified)
        psnfss:
                texmf-dist/tex/latex/psnfss/times.sty

    tinytex -InstallPackage "psnfss"

.LINK
    Execute-TinyTex (Alias: tinytex), math2tex, pdf2svg, tex2pdf


.NOTES
    R: The R Project for Statistical Computing
        https://www.r-project.org/
    
    TinyTeX - Yihui Xie
        https://yihui.org/tinytex/

    GitHub - rstudio/tinytex-releases
        https://github.com/rstudio/tinytex-releases

    CTAN: Package haranoaji
        https://ctan.org/pkg/haranoaji
#>
function Execute-TinyTex {

    [CmdletBinding()]
    param (
        [Parameter( Mandatory=$False, Position=0 )]
        [Alias('f')]
        [String] $File,
        
        [Parameter( Mandatory=$False )]
        [Alias('s')]
        [String] $SearchPackage,
        
        [Parameter( Mandatory=$False )]
        [String] $InstallPackage,
        
        [Parameter( Mandatory=$False )]
        [Switch] $UpdatePackage,
        
        [Parameter( Mandatory=$False )]
        [Switch] $ReInstallTinyTex,
        
        [Parameter( Mandatory=$False )]
        [Switch] $InstallTinyTex,
        
        [Parameter( Mandatory=$False )]
        [Switch] $UnInstallTinyTex,
        
        [Parameter( Mandatory=$False )]
        [Switch] $UpdateTinyTex,
        
        [Parameter( Mandatory=$False )]
        [Switch] $pdflatex,
        
        [Parameter( Mandatory=$False )]
        [Switch] $xelatex,
        
        [Parameter( Mandatory=$False )]
        [Switch] $lualatex,
        
        [Parameter( Mandatory=$False )]
        [Switch] $NewWindow,
        
        [Parameter( Mandatory=$False )]
        [Switch] $NoWait,
        
        [Parameter( Mandatory=$False )]
        [String] $Script,
        
        [parameter( Mandatory=$False, ValueFromPipeline=$True )]
        [object[]] $InputText
    )
    # private function
    function isCommandExist ([string]$cmd) {
        try { Get-Command -Name $cmd -ErrorAction Stop > $Null
            return $True
        } catch {
            return $False
        }
    }
    # test script
    if ( $SearchPackage -or $InstallPackage -or $UpdatePackage ){
        [String] $cmdRscript = "Rscript"
        #[String] $cmdRscript = "tlmgr"
        if ( -not ( isCommandExist $cmdRscript )){
            Write-Error "$cmdRscript is not exists." -ErrorAction Continue
            if ($IsWindows){
                Write-Error 'Install R: The R Project for Statistical Computing.' -ErrorAction Continue
                Write-Error '  uri: https://www.r-project.org/' -ErrorAction Continue
                Write-Error '  winget install --id RProject.R --source winget' -ErrorAction Stop
            } else {
                Write-Error 'Install R: The R Project for Statistical Computing.' -ErrorAction Continue
                Write-Error '  uri: https://www.r-project.org/' -ErrorAction Continue
                Write-Error '  sudo apt install r-base' -ErrorAction Stop
            }
        }
    } else {
        [String] $cmdRscript = "Rscript"
        #[String] $cmdRscript = "tlmgr"
        if ( -not ( isCommandExist $cmdRscript )){
            Write-Error "$cmdRscript is not exists." -ErrorAction Continue
            if ($IsWindows){
                Write-Error 'Install R: The R Project for Statistical Computing.' -ErrorAction Continue
                Write-Error '  uri: https://www.r-project.org/' -ErrorAction Continue
                Write-Error '  winget install --id RProject.R --source winget' -ErrorAction Stop
            } else {
                Write-Error 'Install R: The R Project for Statistical Computing.' -ErrorAction Continue
                Write-Error '  uri: https://www.r-project.org/' -ErrorAction Continue
                Write-Error '  sudo apt install r-base' -ErrorAction Stop
            }
        }
    }
    # test option
    if ( $File -and -not ( Test-Path -LiteralPath $File )){
        Write-Error "$File is not exists." -ErrorAction Stop
    }
    # set rscript command
    [String[]] $cmd = @()
    if ( $InstallTinyTex ){
        [String[]] $cmd += @("-e", "install.packages('tinytex');")
        [String[]] $cmd += @("-e", "tinytex::install_tinytex();")
    } elseif ( $UnInstallTinyTex ){
        [String[]] $cmd += @("-e", "library(tinytex);")
        [String[]] $cmd += @("-e", "tinytex::uninstall_tinytex();")
    } elseif ( $UpdateTinyTex ){
        [String[]] $cmd += @("-e", "install.packages('tinytex');")
    } elseif ( $ReInstallTinyTex ){
        [String[]] $cmd += @("-e", "library(tinytex);")
        [String[]] $cmd += @("-e", "tinytex::reinstall_tinytex();")
    } elseif ( $SearchPackage ){
        # equivalent to:
        # tlmgr search --global --file "/times.sty"
        [String[]] $cmd += @("-e", "library(tinytex);")
        [String[]] $cmd += @("-e", "tinytex::tlmgr_search('$SearchPackage');")
    } elseif ( $InstallPackage ){
        # equivalent to:
        #  tlmgr install psnfss
        # if the package contains executables (e.g., dvisvgm), run
        #  tlmgr path add 
        [String[]] $cmd += @("-e", "library(tinytex);")
        [String[]] $cmd += @("-e", "tinytex::tlmgr_install('$InstallPackage');")
    } elseif ( $UpdatePackage ){
        # equivalent to:
        #  tlmgr update --self --all
        #  tlmgr path add
        #  fmtutil-sys --all
        [String[]] $cmd += @("-e", "library(tinytex);")
        [String[]] $cmd += @("-e", "tinytex::tlmgr_update();")
    } else {
        # set script
        if ( $File ){
            [String] $texFilePath = (Resolve-Path -LiteralPath $File -Relative)
            if ( $IsWindows ){
                [String] $texFilePath = $texFilePath.Replace('\','/')
            }
            [String[]] $cmd += @("-e", "library(tinytex);")
            if ( $pdflatex ){
                [String[]] $cmd += @("-e", "tinytex::pdflatex('$texFilePath');")
            } elseif ( $xelatex ){
                [String[]] $cmd += @("-e", "tinytex::xelatex('$texFilePath');")
            } elseif ( $lualatex ){
                [String[]] $cmd += @("-e", "tinytex::lualatex('$texFilePath');")
            } else {
                [String[]] $cmd += @("-e", "tinytex::lualatex('$texFilePath');")
            }
        } elseif ( $Script ){
            [String[]] $cmd += @("-e", $Script)
        } else {
            [String[]] $cmd += @("-e", 'getwd();')
        }
    }
    # set argument list
    [String[]] $ArgumentList = @("--vanilla", "--slave")
    [String[]] $ArgumentList += $cmd
    [String] $writeCmd = $cmdRscript
    for ( $i=0; $i -lt $ArgumentList.Count; $i++ ){
        [String] $beforeCmd = $ArgumentList[($i - 1)]
        if ( $beforeCmd -eq '-e' ){
            [String] $writeCmd += " " + """$($ArgumentList[$i])"""
        } else {
            [String] $writeCmd += " " + "$($ArgumentList[$i])"
        }
    }
    # set splatting
    $splatting = @{
        FilePath = $cmdRscript
        ArgumentList = $ArgumentList
    }
    if ( -not $NewWindow ){
        $splatting.Set_Item("NoNewWindow", $True)
    }
    if ( -not $NoWait ){
        $splatting.Set_Item("Wait", $True)
    }
    try {
        Write-Host -Message $writeCmd -ForegroundColor "Yellow"
        Start-Process @splatting
    } catch {
        Write-Error $Error[0] -ErrorAction Stop
    }
    if ( $File ){
        Start-Sleep -Seconds 1
        Get-Item -LiteralPath $($texFilePath -replace '\.[^\.]+$', '.pdf')
    }
}
# set alias
[String] $tmpAliasName = "tinytex"
[String] $tmpCmdName   = "Execute-TinyTex"
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
