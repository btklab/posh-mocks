<#
.SYNOPSIS

pu2java - Wrapper for plantuml.jar command

plantuml.jarコマンドを実行するラッパー

前提: java, graphviz, plantuml.jarがインストールされていること

- plantuml official site
    - https://plantuml.com/en/
- graphviz
    - https://graphviz.org/
- java
    - https://www.java.com/en/download/
- plantuml.jar
    - https://sourceforge.net/projects/plantuml/files/plantuml.jar/download

plantuml.jarファイルの置き場所は、-Jar <path>で指定する。
以下の場所にあれば、自動で認識するので-Jarによる指定は不要。

- Windwos/Linux
    - ./plantuml.jar
- Windows:
    - ${HOME}/bin/plantuml.jar
- Linux:
    - /usr/local/bin/plantuml.jar


入力するファイルはBOMなしUTF-8のみ
出力形式はファイルの拡張子から自動判別。
日本語を使う場合、引数でUTF-8を指定すること

関連: mkdotfm, dot2gviz

hint:
  人物相関図 -> package, objectを用いたオブジェクト図
  歴史年表   -> シーケンス図
  業務フロー -> スイムレーン+アクティビティ図

.PARAMETER InputFile
入力ファイル。
文字コードはBOMなしUTF-8のみ

.PARAMETER ConfigFile
設定ファイル。
文字コードはBOMなしUTF-8のみ

.PARAMETER OutputFileType
出力するファイル形式。default="png"
ファイル名は入力ファイル+出力形式の拡張子

.PARAMETER OutputDir
出力するディレクトリ

.PARAMETER Charset
入力ファイルのエンコードの指定
UTF-8固定

.PARAMETER Jar
JAR実行ファイルの指定。
デフォルトで${HOME}/bin/plantuml.jar

.PARAMETER TestDot
graphvizとの連携をチェック

.PARAMETER CheckOnly
To check the syntax of files without generating images

.PARAMETER NoMetadata
PNG/SVG 出力にメタデータを含めない

.PARAMETER NotOverWrite
出力ファイルの上書き禁止

.PARAMETER ErrorCheck
コマンドを実行せずにコマンド文字列を表示する

#>
function pu2java {

    Param(
        [Parameter( Position=0, Mandatory=$True)]
        [Alias('i')]
        [string] $InputFile,

        [Parameter( Position=1, Mandatory=$False)]
        [ValidateSet(
            "gui", "png", "svg", "eps", "pdf",
            "vdx", "xmi", "scxml", "html", "txt",
            "utxt", "latex", "latex:nopreamble")]
        [Alias('o')]
        [string] $OutputFileType = "png",

        [Parameter( Mandatory=$False)]
        [Alias('c')]
        [string] $ConfigFile,

        [Parameter( Mandatory=$False)]
        [string] $OutputDir,

        [Parameter( Mandatory=$False)]
        [string] $Charset = "UTF-8",

        [Parameter( Mandatory=$False)]
        [string] $Jar,

        [Parameter( Mandatory=$False)]
        [switch] $TestDot,

        [Parameter( Mandatory=$False)]
        [switch] $CheckOnly,

        [Parameter( Mandatory=$False)]
        [switch] $NoMetadata,

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
    if ( -not (isCommandExist "java")){
        if ($IsWindows){
            Write-Error 'Install the Java Runtime Environment' -ErrorAction Continue
            Write-Error '  uri: https://www.java.com/en/download/' -ErrorAction Continue
            Write-Error '  winget install --id Oracle.JavaRuntimeEnvironment --source winget' -ErrorAction Stop
        } else {
            Write-Error 'Install the Java Runtime Environment' -ErrorAction Continue
            Write-Error '  uri: https://www.java.com/en/download/' -ErrorAction Continue
            Write-Error '  sudo apt install default-jre' -ErrorAction Stop
        }
    }
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

    ## is JAR execute file exist?
    if($Jar){
        [string] $jarFilePath = (Resolve-Path -LiteralPath $Jar -Relative).Replace('\','/')
    } elseif (Test-Path "plantuml.jar"){
        [string] $jarFilePath = "./plantuml.jar"
    } elseif ($IsWindows){
        [string] $jarFilePath = (Resolve-Path -LiteralPath ${HOME}\bin\plantuml.jar -Relative).Replace('\','/')
    } elseif ($IsLinux){
        [string] $jarFilePath = "/usr/local/bin/plantuml.jar"
    }
    if( -not (Test-Path -LiteralPath $jarFilePath) ){
        #Write-Error "$jarFilePath is not exist." -ErrorAction Stop
    }

    ## is input file exist?
    if( -not (Test-Path $InputFile) ){
        Write-Error "$InputFile is not exist." -ErrorAction Stop
    } else {
        $ifile = $(Resolve-Path -Path $InputFile -Relative).replace('\','/')
    }
    if($ConfigFile){
        if( !(Test-Path $ConfigFile) ){
            Write-Error "$ConfigFile is not exist." -ErrorAction Stop
        }
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
    #Usage: java -jar plantuml.jar -version
    #Usage: java -jar plantuml.jar -testdot
    #Usage: java -jar plantuml.jar -tpng
    if($TestDot){
        $CommandLineStr  = "java"
        $CommandLineStr += " -jar ""$jarFilePath"""
        $CommandLineStr += " -testdot"
    }else{
        $CommandLineStr  = "java"
        $CommandLineStr += " -jar ""$jarFilePath"""
        $CommandLineStr += " -charset ""$Charset"""
        if($NoMetadata){
            $CommandLineStr += " -nometadata"
        }
        if($CheckOnly){
            $CommandLineStr += " -checkonly"
        }
        if($ConfigFile){
            $CommandLineStr += " -config ""$ConfigFile"""
        }
        if($OutputFileType -eq "gui"){
            $CommandLineStr += " -gui"
        }else{
            $CommandLineStr += " -t""$OutputFileType"""
            if($OutputDir){
                $odir = $(Resolve-Path -Path $OutputDir -Relative).replace('\','/')
                $CommandLineStr += " -o ""$odir"""
            }
            $CommandLineStr += " ""$ifile"""
        }
    }
    #Write-Output $CommandLineStr

    if($ErrorCheck){
        Write-Output "$CommandLineStr"
    }else{
        Invoke-Expression $CommandLineStr
        if($TestDot){
            Write-Output "$CommandLineStr"
        }elseif($CheckOnly){
            Write-Output "$CommandLineStr"
        }elseif($OutputFileType -eq 'gui'){
            #pass
        }else{
            Get-Item -LiteralPath $oFilePath
        }
    }
}
