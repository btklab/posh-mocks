<#
.SYNOPSIS
    Add-LineBreak - Insert linebreak when it finds "`r`n" in a strings

.EXAMPLE
    'abc`r`ndef',"ghi jkl" | Add-LineBreak
    abc
    def
    ghi jkl

#>
filter Add-LineBreak {
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

