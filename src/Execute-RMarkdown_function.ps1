<#
.SYNOPSIS
    Execute-RMarkdown (Alias: rmarkdown) - Execute Rscript -e "rmarkdown::render(input='a.Rmd')"

    Compiler for .Rmd file using RMarkdown.

.EXAMPLE
    # Compile a.Rmd to a.html
    rmarkdown a.tex
        Rscript --vanilla --slave -e "library(rmarkdown);" -e "rmarkdown::render(input='a.Rmd', encoding='UTF-8', output_format='all');"

.LINK
    Execute-RMarkdown (rmarkdown), Execute-TinyTeX (tinytex), math2tex, tex2pdf, inkconv

.NOTES
    R: The R Project for Statistical Computing
        https://www.r-project.org/
    #>
function Execute-RMarkdown {

    [CmdletBinding()]
    param (
        [Parameter( Mandatory=$False, Position=0 )]
        [Alias('f')]
        [String] $File,
        
        [Parameter( Mandatory=$False )]
        [Switch] $NewWindow,
        
        [Parameter( Mandatory=$False )]
        [Switch] $All,
        
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
    # test option
    if ( $File -and -not ( Test-Path -LiteralPath $File )){
        Write-Error "$File is not exists." -ErrorAction Stop
    }
    # set rscript command
    [String[]] $cmd = @()
    # set script
    if ( $File ){
        [String] $rmdFilePath = (Resolve-Path -LiteralPath $File -Relative)
        if ( $IsWindows ){
            [String] $rmdFilePath = $rmdFilePath.Replace('\','/')
        }
        [String[]] $cmd += @("-e", "library(rmarkdown);")
        if ( $All ){
            [String[]] $cmd += @("-e", """rmarkdown::render(input='$rmdFilePath', encoding='UTF-8', output_format='all');""")
        } else {
            [String[]] $cmd += @("-e", """rmarkdown::render(input='$rmdFilePath', encoding='UTF-8');""")
        }
    } elseif ( $Script ){
        [String[]] $cmd += @("-e", $Script)
    } else {
        [String[]] $cmd += @("-e", 'getwd();')
    }
    # set argument list
    [String[]] $ArgumentList = @("--vanilla", "--slave")
    [String[]] $ArgumentList += $cmd
    [String] $writeCmd = $cmdRscript
    for ( $i=0; $i -lt $ArgumentList.Count; $i++ ){
        [String] $beforeCmd = $ArgumentList[($i - 1)]
        if ( $beforeCmd -eq '-e' ){
            [string] $tmpCmd = $ArgumentList[$i].Replace('"', '')
            [String] $writeCmd += " " + """$tmpCmd"""
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
}
# set alias
[String] $tmpAliasName = "rmarkdown"
[String] $tmpCmdName   = "Execute-RMarkdown"
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
