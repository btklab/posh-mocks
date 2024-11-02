<#
.SYNOPSIS
    Get-ClipboardAlternative (Alias: gclipa)- Get file/image/uri objects from clipboard

    Auto detect:
        from clipped file  : output to file object
        from clipped image : output to image object or save as png-file
        from clipped uri   : output to uri object
        from clipped text  : output to file object

.LINK
    Get-OGP (ml), Get-ClipboardAlternative (gclipa),
    clip2file, clip2push, clip2shortcut, clip2img, clip2txt, clip2normalize

.EXAMPLE
    # in the case of pipeline input, 
    # attempts to convert it to a file object
    # and returns an error if it fails.
    PS > cat dataset-powerBI.txt | gclipa
    
        Get-ClipboardAlternative: Cannot find path '# Power BI dataset' because it does not exist.
    
    # You can avoid the error with the "-AsPlainText" switch,
    # but in this case you should use Get-Clipboard.
    PS > cat dataset-powerBI.txt | gclipa -Debug -AsPlainText
    
        DEBUG: Read from pipeline
        # Power BI dataset
        https://learn.microsoft.com/ja-jp/power-bi/create-reports/sample-datasets
        https://learn.microsoft.com/ja-jp/power-bi/create-reports/sample-sales-and-marketing
        https://github.com/microsoft/powerbi-desktop-samples/tree/main/powerbi-service-samples

    # If you input file objects from the pipeline,
    # this function will return file objects,
    # but there is probably no need to use this function.
    PS > ls *.md -File | gclipa
    
            Directory: path/to/the/directory
    
        Mode                 LastWriteTime         Length Name
        ----                 -------------         ------ ----
        -a---          2023/12/04    23:55            256 books.md
        -a---          2023/12/04    23:55             29 diaries.md
        -a---          2023/12/10    17:38           2497 notes.md
        -a---          2023/12/04    23:55           3018 recipes.md
        -a---          2023/12/23    12:47           1389 tickets.md

    PS > ls *.txt -File | gclipa Length, Name

        Length Name
        ------ ----
           256 books.txt
            29 diaries.txt
           365 language.txt
           984 meanings.txt
          3334 notes.txt
          3018 recipes.txt
          1682 tickets.txt


.EXAMPLE
    # If input clipped files,
    # this function attempts to return file objects
    ("Preparation : clip files")
    PS > gclipa
    
            Directory: Directory: path/to/the/directory
    
        Mode   LastWriteTime       Length Name
        ----   -------------       ------ ----
        -a---  2023/12/23    19:55   6472 clip2hyperlink_function.ps1
        -a---  2023/06/13    23:12    920 clip2base64_function.ps1
        -a---  2023/12/23    19:55   4254 clip2dir_function.ps1
        -a---  2023/12/23    19:55   6719 clip2file_function.ps1

    # or return file fullpathas as plaintext with -AsPlainText switch
    PS > gclipa -AsPlainText
    
        C:/path/to/the/directory/clip2hyperlink_function.ps1
        C:/path/to/the/directory/clip2base64_function.ps1
        C:/path/to/the/directory/clip2dir_function.ps1
        C:/path/to/the/directory/clip2file_function.ps1


.EXAMPLE
    # If input clipped uris, this function attempts to return uri objects
    
    # set uri to clipboard
    PS > Set-Clipboard -Value "https://github.com/PowerShell/PowerShell"

    # get uri object (default)

    PS > gclipa
        
		AbsolutePath   : /PowerShell/PowerShell
		AbsoluteUri    : https://github.com/PowerShell/PowerShell
		LocalPath      : /PowerShell/PowerShell
		Authority      : github.com
		HostNameType   : Dns
		IsDefaultPort  : True
		IsFile         : False
		IsLoopback     : False
		PathAndQuery   : /PowerShell/PowerShell
		Segments       : {/, PowerShell/, PowerShell}
		IsUnc          : False
		Host           : github.com
		Port           : 443
		Query          :
		Fragment       :
		Scheme         : https
		OriginalString : https://github.com/PowerShell/PowerShell
		DnsSafeHost    : github.com
		IdnHost        : github.com
		IsAbsoluteUri  : True
		UserEscaped    : False
		UserInfo       :

    # get plain text uri
    PS > gclipa -AsPlainText
        https://github.com/PowerShell/PowerShell

    # open in default browser
    PS > gclipa -ii
        https://github.com/PowerShell/PowerShell

.EXAMPLE
    # If input clipped image, this function attempts to return image object
    PS > gclipa
        
        Tag                  :
        PhysicalDimension    : {Width=731, Height=359}
        Size                 : {Width=731, Height=359}
        Width                : 731
        Height               : 359
        HorizontalResolution : 96
        VerticalResolution   : 96
        Flags                : 335888
        RawFormat            : MemoryBMP
        PixelFormat          : Format32bppRgb
        PropertyIdList       : {}
        PropertyItems        : {}
        Palette              : System.Drawing.Imaging.ColorPalette
        FrameDimensionsList  : {7462dc86-6180-4c7e-8e3f-ee7333a7a483}

    # Output clipped image to png file
    PS > gclipa -ImagePath ~/Downloads/image.png -Debug
        
        DEBUG: Read from Clipboard::GetImage()
        DEBUG: SaveAs: path/to/the/dir/image.png
        
        Directory: path/to/the/directory
        
        Mode  LastWriteTime    Length Name
        ----  -------------    ------ ----
        -a--- 2023/12/24 15:07  34641 image.png

