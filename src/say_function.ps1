<#
.SYNOPSIS
    say - Speech Synthesizer

    Speaks input string.
    (Convert strings to speech)
    
    Usage:
        Get-Clipboard | say -JA
        clipwatch -Action {Get-Clipboard | say -EN -Speed 2}
    
    Implementation:
        Audio file output (specified -ToWavFile) is synchronous
        processing like "$synth.Speak($readLine)".

        Speaker output is asynchronous processing like
        "$synth.SpeakAsync($readLine) > $Null"

    thanks:
        PowerShell SpeechSynthesizer @ssashir06 - Qiita
        https://qiita.com/ssashir06/items/35910394a1137cb19a63

        Microsoft reference SpeechSynthesizer class
        https://learn.microsoft.com/ja-jp/dotnet/api/system.speech.synthesis.speechsynthesizer

.LINK
    clipwatch


.PARAMETER ListUpVoices
    Return a list of installed voices.
    Specify with -SelectVoice <str>

.PARAMETER SelectVoice
    Select voice from list.

.PARAMETER CustomVoice
    Specify voice that are not in the -SelectVoice

.PARAMETER EN
    Specify english voice "Microsoft Zira Deskto"

.PARAMETER JA
    Specify japanese voice "Microsoft Haruka Desktop"

.PARAMETER Speed

.PARAMETER Volume
    Specify the reading speed in the range of -10 to 10.
    0 by Default

.PARAMETER ToWavFile
    Output to .wav file with synchronous processing.

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
                $synth.SpeakAsync($line) > $Null
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
