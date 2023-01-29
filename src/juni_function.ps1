<#
.SYNOPSIS
    juni - Enumerate the number of rows in each line

    juni [-z]
    -z: zero start

.EXAMPLE
    "a".."e" | juni
    1 a
    2 b
    3 c
    4 d
    5 e

.EXAMPLE
    "a".."e" | juni -z
    0 a
    1 b
    2 c
    3 d
    4 e

#>
function juni {
    begin
    {
        [int] $i = 0
        if( $args.Count -gt 0 ){
            if( [string]($args[0]) -eq '-z' ){
                [int] $i = -1
            }
        }
    }
    process
    {
        $i++
        Write-Output "$i $_"
    }
}
