<#
.SYNOPSIS
    dot2gviz - Wrapper for Graphviz:dot command

    Prerequisite: graphviz must be installed
    Note: input dot file must be UTF-8 without BOM

    Install Graphviz
        - uri: https://graphviz.org/
            - winget install --id Graphviz.Graphviz --source winget
        - and execute cmd with administrator privileges
            - dot -c

    When using japanese in dot file on windows,
    japanese fonts must be specified in the "fontname"
    of the dot file to be desplayed properly.

.LINK
    pu2java, dot2gviz, pert, pert2dot, pert2gantt2pu, mind2dot, mind2pu, gantt2pu, logi2dot, logi2dot2, logi2dot3, logi2pu, logi2pu2, flow2pu, seq2pu


.PARAMETER InputFile
    DOT file to be input.
    Encode is UTF-8 without BOM only.

.PARAMETER OutputFileType
    Output file Format

.PARAMETER FontName
    Specify the fontname.
    default: MS Gothic

.PARAMETER LayoutEngine
    Specify layout engine.

    circo ...A circular graph.

    dot   ...A hierarchical graph.
             oriented twoards directed graphs.
             default layout engine.

    fdp   ...Spring model graph.
             for undirected graphs

    neato ...Spring model graph.
             for undirected graphs

    osage ...Array type graph.

    sfdp  ...A multiscale version of fdp.
             Suitable for large undirected graphs.

    twopi ...Radial graph.
             Nodes are arranged in concentric circles.

    patchwork ...Patchwork-like graph.

.PARAMETER NotOverWrite
    Overwrite prohibition

.PARAMETER ErrorCheck
    Output dot command without execute.

#>
function dot2gviz {

    Param(
        [Parameter( Position=0, Mandatory=$True)]
        [Alias('i')]
        [string] $InputFile,

        [Parameter( Position=1, Mandatory=$False)]
        [ValidateSet(
            "bmp", "cgimage", "dot", "eps", "exr",
            "fig", "gd", "gv", "gif", "gtk", "ico",
            "imap", "cmap", "jpg", "json", "pdf",
            "pic", "pict", "plain", "png", "pov",
            "ps", "ps2", "psd", "sgi", "svg", "tga",
            "tiff", "tk", "vml", "wbmp", "webp", "x11")]
        [Alias('o')]
        [string] $OutputFileType = "png",

        [Parameter( Mandatory=$False)]
        [Alias('f')]
        [string] $FontName,

        [Parameter( Mandatory=$False)]
        [Alias('l')]
        [ValidateSet(
            "circo", "dot", "fdp", "neato",
            "osage", "sfdp", "twopi", "patchwork")]
        [string] $LayoutEngine,

        [Parameter( Mandatory=$False)]
        [switch] $NotOverWrite,

        [Parameter( Mandatory=$False)]
        [switch] $ErrorCheck
    )
    # private function
    function isCommandExist ($cmd) {
        try { Get-Command $cmd -ErrorAction Stop | Out-Null
            return $True
        } catch {
            return $False
        }
    }
    ## cmd test
    if ( -not (isCommandExist "dot")){
        if ($IsWindows){
            Write-Error 'Install Graphviz' -ErrorAction Continue
            Write-Error '  uri: https://graphviz.org/' -ErrorAction Continue
            Write-Error '  winget install --id Graphviz.Graphviz --source winget' -ErrorAction Continue
            Write-Error 'and execute cmd with administrator privileges:' -ErrorAction Continue
            Write-Error '  dot -c' -ErrorAction Stop
        } else {
            Write-Error 'Install Graphviz' -ErrorAction Continue
            Write-Error '  uri: https://graphviz.org/' -ErrorAction Continue
            Write-Error '  sudo apt install graphviz' -ErrorAction Stop
        }
    }
    ## is input file exist?
    if( -not (Test-Path $InputFile) ){
        Write-Error "$InputFile is not exist." -ErrorAction Stop
    }
    ## create output file name
    [string] $oDir = Resolve-Path -LiteralPath $InputFile -Relative | Split-Path -Parent
    [string] $oFil = (Get-Item -LiteralPath $InputFile).BaseName
    [string] $oFil = "$oFil.$OutputFileType"
    [string] $oFilePath = Join-Path $oDir $oFil
    if( (Test-Path -LiteralPath $oFilePath) -and ($NotOverWrite) ){
        Write-Error "$oFil is already exist." -ErrorAction Stop
    }

    ## execute command
    #Usage: dot [-Vv?] [-(GNE)name=val] [-(KTlso)<val>] <dot files>
    [String] $cmd = "dot"
    [String[]] $ArgumentList = @()
    if( ($FontName -eq '') -and ($LayoutEngine -eq '') ){
        ## No FontName, No LayoutEngine
        [String[]] $ArgumentList += @("-T" + $OutputFileType)
        [String[]] $ArgumentList += @("-o", """$oFilePath""")
        [String[]] $ArgumentList += @("""$InputFile""")

    }elseif( ($FontName -ne '') -and ($LayoutEngine -eq '') ){
        ## FontName, No LayoutEngine
        [String[]] $ArgumentList += @("-Nfontname=""$FontName""")
        [String[]] $ArgumentList += @("-Efontname=""$FontName""")
        [String[]] $ArgumentList += @("-Gfontname=""$FontName""")
        [String[]] $ArgumentList += @("-T" + $OutputFileType)
        [String[]] $ArgumentList += @("-o", """$oFilePath""")
        [String[]] $ArgumentList += @("""$InputFile""")

    }elseif( ($FontName -eq '') -and ($LayoutEngine -ne '') ){
        ## No FontName, LayoutEngine
        [String[]] $ArgumentList += @("-K" + $LayoutEngine)
        [String[]] $ArgumentList += @("-T" + $OutputFileType)
        [String[]] $ArgumentList += @("-o", """$oFilePath""")
        [String[]] $ArgumentList += @("""$InputFile""")

    }else{
        ## FontName, LayoutEngine
        [String[]] $ArgumentList += @("-Nfontname=""$FontName""")
        [String[]] $ArgumentList += @("-Efontname=""$FontName""")
        [String[]] $ArgumentList += @("-Gfontname=""$FontName""")
        [String[]] $ArgumentList += @("-K" + $LayoutEngine)
        [String[]] $ArgumentList += @("-T" + $OutputFileType)
        [String[]] $ArgumentList += @("-o", """$oFilePath""")
        [String[]] $ArgumentList += @("""$InputFile""")
    }
    if($ErrorCheck){
        Write-Output "$cmd $($ArgumentList -join ' ')"
    }else{
        # set splatting
        $splatting = @{
            FilePath = $cmd
            ArgumentList = $ArgumentList
        }
        if ($True){
            $splatting.Set_Item("NoNewWindow", $True)
            $splatting.Set_Item("Wait", $True)
        }
        # execute command
        try {
            Start-Process @splatting
        } catch {
            Write-Error $Error[0] -ErrorAction Stop
        }
        Get-Item -LiteralPath $oFilePath
    }
}
