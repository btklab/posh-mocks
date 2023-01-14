<#
.Synopsis

ConvImage - Image rotation, flipping, scaling

   画像の回転、リサイズ、形式を変換する。
   画像の形式変換は入出力に指定するファイルの拡張子から自動認識する

   「リサイズ」と「回転・反転」は同時にはできない点に注意する。
   出力ファイルと同名ファイルがあると強制上書きされる点にも注意する。

   ConvImage -inputFile <file> -outputFile <file> [-notOverWrite]
   ConvImage -inputFile <file> -outputFile <file> -resize <num>x<num> [-notOverWrite]
   ConvImage -inputFile <file> -outputFile <file> -rotate <num> [-flip] [-flop] ] [-notOverWrite]

   Inspired by:
   
   - Get-Draw.ps1 - miyamiya/mypss: My PowerShell scripts - GitHub
       - https://github.com/miyamiya/mypss
       - License: The MIT License (MIT): Copyright (c) 2013 miyamiya
   - ImageMagick (command)
       - https://imagemagick.org/index.php


.Parameter inputFile
    入力ファイル。

.Parameter outputFile
    出力ファイル。
    指定した拡張子に変換して出力。

    使用できる拡張子
    jpg,png,bmp,emf,gif,tiff,wmf,exif,guid,icon,...

.Parameter Exif
    Exif情報などの画像ファイルのプロパティをできるだけ引き継ぐ
    画像のリサイズ時のみ対応

.Parameter ExifOrientationOnly
    画像の方向（上下左右）のプロパティ（Exif情報）のみ引き継ぐ
    画像のリサイズ時のみ対応

.Parameter resize
    縦x横でサイズを指定。
    アスペクト比（縦横比）は維持される。
    縦x横で指定した場合、
    長辺を基準にアスペクト比を保持してリサイズされる。

    ピクセル指定：100x100
    ピクセル指定：100（高さのみ指定）
    比率指定：50%（高さのみ指定）

.Parameter rotate
    回転角度を指定

.Parameter flip
    上下反転

.Parameter flop
    左右反転

.Parameter notOverWrite
    ファイルを強制的に上書きしない


.EXAMPLE
PS > ConvImage before.jpg after.png

説明
========================
最も簡単な例。
before.jpg を after.png に形式変換する。

.EXAMPLE
PS > ConvImage before.jpg after.png -resize 500x500

説明
========================
最も簡単な例その2。
before.jpg を after.png に形式変換し、かつ、
サイズが 500px×500pxに収まるように
アスペクト比（縦横比）を保ちリサイズする


.EXAMPLE
PS > ConvImage -inputFile before.jpg -outputFile after.png -resize 100x100

説明
========================
オプションを正確に記述した例。上記「簡単な例その2」と同じ結果を得る。
before.jpg を after.png に形式変換し、かつ、
サイズが 100px×100pxに収まるように、
アスペクト比（縦横比）を保ちリサイズする

.EXAMPLE
PS > ConvImage -inputFile before.jpg -outputFile after.png -resize 100x100 -notOverWrite

説明
========================
before.jpg を after.png に形式変換し、かつ、
サイズが 100px×100pxに収まるように、
アスペクト比（縦横比）を保ちリサイズする
-notOverWriteオプションにより、
もし after.png が存在していても上書きしない.

.EXAMPLE
PS > ConvImage before.jpg after.png -resize 10%

説明
========================
before.jpg を after.png に形式変換し、かつ、
縦横のピクセルが 10%（1/10）に縮小される
アスペクト比（縦横比）は保たれる

.EXAMPLE
PS > ConvImage before.jpg after.png -resize 100

説明
========================
before.jpg を after.png に形式変換し、かつ、
縦（高さ）のピクセルが 100pxにリサイズされる
アスペクト比（縦横比）は保たれる

.EXAMPLE
PS > ConvImage before.jpg after.png -rotate 90

説明
========================
before.jpg を after.png に形式変換し、かつ、
90度回転される

.EXAMPLE
PS > ConvImage before.jpg after.png -rotate 90 -flip

説明
========================
before.jpg を after.png に形式変換し、かつ、
90度回転され、かつ、
上下反転される

.EXAMPLE
PS > ConvImage before.jpg after.png -rotate 90 -flop

説明
========================
before.jpg を after.png に形式変換し、かつ、
90度回転され、かつ、
左右反転される

