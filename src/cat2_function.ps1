<#
.SYNOPSIS
指定したファイルの順序でファイルのコンテンツを出力する。
ファイル指定は空白スペース区切り。

cat2 [file]...

通常の Get-Content では引数はカンマ区切りで指定する。
ワイルドカード（*）は使用できるが、
ファイル名は辞書順固定となってしまう。

cat2 を使用することで、
半角空白区切りで複数ファイルの指定でき、また、
出力する順序も指定できる。
ハイフン(-)指定で標準入力からも受付可能。

.DESCRIPTION
-

.EXAMPLE
PS C:\>cat2 b.txt a.txt

説明
----------------------------
b.txt と a.txt の中身をこの順序で出力する
これは以下のコマンドと等価

PS C:\>Get-Content b.txt,a.txt

.EXAMPLE
PS C:\>Get-Content a.txt | cat2 b.txt -

説明
----------------------------
b.txt と 、標準入力からパイプを通ってきたa.txt の中身を
この順序で出力する


.EXAMPLE
PS C:\>cat2 *.txt

説明
----------------------------
Get-Content *.txt と同じ出力を得る。


#>
function cat2 {

    if($args.Count -lt 1){ throw "引数が不正です." }

    # ファイル中身の取得
    foreach ($f in $args){
        if($f -like '-'){
            $input
        }else{
            $fileList = (Get-ChildItem -Path "$f" | ForEach-Object { $_.FullName })
            foreach ($f in $fileList){
                Get-Content -Path "$f" -Encoding UTF8
            }
        }
    }
}
