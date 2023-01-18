<#
.SYNOPSIS

pwmake -- Pwsh implementation of GNU make command

カレントディレクトリにあるMakefileを読み実行する

Usage

- man2 pwmake
- pwmake 引数なしでカレントディレクトリの`Makefile`を探し実行
- pwmake -f path/to/Makefile ファイル指定
- pwmake -Help 各target行末尾の「` ## コメント`」部をヘルプとして出力
- pwmake -DryRun

Detail

- Makefileの記法はおおよそGNU makeにしたがう
    - ただし行頭の空白はTabでもSpaceでも受付
    - ただし変数の定義には$()ではなく${}を使う
      $()とした場合Subexpression演算子として解釈される（後述）
- targetを指定しなかった場合は最初のtargetが実行される
- カレントプロセスで読み込んだドットソースfunctionもMakefileに記述できる
- ファイルは絶対パス指定でない場合はカレントディレクトリからの相対パスで探す
- -n（-DryRun）でコマンドを実行せずにログやエラーを出力できる
- 「toposort」で事前にMakefileの依存関係をチェックしてもよい
- 「#」でコメント
    - ターゲット行のみ行末コメント可能
    - コマンド行には行末コメント不可
    - コメント行の最右文字が"または'の場合はコメントアウトしない
      このケースは、"# this is not a comment"のように
      文字列内にある#だと解釈する
    - しかしkey = val ## note grep "hoge"のようなケースも
      コメントとみなさないので、注意する
    - 左が空白かつ#から始まる行は最右文字にかかわらず全行コメント行とみなす
- Makefile中のパスは、「makeコマンドを実行したディレクトリ」がルートになる
- include file file ...で外部Makefile読み込み
    - 外部Makefile中のパスは「呼び出し元のMakefileの場所」がルートになる

# comment out example
target: deps  #comment
    command \
        | sed 's;^#;;' \
        #| grep -v 'hoge'  <-- comment
        > a.md

Tips:
Makefileの各target行末尾に「 ## コメント」としておくと、
pwmake -Helpで、targetごとのコメントを取得できる。

```Makefile
target: [dep dep ...] ## this is help message
```

## $ pwmake -Help
##
## target synopsis
## ------ --------
## help   help message
## new    create directory and set skeleton files


Note:

- 最初行からコロン「:」を含む行までの間に変数を宣言することができる
- コロン「:」を含む行をターゲット行とみなし、それ以外の行をコマンド行とみなす
- ファイル名やターゲット名に空白（半角スペース）を含めない
- コマンド行は1つ以上の空白又はタブを行頭におく
- コマンドラインの行頭に@をつけると出力にコマンドラインをechoしない

- 宣言した変数を用いるときは${ver}とする。$(ver)は用いない。
- ただし変数に代入する値には$(shell command)としてもよい。たとえば：
    - DATE := $((Get-Date).ToString('yyyy-MM-dd'))は、右辺を展開して代入
    - DATE := ${(Get-Date).ToString('yyyy-MM-dd')}は、右辺を展開せず代入
    - DATE  = $((Get-Date).ToString('yyyy-MM-dd'))は、右辺を展開せず代入
    - DATE  = ${(Get-Date).ToString('yyyy-MM-dd')}は、右辺を展開せず代入
    - 注：最初の例以外は、変数は実行時に展開される点に気をつける
- 変数代入時のシェルコマンドは1行に1つだけしか受け付けない

- シェル変数代入 foo := $(Get-Date) は
  変数に代入する前にシェルを実行した上で変数に格納する

- シェル変数代入 foo  = $(Get-Date) は、
  式として変数に代入し使用されるタイミングでシェルを実行
  =で代入したシェル変数をさらに別の変数に代入すると、
  その変数に=と:=どちらで代入しても式が代入される点に注意。
  要は、var=$()の形で代入したvarの扱いは注意する

- とくに理由がなければ変数はvar:=str, var:=$()のように:=で
  即時評価してから代入する形がわかりやすいかもしれない。
  var=$()のような使用時に評価される変数は、よく理解してから
  用いないと、思わぬ動作をすることがある

- シェル変数代入 foo := Get-Date とすると単純な文字列として代入
  ただし右辺文字列がシェルコマンドとして解釈できる場合は
  foo=$(Get-Date)のように使用されるタイミングで実行されることもある
  しかしシェルコマンドは$()でくるむようにしたほうが安全である

- 改行区切り文字は以下のいずれか
    バックスラッシュ
    バッククオート
    パイプライン（縦棒）

- 自動変数は以下のもののみ実装
    $@ : ターゲットファイル名
    $< : 最初の依存するファイルの名前
    $^ : すべての依存するファイルの名前


Todo:

- シェル関数
  未: $(shell command)

- 変数宣言
  未: 「:=」構文

