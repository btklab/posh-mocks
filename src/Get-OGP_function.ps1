<#
.SYNOPSIS

Get-OGP - 指定したURIからサイトプレビュー用 Open Graph protocol（OGP）を取得する

標準入力、第一引数でUriを指定しない場合はクリップボードの値を使おうとする

拾うのは以下のmetadata:
  <meta property="og:title" content="Build software better, together">
  <meta property="og:url" content="https://github.com">
  <meta property="og:image" content="https://github.githubassets.com/images/modules/open_graph/github-octocat.png">
  <meta property="og:description" content="GitHub is where people build software. More than 94 million people use GitHub to discover, fork, and contribute to over 330 million projects.">
  <title>site_title</title>

-AllMetaDataで、すべてのメタデータを出力
-Cardで、BlogCardスタイルのhtmlリンク形式で出力
  (css不要)

-DownloadMetaImageオプションをつけると、
画像を~/Downloadsフォルダに格納し、かつ、600x600サイズに縮小する。
縮小せず画像取得だけ必要な場合は、併せて-NoShrinkオプションも追加。

タイトルは、以下の順で取得
  <meta property="og:title"... />
  <title>site_title</title>

説明は、以下の順でcontent="cont"を取得
  <meta property="og:description"... />
  <meta name="description"... />

-ImagePathOverwrite '/img/2022/' -Cardとすると、
Cardスタイルのhtmlリンクの中のimageファイルパスを任意のパスに変更できる。

-Markdownスイッチで、[label](uri)形式で出力
 thanks: goark/ml: Make Link with Markdown Format
 <https://github.com/goark/ml>


.PARAMETER Canonical
canonical uriを取得する

.PARAMETER Markdown
markdown形式のリンクを返す

[title](uri)

.PARAMETER Id
-Markdownスイッチと併用で別行リンクを返す

[title][key]
[key]: <uri>

-Id "" とすると：

[GitHub: Let’s build from here][]
[GitHub: Let’s build from here]: <https://github.com/>

.EXAMPLE
"https://github.com/" | Get-OGP | fl
curl https://github.com/
200 OK

description : GitHub is where over 94 million developers shape the future of software, together. Contribute to the open
               source community, manage your Git repositories, review code like a pro, track bugs and feat...
image       : https://github.githubassets.com/images/modules/site/social-cards/campaign-social.png
title       : GitHub: Let’s build from here
uri         : https://github.com/

.EXAMPLE
Get-OGP "https://github.com/" | fl
curl https://github.com/
200 OK

description : GitHub is where over 94 million developers shape the future of software, together. Contribute to the open
               source community, manage your Git repositories, review code like a pro, track bugs and feat...
image       : https://github.githubassets.com/images/modules/site/social-cards/campaign-social.png
title       : GitHub: Let’s build from here
uri         : https://github.com/

.EXAMPLE
Get-OGP "https://github.com/" -DownloadMetaImage | fl
curl https://github.com/
200 OK

description : GitHub is where over 94 million developers shape the future of software, together. Contribute to the open
               source community, manage your Git repositories, review code like a pro, track bugs and feat...
image       : https://github.githubassets.com/images/modules/site/social-cards/campaign-social.png
title       : GitHub: Let’s build from here
uri         : https://github.com/
OutputImage : ~/Downloads/campaign-social_s.png

.EXAMPLE
"https://github.com/" | Get-OGP -AllMetaData
curl https://github.com/
200 OK
<meta charset="utf-8">
<meta name="viewport" content="width=device-width">
<meta name="description" content="GitHub is where over 94 million developers shape the future of software, together. Contribute to the open source community, manage your Git repositories, review code like a pro, track bugs and features, power your CI/CD and DevOps workflows, and secure code before you commit it.">
<meta property="og:image" content="https://github.githubassets.com/images/modules/site/social-cards/campaign-social.png" />
<meta property="og:image:alt" content="GitHub is where over 94 million developers shape the future of software, together. Contribute to the open source community, manage your Git repositories, review code like a pro, track bugs and feat..." />
<meta property="og:site_name" content="GitHub" />
<meta property="og:type" content="object" />
<meta property="og:title" content="GitHub: Let’s build from here" />
<meta property="og:url" content="https://github.com/" />
<meta property="og:description" content="GitHub is where over 94 million developers shape the future of software, together. Contribute to the open source community, manage your Git repositories, review code like a pro, track bugs and feat..." />
<title>GitHub: Let’s build from here · GitHub</title>

