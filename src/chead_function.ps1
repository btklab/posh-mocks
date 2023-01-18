<#
.SYNOPSIS
行頭から指定した行数を削除して出力する
入力はパイプラインからのみ受け付け
デフォルトで1行削除
+hオプションで1行目を無視した行数を削除

chead [+h] [-n num]

.LINK
    head, tail, chead, ctail, ctail2

.EXAMPLE
PS C:\> cat a.txt | chead
a.txt の最初の 1 行を削除し残りの行を出力


.EXAMPLE
PS C:\> cat a.txt | chead -n 5
a.txt の最初の 5 行を削除し残りの行を出力

#>
function chead {

  begin
  {
    $readRowCounter = 0
    $headerFlag = $false

    # 削除する行数を引数から得る
    if($args.Count -eq 0){
      # 引数なしの場合：デフォルトで1行削除
      $cutRowNum = 1

    }elseif($args[0] -eq '-n'){
      # -n 行数指定ありの場合
      if($args.Count -lt 2){
        Write-Error "引数が不足しています." -ErrorAction Stop}
      $cutRowNum = [int]$args[1]

    }elseif($args[0] -eq '+h'){
      $headerFlag = $True
      $cutRowNum = 1
        
      if($args[1] -eq '-n'){
        # -n 行数指定ありの場合
        if($args.Count -lt 3){
          Write-Error "引数が不足しています." -ErrorAction Stop}
        $cutRowNum = [int]$args[2]
      }

    }else{
      Write-Error "引数が不正です." -ErrorAction Stop
    }
  } # end of begin block

  process
  {
    $readRowCounter++
    if($headerFlag){
      if($readRowCounter -eq 1){
        Write-Output $_
      }else{
        if( ($readRowCounter - 1) -gt $cutRowNum){
          Write-Output $_}
      }
    }else{
      if($readRowCounter -gt $cutRowNum){
        Write-Output $_}
    }
  } # end of process block
}
