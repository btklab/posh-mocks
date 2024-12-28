<#
.SYNOPSIS
    Get-OGP - Make Link with markdown format

    Get meta-OGP tag from uri and format markdown href.

    If Uri is not specified in the args or pipline input,
    it tries to use the value from the clipboard.

    Pick up the following metadata:
      <meta property="og:title" content="Build software better, together">
      <meta property="og:url" content="https://github.com">
      <meta property="og:image" content="https://github.githubassets.com/images/modules/open_graph/github-octocat.png">
      <meta property="og:description" content="GitHub is where people build software. More than 94 million people use GitHub to discover, fork, and contribute to over 330 million projects.">
      <title>site_title</title>

    -AllMetaData : output all metadata
    -Card: output in BlogCard style html link (no css required)

    -DownloadMetaImage : Download image in the "~/Downloads" and
    resize image to 600x600px. If you only need to acquire
    images without shrinking, add "-NoShrink" option as well.

    Title is retrieved in the following order:
      <meta property="og:title"... />
      <title>site_title</title>

    Description is obtained in the following order:
      <meta property="og:description"... />
      <meta name="description"... />

    -ImagePathOverwrite '/img/2022/' -Card would change
    the image file path in the card style html link to
    any path.

    -Markdown switch to output in [label](uri) format.
        thanks: goark/ml: Make Link with Markdown Format
        <https://github.com/goark/ml>

    -Dokuwiki switch to output in [[uri|title]] format.

.LINK
    Get-OGP (ml), Get-ClipboardAlternative (gclipa)
    clip2file, clip2push, clip2shortcut, clip2img, clip2txt, clip2normalize

.PARAMETER Canonical
    get canonical uri

.PARAMETER Markdown
    Return links in markdown format
    like: [title](uri)

.PARAMETER Dokuwiki
    Return links in dokuwiki format
    like: [[uri|title]]

.PARAMETER Cite
    Wrap Markdown and Html output in "<cite>" tag

.PARAMETER Id
    Returns a separate line link when used in
    conjunction with the -Markdown switch

      [title][key]
      [key]: <uri>

    If -Id "" and then:

      [GitHub: Let’s build from here][]
      [GitHub: Let’s build from here]: <https://github.com/>

.PARAMETER Raw
    Returns a link without parenthesis

      title
      uri

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

    Description
    ============
    -Image <image_file> to replace image with a local image file,
    and shrink the replaced local image file to 600x600px.

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

    Description
    ============
    Card format

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
                SDGs x maff
            </h2>
            <p style="margin: 0;font-size: 13px;word-break: break-word;display: -webkit-box;-webkit-box-orient: vertical;-webkit-line-clamp: 3;overflow: hidden;">
                description
            </p>
        </div>
    </a>

    Description
    ============
    -Card -ImagePathOverwrite <path> to replace the directory path of the
    image to be embedded in the Card format/

