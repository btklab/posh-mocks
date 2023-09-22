<#
.SYNOPSIS
    Add-LineBreakEndOfFile - Add a blank line to the bottom of stdin

#>
function Add-LineBreakEndOfFile {
    process { Write-Output $_ }
    end     { Write-Output '' }
}

