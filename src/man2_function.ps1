<#
.SYNOPSIS

拡張コマンドのマニュアルを表示する

 -lオプション: コマンド名を一列に出力 

依存: flat, tateyoko, keta

関連: -


.DESCRIPTION
-

.EXAMPLE
PS C:\>man2
拡張コマンドをリストする

.EXAMPLE
PS C:\>man2 getlast
getlast コマンドのヘルプを表示する

.EXAMPLE
PS C:\>man2 -c 3
列数を指定

.EXAMPLE
PS C:\>man2 -Exclude 'Get'
「Get」を含むコマンドを除外

.EXAMPLE
PS C:\>man2 -Include 'Get'
「Get」を含むコマンドのみ出力

#>
function man2 {

    Param(
        [Parameter(Position=0, Mandatory=$False, ValueFromPipeline=$true)]
        [Alias('f')]
        [string]$FunctionName,

        [Parameter(Mandatory=$False)]
        [Alias('c')]
        [int]$Col = 3,

        [Parameter(Mandatory=$False)]
        [Alias('e')]
        [string]$Exclude,

        [Parameter(Mandatory=$False)]
        [Alias('i')]
        [string]$Include,

        [Parameter(Mandatory=$False)]
        [switch]$Examples,

        [Parameter(Mandatory=$False)]
        [Alias('l')]
        [switch]$Line
    )
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
        $file_list = Get-ChildItem -Path $targetDir -File `
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
        $file_list = Get-ChildItem -Path $targetDir -File  `
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
    #Write-Output $targetDir
    # get file num
    $file_count = $file_list `
        | Measure-Object `
        | Select-Object -ExpandProperty Count
    # get display row num
    #$disp_row = [math]::Floor([int]$file_count / $Col)
    $disp_row = [math]::Ceiling([int]$file_count / $Col)
    # output
    if (($FunctionName) -and (Test-Path $FunctionName -PathType Container)){
        if($isWindows){
            $file_list `
                | flat $disp_row `
                | tateyoko `
                | keta -l
        } else {
            $file_list `
                | flat $disp_row `
                | tateyoko `
                | keta -l `
                | less
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
                Get-Help $FunctionName -Examples | Out-Host -Paging
            } else {
                Get-Help $FunctionName -Examples | less
            }
        } else {
            if($isWindows){
                Get-Help $FunctionName -Full | Out-Host -Paging
            } else {
                Get-Help $FunctionName -Full | less
            }
        }
    } elseif ($Line) {
        # output list
        if($isWindows){
            $file_list
        }else{
            $file_list | less
        }
    } else {
        if($isWindows){
            $file_list `
                | flat $disp_row `
                | tateyoko `
                | keta -l
        } else {
            $file_list `
                | flat $disp_row `
                | tateyoko `
                | keta -l `
                | less
        }
    }
}
