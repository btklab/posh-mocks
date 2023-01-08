<#
.SYNOPSIS
桁 - 標準出力の整形

列ごとに文字数に合わせて半角スペース埋めにて右詰め表示する。
端末上で標準出力を目視確認しやすくなる。

keta [-l]

 -l:左詰め（Left）

.DESCRIPTION
-

.EXAMPLE
PS C:\>cat a.txt
01 埼玉県 01 さいたま市 100
01 埼玉県 02 川越市 100
01 埼玉県 03 熊谷市 100
02 東京都 04 新宿区 100
02 東京都 05 中央区 100
02 東京都 06 港区 100
02 東京都 07 八王子市 100
02 東京都 08 立川市 100
03 千葉県 09 千葉市 100
03 千葉県 10 市川市 100
03 千葉県 11 柏市 100
04 神奈川県 12 横浜市 100
04 神奈川県 13 川崎市 100
04 神奈川県 14 厚木市 100

PS C:\>cat a.txt | keta
01   埼玉県 01 さいたま市 100
01   埼玉県 02     川越市 100
01   埼玉県 03     熊谷市 100
02   東京都 04     新宿区 100
02   東京都 05     中央区 100
02   東京都 06       港区 100
02   東京都 07   八王子市 100
02   東京都 08     立川市 100
03   千葉県 09     千葉市 100
03   千葉県 10     市川市 100
03   千葉県 11       柏市 100
04 神奈川県 12     横浜市 100
04 神奈川県 13     川崎市 100
04 神奈川県 14     厚木市 100

#>
function keta {

    begin
    {
        # get args
        if(($args.Count) -and ([string]$args[0] -eq '-l')){
            $leftPaddingFlag = $True
        } else {
            $leftPaddingFlag = $False
        }
        # init variables
        [string] $Delimiter = ' '
        [string] $sp = ''
        [string] $writeLine = ''
        [int] $readRow = 0
        $hashRow = @{}
        # hashtable for storing the number of character bytes for each column
        $hashColByte = @{}
    }

    process
    {
        # 1st pass
        $readRow++
        $line = [string] $_
        $hashRow[$readRow] = $line
        $splitLine = $line -Split $Delimiter

        # get number of columns
        if($readRow -eq 1){$retu = $splitLine.Count}

        # get number of character width for each column
        for($i = 0; $i -lt $splitLine.Count; $i++){
            [string] $colStr = $splitLine[$i]
            [int] $colWidth = [System.Text.Encoding]::GetEncoding("Shift_Jis").GetByteCount($colStr)

            # get max column width for each column
            if([int]($colWidth) + 0 -gt [int]($hashColByte[$i]) + 0){
                $hashColByte[$i] = $colWidth
            }
        }
    }

    end
    {
        # 2nd pass
        for($i = 1; $i -le $readRow; $i++){
            # reload the line and getting the number of character width
            $splitLine = $hashRow[$i] -Split $Delimiter

            # get number of character width per column
            for($j = 0; $j -lt $splitLine.Count; $j++){
                [string] $colStr = $splitLine[$j]
                [int] $colWidth = [System.Text.Encoding]::GetEncoding("Shift_Jis").GetByteCount($colStr)

                # padding
                [int] $setByteNum = [int]($hashColByte[$j]) - [int]($colWidth)
                if($setByteNum -le 0){$setByteNum = 0}

                for($k = 1; $k -le $setByteNum; $k++){
                    $sp = $sp + ' '
                }

                # left padding or right padding?
                if($leftPaddingFlag){
                    [string] $tmpWriteLine = $colStr + $sp
                }else{
                    [string] $tmpWriteLine = $sp + $colStr
                }
                $sp = ''

                # output
                if($j -eq 0){
                    $writeLine = $tmpWriteLine
                }else{
                    $writeLine = $writeLine + $Delimiter + $tmpWriteLine
                }
            }
            Write-Output $writeLine
            $writeLine = ''
        }
    }
}
