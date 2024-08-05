<#
.SYNOPSIS
    teatimer - notify tea-time from the task tray.

    Reference:
    - https://devblogs.microsoft.com/scripting/weekend-scripter-tea-time/
    - Weekend Scripter: Tea Time!
    - October 2nd, 2010
    - Microsoft Scripting Guy Ed Wilson

.PARAMETER Minutes
    Specify how many minutes from now to notify.
    Can be used with Hours, Seconds.

.PARAMETER Hours
    Specify how many hours from now to notify.
    Can be used with Minutes, Seconds.

.PARAMETER Seconds
    Specify how many seconds from now to notify.
    Can be used with Minutes, Hours.

.PARAMETER At
    Specify when to notify.
    If you specify a value before the current time,
    it will be that time on the next day.

    Cannot be used with -Minutes, -Hours, -Seconds.
    If used together, -At takes precedence.

.PARAMETER Title
    The title of the message.
    Default : "Tea is ready."

.PARAMETER Text
    The body of the message.
    Default : "get your tea."

.PARAMETER ShowPastTime
    Include elapsed time in the message.

.PARAMETER IconType
    Type of icon.
    Default : "Information"

    Choices are Application, Asterisk, Error,
    Exclamation, Hand, Information, Question,
    Shield, Warning, WinLog

.EXAMPLE
teatimer

PS > teatimer -Minutes 90

PS > teatimer -Hours 1 -Minutes 90

PS > teatimer -At 10:30
# Notification at 10:30 today.
# If 10:30 has passed at the time of setting,
# will be notified at 10:30 the next day.

PS > teatimer -At "2019/3/20 10:30"

PS > teatimer -Minutes 90 -Title "this is the title" -Text "body"

PS > teatimer -Minutes 90 -ShowPastTime

PS > teatimer -Minutes 90 -IconType Error

#>
function teatimer {
  Param (
    [Parameter(Mandatory=$False)]
    [Alias('m')]
    [int] $Minutes = 0,

    [Parameter(Mandatory=$False)]
    [Alias('h')]
    [int] $Hours = 0,

    [Parameter(Mandatory=$False)]
    [Alias('s')]
    [int] $Seconds = 0,

    [Parameter(Mandatory=$False)]
    [Alias('a')]
    [datetime] $At,

    [Parameter(Mandatory=$False)]
    [string] $Title = "Tea is ready",

    [Parameter(Mandatory=$False)]
    [string] $Text = "get your tea",

    [Parameter(Mandatory=$False)]
    [int] $Timeout = 4000,

    [Parameter(Mandatory=$False)]
    [int] $EventTimeout = 5,

    [Parameter(Mandatory=$False)]
    [switch] $ShowPastTime,

    [Parameter(Mandatory=$False)]
    [Alias('q')]
    [switch] $Quiet,

    [Parameter(Mandatory=$False)]
    [ValidateSet(
      "Application", "Asterisk", "Error", "Exclamation",
      "Hand", "Information", "Question", "Shield",
      "Warning", "WinLogo")]
    [string] $IconType = "Information"
  )

  $nowDateTime = Get-Date
  if($At){
    ## Date and time specification by -At option
    $alarmDateTime = (Get-Date $At)
    if($alarmDateTime -lt $nowDateTime){
      ## If the specified time is in the past,
      ## add 1 to the date.
      $alarmDateTime = $alarmDateTime.AddDays(1)
      if($alarmDateTime -lt $nowDateTime){
        ## Raise error if correction is still not possible.
        $errorDayTime = $At.ToString('yyyy-M-d (ddd) HH:mm:ss')
        Write-Error "Error: specified the past datetime: $errorDayTime" -ErrorAction Stop
        return
      }
    }
    $objTimeSpan = New-TimeSpan -Start $nowDateTime -End $alarmDateTime
  }else{
    ## Specify how many times from now
    $objTimeSpan = New-TimeSpan -Hours $Hours -Minutes $Minutes -Seconds $Seconds
  }
  $sleepSeconds = $objTimeSpan.TotalSeconds

  ## Generate argument list to pass to teatimer_exec.ps1
  $ArgumentList = @()
  $scrFile = "teatimer_exec.ps1"
  $scrPath = Join-Path "$PSScriptRoot" "$scrFile"
  if( -not ( Test-Path -LiteralPath $scrPath ) ){
    Write-Error "$scrFile is not exists." -ErrorAction Stop
  }
  $ArgumentList += $scrPath
  if($At){
    $ArgumentList += '-At'
    $ArgumentList += "'$At'"
  }else{
    $ArgumentList += "-Minutes"
    $ArgumentList += "$Minutes"
    $ArgumentList += "-Hours"
    $ArgumentList += "$Hours"
    $ArgumentList += "-Seconds"
    $ArgumentList += "$Seconds"
  }
  $ArgumentList += "-Title"
  $ArgumentList += "'$Title'"
  $ArgumentList += "-Text"
  $ArgumentList += "'$Text'"
  $ArgumentList += "-Timeout"
  $ArgumentList += "$Timeout"
  $ArgumentList += "-EventTimeout"
  $ArgumentList += "$EventTimeout"
  if($ShowPastTime){
    $ArgumentList += "-ShowPastTime"
  }
  $ArgumentList += "-IconType"
  $ArgumentList += "'$IconType'"
  #Write-Debug $ArgumentList
 
  Write-Debug $($ArgumentList -Join " ")
  Start-Process pwsh -ArgumentList $ArgumentList -WindowStyle Hidden

  ## Output of setting completion message
  $displayAlartDateTime = $(Get-Date).AddSeconds(1) + $objTimeSpan
  $ymdhms = $displayAlartDateTime.ToString('yyyy-M-d (ddd) HH:mm:ss')
  if (-not $Quiet){
    Write-Host "Set an alarm for $ymdhms"
  }
}
