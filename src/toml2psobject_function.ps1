<#
.SYNOPSIS

toml2psobject -- toml風設定ファイルの簡易パーサ

TOML風の設定情報を読み込みPSCustomObjectとして返す。
https://toml.io/en/

配列とハッシュで複数行の要素を格納できるので、
CSV形式などの「1行1レコード形式」では表現しにくい情報を
表現できるかもしれない。（Excelのセル内改行のイメージである）

出力をConvertTo-JsonやConvertTo-Csvなどに食わせて
変換することもできる。これは、PowerShellを使えない
人にも設定情報をエクスポートして再利用する場面を想定したもの。

Usage:
    cat a.toml | toml2psobject
    cat a.toml | toml2psobject -Execute | ConvertTo-Json
    toml2psobject a.toml

Input Format: example1
## comment
[あいうえお]
    bumon = haccp # comment
    cat   = "haccp"
    act   = review
    freq  = weekly
    tag   = [haccp, verification]
    stat  = true
    ref   = 224_617.445_991_228
    link  = {
        y2021="https://github.com/",
        y2022="https://github.com/",
        rep = ["hoge", "fuga"],
        }
    note  = """
      multi-line note1
      multi-line note2
      multi-line note3
      """

期待する入力は、まずidを[ ]で示し、それにぶら下がる要素を
key = value形式で列挙する。

- 余白
    - keyの左の余白はあってもなくてもよい
    - key = valの=の前後の余白はあってもなくても何個でもよい
- 配列とハッシュ
    - 配列は[item, item]、ハッシュは{key=val, key=val}で表現する
    - 配列とハッシュは入れ子にしてもよい
- コメント
    - コメント記号は#、複数行コメントは対応していない
    - コメント行の最右文字が"または'の場合はコメントアウトしない
      このケースは、"# this is not a comment"のように
      文字列内にある#だと解釈する
    - しかしkey = val ## note grep "hoge"のようなケースも
      コメントとみなさないので、注意する。
    - 左が空白かつ#から始まる行は最右文字にかかわらず全行コメント行とみなす
