<#
.SYNOPSIS

say - 標準入力からの文字列を音声出力に変換する

Get-Clipboard | say -JA
clipwatch -Action {Get-Clipboard | say -EN -Speed 2}


動作としては：
  音声ファイル出力（-ToWavFile指定）は同期的処理 $synth.Speak($_)
  スピーカ出力の場合は非同期処理 $synth.SpeakAsync($line) | Out-Null


thanks:
  PowerShellでSpeechSynthesizerを使う @ssashir06 -- Qiita
  https://qiita.com/ssashir06/items/35910394a1137cb19a63

  Microsoftリファレンス SpeechSynthesizer クラス
  https://learn.microsoft.com/ja-jp/dotnet/api/system.speech.synthesis.speechsynthesizer?view=netframework-4.8

.LINK
    clipwatch


.PARAMETER ListUpVoices
インストールされている音声の一覧を返す。
好きなものを-SelectVoice <str>で指定する

.PARAMETER SelectVoice
音声を選択肢の中から選択する

.PARAMETER CustomVoice
-SelectVoiceの選択肢にない音声を
自由に指定する

.PARAMETER EN
英語音声 "Microsoft Zira Deskto" を指定

.PARAMETER JA
日本語音声 "Microsoft Haruka Desktop" を指定

.PARAMETER Speed
速度を-10から10の範囲で指定。
デフォルトで0

.PARAMETER Volume
音量を1から10の範囲で指定。
デフォルトで100

.PARAMETER ToWavFile
音声を.wav形式のファイルに出力
同期的処理 $synth.Speak($_)

.EXAMPLE
"Today's date is $((Get-Date).ToShortDateString())" | say -EN

.EXAMPLE
"Today's date is $((Get-Date).ToShortDateString())" | say -JA

.EXAMPLE
"Today's date is $((Get-Date).ToShortDateString())" | say -EN -ToWavFile a.wav | ii

    Directory: C:\Users\btklab\cms\drafts

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a---          2022/10/01    13:48         169122 a.wav

.EXAMPLE
clipwatch -Action {Get-Clipboard | say -EN -Speed 2}

ClipBoard Changed...

#>
function say {
    Param(
        [Parameter(Mandatory=$False)]
        [switch] $ListUpVoices,

        [Parameter(Mandatory=$False)]
        [ValidateSet(
            "Microsoft David Desktop",
            "Microsoft Zira Desktop",
            "Microsoft Haruka Desktop")]
        [string] $SelectVoice,

        [Parameter(Mandatory=$False)]
        [string] $CustomVoice,

        [Parameter(Mandatory=$False)]
        [switch] $EN,

        [Parameter(Mandatory=$False)]
        [switch] $JA,

        [Parameter(Mandatory=$False)]
        [ValidateRange(1,100)]
        [int] $Volume = 100,

        [Parameter(Mandatory=$False)]
        [ValidateRange(-10,10)]
        [int] $Speed = 0,

        [Parameter(Mandatory=$False)]
        [string] $ToWavFile,

        [parameter(ValueFromPipeline=$True)]
        [string[]] $Text
    )

    begin {
        # load assembly
        Add-Type -AssemblyName System.Speech
        $synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
        # list installed voices
        if ($ListUpVoices){
            try {
                $synth.GetInstalledVoices() `
                    | Select-Object {$_.VoiceInfo.Name}
            } catch {
                $synth.SetOutputToDefaultAudioDevice()
                $synth.Dispose()
            }
            return
        }
        # private function
        function GetFileFullPath ([string]$fPath){
            # get current directory path
            $curDir = (Convert-Path -LiteralPath ".")
            # if absolute path or not
            if(($fPath -notmatch '^[A-Z]:\\.*') -and ($fPath -notmatch '^\\\\')){
                [string] $oPath = Join-Path "$curDir" "$fPath"
            } else {
                [string] $oPath = "$fPath"
            }
            return $oPath
        }
        # set opt
        try {
            # select voice
            if ($CustomVoice) {
                $synth.SelectVoice("$CustomVoice")
            } elseif ($SelectVoice){
                $synth.SelectVoice("$SelectVoice")
            } elseif ($EN){
                $synth.SelectVoice("Microsoft Zira Desktop")
            } elseif ($JA){
                $synth.SelectVoice("Microsoft Haruka Desktop")
            }
            # set volume
            $synth.Volume = $Volume
            # set speed (rate)
            $synth.Rate = $Speed
            # save to .wav file
            if ($ToWavFile){
                [string] $wavFile = GetFileFullPath "$ToWavFile"
                $synth.SetOutputToWaveFile("$wavFile")
            }
        } catch {
            $synth.SetOutputToDefaultAudioDevice()
            $synth.Dispose()
        }
        #$synth

    }
    process {
        foreach ($line in $Text){
            if ($ToWavFile){
                try {
                    $synth.Speak($line)
                } catch {
                    $synth.SetOutputToDefaultAudioDevice()
                    $synth.Dispose()
                }
            } else {
                $synth.SpeakAsync($line) | Out-Null
            }
        }
    }
    end {
        if ($ToWavFile){
            # clean-up
            $synth.SetOutputToDefaultAudioDevice()
            $synth.Dispose()
            Get-Item -LiteralPath "$wavFile"
        }
    }
}
