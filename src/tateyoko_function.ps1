<#
.SYNOPSIS
行列の転置
列数は不揃いでもよいがややこしいので、
列数はそろえておく方がよい

tateyoko [-Separator <String>]

.DESCRIPTION
-

.PARAMETER Separator
区切り文字を指定する。
デフォルトで半角スペース

#>
function tateyoko{
  Param (    
    [Parameter(Mandatory=$false)]
    [ValidateLength(1,1)]
    [string] $Separator = ' ',
    
    [parameter(ValueFromPipeline=$true)]
    [string[]] $Text
  )

  begin
  {
    [string[]]$RowAry = @()
    $MaxColNum = 1
    $writeLine = ''
    $RowList = New-Object 'System.Collections.Generic.List[System.String]'
  }

  process
  {
	# 1st pass
    $readLine = [string]$_
    $RowList.Add($readLine)
    
    # get max col num
    $ColAry = $readLine -Split "$Separator"
    [int]$tmpColNum = @($ColAry).Count
    if($tmpColNum -gt $MaxColNum){
      $MaxColNum = $tmpColNum
    }
  }

  end
  {
    # get max row
    $RowAry = $RowList.ToArray()
    $MaxRowNum = @($RowAry).Count
    
    # 行と列の転置
    for($j = 0; $j -lt $MaxColNum; $j++){
      $outputList = New-Object 'System.Collections.Generic.List[System.String]'
      [string[]]$outputAry = @()
      
      for($i = 0; $i -lt $MaxRowNum; $i++){
          $outputList.Add(@($RowAry)[$i].Split($Separator)[$j])
      }
      $outputAry = $outputList.ToArray()
      $writeLine = $outputAry -Join "$Separator"
      #$writeLine = $writeLine.Trim()
      $writeLine = $writeLine -Replace "($Separator)+$",''
      Write-Output $writeLine
      $writeLine = ''
    }
  }
}
