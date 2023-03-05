<#
.SYNOPSIS
    addr - Add text rightmost of the line

    Inspired by:
        greymd/egzact: Generate flexible patterns on the shell - GitHub
        https://github.com/greymd/egzact

.EXAMPLE
    "A B C D" | addr ' E'
    A B C D E

.EXAMPLE
    "A B C D" | addr 'E' -d ' '
    A B C D E

.LINK
    addt, addb, addl, addr

#>
function addr {
  Param (
    [Parameter(Position=0, Mandatory=$True)]
    [string] $AddText,

    [Parameter(Mandatory=$False)]
    [ValidateSet(' ', ',', '\t', '')]
    [Alias('d')]
    [string] $Delimiter = '',

    [Parameter(ValueFromPipeline=$True)]
    [string[]] $Body
  )
  begin {
    [string] $writeLine = ''
  }
  process {
    [string] $tmpLine = [string] $_
    [string] $writeLine = [string]$tmpLine + "$Delimiter" + "$AddText"
    Write-Output $writeLine
  }
}
