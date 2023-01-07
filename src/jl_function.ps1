<#
.SYNOPSIS

jl -- join-line : 指定した文字列で終わる行に次の行を連結する

デフォルトで全角読点「、」で終わる行に次の行を連結する。
htmlで文末が「、」で終わる場合、
レンダリング後に不要な半角スペースが入るのを抑制する。
標準入力のみ受け付け。

文字列は「正規表現」で指定する点に注意する。
デフォルトは「、」でおわる行。
半角ドット"."、半角ハイフン"-"、ドルマーク"$"、バックスラッシュ"\"などは、
それぞれ"\."、"\-"、"\$"、"\\"とエスケープする。


関連: list2txt, csv2txt


.DESCRIPTION
-

.PARAMETER Key
次の行をつなげるキーとなる末尾文字列を正規表現で指定。
デフォルトで「、」（全角読点が末尾にある）。

.PARAMETER Delimiter
入力データの区切り文字を指定する。
デフォルトで空文字。

.PARAMETER AddCrLf
最終行に空行を挿入する。

.PARAMETER SkipBlank
空行があればそこでいったん出力する。

.EXAMPLE
Write-Output "あいう、","えお”,"かきくけ","こさし","すせそたちつてと"
あいう、
えお
かきくけ
こさし
すせそたちつてと

Write-Output "あいう、","えお”,"かきくけ","こさし","すせそたちつてと" | jl
あいう、えお
かきくけ
こさし
すせそたちつてと

説明
=============
デフォルトで、全角読点「、」で終わる行に次の行を連結する

.EXAMPLE
Write-Output "あいう、","えお”,"かきくけ","こさし","すせそたちつてと" | jl ’'
あいう、えおかきくけこさしすせそたちつてと

Write-Output "あいう、","えお”,"かきくけ","こさし","すせそたちつてと" | jl ’.'
あいう、えおかきくけこさしすせそたちつてと

説明
=============
第一引数はリテラル文字列ではなく正規表現として解釈される。
ドット"."やハイフン"-"は、"\."、"\-"などエスケープすること。


.EXAMPLE
Write-Output "あいう、","えお”,"","かきくけ","こさし","すせそたちつてと" | jl -Delimiter "@"
あいう、@えお

かきくけ
こさし
すせそたちつてと

説明
=============
Delimiterオプションで、行連結時の区切り文字を指定できる。

.EXAMPLE
Write-Output "あいう、","えお”,"","かきくけ","こさし","すせそたちつてと" | jl -Key "" -Delimiter "@"
あいう、@えお@@かきくけ@こさし@すせそたちつてと

説明
=============
jl -Key "" 空文字を指定すると全行連結

.EXAMPLE
Write-Output "a","b","c","d","","e","f","g","h" | jl -Key "" -SkipBlank -Delimiter ","
a,b,c,d

e,f,g,h

説明
=============
SkipBlankオプションで空行があるといったん出力する。

.EXAMPLE
cat data.txt
bumon-A
filter
17:45 2017/05/10
hoge
fuga

bumon-B
eva
17:46 2017/05/10
piyo
piyo

bumon-C
tank
17:46 2017/05/10
fuga
fuga

cat data.txt | jl . -d "`t"
bumon-A filter  17:45 2017/05/10        hoge    fuga
bumon-B eva     17:46 2017/05/10        piyo    piyo
bumon-C tank    17:46 2017/05/10        fuga    fuga

説明
=============
空行区切りレコードをタブ区切りに変換

.EXAMPLE
Write-Output "あいう、","えお”,"かきくけ","","こさし","すせそたちつてと" | jl ’' -SkipBlank
あいう、えおかきくけ

こさしすせそたちつてと



#>
function jl{
    Param(
        [Parameter(Mandatory=$False, Position=0)]
        [Alias('k')]
        [string]$Key = "、",

        [Parameter(Mandatory=$False)]
        [string]$Delimiter = '',

        [Parameter(Mandatory=$False)]
        [switch]$SkipBlank,

        [Parameter(Mandatory=$False)]
        [switch]$AddCrLf,

        [parameter(Mandatory=$False, ValueFromPipeline=$True)]
        [string[]]$Text
    )
    begin{
        ## init var
        [string]$readLine = ""
        [string]$writeLine = ""
        [boolean]$bufFlag = $False
        [int]$counter = 0
        [Regex]$reg = $Key + '$'
    }
    process{
        # increment counter
        $counter++
        # read a line
        $readLine = $_
        if (($SkipBlank) -and ($readLine -eq '')) {
            # skip blank
            if ($bufFlag) {
                Write-Output $writeLine
                $writeLine = ''
                $bufFlag = $False
            }
            Write-Output ""
        } else {
            # don't skip blank
            if ($readLine -cmatch $reg){
                ## if endswith $Str
                if ($bufFlag){
                    $writeLine += $Delimiter + $readLine
                }else{
                    $writeLine = $readLine
                }
                $bufFlag = $True
            }else{
                ## if not endswith $Str
                if ($bufFlag){
                    $writeLine = $writeLine + $Delimiter + $readLine
                    $bufFlag = $False
                }else{
                    $writeLine = $readLine
                }
                Write-Output $writeLine
                $writeLine = ''
            }
        }
    }
    end{
        # output
        if ($writeLine -ne '') {
            Write-Output $writeLine
        }
        if ($AddCrLf) {
            Write-Output ""
        }
    }
}
