<#
.SYNOPSIS
    man2 - Formats filelist as a wide table and gets manual

    Usage:
        man2
        man2 sm2 [-Paging]
    
    Options:
        -l: List commands in a column
        -p: Out-Host -Paging

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

    Add-LineBreakEndOfFile clip2file      han         rev2
    Add-LineBreak          clip2hyperlink head        rev
    Add-Stats              clip2img       image2md    say
    Apply-Function         clip2normalize jl          sed-i
    ConvImage              clip2push      json2txt    sed
    Delete-Field           clip2shortcut  juni        self
    Detect-XrsAnomaly      conv           keta        seq2pu
    Drop-NA                count          kinsoku     sleepy
    Get-AppShortcut        csv2sqlite     lcalc       sm2
    Get-First              csv2txt        linkcheck   summary
    Get-Last               ctail2         linkextract table2md
    Get-OGP                ctail          list2table  tac
    GroupBy-Object         decil          logi2dot    tail-f
    Invoke-Link            delf           logi2pu     tail
    Measure-Property       dot2gviz       man2        tarr
    Override-Yaml          filehame       map2        tateyoko
    Plot-BarChart          fillretu       mdfocus     teatimer
    Rename-Normalize       flat           mdgrep      tenki
    Replace-NA             flow2pu        mind2dot    tex2pdf
    Select-Field           fpath          mind2pu     toml2psobject
    Shorten-PropertyName   fval           movw        uniq
    addb                   fwatch         pawk        vbStrConv
    addl                   gantt2pu       percentile  watercss
    addr                   gdate          pu2java     wrap
    addt                   getfirst       push2loc    yarr
    cat2                   getlast        pwmake      ycalc
    catcsv                 grep           pwsync      ysort
    chead                  gyo            retu        zen

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

    Add-LineBreakEn… Add-LineBreak    Add-Stats        Apply-Function
    ConvImage        Delete-Field     Detect-XrsAnoma… Drop-NA
    Get-AppShortcut  Get-First        Get-Last         Get-OGP
    GroupBy-Object   Invoke-Link      Measure-Property Override-Yaml
    Plot-BarChart    Rename-Normalize Replace-NA       Select-Field
    Shorten-Propert… addb             addl             addr
    addt             cat2             catcsv           chead
    clip2file        clip2hyperlink   clip2img         clip2normalize
    clip2push        clip2shortcut    conv             count
    csv2sqlite       csv2txt          ctail2           ctail
    decil            delf             dot2gviz         filehame
    fillretu         flat             flow2pu          fpath
    fval             fwatch           gantt2pu         gdate
    getfirst         getlast          grep             gyo
    han              head             image2md         jl
    json2txt         juni             keta             kinsoku
    lcalc            linkcheck        linkextract      list2table
    logi2dot         logi2pu          man2             map2
    mdfocus          mdgrep           mind2dot         mind2pu
    movw             pawk             percentile       pu2java
    push2loc         pwmake           pwsync           retu
    rev2             rev              say              sed-i
    sed              self             seq2pu           sleepy
    sm2              summary          table2md         tac
    tail-f           tail             tarr             tateyoko
    teatimer         tenki            tex2pdf          toml2psobject
    uniq             vbStrConv        watercss         wrap
    yarr             ycalc            ysort            zen

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
    if ($isPwshDir) {
        # pwsh dir
        $fileList = Get-ChildItem -Path $targetDir -File `
            | Sort-Object { -join ( [int[]] $_.Name.ToCharArray()).ForEach('ToString', 'x4') } `
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
            | Sort-Object { -join ( [int[]] $_.Name.ToCharArray()).ForEach('ToString', 'x4') } `
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
