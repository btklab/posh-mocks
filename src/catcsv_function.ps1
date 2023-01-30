<#
.SYNOPSIS
    catcsv - Concatenate csv files

    Combine UTF-8 CSV files in any directory
    into single CSV file.

    Blank lines are automatically skipped.
    CSV headers must be standardized to
    either "present or absent". 

    Add the -NoHeader switch when reading
    a CSV files without headers.

    If output file already exists, it will stop
    with an error without overwiting.

    -Dry run with -List siwtch.

.LINK
    catcsv.py, catcsv_function.ps1, (python csvkit)csvsql, in2csv

.PARAMETER List
    Dryrun (output only target file names without execute command)

.PARAMETER NoHeader
    Concatenate headerless CSV files.

.EXAMPLE
    catcsv
    # Concatenate "*.csv" in the current directory
    # to 'out.csv'

.EXAMPLE
    catcsv a*.csv
    # Concatenate "a*.csv" in the current directory
    # to 'out.csv'

.EXAMPLE
    catcsv -NoHeader
    # Concatenate headerless "*.csv" in the current
    # directory to 'out.csv'

#>
function catcsv {
    Param
    (
        [Parameter(Mandatory=$false, Position=0)]
        [Alias('i')]
        [string] $Path = "./*.csv",

        [Parameter(Mandatory=$false)]
        [Alias('o')]
        [string] $Output = "./out.csv",

        [Parameter(Mandatory=$false)]
        [ValidateSet('utf8', 'oem')]
        [string] $Encoding = 'utf8',

        [Parameter(Mandatory=$false)]
        [Switch] $List,

        [Parameter(Mandatory=$false)]
        [Switch] $OffList,

        [Parameter(Mandatory=$false)]
        [Switch] $OverWrite,

        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [Switch] $NoHeader
    )

    ## test path
    $outputFile = $Output
    if (Test-Path -LiteralPath $outputFile){
        $outputFile = Resolve-Path -LiteralPath $outputFile }
    if(( -not $OverWrite ) -and ( Test-Path -LiteralPath $outputFile )){
        Write-Error "file: $Output is already exists." -ErrorAction Stop }
    if(Test-Path -LiteralPath $outputFile ){
        Remove-Item -LiteralPath $outputFile -Force }

    ## parse option
    if($NoHeader){ $skipRow = 0 } else { $skipRow = 1 }

    ## main
    $files = Get-ChildItem -Path $Path
    if ($files.Count -eq 0){
        ### empty files
        Write-Host "No csv file detected."
    } elseif ($List){
        $files
    } else {
        ### read first file
        $files `
            | Select-Object -First 1 `
            | Get-Content -Encoding $Encoding `
            | Select-String -Pattern '.' -Raw `
            | Out-String -Stream `
            | Out-File -Path $outputFile -Encoding $Encoding
        ### read remaining files
        $files `
            | Select-Object -Skip 1 `
            | ForEach-Object {
                $_ `
                | Get-Content -Encoding $Encoding `
                | Select-Object -Skip $skipRow `
                | Select-String -Pattern '.' -Raw `
                | Out-String -Stream `
                | Out-File -Path $outputFile -Encoding $Encoding -Append
            }
        if ( -not $OffList){ $files }
    }
}
