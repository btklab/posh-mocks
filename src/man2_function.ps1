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
    man2 -Column 5
    PS > man2 -c 5

    Add-CrLf           decil           han         mind2pu       table2md
    Add-CrLf-EndOfFile delf            head        movw          tac
    addb               dot2gviz        i           Override-Yaml tail
    addl               filehame        image2md    pawk          tarr
    addr               fillretu        jl          percentile    tateyoko
    addt               flat            json2txt    pu2java       teatimer
    cat2               flow2pu         juni        pwmake        tenki
    catcsv             fpath           keta        retu          tex2pdf
    chead              fval            kinsoku     rev           toml2psobject
    clip2img           fwatch          lcalc       rev2          uniq
    clipwatch          gantt2pu        linkcheck   say           vbStrConv
    conv               gdate           linkextract sed           watercss
    ConvImage          Get-AppShortcut logi2dot    sed-i         wrap
    count              Get-OGP         logi2pu     self          yarr
    csv2sqlite         getfirst        man2        seq2pu        ycalc
    csv2txt            getlast         map2        sleepy        ysort
    ctail              grep            mdgrep      sm2           zen
    ctail2             gyo             mind2dot    summary

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
    ls *.ps1 -File `
        | select @{L="Name";E={$_.Name.Replace('_function.ps1','')}} `
        | Format-Wide -Column 5

    Add-CrLf      Add-CrLf-End… addb         addl         addr
    addt          cat2          catcsv       chead        clip2img
    clipwatch     conv          ConvImage    count        csv2sqlite
    csv2txt       ctail         ctail2       decil        delf
    dot2gviz      filehame      fillretu     flat         flow2pu
    fpath         fval          fwatch       gantt2pu     gdate
    Get-AppShort… Get-OGP       getfirst     getlast      grep
    gyo           han           head         i            image2md
    jl            json2txt      juni         keta         kinsoku
    lcalc         linkcheck     linkextract  logi2dot     logi2pu
    man2          map2          mdgrep       mind2dot     mind2pu
    movw          Override-Yaml pawk         percentile   pu2java
    pwmake        retu          rev          rev2         say
    sed           sed-i         self         seq2pu       sleepy
    sm2           summary       table2md     tac          tail
    tarr          tateyoko      teatimer_ex… teatimer     tenki
    tex2pdf       toml2psobject uniq         vbStrConv    watercss
    wrap          yarr          ycalc        ysort        zen


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
        Get-ChildItem -Path $targetDir -File `
            | Sort-Object -Property Name `
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
            | Sort-Object -Property Name `
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
            | Sort-Object -Property Name `
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
