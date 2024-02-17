<#
.SYNOPSIS
    Inkscape-Converter (Alias: inkconv) - Convert pdf, svg, png using inkscape 

    The file format before and after conversion is automatically
    determined by the extension.

    Usage:
        inkconv in.pdf out.svg | ii
        inkconv in.pdf out.png -w 400 | ii

    Dependencies: inkscape.exe
        winget install --id Inkscape.Inkscape --source winget

.LINK
    Execute-TinyTex (Alias: tinytex), math2tex, tex2pdf, inkconv

.EXAMPLE
    # convert pdf to svg
    inkconv in.pdf out.svg | ii

.EXAMPLE
    # convert pdf to png with size specification
    inkconv in.pdf out.png -w 400 | ii
#>
function Inkscape-Converter {

    Param(
        [Parameter(Position=0,Mandatory=$False)]
        [Alias('i')]
        [string] $InputFile,

        [Parameter(Position=1,Mandatory=$False)]
        [Alias('o')]
        [string] $OutputFile,

        [Parameter(Mandatory=$False)]
        [switch] $NoOverWrite,

        [Parameter(Mandatory=$False)]
        [switch] $Help,

        [Parameter(Mandatory=$False)]
        [Alias('v')]
        [switch] $Version,

        [Parameter(Mandatory=$False)]
        [Alias('h')]
        [int] $Height,

        [Parameter(Mandatory=$False)]
        [Alias('w')]
        [int] $Width,

        [Parameter(Mandatory=$False)]
        [Alias('p')]
        [int] $PdfPage,

        [Parameter(Mandatory=$False)]
        [int] $SleepSec = 1
    )
    ## private function
    function isCommandExist ([string]$cmd) {
        try { Get-Command -Name $cmd -ErrorAction Stop > $Null
            return $True
        } catch {
            return $False
        }
    }
    ## test inkscape
    [String] $cmd = "inkscape"
    if ( -not ( isCommandExist $cmd )){
        Write-Error "$cmd is not exists." -ErrorAction Continue
        if ($IsWindows){
            Write-Error 'Install inkscape' -ErrorAction Continue
            Write-Error '  uri: https://inkscape.org//' -ErrorAction Continue
            Write-Error '  winget install --id Inkscape.Inkscape --source winget' -ErrorAction Stop
        } else {
            Write-Error 'Install inkscape' -ErrorAction Continue
            Write-Error '  uri: https://inkscape.org//' -ErrorAction Continue
            Write-Error '  sudo apt install inkscape' -ErrorAction Stop
        }
    }
    if ( $Version ){
        inkscape --version
        return
    }
    if ( $Help ){
        inkscape --help
        return
    }
    ## test input
    if ( -not $InputFile ){
        Write-Error "input file must be specified." -ErrorAction Stop
    }
    if ( -not $OutputFile ){
        Write-Error "output file must be specified." -ErrorAction Stop
    }
    if ( -not (Test-Path $InputFile)){
        Write-Error """$InputFile"" is not exists." -ErrorAction Stop
    }
    ## test output
    if (( $NoOverWrite) -and (Test-Path $OutputFile)){
        Write-Error """$OutputFile"" is already exists." -ErrorAction Stop
    }
    ## set file path
    [string] $iFilePath = (Resolve-Path -LiteralPath $InputFile -Relative)
    [string] $oFilePath = $(Resolve-Path -LiteralPath . -Relative)
    [string] $oFilePath = Join-Path $oFilePath $OutputFile
    if ( $IsWindows ){
        $iFilePath = $iFilePath.Replace('\', '/')
        $oFilePath = $oFilePath.Replace('\', '/')
    }
    [string] $oFilePath = $oFilePath.Replace('/./', '/')
    [string] $oFilePath = """$oFilePath"""
    [string] $iFilePath = """$iFilePath"""
    ## set opts
    #[string[]] $comArg = @("--export-filename=""$oFilePath""", $iFilePath)
    [string[]] $comArg = @("-o", $oFilePath)
    if ( $Height ){ $comArg += ,@("-h", $Height) }
    if ( $Width  ){ $comArg += ,@("-w", $Width) }
    if ( $PdfPage){ $comArg += ,@("--pdf-page=$PdfPage") }
    [string[]] $comArg += ,@($iFilePath)
    [string] $writeCmd = $cmd
    foreach ( $i in $comArg ){ $writeCmd += " " + $i }
    ## Invoke inkscape
    Write-Host -Message $writeCmd -ForegroundColor "Yellow"
    Start-Process -FilePath $cmd -ArgumentList $comArg -NoNewWindow -Wait
    Start-Sleep -Second $SleepSec
    Get-Item -LiteralPath $OutputFile
}
# set alias
[String] $tmpAliasName = "inkconv"
[String] $tmpCmdName   = "Inkscape-Converter"
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

