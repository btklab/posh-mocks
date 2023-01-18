<#
.SYNOPSIS
行頭から指定した行数のみ出力する
デフォルトで10行

head [-n num] [file]...

file を指定しなかった場合、
標準入力から読み込み。

file を指定した場合、
ファイル名とともに指定した行数を出力する。

file を指定する場合の方が
指定しない場合よりおそらく高速だが、
標準入力からはデータを受け付けない点に注意。

.LINK
    head, tail, chead, ctail, ctail2


.EXAMPLE
PS C:\> cat a.txt | head
a.txt の最初の 10 行を出力


.EXAMPLE
PS C:\> cat a.txt | head -n 10
a.txt の最初の 10 行を出力

.EXAMPLE
PS C:\> head *.txt
拡張子が.txt のファイルのファイル名と
最初の 10 行を出力

.EXAMPLE
PS C:\> head -n 10 *.txt
拡張子が.txt のファイルのファイル名と
最初の 10 行を出力


.EXAMPLE
PS C:\> head -n 10 onemil.txt | chead | ctail
ファイルを一つだけ指定し、
最初の行（ファイル名）と最後の行（空行）を削除すれば、
大きいファイルからでも行頭を素早く取得できる。
（ただしワイルドカードや複数ファイル指定の場合、
このワンライナーは使えない点に注意する）


#>
function head{

  begin
  {
    $stdinFlag      = $false
    $readFileFlag   = $false
    $setNumFlag     = $false
    $oldVersionFlag = $false
    $readRowCounter = 0

    # バージョン確認
    # Get-Content -LiteralPath file -Head <n> は v5.0以降でしか使用できない
    $ver = [int]$PSVersionTable.PSVersion.Major
    if($ver -le 2){ $oldVersionFlag = $true }

    # 入力形式と出力行数を引数から得る
    if($args.Count -eq 0){
      # 引数なしの場合：標準入力からデータを得る
      $stdinFlag = $true
      $dispRowNum = 10
    }elseif($args[0] -eq '-n'){
      # -n 行数指定ありの場合
      if($args.Count -lt 2){
        Write-Error "引数が不足しています." -ErrorAction Stop }
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

  } # end of begin block

  process
  {
    if($stdinFlag){
      $readRowCounter++
      if($readRowCounter -le $dispRowNum){
        Write-Output $_
      }
    }
  } # end of process block

  end
  {
    if($readFileFlag){
      for($i = $fileArryStartCounter; $i -lt $args.Count; $i++){
        $fileList = (Get-ChildItem $args[$i] | %{ $_.FullName })
        foreach($f in $fileList){
          # ファイル名出力
          #$dispFileName = (Split-Path -Leaf "$f")
          $dispFileName = "$f"
          #$dispFileName = (Resolve-Path "$f" -Relative)
          Write-Output ('==> ' + "$dispFileName" + ' <==')
          # バージョンに応じて指定行を出力
          #$oldVersionFlag = $true
          if($oldVersionFlag){
            # v2.0 以下
            $tmpDispRowNum = $dispRowNum - 1
            #@(Get-Content -LiteralPath "$f" -Encoding oem)[0..$tmpDispRowNum]
            @(Get-Content -LiteralPath "$f" -Encoding UTF8)[0..$tmpDispRowNum]
          }else{
            #Get-Content -LiteralPath "$f" -Encoding oem -Head $dispRowNum
            Get-Content -LiteralPath "$f" -Encoding UTF8 -Head $dispRowNum
          }
          # ファイルの区切りとして空行を一行出力
          Write-Output ''
        }
      }
    }
  } # end of end block
}