.EXAMPLE
Get-OGP "https://github.com/" -DownloadMetaImage -Image ~/Downloads/hoge.png | fl
curl https://github.com/
200 OK

description : GitHub is where over 94 million developers shape the future of software, together. Contribute to the open
               source community, manage your Git repositories, review code like a pro, track bugs and feat...
title       : GitHub: Let’s build from here
uri         : https://github.com/
image       : ~/Downloads/hoge.png
OutputImage : ~/Downloads/campaign-social_s.png

説明
============
-Image <image_file> で、imageをローカルの画像ファイルと差し替え。
かつ、差し替えたローカル画像ファイルを600x600にシュリンク。

.EXAMPLE
Get-OGP "https://github.com/"-DownloadMetaImage -Card | fl
curl https://github.com/
200 OK
<!-- blog card -->
<a href="https://github.com/" style="margin: 50px;padding: 12px;border: solid thin slategray;display: flex;text-decoration: none;color: inherit;" onMouseOver="this.style.opacity='0.9'" target="_blank">
    <div style="flex-shrink: 0;">
        <img src="~/Downloads/campaign-social_s.png" alt="" width="100" />
    </div>
    <div style="margin-left: 10px;">
        <h2 style="margin: 0;padding-bottom: 13px;border: none;font-size: 16px;">
            GitHub: Let’s build from here
        </h2>
        <p style="margin: 0;font-size: 13px;word-break: break-word;display: -webkit-box;-webkit-box-orient: vertical;-webkit-line-clamp: 3;overflow: hidden;">
            GitHub is where over 94 million developers shape the future of software, together. Contribute to the open source community, manage your Git repositories, review code like a pro, track bugs and feat...
        </p>
    </div>
</a>

説明
============
-Cardで、Card形式

.EXAMPLE
Get-OGP "https://www.maff.go.jp/j/shokusan/sdgs/" -ImagePathOverwrite '/img/2022/' -Card
curl https://www.maff.go.jp/j/shokusan/sdgs/
200 OK
<!-- blog card -->
<a href="https://www.maff.go.jp/j/shokusan/sdgs/" style="margin: 50px;padding: 12px;border: solid thin slategray;display: flex;text-decoration: none;color: inherit;" onMouseOver="this.style.opacity='0.9'">
    <div style="flex-shrink: 0;">
        <img src="/img/2022/a_s.png" alt="" width="100" />
    </div>
    <div style="margin-left: 10px;">
        <h2 style="margin: 0;padding-bottom: 13px;border: none;font-size: 16px;">
            SDGs×食品産業：農林水産省
        </h2>
        <p style="margin: 0;font-size: 13px;word-break: break-word;display: -webkit-box;-webkit-box-orient: vertical;-webkit-line-clamp: 3;overflow: hidden;">
            農林水産省・新事業・食品産業部では、食品産業によるSDGs関連の取組を、実例とともに国民にわかりやすく発信し、我が国の食品産業が社会問題の解決に貢献していることを伝えるために特設サイトを開設しました。
        </p>
    </div>
</a>

説明
============
-Card -ImagePathOverwrite <path> で、Card形式に埋め込む画像の
ディレクトリパスを<path>に置換。
出力したデータを書き換える必要がなくなるが、事前に指定する必要があるので、
手間はとくに変わらない。ただ、画像パスがどこに埋め込まれたかを目視で
探さなくて済む。

