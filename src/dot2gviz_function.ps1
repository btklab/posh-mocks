<#
.SYNOPSIS

dot2gviz - Wrapper for Graphviz:dot command

graphviz：dotコマンドのラッパー

前提: graphvizがインストールされていること
注意: 入力するdotファイルはBOMなしUTF-8のみ

- Install Graphviz
    - uri: https://graphviz.org/
    - winget install --id Graphviz.Graphviz --source winget
- and execute cmd with administrator privileges
    - dot -c

日本語を使う場合、windowsではdotファイルもしくはdotコマンドの引数で
fontnameで日本語フォントを指定しないとうまくいかない点に注意する

.LINK
    pu2java, dot2gviz, pert, pert2dot, pert2gantt2pu, mind2dot, mind2pu, gantt2pu, logi2dot, logi2dot2, logi2dot3, logi2pu, logi2pu2, flow2pu


.PARAMETER InputFile
入力するdotファイル。
文字コードはBOMなしUTF-8のみ

.PARAMETER OutputFileType
出力するファイル形式

.PARAMETER FontName
出力するフォント名の指定

BIZ UDGothic, BIZ UDGothic Bold, BIZ UDPGothic, BIZ UDPGothic Bold,
BIZ UDMincho Medium, BIZ UDPMincho Medium, Meiryo, Meiryo Italic,
Meiryo Bold, Meiryo Bold Italic, Meiryo UI, Meiryo UI Italic,
Meiryo UI Bold, Meiryo UI Bold Italic, MS Gothic, MS PGothic,
MS UI Gothic, MS Mincho, MS PMincho, Yu Mincho Light,
Yu Mincho Regular, Yu Mincho Demibold, Myrica M, Myrica M Bold,

.PARAMETER LayoutEngine
レイアウトエンジンの指定

circo     円形のグラフ.
dot     階層型のグラフ. 有向グラフ向き. デフォルトのレイアウトエンジン
fdp     スプリング(ばね)モデルのグラフ. 無向グラフ向き.
neato     スプリング(ばね)モデルのグラフ. 無向グラフ向き.
osage     配列型のグラフ.
sfdp     fdpのマルチスケール版. 大きな無向グラフ向き.
twopi    放射型のグラフ. ノードは同心円状に配置される.
patchwork    パッチワーク風

.PARAMETER NotOverWrite
出力ファイルの上書き禁止

.PARAMETER ErrorCheck
コマンドを実行せずにコマンド文字列を表示する

#>
function dot2gviz {

    Param(
        [Parameter( Position=0, Mandatory=$True)]
        [Alias('i')]
        [string] $InputFile,

        [Parameter( Position=1, Mandatory=$False)]
        [ValidateSet(
            "bmp", "cgimage", "dot", "eps", "exr",
            "fig", "gd", "gv", "gif", "gtk", "ico",
            "imap", "cmap", "jpg", "json", "pdf",
            "pic", "pict", "plain", "png", "pov",
            "ps", "ps2", "psd", "sgi", "svg", "tga",
            "tiff", "tk", "vml", "wbmp", "webp", "x11")]
        [Alias('o')]
        [string] $OutputFileType = "png",

        [Parameter( Mandatory=$False)]
        [Alias('f')]
        [string] $FontName,

        [Parameter( Mandatory=$False)]
        [Alias('l')]
        [ValidateSet(
            "circo", "dot", "fdp", "neato",
            "osage", "sfdp", "twopi", "patchwork")]
        [string] $LayoutEngine,

        [Parameter( Mandatory=$False)]
        [switch] $NotOverWrite,

        [Parameter( Mandatory=$False)]
        [switch] $ErrorCheck
    )
    # private function
    function isCommandExist ($cmd) {
      try { Get-Command $cmd -ErrorAction Stop | Out-Null
        return $True
      } catch {
        return $False
      }
    }
    ## cmd test
    if ( -not (isCommandExist "dot")){
        if ($IsWindows){
            Write-Error 'Install Graphviz' -ErrorAction Continue
            Write-Error '  uri: https://graphviz.org/' -ErrorAction Continue
            Write-Error '  winget install --id Graphviz.Graphviz --source winget' -ErrorAction Continue
            Write-Error 'and execute cmd with administrator privileges:' -ErrorAction Continue
            Write-Error '  dot -c' -ErrorAction Stop
        } else {
            Write-Error 'Install Graphviz' -ErrorAction Continue
            Write-Error '  uri: https://graphviz.org/' -ErrorAction Continue
            Write-Error '  sudo apt install graphviz' -ErrorAction Stop
        }
    }
    ## is input file exist?
    if( -not (Test-Path $InputFile) ){
        Write-Error "$InputFile is not exist." -ErrorAction Stop
    }
    ## create output file name
    [string] $oDir = Resolve-Path -LiteralPath $InputFile -Relative | Split-Path -Parent
    [string] $oFil = (Get-Item -LiteralPath $InputFile).BaseName
    [string] $oFil = "$oFil.$OutputFileType"
    [string] $oFilePath = Join-Path $oDir $oFil
    if( (Test-Path -LiteralPath $oFilePath) -and ($NotOverWrite) ){
        Write-Error "$oFil is already exist." -ErrorAction Stop
    }

    ## execute command
    #Usage: dot [-Vv?] [-(GNE)name=val] [-(KTlso)<val>] <dot files>

    if( ($FontName -eq '') -and ($LayoutEngine -eq '') ){
        ## No FontName, No LayoutEngine
        [string] $CommandLineStr  = "dot"
        [string] $CommandLineStr += " -T" + $OutputFileType
        [string] $CommandLineStr += " -o ""$oFilePath"""
        [string] $CommandLineStr += " ""$InputFile"""

    }elseif( ($FontName -ne '') -and ($LayoutEngine -eq '') ){
        ## FontName, No LayoutEngine
        [string] $CommandLineStr  = "dot"
        [string] $CommandLineStr += " -Nfontname=""$FontName"""
        [string] $CommandLineStr += " -Efontname=""$FontName"""
        [string] $CommandLineStr += " -Gfontname=""$FontName"""
        [string] $CommandLineStr += " -T" + $OutputFileType
        [string] $CommandLineStr += " -o ""$oFilePath"""
        [string] $CommandLineStr += " ""$InputFile"""

    }elseif( ($FontName -eq '') -and ($LayoutEngine -ne '') ){
        ## No FontName, LayoutEngine
        [string] $CommandLineStr  = "dot"
        [string] $CommandLineStr += " -K" + $LayoutEngine
        [string] $CommandLineStr += " -T" + $OutputFileType
        [string] $CommandLineStr += " -o ""$oFilePath"""
        [string] $CommandLineStr += " ""$InputFile"""

    }else{
        ## FontName, LayoutEngine
        [string] $CommandLineStr  = "dot"
        [string] $CommandLineStr += " -Nfontname=""$FontName"""
        [string] $CommandLineStr += " -Efontname=""$FontName"""
        [string] $CommandLineStr += " -Gfontname=""$FontName"""
        [string] $CommandLineStr += " -K" + $LayoutEngine
        [string] $CommandLineStr += " -T" + $OutputFileType
        [string] $CommandLineStr += " -o ""$oFilePath"""
        [string] $CommandLineStr += " ""$InputFile"""
    }
    #Write-Output $CommandLineStr

    if($ErrorCheck){
        Write-Output "$CommandLineStr"
    }else{
        Invoke-Expression $CommandLineStr
        Get-Item -LiteralPath $oFilePath
    }
}
