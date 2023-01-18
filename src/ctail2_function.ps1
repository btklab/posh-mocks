<#
.SYNOPSIS
行末尾から指定した行数を削除して出力する
デフォルトで1行
処理は遅いが行数を指定できる

ctail2 [-n num] [file]...

file を指定しなかった場合、
標準入力から読み込み。

file を指定した場合、
標準入力からはデータを受け付けない点に注意。
file を指定する場合の方が
指定しない場合よりおそらく高速。

.LINK
    head, tail, chead, ctail, ctail2

.EXAMPLE
PS C:\> cat a.txt | ctail2
a.txt の最後の 1 行を削除し残りの行を出力

.EXAMPLE
PS C:\> cat a.txt | ctail2 -n 5
a.txt の最後の 5 行を削除し残りの行を出力

.EXAMPLE
PS C:\> ctail2 a.txt
a.txt の最後の 1 行を削除して残りの行を出力

#>
function ctail2 {

  $stdinFlag = $false
  $readFileFlag = $false
  $setNumFlag = $false
  $oldVersionFlag = $false
  $readRowCounter = 0

  # バージョン確認
  # Get-Content file -Head <n> は v5.0以降でしか使用できない
  $ver = [int]$PSVersionTable.PSVersion.Major
  if($ver -le 2){
    $oldVersionFlag = $true
  }

  # 入力形式と出力行数を引数から得る
  if($args.Count -eq 0){
    # 引数なしの場合：標準入力からデータを得る
    $stdinFlag = $true
    $cutRowNum = 1
  }elseif($args[0] -eq '-n'){
    # -n 行数指定ありの場合
    if($args.Count -lt 2){
      Write-Error "引数が不足しています." -ErrorAction Stop}
    $setNumFlag = $true
    $cutRowNum = [int]$args[1]
  }else{
    # 行数指定なしの場合:引数はすべてファイル名とみなす
    $readFileFlag = $true
    $cutRowNum = 1
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

  if($stdinFlag){
    $inputData = $input | ForEach-Object { $_ }
    $fileGyoNum = $inputData.Length - 1 - $cutRowNum
    if($fileGyoNum -ge 0){$inputData[0..$fileGyoNum]}
  }

  if($readFileFlag){
    for($i = $fileArryStartCounter; $i -lt $args.Count; $i++){
      $fileList = (Get-ChildItem -Path $args[$i] `
        | ForEach-Object { $_.FullName })
      foreach($f in $fileList){
        $fileFullPath = "$f"
        $fileGyoNum = (Get-Content -LiteralPath "$fileFullPath" -Encoding UTF8).Length - 1 - $cutRowNum
        if($fileGyoNum -ge 0){(Get-Content -LiteralPath "$fileFullPath" -Encoding UTF8)[0..$fileGyoNum]}
      }
    }
  }
}
