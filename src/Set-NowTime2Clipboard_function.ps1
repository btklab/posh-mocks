<#
.SYNOPSIS
    Set-NowTime2Clipboard (Alias: now) - Set current datetime to the clipboard

    # syntax
    now [-Date] [-WeekDay] [-WeekDayOnly] [-Echo] [-Quote] [-Delimiter <String>]
    now [-Time] [-WeekDay] [-WeekDayOnly] [-Echo] [-Quote] [-Delimiter <String>]
    now [-TimeS] [-WeekDay] [-WeekDayOnly] [-Echo] [-Quote] [-Delimiter <String>]
    now [-DateTime] [-WeekDay] [-WeekDayOnly] [-Echo] [-Quote] [-Delimiter <String>]
    now [-DateTimeT] [-DateTimeTS] [-WeekDay] [-WeekDayOnly] [-Echo] [-Quote] [-Delimiter <String>]

    # format
    now             : 2023-12-21 (default)
    now -Date       : 2023-12-21
    now -Time       : 06:32
    now -TimeS      : 06:32:35
    now -DateTime   : 2023-12-21 06:32
    now -DateTimeT  : 2023-12-21T06:32
    now -DateTimeTS : 2023-12-21T06:32

    # add quote and weekday
    now                  : 2023-12-21
    now -WeekDay         : 2023-12-21 (thu)
    now -Quote           : "2023-12-21"
    now -WeekDay -Quote  : "2023-12-21 (thu)"

.EXAMPLE
    # format
    now             : 2023-12-21 (default)
    now -Date       : 2023-12-21
    now -Time       : 06:32
    now -TimeS      : 06:32:35
    now -DateTime   : 2023-12-21 06:32
    now -DateTimeT  : 2023-12-21T06:32
    now -DateTimeTS : 2023-12-21T06:32

.EXAMPLE
    # add quote and weekday
    now                  : 2023-12-21
    now -WeekDay         : 2023-12-21 (thu)
    now -Quote           : "2023-12-21"
    now -WeekDay -Quote  : "2023-12-21 (thu)"


.EXAMPLE
    # output all switch
    @(
    "Date"
    "Time",
    "TimeS",
    "DateTime",
    "DateTimeT",
    "DateTimeTS"
    ) | %{ """now -$_ : "" + `$(now -$_)" }

    now -Date       : 2023-12-21
    now -Time       : 06:32
    now -TimeS      : 06:32:35
    now -DateTime   : 2023-12-21 06:32
    now -DateTimeT  : 2023-12-21T06:32
    now -DateTimeTS : 2023-12-21T06:32

.NOTES
    Get-Date (Microsoft.PowerShell.Utility) - PowerShell
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-date

#>
function Set-NowTime2Clipboard {

    [CmdletBinding(DefaultParameterSetName="Date")]
    param (
        [Parameter(ParameterSetName="Date")]
        [Alias('d')]
        [Switch] $Date,
        
        [Parameter(ParameterSetName="Time")]
        [Alias('t')]
        [Switch] $Time,
        
        [Parameter(ParameterSetName="TimeS")]
        [Alias('ts')]
        [Switch] $TimeS,
        
        [Parameter(ParameterSetName="DateTime")]
        [Alias('dt')]
        [Switch] $DateTime,
        
        [Parameter(ParameterSetName="DateTimeT")]
        [Alias('dtt')]
        [Switch] $DateTimeT,
        
        [Parameter(ParameterSetName="DateTimeT")]
        [Alias('dtts')]
        [Switch] $DateTimeTS,
        
        [Parameter( Mandatory=$False )]
        [Alias('w')]
        [Switch] $WeekDay,
        
        [Parameter( Mandatory=$False )]
        [Alias('wo')]
        [Switch] $WeekDayOnly,
        
        [Parameter( Mandatory=$False )]
        [Alias('e')]
        [Switch] $Echo,
        
        [Parameter( Mandatory=$False )]
        [Alias('q')]
        [Switch] $Quote,
        
        [Parameter( Mandatory=$False )]
        [String] $Delimiter = "-"
    )
    # set date strings
    [String] $longDate     = (Get-Date).ToString('yyyy MM dd').Replace(" ", $Delimiter)
    [String] $shortDate    = (Get-Date).ToString('yy MM dd').Replace(" ", $Delimiter)
    [String] $longTime     = (Get-Date).ToString('HH:mm:ss')
    [String] $shortTime    = (Get-Date).ToString('HH:mm')
    [String] $shortWeekDay = (Get-Date).ToString('ddd')
    switch -Exact ($PsCmdlet.ParameterSetName) {
        "Date"        { [String] $dtFormat = $longDate  }
        "Time"        { [String] $dtFormat = $shortTime }
        "TimeS"       { [String] $dtFormat = $longTime  }
        "DateTime"    { [String] $dtFormat = $longDate + " " + $shortTime }
        "DateTimeT"   { [String] $dtFormat = $longDate + "T" + $shortTime }
        "DateTimeTS"  { [String] $dtFormat = $longDate + "T" + $longTime }
        default       { [String] $dtFormat = $longDate }
    }
    # add weekday strings
    if ( $WeekDayOnly ){
        $dtFormat = $dtFormat + " " + $shortWeekDay
    } elseif ( $WeekDay ){
        $dtFormat = $dtFormat + " " + "($shortWeekDay)"
    }
    # set output format
    Write-Debug $dtFormat
    [String] $writeLine = (Get-Date).ToString($dtFormat)
    # add quote
    if ( $Quote ){
        $writeLine = """$dtFormat"""
    }
    # output
    if ( $Echo ){
        # echo only
        Write-Output "$writeLine"
    } else {
        # echo and set clipboard
        Write-Output "$writeLine"
        Write-Output "$writeLine" | Set-ClipBoard
    }
}
# set alias
[String] $tmpAliasName = "now"
[String] $tmpCmdName   = "Set-NowTime2Clipboard"
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
