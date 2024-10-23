<#
.SYNOPSIS
    jl - Join the next Line if line ends with the keyword

    Concatenate the next line to the current line
    ending with the specified string "、".

    The purpose of this function is to suppress
    unnecessary space after rendering when a
    sentence ends with "、" in html.

    Note that ending character string treated as
    regular expressions. Use escape mark "\" to 
    search for symbols as character, for example,
    
        "." to "\."
        "-" to "\-"
        "$" to "\$"
        "\" to "\\"

.LINK
    jl, jl2, list2txt, csv2txt

.PARAMETER Key
    Specify the end string that coonects
    the next line with a regular expression.

    Defalut: "、"

.PARAMETER Delimiter
    Specifies delimiter.
    
    Default: ''

.PARAMETER AddCrLf
    Insert a blank line end of input.

.PARAMETER SkipBlank
    If detect a blank line,
    output once there.

.EXAMPLE
    "あいう、","えお”,"かきくけ","こさし","すせそたちつてと"
    あいう、
    えお
    かきくけ
    こさし
    すせそたちつてと
    
    PS > "あいう、","えお”,"かきくけ","こさし","すせそたちつてと" | jl
    あいう、えお
    かきくけ
    こさし
    すせそたちつてと
    
    説明
    =============
    デフォルトで、全角読点「、」で終わる行に次の行を連結する

.EXAMPLE
    "あいう、","えお”,"かきくけ","こさし","すせそたちつてと" | jl ’'
    あいう、えおかきくけこさしすせそたちつてと
    
    PS > "あいう、","えお”,"かきくけ","こさし","すせそたちつてと" | jl ’.'
    あいう、えおかきくけこさしすせそたちつてと
    
    説明
    =============
    第一引数はリテラル文字列ではなく正規表現として解釈される。
    ドット"."やハイフン"-"は、"\."、"\-"などエスケープすること。

.EXAMPLE
    "あいう、","えお”,"","かきくけ","こさし","すせそたちつてと" | jl -Delimiter "@"
    あいう、@えお
    
    かきくけ
    こさし
    すせそたちつてと
    
    説明
    =============
    Delimiterオプションで、行連結時の区切り文字を指定できる。

.EXAMPLE
    "あいう、","えお”,"","かきくけ","こさし","すせそたちつてと" | jl -Key "" -Delimiter "@"
    あいう、@えお@@かきくけ@こさし@すせそたちつてと
    
    説明
    =============
    jl -Key "" 空文字を指定すると全行連結

.EXAMPLE
    "a","b","c","d","","e","f","g","h" | jl -Key "" -SkipBlank -Delimiter ","
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
    
    PS > cat data.txt | jl . -d "`t"
    bumon-A filter  17:45 2017/05/10        hoge    fuga
    bumon-B eva     17:46 2017/05/10        piyo    piyo
    bumon-C tank    17:46 2017/05/10        fuga    fuga
    
    説明
    =============
    空行区切りレコードをタブ区切りに変換

.EXAMPLE
    "あいう、","えお”,"かきくけ","","こさし","すせそたちつてと" | jl ’' -SkipBlank
    あいう、えおかきくけ
    
    こさしすせそたちつてと

#>
function jl {
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
        [int] $counter      = 0
        [bool] $bufFlag     = $False
        [Regex] $reg        = $Key + '$'
        [string] $readLine  = ""
        [string] $writeLine = ""
    }
    process{
        # increment counter
        $counter++
        # read a line
        [string] $readLine = $_
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
