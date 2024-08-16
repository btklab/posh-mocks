<# 
.SYNOPSIS
    ClipImageFrom-File - Clips an image from the specified image file.

    Reads the specified image file and stores it on the clipboard.
    The input path for the image file can be one of the following:
    clipboard, file object via pipeline, or file path via pipeline.

    Usage:
        # read from clipped image file
        ClipImageFrom-File

        # read from file object via pipeline
        ls a.png | ClipImageFrom-File

        # read from file path via pipeline
        (ls a.png).FullName | ClipImageFrom-File

.LINK
    clip2file, clip2push, clip2shortcut, clip2img, clip2txt, clip2normalize, ClipImageFrom-File

#>
function ClipImageFrom-File {
    Param(
        [Parameter( Mandatory=$False, ValueFromPipeline=$True, Position=0 )]
        [Alias("f")]
        [string[]] $Files,
        
        [Parameter(Mandatory=$False)]
        [Alias('p')]
        [switch] $MSPaint,
        
        [Parameter(Mandatory=$False)]
        [Alias('o')]
        [switch] $OutputOnlyObject,
        
        [Parameter(Mandatory=$False)]
        [Alias('e')]
        [switch] $SkipError,
        
        [Parameter( Mandatory=$False )]
        [Alias("u")]
        [switch] $UrlDecode        
    )
    ## private function
    function Get-ImageTypeFromExt {
        param(
            [Parameter(Mandatory)]
            [string]$filePath
        )
        try {
            [String] $ext = (Get-Item -LiteralPath $filePath).Extension
            return $ext
        }
        catch {
            Write-Warning "$($_.Exception.Message)" -ErrorAction Stop
        }
    }
    ## init filepath array
    [string[]] $readLineAry = @()
    if ( $input.Count -gt 0 ){
        ## get file path from pipeline text
        [string[]] $readLineAry = $input `
            | ForEach-Object {
                if ( ($_ -is [System.IO.FileInfo]) -or ($_ -is [System.IO.DirectoryInfo]) ){
                    ## from filesystem object
                    [string] $oText = $_.FullName
                } elseif ( $_ -is [System.IO.FileSystemInfo] ){
                    ## from filesystem object
                    [string] $oText = $_.FullName
                } else {
                    ## from text
                    [string] $oText = $_
                }
                Write-Output $oText
            }
        [string[]] $readLineAry = ForEach ($r in $readLineAry ){
            if ( $r -ne '' ){ $r.Replace('"', '') }
        }
    } elseif ( $Files.Count -gt 0 ){
        ## get filepath from option
        [string[]] $readLineAry = $Files | `
            ForEach-Object { (Get-Item -LiteralPath $_).FullName }
    } else {
        ## get filepath from clipboard
        if ( $True ){
            ### get filepath as object
            Add-Type -AssemblyName System.Windows.Forms
            [string[]] $readLineAry = [Windows.Forms.Clipboard]::GetFileDropList()
        }
        if ( -not $readLineAry ){
            ### get filepath as text
            [string[]] $readLineAry = Get-Clipboard | `
                ForEach-Object { if ($_ -ne '' ) { $_.Replace('"', '')} }
        }
    }
    ## test
    if ( -not $readLineAry ){
        Write-Error "no input file." -ErrorAction Stop
    }
    ## sort file paths
    [string[]] $sortedReadLineAry = $readLineAry | Sort-Object
    ## output text with prefix
    [object[]] $obj = foreach ( $f in $sortedReadLineAry ){
        if ( ( $f -match '^file:///' ) -or ( $UrlDecode ) ){
            [string] $f = [uri]::UnEscapeDataString( $($f -replace '^file:///', '') )
        }
        if ( Test-Path -LiteralPath $f ){
            Get-Item -LiteralPath $f
        } else {
            Write-Error "File not found: ""$f""." -ErrorAction Stop
        }
    }
    # main
    ## load assembly
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [String[]] $imagePaths = $obj | ForEach-Object { $_.FullName }
    foreach ( $imagePath in $imagePaths ){
        try {
            $image = [System.Drawing.Image]::FromFile($imagePath)
        } catch {
            if ( -not $SkipError ){
                Write-Error "$($_.Exception.Message)" -ErrorAction Stop
            }
        }
        $imageType = Get-ImageTypeFromExt $imagePath
        $bitmap = New-Object System.Drawing.Bitmap $image
        $bitmap `
            | Select-Object `
                @{N="Name";E={$(Get-Item -Path $imagePath).Name}}, `
                @{N="Ext";E={$imageType}}, `
                *
        if ( $OutputOnlyObject ){ continue }
        $dataObject = New-Object System.Windows.Forms.DataObject
        $dataObject.SetData([System.Windows.Forms.DataFormats]::Bitmap, $bitmap)
        [System.Windows.Forms.Clipboard]::SetDataObject($dataObject, $true)
        #Write-Host "Image loaded to clipboard successfully." -ForegroundColor "Green"
        #Write-Host "Image: $imagePath" -ForegroundColor "Green"
    }
    # invoke clipboard
    if ($MSPaint){
        if ($IsWindows){
            Start-Process -FilePath "${HOME}\AppData\Local\Microsoft\WindowsApps\mspaint.exe"
        }
    }
    return
}
# set alias
[String] $tmpAliasName = "clipimage"
[String] $tmpCmdName   = "ClipImageFrom-File"
[String] $tmpCmdPath = Join-Path `
    -Path $PSScriptRoot `
    -ChildPath $($MyInvocation.MyCommand.Name) `
    | Resolve-Path -Relative
if ( $IsWindows ){ $tmpCmdPath = $tmpCmdPath.Replace('\' ,'/') }
# is alias already exists?
if ((Get-Command -Name $tmpAliasName -ErrorAction SilentlyContinue).Count -gt 0){
    try {
        if ( (Get-Command -Name $tmpAliasName).CommandType -eq "Alias" ){
            if ( (Get-Command -Name $tmpAliasName).ReferencedCommand.Name -eq $tmpCmdName ){
                Set-Alias -Name $tmpAliasName -Value $tmpCmdName -PassThru `
                    | ForEach-Object{
                        Write-Host "$($_.DisplayName)" -ForegroundColor Green
                    }
            } else {
                throw
            }
        } elseif ( "$((Get-Command -Name $tmpAliasName).Name)" -match '\.exe$') {
            Set-Alias -Name $tmpAliasName -Value $tmpCmdName -PassThru `
                | ForEach-Object{
                    Write-Host "$($_.DisplayName)" -ForegroundColor Green
                }
        } else {
            throw
        }
    } catch {
        Write-Error "Alias ""$tmpAliasName ($((Get-Command -Name $tmpAliasName).ReferencedCommand.Name))"" is already exists. Change alias needed. Please edit the script at the end of the file: ""$tmpCmdPath""" -ErrorAction Stop
    } finally {
        Remove-Variable -Name "tmpAliasName" -Force
        Remove-Variable -Name "tmpCmdName" -Force
    }
} else {
    Set-Alias -Name $tmpAliasName -Value $tmpCmdName -PassThru `
        | ForEach-Object {
            Write-Host "$($_.DisplayName)" -ForegroundColor Green
        }
    Remove-Variable -Name "tmpAliasName" -Force
    Remove-Variable -Name "tmpCmdName" -Force
}
