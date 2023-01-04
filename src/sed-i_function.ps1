<#
.SYNOPSIS

sed-i -- ファイルの文字列置換と上書き(sed -i)
ただし上書きするのは-Executeスイッチを指定したときのみ。
これは、望まない置換を予防するため。

Usage:

sed-i 's;abc;def;g' file -Execute
    sed -i.bak 's;abc;def;g' file と等価（.bakでバックアップ）

sed-i 's;abc;def;g' file -Execute -OverWrite
    sed -i 's;abc;def;g' file と等価（上書き）↓

sed-i 's;<before>;<after>;g' file [-Execute] [-Overwrite|-OverwriteBackup]
sed-i 's;<before>;<after>;g','s;<before>;<after>;g',... file
    置換文字列はカンマ区切りで複数指定できる

デフォルトでdry run、かつ、バックアップ作成（.bak）ありの安全動作。
  -Patternsはカンマ区切りで複数指定できる
  -Executeスイッチで実行
  -OverWriteスイッチで上書き
  -OverWriteBackupスイッチで、.bakファイルがあった場合も上書き
  -EncodingはデフォルトでUTF8
  -MatchFileOnlyで、dry run時に変換対象ファイルのみ出力

thanks:
  PowerShellでファイル内の文字列置換 (sed -i) をする -- 晴耕雨読
  https://tex2e.github.io/blog/powershell/sed

関連: sed

info:
  sed -i と同じようにファイル内の文字列を置換するときは、以下のように複数のコマンドを組み合わせる。

  (Get-Content ファイル名) | foreach { $_ -replace "置換前","置換後" } | Set-Content ファイル名

  以下は、UTF-8 でエンコードされた text.txt ファイル内の「http:」を「https:」に置換する例

  $Target = "test.txt"
  $ENCODING = "UTF8"
  (Get-Content $Target -Encoding $ENCODING) `
      | % { $_ -replace "http:","https:" } `
      | Set-Content $Target -Encoding $ENCODING


補足:
  Get-Contentの処理を丸括弧で囲まないと別のプロセスが掴んでファイル書き込みができなくなる
  パイプライン処理によって、Get-Content のファイル読み込みが1行1行で遅延評価されているため。
  丸括弧は式の評価順を制御するためのものだが、遅延評価させずにすぐに式を評価するためにも使用できる。
  パイプラインの前で使用すると、ファイルの中身を全て読み込んで String 型にしてから次の処理に渡す。
  これにより、2つのコマンドが同じファイルを参照できるようになる。

.PARAMETER Patterns
sed形式で置換前後regexを指定。
カンマ区切りで複数指定できる。

's;hoge;fuga;g'
's;hoge;fuga;g','s;f(uga);h$1;'

.PARAMETER Execute
上書きの実行

.PARAMETER OverWrite
バックアップファイルを作成せずにファイルを上書き

.PARAMETER SkipError
エラーがあっても処理を継続
デフォルトでエラー発生時停止

.PARAMETER OverWriteBackup
バックアップファイルが存在していても強制上書き。
デフォルトではバックアップファイルが存在すると
エラーで処理が止まる

.PARAMETER BackupExtension
バックアップ拡張子を指定。

.EXAMPLE
"abcde" > a.txt; sed-i 's;abc;def;g' a.txt
ifile: ./a.txt
ofile: ./a.txt.bak
defde

.EXAMPLE
ls *.txt
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a---          2022/09/29    21:41              7 a.txt
-a---          2022/09/29    21:41              7 b.txt

PS> ls *.txt | %{ sed-i 's;abc;def;g' $_.FullName }
ifile: a.txt
ofile: a.txt.bak
defde

ifile: C:\Users\btklab\cms\drafts\tmp\b.txt
ofile: C:\Users\btklab\cms\drafts\tmp\b.txt.bak
defde

.EXAMPLE
ls *.txt | %{ sed-i 's;abc;hoge;g' $_.FullName -Execute }
./a.txt > ./a.txt.bak
./b.txt > ./b.txt.bak

.EXAMPLE
ls *.txt | %{ sed-i 's;abc;hoge;g' $_.FullName -Execute -OverWrite }
./a.txt > ./a.txt
./b.txt > ./b.txt

