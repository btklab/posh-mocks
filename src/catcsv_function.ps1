<#
.SYNOPSIS

catcsv - concatenate csv files

任意のフォルダにあるUTF-8なCSVファイル群を
ひとつのCSVファイルにまとめる。

空行は自動でスキップする
CSVヘッダは「有or無」どちらかに統一されている必要あり。
ヘッダ「無」の場合は-NoHeaderオプションをつける

Get-Contentによる単純なテキスト結合のため区切り文字の指定はない。
出力ファイルがすでに存在しておれば、エラーで止まる。
Listスイッチで、処理せずにターゲットファイルだけをリスト。

Usage: catcsv
    * カレントディレクトリの'*.csv'を'out.csv'に出力する

関連: catcsv.py, catcsv_function.ps1, (python csvkit)csvsql, in2csv

.PARAMETER List
処理をせずにターゲットファイルだけを列挙

.PARAMETER NoHeader
ヘッダなしCSVを連結する

.EXAMPLE
catcsv
-> カレントディレクトリの'*.csv'を'out.csv'に出力する

.EXAMPLE
catcsv -NoHeader
-> インプットCSVがすべてヘッダなしの場合

.EXAMPLE
catcsv a*.csv
-> 'a*.csv'に該当するCSVファイルを結合し'out.csv'に出力する

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
        [ValidateSet('UTF-8', 'Shift_JIS')]
        [string] $Encoding = 'UTF-8',

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
