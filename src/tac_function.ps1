<#
.SYNOPSIS
    tac -- print lines in reverse

        1..5 | tac
        5
        4
        3
        2
        1

.LINK
    rev

.EXAMPLE
    1..5 | tac
    5
    4
    3
    2
    1
#>
function tac {
    Param(
        [parameter(Mandatory=$False, Position=0)]
        [string[]] $InputFiles,

        [parameter(Mandatory=$False, ValueFromPipeline=$True)]
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