#>
function ConvImage
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $True,Position=0)]
        [string[]]$inputFile,

        [parameter(Mandatory = $True,Position=1)]
        [string[]]$outputFile,

        [parameter(Mandatory = $False)]
        [string]$resize = "None",

        [parameter(Mandatory = $False)]
        [ValidateSet("90", "180", "270")]
        [string]$rotate = "None",

        [parameter(Mandatory = $False)]
        [switch]$flip,

        [parameter(Mandatory = $False)]
        [switch]$flop,

        [parameter(Mandatory = $False)]
        [switch]$Exif,

        [parameter(Mandatory = $False)]
        [switch]$ExifOrientationOnly,

        [parameter(Mandatory = $False)]
        [switch]$notOverWrite
    )

    # カレントディレクトリの取得
    $str_path = (Convert-Path .)

    # inputFileが絶対パスでなければ、絶対パスを追加
    if($inputFile -eq ''){
        Write-Error '-inputFile の指定が不正です.' -ErrorAction Stop}
    if(($inputFile -notmatch '^[A-Z]:\\.*') -and ($inputFile -notmatch '^\\\\')){
        $inputFilePath = (Join-Path "$str_path" "$inputFile")
    }else{
        $inputFilePath = $inputFile
    }
    #Write-Output $inputFilePath

    # outputFileが絶対パスでなければ、絶対パスを追加
    if($outputFile -eq ''){
        Write-Error '-outputFile の指定が不正です.' -ErrorAction Stop}
    if(($outputFile -notmatch '^[A-Z]:\\.*') -and ($outputFile -notmatch '^\\\\')){
        $outputFilePath = (Join-Path "$str_path" "$outputFile")
    }else{
        $outputFilePath = $outputFile
    }
    #Write-Output $outputFilePath

    # inputFileの存在チェックとフルパスの取得
    #$inputFilePath = (Get-ChildItem $inputFile | %{ $_.FullName })
    if(!(Test-Path "$inputFilePath")){
        Write-Error "$inputFile が存在していません." -ErrorAction Stop}

    # -notOverWriteオプションがあれば上書きしないモード
    if($notOverWrite){
        if((Test-Path "$outputFilePath")){
            Write-Error "$outputFile が存在しています." -ErrorAction Stop}
    }

    # もしinputFileとoutputFileが同じならば終了
    if("$outputFilePath" -eq "$inputFilePath"){
        Write-Error "入出力で同じファイルを指定できません." -ErrorAction Stop}
    #Write-Output $inputFile,$outputFile
    #throw

    # ファイル拡張子の取得
    $inputExt = $inputFile -Replace '^.*\.([^.]*)$','$1'
    #$inputExt = $inputExt.ToLower()
    $outputExt = $outputFile -Replace '^.*\.([^.]*)$','$1'
    #$outputExt = $outputExt.ToLower()
    #Write-Output $inputExt,$outputExt

    # 出力ファイル拡張子のImageFormat形式変換
    if($outputExt -eq 'jpg' ) { $ImageFormatExt = 'Jpeg' }
    if($outputExt -eq 'jpeg') { $ImageFormatExt = 'Jpeg' }
    if($outputExt -eq 'png' ) { $ImageFormatExt = 'Png'  }
    if($outputExt -eq 'bmp' ) { $ImageFormatExt = 'Bmp'  }
    if($outputExt -eq 'emf' ) { $ImageFormatExt = 'Emf'  }
    if($outputExt -eq 'gif' ) { $ImageFormatExt = 'Gif'  }
    if($outputExt -eq 'tiff') { $ImageFormatExt = 'Tiff' }
    if($outputExt -eq 'wmf' ) { $ImageFormatExt = 'Wmf'  }
    if($outputExt -eq 'exif') { $ImageFormatExt = 'Exif' }
    if($outputExt -eq 'guid') { $ImageFormatExt = 'Guid' }
    if($outputExt -eq 'icon') { $ImageFormatExt = 'Icon' }

    # ファイル拡張子のテスト
    $iExtFlag = $false
    $oExtFlag = $false
    [string[]]$extLists = @("jpg","jpeg","png","bmp","emf","gif","tiff","wmf","exif","guid","icon") 
    foreach ($ex in $extLists){
        if($ex -eq $inputExt) {$iExtFlag = $true}
        if($ex -eq $outputExt){$oExtFlag = $true}
    }
    if(!$iExtFlag){
        Write-Error "$inputFile の拡張子が正しくありません." -ErrorAction Stop }
    if(!$oExtFlag){
        Write-Error "$outputFile の拡張子が正しくありません." -ErrorAction Stop }

    # outputFileの拡張子を小文字に変換する
    $tmpFileName = $outputFilePath -Replace '^(.*\.)[^.]*$','$1'
    $outputFilePath = [string]$tmpFileName + $outputExt
    #Write-Output $inputFilePath,$outputFilePath

    # 回転オプションの整形（RotateFlipType対応文字列の生成）
    # rotate：回転
    if($rotate -eq 'None'){
        $rotateStr = 'Rotate' + "$rotate"
    }else{
        $rotateStr = 'Rotate' + [string]$rotate
    }    

    # flip,flop：上下左右反転
    if($flip -and $flop){
        $flipStr = 'FlipXY'
    }elseif($flip -and (!$flop)){
        $flipStr = 'FlipY'
    }elseif((!$flip) -and $flop){
        $flipStr = 'FlipX'
    }else{
        $flipStr = 'FlipNone'
    }

    # 回転オプション
    $RotateFlipTypeStr = $rotateStr + $flipStr
    #Write-Output $rotateFlag,$flipFlag,$RotateFlipTypeStr
    if($RotateFlipTypeStr -eq "RotateNoneFlipNone"){
        $rotateFlag = $false
    }else{
        $rotateFlag = $true
    }

    # resizeオプションの解析    
    #    縦x横でサイズを指定。
    #    アスペクト比（縦横比）は維持される。
    #    つまり長辺が指定サイズで出力される
    #
    #    ピクセル指定：100x100
    #    ピクセル指定：100
    #    比率指定：50%
    $resizeFlag = $false
    $percentFlag = $false
    $splitFlag = $false

    # "%"の文字を含むか：%での値指定か
    if([string]$resize -match '%'){
        $percentFlag = $true
        $resize = $resize -Replace '%',''
    }

    # "x"の文字を含むか：縦x横の両方の値指定か
    if([string]$resize -match 'x'){
        $resizeFlag = $true
        $splitFlag = $true
        $splitResize = $resize -Split 'x'
        if($splitResize.Count -ne 2){
            Write-Error "$resize `の指定が不正です." -ErrorAction Stop}
        $TateNum = [int]$splitResize[0]
        $YokoNum = [int]$splitResize[1]
        #Write-Output $TateNum,$YokoNum,$percentFlag
    }elseif($resize -ne 'None'){
        $resizeFlag = $true
        $TateYokoNum = [int]$resize
        #Write-Output $TateYokoNum,$percentFlag
    }

    #Write-Output $rotateFlag,$resizeFlag
    # 当スクリプトは「リサイズ」と「回転、反転」のどちらかしか実行できない
    if($rotateFlag -and $resizeFlag){
        Write-Error '当スクリプトは「リサイズ」と「回転、反転」のどちらかしか実行できません.'  -ErrorAction Stop}


    #
    # MAIN処理
    #
    # アセンブリの読み込み
    Add-Type -AssemblyName System.Drawing

    # 画像ファイルの読み込み
    $image = New-Object System.Drawing.Bitmap("$inputFilePath")

    ## 画像の回転、反転
    if($rotateFlag){
        # 回転
        $image.RotateFlip("$RotateFlipTypeStr") 

        # 保存
        $image.Save("$outputFilePath", [System.Drawing.Imaging.ImageFormat]::"$ImageFormatExt")

        # オブジェクトの破棄
        $image.Dispose()

    ## 画像のリサイズ
    }elseif($resizeFlag){
        # 縮小先のオブジェクトを生成
        if($splitFlag){
            # 縦x横指定
            if($percentFlag){
                # "%"指定：高さのみ指定
                $tateRatio = $TateNum / 100
                $yokoRatio = $YokoNum / 100
                $ratio = $tateRatio
            }else{
                # ピクセル指定：指定したサイズの箱に収まるようにする
                # つまり縮小率の高い方の値を採用する
                $tateRatio = $TateNum / $image.Height
                $yokoRatio = $YokoNum / $image.Width
                #Write-Output $image.Height,$image.Width
                #Write-Output $tateRatio,$yokoRatio
                if($tateRatio -gt $yokoRatio){
                    # 縦 > 横の場合
                    $ratio = $yokoRatio
                }else{
                    $ratio = $tateRatio
                }
            }
        }else{
            # 数値のみ（高さのみ）指定
            if($percentFlag){
                # "%"指定
                $ratio = $TateYokoNum / 100
            }else{
                # ピクセル指定：高さ指定
                $ratio = $TateYokoNum / $image.Height
            }
        }
        $resizeHeightPixel = $image.Height * $ratio
        $resizeWidthPixel = $image.Width * $ratio

        #$canvas = New-Object System.Drawing.Bitmap([int]($image.Width / 2), [int]($image.Height / 2))
        $canvas = New-Object System.Drawing.Bitmap([int]($resizeWidthPixel), [int]($resizeHeightPixel))

        # 縮小先へ描画
        $graphics = [System.Drawing.Graphics]::FromImage($canvas)
        $graphics.DrawImage($image, (New-Object System.Drawing.Rectangle(0, 0, $canvas.Width, $canvas.Height)))

        # 属性の引継ぎ(Exifや回転情報などが引き継がれるはず)
        if ($Exif){
            foreach($item in $image.PropertyItems) {
                $canvas.SetPropertyItem($item)
            }
        }
        if ($ExifOrientationOnly){
            ## 画像の方向のみ引き継ぎ。
            ## Exifの中でorientation情報(ID)は0x0112（10進数で274）
            ## https://www.media.mit.edu/pia/Research/deepview/exif.html
            ## https://blog.shibayan.jp/entry/20140428/1398688687
            foreach($item in $image.PropertyItems) {
                if ($item.Id -eq 0x0112){
                    $canvas.SetPropertyItem($item)
                }
            }
        }

        # 保存
        $canvas.Save("$outputFilePath", [System.Drawing.Imaging.ImageFormat]::"$ImageFormatExt")

        # オブジェクトの破棄
        $graphics.Dispose()
        $canvas.Dispose()
        $image.Dispose()

    ## 画像形式の変換のみ
    }else{
        # 保存
        $image.Save("$outputFilePath", [System.Drawing.Imaging.ImageFormat]::"$ImageFormatExt")

        # オブジェクトの破棄
        $image.Dispose()
    }
}
