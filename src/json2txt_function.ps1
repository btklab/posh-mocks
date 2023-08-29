<#
.SYNOPSIS
    json2txt - transform json into key-value format with one record per line.

    Convert Json format to one record per element for easy grep.
    Reverse conversion is not possible.

    Use ConvertFrom-Json -AsHashTable implemented in
    PowerShell 7.3 or later.

    Inspired by:

        - tomnomnom/gron: Make JSON greppable! - GitHub
            - https://github.com/tomnomnom/gron
        
        - jiro4989/gsv: gsv transforms a multi-line CSV into one-line JSON to make it easier to grep - GitHub
            - https://github.com/jiro4989/gsv

.LINK
    csv2txt

.EXAMPLE
    cat a.json
    {"widget": {
        "debug": "on",
        "window": {
            "title": "Sample Konfabulator Widget",
            "name": "main_window",
            "width": 500,
            "height": 500
        },
        "image": {
            "src": "Images/Sun.png",
            "name": "sun1",
            "hOffset": 250,
            "vOffset": 250,
            "alignment": "center"
        },
        "text": {
            "data": "Click Here",
            "size": 36,
            "style": "bold",
            "name": "text1",
            "hOffset": 250,
            "vOffset": 100,
            "alignment": "center",
            "onMouseUp": "sun1.opacity = (sun1.opacity / 100) * 90;"
        }
    }}

    from: https://json.org/example.html


    PS > cat a.json | json2txt
    (dot)widget.debug = on
    (dot)widget.window.title = "Sample Konfabulator Widget"
    (dot)widget.window.name = "main_window"
    (dot)widget.window.width = 500
    (dot)widget.window.height = 500
    (dot)widget.image.src = "Images/Sun.png"
    (dot)widget.image.name = "sun1"
    (dot)widget.image.hOffset = 250
    (dot)widget.image.vOffset = 250
    (dot)widget.image.alignment = "center"
    (dot)widget.text.data = "Click Here"
    (dot)widget.text.size = 36
    (dot)widget.text.style = "bold"
    (dot)widget.text.name = "text1"
    (dot)widget.text.hOffset = 250
    (dot)widget.text.vOffset = 100
    (dot)widget.text.alignment = "center"
    (dot)widget.text.onMouseUp = "sun1.opacity = (sun1.opacity / 100) * 90;"


    PS > (cat a.json | ConvertFrom-Json).firstName
    John

#>
function json2txt {
    #Requires -Version 7.3

    Param(
        [Parameter(Position=0,Mandatory=$False)]
        [Alias('p')]
        [regex] $Pattern,

        [parameter(Mandatory=$False)]
        [Alias('f')]
        [string] $File,

        [parameter(Mandatory=$False)]
        [string] $DateFormat,

        [parameter(Mandatory=$False)]
        [switch] $AsObject,

        [parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [string[]] $Text
    )

    # private functions
    ## is file exists?
    function isFileExists ([string]$f){
        if(-not (Test-Path -LiteralPath "$f")){
            Write-Error "$f is not exists." -ErrorAction Stop
        }
        return
    }
    ## format value
    function FormatVal {
        param(
            [parameter(Mandatory=$True, Position=0)]
            [string] $Token
        )
        $Token = $Token.Trim()
        $double = New-Object System.Double
        $datetime = New-Object System.DateTime
        switch -Exact ($Token.ToString()) {
            "true"  { return "true" }
            "false" { return "false" }
            "yes"   { return "yes" }
            "no"    { return "no" }
            "on"    { return "on" }
            "off"   { return "off" }
            "null"  { return "null" }
            "nil"   { return "nill" }
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
                if ($Token -notmatch '^".*"$|^''.*''$'){
                    return """$Token"""
                } else {
                    return $Token
                }
            }
        }
    }
    ## is key Array or Hash?
    function retArrayOrHashOrValue ($obj){
        # ref: PowerTip: Find if Variable Is Array
        # https://devblogs.microsoft.com/scripting/powertip-find-if-variable-is-array/
        try {
            if ($obj -is [Array]){
                return "Array"
            } elseif ($obj.GetType().Name -match 'HashTable' ){
                return "Hash"
            } else {
                return "Value"
            }
        } catch {
            # if Null
            return "Null"
        }
        return "None"
    }
    ## quote key strings
    function quoteKey ([string] $key){
        [string] $ret = $key
        if ( $ret -match ' |\-|\(|\)|\[|\]|\{|\}|\$'){
           $ret = """$ret"""
           $ret = $ret -replace '\$','$'
        }
        return $ret
    }
    ## transform json into key-value format
    function TransJsonKey ($contents, [string]$key){
        Write-Debug $key
        $exp = '$contents' + '.' + $key
        #Write-Debug $exp
        if ($exp -match 'PS'){
            [string[]] $expAry = @()
            $splitExp = $exp.Split('.')
            foreach ($i in $splitExp){
                if ($i -match 'PS'){
                    $expAry += """$i"""
                } else {
                    $expAry += $i
                }
            }
            $exp = $expAry -Join '.'
        }
        Write-Debug $exp
        $con = Invoke-Expression $exp
        switch -Exact (retArrayOrHashOrValue $con) {
            "Array" {
                foreach ($i in $con){
                    if ($i.GetType().Name -match 'HashTable'){
                        # item is hashtable
                        foreach ($k in $i.keys){
                            $k = quoteKey $k
                            $k = "$key.$k"
                            TransJsonKey $contents $k
                        }
                        break;
                    } elseif ($i.GetType().BaseType -eq 'System.Array'){
                        # item is array
                        foreach ($a in $i){
                            ".$key = $a"
                        }
                    } else {
                        # item is value
                        if (($i -eq "") -or ($i -eq '""')){
                            $val = '""'
                        } else {
                            $val = FormatVal $i
                        }
                        Write-Output ".$key = $val"
                    }
                }
                break;
                #return ".$key = array"
            }
            "Hash"  {
                foreach ($k in $con.keys){
                    $k = quoteKey $k
                    [string] $hkey = "$key.$k"
                    TransJsonKey $contents "$hkey"
                }
                break;
                #return ".$key = hash"
            }
            "Value" {
                if ($con -eq ""){
                    $val = '""'
                } else {
                    $val = FormatVal $con
                }
                Write-Output ".$key = $val"
                break;
            }
            "Null" {
                $val = FormatVal "null"
                Write-Output ".$key = $val"
                break;
            }
            default {
                if ($con -eq ""){
                    $val = '""'
                } else {
                    $val = FormatVal $con
                }
                Write-Output ".$key = $val"
                break;
            }
        }
    }
    # get contents
    if($File){
        # test input file
        isFileExists "$File"
        $contents = Get-Content -Raw -LiteralPath $File -Encoding UTF8 `
            | ConvertFrom-Json -AsHashTable:$True
    } else {
        # read from stdin
        $contents = @($input) `
            | ConvertFrom-Json -AsHashTable:$True
    }
    if ( $AsObject ){
        $contents
    } else {
        foreach ($key in $contents.keys){
            $key = quoteKey $key
            TransJsonKey $contents $key
        }
    }
}
