<#
.SYNOPSIS
    Sleep-ComputerAFM - Sleep computer after a few minutes

.EXAMPLE
    Sleep-ComputerAFM -Minutes 3

#>
function Sleep-ComputerAFM {

    [CmdletBinding()]
    param (
        [Parameter( Mandatory=$False )]
        [Alias('m')]
        [Int] $Minutes = 1,
        
        [Parameter( Mandatory=$False )]
        [Alias('dll')]
        [Switch] $UseRundll32
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
    if ( $UseRundll32 ){
        # use rundll32.exe
        powercfg -h off
        rundll32.exe powrprof.dll,SetSuspendState 0,1,0
    } else {
        # use windows.forms
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.Application]::SetSuspendState([System.Windows.Forms.PowerState]::Suspend, $false, $false)
    }
}
## set alias
#[String] $tmpAliasName = "sleepc"
#[String] $tmpCmdName   = "Sleep-ComputerAFM"
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
