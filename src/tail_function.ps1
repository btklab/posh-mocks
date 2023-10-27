<#
.SYNOPSIS
    Tail-Object (Alias: tail) - Output the last part of files
      
        tail [-n num] [file]...

    If no file is specified, read from stdin.

.LINK
    head, tail, chead, ctail, tail-f

.EXAMPLE
    1..20 | tail
    11
    12
    13
    14
    15
    16
    17
    18
    19
    20

.EXAMPLE
    1..20 | tail -n 5
    16
    17
    18
    19
    20

.EXAMPLE
    tail *.*

    ==> timeline-date-val.txt <==
    2020-04 366.5 544.1
    2020-05 605.8 770.3
    2020-06 706.9 836.6

    ==> tips.csv <==
    22.67,2,"Male","Yes","Sat","Dinner",2
    17.82,1.75,"Male","No","Sat","Dinner",2
    18.78,3,"Female","No","Thur","Dinner",2

    ==> titanic.csv <==
    0,3,female,,1,2,23.45,S,Third,woman,False,,Southampton,no,False
    1,1,male,26.0,0,0,30.0,C,First,man,True,C,Cherbourg,yes,True
    0,3,male,32.0,0,0,7.75,Q,Third,man,True,,Queenstown,no,True

#>
function Tail-Object {
    Param(
        [Parameter(Mandatory=$False,Position=0)]
        [alias('p')]
        [string[]] $Path,
        
        [Parameter(Mandatory=$False)]
        [alias('n')]
        [int] $Num = 10,
        
        [parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [string[]] $InputObject
    )
    # main
    ## If file paths specified as an argument
    if ( $Path ){
        [object[]] $PathObjects = Get-ChildItem -Path $Path
        Write-Debug $PathObjects.Count
        if ( $PathObjects.Count -eq 1 ){
            # output contents
            $splatting = @{
                Path     = $Path
                Tail     = $Num
                Encoding = "utf8"
            }
            Get-Content @splatting
        } else {
            # output contents with file name
            foreach ( $p in $PathObjects ){
                [string] $fileName = $p.Name
                $splatting = @{
                    Path     = $p.FullName
                    Tail     = $Num
                    Encoding = "utf8"
                }
                Write-Host ""
                Write-Host "==> $fileName <==" -ForegroundColor Green
                Get-Content @splatting
            }

        }
        return
    }
    ## If a text object is input from the pipeline
    $splatting = @{
        Last = $Num
    }
    $input | Select-Object @splatting
    return
}
Set-Alias -Name tail -Value Tail-Object -PassThru | Select-Object -Property "DisplayName"