- 自動変数の対応状況
  済: $@ : ターゲットファイル名
  済: $< : 最初の依存するファイルの名前
  済: $^ : すべての依存するファイルの名前
  未: $? : ターゲットより新しいすべての依存するファイル名
  未: $+ : Makefileと同じ順番の依存するファイルの名前
  未: $* : サフィックスを除いたターゲットの名前
  未: $% : ターゲットがアーカイブメンバだったときのターゲットメンバ名

  済: %.ext : ターゲット名から拡張子を削除した文字列と置換。
          ターゲットラインのみ使用可。コマンドラインは使用不可。

  - '%'の使用例：拡張子をくっつけて利用する
    %.tex: %.md
        cat $< | md2html > $@

- サフィックスルール
  未

- マクロ置換
  未 


参考:
- https://www.gnu.org/software/make/
- https://www.oreilly.co.jp/books/4873112699/


Makefileの例1：

```Makefile
.PHONY: all
all: hoge.txt

hoge.txt: log.txt
    1..10 | grep 10 >> hoge.txt

log.txt:
    (Get-Date).ToString('yyyy-MM-dd HH:mm:ss') | sed 's;2022;2000;' | md2html >> log.txt
```


Makefileの例2：

```Makefile
min = 10  ## min
max = 100 ## max
epochs = 3
lr = 1e-5

## output files
OUT_DIR = min_${min}_max_${max}
PARSED_FILE = ${OUT_DIR}/parsed.txt
DATASET_DIR = ${OUT_DIR}/dataset
DATASET = ${DATASET_DIR}/train.tsv ${DATASET_DIR}/dev.tsv ${DATASET_DIR}/test.tsv
LOG_FILE = output/min_${min}_max_${max}.log

.PHONY: all

all: ${LOG_FILE}
  cat ${LOG_FILE}

${PARSED_FILE}: input.txt
  python parse.py input.txt --min ${min} --max ${max} > ${PARSED_FILE}

${DATASET}: ${PARSED_FILE}
  python dataset.py ${PARSED_FILE} ${DATASET_DIR}

${LOG_FILE}: ${DATASET}
  python run.py ${DATASET_DIR} \
    --epochs ${epochs} --lr ${lr} \
    --do_train --do_eval --do_test
```


.LINK
    toposort, pwmake

.EXAMPLE
cat Makefile

min = 10  ## min
max = 100 ## max
epochs = 3
lr = 1e-5

## output files
OUT_DIR = min_${min}_max_${max}
PARSED_FILE = ${OUT_DIR}/parsed.txt
DATASET_DIR = ${OUT_DIR}/dataset
DATASET = ${DATASET_DIR}/train.tsv ${DATASET_DIR}/dev.tsv ${DATASET_DIR}/test.tsv
LOG_FILE = output/min_${min}_max_${max}.log

.PHONY: all

all: ${LOG_FILE}
  cat ${LOG_FILE}

${PARSED_FILE}: input.txt
  python parse.py input.txt --min ${min} --max ${max} > ${PARSED_FILE}

${DATASET}: ${PARSED_FILE}
  python dataset.py ${PARSED_FILE} ${DATASET_DIR}

${LOG_FILE}: ${DATASET}
  python run.py ${DATASET_DIR} \
    --epochs ${epochs} --lr ${lr} \
    --do_train --do_eval --do_test

.EXAMPLE
pwmake -Variables max=100,min=99,epochs=8

######## override args ##########
max=100
min=99
epochs=8
######## argblock ##########
min=10
max=100
epochs=3
lr=1e-5
OUT_DIR=min_99_max_100
PARSED_FILE=min_99_max_100/parsed.txt
DATASET_DIR=min_99_max_100/dataset
DATASET=min_99_max_100/dataset/train.tsv min_99_max_100/dataset/dev.tsv min_99_max_100/dataset/test.tsv
LOG_FILE=output/min_99_max_100.log
######## phonies ##########
all
######## comBlock ##########

all: output/min_99_max_100.log
 cat output/min_99_max_100.log

min_99_max_100/parsed.txt: input.txt
 python parse.py input.txt --min 99 --max 100 > min_99_max_100/parsed.txt

min_99_max_100/dataset/train.tsv min_99_max_100/dataset/dev.tsv min_99_max_100/dataset/test.tsv: min_99_max_100/parsed.txt
 python dataset.py min_99_max_100/parsed.txt min_99_max_100/dataset

output/min_99_max_100.log: min_99_max_100/dataset/train.tsv min_99_max_100/dataset/dev.tsv min_99_max_100/dataset/test.tsv
 python run.py min_99_max_100/dataset --epochs 8 --lr 1e-5 --do_train --do_eval --do_test


====
override variables


