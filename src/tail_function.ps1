<#
.SYNOPSIS
行末から指定した行数のみ出力する
デフォルトで10行

tail [-n num] [file]...

file を指定しなかった場合、
標準入力から読み込み。

file を指定した場合、
ファイル名とともに指定した行数を出力するが、
標準入力からはデータを受け付けない点に注意。

file を指定する場合の方が
指定しない場合よりおそらく高速。


.DESCRIPTION
-

.EXAMPLE
PS C:\> cat a.txt | tail
a.txt の末尾の 10 行を出力


.EXAMPLE
PS C:\> cat a.txt | tail -n 10
a.txt の末尾の 10 行を出力

.EXAMPLE
PS C:\> tail *.txt
拡張子が.txt のファイルのファイル名と
末尾の 10 行を出力

.EXAMPLE
PS C:\> tail -n 10 *.txt
拡張子が.txt のファイルのファイル名と
末尾の 10 行を出力

#>
function tail{

  begin{
    $stdinFlag = $false
    $readFileFlag = $false
    $setNumFlag = $false
    $readRowCounter = 0
    $tailHash = @{}
    $oldVersionFlag = $false
    # バージョン確認
    # Get-Content file -Tail <n> は v5.0以降でしか使用できない
    $ver = [int]$PSVersionTable.PSVersion.Major
    if($ver -le 2){
      $oldVersionFlag = $true
    }
    if($args.Count -eq 0){
      # 引数なしの場合：標準入力からデータを得る
      $stdinFlag = $true
      $dispRowNum = 10
    }elseif($args[0] -eq '-n'){
      # -n 行数指定ありの場合
      if($args.Count -lt 2){throw "引数が不足しています."}
      $setNumFlag = $true
      $dispRowNum = [int]$args[1]
    }else{
      # 行数指定なしの場合:引数はすべてファイル名とみなす
      $readFileFlag = $true
      $dispRowNum = 10
      $fileArryStartCounter = 0
    }
    # -n で行数指定ありの場合の入力形式判断
    if($setNumFlag){
      if($args.Count -eq 2){
        # 引数の数が2つの場合(-n num)：標準入力からデータを得る
        $stdinFlag = $true
      }else{
        # 引数の数が2つ以上場合：3つめ以降の引数はファイル名
        $readFileFlag = $true
        $fileArryStartCounter = 2
      }
    }
    #Write-Output $stdinFlag,$readFileFlag,$dispRowNum,$fileArryStartCounter
    # 配列tailHashの初期化
    # ファイル行数が指定行数より小さい場合の検知に使用する
    $chkStr = 'nulpopopo'
    for($i = 1; $i -le $dispRowNum; $i++){
      $tmpKey = 'COL' + [string]$i
      $tailHash["$tmpKey"] = $chkStr
    }
  } # end of begin block

  process{
    # 入力形式が標準入力の場合
    if($stdinFlag){
      $readRowCounter++
      $tmpKey = 'COL' + [string]$readRowCounter
      $tailHash["$tmpKey"] = $_
      if($readRowCounter -eq $dispRowNum){$readRowCounter = 0}
    }
  } # end of process block

  end{
    # 入力形式が標準入力の場合
    if($stdinFlag){
      if($readRowCounter -eq 0){
        for($i = 1; $i -le $dispRowNum; $i++){
          $tmpKey = 'COL' + [string]$i
          Write-Output $tailHash["$tmpKey"]
        }
      }else{
        for($i = $readRowCounter + 1; $i -le $dispRowNum; $i++){
          $tmpKey = 'COL' + [string]$i
          if([string]$tailHash["$tmpKey"] -ne [string]$chkStr){
            Write-Output $tailHash["$tmpKey"]
          }
          }
        for($i = 1; $i -le $readRowCounter; $i++){
          $tmpKey = 'COL' + [string]$i
          Write-Output $tailHash["$tmpKey"]
        }
      }
    }
    # 入力形式がファイルの場合
    if($readFileFlag){
      for($i = $fileArryStartCounter; $i -lt $args.Count; $i++){
        $fileList = (Get-Item $args[$i] | %{ $_.FullName })
        foreach($files in $fileList){
          # ファイル名を出力
          #$dispFileName = (Split-Path -Leaf "$files")
          $dispFileName = "$files"
          Write-Output ('==> ' + "$dispFileName" + ' <==')
          # バージョンに応じて指定行数を出力
          #$oldVersionFlag = $true
          if($oldVersionFlag){
            # v2.0 以下
            $tmpDispRowNum = $dispRowNum * -1
            @(Get-Content "$files" -Encoding UTF8)[$tmpDispRowNum..-1]
          }else{
            Get-Content "$files" -Tail $dispRowNum -Encoding UTF8
          }
          # ファイルの区切りとして空行を一行出力
          Write-Output ''
        }
      }
    }
  } #end of end block
}
