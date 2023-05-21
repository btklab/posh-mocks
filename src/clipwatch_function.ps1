<#
.SYNOPSIS
    clipwatch - A clipboard watcher using Compare-Object

.LINK
    fwatch

.PARAMETER Action
    Action(ScriptBlock) when change detected

.PARAMETER Interval
    Loop interval (seconds)

.PARAMETER Quiet
    Do not show status info

.PARAMETER Log
    Output Log

.PARAMETER OutOnlyLog
    Action > $Null

.PARAMETER Repeat
    Repeat mode

.EXAMPLE
    clipwatch -Action {Get-ClipBoard | say}

    =====
    watch and say

#>
function clipwatch {
    Param(
        [Parameter(Position=0, Mandatory=$True)]
        [Alias('a')]
        [ScriptBlock] $Action,

        [Parameter(Mandatory=$False)]
        [string] $Interval = 1,

        [Parameter(Mandatory=$False)]
        [string] $Log,

        [Parameter(Mandatory=$False)]
        [string] $Message,

        [Parameter(Mandatory=$False)]
        [switch] $OutOnlyLog,

        [Parameter(Mandatory=$False)]
        [switch] $Repeat,

        [Parameter(Mandatory=$False)]
        [switch] $Echo,

        [Parameter(Mandatory=$False)]
        [Alias('q')]
        [switch] $Quiet
    )

    ## set log message
    [string] $scriptLine = "clipwatch"
    if($Action) { [string] $scriptLine += " -Action {$Action}"}
    if($Log)    { [string] $scriptLine += " -Log $Log"}

    ## Output Log Header
    if(-not $Quiet){
        Write-Output "$scriptLine"
        Write-Output ''
    }

    ## main
    [bool] $diffFlag = $False
    [bool] $repFlag = $True
    [string] $clipStrOld = Get-ClipBoard
    while ($true) {
        $clipStrNew = Get-ClipBoard
        if ($clipStrNew) {
            ## compare
            [object] $res = Compare-Object `
                        -ReferenceObject  $clipStrOld `
                        -DifferenceObject $clipStrNew `
                   | Where-Object { $_.SideIndicator -ne '==' }
            ## check flag
            if ( ($res -ne $Null) -or ($repFlag -eq $True) ){
                [bool] $diffFlag = $True
            }
            if ( $diffFlag -or $repFlag ){
                ## detect difference
                if(-not $Quiet ){
                    if ( $diffFlag ){
                        [string] $writeLine = "ClipBoard Changed..."
                    } else {
                        [string] $writeLine = ''
                    }
                    if($Message){ $writeLine = $writeLine + " $Message" }
                    Write-Output $writeLine
                }
                if($OutOnlyLog){
                    & $Action > $Null
                } else {
                    & $Action
                    if ( $Echo ){
                        Write-Host $clipStrNew -Foregroundcolor green
                    }
                }
            }
            [bool] $diffFlag = $False
            [bool] $repFlag  = $False
        }
        [string] $clipStrOld = [string] $clipStrNew
        if ( $Repeat ){
            [string] $resFromHost = Read-Host "Press any key to next/repeat"
            if ( $resFromHost -eq '' ){
                [bool] $repFlag = $True
            } else {
                [bool] $repFlag = $True
            }
        }
        Start-Sleep -Seconds $interval
    }
}