.EXAMPLE
cat Makefile
# use uplatex
file    := a
texfile := ${file}.tex
dvifile := ${file}.dvi
pdffile := ${file}.pdf
date    := $((Get-Date).ToString('yyyy-MM-dd (ddd) HH:mm:ss'))

.PHONY: all
all: ${pdffile} ## Generate pdf file and open.
    @echo ${date}

${pdffile}: ${dvifile} ## Generate pdf file from dvi file.
    dvipdfmx -o $@ $<

${dvifile}: ${texfile} ## Generate dvi file from tex file.
    uplatex $<
    uplatex $<

.PHONY: clean
clean: ## Remove cache files.
    Remove-Item -Path *.aux,*.dvi,*.log -Force


# Makefileの各target列末尾に「` ## コメント`」としたので、`pwmake -Help`で、targetごとのヘルプを取得できる。
PS > make -f Makefile -Help
PS > pwmake -Help # デフォルトでカレントディレクトリのMakefileを探す

target synopsis
------ --------
all    Generate pdf file and open.
a.pdf  Generate pdf file from dvi file.
a.dvi  Generate dvi file from tex file.
clean  Remove cache files.


# -DryRunでコマンドを実行せずに実行ログのみ出力
pwmake -DryRun

######## override args ##########
None

######## argblock ##########
file=a
texfile=a.tex
dvifile=a.dvi
pdffile=a.pdf
date=2023-01-15 (Sun) 10:26:09

######## phonies ##########
all
clean

######## comBlock ##########
all: a.pdf
 @echo 2023-01-15 (Sun) 10:26:09

a.pdf: a.dvi
 dvipdfmx -o $@ $<

a.dvi: a.tex
 uplatex $<
 uplatex $<

clean:
 Remove-Item -Path *.aux,*.dvi,*.log -Force

######## topological sorted target lines ##########
a.tex
a.dvi
a.pdf
all

######## topological sorted command lines ##########
uplatex a.tex
uplatex a.tex
dvipdfmx -o a.pdf a.dvi
@echo 2023-01-15 (Sun) 10:26:09

######## execute commands ##########
uplatex a.tex
uplatex a.tex
dvipdfmx -o a.pdf a.dvi
@echo 2023-01-15 (Sun) 10:26:09


# 実行時エラーが発生すると処理は停止する
PS > pwmake
> uplatex a.tex
pwmake: The term 'uplatex' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.

