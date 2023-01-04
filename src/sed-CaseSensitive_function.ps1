<#
.SYNOPSIS
sed: stream editor - 行単位での文字列置換

大文字小文字を区別する
正規表現が使用できる

■置換モード

sed-CaseSensitive 's;置換対象;置換後;g'
sed-CaseSensitive 's;置換対象;置換後;'

　- 末尾に g をつけると該当文字列をすべて置換
　- 末尾に g をつけないと行の左から検索し
      最初に該当した文字列のみ置換する

sed-CaseSensitive "s;`t;;"

    - タブを削除。制御文字を扱う場合はダブルクオートでくくる

■指定行出力モード

sed-CaseSensitive 'p;出力開始行キーワード;出力終了行キーワード;

    - 出力開始ワードから出力終了ワードまでの行のみ
      出力する
    - 開始keyと終了keyに異なる文字列を指定すると、
      思うような出力が得られやすい

      （開始keyと終了keyに同じ文字列を指定すると、
      「その文字列を含む行だけ」が出力され、
      その間の行は出力されない）

■指定行削除モード

sed-CaseSensitive 'd;出力開始行キーワード;出力終了行キーワード;

    - 出力開始ワードから出力終了ワードまでの行を
      削除して出力する

.EXAMPLE
PS C:\>Write-Output 'a1b1c1' | sed-CaseSensitive 's;1;2;g'
a2b2c2

説明
---------------
すべての 1 を 2 に置換


.EXAMPLE
PS C:\>Write-Output 'a1b1c1' | sed-CaseSensitive 's;1;2;'
a2b1c1

説明
---------------
最初にヒットした 1 のみ 2 に置換


.EXAMPLE
PS C:\>cat a.txt | sed-CaseSensitive "s;`t;;g"

説明
---------------
タブを削除

.EXAMPLE
PS C:\>cat a.txt | sed-CaseSensitive "s; ;`r`n;g"

説明
---------------
空白を改行に置換

.EXAMPLE
PS C:\>cat a.txt
aaa
bbb
ccc
ddd
eee

PS C:\>cat a.txt | sed-CaseSensitive 'p;^bbb;^ddd;'
bbb
ccc
ddd

説明
---------------
指定行出力モード。文字列bbbを含む行から
文字列dddを含む行までを出力

PS C:\>cat a.txt | sed-CaseSensitive 'p;^bbb;^ddd;'
aaa
eee

説明
---------------
指定行削除モード。文字列bbbを含む行から
文字列dddを含む行までを削除

#>
function sed-CaseSensitive {

    begin {
        ## flagのセット
        $gflag = $false
        $sflag = $false
        $pflag = $false
        $dflag = $false
        $pReadFlag = $false

        ## 引数のテスト
        if($args.Count -ne 1){throw "引数が不足しています."}
        [string]$OptStr = ($args[0]).Substring(0,1)
        if( ($OptStr -ne "s") -and `
            ($OptStr -ne "p") -and `
            ($OptStr -ne "d") ){
               throw "引数が不正です."
        }

        ## セパレータ文字の取得（2文字目がセパレータ）
        [string]$SepStr = ($args[0]).Substring(1,1)

        # 置換対象文字列の取得
        $regexstr = ($args[0]).Split("$SepStr")
        if($regexstr.Count -ne 4){throw "引数が不正です."}

        $srcptn = $regexstr[1]
        $repptn = $regexstr[2]
        #$repptn = $repptn -replace '\\n', '`r`n'
        #$repptn = $repptn -replace '\\t', '`t'
        if(! $srcptn){throw "引数が不正です."}

        # s（置換）とg（global）の指定確認
        if($regexstr[0] -like 's'){$sflag = $true}
        if($regexstr[0] -like 'p'){
               $pflag = $true
               $pReadFlag = $false
        }
        if($regexstr[0] -like 'd'){
               $dflag = $true
               $pReadFlag = $true
        }
        if($regexstr[3] -like 'g'){
               $gflag = $true
        }else{
               $regex = [Regex]$srcptn
        }
        if(!($sflag) -and !($pflag) -and !($dflag)){throw "引数が不正です."}
        #Write-Output $srcptn, $repptn
    }

    process {
        if($sflag){
               # sフラグ：置換モード
               if($gflag){
                      $line = $_ -creplace $srcptn, $repptn
               }else{
                      $line = $regex.Replace($_, $repptn, 1)
               }
               Write-Output $line
        }elseif($pflag){
               # pフラグ：マッチした行のみ表示するモード
               $line = [string]$_
               if($line -cmatch "$srcptn" ){$pReadFlag = $true}
               #$pReadFlag
               if($pReadFlag){Write-Output $line}
               if($line -cmatch "$repptn" ){$pReadFlag = $false}
               #$pReadFlag
        }elseif($dflag){
               # dフラグ：マッチした行のみ削除するモード
               $line = [string]$_
               if($line -cmatch "$srcptn" ){$pReadFlag = $false}
               if($pReadFlag){Write-Output $line}
               if($line -cmatch "$repptn" ){$pReadFlag = $true}
        }
    }
}
