<#
.SYNOPSIS
    clipwatch -- A clipboard watcher using Compare-Object

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
    Action | Out-Null

.EXAMPLE
    clipwatch -Action {Get-ClipBoard | say}

    =====
    watch and say

#>
function clipwatch {
    Param(
        [Parameter(Position=0, Mandatory=$False)]
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
        [Alias('q')]
        [switch] $Quiet
    )

    ## set log message
    [string]$scriptLine = "clipwatch"
    if($Action) {$scriptLine += " -Action {$Action}"}
    if($Log)    {$scriptLine += " -Log $Log"}

    ## Output Log Header
    if(-not $Quiet){
        Write-Output "$scriptLine"
        Write-Output ''
    }

    ## main
    $clipStrOld = Get-ClipBoard
    while ($true) {
        $clipStrNew = Get-ClipBoard
        if ($clipStrNew) {
            ## compare
            $res = Compare-Object `
                        -ReferenceObject $clipStrOld `
                        -DifferenceObject $clipStrNew `
                   | where { $_.SideIndicator -ne '==' }
            if ($res -ne $Null) {
                ## detect difference
                if(-not $Quiet){
                    $writeLine = "ClipBoard Changed..."
                    if($Message){ $writeLine = $writeLine + " $Message" }
                    Write-Output $writeLine
                }
                if($OutOnlyLog){
                    if($Action){& $Action | Out-Null}
                } else {
                    if($Action){& $Action}
                }
            }
        }
        $clipStrOld = Get-ClipBoard
        Start-Sleep -Second $interval
    }
}
