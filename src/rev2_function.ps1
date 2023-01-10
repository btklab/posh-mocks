<#
.SYNOPSIS
半角スペースで区切られた列をリバースする
列内の文字列はリバースしない
入力はパイプのみ受け付け

rev2 [-e]

 -e: echo: 入力データも出力する

関連コマンド: stair, cycle

.DESCRIPTION
ref:
https://qiita.com/greymd/items/3515869d9ed2a1a61a49
シェルの弱点を補おう！"まさに"なCLIツール、egzact
Qiita:greymd氏, 2016/05/12, accessed 2017/11/13

.EXAMPLE
PS> Write-Output "01 02 03" | rev2
03 02 01

.EXAMPLE
PS> Write-Output "01 02 03" | rev2 -e
01 02 03
03 02 01

.EXAMPLE
PS> Write-Output "A B C D E" | stair | stair -r

説明
====================
A B C D E という5つのフィールドの部分集合を全て列挙する

.EXAMPLE
PS> Write-Output "A B C D E" | cycle | stair | stair -r

説明
====================
cycleを組み合わせることで、
A B C D E という5つのフィールドの部分集合を全て列挙する
かつ、
E→Aにつながる組み合わせも列挙する
（環状線のイメージ）

.EXAMPLE
PS> Write-Output "A B C D E" | rev2 -e | cycle | stair | stair -r

説明
====================
cycle と rev2 -e を組み合わせることで、
A B C D E という5つのフィールドの部分集合を全て列挙する
かつ、
E→Aにつながる組み合わせも列挙する
（環状線のイメージ）
かつ、
逆方向（たとえば、B→A）も考慮したパターンを列挙する
（環状線の内回りと外回りのイメージ）

#>
function rev2 {
    Param(
        [parameter(Mandatory=$False)]
        [Alias('e')]
        [switch] $echo,

        [parameter(Mandatory=$False,
            ValueFromPipeline=$True)]
        [string[]]$Text
    )
    process {
        [string] $readLine = "$_".Trim()
        [string] $readLine = $readLine -Replace "  +", " "
        [string[]] $splitReadLine = $readLine -Split " "
        if($echo){ Write-Output $readLine }
        [string] $writeLine = [string]::join(" ",$splitReadLine[($splitReadLine.Count - 1)..0])
        Write-Output $writeLine
    }
}
