<#
.SYNOPSIS
    toml2psobject - A parser for toml-like configuration files

    Parse TOML-like setting file and return it as a PSCustomObject.
    
        TOML https://toml.io/en/

    Array and hash can store multiple row elements,
    so It may be possible to express infomation that
    is difficult to express in "one line, one record
    format" such as CSV.

    You can convert the output by pipe to ConvertTo-Json,
    ConvertTo-Csv, etc. This assumes that people who can't
    use PowerShell to export and reuse the setting information.

    Usage:
        cat a.toml | toml2psobject
        cat a.toml | toml2psobject -Execute | ConvertTo-Json
        toml2psobject a.toml

    Input:
        ## comment
        [aiue.o]
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

    Output:
        # note: [label] is recognized as "id"="label")
        # instead of not being able to specify key,
        # multibyte characters and symbols can be used as labels.
            id    : aiue.o
            bumon : haccp
            cat   : "haccp"
            act   : review
            freq  : weekly
            tag   : ["haccp", "verification"]
            stat  : True
            ref   : 224617.445991228
            link  : {y2021="https://github.com/", y2022="https://github.com/", rep = ["hoge", "fuga"]}
            note  : multi-line note1
                    multi-line note2
                    multi-line note3
    
    Note:
        The expected input: First, the id is indicated by [string],
        and the elements hanging from it are enumerated in the
        key=value format.

        Blank lines are optional(ignored).

        [string] is recognized as id = "string" (key-name = "id").
        In the case of TOML: key-name = "string".
        This is one of the parts where the behaviour differs between
        this function and TOML. Instead, unlike TOML, you can use
        multibyte characters and symbols inside [ ]. On the
        other hand, you cannot nest keys by joining them with dots.
        (it is interpreted as just strings)
        
            ok...use multibyte strings and symbols inside [ ] 
            ng...[hoge.fuga.piyo] is interpreted as just strings:
                 like id="hoge.fuga.piyo"
        
        Automatic recognition of data types:
            Elements of the input data is automatically recognized
            in the following format:

                string    System.String
                decimal   System.Double
                boolean   System.Boolean
                datetime  System.Datetime
                null      $Null
                Array     System.Collections.ArrayList
                HashTable System.Collections.Hashtable
        
            - String types are automatically recognized without
              double quotes. 
            - However, since the type of hash-value (right side
              of "=") is not automatically recognized. So it is
              safe to double-quote the strings on the hash-value.
            - Note that double-quote will be escaped when connecting
              to ConvertTo-Json, etc.
            - float(double) type may use underscore "_" as delimiter.
        
        Margins (white spaces):
            - left margin of key is optional.
            - There can be any number of spaces before and after "="
        
        Arrays and hashes:
            - Arrays are expressed as [elem, elem,...].
            - Hashes are expressed as {key="val", key="val",...}.
            - Arrays and hashed can be nested.
        
        Comment:
            - The comment symbol is "#".
            - Multi-line comments are not supported.
            - Do not comment out if the rightmost character is
              double quote or single quote. This case is interpreted
              as a # in a string element such as
                - "# this is not a commnent".
            - However, the following cases are not regaded ascomments,
              so be careful.
                - key = val ## note grep "hoge"
            - Any line starting with "#" and white-spaces on the left
              is treated as a comment line regardless of the rightmost
              character.
        
        Element with LineFeed:
            - Strings with linefeed can be stored by enclosing them in
              three double quotes like following
                note="""
                this is
                multi line
                note
                """
            - linefeeds are represented by the symbol specified by
              "-LineSeparator" option.
                - default "`n" (as special character)
                - If you specify a simple string(not a special character)
                  such as "\n", it will be concatenated into one line.
            - If "\n"(string) is found inside the element,
              replace it with "`n".
                - Substitution string can be changed with
                  "-LineSeparator" option.
            - reference about PowerShell's special characters
                - https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_special_characters
        
        Line breaks within elements:
            If the end of the line is "{" or "[" or ",", it is considered
            as multiple lines. for example:

                ref = {name="hoge", prop="fuga"}
            
            is equivalent to following:
            
                ref = {
                    name="hoge",
                    prop="fuga"
                }
            
            The comma in the last element is ignored,
            so It doesn't matter if it's there or not:

                ref = {
                    name="hoge",
                    prop="fuga",  ## this comma will be ignored.
                }
            
            A closing parenthesis may be attached to the last
            element:
            
            ref = {
                name="hoge",
                prop=[1, 2]} ## it is OK to write like this.
            
            When using hash, make the key strings instead of a number,
            or wrap the key in double quotes. If the value is strings,
            wrap it in double quotes. Then you can link with
            ConvertTo-Json etc with pipelines.
            
                ref = {
                      name="hoge",
                      prop="fuga",
                      }
    
    Options:
        -Execute : Recognize array and has as PowerShell Objects.
            (array and hash are output as strings by default) 
            Specify when applying ConvertTo-Json etc. If the purpose
            is to convert to Json format, You can use "-ToJson" switch.
        
        -ToJson : Return as Json format.
        
        -DateFormat '%Y-%m-%d (%a)' : Allows to specify the date and time
            format in Unix format. When using hyphens etc, Invoke-Expression
            can be done by quote whole value.
        
        -Quote : Quote the strings. Strings in arrays are
            automatically quoted, but in hashes are not
            automatically quoted. (If the hash value contains
            symbols, quote them yourself).
            In any case, note that array elements are parsed
            for their daya types, but hash elements are not
            parsed and are output as is.

    Input example:
        Here is another example of a TOML-like input.
        Note that even with [server.alpha] line TOML,
        the parent-child relationship between elements
        cannot be expressed.

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

