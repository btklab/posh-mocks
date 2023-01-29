<#
.SYNOPSIS
    Add-CrLf-EndOfFile - Add a blank line to the bottom of stdin

#>
function Add-CrLf-EndOfFile {
    process { Write-Output $_ }
    end     { Write-Output '' }
}