- 改行あり文字列
    - ダブルクオート3つ"""で囲めば改行あり文字列を格納できる
    - ただし出力時には1行となり改行は\n記号として表現される
    - 出力後の改行は何か他の方法や道具で変換されたい
    - 端末上で確認するだけならSimplifyスイッチをつけて出力する
- 空行はあってもなくてもよい
- データ型の自動認識
    - 文字列のダブルクオートは、なくてもおおよそ自動で文字列と認識される
    - ただしハッシュ（{ }）の値（右辺）の型は自動認識されないので、
      ダブルクオートしておくとよい
    - ダブルクオートするとConvertTo-Jsonした場合などに
      ダブルクオートがエスケープされてしまう点に注意する
    - float(double)型には区切り文字として_を用いてもよい

TOMLと異なり最初の[ ]でマルチバイト文字を使用できる。
一方で、ドットで結合してキーをネストすることはできない。
[ ]内はkeyが"id"の要素として認識される。

TOMLデータは以下の形式で自動認識される。

    string    System.String
    decimal   System.Double
    boolean   System.Boolean
    datetime  System.Datetime
    null      $Null
    Array     System.Collections.ArrayList
    HashTable System.Collections.Hashtable

-Executeスイッチで、配列とハッシュ型を認識。
パイプで後段にConvertTo-Jsonなどを当てる場合に指定する。
-ToJsonスイッチを用いてもよい。
デフォルトで配列とハッシュは文字列型として出力する。
これは、CSVなどの形式でオブジェクトを1行1レコードの文字列として
出力する用途を優先して想定したもの。

-DateFormat '%Y-%m-%d (%a)'とすれば日時形式のフォーマットをUnix形式で指定できる
半角ハイフン'-'などを用いるときは、全体をクオートするとiexできる

-Quoteオプションで文字列をクオートして出力
配列の文字列要素は自動でクオートして出力
ハッシュの文字列要素は自動でクオートされない
（ハッシュの値に記号を含む場合は自分でクオートする）


いずれにせよ、リストの要素はデータ型はパースされるが、
ハッシュの要素はパースされずそのまま出力される点に注意する

行末が{[,の3ついずれかの場合は複数行とみなす。
たとえば、

    ref = {name="hoge", prop="fuga"}

は、以下のようにもかける。

    ref = {
        name="hoge",
        prop="fuga"
        }

最後の要素のカンマは無視されるので、
あってもなくてもどちらでもよい。

    ref = {
        name="hoge",
        prop="fuga",
        }

最後の要素に閉じかっこをくっつけてもとよい

    ref = {
        name="hoge",
        prop=[1, 2]}

ハッシュを用いるときは、キーを数値ではなく文字列にするか、
キーをダブルクオートでくるんでおく。
値も、文字列の場合はダブルクオートでくるんでおく。
そうすると、後段にパイプでConvertTo-Jsonなどと連携できる。

  ref = {
        name="hoge",
        prop="fuga"}


TOML風入力ファイルの例をもう一つ示す。
TOMLのように[servers.alpha]としても、
要素の親子関係が表現できていない点に注意。
(ref: https://toml.io/en/)

# This is a TOML document
title = "TOML Example"

[owner]
name = "Tom Preston-Werner"
dob = 1979-05-27T07:32:00-08:00

[database]
enabled = true
ports = [ 8000, 8001, 8002 ]
data = [ ["delta", "phi"], [3.14] ]
temp_targets = { cpu = 79.5, case = 72.0 }

[servers]

[servers.alpha]
ip = "10.0.0.1"
role = "frontend"

[servers.beta]
ip = "10.0.0.2"
role = "backend"



関連: convToml, mdgrep


.PARAMETER NoPoshListAndHash

リストとハッシュの表現を、
PowerShell形式ではなくToml形式とする

.EXAMPLE
cat example1.toml
## comment
[あいうえお]
    bumon = haccp # comment
    cat   = "haccp"
    act   = review
    freq  = weekly
    tag   = [haccp, verification]
    stat  = true
    ref   = 224_617.445_991_228
    link  = {
        y2021="https://github.com/",
        y2022="https://github.com/",
        rep = ["hoge", "fuga"],
        }
    note  = """
      multi-line note1
      multi-line note2
      multi-line note3
      """

cat example1.toml | toml2psobject -NoPoshListAndHash | fl

id    : あいうえお
bumon : haccp
cat   : "haccp"
act   : review
freq  : weekly
tag   : ["haccp", "verification"]
stat  : True
ref   : 224617.445991228
link  : {y2021="https://github.com/", y2022="https://github.com/", rep = ["hoge", "f
        uga"]}
note  : multi-line note1\nmulti-line note2\nmulti-line note3

.EXAMPLE
cat example1.toml | toml2psobject -Simplify
[あいうえお]
bumon = haccp
cat   = "haccp"
act   = review
freq  = weekly
tag   = [haccp, verification]
stat  = true
ref   = 224_617.445_991_228
link  = {y2021="https://github.com/",y2022="https://github.com/",rep = ["hoge", "fuga"]}
note  = """
multi-line note1
multi-line note2
multi-line note3
"""

.EXAMPLE
cat example1.toml | toml2psobject -Execute | ConvertTo-Json
 or cat example1.toml | toml2psobject -ToJson -JsonDepth 10
{
  "id": "あいうえお",
  "bumon": "haccp",
  "cat": "\"haccp\"",
  "act": "review",
  "freq": "weekly",
  "tag": [
    "haccp",
    "verification"
  ],
  "stat": "True",
  "ref": "224617.445991228",
  "link": {
    "rep": [
      "hoge",
      "fuga"
    ],
    "y2021": "https://github.com/",
    "y2022": "https://github.com/"
  },
  "note": "multi-line note1\\nmulti-line note2\\nmulti-line note3"
}

説明
==============
ConvertTo-JsonでJson形式に変換するときは、
-Executeオプションを用いて配列とハッシュを
テキスト表現→オブジェクトに変換する。

float(double)型の値もクオートされる。
ダブルクオートした値はダブルクオートが
エスケープされて改めてクオートされる。

#>
function toml2psobject {
    Param(
        [parameter(Mandatory=$False, Position=0)]
        [string] $File,
        
        [parameter(Mandatory=$False)]
        [string] $DateFormat = '%Y-%m-%d',
        
        [parameter(Mandatory=$False)]
        [switch] $ToJson,
        
        [parameter(Mandatory=$False)]
        [int] $JsonDepth = 10,
        
        [parameter(Mandatory=$False)]
        [switch] $Simplify,
        
        [parameter(Mandatory=$False)]
        [switch] $Quote,
        
        [parameter(Mandatory=$False)]
        [switch] $NoPoshListAndHash,
        
        [parameter(Mandatory=$False)]
        [switch] $Execute,
        
        [parameter(Mandatory=$False, ValueFromPipeline=$True)]
        [string[]] $Text
    )
    # is file exists?
    function isFileExists ([string]$f){
        if(-not (Test-Path -LiteralPath "$f")){
            Write-Error "$f is not exists." -ErrorAction Stop
        }
        return
    }
    # is pandoc command exist?
    function isCommandExist ([string]$cmd) {
      try { Get-Command $cmd -ErrorAction Stop | Out-Null
          return $True
      } catch {
          return $False
      }
    }
    # private function
    filter TrimLine {
        return "$($_.Trim())"
    }
    filter DeleteComment {
        if ($_ -match '^\s*#'){
            return ''
        } else {
            $_ = $_ -replace '#.*[^"'']$'
            return "$_"
        }
    }
    filter SkipEmpty {
        if ($_ -ne ''){ return "$_" }
    }
    [string] $sQuote       = "'"
    [string] $dQuote       = '"'
    [string] $comma        = ','
    [string] $bracketBegin = '['
    [string] $bracketClose = ']'
    [string] $braceBegin   = '{'
    [string] $braceClose   = '}'
    [string] $repComma        = "@@@c@o@m@m@a@@@"
    [string] $repBracketBegin = "@@@b@r@a@c@k@e@t@B@e@g@i@n@@@"
    [string] $repBracketClose = "@@@b@r@a@c@k@e@t@c@l@o@s@e@@@"
    [string] $repBraceBegin   = "@@@b@r@a@c@e@b@e@g@i@n@@@"
    [string] $repBraceClose   = "@@@b@r@a@c@e@c@l@o@s@e@@@"

    function QuoteValue {
        Param(
            [parameter(Mandatory=$True)]
            [string] $vStr
        )
        #return $vStr
        $v = $vStr.Trim()
        [bool] $sQuoteFlag  = $False
        [bool] $dQuoteFlag  = $False
        [bool] $bracketFlag = $False
        [bool] $braceFlag   = $False
        [int] $sQuoteCnt  = 0
        [int] $dQuoteCnt  = 0
        [int] $bracketCnt = 0
        [int] $braceCnt   = 0
        [int] $wCnt       = 0
        [string[]] $lineAry = @()
        if ($v -match '^"|^'''){
            [string] $wLine = $v
        } elseif (($v -match $sQuote) `
            -or ($v -match $dQuote) `
            -or ($v -match '\[') `
            -or ($v -match '\{')
        ){
            $v.GetEnumerator() | ForEach-Object {
                $wCnt++
                [string] $w = [string] $_
                # in quote or not?
                if ($w -eq $sQuote){
                    $sQuoteCnt++
                    if( ($sQuoteCnt % 2) -eq 1){
                        $sQuoteFlag = $True
                    } else {
                        $sQuoteFlag = $False
                    }
                }
                if ($w -eq $dQuote){
                    $dQuoteCnt++
                    if( ($dQuoteCnt % 2) -eq 1){
                        $dQuoteFlag = $True
                    } else {
                        $dQuoteFlag = $False
                    }
                }
                if (($w -eq $bracketBegin) -and ((-not $sQuoteFlag) -and (-not $dQuoteFlag))){
                    if ($wCnt -eq 1){
                        $bracketFlag = $False
                    } else {
                        $bracketCnt++
                        $bracketFlag = $True
                    }
                }
                if ($w -eq $bracketClose){
                    $bracketCnt--
                    if ($bracketCnt -eq 0){
                        $bracketFlag = $False
                    }
                }
                if (($w -eq $braceBegin) -and ((-not $sQuoteFlag) -and (-not $dQuoteFlag))){
                    if ($wCnt -eq 1){
                        $braceFlag = $False
                    } else {
                        $braceCnt++
                        $braceFlag = $True
                    }
                }
                if ($w -eq $braceClose){
                    $braceCnt--
                    if ($braceCnt -eq 0){
                        $braceFlag = $False
                    }
                }
                if (($bracketFlag) -or ($braceFlag)) {
                    if ($w -eq $comma){
                        $lineAry += $repComma
                    } else {
                        $lineAry += $w
                    }
                } elseif ((-not $sQuoteFlag) -and (-not $dQuoteFlag)){
                    # outside quote
                    $lineAry += $w
                } else {
                    # inside quote
                    switch -Exact ($w){
                        "$comma"        {$lineAry += $repComma; break;}
                        "$bracketBegin" {$lineAry += $repBracketBegin; break;}
                        "$bracketClose" {$lineAry += $repBracketClose; break;}
                        "$braceBegin"   {$lineAry += $repBraceBegin; break;}
                        "$braceClose"   {$lineAry += $repBraceClose; break;}
                        default         {$lineAry += $w; break;}
                    }
                }
            }
            [string] $wLine = $lineAry -Join ''
            [string[]] $lineAry = @()
            if ($wLine -match '^\[|^\{'){
                if ($wLine -notmatch '\]$|\}$'){
                    Write-Error "not closed list or hash: $wLine" -ErrorAction Stop
                }
                $preBlacket = $wLine -replace '^(.)(.*)(.)$','$1'
                $wLineBody  = $wLine -replace '^(.)(.*)(.)$','$2'
                $sufBlacket = $wLine -replace '^(.)(.*)(.)$','$3'
                $itemsOfAry = $wLineBody -Split $comma
                foreach ($item in $itemsOfAry){
                    $item = $item.Trim()
                    if ($item -eq ''){
                        $lineAry += $item
                    } elseif ($item -match '^\[|^\{'){
                        # recursion for nested list and hash
                        $item = $item.Replace($repComma, $comma)
                        $lineAry += QuoteValue $item
                    } else {
                        if ($preBlacket -eq '['){
                            $lineAry += tranSTRING -Token $item -isArray:$True -isHash:$False
                        } else{
                            $lineAry += tranSTRING -Token $item -isArray:$False -isHash:$True
                        }
                    }
                }
                switch -regex ($wLine){
                    '^\[' {
                        $wLineBody = $lineAry -Join ', '
                        }
                    '^\{' {
                        if (-not $NoPoshListAndHash){
                            $wLineBody = $lineAry -Join '; '
                        } else {
                            $wLineBody = $lineAry -Join ', '
                        }
                        }
                    default {
                        Write-Error "unknown error: parse brace or bracket" -ErrorAction Stop
                        }
                }
                $wLine = $preBlacket + $wLineBody + $sufBlacket
                #$wLine = $wLine.Replace($repComma, ",")
            }
        } else {
            if ($v -eq ''){
                [string] $wLine = $v
            } else {
                [string] $wLine = tranSTRING -Token $v -isArray:$False -isHash:$False
            }
        }
        return $wLine
    }
    function Join-Line {
        Param(
            [parameter(Mandatory=$False, ValueFromPipeline=$True)]
            [string[]] $Text
        )
        begin {
            [bool] $insideObjectFlag = $False
            [bool] $insideHereStringFlag = $False
            [string[]] $befLineAry = @()
            $lineList = New-Object 'System.Collections.Generic.List[System.String]'
            [string] $befLineStr = ''
            [int] $rowCnt = 0
            [bool] $skipRowFlag = $False
        }
        process {
            # 1st pass
            $rowCnt++
            [string] $line = "$_".Trim()
            if ($skipRowFlag){
                $skipRowFlag = $False
                [string] $befLineStr = $line
            } elseif (($line -eq '}') -or ($line -eq ']')){
                # add close bracket end of before row
                if ($rowCnt -gt 1){
                    $befLineStr += $line
                    $lineList.Add($befLineStr)
                    $skipRowFlag = $True
                }
                [string] $befLineStr = 'None'
            } else {
                if ($rowCnt -gt 1){
                    $lineList.Add($befLineStr)
                }
                [string] $befLineStr = $line
            }
        }
        end {
            if (-not $skipRowFlag){
                $lineList.Add($befLineStr)
            }
            [string[]]$lineAry = @()
            $lineAry = $lineList.ToArray()
            # 2nd pass
            foreach ($line in $lineAry){
                if (($line -notmatch '"""$') -and ($insideHereStringFlag)){
                    $befLineAry += $line
                } elseif (($line -match '"""$') -and ($insideHereStringFlag)){
                    $insideObjectFlag = $False
                    $insideHereStringFlag = $False
                    $befLineAry += $line
                    if ($Simplify){
                        $writeLine = $befLineAry -Join "`n"
                    } else {
                        $writeLine = $befLineAry -Join "\n"
                        $writeLine = $writeLine.Replace('"""\n','"""').Replace('\n"""','"""').Replace('"""','')
                    }
                    [string[]] $befLineAry = @()
                    Write-Output $writeLine
                } elseif (($line -notmatch '\]$|\}$') -and ($insideObjectFlag)){
                    $befLineAry += $line
                } elseif (($line -match '\]$|\}$') -and ($insideObjectFlag)){
                    $insideObjectFlag = $False
                    $befLineAry += $line
                    $writeLine = $befLineAry -Join ''
                    $writeLine = $writeLine -replace ',*\s*\]',']' -replace ',*\s*\}','}'
                    $befLineAry = @()
                    Write-Output $writeLine
                } elseif (($line -match '"""$') -and (-not $insideHereStringFlag)){
                    $insideObjectFlag = $True
                    $insideHereStringFlag = $True
                    $befLineAry += $line
                } elseif (($line -match '\[$|\{$|,$')){
                    $insideObjectFlag = $True
                    $befLineAry += $line
                } else {
                    Write-Output $line
                }
            }
            # check close bracket
            if ($befLineAry.Length -ne 0){
                Write-Error "bracket is not closed." -ErrorAction Stop
            }
        }
    }
    function tranSTRING {
        param(
            [parameter(Mandatory=$True, Position=0)]
            [string] $Token,
            [parameter(Mandatory=$False)]
            [switch] $isArray,
            [parameter(Mandatory=$False)]
            [switch] $isHash
        )
        $Token = $Token.Trim()
        $double = New-Object System.Double
        $datetime = New-Object System.DateTime
        switch -Exact ($Token.ToString()) {
            "true"  { return $true }
            "false" { return $false }
            "yes"   { return $true }
            "no"    { return $false }
            "on"    { return $true }
            "off"   { return $false }
            "null"  { return $null }
            "nil"   { return $null }
            {[Double]::TryParse($Token.Replace('_',''), [ref]$double)} {
                return $double
            }
            {[Datetime]::TryParse($Token, [ref]$datetime)} {
                if ($DateFormat){
                    [string] $ret = Get-Date -Date $datetime -UFormat $DateFormat
                    return $ret
                } else {
                    return $datetime
                }
            }
            default {
                if ($Token -notmatch '^"|^''|^\[|^\{'){
                    if ($isHash){
                        return $Token
                    } elseif ($Quote){
                        return """$Token"""
                    } elseif ($isArray) {
                        return """$Token"""
                    } else {
                        return $Token
                    }
                } else {
                    return $Token
                }
            }
        }
    }
    
    function CreateMap {
    Param(
        [parameter(Mandatory=$False, ValueFromPipeline=$True)]
        [string[]] $Text
    )
        Begin {
            $initFlag = $True
            $o = [ordered]@{}
        }
        Process {
            [string] $line = [string] $_
            switch -regex ($line) {
                "^\[" {
                    # set name
                    $initFlag = $False
                    if ($o.Keys.Count -gt 0){ [PSCustomObject] $o }
                    $o = [ordered]@{}
                    if ($Quote){
                        $o["id"] = $line -replace '^\[','"' -replace '\]$','"'
                    } else {
                        $o["id"] = $line -replace '^\[','' -replace '\]$',''
                    }
                }

                '^\s*([^=]+)=(.*)$' {
                    # set the properties on the data object
                    $key, $val = $matches[1, 2]
                    [string] $key = $key.Trim()
                    [string] $val = $val.Trim()
                    if (($initFlag) -and ($o.Keys.Count -eq 0)){
                        if ($Quote){
                            $o["id"] = '"init"'
                        } else {
                            $o["id"] = "init"
                        }
                        $initFlag = $False
                    }
                    if (($val -match '^""$') -or ($val -match "^''$")){
                        $val = ''
                    } else {
                        $val = QuoteValue $val
                        if ((-not $NoPoshListAndHash) -or ($Execute) -or ($ToJson)){
                            $val = $val.Replace('[','@(').Replace(']',')')
                            $val = $val.Replace('{','@{')
                        }
                        $val = $val.Replace($repComma, $comma)
                        $val = $val.Replace($repBracketBegin, $bracketBegin)
                        $val = $val.Replace($repBracketClose, $bracketClose)
                        $val = $val.Replace($repBraceBegin, $braceBegin)
                        $val = $val.Replace($repBraceClose, $braceClose)
                    }
                    if (($Execute) -or ($ToJson)){
                        if ($val -match '^@'){
                            $oItem = Invoke-Expression -Command "$val"
                        } else {
                            $oItem = $val
                        }
                    } else {
                        $oItem = $val
                    }
                    $o["$key"] = $oItem
                }
                default {
                    Write-Error "parse error: no key=value line detected" -ErrorAction Stop
                }
            }
        }
        End {
            if ($o.Keys.Count -gt 0){
                [PSCustomObject] $o
            }
        }
    }
    # main
    # set contents
    if($File){
        # test input file
        isFileExists "$File"
        $contents = Get-Content -LiteralPath $File -Encoding UTF8
    } else {
        # read from stdin
        $contents = @($input)
    }
    # parse toml
    if ($Simplify) {
        $contents `
            | DeleteComment `
            | TrimLine `
            | SkipEmpty `
            | Join-Line
    } elseif ($ToJson) {
        $contents `
            | DeleteComment `
            | TrimLine `
            | SkipEmpty `
            | Join-Line `
            | CreateMap `
            | ConvertTo-Json -Depth $JsonDepth
    } else {
        $contents `
            | DeleteComment `
            | TrimLine `
            | SkipEmpty `
            | Join-Line `
            | CreateMap
    }
}
