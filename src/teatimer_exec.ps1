<#
.SYNOPSIS
Tea timeが来たらタスクトレイから通知してくれる。
処理が完了するまでプロンプトが戻ってこないので、
専用の窓が必要な点に注意する。

Reference:
    - https://devblogs.microsoft.com/scripting/weekend-scripter-tea-time/
    - Weekend Scripter: Tea Time!
    - October 2nd, 2010
    - Microsoft Scripting Guy Ed Wilson


.PARAMETER Minutes
今から何分後に通知するかを指定する
Hours,Secondsと併用可能

.PARAMETER Hours
今から何時間に通知するかを指定する
Minutes,Secondsと併用可能

.PARAMETER Seconds
今から何分後に通知するかを指定する
Hours,Minutesと併用可能

.PARAMETER At
何時に通知するかを指定する
現在時刻より前の値を指定した場合、
翌日のその時刻になる

Minutes,Hours,Secondsとは併用不可
もし併用した場合はAtが優先される

.PARAMETER Title
メッセージのタイトル
デフォルト値は、"Tea is ready"

.PARAMETER Text
メッセージの本文
デフォルト値は、"get your tea"

.PARAMETER ShowPastTime
メッセージに経過時間を含める

.PARAMETER IconType
アイコンの種類
デフォルト値は "Information"
選択肢は、Application, Asterisk, Error,
Exclamation, Hand, Information, Question,
Shield, Warning, WinLog

.EXAMPLE
PS C:\> teatimer
オプションを指定しなければ、直ちに通知する

.EXAMPLE
PS C:\> teatimer -Minutes 90
90分後に通知してくれる

.EXAMPLE
PS C:\> teatimer -Hours 1 -Minutes 90
1時間と90分後に通知してくれる

.EXAMPLE
PS C:\> teatimer -At 10:30
本日の10:30に通知してくれる
ただし、設定時点で10:30が過ぎていた場合、
翌日の10:30に通知してくれる

.EXAMPLE
PS C:\> teatimer -At "2019/3/20 10:30"
クオートすれば、日付指定も可能

.EXAMPLE
PS C:\> teatimer -Minutes 90 -Title "そろそろ休憩しませんか？" -Text "もう90分も仕事しています"
通知のタイトルと文章を指定

.EXAMPLE
PS C:\> teatimer -Minutes 90 -ShowPastTime
90分後に通知してくれる
通知メッセージに設定してからの経過時間も表示する

.EXAMPLE
PS C:\> teatimer -Minutes 90 -IconType Error
アイコンのタイプを変更する


#>
function teatimer-exec {
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
    [ValidateSet(
      "Application",
      "Asterisk",
      "Error",
      "Exclamation",
      "Hand",
      "Information",
      "Question",
      "Shield",
      "Warning",
      "WinLogo")]
    [string] $IconType = "Information"
  )

  $nowDateTime = Get-Date
  if($At){
    ## -At による日時指定
    $alarmDateTime = (Get-Date $At)
    if($alarmDateTime -lt $nowDateTime){
      ## 指定時間が過去の場合、日付を1加算
      $alarmDateTime = $alarmDateTime.AddDays(1)
      if($alarmDateTime -lt $nowDateTime){
        ## それでも補正できない場合はエラー
        $errorDayTime = $At.ToString('yyyy-M-d (ddd) HH:mm:ss')
        Write-Error "Error: 過去の日付 $errorDayTime が指定されました." -ErrorAction Stop
        return
      }
    }
    $objTimeSpan = New-TimeSpan -Start $nowDateTime -End $alarmDateTime
  }else{
    ## 今から何分後か、という指定
    $objTimeSpan = New-TimeSpan -Hours $Hours -Minutes $Minutes -Seconds $Seconds
  }
  $sleepSeconds = $objTimeSpan.TotalSeconds
  #Write-Output $sleepSeconds
  #Write-Output $displayAlartDateTime

  ## 設定完了メッセージの出力
  $displayAlartDateTime = $(Get-Date) + $objTimeSpan
  $ymdhms = $displayAlartDateTime.ToString('yyyy-M-d (ddd) HH:mm:ss')
  Write-Host "$ymdhms にアラームを設定しました."

  ## Exec Sleep And Velify Timer is working properly
  #$startTime = Get-Date
  Start-Sleep -Seconds $sleepSeconds
  #$endTime   = Get-Date
  #(New-TimeSpan -Start $startTime -End $endTime).TotalSeconds

  ## Show-BalloonTip
  Add-Type -AssemblyName system.windows.forms
  Add-Type -AssemblyName System.Drawing
  $toast = New-Object system.windows.forms.notifyicon
  #$toast.icon = [system.drawing.systemicons]::Information
  $toast.icon = [system.drawing.systemicons]::$IconType
  $toast.balloonTipTitle = $Title
  $toast.visible = $True
  $objPastSpan = New-TimeSpan -Start $nowDateTime -End (Get-Date)
  if($ShowPastTime){
    $writeLine  = " (経過時間"
    $writeLine += " h:" + $objPastSpan.Hours.ToString('0.0')
    $writeLine += " m:" + $objPastSpan.Minutes.ToString('0.0')
    $writeLine += " s:" + $objPastSpan.Seconds.ToString('0.0')
    $writeLine += ")"
    $toast.BalloonTipText = $Text + $writeLine
  }else{
    $toast.BalloonTipText = $Text
  }
  $toast.ShowBalloonTip($Timeout)

  ## BalloonTipClicked event
  Register-ObjectEvent -InputObject $toast -EventName BalloonTipClicked `
    -SourceIdentifier balloon_clicked

  if(Wait-Event -Timeout $eventTimeout -SourceIdentifier balloon_clicked)
  {
    Remove-Event -SourceIdentifier balloon_clicked
    Unregister-Event -SourceIdentifier balloon_clicked
    $toast.Dispose()
  }
  else
  {
    Unregister-Event -SourceIdentifier balloon_clicked
    $toast.Dispose()
  }

}

$comStr = "teatimer-exec $args"
$comStr = $comStr -Replace '(\-Title) (.*) (\-Text)','$1 "$2" $3'
$comStr = $comStr -Replace '(\-Text) (.*) (\-Timeout)','$1 "$2" $3'
$comStr = $comStr -Replace '(\-At) (.*) (\-Title)','$1 "$2" $3'
Write-Output $comStr
#sleep -seconds 3
Invoke-Expression $comStr
