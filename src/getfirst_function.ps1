<#
.SYNOPSIS

getfirst - Get the first row of the same key

半角スペース区切り入力から、
同一キーの最初行のデータを出力。
大文字小文字を区別しない

getfirst <k1> <k2>

.EXAMPLE
cat a.txt
01 埼玉県 01 さいたま市 100
01 埼玉県 02 川越市 100
01 埼玉県 03 熊谷市 100
02 東京都 04 新宿区 100
02 東京都 05 中央区 100
02 東京都 06 港区 100
02 東京都 07 千代田区 100
02 東京都 08 八王子市 100
02 東京都 09 立川市 100
03 千葉県 10 千葉市 100
03 千葉県 11 市川市 100
03 千葉県 12 柏市 100
04 神奈川県 13 横浜市 100
04 神奈川県 14 川崎市 100
04 神奈川県 15 厚木市 100
04 神奈川県 16 小田原市 100

cat a.txt | getfirst 1 2
01 埼玉県 01 さいたま市 100
02 東京都 04 新宿区 100
03 千葉県 10 千葉市 100
04 神奈川県 13 横浜市 100

#>
function getfirst {
    begin
    {
        [string] $Delimiter = ' '
        # test args
        if($args.Count -ne 2){
            Write-Error "not enough arguments." -ErrorAction Stop }
        [int] $k1 = [int]($args[0]) - 1
        [int] $k2 = [int]($args[1]) - 1
        if (($k1 -lt 0) -or ($k2 -lt 0)){
            Write-Error "Specify an integer greater equal to 1" -ErrorAction Stop
        }
        if ($k2 -lt $k1){
            Write-Error "$k2 less than $k1." -ErrorAction Stop
        }
        # init key hashtable
        [int] $ver = $PSVersionTable.PSVersion.Major
        if($ver -le 2){
            $hash = @{}
        }else{
            $hash = [ordered]@{}
        }
    }
    process
    {
        [string] $readLine = [string] $_
        $splitLine = $readLine -Split "$Delimiter"
        if ($k2 -gt $splitLine.Count - 1){
            Write-Error "More than the number of columns was specified" -ErrorAction Stop
        }
        [string] $key = $splitLine[($k1..$k2)]
        if( -not ($hash.Contains("$key")) ){
            $hash["$key"] = $readLine
        }
    }
    end
    {
        foreach ($k in $hash.Keys){
            [string] $val = $hash[$k]
            Write-Output $val
        }
    }
}
