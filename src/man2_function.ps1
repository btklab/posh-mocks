<#
.SYNOPSIS

man2 - Display function list and manual

拡張コマンドのリスト・マニュアルを表示する

Usage:
 man2
 man2 sm2 [-Paging]
 

 -lオプション：コマンド名を一列に出力 
 -pオプション：Out-Host -Paging

依存: flat, tateyoko, keta

.EXAMPLE
man2

拡張コマンドをリストする

.EXAMPLE
man2 getlast

getlast コマンドのヘルプを表示する

.EXAMPLE
man2 -c 3

列数を指定

.EXAMPLE
man2 -Exclude 'Get'

「Get」を含むコマンドを除外

.EXAMPLE
man2 -Include 'Get'

「Get」を含むコマンドのみ出力

#>
function man2 {

    Param(
        [Parameter(Position=0, Mandatory=$False, ValueFromPipeline=$true)]
        [Alias('f')]
        [string]$FunctionName,

        [Parameter(Mandatory=$False)]
        [Alias('c')]
        [int]$Column = 20,

        [Parameter(Mandatory=$False)]
        [Alias('e')]
        [string]$Exclude,

        [Parameter(Mandatory=$False)]
        [Alias('p')]
        [switch]$Paging,

        [Parameter(Mandatory=$False)]
        [Alias('i')]
        [string]$Include,

        [Parameter(Mandatory=$False)]
        [switch]$Examples,

        [Parameter(Mandatory=$False)]
        [Alias('l')]
        [switch]$Line
    )
    # private functions
    function Get-UIBufferSize {
        return (Get-Host).UI.RawUI.BufferSize
    }
    function Get-LineWidth {
        param (
            [Parameter(Mandatory=$False)]
            [switch] $Max = $True,
            [parameter(Mandatory=$False, ValueFromPipeline=$True)]
            [string[]] $InputText
        )
        begin {
            [int] $lineWidth = 0
            $enc = [System.Text.Encoding]::GetEncoding("Shift_JIS")
        }
        process {
            [string] $line = [string] $_
            [int] $tmpWidth = $enc.GetByteCount($line)
            if ($Max){
                if ($tmpWidth -gt $lineWidth){
                    $lineWidth = $tmpWidth
                }
            }
        }
        end {
            return $lineWidth
        }        
    }
    # get script dir
    $isPwshDir = $False
    if (($FunctionName) -and (Test-Path -Path $FunctionName -PathType Container)){
        $dir = $FunctionName
        $dir = Resolve-Path -Path $dir
        $targetDir = Join-Path $dir '*'
        $targetDir = Resolve-Path -Path $targetDir
    } else {
        $dir = $PSScriptRoot
        $dir = Resolve-Path -Path $dir
        $targetDir = Join-Path $dir '*.ps1'
        $isPwshDir = $True
    }
    # get function files
    if ($isPwshDir) {
        # pwsh dir
        $fileList = Get-ChildItem -Path $targetDir -File `
            | Where-Object { $_.Name -match '_function\.ps1$' -and $_.Name -notmatch '^sample' } `
            | Select-Object -ExpandProperty Name `
            | ForEach-Object { $_.Replace('_function.ps1', '') }`
            | ForEach-Object {
                if (($Exclude) -and ($Include)) {
                    if (($_ -notmatch $Exclude) -and ($_ -match $Include)) { Write-Output $_ }
                }elseif ($Exclude) {
                    if  ($_ -notmatch $Exclude) { Write-Output $_ }
                }elseif ($Include) {
                    if  ($_ -match $Include) { Write-Output $_ }
                }else{
                    Write-Output $_
                }
            }
    } else {
        # not pwsh dir
        $fileList = Get-ChildItem -Path $targetDir -File  `
            | Select-Object -ExpandProperty Name `
            | ForEach-Object {
                if (($Exclude) -and ($Include)) {
                    if (($_ -notmatch $Exclude) -and ($_ -match $Include)) { Write-Output $_ }
                }elseif ($Exclude) {
                    if  ($_ -notmatch $Exclude) { Write-Output $_ }
                }elseif ($Include) {
                    if  ($_ -match $Include) { Write-Output $_ }
                }else{
                    Write-Output $_
                }
            }
    }
    # output
    function dispMan {
        param(
            [string[]] $fileList
        )
        # get window width
        [int] $bufWidth = (Get-UIBufferSize).Width
        # set linewidth max value
        [int] $lineWidthMax = 2147483647

        [int] $bufCol = $Column
        while ($lineWidthMax -gt $bufWidth){
            [int] $dispRow = [math]::Ceiling( ($fileList.Count) / $bufCol)
            $lineWidthMax = $fileList `
                | flat $dispRow `
                | tateyoko `
                | keta -l `
                | Get-LineWidth -Max
            $bufCol--
        }
        [string[]] $dispAry = $fileList `
                | flat $dispRow `
                | tateyoko `
                | keta -l
        return $dispAry
    }
    if (($FunctionName) -and (Test-Path $FunctionName -PathType Container)){
        if($isWindows){
            dispMan $fileList
        } else {
            dispMan $fileList | less
        }
    } elseif (($FunctionName) -and (Test-Path $FunctionName -Include *.py)){
        # python script -> help
        if ($IsWindows){
            python $FunctionName --help
        } else {
            python3 $FunctionName --help
        }
    } elseif ($FunctionName) {
        # ps1 function -> Get-Help
        if ($Examples) {
            if($isWindows){
                Get-Help $FunctionName -Examples | Out-Host -Paging:$Paging
            } else {
                Get-Help $FunctionName -Examples | less
            }
        } else {
            if($isWindows){
                Get-Help $FunctionName -Full | Out-Host -Paging:$Paging
            } else {
                Get-Help $FunctionName -Full | less
            }
        }
    } elseif ($Line) {
        # output list
        if($isWindows){
            $fileList
        }else{
            $fileList | less
        }
    } else {
        if($isWindows){
            dispMan $fileList
        } else {
            dispMan $fileList | less
        }
    }
}
