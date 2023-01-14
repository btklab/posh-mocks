<#
.SYNOPSIS

linkcheck - Broken link checker

引数に指定したuriのリンク切れをチェックする

reference:
  - Invoke-WebRequest
    https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-7.2

-Headerオプションで、
1列目をfilename、2列目をhrefとして認識する。
出力にも、filenameをヘッダに付与する。
ただし、filenameに半角スペースを含まないこと。


関連: lincextract, linkcheck2


.PARAMETER Header
1列目をfilename、2列目をhrefとして認識し、
出力にも、filenameをヘッダに付与する

出力例:
[ng] index.html www.microsoft.com/unkownhost

Headerオプションを指定しない場合：
[ng] www.microsoft.com/unkownhost


.PARAMETER VerboseOutput
エラー如何にかかわらず、すべての入力に
[ng]または[ok]タグを付与して出力する

出力の最後に、Broken linksのリストを返す。


.PARAMETER WaitSeconds
1リンク検証ごとのスリープ時間（秒）を指定


.EXAMPLE
cat uri-list.txt
https://www.example.com/
www.microsoft.com/unkownhost

linkcheck www.microsoft.com/unkownhost
Detect broken links.
[ng] www.microsoft.com/unkownhost

.EXAMPLE
cat uri-list.txt | linkcheck
Detect broken links.
[ng] www.microsoft.com/unkownhost

.EXAMPLE
linkcheck (cat uri-list.txt) -WaitSeconds 1
Detect broken links.
[ng] www.microsoft.com/unkownhost

.EXAMPLE
linkcheck (cat uri-list.txt) -VerboseOutput
[ok] https://www.example.com/
[ng] www.microsoft.com/unkownhost
Detect broken links.
[ng] www.microsoft.com/unkownhost

.EXAMPLE
$uAry = @("https://www.example.com/","www.microsoft.com/unkownhost")
linkcheck $uAry -VerboseOutput

[ok] https://www.example.com/
[ng] www.microsoft.com/unkownhost
Detect broken links.
[ng] www.microsoft.com/unkownhost

.EXAMPLE
cat uri-list.txt
a.html https://www.example.com/
a.html www.microsoft.com/unkownhost

cat uri-list.txt | linkcheck
Detect broken links.
[ng] a.html https://www.example.com/
[ng] a.html www.microsoft.com/unkownhost
#>
function linkcheck {
    Param(
        [parameter(
            Mandatory=$True,
            Position=0,
            ValueFromPipeline=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]] $Uris,

        [parameter(Mandatory=$False)]
        [switch] $Header,
        
        [parameter(Mandatory=$False)]
        [int] $WaitSeconds = 1,
        
        [parameter(Mandatory=$False)]
        [switch] $VerboseOutput
    )

    # set uri
    if($input){
        [string[]] $src = $input
    } else {
        [string[]] $src = $Uris
    }
    # set variables
    [string[]] $errAry = @()
    # main
    foreach($line in $src){
        if($Header){
            [string[]] $splitLine = $line.split(' ', 2)
            if($splitLine.Count -ne 2){
                Write-Error "Invalid line detected: $line" -ErrorAction Stop
            }
            [string] $uri  = $splitLine[0]
            [string] $href = $splitLine[1]
        } else {
            [string] $uri  = ''
            [string] $href = $line
        }
        # ad hock countermeasure
        # For some reason, the variable "$uri" may be $null
        # from pipline input
        if ($uri -ne $null) {
            try {
                $origErrActPref = $ErrorActionPreference
                $ErrorActionPreference = "SilentlyContinue"
                $Response = Invoke-WebRequest -Uri "$href"
                $ErrorActionPreference = $origErrActPref
                # This will only execute if the Invoke-WebRequest is successful.
                $StatusCode = $Response.StatusCode
                [string] $msg = "$uri $href"
                [string] $msg = "[ok] " + $msg.trim()
                if($VerboseOutput){Write-Host $msg -ForegroundColor Green}
            } catch {
                $StatusCode = $_.Exception.Response.StatusCode.value__
                [string] $msg = "$uri $href"
                [string] $msg = "[ng] " + $msg.trim()
                if($VerboseOutput){Write-Host $msg -ForegroundColor Yellow}
                $errAry += ,$msg
            }
            Start-Sleep -Seconds $WaitSeconds
        }
    }
    ## output error
    # ad hock countermeasure
    if ($uri -ne $null){
        if ($errAry){
            if ($Header){
                Write-Output "Detect broken links in $uri"
            } else {
                Write-Output "Detect broken links."
            }
            #Write-Output "----"
            foreach($e in $errAry){
                Write-Output "$e"
            }
        } else {
            if ($Header){
                Write-Output "No broken links in $uri"
            } else {
                Write-Output "No broken links."
            }
        }
    }
}
