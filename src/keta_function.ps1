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
        $leftFlag = $false
        # get args
        if(($args.Count) -and ([string]$args[0] -eq '-l')){
            $leftFlag = $true
        }
        # init variables
        $sp = ''
        $writeLine = ''
        $readRow = 0
        $hashRow = @{}
        # 列毎の文字バイト数格納ハッシュ
        $hashColByte = @{}
    }

    process
    {
        # 1st pass
        $readRow++
        $splitLine = $_ -Split ' '

        # 列数の取得
        if($readRow -eq 1){$retu = $splitLine.Count}

        # 列毎の文字数取得
        for($i = 0; $i -lt $splitLine.Count; $i++){

            # 対象文字列にシングルクオートがあると.GetByteCountで
            # エラーになるため、シングルクオートはあらかじめエスケープしておく

            # シングルクオートの計数
            $quotnum = 0
            $colStr = $splitLine[$i]
            $s = $colStr
            for($k = 0; $k -lt $s.Length; $k++){
                if([string]$s[$k] -eq "'"){ $quotnum-- }
            }

            # シングルクオートのエスケープ
            $colStr = [string]$colStr -Replace "'","@a@a@"
            #Write-Output $colStr

            $ex = '[System.Text.Encoding]::GetEncoding("Shift_Jis").GetByteCount(' + "'" + $colStr + "'" + ')'
            $strByte = Invoke-Expression "$ex"
            $strByte = [int]$strByte + ( [int]$quotnum * 4 )            
            #Write-Output $strByte
            #Write-Output $hashColByte[$i]

            # 最大文字バイト数の取得
            if([int]$strByte + 0 -gt [int]($hashColByte[$i]) + 0){
                $hashColByte[$i] = [int]$strByte
            }
        }

        # 行をハッシュに格納
        $hashRow[$readRow] = [string]$_
    }

    end
    {
        # 2nd pass
        for($i = 1; $i -le $readRow; $i++){
            # 行の再読み込みと文字Byte数の取得
            $splitLine = $hashRow[$i] -Split ' '

            # 列毎の文字数取得
            for($j = 0; $j -lt $splitLine.Count; $j++){
                
                # 対象文字列にシングルクオートがあると.GetByteCountで
                # エラーになるため、シングルクオートはあらかじめエスケープしておく

                # シングルクオートの計数
                $quotnum = 0
                $colStr = $splitLine[$j]
                $s = $colStr
                for($k = 0; $k -lt $s.Length; $k++){
                    if([string]$s[$k] -eq "'"){ $quotnum-- }
                }

                # シングルクオートのエスケープ
                $colStr = [string]$colStr -Replace "'","@a@a@"
                #Write-Output $colStr

                $ex = '[System.Text.Encoding]::GetEncoding("Shift_Jis").GetByteCount(' + "'" + $colStr + "'" + ')'
                $strByte = Invoke-Expression "$ex"
                $strByte = [int]$strByte + ( [int]$quotnum * 4 )
                #Write-Output $strByte

                # シングルクオートのエスケープ解除
                $colStr = [string]$colStr -Replace "@a@a@","'"

                # ゼロ埋めメイン処理
                $setByteNum = [int]$hashColByte[$j] - [int]$strByte
                if($setByteNum -le 0){$setByteNum = 0}

                for($k = 1; $k -le $setByteNum; $k++){
                    $sp = [string]$sp + ' '
                }

                # 左詰めか右詰か
                if($leftFlag){
                    $tmpWriteLine = [string]$colStr + $sp
                }else{
                    $tmpWriteLine = $sp + [string]$colStr
                }
                $sp = ''

                # 出力文字列の生成
                if($j -eq 0){
                    $writeLine = [string]$tmpWriteLine
                }else{
                    $writeLine = [string]$writeLine + ' ' + [string]$tmpWriteLine
                }
            }
            Write-Output $writeLine
            $writeLine = ''
        }
    }
}
