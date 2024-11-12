<#
.SYNOPSIS
    Auto-Clip (Alias: aclip) - Get from clipboard and Set to clipboard from pipeline

    Automatically distinguishes between "Get-Clipboard" and "Set-Clipboard"
    depending on the situation. If detects pipeline input, it runs as
    "Set-Clipboard", otherwise it runs "Get-Clipboard".

        Set clipboard
        PS> echo "hoge" | aclip
            hoge
        
        Get clioboard
        PS> acilp
            hoge
        
        Get and Replace and Set clipboard
        PS> aclip | %{ $_ -replace "hoge", "fuga" } | aclip
            fuga


.LINK
    Get-OGP (ml), Get-ClipboardAlternative (gclipa),
    clip2file, clip2push, clip2shortcut, clip2img, clip2txt, clip2normalize

.EXAMPLE
    # Set clipboard
    echo "hoge" | aclip
        hoge

    # Get clioboard
    acilp
        hoge

    # Get and Replace and Set clipboard
    aclip | %{ $_ -replace "hoge", "fuga" } | aclip
        fuga

.EXAMPLE
    # Get clipped files
    ("copy files to clipboard")

    # Output as file object
    aclip
    
        Directory: path/to/the/dir
    
        Mode     LastWriteTime Length Name
        ----     ------------- ------ ----
        -a--- 2023/09/03 13:40   3525 Get-CMLog_function.ps1
        -a--- 2024/01/14  9:11  19917 Get-DateAlternative_function.ps1


    # Output as plain text path
    aclip -AsPlainText
        path/to/the/dir/Get-CMLog_function.ps1
        path/to/the/dir/Get-DateAlternative_function.ps1

.EXAMPLE
    # Get uri
    aclip -AsPlainText
        https://github.com/

    # Default output
    aclip
        AbsolutePath   : /
        AbsoluteUri    : https://github.com/
        LocalPath      : /
        Authority      : github.com
        HostNameType   : Dns
        IsDefaultPort  : True
        IsFile         : False
        IsLoopback     : False
        PathAndQuery   : /
        Segments       : {/}
        IsUnc          : False
        Host           : github.com
        Port           : 443
        Query          :
        Fragment       :
        Scheme         : https
        OriginalString : https://github.com/
        DnsSafeHost    : github.com
        IdnHost        : github.com
        IsAbsoluteUri  : True
        UserEscaped    : False
        UserInfo       :

.EXAMPLE
    # Get clipped image (e.g. screen shot)
    aclip
        Tag                  :
        PhysicalDimension    : {Width=1273, Height=935}
        Size                 : {Width=1273, Height=935}
        Width                : 1273
        Height               : 935
        HorizontalResolution : 96
        VerticalResolution   : 96
        Flags                : 335888
        RawFormat            : MemoryBMP
        PixelFormat          : Format32bppRgb
        PropertyIdList       : {}
        PropertyItems        : {}
        Palette              : System.Drawing.Imaging.ColorPalette
        FrameDimensionsList  : {7462dc86-6180-4c7e-8e3f-ee7333a7a483}

    # Get clipped image and Output to file
        aclip -ImagePath a

            Directory: path/to/the/dir

        Mode      LastWriteTime  Length Name
        ----      -------------  ------ ----
        -a---  2024/11/02  6:31  116412 a.png

