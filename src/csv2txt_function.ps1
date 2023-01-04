<#
.SYNOPSIS
CSVデータをSSVに変換する

csv2txt [-z|-NaN]

-z :データのない列をゼロ0で表現する
-NaN :データのない列をNaNで表現する

.DESCRIPTION
エクセルからのCSV出力にも対応している
セル内改行vbLFは文字列\nに変換される

変換上の注意点
--------------------------------
 * 空白区切りでフィールド、改行でレコードを表現する
 * データ中の\は\\に変換する
 * データ中の改行コードは文字列\nに変換する
 * データ中の半角スペースは_に変換する
 * データ中のアンダーバー_は\_に変換する
 * データのないフィールドはアンダーバーで表現する

入力されるCSVファイルの構造
--------------------------------
 * フィールドをカンマで区切る。レコードの終わりに改行をいれる
 ただし、カンマ／ダブルクォート／改行のあるフィールドは必ず
 * ダブルクオートで囲う。これらの記号がなくてもダブルクォート
 で囲っている場合がある
 * データ中のダブルクォートはフィールドを囲うために使うものと
 区別するために、""と2文字で書いてエスケープする"


.EXAMPLE
PS C:\>cat a.csv | csv2txt

説明
-------------
CSVデータをSSVデータに変換する。
空の要素はアンダースコア(_)に変換される。

.EXAMPLE
PS C:\>cat a.csv | csv2txt -z

説明
-------------
CSVデータをSSVデータに変換する。
空の要素はゼロ 0 に変換される。

#>
function csv2txt {

    begin
    {
        if($args[0] -eq "-z"){
            $nulldata = '0'
        }elseif($args[0] -eq "-NaN"){
            $nulldata = 'NaN'
        }else{
            $nulldata = '_'
        }

        # 変数の初期化
        $cnt = 0
        $tmpBuf = ''
    }

    process
    {
        $strLen = $_.Length

        # ダブルクオートが偶数か奇数か数える
        for($i = 0; $i -lt $strLen; $i++){
            $strWord = $_[$i]
            if($strWord -eq '"'){ $cnt += 1 }

            #ダブルクオート数が奇数の場合のカンマを別文字に変換
            #また、\マークを別文字に変換しておく
            if($cnt % 2 -eq 1){
                if($strWord -eq ','){
                    $addWord = '\c'
                }elseif($strWord -eq '\'){
                    $addWord = '@y@y@'
                }else{
                    $addWord = [string]$strWord
                }
            }else{
                # ダブルクオート数が偶数の場合
                if($strWord -eq '\'){
                    $addWord = '@y@y@'
                }else{
                    $addWord = [string]$strWord
                }
            }
            $tmpBuf = [string]$tmpBuf + [string]$addWord
        }

        # ダブルクオートカウンタが偶数なら出力
        # そうでないなら次の行を読み込み
        if($cnt % 2 -eq 0){

            # 各種文字列変換処理

            # 行頭の"を削除
            $tmpBuf = $tmpBuf -Replace '^"', ''

            # 行末の"を削除
            $tmpBuf = $tmpBuf -Replace '"$', ''

            # 行中の",を,に変換
            $tmpBuf = $tmpBuf.Replace('",', ',')

            # 行中の,"を,に変換
            $tmpBuf = $tmpBuf.Replace(',"', ',')

            # 文字列としての"を別文字に置換
            $tmpBuf = $tmpBuf.Replace('""', '\d')

            # アンダースコアの処理
            $tmpBuf = $tmpBuf.Replace('_', '\_')

            # 半角スペースの処理
            $tmpBuf = $tmpBuf.Replace(' ', '_')

            # 行末のカンマの処理
            $addNull = ',' + [string]$nulldata
            $tmpBuf = $tmpBuf -Replace ',$', $addNull

            # 行頭のカンマの処理
            $addNull = [string]$nulldata + ','
            $tmpBuf = $tmpBuf -Replace '^,', $addNull

            # 連続するカンマの処理
            $addNull = ',' + [string]$nulldata + ','
            $tmpBuf = $tmpBuf.Replace(',,', $addNull)
            $tmpBuf = $tmpBuf.Replace(',,', $addNull)

            # 残っているカンマを別文字に変換
            $tmpBuf = $tmpBuf.Replace(',', '\s')

            # 別文字を元の文字に再変換
            # \s セパレータ
            $tmpBuf = $tmpBuf.Replace('\s', ' ')
            # \c カンマ
            $tmpBuf = $tmpBuf.Replace('\c', ',')
            # \d ダブルクオート
            $tmpBuf = $tmpBuf.Replace('\d', '"')
            # @y@y@を\\に
            $tmpBuf = $tmpBuf.Replace('@y@y@', '\\')

            Write-Output $tmpBuf
            $tmpBuf = ''
        }else{
            $tmpBuf = [string]$tmpBuf + '\n'
        }
    }
}
