<#
.SYNOPSIS
    tail-f - Output appended data as the file grows

    A PowerShell implementation of the "tail -f" command
    using "Get-Content a.txt -Wait -Tail 1 -Encoding utf8".


.EXAMPLE
    1..100 | %{ (Get-Date).ToString('yyyy-MM-dd HH:mm:ss') >> a.txt; sleep 1 }
    ("another process")
    tail-f a.txt

    2023-04-07 05:33:29
    2023-04-07 05:33:30
    2023-04-07 05:33:31
    2023-04-07 05:33:32
    ...

.LINK
    head, tail, chead, ctail, tail-f

#>
function tail-f {
    param (
        [Parameter( Mandatory=$True, Position=0 )]
        [Alias('p')]
        [string] $Path
    )
    Get-Content -LiteralPath $Path -Encoding utf8 -Wait -Tail 1
}