.EXAMPLE
    Get-OGP "https://github.com/" -Canonical -Markdown | Set-Clipboard
    curl https://github.com/
    200 OK
    [GitHub: Let’s build from here](https://github.com/)

    Description
    ============
    Attempt to retrieve the canonical uri with "-Canonical" switch.
    If not found canonical uri, output the input uri as is.

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
        [Alias('d')]
        [switch] $Dokuwiki,

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
        [switch] $Cite,

        [Parameter(Mandatory=$False)]
        [switch] $Raw,

        [Parameter(Mandatory=$False)]
        [switch] $NoShrink
    )
    # private function
    function Parse-AmazonURI ([string]$amUri){
        # Parse:
        # https://www.amazon.co.jp/82%B9/dp/4840107505
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
                # Parse:
                #  <meta property="og:title" content="Yahoo! JAPAN"/>
                #  <meta property="og:url"   content="https://github.com//"/>
                #  <meta property="og:image" content="https://s.yimg.jp/images/top/ogp/fb_y_1500px.png"/>
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
        } elseif ($imageFlag){
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
            } else {
                Write-Output $oHtml
            }
            return
        }
        if( $Markdown ){
            # markdown href output
            [string[]] $oMarkdown = @()
            if($Id -eq '@not@set@'){
                if ( $Cite ){
                    $oMarkdown += "<cite>[$innerTitle]($innerUri)</cite>"
                } else {
                    $oMarkdown += "[$innerTitle]($innerUri)"
                }
            } else {
                if ( $Cite ){
                    $oMarkdown += "<cite>[$innerTitle][$Id]</cite>"
                } else {
                    $oMarkdown += "[$innerTitle][$Id]"
                }
                if ($Id -eq ''){
                    $oMarkdown += "[$innerTitle]: <$innerUri>"
                } else {
                    $oMarkdown += "[$Id]: <$innerUri>"
                }
            }
            if ($Clip){
                $oMarkdown | Set-ClipBoard
            } else {
                Write-Output $oMarkdown
            }
            return
        }
        if( $Dokuwiki ){
            # markdown href output
            [string[]] $oDokuwiki = @()
            if ( $Cite ){
                $oDokuwiki += "<cite>[[$innerUri|$innerTitle]]</cite>"
            } else {
                $oDokuwiki += "[[$innerUri|$innerTitle]]"
            }
            if ($Clip){
                $oDokuwiki | Set-ClipBoard
            } else {
                Write-Output $oDokuwiki
            }
            return
        }
        if ( $Html ){
            if ( $Cite ){
                [string] $oHref = "<cite><a href=""$innerUri"">$innerTitle</a></cite>"
            } else {
                [string] $oHref = "<a href=""$innerUri"">$innerTitle</a>"
            }
            if ($Clip){
                $oHref | Set-ClipBoard
            } else {
                Write-Output $oHref
            }
            return
        }
        if ( $Raw ){
            # markdown href output
            [string[]] $oRaw = @()
            if ( $innerTitle -ne '' ){
                $oRaw += "$innerTitle"
                $oRaw += "$innerUri"
            } else {
                $oRaw += "$innerUri"
            }
            if ($Clip){
                $oRaw | Set-ClipBoard
            } else {
                Write-Output $oRaw
            }
            return
        }
        if ( $True ){
            if ($Clip){
                [pscustomobject] $o `
                    | ConvertTo-Csv -NoTypeInformation `
                    | Set-ClipBoard
            } else {
                # output as object
                [pscustomobject] $o
            }            
            return
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
        #$reader.Close()  # Close should call either $reader or $stream. no harm in calling both
        #$stream.Close()
    }
}
# set alias
[String] $tmpAliasName = "ml"
[String] $tmpCmdName   = "Get-OGP"
[String] $tmpCmdPath = Join-Path `
    -Path $PSScriptRoot `
    -ChildPath $($MyInvocation.MyCommand.Name) `
    | Resolve-Path -Relative
if ( $IsWindows ){ $tmpCmdPath = $tmpCmdPath.Replace('\' ,'/') }
# is alias already exists?
if ((Get-Command -Name $tmpAliasName -ErrorAction SilentlyContinue).Count -gt 0){
    try {
        if ( (Get-Command -Name $tmpAliasName).CommandType -eq "Alias" ){
            if ( (Get-Command -Name $tmpAliasName).ReferencedCommand.Name -eq $tmpCmdName ){
                Set-Alias -Name $tmpAliasName -Value $tmpCmdName -PassThru `
                    | ForEach-Object{
                        Write-Host "$($_.DisplayName)" -ForegroundColor Green
                    }
            } else {
                throw
            }
        } elseif ( "$((Get-Command -Name $tmpAliasName).Name)" -match '\.exe$') {
            Set-Alias -Name $tmpAliasName -Value $tmpCmdName -PassThru `
                | ForEach-Object{
                    Write-Host "$($_.DisplayName)" -ForegroundColor Green
                }
        } else {
            throw
        }
    } catch {
        Write-Error "Alias ""$tmpAliasName ($((Get-Command -Name $tmpAliasName).ReferencedCommand.Name))"" is already exists. Change alias needed. Please edit the script at the end of the file: ""$tmpCmdPath""" -ErrorAction Stop
    } finally {
        Remove-Variable -Name "tmpAliasName" -Force
        Remove-Variable -Name "tmpCmdName" -Force
    }
} else {
    Set-Alias -Name $tmpAliasName -Value $tmpCmdName -PassThru `
        | ForEach-Object {
            Write-Host "$($_.DisplayName)" -ForegroundColor Green
        }
    Remove-Variable -Name "tmpAliasName" -Force
    Remove-Variable -Name "tmpCmdName" -Force
}

