<#
.SYNOPSIS
    Replace-ForEach - Replace specified property string

    Replace-ForEach
        [-p|-Property] <String[]>
        [-f|-From] <Regex>
        [-t|-To] <Regex>
        [-OnlyIfPropertyExists]

.LINK
    Shorten-PropertyName

.EXAMPLE
    # replace method property's space to underscore

    # Input
    Import-Csv planets.csv `
        | Select-Object -First 3 `
        | Format-Table

    method          number orbital_period mass distance year
    ------          ------ -------------- ---- -------- ----
    Radial Velocity 1      269.3          7.1  77.4     2006
    Radial Velocity 1      874.774        2.21 56.95    2008
    Radial Velocity 1      763.0          2.6  19.84    2011

    # Use Replace-ForEach function
    Import-Csv planets.csv `
        | Select-Object -First 3 `
        | Replace-ForEach method -From ' ' -To '_' `
        | Format-Table

    method          number orbital_period mass distance year
    ------          ------ -------------- ---- -------- ----
    Radial_Velocity 1      269.3          7.1  77.4     2006
    Radial_Velocity 1      874.774        2.21 56.95    2008
    Radial_Velocity 1      763.0          2.6  19.84    2011

    # Equivalent to
    Import-Csv planets.csv `
        | Select-Object -First 3 `
        | ForEach-Object { $_.method = $_.method -replace ' ', '_'; $_ } `
        | Format-Table

#>
function Replace-ForEach
{
    [CmdletBinding()]
    Param(
        [Parameter( Mandatory=$True, Position=0 )]
        [Alias('p')]
        [string[]] $Property
        ,
        [Parameter( Mandatory=$True, Position=1 )]
        [Alias('f')]
        [regex] $From
        ,
        [Parameter( Mandatory=$False, Position=2 )]
        [Alias('t')]
        [regex] $To = ''
        ,
        [Parameter( Mandatory=$False )]
        [ValidateSet("int", "double", "decimal", "string")]
        [Alias('c')]
        [string] $Cast
        ,
        [Parameter( Mandatory=$False )]
        [switch] $OnlyIfPropertyExists
        ,
        [Parameter(Mandatory=$False, ValueFromPipeline=$True)]
        [PSObject] $InputObject
    )
    # get all property names
    [String[]] $propNames = ($input[0].PSObject.Properties).Name
    # is specified property exists?
    [bool] $isPropertyExists = $False
    foreach ( $p in $Property ){
        if ( $propNames.Contains($p) ){
            $isPropertyExists = $True
        }
    }
    if ( -not $isPropertyExists ){
        if ( $OnlyIfPropertyExists ){
            # Output as-is
            $input | Select-Object -Property *
            return
        } else {
            Write-Error "Property: $p is not exists." -ErrorAction Stop
            return
        }
    }
    # exec replace foreach object
    foreach ( $obj in @($input | Select-Object -Property *) ){
        foreach ( $p in $Property ){
            switch -Exact ($Cast) {
                "string" {
                    $obj.$p = [string]( [string]($obj.$p) -replace $from, $To )
                    break
                }
                "int" {
                    $obj.$p = [int]( [string]($obj.$p) -replace $from, $To )
                    break
                }
                "double" {
                    $obj.$p = [double]( [string]($obj.$p) -replace $from, $To )
                    break
                }
                "decimal" {
                    $obj.$p = [decimal]( [string]($obj.$p) -replace $from, $To )
                    break
                }
                default {
                    $obj.$p = [string]( [string]($obj.$p) -replace $from, $To )
                    break
                }
            }
        }
        Write-Output $obj
    }
}
