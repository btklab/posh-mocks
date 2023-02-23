<#
.SYNOPSIS
    fpath - Remove double-quotes and replace backslashes to slashes from windows path
    
    fpath means format-paths

    If Paths is not specified in the args or pipline input,
    it tries to use the value from the clipboard.

    Multiple lines are allowed.

    Usage:
        # get paths from clipboard
        fpath
        Get-Clipboard | fpath

        # get paths from clipboard and set output to clipboard
        fpath | Set-Clipboard

        # get path from parameter
        fpath "C:\Users\hoge\fuga\piyo_function.ps1"
        C:/Users/hoge/fuga/piyo_function.ps1

        # get path from stdin
        "C:\Users\hoge\fuga\piyo_function.ps1" | fpath
        C:/Users/hoge/fuga/piyo_function.ps1

        # get path from file
        cat paths.txt | fpath


.EXAMPLE
    # get path from parameter
    fpath "C:\Users\hoge\fuga\piyo_function.ps1"
    C:/Users/hoge/fuga/piyo_function.ps1

    # get path from stdin
    "C:\Users\hoge\fuga\piyo_function.ps1" | fpath
    C:/Users/hoge/fuga/piyo_function.ps1

    # get paths from clipboard
    fpath
    Get-Clipboard | fpath

    # get path from file
    cat paths.txt | fpath

.EXAMPLE
    # get paths from clipboard and set output to clipboard
    fpath | Set-Clipboard

.LINK
    ml (Get-OGP), fpath

#>
function fpath {
    param (
        [Parameter( Mandatory=$False, Position=0, ValueFromPipeline=$True)]
        [Alias('p')]
        [string[]] $Paths
    )
    if ( -not $Paths ){ [string[]] $Paths = Get-ClipBoard }
    if ( $Paths.Count -eq 0 ){ return }
    foreach ( $pat in $Paths ){
        if ( $pat -ne ''){
            [string] $writeLine = $pat.Replace('"','').Replace('\','/')
            Write-Output $writeLine
        }
    }
}
