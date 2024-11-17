<#
.SYNOPSIS
    man2 - Formats filelist as a wide table and gets manual

    Usage:
        man2
        man2 sm2 [-Paging]
    
    Options:
        -l: List commands in a column
        -p: Out-Host -Paging
        -r: Sort by recent updates

    Dependency:
        flat, tateyoko, keta

        -Independent: use Format-Wide,
                      not use dependent files.

.LINK
    Format-Wide -Column <n>

    Format-Wide (Microsoft.PowerShell.Utility)
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/format-wide

    Select-Object (Microsoft.PowerShell.Utility
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/select-object

.EXAMPLE
    man2 -Column 4
    PS > man2 -c 4

    Add-LineBreakEndOfFile clip2file      head        say
    Add-LineBreak          clip2hyperlink image2md    sed-i
    Add-Stats              clip2img       jl          sed
    Apply-Function         clip2normalize json2txt    self
    ConvImage              clip2push      juni        seq2pu
    Delete-Field           clip2shortcut  keta        sleepy
    Detect-XrsAnomaly      conv           kinsoku     sm2
    Drop-NA                count          lcalc       summary
    Get-AppShortcut        csv2sqlite     linkcheck   table2md
    Get-First              csv2txt        linkextract tac
    Get-Histogram          ctail2         list2table  tail-f
    Get-Last               ctail          logi2dot    tail
    Get-OGP                decil          logi2pu     tarr
    GroupBy-Object         delf           man2        tateyoko
    Invoke-Link            dot2gviz       map2        teatimer
    Measure-Stats          filehame       mdfocus     tenki
    Override-Yaml          fillretu       mdgrep      tex2pdf
    Plot-BarChart          flat           mind2dot    toml2psobject
    Rename-Normalize       flow2pu        mind2pu     uniq
    Replace-NA             fpath          movw        vbStrConv
    Select-Field           fval           pawk        watercss
    Shorten-PropertyName   fwatch         percentile  wrap
    addb                   gantt2pu       pu2java     yarr
    addl                   gdate          push2loc    ycalc
    addr                   getfirst       pwmake      ysort
    addt                   getlast        pwsync      zen
    cat2                   grep           retu
    catcsv                 gyo            rev2
    chead                  han            rev

.EXAMPLE
    man2 getlast

    Get help of getlast command.

.EXAMPLE
    man2 -c 3

    Specify the number of columns to output.

.EXAMPLE
    man2 -Exclude 'Get'

    Exclude commands contains "Get".


.EXAMPLE
    man2 -Include 'Get'

    Include commands contains "Get".

.EXAMPLE
    # use only Format-Wide command let
    ls src/*_function.ps1 -File `
      | Sort-Object {
        -join ( [int[]] $_.Name.ToCharArray()).ForEach('ToString', 'x4')
        } `
      | select @{L="Name";E={$_.Name.Replace('_function.ps1','')}} `
      | Format-Wide -Column 4

    Add-LineBreakEndOfFi… Add-LineBreak        Add-Stats            Apply-Function
    ConvImage             Delete-Field         Detect-XrsAnomaly    Drop-NA
    Get-AppShortcut       Get-First            Get-Histogram        Get-Last
    Get-OGP               GroupBy-Object       Invoke-Link          Measure-Stats
    Override-Yaml         Plot-BarChart        Rename-Normalize     Replace-NA
    Select-Field          Shorten-PropertyName addb                 addl
    addr                  addt                 cat2                 catcsv
    chead                 clip2file            clip2hyperlink       clip2img
    clip2normalize        clip2push            clip2shortcut        conv
    count                 csv2sqlite           csv2txt              ctail2
    ctail                 decil                delf                 dot2gviz
    filehame              fillretu             flat                 flow2pu
    fpath                 fval                 fwatch               gantt2pu
    gdate                 getfirst             getlast              grep
    gyo                   han                  head                 image2md
    jl                    json2txt             juni                 keta
    kinsoku               lcalc                linkcheck            linkextract
    list2table            logi2dot             logi2pu              man2
    map2                  mdfocus              mdgrep               mind2dot
    mind2pu               movw                 pawk                 percentile
    pu2java               push2loc             pwmake               pwsync
    retu                  rev2                 rev                  say
    sed-i                 sed                  self                 seq2pu
    sleepy                sm2                  summary              table2md
    tac                   tail-f               tail                 tarr
    tateyoko              teatimer             tenki                tex2pdf
    toml2psobject         uniq                 vbStrConv            watercss
    wrap                  yarr                 ycalc                ysort
    zen

#>
function man2 {

    Param(
        [Parameter(Position=0, Mandatory=$False, ValueFromPipeline=$true)]
        [Alias('f')]
        [string]$FunctionName,

        [Parameter(Mandatory=$False)]
        [Alias('c')]
        [int]$Column = 10,

        [Parameter(Mandatory=$False)]
        [Alias('e')]
        [string]$Exclude,

        [Parameter(Mandatory=$False)]
        [Alias('p')]
        [switch]$Paging,

        [Parameter(Mandatory=$False)]
        [Alias('r')]
        [switch]$Recent,

        [Parameter(Mandatory=$False)]
        [Alias('d')]
        [switch]$Descending,

        [Parameter(Mandatory=$False)]
        [Alias('i')]
        [string]$Include,

        [Parameter(Mandatory=$False)]
        [switch]$Examples,

        [Parameter(Mandatory=$False)]
        [switch]$Independent,

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
        # open with explorer
        [string] $dir = $FunctionName
        [string] $dir = (Resolve-Path -Path $dir).Path
        [string] $targetDir = $dir
        [string] $targetDir = (Resolve-Path -Path $targetDir).Path
    } else {
        [string] $dir = $PSScriptRoot
        [string] $dir = (Resolve-Path -Path $dir).Path
        [string] $targetDir = Join-Path $dir '*.ps1'
        [bool] $isPwshDir = $True
    }

    # Do not use dependency files
    if ( $Independent ){
        Get-ChildItem -Path $targetDir -File -Name `
            | Sort-Object { -join ( [int[]]($_.Name.ToCharArray()).ForEach('ToString', 'x4')) } `
            | Select-Object @{ label="Name"; expression={ $_.Name.Replace('_function.ps1','') } } `
            | Where-Object {
                if (($Exclude) -and ($Include)) {
                    $_.Name -match $Include -and $_.Name -notmatch $Exclude
                }elseif ($Exclude) {
                    $_.Name -notmatch $Exclude
                }elseif ($Include) {
                    $_.Name -match $Include
                }else{
                    $_.Name -match "."
                }
            } `
            | Format-Wide -Column $Column
        return
    }

    # get function files
    if ( $Recent ){
        [scriptblock] $sortScript = { $_.LastWriteTime } `
    } else {
        [scriptblock] $sortScript = { -join ( [int[]] $_.Name.ToCharArray()).ForEach('ToString', 'x4') } `
    }
    $splattingSort = @{
        Property = $sortScript
        Descending = $Descending
    }
    if ($isPwshDir) {
        # pwsh dir
        $fileList = Get-ChildItem -Path $targetDir -File `
            | Sort-Object @splattingSort `
            | Where-Object { $_.Name -match '_function\.ps1$' } `
            | Select-Object @{ label="Name"; expression={ $_.Name.Replace('_function.ps1','') } } `
            | Where-Object {
                if (($Exclude) -and ($Include)) {
                    $_.Name -match $Include -and $_.Name -notmatch $Exclude
                }elseif ($Exclude) {
                    $_.Name -notmatch $Exclude
                }elseif ($Include) {
                    $_.Name -match $Include
                }else{
                    $_.Name -match "."
                }
            } `
            | Select-Object -ExpandProperty Name
    } else {
        # not pwsh dir
        $fileList = Get-ChildItem -Path $targetDir -File  `
            | Sort-Object @splattingSort `
            | Where-Object {
                if (($Exclude) -and ($Include)) {
                    $_.Name -match $Include -and $_.Name -notmatch $Exclude
                }elseif ($Exclude) {
                    $_.Name -notmatch $Exclude
                }elseif ($Include) {
                    $_.Name -match $Include
                }else{
                    $_.Name -match "."
                }
            } `
            | Select-Object -ExpandProperty Name
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

        if ($Column -lt 1){
            [int] $bufCol = 1
        } else {
            [int] $bufCol = $Column
        }
        [int] $dispRow = [math]::Ceiling( ($fileList.Count) / $bufCol)
        while (($lineWidthMax -gt $bufWidth) -and ($bufCol -gt 0)){
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
                | keta -l `
                | ForEach-Object {
                    Write-Output $($_.Trim())
                }
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
