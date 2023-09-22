<#
.SYNOPSIS
    Delete-Field - Delete properties by number of columns.

    Specify the field numbers you want to DELETE,
    with the leftmost column as 1st.


.LINK
    Shorten-PropertyName, Drop-NA, Replace-NA, Apply-Function, Add-Stats, Detect-XrsAnomaly, Plot-BarChart, Get-First, Get-Last, Select-Field, Delete-Field

.EXAMPLE
    Import-Csv penguins.csv `
        | Shorten-PropertyName `
        | head -n 2 `
        | ft

    count species island    b_l_m b_d_m f_l_m b_m_g sex    year
    ----- ------- ------    ----- ----- ----- ----- ---    ----
    1     Adelie  Torgersen 39.1  18.7  181   3750  male   2007
    2     Adelie  Torgersen 39.5  17.4  186   3800  female 2007

    Import-Csv penguins.csv `
        | Shorten-PropertyName `
        | head -n 2 `
        | Delete-Field 2,3,-2 `
        | ft
    
    count b_l_m b_d_m f_l_m b_m_g year
    ----- ----- ----- ----- ----- ----
    1     39.1  18.7  181   3750  2007
    2     39.5  17.4  186   3800  2007

#>
function Delete-Field
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [ValidateScript({ $_ -ne 0 })]
        [Alias('p')]
        [int[]] $Property,
        
        [Parameter(Mandatory=$False, ValueFromPipeline=$True)]
        [PSObject] $InputObject
    )
    # get all property names
    [String[]] $OldPropertyNames = ($input[0].PSObject.Properties).Name
    [String[]] $SelectedProperties = for ($i=0; $i -lt $Property.Count; $i++){
        if ( $Property[$i] -lt 0 ){
            Write-Output $OldPropertyNames[$Property[$i]]
        } else {
            Write-Output $OldPropertyNames[$($Property[$i] - 1)]
        }
    }
    $splatting = @{
        ExcludeProperty = $SelectedProperties
    }
    $input | Select-Object @splatting
}
