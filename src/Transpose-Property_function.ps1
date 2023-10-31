<#
.SYNOPSIS
    Transpose-Property - Transpose Property name and value

.LINK
    Measure-Object, Measure-Stats, Measure-Summary, Transpose-Property

.EXAMPLE
    # input
    Import-Excel -Path iris.xlsx `
        | Measure-Object "sepal_length", "petal_length" -AllStats `
        | Format-Table -AutoSize

    Count Average    Sum Maximum Minimum StandardDeviation Property
    ----- -------    --- ------- ------- ----------------- --------
      150    5.84 876.50    7.90    4.30              0.83 sepal_length
      150    3.76 563.70    6.90    1.00              1.77 petal_length

    # Transpose object
    Import-Excel -Path iris.xlsx `
        | Measure-Object "sepal_length", "petal_length" -AllStats `
        | Transpose-Property -Property "Property" `
        | Format-Table -AutoSize

    Property          sepal_length petal_length
    --------          ------------ ------------
    Count                      150          150
    Average                   5.84         3.76
    Sum                     876.50       563.70
    Maximum                   7.90         6.90
    Minimum                   4.30         1.00
    StandardDeviation         0.83         1.77

.EXAMPLE
    # input
    Import-Csv -Path planets.csv `
        | Measure-Summary `
        | Format-Table -AutoSize

    Property       Count        Sum    Mean       SD     Min    Qt25 Median    Qt75       Max
    --------       -----        ---    ----       --     ---    ---- ------    ----       ---
    number          1035    1848.00    1.79     1.24    1.00    1.00 1         2.00      7.00
    orbital_period   992 1986894.26 2002.92 26014.73    0.09    5.45 39.98   526.62 730000.00
    mass             513    1353.38    2.64     3.82    0.00    0.23 1.26      3.06     25.00
    distance         808  213367.98  264.07   733.12    1.35   32.56 55.25   180.00   8500.00
    year            1035 2079388.00 2009.07     3.97 1989.00 2007.00 2010   2012.00   2014.00

    # Transpose object
    Import-Csv -Path planets.csv `
        | Measure-Summary `
        | Transpose-Property -Property "Property" `
        | Format-Table -AutoSize

    Property  number orbital_period    mass  distance       year
    --------  ------ --------------    ----  --------       ----
    Count       1035            992     513       808       1035
    Sum      1848.00     1986894.26 1353.38 213367.98 2079388.00
    Mean        1.79        2002.92    2.64    264.07    2009.07
    SD          1.24       26014.73    3.82    733.12       3.97
    Min         1.00           0.09    0.00      1.35    1989.00
    Qt25        1.00           5.45    0.23     32.56    2007.00
    Median         1          39.98    1.26     55.25       2010
    Qt75        2.00         526.62    3.06    180.00    2012.00
    Max         7.00      730000.00   25.00   8500.00    2014.00
    Outlier       93            126      52       106         32

#>
function Transpose-Property
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$False, Position=0)]
        [Alias('p')]
        [String] $Property = "Property",
        
        [Parameter(Mandatory=$False, ValueFromPipeline=$True)]
        [PSObject] $InputObject
    )
    # get all property names
    [String[]] $AllPropertyNames = ($input[0].PSObject.Properties).Name `
        | Where-Object { $_ -ne $Property }
    [String[]] $AxisPropertyNames = $input | Select-Object -ExpandProperty $Property
    Write-Debug "AllProp  : $($AllPropertyNames  -join ', ')"
    Write-Debug "AxisProp : $($AxisPropertyNames -join ', ')"
    # main
    [int] $add = 0
    for ($i=0; $i -lt $AllPropertyNames.Count; $i++){
        $outObject = [ordered]@{}
        $outObject[$Property] = $AllPropertyNames[$i]
        for ($k=0; $k -lt $AxisPropertyNames.Count; $k++){
            [string] $axName = $AxisPropertyNames[$k]
            $outObject[$axName] = ($input[$k]).($AllPropertyNames[$add])
        }
        [pscustomobject]$outObject
        $add++
    }
}