.LINK
    convToml, mdgrep

.PARAMETER NoPoshListAndHash
    Represent arrays and hashed in TOML format
    instead of PowerShell format.

.EXAMPLE
    cat example1.toml
    ## comment
    [aiue.o]
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

    PS > cat example1.toml | toml2psobject -NoPoshListAndHash | fl
    id    : aiue.o
    bumon : haccp
    cat   : "haccp"
    act   : review
    freq  : weekly
    tag   : ["haccp", "verification"]
    stat  : True
    ref   : 224617.445991228
    link  : {y2021="https://github.com/", y2022="https://github.com/", rep = ["hoge", "fuga"]}
    note  : multi-line note1
            multi-line note2
            multi-line note3


    PS > cat example1.toml | toml2psobject -Simplify
    [aiue.o]
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

    PS > cat example1.toml | toml2psobject -Execute | ConvertTo-Json
    PS > cat example1.toml | toml2psobject -ToJson -JsonDepth 10
    {
      "id": "aiue.o",
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
        "y2021": "https://github.com/",
        "y2022": "https://github.com/",
        "rep": [
          "hoge",
          "fuga"
        ]
      },
      "note": "multi-line note1\nmulti-line note2\nmulti-line note3"
    }


    Description
    ==============
    When converting to Jsonformat with ConvertTo-Json,
    use "-Execute" option to convert arrays and hashes
    text representation to objects.

    Values of float(double) type are also quoted.
    If the input element is already double-quoted,
    the double-quotes are escaped.
    ("hoge" escaped to "\"hoge\"")

#>
function toml2psobject {
    Param(
        [parameter(Mandatory=$False, Position=0)]
        [string] $File,
        
        [parameter(Mandatory=$False)]
        [string] $LineSeparator = "`n",
        
        [parameter(Mandatory=$False)]
        [switch] $DoNotReplaceLineSeparator,
        
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
            [parameter(Mandatory=$False)]
            [string] $vStr = ''
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
    function JoinLine {
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
                        if ( $DoNotReplaceLineSeparator ){
                            #pass
                        } else {
                            # replace '\n' to "`n"
                            $val = $val.Replace('\n', $LineSeparator)
                        }
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
            | JoinLine
    } elseif ($ToJson) {
        $contents `
            | DeleteComment `
            | TrimLine `
            | SkipEmpty `
            | JoinLine `
            | CreateMap `
            | ConvertTo-Json -Depth $JsonDepth
    } else {
        $contents `
            | DeleteComment `
            | TrimLine `
            | SkipEmpty `
            | JoinLine `
            | CreateMap
    }
}
