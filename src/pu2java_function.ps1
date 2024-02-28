<#
.SYNOPSIS
    pu2java - Wrapper for plantuml.jar command

    Prerequisit: java, graphviz, plantuml.jar are installed.

        - plantuml official site
            - https://plantuml.com/en/
        - graphviz
            - https://graphviz.org/
        - java
            - https://www.java.com/en/download/
        - plantuml.jar
            - https://sourceforge.net/projects/plantuml/files/plantuml.jar/download
    
    -Jar <path> specifies the "plantuml.jar" file location.
    IF it is in the following location, it will be automatically
    recognized, so you don't neet to specify it with -Jar <path>.

        - Windwos/Linux
            - ./plantuml.jar
        - Windows:
            - ${HOME}/bin/plantuml/plantuml.jar
        - Linux:
            - /usr/local/bin/plantuml/plantuml.jar
    
    The input file is UTF-8 NoBOM.
    The output format is automatically determined from the output
    file extension.

.LINK
    pu2java, dot2gviz, pert, pert2dot, pert2gantt2pu, mind2dot, mind2pu, gantt2pu, logi2dot, logi2dot2, logi2dot3, logi2pu, logi2pu2, flow2pu, seq2pu


.PARAMETER OutputFileType
    Default = "png"

.PARAMETER OutputDir
    Output directory

.PARAMETER Charset
    Input file encode.
    Default = UTF-8

.PARAMETER Jar
    Specifying JAR executable file path.
    Default = ${HOME}/bin/plantuml/plantuml.jar

.PARAMETER TestDot
    Test integration with graphviz.

.PARAMETER CheckOnly
    To check the syntax of files without generating images

.PARAMETER NoMetadata
    Do not include metadata in PNG/SVG output.

.PARAMETER NotOverWrite
    Do not overwrite if output file already exists.

.PARAMETER ErrorCheck
    Print the command without execuitng the command.

#>
function pu2java {

    Param(
        [Parameter( Position=0, Mandatory=$True)]
        [Alias('i')]
        [string] $InputFile,

        [Parameter( Position=1, Mandatory=$False)]
        [ValidateSet(
            "gui", "png", "svg", "eps", "pdf",
            "vdx", "xmi", "scxml", "html", "txt",
            "utxt", "latex", "latex:nopreamble")]
        [Alias('o')]
        [string] $OutputFileType = "png",

        [Parameter( Mandatory=$False)]
        [Alias('c')]
        [string] $ConfigFile,

        [Parameter( Mandatory=$False)]
        [string] $OutputDir,

        [Parameter( Mandatory=$False)]
        [string] $Charset = "UTF-8",

        [Parameter( Mandatory=$False)]
        [string] $Jar,

        [Parameter( Mandatory=$False)]
        [switch] $TestDot,

        [Parameter( Mandatory=$False)]
        [switch] $CheckOnly,

        [Parameter( Mandatory=$False)]
        [switch] $NoMetadata,

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
    if ( -not (isCommandExist "java")){
        if ($IsWindows){
            Write-Error 'Install the Java Runtime Environment' -ErrorAction Continue
            Write-Error '  uri: https://www.java.com/en/download/' -ErrorAction Continue
            Write-Error '  winget install --id Oracle.JavaRuntimeEnvironment --source winget' -ErrorAction Stop
        } else {
            Write-Error 'Install the Java Runtime Environment' -ErrorAction Continue
            Write-Error '  uri: https://www.java.com/en/download/' -ErrorAction Continue
            Write-Error '  sudo apt install default-jre' -ErrorAction Stop
        }
    }
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

    ## is JAR execute file exist?
    if($Jar){
        if ( -not (Test-Path -LiteralPath $Jar ) ){
            Write-Error "$Jar is not exist." -ErrorAction Stop
        }
        [string] $jarFilePath = (Resolve-Path -LiteralPath $Jar -Relative).Replace('\','/')
    } elseif (Test-Path "plantuml.jar"){
        [string] $jarFilePath = "./plantuml.jar"
    } elseif ($IsWindows){
        [string] $jarPath = "$(${HOME})\bin\plantuml\plantuml.jar"
        if ( -not (Test-Path -LiteralPath $jarPath ) ){
            Write-Error "$jarPath is not exist." -ErrorAction Stop
        }
        [string] $jarFilePath = (Resolve-Path -LiteralPath $jarPath -Relative).Replace('\','/')
    } elseif ($IsLinux){
        [string] $jarPath = "/usr/local/bin/plantuml/plantuml.jar"
        if ( -not (Test-Path -LiteralPath $jarPath ) ){
            Write-Error "$jarPath is not exist." -ErrorAction Stop
        }
        [string] $jarFilePath = "/usr/local/bin/plantuml/plantuml.jar"
    }
    if( -not (Test-Path -LiteralPath $jarFilePath) ){
        Write-Error "$jarFilePath is not exist." -ErrorAction Stop
    }

    ## is input file exist?
    if( -not (Test-Path $InputFile) ){
        Write-Error "$InputFile is not exist." -ErrorAction Stop
    } else {
        $ifile = $(Resolve-Path -Path $InputFile -Relative).replace('\','/')
    }
    if($ConfigFile){
        if( !(Test-Path $ConfigFile) ){
            Write-Error "$ConfigFile is not exist." -ErrorAction Stop
        }
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
    #Usage: java -jar plantuml.jar -version
    #Usage: java -jar plantuml.jar -testdot
    #Usage: java -jar plantuml.jar -tpng
    [String] $cmd = "java"
    [String[]] $ArgumentList = @()
    if($TestDot){
        $ArgumentList += @("-jar", """$jarFilePath""")
        $ArgumentList += @("-testdot")
    }else{
        $ArgumentList += @("-jar", """$jarFilePath""")
        $ArgumentList += @("-charset", """$Charset""")
        if($NoMetadata){
            $ArgumentList += @("-nometadata")
        }
        if($CheckOnly){
            $ArgumentList += @("-checkonly")
        }
        if($ConfigFile){
            [string] $configPath = $(Resolve-Path -Path $ConfigFile -Relative).replace('\','/')
            $ArgumentList += @("-config", """$configPath""")
        }
        if($OutputFileType -eq "gui"){
            $ArgumentList += @("-gui")
        }else{
            #$CommandLineStr += " -t ""$OutputFileType"""
            $ArgumentList += @("-t$OutputFileType")
            if($OutputDir){
                $odir = $(Resolve-Path -Path $OutputDir -Relative).replace('\','/')
                $ArgumentList += @("-o", """$odir""")
            }
            $ArgumentList += @("""$ifile""")
        }
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
        if($TestDot){
            Write-Output "$cmd $($ArgumentList -join ' ')"
        }elseif($CheckOnly){
            Write-Output "$cmd $($ArgumentList -join ' ')"
        }elseif($OutputFileType -eq 'gui'){
            #pass
        }else{
            Get-Item -LiteralPath $oFilePath
        }
    }
}

