<#
.SYNOPSIS
    ctail - Cut the last part of files

    Cut the last lines of input for the
    specified number of lines.

    Cut last one line by default.

    If no file is specified,
    read from pipeline input.

.LINK
    head, tail, chead, ctail, tail-f

.EXAMPLE
    # read from stdin

    PS > 1..5 | ctail
    1
    2
    3
    4

    PS > 1..5 | ctail -n 2
    1
    2
    3

.EXAMPLE
    # read from file

    PS > 1..5 > a.txt; ctail a.txt
    1
    2
    3
    4

    PS > 1..5 > a.txt; ctail -n 2 a.txt
    1
    2
    3

.NOTES
    learn: Select-Object
    https://learn.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/select-object


#>
function ctail {

    param (
        [Parameter( Mandatory=$False )]
        [Alias('n')]
        [int] $Num = 1,
        
        [Parameter( Mandatory=$False, Position=0 )]
        [Alias('f')]
        [string[]] $Files,
        
        [parameter( Mandatory=$False, ValueFromPipeline=$True )]
        [string[]] $InputText
    )
    $splatting = @{
        SkipLast = $Num
    }
    #$splatting.Set_Item('NoEmphasis', $True)
    if ( $Files ){
        foreach ( $f in $Files){
            Get-Content -LiteralPath $f `
                | Select-Object @splatting
        }
    } else {
        $input `
            | Select-Object @splatting
    }
}
