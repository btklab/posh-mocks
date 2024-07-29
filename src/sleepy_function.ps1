<#
.SYNOPSIS
    sleepy - Sleep with progress bar

    thanks:
        mattn/sleepy - GitHub https://github.com/mattn/sleepy
        License: The MIT License (MIT): Copyright (c) 2022 Yasuhiro Matsumoto

.LINK
    Write-Progress
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-progress

.PARAMETER Minutes
    Default set to 25 minutes (as pomodoro timer)

.PARAMETER TeaTimer
    Call teatimer function after specified time has elapsed. 

.PARAMETER Past
    Display elapsed time since the specified time.

.PARAMETER FirstBell
    Set firstbell (preliminary bell)
    Specify minutes in advance should the bell ring?

.EXAMPLE
    # examples

    # count 3 sec and past timer
    sleepy -s 3 -p

    # infinit
    sleepy -i

    # clock mode
    sleepy -c

#>
function sleepy {
    Param(
        [Parameter(Position=0,Mandatory=$False)]
        [Alias('m')]
        [double] $Minutes,

        [Parameter(Mandatory=$False)]
        [Alias('h')]
        [double] $Hours,

        [Parameter(Mandatory=$False)]
        [Alias('s')]
        [double] $Seconds,

        [Parameter(Mandatory=$False)]
        [Alias('p')]
        [switch] $Past,

        [Parameter(Mandatory=$False)]
        [Alias('t')]
        [switch] $TeaTimer,

        [Parameter(Mandatory=$False)]
        [Alias('i')]
        [switch] $Infinit,

        [Parameter(Mandatory=$False)]
        [Alias('c')]
        [switch] $Clock,

        [Parameter(Mandatory=$False)]
        [Alias('f')]
        [int] $FirstBell,

        [Parameter(Mandatory=$False)]
        [switch] $Message,

        [Parameter(Mandatory=$False)]
        [Alias('d')]
        [double] $Span = 1
    )
    # private function
    # is command exist?
    function isCommandExist ([string]$cmd) {
        try { Get-Command $cmd -ErrorAction Stop | Out-Null
            return $True
        } catch {
            return $False
        }
    }
    # convert timespan to strings
    function span2str ($timespan){
        if ($timespan.Days -ge 1){
            [string] $sStr = $timespan.ToString("dd\.hh\:mm\:ss")
        } else {
            if ($timespan.Hours -ge 1){
                [string] $sStr = $timespan.ToString("hh\:mm\:ss")
            } else {
                [string] $sStr = $timespan.ToString("mm\:ss")
            }
        }
        return $sStr
    }
    # past timer (minutes)
    $pMin = 59
    # set time span (seconds)
    if ($Hours){
        [double] $addSec = $Hours * 60 * 60
        [string] $dStr = "$Hours hr"
    } elseif ($Minutes){
        [double] $addSec = $Minutes * 60
        [string] $dStr = "$Minutes min"
    } elseif ($Seconds){
        [double] $addSec = $Seconds
        [string] $dStr = "$Seconds sec"
    } else {
        # pomodoro: 25 min
        [double] $addSec = 25 * 60
        [string] $dStr = "25 min"
    }
    # set start time
    [datetime] $sDateTime = Get-Date
    # calc end time from start time
    [datetime] $eDateTime = $sDateTime.AddSeconds($addSec)
    # set span
    $eSpan = New-TimeSpan -Start $sDateTime -End $eDateTime
    # now time
    [datetime] $nDateTime = Get-Date
    # duration
    [double] $sSec = $sDateTime.Minute
    [double] $eSec = $eDateTime.Minute
    # infinit
    if ($Infinit){
        while ($True){
            [datetime] $nDateTime = Get-Date
            $iSpan = New-TimeSpan -Start $sDateTime -End $nDateTime
            [string] $iStr = span2str $iSpan
            [string] $nStr = (Get-Date).ToString('M/d (ddd) HH:mm:ss')
            $splatting = @{
                Activity = "$iStr"
                Status = " $nStr"
                PercentComplete = 1
                Id = 1
            }
            Write-Progress @splatting
            Start-Sleep -Milliseconds 300
        }
        return
    }
    if ($Clock){
        while ($True){
            [datetime] $nDateTime = Get-Date
            $iSpan = New-TimeSpan -Start $sDateTime -End $nDateTime
            [string] $iStr = (Get-Date).ToString('HH:mm')
            [string] $nStr = (Get-Date).ToString('M/d (ddd)')
            $splatting = @{
                Activity = "$iStr"
                Status = " $nStr"
                PercentComplete = 1
                Id = 1
            }
            Write-Progress @splatting
            Start-Sleep -Milliseconds 300
        }
        return
    }
    # main loop
    if ($Message){
        Write-Host "st: $((Get-Date).ToString('M/d HH:mm:ss')) ($($dStr))" -ForegroundColor Green
    }
    if ($FirstBell){
        if (-not (isCommandExist "teatimer")){
            Write-Error "command: ""teatimer"" is not available." -ErrorAction Stop
        }
        [int] $fBell = -1 *  $FirstBell
        teatimer -Text "last $FirstBell minutes" -Title "First bell" -At $eDateTime.AddMinutes($fBell).ToString('yyyy-MM-dd HH:mm:ss') -Quiet
    }
    while ($nDateTime -le $eDateTime) {
        [datetime] $nDateTime = Get-Date
        $tSpan = New-TimeSpan -Start $sDateTime -End $nDateTime
        $rSpan = New-TimeSpan -Start $nDateTime -End $eDateTime
        [int] $tSec = $tSpan.TotalSeconds
        [int] $dSec = $rSpan.TotalSeconds
        # progres percentage
        [double] $tprc = $tSec / $addSec * 100
        if ( $tprc -gt 100 ){
            $tprc = 100
        }
        if ($tprc -le 0.5){
            [int] $perc = 1
        } else {
            [int] $perc = $tprc
        }
        [string] $eStr = span2str $eSpan
        [string] $tStr = span2str $tSpan
        $splatting = @{
            Activity = "$($tStr) / $($eStr)"
            Status = " $perc% Complete:"
            PercentComplete = $perc
            SecondsRemaining = $dSec
            Id = 1
        }
        Write-Progress @splatting
        Start-Sleep -Seconds $Span
    }
    if ($Message){
        Write-Host "en: $((Get-Date).ToString('M/d HH:mm:ss'))" -ForegroundColor Green
    }
    if ($TeaTimer){
        if (-not (isCommandExist "teatimer")){
            Write-Error "command: ""teatimer"" is not available." -ErrorAction Stop
        }
        #teatimer -At (Get-Date).AddSeconds(2).ToString('yyyy-MM-dd HH:mm:ss') -Quiet
        teatimer -Quiet
    }

    # past timer
    if ($Past){
        [datetime] $sDateTime = $eDateTime
        while ($True){
            [datetime] $nDateTime = Get-Date
            $iSpan = New-TimeSpan -Start $sDateTime -End $nDateTime
            [string] $iStr = span2str $iSpan
            [string] $iStr = "past: $iStr"
            [string] $nStr = (Get-Date).ToString('M/d (ddd) HH:mm')
            $splatting = @{
                Activity = "$iStr"
                Status = " $nStr"
                PercentComplete = 1
                ParentId = 1
            }
            Write-Progress @splatting
            Start-Sleep -Milliseconds 300
        }
    }
}
