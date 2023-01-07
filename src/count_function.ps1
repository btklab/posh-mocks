<#
.SYNOPSIS

count - Count up keys

半角スペース区切り入力から、
同じキーの行数をカウントする。

大文字小文字を区別しない。
キー列での事前ソートが必要。

count [-c] <k1> <k2>

標準入力テキストの<k1>列から<k2>列をキーフィールドとし、
キーフィールドの値が同じ行(行)の数を出力する。

デフォルトで一意のキー数を出力。
-cスイッチで同じキーをカウントアップしながら全行出力。


.EXAMPLE
PS> cat a.txt
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

PS> cat a.txt | grep . | sort | count 1 2
3 01 埼玉県
6 02 東京都
3 03 千葉県
4 04 神奈川県


PS> cat a.txt | grep . | sort | count -c 1 2
1 01 埼玉県 01 さいたま市 100
2 01 埼玉県 02 川越市 100
3 01 埼玉県 03 熊谷市 100
1 02 東京都 04 新宿区 100
2 02 東京都 05 中央区 100
3 02 東京都 06 港区 100
4 02 東京都 07 千代田区 100
5 02 東京都 08 八王子市 100
6 02 東京都 09 立川市 100
1 03 千葉県 10 千葉市 100
2 03 千葉県 11 市川市 100
3 03 千葉県 12 柏市 100
1 04 神奈川県 13 横浜市 100
2 04 神奈川県 14 川崎市 100
3 04 神奈川県 15 厚木市 100
4 04 神奈川県 16 小田原市 100

#>
function count {

    begin
    {
        # parse args
        if($args.Count -lt 2){
            Write-Error "Insufficient arguments." -ErrorAction Stop
        }elseif ($args[0] -eq "-c"){
            if($args.Count -lt 3){
                Write-Error "Insufficient arguments." -ErrorAction Stop }
            [boolean] $oFlag = $True
            [int] $k1 = $args[1] - 1
            [int] $k2 = $args[2] - 1
        }else{
            [boolean] $oFlag = $False
            [int] $k1 = $args[0] - 1
            [int] $k2 = $args[1] - 1
        }

        # row counter
        $readRow = 0

        # key counter
        $keyCount = 0

        # init var
        $writeLine = ""
        $Delimiter = " "
    }

    process
    {
        $readRow++
        [string] $line = [string] $_
        [string[]]$splitLine = $line -Split "$Delimiter"
        # create key string
        [string] $key = $splitLine[($k1..$k2)] -Join "$Delimiter"
        # reset count if key changed
        if($readRow -gt 1){
            if ($oFlag){
                [string] $writeLine = [string] $keyCount + "$Delimiter" + $lastline
                Write-Output "$writeLine"
            } else {
                if($key -ne $lastkey){
                    [string] $writeLine = [string]$keyCount + "$Delimiter" + $lastkey
                    Write-Output "$writeLine"
                }
            }
            if($key -ne $lastkey){
                $keyCount = 0
            }
        }
        [string] $lastkey = $key
        [string] $lastline = $line
        # count up key num
        $keyCount += 1
    } # end of process block

    end
    {
        if ($oFlag){
            [string] $writeLine = [string] $keyCount + "$Delimiter" + $lastline
        } else {
            [string] $writeLine = [string] $keyCount + "$Delimiter" + $lastkey
        }
        Write-Output "$writeLine"
    }

}

