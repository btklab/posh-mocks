<#
.SYNOPSIS
    chead - Cut the first part of files

    Cut the specified number of lines
    from the first part of input.

    Accepts input only from pipline.
    Cut 1 row by default.

.LINK
    head, tail, chead, ctail, tail-f

.EXAMPLE
    # read from stdin

    PS > 1..5 | chead
    2
    3
    4
    5

    PS > 1..5 | chead -n 2
    3
    4
    5

.EXAMPLE
    # read from file
    
    PS > 1..5 > a.txt; chead a.txt
    2
    3
    4
    5
    
    PS > 1..5 > a.txt; chead -n 2 a.txt
    3
    4
    5

.NOTES
    learn: Select-Object
    https://learn.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/select-object


#>
function chead {

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
        Skip = $Num
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
