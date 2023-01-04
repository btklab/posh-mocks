<#
.SYNOPSIS

addb: add-bottom

標準入力の行末に任意の文字列行を追加する

.DESCRIPTION
引用:
https://qiita.com/greymd/items/3515869d9ed2a1a61a49
シェルの弱点を補おう！"まさに"なCLIツール、egzact
Qiita:greymd氏, 2016/05/12, accessed 2017/11/13

.PARAMETER AddText
追加する文字列を指定する

.EXAMPLE
PS C:\>Write-Output "A B C D" | addb '</table>'
A B C D
</table>

.EXAMPLE
PS C:\>Write-Output "A B C D" | addb '','title'
A B C D

title

#>
function addb {

  Param (
    [Parameter(Position=0, Mandatory=$True)]
    [AllowEmptyString()]
    [string[]] $AddText,

    [Parameter(ValueFromPipeline=$True)]
    [string[]] $Body
  )

  process {
	  Write-Output $_
  }

  end {
    foreach ($t in $AddText){
      Write-Output "$t"
    }
  }
}
