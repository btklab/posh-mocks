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
<meta name="request-id" content="FBC2:1408:1472DE:19F50A:63B2D937" data-pjax-transient="true"/>
<meta name="html-safe-nonce" content="afc9a261a365d3df147ba51e8faf45e4b2d6a6df90d1323d509b4ac53dd65d08" data-pjax-transient="true"/>
<meta name="visitor-payload" content="eyJyZWZlcnJlciI6IiIsInJlcXVlc3RfaWQiOiJGQkMyOjE0MDg6MTQ3MkRFOjE5RjUwQTo2M0IyRDkzNyIsInZpc2l0b3JfaWQiOiI2OTQzMjMzNTYyNDcxNzQ5OTQzIiwicmVnaW9uX2VkZ2UiOiJqYXBhbmVhc3QiLCJyZWdpb25fcmVuZGVyIjoiamFwYW5lYXN0In0=" data-pjax-transient="true"/>
<meta name="visitor-hmac" content="ebbab191bc01b35061ad0f083d7518ee1d36203ae30c82bd3a394c2a801c2149" data-pjax-transient="true"/>
<meta name="page-subject" content="GitHub">
<meta name="github-keyboard-shortcuts" content="dashboards" data-turbo-transient="true" />
<meta name="selected-link" value="/" data-turbo-transient>
<meta name="google-site-verification" content="c1kuD-K2HIVF635lypcsWPoD4kilo5-jA_wBFyT4uMY">
<meta name="google-site-verification" content="KT5gs8h0wvaagLKAVWq8bbeNwnZZK1r1XQysX3xurLU">
<meta name="google-site-verification" content="ZzhVyEFwb7w3e0-uOTltm8Jsck2F5StVihD0exw2fsA">
<meta name="google-site-verification" content="GXs5KoUUkNCoaAZn7wPN-t01Pywp9M3sEjnt_3_ZWPc">
<meta name="google-site-verification" content="Apib7-x98H0j5cPqHWwSMm6dNU4GmODRoqxLiDzdx9I">
<meta name="octolytics-url" content="https://collector.github.com/github/collect" />
<meta name="user-login" content="">
<meta name="viewport" content="width=device-width">
<meta name="description" content="GitHub is where over 94 million developers shape the future of software, together. Contribute to the open source community, manage your Git repositories, review code like a pro, track bugs and features, power your CI/CD and DevOps workflows, and secure code before you commit it.">
<meta property="fb:app_id" content="1401488693436528">
<meta name="apple-itunes-app" content="app-id=1477376905" />
<meta name="twitter:image:src" content="https://github.githubassets.com/images/modules/site/social-cards/campaign-social.png" />
<meta name="twitter:site" content="@github" />
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content="GitHub: Let’s build from here" />
<meta name="twitter:description" content="GitHub is where over 94 million developers shape the future of software, together. Contribute to the open source community, manage your Git repositories, review code like a pro, track bugs and feat..." />
<meta property="og:image" content="https://github.githubassets.com/images/modules/site/social-cards/campaign-social.png" />
<meta property="og:image:alt" content="GitHub is where over 94 million developers shape the future of software, together. Contribute to the open source community, manage your Git repositories, review code like a pro, track bugs and feat..." />
<meta property="og:site_name" content="GitHub" />
<meta property="og:type" content="object" />
<meta property="og:title" content="GitHub: Let’s build from here" />
<meta property="og:url" content="https://github.com/" />
<meta property="og:description" content="GitHub is where over 94 million developers shape the future of software, together. Contribute to the open source community, manage your Git repositories, review code like a pro, track bugs and feat..." />
<meta name="hostname" content="github.com">
<meta name="expected-hostname" content="github.com">
<meta name="enabled-features" content="TURBO_EXPERIMENT_RISKY,IMAGE_METRIC_TRACKING,GEOJSON_AZURE_MAPS">
<meta http-equiv="x-pjax-version" content="d723c77796b63329602515be9802022933c67f9314b79877a2818a8018e9268c" data-turbo-track="reload">
<meta http-equiv="x-pjax-csp-version" content="3f846e6544a1902c66451867aeeb5075d5751f213c39d9f38b95724bb97d5045" data-turbo-track="reload">
<meta http-equiv="x-pjax-css-version" content="9556cd062552d1fe04e933d9cbb8b03bdc5aae786bc1081caa9d8885a385528b" data-turbo-track="reload">
<meta http-equiv="x-pjax-js-version" content="b2193b29d11bb50a2ff37e86140fee0b2b1ab807f5b1bece10b01657929d6481" data-turbo-track="reload">
<meta name="turbo-cache-control" content="no-preview" data-turbo-transient="">
<meta property="og:image:type" content="image/png">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta name="is_logged_out_page" content="true">
<meta name="turbo-body-classes" content="logged-out env-production page-responsive header-overlay home-campaign">
<meta name="browser-stats-url" content="https://api.github.com/_private/browser/stats">
<meta name="browser-errors-url" content="https://api.github.com/_private/browser/errors">
<meta name="browser-optimizely-client-errors-url" content="https://api.github.com/_private/browser/optimizely_client/errors">
<meta name="theme-color" content="#1e2327">
<title>GitHub: Let’s build from here · GitHub</title>
<title>Python</title>
<title>JavaScript</title>
<title>Go</title>

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
        [boolean] $imageFlag   = $False
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
