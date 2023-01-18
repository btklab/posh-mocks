<#
.SYNOPSIS

addl: add-left

標準入力の最左列に任意の文字列行を追加する
区切り文字はデフォルトで空文字

.DESCRIPTION
引用:
https://qiita.com/greymd/items/3515869d9ed2a1a61a49
シェルの弱点を補おう！"まさに"なCLIツール、egzact
Qiita:greymd氏, 2016/05/12, accessed 2017/11/13

.PARAMETER AddText
追加する文字列を指定する

.PARAMETER Delimiter
区切り文字を指定する

.EXAMPLE
PS C:\>Write-Output "A B C D" | addl '0 '
0 A B C D

.EXAMPLE
PS C:\>Write-Output "A B C D" | addl '0' -Delimiter ' '
0 A B C D E

.LINK
    addt, addb, addl, addr

#>
function addl {

  Param (
    [Parameter(Position=0, Mandatory=$True)]
    [string] $AddText,

    [Parameter(Mandatory=$False)]
    [ValidateSet(' ', ',' , '\t', '')]
    [Alias('d')]
    [string] $Delimiter = '',

    [Parameter(ValueFromPipeline=$True)]
    [string[]] $Body
  )

  begin {
	  $writeLine = ''
  }

  process {
	  [string]$tmpLine = $_
	  $writeLine = "$AddText" + "$Delimiter" + "$tmpLine"
	  Write-Output $writeLine
  }

}
