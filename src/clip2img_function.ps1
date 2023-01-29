<# 
.SYNOPSIS
    clip2img -- Save clip board image as an image file

    clip2img [directory] [-DirView] [-MSPaint] [-View]
    clip2img -d ~/Documents
    clip2img -n a.png

    "~/Pictures" is the default image save location.
    "clip-yyyy-MM-dd-HHmmssfff.png" is the default
    save file name.

    Note that if output file already exists,
    it will be overwritten

.PARAMETER Name
    Specify the output file name.

.PARAMETER MSPaint
    Save image file and open file using MSPaint.

.PARAMETER Clip
    Save image file and copy file name to clipboard.

.PARAMETER View
    Save file and open file using default viewer.

.PARAMETER Directory
    Specify directory to save image file.

.PARAMETER Prefix
    Specify filename prefix.

.PARAMETER DirView
    Open the folder using explorer
    where the image file is saved.

.EXAMPLE
clip2img

====
Save image file as "clip-yyyy-MM-dd-HHmmssfff.png"
to the current directory.


PS > clip2img -d ~/Picture

====
Save image file as "clip-yyyy-MM-dd-HHmmssfff.png"
to "~/Pictures" directory.


.EXAMPLE
clip2img -n a.png

====
Save image file as "a.png" in
the current directory.

#>
function clip2img {
    Param(
        [Parameter(Mandatory=$False, Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('d')] [string] $Directory = "$HOME/Pictures",

        [Parameter(Mandatory=$False)]
        [Alias('n')] [string] $Name,

        [Parameter(Mandatory=$False)]
        [string] $Prefix = '',

        [Parameter(Mandatory=$False)]
        [Alias('p')] [switch] $MSPaint,

        [Parameter(Mandatory=$False)]
        [Alias('c')] [switch] $Clip,

        [Parameter(Mandatory=$False)]
        [Alias('i')] [switch] $DirView,

        [Parameter(Mandatory=$False)]
        [Alias('v')] [switch] $View
    )

    Add-Type -AssemblyName System.Windows.Forms
    $clipImage = [Windows.Forms.Clipboard]::GetImage()
    if ($clipImage -ne $null) {
        ## set save file path
        if ($Name){
            ## manual set filename
            $saveFileName = $Name
            if ($saveFileName -notmatch '\.png$'){
                $saveFileName = $saveFileName + '.png'
            }
        } else {
            ## auto set filename
            [string]$prefStr = 'clip'
            [string]$yyyymmdd = Get-Date -Format "yyyy-MM-dd-HHmmssfff"
            [string]$saveFileName = "$prefStr-$yyyymmdd.png"
        }
        [string]$saveFileName = "$Prefix" + "$saveFileName"
        ## set output dir path
        if ( -not (Test-Path -LiteralPath "$Directory") ){
            ## Non-existent directory name is an error.
            Write-Error "The specified directory does not exist. ($Directory)" -ErrorAction Stop
        }
        $outputDir = Resolve-Path -LiteralPath "$Directory"
        $saveFilePath = Join-Path $outputDir $saveFileName
        ## save as image file
        $clipImage.Save($saveFilePath)
        Get-Item $saveFilePath
        if ($View) {
            Invoke-Item $saveFilePath
        }elseif ($MSPaint){
            if ($IsWindows){
                 & "${HOME}\AppData\Local\Microsoft\WindowsApps\mspaint.exe" "$saveFilePath"
            } else {
                Invoke-Item "$saveFilePath"
            }
        }
        if ($Clip){
            Get-ChildItem -LiteralPath $saveFileName -Name | Set-Clipboard
        }
        if ($DirView){
            Invoke-Item "$outputDir"
        }
    } else {
        Write-Error "No image in clip board." -ErrorAction Stop
    }
}
