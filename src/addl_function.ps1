<#
.SYNOPSIS
    addl - Add text leftmost of the line

    Inspired by:
        greymd/egzact: Generate flexible patterns on the shell - GitHub
        https://github.com/greymd/egzact

.EXAMPLE
    "A B C D" | addl '0 '
    0 A B C D

.EXAMPLE
    "A B C D" | addl '0' -d ' '
    0 A B C D E

.LINK
    addt, addb, addl, addr

#>
function addl {

  Param (
    [Parameter(Position=0, Mandatory=$True)]
    [string] $AddText,

    [Parameter(Mandatory=$False)]
    [ValidateSet(' ', ',' , '\t', '')]
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
    [string] $writeLine = "$AddText" + "$Delimiter" + "$tmpLine"
    Write-Output $writeLine
  }
}