.EXAMPLE
Get-OGP "https://github.com/" -Canonical -Markdown | Set-Clipboard
curl https://github.com/
200 OK
[GitHub: Let’s build from here](https://github.com/)

説明
============
-Canonicalスイッチでcanonical uriの取得を試みる。
見つからなければ、入力されたuriをそのまま出力


.EXAMPLE
Get-OGP "https://github.com/" -Canonical -Markdown -id ""
curl https://github.com/
200 OK
[GitHub: Let’s build from here][]
[GitHub: Let’s build from here]: <https://github.com/>

.EXAMPLE
Get-OGP "https://github.com/" -Canonical -Html
curl https://github.com/
200 OK
<a href="https://github.com/">GitHub: Let’s build from here</a>

#>
function Get-OGP {

    Param(
        [Parameter(Position=0,Mandatory=$False,
            ValueFromPipeline=$True)]
        [Alias('u')]
        [string] $Uri,

        [Parameter(Mandatory=$False)]
        [Alias('b')]
        [switch] $Card,

        [Parameter(Mandatory=$False)]
        [Alias('m')]
        [switch] $Markdown,

        [Parameter(Mandatory=$False)]
        [Alias('i')]
        [string] $Id = "@not@set@",

        [Parameter(Mandatory=$False)]
        [Alias('h')]
        [switch] $Html,

        [Parameter(Mandatory=$False)]
        [Alias('c')]
        [switch] $Clip,

        [Parameter(Mandatory=$False)]
        [switch] $DownloadMetaImage,

        [Parameter(Mandatory=$False)]
        [string] $Method = "GET",

        [Parameter(Mandatory=$False)]
        [string] $UserAgent = "bot",

        [Parameter(Mandatory=$False)]
        [string] $Image,

        [Parameter(Mandatory=$False)]
        [string] $ImagePathOverwrite,

        [Parameter(Mandatory=$False)]
        [string] $Title,

        [Parameter(Mandatory=$False)]
        [string] $Description,

        [Parameter(Mandatory=$False)]
        [switch] $AllMetaData,

        [Parameter(Mandatory=$False)]
        [string] $ShrinkSize = '600x600',

        [Parameter(Mandatory=$False)]
        [switch] $UriEncode,

        [Parameter(Mandatory=$False)]
        [switch] $Canonical,

        [Parameter(Mandatory=$False)]
        [switch] $NoShrink
    )
    # private function
    # https://www.amazon.co.jp/82%B9/dp/4840107505
    function Parse-AmazonURI ([string]$amUri){
        
        if ($amUri -match "/dp/(?<asin>[^/]+)"){
            $dp = $Matches.asin
            return "https://www.amazon.co.jp/dp/$dp"
        }
        if ($amUri -match "/gp/product/(?<asin>[^/]+)"){
            $dp = $Matches.asin
            return "https://www.amazon.co.jp/dp/$dp"
        }
        if ($amUri -match "/exec/obidos/asin/(?<asin>[^/]+)"){
            $dp = $Matches.asin
            return "https://www.amazon.co.jp/dp/$dp"
        }
        if ($amUri -match "/o/ASIN/(?<asin>[^/]+)"){
            $dp = $Matches.asin
            return "https://www.amazon.co.jp/dp/$dp"
        }
        return $amUri
    }
    # main
    if (-not $Uri){ $Uri = Get-ClipBoard }
    if ($Uri -match '^https://www\.amazon\.co\.jp/'){
        $Uri = Parse-AmazonURI $Uri
    }
    Write-Host "curl $Uri" -ForegroundColor Yellow

    try {
        $res = Invoke-WebRequest `
                -Uri "$Uri" `
                -Method "$Method" `
                -UserAgent "$UserAgent"

        $debStr = $res.StatusCode.ToString() + " " + $res.StatusDescription 
        Write-Host $debStr -ForegroundColor Yellow

        [regex] $reg      = '<meta [^>]+>'
        [regex] $regTitle = '<title>[^<]+</title>'
        [regex] $regLink  = '<link rel="canonical" [^<]+/>'

        [string[]] $metaAry = @()
        $metaAry = $res.RawContent | ForEach-Object {
            $reg.Matches($_) `
                | foreach { Write-Output $_.Value }
            $regTitle.Matches($_) `
                | foreach { Write-Output $_.Value }
            $regLink.Matches($_) `
                | foreach { Write-Output $_.Value }
            }
        if ($metaAry -eq $Null ){
            Write-Error "No meta data in $Uri" -ErrorAction Stop
        }
        if ($AllMetaData){
            $metaAry | ForEach-Object { Write-Output $_ }
            return
        }
        $o = [ordered]@{}
        [string] $innerTitle   = ""
        [string] $innerUri     = ""
        [string] $canonicalUri = ""
        [string] $innerImage   = ""
        [string] $innerDesc    = ""
        [bool] $imageFlag   = $False
        $metaAry | ForEach-Object {
            [string] $metaTag = [string] $_
            [string] $prop = $metaTag -replace '^<meta [^<]*property="(?<property>[^"]*)".*$', '$1'
            [string] $cont = $metaTag -replace '^<meta [^<]*content="(?<content>[^"]*)".*$', '$1'
            [string] $name = $metaTag -replace '^<meta [^<]*name="(?<name>[^"]*)".*$', '$1'
            [string] $link = $metaTag -replace '^<link rel="canonical" [^<]*(href="[^"]*").*$', '$1'
            if (($name -eq "description") -and ($content -notmatch '^<')){
                    $innerDesc = $cont
                    $o["description"] = $innerDesc
            } elseif (($name -eq "title") -and ($content -notmatch '^<')){
                    $innerTitle = $cont
                    $o["title"] = $innerTitle
            } else {
                #<meta property="og:title" content="Yahoo! JAPAN"/>
                #<meta property="og:url"   content="https://github.com//"/>
                #<meta property="og:image" content="https://s.yimg.jp/images/top/ogp/fb_y_1500px.png"/>
                if (($prop -match 'og:title$') -or ($name -match 'og:title$')){
                    $innerTitle = "$cont"
                    if ($o["title"] -eq $Null){
                        $o["title"] = "$cont"
                    }
                }
                if (($prop -match 'og:url$') -or ($name -match 'og:url$')){
                    $innerUri = "$cont"
                    $o["uri"] = "$cont"
                }
                if (($prop -match 'og:description$') -or ($name -match 'pg:description$')){
                    $innerDesc = "$cont"
                    $o["description"] = "$cont"
                }
                if (($prop -match 'og:image$') -or ($name -match 'og:image$')){
                    $innerImage = "$cont"
                    if ($o["image"] -eq $Null){
                        $o["image"] = "$cont"
                    }
                }
                if ($link -match '^href='){
                    $canonicalUri = $link -replace 'href="([^"]+)"','$1'
                }
                # download image
                if (($DownloadMetaImage) -and (($prop -match 'og:image$') -or ($name -match 'og:image$'))){
                    $imageFlag = $True
                    [string] $imageUri = "$cont"
                    [string] $imageFileName = Split-Path -Path "$imageUri" -Leaf
                }
            }
            $prop = ''
            $cont = ''
            $name = ''
            $link = ''
        }
        # if title -eq empty
        if ($innerTitle -eq ''){
            $metaAry | ForEach-Object {
                [string] $metaTag = [string] $_
                if ($metaTag -match '^<title'){
                    [string] $innerTitle = $metaTag -replace '^<title\>([^<]+)</title>.*$', '$1'
                    if ($innerTitle -notmatch '^<'){
                        $o["title"] = "$innerTitle"
                    }
                }
            }
        }
        # set url
        if (($Canonical) -and ($canonicalUri -ne '')){
            $innerUri = "$canonicalUri"
            $o["uri"] = "$canonicalUri"
        } elseif ($innerUri -eq ''){
            $innerUri = "$Uri"
            $o["uri"] = "$Uri"
        }
        if ($Title){
            $o["title"] = "$Title"
        }
        if ($Description){
            $o["description"] = "$Description"
        }
        # execute download image
        if ($Image){
            if($isWindows){
                $o["image"] = "$(($Image).Replace('\','/'))"
            }else{
                $o["image"] = "$Image"
            }
            [string] $dlDirName = "${HOME}/Downloads"
            $dlPath = (Resolve-Path -LiteralPath "$Image").Path
            $oFile = $dlPath -replace '(\.[^.]+)$','_s$1'
            if (-not $NoShrink){
                ConvImage -inputFile "$dlPath" -outputFile "$oFile" -resize "$ShrinkSize"
                if ($isWindows){
                    $o["OutputImage"] = "$(($oFile).Replace('\','/'))"
                }else{
                    $o["OutputImage"] = "$oFile"
                }
            } else {
                if ($isWindows){
                    $o["OutputImage"] = "$(($dlPath).Replace('\','/'))"
                }else{
                    $o["OutputImage"] = "$dlPath"
                }
            }
        }elseif ($imageFlag){
            [string] $dlDirName = "${HOME}/Downloads"
            [string] $dlPath = Join-Path "$dlDirName" "$imageFileName"
            try {
                Invoke-WebRequest -Uri "$imageUri" -OutFile "$dlPath"
                $oFile = $dlPath -replace '(\.[^.]+)$','_s$1'
                if (-not $NoShrink){
                    ConvImage -inputFile "$dlPath" -outputFile "$oFile" -resize "$ShrinkSize"
                    $o["OutputImage"] = "$oFile"
                } else {
                    $o["OutputImage"] = "$dlPath"
                }
            } catch {
                # status code
                Write-Host "$_.Exception.Response.StatusCode.value__" -ForegroundColor Red
            }
        }
        if($Card){
            $oHtml = @'
<!-- blog card -->
<a href="{{- .Params.url -}}" style="margin: 50px;padding: 12px;border: solid thin slategray;display: flex;text-decoration: none;color: inherit;" onMouseOver="this.style.opacity='0.9'" target="_blank">
    <div style="flex-shrink: 0;">
        <img src="{{- .Params.image -}}" alt="" width="100" />
    </div>
    <div style="margin-left: 10px;">
        <h2 style="margin: 0;padding-bottom: 13px;border: none;font-size: 16px;">
            {{- .Params.title -}}
        </h2>
        <p style="margin: 0;font-size: 13px;word-break: break-word;display: -webkit-box;-webkit-box-orient: vertical;-webkit-line-clamp: 3;overflow: hidden;">
            {{- .Params.description | plainify | safeHTML -}}
        </p>
    </div>
</a>
'@
            if ($innerTitle -notmatch "^<"){
                if($UriEncode){
                    [string] $uTitle = [uri]::EscapeUriString("$innerTitle")
                }else{
                    [string] $uTitle = "$innerTitle"
                }
                $oHtml = $oHtml.Replace('{{- .Params.title -}}', "$uTitle")
            }
            if ($innerUri -ne ""){
                if($UriEncode){
                    [string] $uUri = [uri]::EscapeUriString("$innerUri")
                }else{
                    [string] $uUri = "$innerUri"
                }
                $oHtml = $oHtml.Replace('{{- .Params.url -}}', "$uUri")
            }
            if ($innerDesc -ne ""){
                if($UriEncode){
                    [string] $uDesc = [uri]::EscapeUriString("$innerDesc")
                }else{
                    [string] $uDesc ="$innerDesc"
                }
                $oHtml = $oHtml.Replace('{{- .Params.description | plainify | safeHTML -}}',"$uDesc")
            }
            if ($Image){
                [string] $uImage = $o["OutputImage"]
                if($ImagePathOverwrite){
                    $fImage = Split-Path -Path "$uImage" -Leaf
                    $uImage = Join-Path "$ImagePathOverwrite" "$fImage"
                    if($isWindows){$uImage = $uImage.Replace('\','/')}
                }else{
                    if($isWindows){
                        $uImage = $uImage.Replace('/','\').Replace("${HOME}","~").Replace('\','/')
                    }else{
                        $uImage = $uImage.Replace("${HOME}","~")
                    }
                }
                $oHtml = $oHtml.Replace('{{- .Params.image -}}',"$uImage")
            } elseif ($imageFlag){
                [string] $uImage = $o["OutputImage"]
                if($ImagePathOverwrite){
                    $fImage = Split-Path -Path "$uImage" -Leaf
                    $uImage = Join-Path "$ImagePathOverwrite" "$fImage"
                    if($isWindows){$uImage = $uImage.Replace('\','/')}
                }
                $oHtml = $oHtml.Replace('{{- .Params.image -}}',"$uImage")
            }
            if ($Clip){
                $oHtml | Set-ClipBoard
                return
            } else {
                return $oHtml
            }
        }elseif($Markdown){
            # markdown href output
            if($Id -eq '@not@set@'){
                [string]$oMarkdown = "[$innerTitle]($innerUri)"
            } else {
                [string[]] $oMarkdown = @()
                $oMarkdown += "[$innerTitle][$Id]"
                if ($Id -eq ''){
                    $oMarkdown += "[$innerTitle]: <$innerUri>"
                } else {
                    $oMarkdown += "[$Id]: <$innerUri>"
                }
            }
            if ($Clip){
                $oMarkdown | Set-ClipBoard
                return
            } else {
                return $oMarkdown
            }
        }elseif($Html){
            [string] $oHref = "<a href=""$innerUri"">$innerTitle</a>"
            if ($Clip){
                $oHref | Set-ClipBoard
                return
            } else {
                return $oHref
            }
        }else{
            if ($Clip){
                [pscustomobject] $o `
                    | ConvertTo-Csv -NoTypeInformation `
                    | Set-ClipBoard
                return
            } else {
                # output as object
                return [pscustomobject] $o
            }            
        }
    } catch {
        # status code
        Write-Host "$_.Exception.Response.StatusCode.value__" -ForegroundColor Red
        # response body
        #$stream = $_.Exception.Response.GetResponseStream()
        #$reader = New-Object System.IO.StreamReader $stream
        #$reader.BaseStream.Position = 0
        #$reader.DiscardBufferedData()
        #Write-Host $reader.ReadToEnd()
        #$reader.Close()  # Closeは$readerと$streamの一方を呼び出せばよい。両方呼び出しても害はない
        #$stream.Close()
    }
}
