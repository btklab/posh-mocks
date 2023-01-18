<#
.SYNOPSIS
改行（CrLf）の挿入
文字列中に`r`nを見つけるとそこに改行を挿入する

Add-CrLf

.EXAMPLE
PS C:\>Write-Output 'abc`r`n'def' | Add-CrLf
abc
def

#>
filter Add-CrLf {
  if($_ -match '`r?`n'){
      $splitbuf = $_ -Split '`r?`n'
      for($i = 0; $i -lt $splitbuf.Count; $i++){
          Write-Output $splitbuf[$i]
      }
  }else{
      Write-Output $_
  }
}

