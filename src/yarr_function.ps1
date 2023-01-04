<#
.SYNOPSIS

yarr - Expand vertical data to horizontal

縦型（ロング型）の半角スペース区切りレコードを
指定列をキーに横型（ワイド型）に変換する。

指定列をキーとして横に並べる
事前ソート不要
大文字小文字を区別しない

.EXAMPLE
cat a.txt
2018 3
2018 3
2018 3
2017 1
2017 1
2017 1
2017 1
2017 1
2022 5
2022 5

PS> cat a.txt | grep . | yarr -n 1
2018 3 3 3
2017 1 1 1 1 1
2022 5 5

※ grep . で空行をスキップ（＝1文字以上の行のみヒット）



.EXAMPLE
PS C:\>cat a.txt | yarr -n 2
1列目から2列目をキーとして折り返す

#>
function yarr {
    Param(
        [Parameter(Position=0,Mandatory=$False)]
        [Alias('n')]
        [int] $num = 1,

        [Parameter(Mandatory=$False)]
        [ValidateSet( " ", ",", "\t")]
        [string] $Delimiter = ' ',

        [parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [string[]] $Text
    )

    begin {
        ## init var
        $hash = [ordered] @{}
    }
    process {
        [string]$line = $_
        # is line empty?
        if ($line -eq ''){
            Write-Error "detect empty row: $line" -ErrorAction Stop
        }
        # split key
        $keyValAry = $line -split "$Delimiter"
        if ($keyValAry.Count -le $num){
            Write-Error "Detect key-only lines: $line"  -ErrorAction Stop
        }
        # set key, val into hashtable
        [int] $sKey = 0
        [int] $eKey = $num - 1
        [int] $sVal = $eKey + 1
        [int] $eVal = $keyValAry.Count - 1
        [string] $key = $keyValAry[($sKey..$eKey)] -Join "$Delimiter"
        [string] $val = $keyValAry[($sVal..$eVal)] -Join "$Delimiter"
        if ($hash.Contains($key)){
            # if key already exist
            $val = $hash["$key"] + "$Delimiter" + $val
            $hash["$key"] = $val
        } else {
            $hash.Add($key, $val)
        }
    }
    end {
        # output hash
        foreach ($k in $hash.keys){
            [string] $writeLine = $k + "$Delimiter" + $hash["$k"]
            Write-Output $writeLine
        }
    }
}
