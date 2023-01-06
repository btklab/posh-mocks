<#
.SYNOPSIS

tarr - Expand wide data to long

横長（ワイド型）の半角スペース区切りレコードを、
指定列をキーに縦長（ロング型）に変換する。

ヘッダなし半角スペース区切り入力を期待。
事前ソート不要。
大文字小文字を区別しない。

.EXAMPLE
cat a.txt
2018 1 2 3
2017 1 2 3 4
2022 1 2

PS> cat a.txt | grep . | tarr -n 1
2018 1
2018 2
2018 3
2017 1
2017 2
2017 3
2017 4
2022 1
2022 2

※ grep . で空行をスキップ（＝1文字以上の行のみヒット）

.EXAMPLE
PS C:\>cat a.txt | tarr -n 2
1列目から2列目をキーとして折り返す

#>
function tarr {
    Param(
        [Parameter(Position=0,Mandatory=$False)]
        [Alias('n')]
        [int] $num = 1,

        [Parameter(Mandatory=$False)]
        [ValidateSet( ' ', ',', "\t")]
        [string] $Delimiter = ' ',

        [parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [string[]] $Text
    )
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
		foreach ($val in $keyValAry[($sVal..$eVal)]){
			[string] $writeLine = $key + "$Delimiter" + $val
			Write-Output $writeLine
		}
    }
}
