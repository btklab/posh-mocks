<#
.SYNOPSIS

yarr - Expand vertical data to horizontal

縦型（ロング型）の半角スペース区切りレコードを
指定列をキーに横型（ワイド型）に変換する。

指定列をキーとして横に並べる
事前ソート不要
大文字小文字を区別しない

yarr num=<num>

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

PS> cat a.txt | grep . | yarr num=1
2018 3 3 3
2017 1 1 1 1 1
2022 5 5

※ grep . で空行をスキップ（＝1文字以上の行のみヒット）



.EXAMPLE
PS C:\>cat a.txt | yarr num=2
1列目から2列目をキーとして折り返す



#>
function yarr {

    begin
    {
		# test arg
        if($args.Count -ne 1){
            Write-Error "引数が不正です." -ErrorAction Stop }
        if($args[0] -notmatch '^num='){
            Write-Error "引数が不正です." -ErrorAction Stop }

        # init var
        $keyStr = ''

        # create key string
        $k1 = 0
        $k2 = $args[0] -Replace 'num=', ''
        $k2 = [int]$k2 - 1
        for($i=$k1;$i -le $k2; $i++ ){
            $keyStr += '[string]$splitLine[' + [string]$i + ']'
        }
        $keyStr = $keyStr -replace '\]\[string', '] + " " + [string'
        $keyStr = $keyStr.Trim()
        #Write-Output $keyStr

        # init hashtable
        $ver = [int] $PSVersionTable.PSVersion.Major
        #Write-Output $ver
        if($ver -le 2){
            $yarrHash = @{}
        }else{
            $yarrHash = [ordered]@{}
        }
    }

    process
    {
        $splitLine = $_ -Split " "
        if ($_ -eq ''){
            Write-Error "空行を検知" -ErrorAction Stop
        }
        $cnt = 0
        $key = Invoke-Expression $keyStr
        for($i=0;$i -lt $splitLine.Count;$i++){
            if(!(($i -ge $k1) -And ($i -le $k2))){
                if($cnt -eq 0){
                    $str = [string]$splitLine[$i]
                    $cnt++
                }else{
                    $str = [string]$str + ' ' + [string]$splitLine[$i]
                }
            }
        }
        if($yarrHash.Contains("$key")){
            $yarrHash["$key"] = [string]$yarrHash["$key"] + ' ' + $str
        }else{
            $yarrHash["$key"] = [string]$key + ' ' + [string]$str
        }
    }

    end
    {
        Write-Output $yarrHash.Values
    }
}
