<# 
.SYNOPSIS
clip2img -- clip boardのデータを画像ファイルとして保存

clip2img [directory] [-DirView] [-MSPaint] [-View]
clip2img -d ~/Documents
clip2img -n a.png

デフォルトの保存場所は"~/Pictures"
デフォルトのファイル名は"clip-yyyy-MM-dd-HHmmssfff.png"
同じファイル名がすでに存在した場合は上書きされる点に注意する

.PARAMETER Name
ファイル名を指定する

.PARAMETER MSPaint
ファイル保存しつつMSPaintでファイルを開く

.PARAMETER Clip
ファイル名をクリップボードにコピー

.PARAMETER View
ファイル保存しつつファイルを開く

.PARAMETER Directory
フォルダを指定する

.PARAMETER Prefix
ファイル名プレフィクスを指定

.PARAMETER DirView
保存先フォルダをエクスプローラで開く

.EXAMPLE
clip2img
====
カレントディレクトリに"clip-yyyy-MM-dd-HHmmssfff.png"出力
.EXAMPLE
clip2img -d ~/Picture
====
Pictureディレクトリに"clip-yyyy-MM-dd-HHmmssfff.png"出力

.EXAMPLE
clip2img -n a.png
====
カレントディレクトリに"a.png"出力

#>
function clip2img {
    Param(
        [Parameter(Mandatory=$False, Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('d')] [string] $Directory = "$HOME/Pictures",

        [Parameter(Mandatory=$False)]
        [Alias('n')] [string] $Name,

        [Parameter(Mandatory=$False)]
        [string] $Prefix = '',

        [Parameter(Mandatory=$False)]
        [Alias('p')] [switch] $MSPaint,

        [Parameter(Mandatory=$False)]
        [Alias('c')] [switch] $Clip,

        [Parameter(Mandatory=$False)]
        [Alias('i')] [switch] $DirView,

        [Parameter(Mandatory=$False)]
        [Alias('v')] [switch] $View
    )

    Add-Type -AssemblyName System.Windows.Forms
    $clipImage = [Windows.Forms.Clipboard]::GetImage()
    if ($clipImage -ne $null) {
        ## set save file path
        if ($Name){
            ## manual set filename
            $saveFileName = $Name
            if ($saveFileName -notmatch '\.png$'){
                $saveFileName = $saveFileName + '.png'
            }
        } else {
            ## auto set filename
            [string]$prefStr = 'clip'
            [string]$yyyymmdd = Get-Date -Format "yyyy-MM-dd-HHmmssfff"
            [string]$saveFileName = "$prefStr-$yyyymmdd.png"
        }
        [string]$saveFileName = "$Prefix" + "$saveFileName"
        ## set output dir path
        if ( -not (Test-Path -LiteralPath "$Directory") ){
            ## 存在しないディレクトリ名はエラー
            throw "存在しないディレクトリが指定されました. "
        }
        $outputDir = Resolve-Path -LiteralPath "$Directory"
        $saveFilePath = Join-Path $outputDir $saveFileName
        ## save as image file
        $clipImage.Save($saveFilePath)
        Get-Item $saveFilePath
        if ($View) {
            Invoke-Item $saveFilePath
        }elseif ($MSPaint){
            if ($IsWindows){
                 & "${HOME}\AppData\Local\Microsoft\WindowsApps\mspaint.exe" "$saveFilePath"
            } else {
                Invoke-Item "$saveFilePath"
            }
        }
        if ($Clip){
            Get-ChildItem -LiteralPath $saveFileName -Name | Set-Clipboard
        }
        if ($DirView){
            Invoke-Item "$outputDir"
        }
    } else {
        Write-Error "No image in clip board." -ErrorAction Stop
    }
}

