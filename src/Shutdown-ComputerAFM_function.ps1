<#
.SYNOPSIS
    Shutdown-ComputerAFM - Shutdown computer after a few minutes

.EXAMPLE
    Shutdown-ComputerAFM 3

#>
function Shutdown-ComputerAFM {

    [CmdletBinding()]
    param (
        [Parameter( Mandatory=$False )]
        [Alias('m')]
        [Int] $Minutes = 1,

        [Parameter( Mandatory=$False )]
        [Alias('f')]
        [Switch] $Force
    )
    function isCommandExist ([string]$cmd) {
        try { Get-Command -Name $cmd -ErrorAction Stop > $Null
            return $True
        } catch {
            return $False
        }
    }
    if ( isCommandExist "sleepy" ){
        sleepy -Minutes $Minutes
    } else {
        Start-Sleep -Seconds $($Minutes * 60)
    }
    Stop-Computer -Force:$Force
}
## set alias
#[String] $tmpAliasName = "shutdownc"
#[String] $tmpCmdName   = "Shutdown-ComputerAFT"
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