#>
function Auto-Clip {
    param (
        [Parameter( Mandatory=$False, Position=0 )]
        [Alias('p')]
        [String[]] $Property
        ,
        [Parameter( Mandatory=$False )]
        [Alias('t')]
        [Switch] $AsPlainText
        ,
        [Parameter( Mandatory=$False )]
        [Alias('q')]
        [Switch] $Quiet
        ,
        [Parameter( Mandatory=$False )]
        [String] $ImagePath
        ,
        [Parameter( Mandatory=$False )]
        [Alias('Screenshot')]
        [Switch] $MSPaint
        ,
        [Parameter( Mandatory=$False )]
        [Alias('c')]
        [Switch] $Clear
        ,
        [Parameter( Mandatory=$False )]
        [Alias('e')]
        [String] $Expand
        ,
        [Parameter( Mandatory=$False )]
        [Alias('n')]
        [Switch] $Name
        ,
        [parameter( Mandatory=$False, ValueFromPipeline=$True )]
        [object[]] $InputObject
    )
    if ( $Clear ){
        $Null | Set-Clipboard
        #Add-Type -AssemblyName System.Windows.Forms
        #[System.Windows.Forms.Clipboard]::Clear
        return
    }
    # read from pipeline
    if ( $input.Count -gt 0 ){
        Write-Debug "Read from pipeline"
        if ( $Quiet ){
            ## Saves output in a clipboard
            $input | Set-Clipboard
        } else {
            ## Tee :Saves output in a clipboard and also sends it down the pipeline.
            $input | Set-Clipboard ; Get-Clipboard
        }
        return
    }
    # read from clipboard
    Add-Type -AssemblyName System.Windows.Forms
    [Object[]] $objAry = @()
    #
    # as image
    #
    try {
        if ( ([Windows.Forms.Clipboard]::GetImage()).GetType().FullName -eq "System.Drawing.Bitmap" ){
            $objAry = @([Windows.Forms.Clipboard]::GetImage())
            if ( $objAry.Count -gt 0 ){
                Write-Debug "Read from Clipboard::GetImage()"
                if ( -not $ImagePath -and $MSPaint ){
                    # Get image from ~/Pictures/Screenshots
                    [String] $screenShotPath = Get-ChildItem -LiteralPath "${HOME}/Pictures/Screenshots/" `
                        | Sort-Object LastWriteTime -Descending `
                        | Select-Object -First 1 -ExpandProperty "FullName"
                    if ( $screenShotPath -eq '' ){
                        Write-Error "No image found." -ErrorAction Stop
                    }
                    Write-Debug $screenShotPath
                    Get-Item -LiteralPath "$screenShotPath"
                    if ($IsWindows){
                        Start-Process -FilePath "${HOME}\AppData\Local\Microsoft\WindowsApps\mspaint.exe" -ArgumentList """$screenShotPath"""
                    } else {
                        Invoke-Item "$saveFilePath"
                    }
                } elseif ( $ImagePath ){
                    $clipImage = [Windows.Forms.Clipboard]::GetImage()
                    if ($clipImage -ne $null) {
                        ## set save file path
                        [string] $yyyymmdd = Get-Date -Format "yyyy-MM-dd-HHmmssfff"
                        [string] $saveFileName = $ImagePath
                        if ($saveFileName -notmatch '\.png$'){
                            $saveFileName = $saveFileName + '.png'
                        }
                        [string] $saveFileDir  = Split-Path -Parent $saveFileName
                        if ( $saveFileDir -eq '' ){
                            [string] $saveFileDir = (Resolve-Path -LiteralPath .).Path
                        }
                        [string] $saveBaseName = Split-Path -Leaf $saveFileName
                        if ( Test-Path -LiteralPath $saveFileDir ){
                            # pass
                        } else {
                            Write-Error "Path: $saveFileDir is not exists."
                        }
                        $saveFilePath = (Resolve-Path -LiteralPath $saveFileDir).Path `
                            | Join-Path -ChildPath $saveBaseName
                        ## save as image file
                        Write-Debug "SaveAs: $saveFilePath"
                        $clipImage.Save($saveFilePath)
                        Get-Item -LiteralPath $saveFilePath
                        if ($MSPaint){
                            if ($IsWindows){
                                Start-Process -FilePath "${HOME}\AppData\Local\Microsoft\WindowsApps\mspaint.exe" -ArgumentList """$saveFilePath"""
                            } else {
                                Invoke-Item "$saveFilePath"
                            }
                        }
                    } else {
                        Write-Error "No image in clip board." -ErrorAction Stop
                    }
                } else {
                    # output as image object
                    if ( $Property.Count -gt 0 ){
                        Write-Output $objAry | Select-Object -Property $Property
                    } else {
                        Write-Output $objAry
                    }
                }
                return
            }
            if ( $ImagePath ){
                Write-Error "Image could not detected." -ErrorAction Stop
            }
            return
        }
    } catch {
        # pass
    }
    #
    # as file object
    #
    try {
        $objAry = @([Windows.Forms.Clipboard]::GetFileDropList())
        if ( $objAry.Count -gt 0 ){
            Write-Debug "Read from Clipboard::GetFileDropList()"
            foreach ( $f in @($objAry | Sort-Object) ){
                if ( $AsPlainText ){
                    Write-Output $f
                } else {
                    # output as file object
                    $objFile = Get-Item -LiteralPath $((Resolve-Path -LiteralPath $f).Path)
                    if ( $Name ){
                        Write-Output $objFile.Name
                    } elseif ( $Expand ){
                        Write-Output $objFile.$Expand
                    } elseif ( $AsPlainText ){
                        Write-Output $objFile.FullName
                    } else {
                        if ( $Property.Count -gt 0 ){
                            Write-Output $objFile | Select-Object -Property $Property
                        } else {
                            Write-Output $objFile
                        }
                    }
                }
            }
            return
        }
    } catch {
        # pass
    }
    #
    # as text
    #
    try {
        $objAry = @([Windows.Forms.Clipboard]::GetText() -split "`r?`n")
        if ( $objAry.Count -gt 0 ){
            Write-Debug "Read from Clipboard::GetText()"
            foreach ( $f in $objAry ){
                if ( $AsPlainText ){
                    # output as-is
                    Write-Output $f
                    continue
                }
                if ( [string] $f -match '^http:|^https:' ){
                    # parse uri
                    if ( $Property.Count -gt 0 ){
                        [Uri]::new($f) | Select-Object -Property $Property
                    } else {
                        [Uri]::new($f)
                    }
                    continue
                }
                if ( $True ){
                    # output as-is
                    Write-Output $f
                    continue
                }
            }
            return
        }
    } catch {
        # pass
    }
    #
    # as data object
    #
    #try {
    #    $objAry = @([Windows.Forms.Clipboard]::GetDataObject())
    #    if ( $objAry.Count -gt 0 ){
    #        Write-Debug "Read from Clipboard::GetDataObject()"
    #        if ( $Property.Count -gt 0 ){
    #            Write-Output $objAry | Select-Object -Property $Property
    #        } else {
    #            Write-Output $objAry
    #        }
    #        return
    #    }
    #} catch {
    #    # pass
    #}
    Write-Debug "Read from Get-Clipboard"
    Get-Clipboard
}
# set alias
[String] $tmpAliasName = "aclip"
[String] $tmpCmdName   = "Auto-Clip"
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
