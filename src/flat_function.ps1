<#
.SYNOPSIS
指定した列数で折り返す
区切り文字は半角スペースを認識する

flat [fs=<string>] [num>]

flat 
 引数を何も指定しなければ全行1列半角スペース区切りでに出力

flat <num>
 指定列数で折り返し

.DESCRIPTION

inspired by
https://qiita.com/greymd/items/3515869d9ed2a1a61a49
シェルの弱点を補おう！"まさに"なCLIツール、egzact
Qiita:greymd氏, 2016/05/12, accessed 2017/11/13

.EXAMPLE
PS C:\>ls -Name *.txt | flat

説明
--------------
カレントディレクトリ内の *.txt の中身が
半角スペース区切りで一行に出力される

.EXAMPLE
PS C:\>ls -Name *.* | flat 5

説明
--------------
カレントディレクトリ内のファイルが
5列で表示される

#>
function flat {

    begin
    {
        # 引数の処理
        $nflag = $false
        $fsflag = $false
        $emptyflag = $false

        foreach($arg in $args){
            if([string]$arg -match 'fs='){
                $fsflag = $true
                $fs = [string]$arg -Replace '^fs=',''
                if($fs -eq ''){$emptyflag = $true}
            }
        }
        if($fsflag){
            if($args[1]){
                $nflag = $true
                $optNum = [int]$args[1]
                if($optNum -lt 1){throw '列数には1以上の整数を指定ください'}
            }
        }elseif($args[0]){
            $fs = ' '
            $nflag = $true
            $optNum = [int]$args[0]
            if($optNum -lt 1){throw '列数には1以上の整数を指定ください'}
        }else{
            $fs = ' '
        }

        # 変数の初期化
        if($nflag){
            $retu = [int]$optNum
            $counter = 0
        }
        $readLine = ''
        $writeLine = ''
    }

    process
    {
        $readLine = [string]$_

        if(!$emptyflag){
            # -n オプション:任意の列数で改行
            if($nflag){
                $splitLine = $readLine -Split "$fs"
                for($i=0; $i -lt $splitLine.Count; $i++){
                    $counter++
                    $writeLine = [string]$WriteLine + "$fs" + [string]$splitLine[$i]
                    if($counter -eq $retu){
                        $writeLine = $WriteLine -Replace "^$fs", ""
                        Write-Output $writeLine
                        $writeLine = ''
                        $counter = 0
                    }
                }
            }else{
                # 引数なし：全行を半角スペース区切りで1行にして出力
                $writeLine = [string]$writeLine + "$fs" + [string]$readLine
            }
        }else{
            # -n オプション:任意の列数で改行
            if($nflag){
                $splitLine = $readLine -Split "$fs"
                for($i=1; $i -lt $splitLine.Count - 1; $i++){
                    $counter++
                    $writeLine = [string]$WriteLine + [string]$splitLine[$i]
                    if($counter -eq $retu){
                        Write-Output $writeLine
                        $writeLine = ''
                        $counter = 0
                    }
                }
            }else{
                # 引数なし：全行を1行にして出力
                $writeLine = [string]$writeLine + [string]$readLine
            }
        }

    }

    end
    {
        if($nflag){
            if($writeLine -ne ''){
                $writeLine = $WriteLine -Replace "^$fs", ""
                Write-Output $writeLine
            }
        }else{
            $writeLine = $WriteLine -Replace "^$fs", ""
            Write-Output $writeLine
        }
    }
}
