<#
.SYNOPSIS

addr: add-right

標準入力の最右列に任意の文字列行を追加する
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
PS C:\>Write-Output "A B C D" | addr ' E'
A B C D E

.EXAMPLE
PS C:\>Write-Output "A B C D" | addr 'E' -Delimiter ' '
A B C D E

.LINK
    addt, addb, addl, addr

#>
function addr {

  Param (
    [Parameter(Position=0, Mandatory=$True)]
    [string] $AddText,

    [Parameter(Mandatory=$False)]
    [ValidateSet(' ', ',', '\t', '')]
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
	  $writeLine = [string]$tmpLine + "$Delimiter" + "$AddText"
	  Write-Output $writeLine
  }
}