#>
function sed-i {
    Param(
        [Parameter(Position=0,Mandatory=$True)]
        [Alias('p')]
        [string[]] $Patterns,

        [Parameter(Position=1,Mandatory=$True)]
        [Alias('t')]
        [string] $Target,

        [Parameter(Mandatory=$False)]
        [Alias('e')]
        [switch] $Execute,

        [Parameter(Mandatory=$False)]
        [switch] $SkipError,

        [Parameter(Mandatory=$False)]
        [string] $BackupExtension = '.bak',

        [Parameter(Mandatory=$False)]
        [switch] $OverWriteBackup,

        [Parameter(Mandatory=$False)]
        [switch] $OverWrite,

        [Parameter(Mandatory=$False)]
        [switch] $MatchFileOnly,

        [Parameter(Mandatory=$False)]
        [string] $Encoding = 'UTF8'
    )
    # test path
    if (-not $SkipError){
        if (-not (Test-Path -LiteralPath "$Target")){
            Write-Error "$Target is not exists." -ErrorAction Stop
        }
    }
    if ($OverWrite){
        [string] $BackupTarget = "$Target"
    } else {
        [string] $BackupTarget = "$Target" + "$BackupExtension"
    }

    # private function
    function execSed {
        Param(
            [Parameter(Position=0,Mandatory=$True)]
            [string] $Patn,
            [Parameter(Position=1,Mandatory=$True)]
            [string] $Line
        )
        ## test replace option
        [string] $OptStr = ($Patn).Substring(0,1)
        if( ($OptStr -ne "s") -and `
            ($OptStr -ne "p") -and `
            ($OptStr -ne "d") ){
            Write-Error "引数が不正です." -ErrorAction Stop
        }
        ## get separator string (2nd letter from the left)
        [string] $SepStr = ($Patn).Substring(1,1)
        # 置換対象文字列の取得
        [string[]] $regexstr = ($Patn).Split("$SepStr")
        if($regexstr.Count -ne 4){Write-Error "引数が不正です." -ErrorAction Stop}
        [regex] $srcptn = $regexstr[1]
        [regex] $repptn = $regexstr[2]
        if(! $srcptn){Write-Error "引数が不正です." -ErrorAction Stop}
        # s（置換）とg（global）の指定確認
        if($regexstr[0] -like 's'){
            $sflag = $True}
        if($regexstr[0] -like 'p'){
            $pflag = $True
            $pReadFlag = $False}
        if($regexstr[0] -like 'd'){
            $dflag = $True
            $pReadFlag = $True}
        if($regexstr[3] -like 'g'){
            $gflag = $True
        }else{
            $regex = [Regex]$srcptn        
        }
        # sed
        if($sflag){
            # sフラグ：置換モード
            if($gflag){
                [string] $writeLine = $Line -replace "$srcptn", "$repptn"
            }else{
                [string] $writeLine = $regex.Replace("$Line", "$repptn", 1)
            }
            Write-Output $writeLine
        }elseif($pflag){
            # pフラグ：マッチした行のみ表示するモード
            if($Line -match "$srcptn" ){$pReadFlag = $True}
            if($pReadFlag){Write-Output $Line}
            if($Line -match "$repptn" ){$pReadFlag = $False}
        }elseif($dflag){
            # dフラグ：マッチした行のみ削除するモード
            if($Line -match "$srcptn" ){$pReadFlag = $False}
            if($pReadFlag){Write-Output $Line}
            if($Line -match "$repptn" ){$pReadFlag = $True}
        }
    }
    function getPatn {
        Param(
            [Parameter(Position=0,Mandatory=$True)]
            [string] $Patn
        )
        ## test replace option
        [string] $OptStr = ($Patn).Substring(0,1)
        if( ($OptStr -ne "s") -and `
            ($OptStr -ne "p") -and `
            ($OptStr -ne "d") ){
            Write-Error "引数が不正です." -ErrorAction Stop
        }
        ## get separator string (2nd letter from the left)
        [string] $SepStr = ($Patn).Substring(1,1)
        # 置換対象文字列の取得
        [string[]] $regexstr = ($Patn).Split("$SepStr")
        if($regexstr.Count -ne 4){Write-Error "引数が不正です." -ErrorAction Stop}
        [string] $srcptn = $regexstr[1]
        [string] $repptn = $regexstr[2]
        if(! $srcptn){Write-Error "引数が不正です." -ErrorAction Stop}
        return $srcptn
    }

    # main
    if ($Execute){
        # exec sed -i
        if (-not $OverWrite){
            if (-not $OverWriteBackup){
                if (Test-Path -LiteralPath "$BackupTarget"){
                    $bfile = "$BackupTarget".Replace('\','/')
                    Write-Error """$bfile"" is already exists." -ErrorAction Stop
                }
            }
            Copy-Item -LiteralPath "$Target" -Destination "$BackupTarget" -Force
        }
        $tfile = "$Target".Replace('\','/')
        $bfile = "$BackupTarget".Replace('\','/')
        Write-Host "$tfile > $bfile"
        (Get-Content -LiteralPath "$Target" -Encoding $Encoding) `
            | ForEach-Object {
                [string] $line = [string] $_
                if ($line -notmatch '^$'){
                    foreach ($patn in $Patterns){
                        $line = execSed -Patn "$Patn" -Line "$line"
                    }
                }
                Write-Output "$line"
            } `
            | Set-Content -LiteralPath "$Target" -Encoding $Encoding
    } else {
        if ($MatchFileOnly){
            # output match file only
            [boolean] $testFlag = $False
            foreach ($patn in $Patterns){
                [regex] $p = getPatn "$patn"
                $tmpVar = Select-String -Pattern "$p" -LiteralPath "$Target"
                if ($tmpVar -eq $Null){ $testFlag = $True }
            }
            if ($testFlag){ Write-Output "$($Target.Replace('\','/'))" }
        } else {
            Write-Host "ifile: ""$($Target.Replace('\','/'))""" -ForegroundColor Yellow
            Write-Host "ofile: ""$($BackupTarget.Replace('\','/'))""" -ForegroundColor Yellow
            # dry run
            (Get-Content -LiteralPath "$Target" -Encoding $Encoding) `
                | ForEach-Object {
                    [string] $line = [string] $_
                    if ($line -notmatch '^$'){
                        foreach ($patn in $Patterns){
                            $line = execSed -Patn "$Patn" -Line "$line"
                        }
                    }
                    Write-Output "$line"
                }
            Write-Output ''
        }
    }
}
