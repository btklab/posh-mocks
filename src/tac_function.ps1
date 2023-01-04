<#
.SYNOPSIS
tac -- print lines in reverse

ref:
https://man7.org/linux/man-pages/man1/tac.1.html

関連: rev

.DESCRIPTION
-

.EXAMPLE
1..5 | tac
5
4
3
2
1

.EXAMPLE
tac a.txt

#>
function tac {
    Param(
        [parameter(Mandatory=$False)]
        [string[]] $InputFiles,

        [parameter(
          Mandatory=$False,
          ValueFromPipeline=$True)]
        [string[]] $Text
    )
    if($InputFiles){
        foreach ($f in $InputFiles){
            $con = Get-Content -Path "$f" -Encoding UTF8
            ($con)[($con.Length)..0]
        }
    } else {
        @($input)[(@($input).Count - 1)..0]
    }
}