#>
function pwmake {
    Param(
        [Parameter(Position=0, Mandatory=$False)]
        [Alias('t')]
        [string] $Target,

        [Parameter(Position=1, Mandatory=$False)]
        [Alias('v')]
        [string[]] $Variables,

        [Parameter(Mandatory=$False)]
        [Alias('f')]
        [string] $File = "Makefile",

        [Parameter(Mandatory=$False)]
        [Alias('d')]
        [string] $Delimiter = " ",

        [Parameter(Mandatory=$False)]
        [Alias('td')]
        [string] $TargetDelimiter = ":",

        [Parameter(Mandatory=$False)]
        [ValidateSet("stop","silentlyContinue")]
        [string] $ErrAction = "stop",

        [Parameter(Mandatory=$False)]
        [switch] $Help,

        [Parameter(Mandatory=$False)]
        [Alias('n')]
        [switch] $DryRun
    )

    ## show-help function
    function ParseHelp ([string[]] $argBlock) {
        ## parse help messages written in the following format
        ##   target: [dep dep ...] ## synopsis
        ##
        ## bellow is the output
        ##
        ## $ pwmake -Help
        ##
        ## target synopsis
        ## ------ --------
        ## help   help message
        ## new    create directory and set skeleton files
        ##
        if ($argBlock){
            $varDict = @{}
            foreach ($var in $argBlock) {
                ## get args and add dict (key, val)
                $key, $val = GetArgVar "$var" $varDict
                if($varDict){
                    foreach ($k in $varDict.Keys){
                        ## replace variables
                        [string]$bef = '${' + $k + '}'
                        [string]$aft = $varDict[$k]
                        $val = $val.Replace($bef, $aft)
                    }
                }
                $varDict.Add($key, $val)
                #Write-Output "$key=$val"
            }
        }        
        Select-String '^[a-zA-Z0-9_\-\{\}\$\.\ ]+?:' -Path $File -Raw `
            | ForEach-Object {
                $helpStr = [string]$_
                if ($helpStr -match ':='){
                    ## skip variable definition line
                    return
                } elseif ($helpStr -match '^\.phony'){
                    ## skip phony definition line
                    return
                } elseif ($helpStr -match ' ## '){
                    $helpStr = $helpStr -replace ':.*? ## ', ' ## '
                } else {
                    $helpStr = $helpStr -replace ':.*$', ''
                }
                if ($argBlock){
                    ## replace variables
                    foreach ($k in $varDict.Keys){
                        [string]$bef = '${' + $k + '}'
                        [string]$aft = $varDict[$k]
                        $helpStr = $helpStr.Replace($bef, $aft)
                    }
                }
                $helpStr
                } `
            | ForEach-Object {
                $helpAry = $_.split(' ## ', 2)
                return [pscustomobject]@{
                    target = $helpAry[0]
                    synopsis = $helpAry[1]}
            }
    }

    ## init var
    $makeFile = $File
    $phonyDict = @{}

    ## test
    $isExistMakefile = Test-Path -LiteralPath $makeFile
    if( -not $isExistMakefile){
        Write-Error "Could not find ""$makefile""" -ErrorAction Stop
    }

    ## private functions
    function AddEndOfFileMarkAndIncludeMakefile ([string]$mfile){
        [string[]]$lines = @()
        [string]$parentDir = Split-Path "$mfile" -Parent
        $lines = Get-Content -LiteralPath "$mfile" -Encoding UTF-8 `
            | ForEach-Object {
                $mfileline = [string]$_
                if ($mfileline -match '^include '){
                    ## include other makefile
                    $mfileline = $mfileline -replace '^include ',''
                    $mfileline = $mfileline.trim()
                    [string[]]$fListAry = $mfileline -split ' '
                    foreach ($f in $fListAry){
                        $fPath = Join-Path "$parentDir" "$f"
                        Get-Content -Path "$fPath" -Encoding UTF8
                        Write-Output ''
                    }
                } else {
                    Write-Output "$mfileline"
                }
            }
        #$lines += ,@('')
        #$lines += ,@('end_of_makefile:')
        return $lines
    }

    function DeleteSpace ([string]$line, [bool]$firstComFlag, [regex]$reg){
        if($reg){
            $line = $line -replace $reg, ''}
        if($firstComFlag){
            $line = $line -replace '^\s+',' '}
        else{
            $line = $line -replace '^\s+',''}
        return $line
    }

    function RemoveLineBreaks ([string[]]$lines){
        [string]$prevLine = ''
        $lines = foreach ($line in $lines) {
            $line = [string]$line -replace '^\s+',' '
            if ($line -match ' \\$'){
                ## backslash
                $line = $line -replace '\s+\\$',' @-->@'
                $prevLine = $prevLine + $line
            }elseif($line -match ' \`$'){
                ## backquote
                $line = $line -replace '\s+\`$',' @-->@'
                $prevLine = $prevLine + $line
            }elseif($line -match ' \|$'){
                ## pipe
                $line = $line -replace '\s+\|$',' | @-->@'
                $prevLine = $prevLine + $line
            } else {
                if($prevLine -ne ''){
                    $prevLine = $prevLine + $line
                    $prevLine = $prevLine -replace '@\-\->@\s*',''
                    Write-Output $prevLine
                    $prevLine = ''
                }else{
                    Write-Output $line
                }
            }
        }
        return $lines
    }

    function DeleteComment ([string[]]$lines){
        $lines = foreach ($line in $lines) {
            if($line -notmatch '^\s*#'){
                #[regex]$reg = '#["' + "']+$"
                #$line = $line -replace "$reg",''
                if($line -match '^\s+'){
                    ## command line
                    #pass
                }else{
                    ## target: dep line
                    $line = $line -replace '#.*[^"'']$', ''
                }
                $line = $line -replace ' *$', ''
                Write-Output $line
            }
        }
        return $lines
    }

    function SeparateBlock ([string[]]$lines){
        [bool]$argBlockFlag = $true
        [string[]]$argBlock = @()
        [string[]]$comBlock = @()
        foreach ($line in $lines) {
            if ($line -match '.'){
                if ($line -notmatch '='){ $argBlockFlag = $False } }
            if ($argBlockFlag){
                if( ($line -ne '') -and ($line -match ':=') ){
                    $line = $line -replace '\s*:=\s*',':='
                    $argBlock += ,@($line)
                }elseif( ($line -ne '') -and ($line -match '=') ){
                    $line = $line -replace '\s*=\s*','='
                    $argBlock += ,@($line)
                }
            }else{
                $comBlock += ,@($line)
            }
        }
        ## add emptyline at the end of comBlock for CreateTargetDict function
        $comBlock += ,@('')
        return $argBlock, $comBlock
    }

    function ReplaceOverrideVariables ([string[]]$lines){
        ## test and set var in dictionary
        $varDict = @{}
        foreach ($var in $Variables) {
            if($var -notmatch '='){
                Write-Error "Use ""<name>=<val>"" when setting -Variable $var" -ErrorAction Stop}
            $varAry = $var -split "=", 2
            $key = $varAry[0].trim()
            $val = $varAry[1].trim()
            $varDict.Add($key, $val)
        }
        ## replace var in lines
        $lines = foreach ($line in $lines) {
            foreach ($k in $varDict.Keys){
                ## replace variable
                [string]$bef = '${' + $k + '}'
                [string]$aft = $varDict[$k]
                $line = $line.Replace($bef, $aft)
            }
            Write-Output $line
        }
        return $lines
    }

    function GetArgVar ([string]$var, $varDict){
        ## input -> var := str
        ## input -> var := ${var}
        ## input -> var := ${var}.png
        ## input -> var := $(shell command)
        ## return: key:var, val:hoge
        if ($var -match ':='){
            ## ':=' defines a simply-expanded variable
            $varAry = $var -split ":=", 2
            [string]$key = $varAry[0].trim()
            [string]$val = $varAry[1].trim()
            ## replace ${var}
            if ($val -match '\$\{'){
                if($varDict){
                    foreach ($k in $varDict.Keys){
                        ## replace variables
                        [string]$bef = '${' + $k + '}'
                        [string]$aft = $varDict[$k]
                        $val = $val.Replace($bef, $aft)
                    }
                }
            }
            ## execute shell command
            if ($val -match '\$\(..*\)'){
               ## if $val contains $(command)
               ##     execute $val as shell command before variable assignment
               [string]$bef = $val -replace '^.*(\$\(..*\)).*$', '$1'
               [string]$aft = Invoke-Expression "$bef"
               [string]$val = $val.Replace($bef, $aft)
            }
        } else {
            ## '=' defines a recursively-expanded variable
            $varAry = $var -split "=", 2
            [string]$key = $varAry[0].trim()
            [string]$val = $varAry[1].trim()
            #$val = '$(' + $val + ')'
        }
        return $key, $val
    }

    function ReplaceArgBlock ([string[]]$argBlock){
        $varDict = @{}
        ## replace var in argBlock
        $argBlock = foreach ($var in $argBlock) {
            ## get key, val
            $key, $val = GetArgVar "$var" $varDict
            if($varDict){
                foreach ($k in $varDict.Keys){
                    ## replace variables
                    [string]$bef = '${' + $k + '}'
                    [string]$aft = $varDict[$k]
                    $val = $val.Replace($bef, $aft)
                }
            }
            $varDict.Add($key, $val)
            Write-Output "$key=$val"
        }
        return $argBlock
    }

    function ReplaceComBlock ([string[]]$argBlock, [string[]]$comBlock){
        $varDict = @{}
        ## set replace-dictionary
        foreach ($var in $argBlock) {
            $varAry = $var -split "=", 2
            $key = $varAry[0].trim()
            $val = $varAry[1].trim()
            $varDict.Add($key, $val)
        }
        $comBlock = foreach ($line in $comBlock) {
            foreach ($k in $varDict.Keys){
                [string]$bef = '${' + $k + '}'
                [string]$aft = $varDict[$k]
                $line = $line.Replace($bef, $aft)
            }
            Write-Output $line
        }
        return $comBlock
    }

    function CollectPhonies ([string[]]$comBlock){
        [string[]]$phonies = @()
        $comBlock = foreach ($line in $comBlock) {
            if ($line -match '^\.PHONY:'){
                $line = $line -replace '^\.PHONY:\s*'
                $tmpPhonies = $line -split $Delimiter
                foreach ($ph in $tmpPhonies){
                    $phonies += $ph
                }
            } else {
                Write-Output $line
            }
        }
        return $comBlock, $phonies
    }

    function CreateTargetDict ([string[]]$comBlock){
        $comDict    = @{}
        $tarDepDict = @{}
        [bool]$isFirstTarget = $true
        [string[]]$targetLineAry = @()
        [string[]]$comAry = @()
        [string[]]$depAry = @()
        foreach ($line in $comBlock) {
            if ($line -eq ''){
                if($isFirstTarget){
                    Write-Error "wrong start line" -ErrorAction Stop}
                ## output dictionary
                $comDict.Add($tar, $comAry)
                [string[]]$comAry = @()
            } else {
                if($line -match '^[^\s+].*:'){
                    ## target: dependency line
                    $targetLineAry += ,@($line)
                    $tar, $dep = $line -split ':', 2
                    $tar = $tar.trim()
                    $dep = $dep.trim()
                    $depAry = $dep -split $Delimiter
                    $tarDepDict.Add($tar, $depAry)
                    if($isFirstTarget){
                        ## get first target name
                        $isFirstTarget = $False
                        $firstTarget = $tar
                    }
                } elseif ($line -match '^\s') {
                    ## command line
                    $comAry += ,@($line.trim())
                } else {
                    Write-Error "unexpected line: $line" -ErrorAction Stop
                }
            }
        }
        return $targetLineAry, $comDict, $tarDepDict, $firstTarget
    }

    function CleanComBlock ([string[]]$ary){
        $isFirstLine = $true
        $ary = foreach ($line in $ary) {
            if ($line -ne ''){
                if ($isFirstLine){
                    ## first target line: output only input line
                    Write-Output $line
                    $isFirstLine = $False
                }elseif ($line -match '^[^\s].*:'){
                    ## normal target line: output with emptyline
                    Write-Output ''
                    Write-Output $line
                }else{
                    ## command line: output only input line
                    if($line -notmatch '^\s'){
                        Write-Error "unexpected line: $line" -ErrorAction Stop
                    }
                    Write-Output $line
                }
            }
        }
        $ary += @('')
        return $ary
    }

    function isPercentUsedCorrectly ([string]$line, [switch]$isTaget){
        if($isTaget){
            if ($line -match '%\.'){ return $True }
        } else {
            if ($line -match '\$%\.'){ return $True }
        }
        Write-Error "記号'%'は拡張子と一緒に用いてください: $line" -ErrorAction Stop
        return $False

    }
    function ReplacePercentToTarget ([string[]]$ary){
        ## ターゲット文字列のドットから右を最短で削除
        $repTar = $Target -replace '\.[^.\\/]*$', ''
        $repTar += '.'
        #Write-Debug $repTar
        $ary = foreach ($line in $ary) {
            if ($line -match '%\.'){
                if ($line -match '^[^\s].*:'){
                    ## target line: replace '%.' to target
                    $line = $line.Replace('%.',"$repTar")
                    Write-Output $line
                }else{
                    Write-Output $line
                }
            }else{
                Write-Output $line
            }
        }
        return $ary
    }

    function GetDepsDict ([string[]]$lines){
        $depsDict = @{}
        $firstTargetFlag = $True
        foreach ($line in $lines) {
            $t, $d = $line -split $TargetDelimiter, 2
            $t = $t.trim(); $d = $d.trim()
            if($d -eq ''){
                $depsAry = @()
            } else {
                $depsAry = $d -split $Delimiter
            }
            $depsDict.Add($t, $depsAry)
            if($firstTargetFlag){
                $firstTargetFlag = $False
                $firstTarget = $t
            }
        }
        return $depsDict
    }

    function IsTargetExists ([string]$tar, $dependencies){
        $tFlag = $False
        foreach ($key in $dependencies.Keys){
            if($key -eq $tar){$tFlag = $True}
        }
        return $tFlag
    }

    function Toposort_Tarjan ([string]$tar, $dependencies, $marked = @{}, $sorted = @()){
        ## Tarjan's topological sort
        ## :arg dependencies: dict of ``(tar, [list of dependencies])`` pairs
        if ($marked[$tar]){ return }
        $marked[$tar] = $True
        [string]$uniDeps = $dependencies[$tar] -Join $Delimiter
        if (IsTargetExists $uniDeps $dependencies){
            Toposort_Tarjan $uniDeps $dependencies $marked $sorted
        } else {
            foreach ($m in $dependencies[$tar]){
                Toposort_Tarjan $m $dependencies $marked $sorted
            }
        }
        $sorted += $tar
        return $sorted
    }

    function TargetContainsPhony ( [string]$tar, [string[]]$phonies ){
        $tarAry = $tar -split $Delimiter
        foreach ($ta in $tarAry){
            foreach ($phony in $phonies){
                if ($ta -eq $phony){ return $True }
            }
        }
        return $False
    }

    function DepContainsPhony ( [string[]]$depAry, [string[]]$phonies ){
        foreach ($de in $depAry){
            foreach ($phony in $phonies){
                if ($de -eq $phony){ return $True }
            }
        }
        return $False
    }

    function TargetFileIsNotExists ( [string]$tar ){
        $tarAry = "$tar" -split $Delimiter
        foreach ($ta in $tarAry){
            if ( -not (Test-Path -LiteralPath "$ta") ){ return $True }
        }
        return $False
    }

    function DepFileIsNotExists ( [string[]]$dependencies, [string[]]$phonies ){
        $depAry = $dependencies -split $Delimiter
        foreach ($de in $depAry){
            if ( TargetContainsPhony $de $phonies )   { return $True }
            if ( -not (Test-Path -LiteralPath "$de") ){ return $True }
        }
        return $False
    }

    function GetLastWriteTime ([string[]]$files, [string]$oldnew = "older"){
        [datetime]$retDate = (Get-Item -LiteralPath $files[0]).LastWriteTime
        foreach ($f in $files){
            [datetime]$tmpDate = (Get-Item -LiteralPath "$f").LastWriteTime
            if ($oldnew -eq 'older'){
                if ($tmpDate -lt $retDate){ $retDate = $tmpDate }
            }else{
                if ($tmpDate -gt $retDate){ $retDate = $tmpDate }
            }
        }
        return $retDate
    }

    function TargetFileOlerThanDepFile ([string]$tar, [string[]]$depAry){
        $tarAry = $tar -split $Delimiter
        [datetime]$tarFileOlderDate = GetLastWriteTime $tarAry "older"
        [datetime]$depFileNewerDate = GetLastWriteTime $depAry "newer"
        Write-Debug "tar older: $($tarFileOlderDate.ToString('yyyy-MM-dd HH:mm:ss'))"
        Write-Debug "dep newer: $($depFileNewerDate.ToString('yyyy-MM-dd HH:mm:ss'))"
        if ($tarFileOlderDate -lt $depFileNewerDate){
            return $True
        } else {
            return $False
        }
    }

    function IsTargetExecute ([string]$tar, $tarDepDict, $phonies){
        if ($tarDepDict[$tar][0] -eq '') {
            $depExists = $False
        } else {
            $depExists = $True
        }
        if ( $depExists -eq $False ){
            ## if target has no dependency
            if (TargetContainsPhony "$tar" $phonies){
                Write-Debug "check: TargetContainsPhony: $tar"
                return $True }
            if (TargetFileIsNotExists "$tar"){
                Write-Debug "check: TargetFileIsNotExists: $tar"
                return $True }
            Write-Debug "check: TargetFileIsExists: $tar"
        } else {
            ## if target has dependencies
            ### test targets
            if (TargetContainsPhony "$tar" $phonies){
                Write-Debug "check: TargetContainsPhony: $tar"
                return $True }
            if (TargetFileIsNotExists "$tar"){
                Write-Debug "check: TargetFileIsNotExists: $tar"
                return $True }
            ## test deps
            [string[]]$depAry = $tarDepDict[$tar]
            if (DepContainsPhony $depAry $phonies){
                Write-Debug "check: DepContainsPhony: $($tar): $($depAry)"
                return $True }
            if (DepFileIsNotExists $depAry $phonies){
                Write-Debug "check: DepFileIsNotExists: $($tar): $($depAry)"
                return $True }
            if (TargetFileOlerThanDepFile "$tar" $depAry){
                Write-Debug "check: TargetFileOlerThanDepFile: $($tar): $($depAry)"
                return $True }
             Write-Debug "check: TargetFileNewerThanDepFile: $($tar): $($depAry)"
        }
        return $False
    }

    function NoTarFile ([string]$tar){
        $targetFileIsNotExists = $False
        $tarAry = "$tar" -split $Delimiter
        foreach ($f in $tarAry){
            if ( -not (Test-Path -LiteralPath $f)){
                $targetFileIsNotExists = $True
            }
        }
        return $targetFileIsNotExists
    }

    function ReplaceAutoVar ([string]$comline, [string]$tar, $tarDepDict){
        ## replace auto variables written in each command line
        ##     $@ : ターゲットファイル名
        ##     $< : 最初の依存するファイルの名前
        ##     $^ : すべての依存するファイルの名前

        ## set dependency line
        if ($tarDepDict[$tar][0] -eq '') {
            $dep = ''
        }else{
            $dep = $tarDepDict[$tar] -join "$Delimiter"
        }

        ## set replace str
        [string]$autoValTarAll   = $tar
        [string]$autoValTarFirst = ($tar -split "$Delimiter")[0]
        [string]$autoValDepAll   = $dep
        [string]$autoValDepFirst = ($dep -split "$Delimiter")[0]

        ## replace auto variables
        $comline = $comline.replace('$@',"$autoValTarFirst")
        $comline = $comline.replace('$<',"$autoValDepFirst")
        $comline = $comline.replace('$^',"$autoValDepAll")
        return $comline
    }

    ## parse Makefile
    [string[]]$lines    = @()
    [string[]]$argBlock = @()
    [string[]]$comBlock = @()
    [string[]]$phonies  = @()

    ### preprocessing
    $lines = AddEndOfFileMarkAndIncludeMakefile "$makeFile"
    $lines = DeleteComment $lines
    $lines = RemoveLineBreaks $lines

    ### replace variables
    if($Variables){
        $lines = ReplaceOverrideVariables $lines
    }
    $argBlock, $comBlock = SeparateBlock $lines

    ### replace '%' to target string
    $comBlock = ReplacePercentToTarget $comBlock

    ## show help
    if ($Help){
        if($argBlock){
            ParseHelp $argBlock
        } else {
            ParseHelp
        }
        return
    }

    ### replace argblock
    if($argBlock){
        $argBlock = ReplaceArgBlock $argBlock
        $comBlock = ReplaceComBlock $argBlock $comBlock
    }

    ### create phonyDict
    $comBlock, $phonies = CollectPhonies $comBlock

    ### cleaning comBlock: add emptyline before target line
    $comBlock = CleanComBlock $comBlock

    ### debug
    if($DryRun){
        Write-Output "######## override args ##########"
        if($Variables){$Variables}else{"None"}
        Write-Output ''
        Write-Output "######## argblock ##########"
        if($argBlock){$argBlock}else{"None"}
        Write-Output ''
        Write-Output "######## phonies ##########"
        if($phonies){$phonies}else{"None"}
        Write-Output ''
        Write-Output "######## comBlock ##########"
        $comBlock
    }

    ## comBlock:
    ##   data structure: (block separator -eq emptyline)
    ## ----------------------------
    ##    target: dependent,...
    ##        command1
    ##        command2
    ##
    ##    target: dependent,...
    ##        command1
    ##        command2
    ##

    ## set dictionary
    $targetLineAry, $comDict, $tarDepDict, $firstTarget = CreateTargetDict $comBlock

    ## set target
    if($Target){
        [string] $tar = $Target
    } else {
        [string] $tar = $firstTarget
    }

    ## is exist target?
    if ( -not $comDict.ContainsKey($tar) ){
        Write-Error "Target: $tar is not exist in $makeFile" -ErrorAction Stop}

    ## set target and dependencies
    $depsDict = GetDepsDict $targetLineAry

    ## get topological sorted target line
    [string[]]$targetSortedList = @()
    $targetSortedList = Toposort_Tarjan "$tar" $depsDict
    #$targetSortedList = $targetLineAry | toposort

    ## debug log
    if ($DryRun){
        Write-Output "######## topological sorted target lines ##########"
        foreach ($line in $targetSortedList) {
            Write-Output "$line"
        }
        Write-Output ""
        Write-Output "######## topological sorted command lines ##########"
        foreach ($tmpTarget in $targetSortedList) {
            foreach($comline in $comDict[$tmpTarget]) {
                if ( $comline -notmatch '^\s*$' ){
                    $comline = ReplaceAutoVar "$comline" "$tmpTarget" $tarDepDict
                    #Write-Output "$($tmpTarget): $comline"
                    Write-Output "$comline"
                }
            }
        }
    }

    ## execute commands
    $isCommandExecuted = $False
    if ($DryRun){
        Write-Output ""
        Write-Output "######## execute commands ##########"
    }
    [string[]]$execComAry = @()
    foreach ($tar in $targetSortedList) {
        $targetLineIsExist = $comDict.ContainsKey($tar)
        if ( -not $targetLineIsExist ){
            if (NoTarFile "$tar"){
                ## target file is not exists
                Write-Error "Error: file is not exitsts: '$tar'." -ErrorAction Stop
            } else {
                ## target file is exists
                continue
            }
        }

        ## set commandline as string array
        [string[]]$commandlines = $comDict[$tar]

        ## set dependency line as string
        if ($tarDepDict[$tar][0] -eq '') {
            $dep = ''
        }else{
            $dep = $tarDepDict[$tar] -join "$Delimiter"
        }

        ## target should be execute?
        $comExecFlag = IsTargetExecute "$tar" $tarDepDict $phonies
        if( -not $comExecFlag ){
            ## continue ForEach-Object
            ## do not execute commands
            #if ($DryRun){ Write-Output "[F] $($tar): $dep" }
            continue
        }

        ## is commandlines are exists?
        if ($commandlines.Count -eq 0){
            ## continue ForEach-Object
            #if ($DryRun){ Write-Output "[F] $($tar): $dep" }
            continue
        }

        ## execute commandlines
        foreach ($comline in $commandlines){
            ## replace auto variables
            [string] $comline = ReplaceAutoVar "$comline" "$tar" $tarDepDict
            if (($comline -eq '') -or ($comline -match '^\s*$')){
                continue
            }
            ## main
            if ($DryRun){
                ## out debug
                #Write-Output "[T] $($tar): $comline"
                Write-Output "$comline"
            }else{
                ## exec commandline
                $echoCom = $True
                if ($comline -match '^@[^\(\{]'){
                    $echoCom = $False
                    $comline = $comline -replace '^@', ''
                }
                if ($echoCom){
                    Write-Host "> $comline" -ForegroundColor Green
                }
                try {
                    $isCommandExecuted = $True
                    Invoke-Expression "$comline"
                } catch {
                    if ($ErrAction -eq "stop"){
                        #Write-Warning "Error: $($tar): $comline"
                        Write-Error $Error[0] -ErrorAction Stop
                    }else{
                        #Write-Warning "Error: $($tar): $comline"
                        Write-Warning $Error[0]
                    }
                }
            }
        }
        if ($echoCom){ Write-Host "" }
    }
    if( (-not $isCommandExecuted) -and (-not $DryRun)){
        Write-Host "make: '$tar' is up to date."
    }
}
