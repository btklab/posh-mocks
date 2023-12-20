<#
.SYNOPSIS
    Sleep-Computer - Sleep computer

.EXAMPLE
    Start-Sleep -Seconds 60; Sleep-Computer

#>
function Sleep-Computer {

    [CmdletBinding()]
    param (
        [Parameter( Mandatory=$False )]
        [Alias('dll')]
        [Switch] $UseRundll32,
        
        [Parameter( Mandatory=$False )]
        [Alias('s')]
        [Int] $Seconds = 1
    )
    Start-Sleep -Seconds $Seconds
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
#[String] $tmpCmdName   = "Sleep-Computer"
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
#        Write-Error "Alias ""$tmpAliasName ($((Get-Command -Name $tmpAliasName).ReferencedCommand.Name))"" is already exists. Change alias needed." -ErrorAction Stop
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
