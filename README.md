# posh-mocks

A mock-up set of [PowerShell](https://github.com/PowerShell/PowerShell) 7 functions that filter text-object input from the pipeline(stdin) and return text-object (this concept is closer to Bash than PowerShell).Inspired by [Parsing Text with PowerShell (3/3), Steve Lee, January 28th, 2019](https://devblogs.microsoft.com/powershell/parsing-text-with-powershell-3-3/).

- For use in UTF-8 Japanese environments on windows.
- For my personal work and hobby use.
- Note that the code is spaghetti (due to my technical inexperience).

function list:

```powershell
# one-liner to create function list
cat README.md | grep '^#### ' | grep -o '`[^`]+`' | sort | flat fs=", " | Set-Clipboard
```

- `Add-CrLf-EndOfFile`, `Add-CrLf`, `addb`, `addl`, `addr`, `addt`, `cat2`, `catcsv`, `chead`, `clip2img`, `clipwatch`, `csv2sqlite`, `csv2txt`, `ctail`, `ctail2`, `flat`, `fwatch`, `Get-OGP(Alias:ml)`, `grep-CaseSensitive`, `grep`, `gyo`, `head`, `keta`, `man2`, `pwmake`, `say`, `sed-CaseSensitive`, `sed-i`, `sed`, `sleepy`, `tac`, `tail`, `tateyoko`, `teatimer`, `uniq-CaseSensitive`, `uniq`

Inspired by:

- Article
    - [Parsing Text with PowerShell (3/3), Steve Lee, January 28th, 2019](https://devblogs.microsoft.com/powershell/parsing-text-with-powershell-3-3/).
- Unix/Linux commands
    - Commands: `grep`, `sed`, `head`, `tail`, `awk`, `make`, `uniq`, and more...
- [Open-usp-Tukubai - GitHub](https://github.com/usp-engineers-community/Open-usp-Tukubai)
    - License: The MIT License (MIT): Copyright (C) 2011-2022 Universal Shell Programming Laboratory
    - Commands: `man2`, `keta`, `tateyoko`, `gyo`
- [greymd/egzact: Generate flexible patterns on the shell - GitHub](https://github.com/greymd/egzact)
    - License: The MIT License (MIT): Copyright (c) 2016 Yasuhiro, Yamada
    - Commands: `flat`, `addt`, `addb`, `addr`, `addl`, 
- [mattn/sleepy - GitHub](https://github.com/mattn/sleepy)
    - License: The MIT License (MIT): Copyright (c) 2022 Yasuhiro Matsumoto
    - Commands: `sleepy`

コード群にまとまりはないが、事務職（非技術職）な筆者の毎日の仕事（おもに文字列処理）を、より素早くさばくための道具としてのコマンドセットを想定している（毎日使用する関数は10個に満たないが）。

基本的に入力としてUTF-8で半角区切りな行指向の文字列データ（テキストオブジェクト）を期待する、主にパターンマッチング処理を行うためのフィルタ群。少しながら、オブジェクトのパイプライン入力を受け付けたり、オブジェクトとして出力する「PowerShellのコマンドレット的といえるもの」も、ある。Windows上でしか動かない関数も、ある。

`src`下のファイルは1ファイル1関数。関数名はファイル名から`_function.ps1`をのぞいた文字列。基本的に他の関数には依存しないようにしているので、関数ファイル単体を移動して利用することもできる。（一部の関数は他の関数ファイルに依存しているものもある）


## Install functions

1. Comment out unnecessary lines (functions) in `operator.ps1`
2. Dot sourcing `operator.ps1` (and optional `operator-extra.ps1`)

```powershell
# install all functions
. path/to/pwsh-spaghetti/operator.ps1
. path/to/pwsh-spaghetti/operator-extra.ps1
```

関数は一部を除きできるだけ他の関数と依存しないようにしている。
必要な関数単独を直接ドットソースで読み込んでもよい。
この場合、以下のように最初にカレントプロセスのエンコードを`UTF-8`にしておくとよい。
理由は、当関数群は基本的にパイプライン経由の入出力として`UTF-8`を想定しているため。


```powershell
# install favorite functions
# set encode
if ($IsWindows){
    chcp 65001
    [System.Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")
    [System.Console]::InputEncoding  = [System.Text.Encoding]::GetEncoding("utf-8")
    # compartible with multi byte code
    $env:LESSCHARSET = "utf-8"
}
# sourcing dot files
. path/to/pwsh-spaghetti/src/hoge_function.ps1
. path/to/pwsh-spaghetti/src/piyo_function.ps1
```


## Description of each functions

各関数の挙動と作った動機と簡単な説明。

### show functions

#### `man2` - Enumerate the function names

`src`配下の関数（ファイル）名を列挙する。
筆者は作った関数をすぐに忘れてしまうため。

- Usage
    - `man2 [-c <int>] [func-name]`
- 挙動
    - `man2`関数ファイルと同階層にある`*_function.ps1`ファイルから`_function.ps1`を除去して列挙する
- 依存
    - `flat`, `tateyoko`, `keta`
- Examples
    - `man2`
    - `man2 -c 4`
    - `man2 man2`
    - `man2 keta`
- Inspired by [Open-usp-Tukubai - GitHub](https://github.com/usp-engineers-community/Open-usp-Tukubai)
    - License: The MIT License (MIT): Copyright (C) 2011-2022 Universal Shell Programming Laboratory
    - Command: `man2`

### unix-like commands

#### `sed`, `sed-CaseSensitive` - Stream EDitor

文字列を置換する。
Linux環境で使う`sed`のような使用感で文字列を置換するが、劣化コピーである。
`"string" | ForEach-Object{ $_ -replace 'reg','str' }`と同じ効果を得る。
`sed`は（筆者が毎日）よく使うコマンドなので、Bash・PowerShellとも同じ使用感・より短い文字数で利用できるようにした。

- Usage
    - `sed 's;<regex-pattern>;<replace-strings>;g'`
        - 左から2文字目が区切り文字。`sed 's@hoge@piyo@g'`と書いてもよい
    - `sed 's;<regex-pattern>;<replace-strings>;'`
        - 末尾に`g`がない場合、行の左から右にみて最初にヒットした`regex-pattern`のみ置換する
        - このユースケースでは大文字小文字が区別される点に注意する
    - ```sed "s;`t;<replace-strings>;g"```
        - ダブルクオートで囲むと``` `t ```や``` `r`n ```などの制御文字を置換可能
        - Bashで使う`sed`のように`\t`や`\n`ではない点に注意
- Inspired by Unix/Linux Commands
    - Command: `sed`

#### `sed-i` - Edit files in place

文字列を置換し、かつファイルを上書き。
Linuxでいう`sed -i`（の劣化コピー）。ただし誤爆防止のため`-Execute`スイッチを使用しなければ上書きはしない。
同じ動作をするPowerShellワンライナーがいつも長くなるので。

- Usage
    - `sed-i 's;<before>;<after>;g' file [-Execute] [-Overwrite|-OverwriteBackup]`
        - デフォルトでdry run、かつ、バックアップ作成（.bak）ありの安全動作
- Examples
    - `sed-i 's;abc;def;g' file -Execute`
        - Linux: `sed -i.bak 's;abc;def;g' file` と等価（`.bak`ファイルにオリジナルファイルをバックアップ）
    - `sed-i 's;abc;def;g' file -Execute -OverWrite`
        - Linux: `sed -i 's;abc;def;g' file` と等価（上書き）↓
    - `sed-i 's;<before>;<after>;g','s;<before>;<after>;g',... file`
        - 置換文字列はカンマ区切りで複数指定できる
- Inspired by Unix/Linux Commands
    - Command: `sed`

#### `grep`, `grep-CaseSensitive`

文字列の検索とヒット行の出力。
Linux環境で使う`grep`のような使用感で文字列を検索するが、劣化コピーである。
`"string" | Select-String -Pattern <reg>`と同じ効果を得る。
`grep`は（筆者が毎日）よく使うコマンドなので、Bash・PowerShellとも同じ使用感・より短い文字数で利用できるようにした。

- Usage
    - `grep 'word' <file1,file2,...>`
    - `grep -v 'word' <file1,file2,...>`
    - `grep -o 'word' <file1,file2,...>`
    - `grep -H 'word' <file1,file2,...>`
    - `grep -f 'file' <file1,file2,...>`
- Inspired by Unix/Linux Commands
    - Command: `grep`


#### `head`, `tail` - output the first/last part of files

入力文字列の最初の数行または最後の数行を出力する。
Linux環境で使う`head`、`tail`のような使用感で文字列を置換する。
`"string" | Select-Object -First <int> / -Last <int>`と同じ効果を得る。

- Usage
    - `1..20 | head [-n <int>]`
    - `1..20 | tail [-n <int>]`
    - `head *.*`
    - `tail *.*`
- Inspired by Unix/Linux Commands
    - Command: `head`, `tail`

#### `chead`, `ctail`, `ctail2` - cut the first/last part of files

入力文字列の最初の数行または最後の数行を削除（カット）して出力する。
`"string" | Select-Object -Skip <int> / -SkipLast <int>`と同じ効果を得る。

- Usage
    - `1..20 | chead  [-n <int>]`
    - `1..20 | ctail2 [-n <int>]`
    - `1..20 | ctail`
        - `ctail`は末尾の1行のみ削除
        - 場合により`ctail`よりも高速に動作するかもしれない
- Inspired by Unix/Linux Commands
    - Command: `chead`

#### `uniq`, `uniq-CaseSensitive` - report or omit repeated lines

入力から隣接する（連続する）重複行をなくし一意とする。大文字小文字は区別しない。事前ソート必要。
`Group-Object -NoElement`と同じ効果。

- Usage
    - `1,2,3,4,5,3 | sort | uniq`
    - `1,2,3,4,5,3 | sort | uniq -c`
- Inspired by Unix/Linux Commands
    - Command: `uniq`

#### `cat2` - concatenate files and print on the standard output

テキストファイルのコンテンツを取得。
複数ファイルを指定する方法は、`Get-Content`の際の「カンマ区切り」ではなく「半角スペース区切り」。
ハイフン「-」指定で標準入力

- Usage
    - `cat2 file1 file2 file3...`
- Inspired by Unix/Linux Commands
    - Command: `cat`

#### `tac` - output strings in reverse

入力を行単位逆順に出力する。

- Usage
    - `1..5 | tac`
    - ` tac a.txt,b.txt`
- Inspired by Unix/Linux Commands
    - Command: `tac`

### text filter

#### `tateyoko` - transpose columns and rows

半角スペース区切り文字列の縦横変換。
行数と列数は不揃いでもよい。

- Usage
    - `"1 2 3","4 5 6","7 8 9" | tateyoko`
- Inspired by [Open-usp-Tukubai - GitHub](https://github.com/usp-engineers-community/Open-usp-Tukubai)
    - License: The MIT License (MIT): Copyright (C) 2011-2022 Universal Shell Programming Laboratory
    - Command: `tateyoko`

#### `flat` - flat rows

半角スペース区切り文字列を任意列数となるように整える。

- Usage
    - `"1 2 3","4 5 6","7 8 9" | flat`
    - `"1 2 3","4 5 6","7 8 9" | flat 4`
- Inspired by [greymd/egzact: Generate flexible patterns on the shell - GitHub](https://github.com/greymd/egzact)
    - License: The MIT License (MIT): Copyright (c) 2016 Yasuhiro, Yamada
    - Command: `flat`

#### `Add-CrLf`, `Add-CrLf-EndOfFile` - Add LineFeed

改行を挿入する。

- `Add-CrLf`は、文字列中に``` `r`n ```を見つけるとそこに改行を挿入する。
- `Add-CrLf-EndOfFile`は、入力の最後に改行を1行挿入する。


#### `addb`, `addl` , `addr` , `addt` - Insert text strings at the top, bottom, left, and right of the input

入力の上下左右に文字列を挿入する。

- `addt`: add-top: 入力行の先頭行の`上`に文字列を追加
- `addb`: add-bottom: 入力行の末尾行の`下`文字列を追加
- `addr`: add-right: 各入力行の最`右`列に文字列を追加
- `addl`: add-left: 各入力行の最`左`列に文字列を追加

`addt`と`addb`は、ヘッダやフッタを追加する。<br />
`addt`と`addb`はカンマ区切りで複数行指定も可能。<br />
`addr`と`addl`は、左や右に列を追加するのに便利。<br />

- Usage
    - `"A B C D" | addt '<table>','' | addb '','</table>'`
    - `"B C D" | addr " E" | addl "A "`
- Inspired by [greymd/egzact: Generate flexible patterns on the shell - GitHub](https://github.com/greymd/egzact)
    - License: The MIT License (MIT): Copyright (c) 2016 Yasuhiro, Yamada
    - Command: `addt`, `addb`, `addr`, `addl`


#### `keta`

半角スペース区切り入力の桁そろえ。
端末上で半角スペース区切り入力を確認するときに見やすい。
マルチバイト文字対応。

- Usage
    - `"aaa bbb ccc","dddddd eeee ffff" | keta`
        - デフォルトで右揃え
    - `"aaa bbb ccc","dddddd eeee ffff" | keta -l`
        - `-l`スイッチで左揃え
- Inspired by [Open-usp-Tukubai - GitHub](https://github.com/usp-engineers-community/Open-usp-Tukubai)
    - License: The MIT License (MIT): Copyright (C) 2011-2022 Universal Shell Programming Laboratory
    - Command: `keta`

#### `gyo` - row counter

入力文字列の行数を出力する。
`(1..20 | Measure-Object).Count`と同じ効果。

- Usage
    - `1..20 | gyo`
    - `gyo *.*`
- Inspired by [Open-usp-Tukubai - GitHub](https://github.com/usp-engineers-community/Open-usp-Tukubai)
    - License: The MIT License (MIT): Copyright (C) 2011-2022 Universal Shell Programming Laboratory
    - Command: `gyo`

### csv handling

#### `csv2txt` - csv to text

CSVを半角スペース区切りの1行1レコード形式（SSV）に変換する。
改行含みのCSVデータを1行にして`grep`する、などの用途に便利。

- Usage
    - `cat a.csv | csv2txt [-z | -NaN]`

#### `catcsv` - concatenate csv files

任意のフォルダにあるUTF-8なCSVファイル群をひとつのCSVファイルにまとめる。
空行はスキップ。CSVヘッダは「有or無」どちらかに統一されている必要あり。
ヘッダ「無し」の場合`-NoHeader`オプションをつける

- Usage
    - `catcsv [[-Path] <String>] [-Output <String>] [-List] [-OffList] [-OverWrite] [-NoHeader]`
    - `catcsv`
        - カレントディレクトリの`*.csv`を`out.csv`に出力する
    - `catcsv a*.csv`
        - カレントディレクトリの`a*.csv`を`out.csv`に出力する

#### `csv2sqlite` - Apply sqlite-sql to csv files

CSVファイルに対して`sqlite`のSQL文を発行する。
CSVファイルをSQLで操作し、集計したり検索できる。

- Usage
    - `csv2sqlite csv,csv,... "<sqlstring>"`
    - `csv2sqlite csv,csv,... -ReadFile <sqlfile>`
    - `"<sqlstring>" | csv2sqlite csv,csv,...`
    - `cat <sqlfile> | csv2sqlite csv,csv,...`
    - `csv2sqlite db "<sqlstring>"`
    - `csv2sqlite db -ReadFile <sqlfile>`
    - `"<sqlstring>" | csv2sqlite db`
    - `cat <sqlfile> | csv2sqlite db`

### clipboard operation

#### `clip2img` - Save clip board image as an image file

クリップボードの画像データを画像ファイルとして保存。
`printscreen`で画像をキャプチャして画像ファイルに保存する、という作業を想定。
クリップボードに画像がなければエラーを返す。

デフォルトの保存場所は`~/Pictures`

- Usage
    - `clip2img [directory] [-DirView] [-MSPaint] [-View]`
    - `clip2img -d ~/Documents`
    - `clip2img -n a.png`

#### `clipwatch` - A clipboard watcher using Compare-Object

`Compare-Object`を用いたクリップボードウォッチャー。
クリップボードの変化を検知すると`-Action {scriptblock}`に指定したアクションを実行する。

- Usage
    - `clipwatch -Action {Get-ClipBoard | say}`
        - 文字列をクリップボードにコピーするたび`say`コマンド（後述）を実行する
    - `clipwatch -Action {Get-Clipboard | say -EN -Speed 2}`

### file watcher

#### `fwatch` - A filewatcher using LastWriteTime and FileHash

ファイル監視。実行したディレクトリ配下のファイルの変更を、
更新時刻またはハッシュ値の比較で検知する。
`-Action {scriptblock}`を指定すると、変化を検知した際にアクションを実行する。
LaTeXなど、文章を書きながら、上書き保存するたび自動コンパイルしたい場合に便利。

- Usage
    - `fwatch [-Path] <String> [[-Action] <ScriptBlock>] [-Interval <String>] [-Log <String>] [-Message <String>] [-Recurse] [-Hash] [-OutOnlyLog] [-Quiet]`
    - `fwatch -Path index.md -Action {cat index.md | md2html > a.html; ii a.html}`
    - `fwatch -Path . -Action {cat a.md | md2html > a.html; ii a.html} -Recurse`


### utils

#### `Get-OGP(Alias:ml)` - Make Link with Markdown Format

指定したURIからサイトプレビュー用Open Graph protocol（OGP）の要素（主にmetaタグの要素）を取得する。
標準入力、第一引数でUriを指定しない場合はクリップボードの値を使おうとする。

気になるサイトのUriをクリップボードにコピーした状態でコマンドを打つと、マークダウン形式やhtml形式に変換してくれる。
ブログ記事の作成などに便利な道具。

- Usage (`Set-Alias -name ml -value Get-OGP`)
    - `ml -m | Set-Clipboard`
        - クリップボードのUriをマークダウン形式のリンクに変換して再度クリップボードに格納
    - `ml | Format-List`
        - クリップボードのUriからOGP要素（metaタグの要素）を取得
- Inspired by [goark/ml - GitHub](https://github.com/goark/ml)
    - License: Apache License Version 2.0, January 2004, https://www.apache.org/licenses/LICENSE-2.0
    - Command: `Get-OGP (Alias: ml)`


### misc

#### `pwmake` - pwsh implementation of gnu make command

PowerShell版make-like command。劣化コピー。
カレントディレクトリにあるMakefileを読み実行する。

特徴は、実行コマンドにPowerShellコマンドを使用できる点、およびタスクランナーとしてカレントプロセスで動作する点。
たとえば、ドットソースで読み込んだ関数もMakefileに記述して走らせることができる。
（実際のところ、筆者はこの関数をたまにしか使わない自作コマンドのメモ（覚え書き）として用いている）

- Usage
    - `pwmake [[-Target] <String>] [[-Variables] <String[]>] [-File <String>] [-Delimiter <String>] [-TargetDelimiter <String>] [-ErrAction<String>] [-Help] [-DryRun]`
- Inspired by Unix/Linux Commands
    - Command: `make`


#### `say` - Speech Synthesizer

入力された文字列を読み上げる（文字列入力を音声出力に変換する）。

- Usage
    - `Get-Clipboard | say -JA`
    - `clipwatch -Action {Get-Clipboard | say -EN -Speed 2}`


#### `sleepy` - A pomodoro timer using progress bar

`Start-Sleep`にプログレスバーを付与したもの。
経過時間や残り時間が**視覚的に**わかる。
デフォルトで`-Minutes 25`（ポモドーロタイマー）。

Sleepが終わるまでプロンプトが帰ってこないので、
筆者は`Windows Terminal`を`Alt > Shift> +/-`で分割して時計として使っている。

- Usage
    - `sleepy`
        - pomodoro timer (`-Minute 25`)
    - `sleepy -s 3`
        - count 3 seconds.
    - `sleepy -s 3 -p`
        - count 3 seconds and then start past timer.
    - `sleepy -s 3 -p -t`
        - count 3 seconds and popup notification and then start past timer.
        - depends on `teatimer` function
    - `sleepy -t`
        - enable time-up notification.
        - depends on `teatimer` function
    - `sleepy -i`
        - infinit timer.
    - `sleepy -c`
        - clock mode
- Inspired by [mattn/sleepy - GitHub](https://github.com/mattn/sleepy)
    - License: The MIT License (MIT): Copyright (c) 2022 Yasuhiro Matsumoto
    - Command: `sleepy`

#### `teatimer` - time-up notification

ティータイマー。時間がきたら通知トレイからポップアップ通知してくれる。
仕事に没頭すると休憩するタイミングをのがしやすいので。

- Usage
    - `teatimer [[-Minutes] <Int32>] [[-Hours] <Int32>] [[-Seconds] <Int32>] [[-At] <DateTime>] [    [-Title] <String>] [[-Text] <String>] [[-Timeout] <Int32>] [[-EventTimeout] <Int32>] [-ShowPastTime] [-Quiet] [[-IconType]`
