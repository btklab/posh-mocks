<#
.SYNOPSIS
    Add-CrLf - Insert a newline when it finds "`r`n" in a strings

.EXAMPLE
    'abc`r`ndef',"ghi jkl" | Add-CrLf
    abc
    def
    ghi jkl

#>
filter Add-CrLf {
    [string] $readLine = [string] $_
    if( $readLine -match '`r?`n' ){
        $splitbuf = $readLine -Split '`r?`n'
        foreach ($elem in $splitbuf){
            Write-Output $elem
        }
    } else {
        Write-Output $readLine
    }
}