#>
function Get-ClipboardAlternative {
    param (
        [Parameter( Mandatory=$False, Position=0 )]
        [Alias('p')]
        [String[]] $Property,
        
        [Parameter( Mandatory=$False )]
        [Alias('f')]
        [Object[]] $File,
        
        [Parameter( Mandatory=$False )]
        [Alias('t')]
        [Switch] $AsPlainText,
        
        [Parameter( Mandatory=$False )]
        [String] $ImagePath,
        
        [Parameter( Mandatory=$False )]
        [Switch] $ImageView,
        
        [Parameter( Mandatory=$False )]
        [Switch] $ImageDir,
        
        [Parameter( Mandatory=$False )]
        [Switch] $ImageClip,
        
        [Parameter( Mandatory=$False )]
        [Switch] $ImageAllAct,
        
        [Parameter( Mandatory=$False )]
        [Switch] $MSPaint,
        
        [Parameter( Mandatory=$False )]
        [Alias('ii')]
        [Switch] $InvokeItem,
        
        [parameter( Mandatory=$False, ValueFromPipeline=$True )]
        [object[]] $InputObject
    )
    ## read from parameter
    if ( $File.Count -gt 0 ){
        Write-Debug "Read from -File parameter"
        foreach ( $f in $File ){
            if ( ($f -is [System.IO.FileInfo]) `
                -or ($f -is [System.IO.DirectoryInfo]) `
                -or ($f -is [System.IO.FileSystemInfo]) ){
                # input is file object
                if ( $AsPlainText ){
                    Write-Output $($f.FullName)
                } else {
                    if ( $Property.Count -gt 0 ){
                        Write-Output $f | Select-Object -Property $Property
                    } else {
                        Write-Output $f
                    }
                }
            } else {
                # input is file path text
                $objFile = Get-Item -LiteralPath $((Resolve-Path -LiteralPath $f).Path)
                if ( $AsPlainText ){
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
    # read from pipeline
    if ( $input.Count -gt 0 ){
        Write-Debug "Read from pipeline"
        foreach ( $f in @($input) ){
            if ( ($f -is [System.IO.FileInfo]) `
                -or ($f -is [System.IO.DirectoryInfo]) `
                -or ($f -is [System.IO.FileSystemInfo]) ){
                # input is file object
                if ( $AsPlainText ){
                    Write-Output $($f.FullName)
                } else {
                    if ( $Property.Count -gt 0 ){
                        Write-Output $f | Select-Object -Property $Property
                    } else {
                        Write-Output $f
                    }
                }
                continue
            } else {
                try {
                    Get-Item -LiteralPath $($f.Replace('"', '')) -ErrorAction Stop > $Null
                    # input is file path text
                    $objFile = Get-Item -LiteralPath $($f.Replace('"', '')) -ErrorAction Stop
                    if ( $AsPlainText ){
                        Write-Output $objFile.FullName
                    } else {
                        if ( $Property.Count -gt 0 ){
                            Write-Output $objFile | Select-Object -Property $Property
                        } else {
                            Write-Output $objFile
                        }
                    }
                    continue
                } catch {
                    # input is text
                    if ( $AsPlainText ){
                        Write-Output $f
                        continue
                    }
                    Write-Error "Cannot find path '$f' because it does not exist." -ErrorAction Stop
                }
            }
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
                if ( $ImagePath ){
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
                        if ( $ImageClip -or $ImageAllAct ){
                            Get-ChildItem -LiteralPath $saveFilePath -Name | Set-Clipboard
                        }
                        if ( $ImageDir -or $ImageAllAct -or $InvokeItem ){
                            Invoke-Item $saveFileDir
                        }
                        if ( $ImageView -or $ImageAllAct -or $InvokeItem ) {
                            Invoke-Item $saveFilePath
                        } elseif ($MSPaint){
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
        #pass
    }
    #
    # as file object
    #
    $objAry = @([Windows.Forms.Clipboard]::GetFileDropList())
    if ( $objAry.Count -gt 0 ){
        Write-Debug "Read from Clipboard::GetFileDropList()"
        foreach ( $f in @($objAry | Sort-Object) ){
            if ( $AsPlainText ){
                Write-Output $f
            } else {
                # output as file object
                $objFile = Get-Item -LiteralPath $((Resolve-Path -LiteralPath $f).Path)
                if ( $AsPlainText ){
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
    #
    # as text
    #
    $objAry = @([Windows.Forms.Clipboard]::GetText() -split "`r?`n")
    if ( $objAry.Count -gt 0 ){
        Write-Debug "Read from Clipboard::GetText()"
        foreach ( $f in $objAry ){
            if ( $InvokeItem ){
                Start-Process -FilePath $f
                Write-Output $f
                continue
            }
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
                # parse as file object
                try {
                    Get-Item -LiteralPath $($f.Replace('"', '')) -ErrorAction Stop > $Null
                    # input is file path text
                    $objFile = Get-Item -LiteralPath $($f.Replace('"', '')) -ErrorAction Stop
                    if ( $AsPlainText ){
                        Write-Output $objFile.FullName
                    } else {
                        if ( $Property.Count -gt 0 ){
                            Write-Output $objFile | Select-Object -Property $Property
                        } else {
                            Write-Output $objFile
                        }
                    }
                    continue
                } catch {
                    # input is text
                    if ( $AsPlainText ){
                        Write-Output $f
                        continue
                    }
                    Write-Error "Cannot find path '$f' because it does not exist." -ErrorAction Stop
                }
            }
        }
        return
    }
    #
    # as data object
    #
    $objAry = @([Windows.Forms.Clipboard]::GetDataObject())
    if ( $objAry.Count -gt 0 ){
        Write-Debug "Read from Clipboard::GetDataObject()"
        if ( $Property.Count -gt 0 ){
            Write-Output $objAry | Select-Object -Property $Property
        } else {
            Write-Output $objAry
        }
        return
    }
}
# set alias
[String] $tmpAliasName = "gclipa"
[String] $tmpCmdName   = "Get-ClipboardAlternative"
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
