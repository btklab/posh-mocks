<#
.SYNOPSIS
    addb - add text bottom of line

    Inspired by:
        greymd/egzact: Generate flexible patterns on the shell - GitHub
        https://github.com/greymd/egzact

.EXAMPLE
    "A B C D" | addt '<table>' | addb '</table>'
    <table>
    A B C D
    </table>

.EXAMPLE
    "A B C D" | addt '# this is title','' | addb '','this is footer'
    # this is title
    
    A B C D
    
    this is footer


.LINK
    addt, addb, addl, addr


#>
function addb {
  Param (
    [Parameter(Position=0, Mandatory=$True)]
    [AllowEmptyString()]
    [string[]] $AddText,

    [Parameter(ValueFromPipeline=$True)]
    [string[]] $Body
  )
  process {
    Write-Output $_
  }
  end {
    foreach ($t in $AddText){
      Write-Output "$t"
    }
  }
}
