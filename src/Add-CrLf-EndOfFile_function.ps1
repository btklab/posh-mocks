<#
.SYNOPSIS
ファイル末尾に改行（CrLf）を挿入

Add-CrLf-EndOfFile

.DESCRIPTION
-

#>
function Add-CrLf-EndOfFile {
    begin  {}
    process{Write-Output $_}
    end    {Write-Output ''}
}

