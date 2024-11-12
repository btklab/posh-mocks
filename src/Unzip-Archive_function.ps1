<#
.SYNOPSIS
    Unzip-Archive (Alias: clip2unzip) - Expand the clipboaded zip files to the directory where they exists

    The Unzip-Archive (this) expands zip files to that's the same name
    as the zip files like the Expand-Archive (built-in) command,
    but the default extraction destination is different:
    
        - (built-in) Expand-Archive expands to the current location
        - (this) Unzip-Archive expands to the location where the zip files exists

    Usage:

        1. Copy Zip files to the clipboard
        2. run `clip2unzip [-f|-Force]`
        3. the copied Zip files are expanded
           to the directory where they exists 

    If the Uri (beginning with 'http') is clipped,
    the zip file is first downloaded to '~/Downloads' and then expanded.

.EXAMPLE
    # Prepare: clip zip files to the clipboad
    # and run the following command
    PS > clip2unzip

        Expand-Archive [The archive file 'path/to/the/zipdir/PowerShell-7.4.0-win-x64.zip' …]

        Directory: path/to/the/zipdir

        Mode        LastWriteTime Length Name
        ----        ------------- ------ ----
        d---- 2023/12/24    11:52        PowerShell-7.4.0-win-x64

    # and open expanded dir in Explorer or Push-Location
    PS > clip2unzip -f | ii
    PS > clip2unzip -f | pushd

.EXAMPLE
    # clip uri
    "https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/PowerShell-7.4.0-win-x64.zip" `
        | Set-Clipboard

    # Download zip from web (into ~/Downloads) and Expand zip
    clip2unzip

        Web request status [Downloaded: 28.9 MB of 105.4 MB                                        ]
        Expand-Archive [The archive file 'path/to/the/zipdir/PowerShell-7.4.0-win-x64.zip' …]

        Directory: path/to/the/zipdir

        Mode        LastWriteTime Length Name
        ----        ------------- ------ ----
        d---- 2023/12/24    11:52        PowerShell-7.4.0-win-x64


    # and Open expanded directory in Explorer or Push-Location
    PS > clip2unzip -f | ii
    PS > clip2unzip -f | Pushd

.EXAMPLE
    # variation of input
    ## input fullpath-text from stdin
    PS > "path/to/the/zipdir/PowerShell-7.4.0-win-x64.zip" | clip2unzip -f

    ## input file object from stdin
    PS > ls ~/Downloads/PowerShell-7.4.0-win-x64.zip | clip2unzip -f

    ## specify -File <fullpath-text>
    PS > clip2unzip -File "path/to/the/zipdir/PowerShell-7.4.0-win-x64.zip" -f

.NOTES
    Expand-Archive (Microsoft.PowerShell.Archive) - PowerShell
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.archive/expand-archive

#>
function Unzip-Archive {
    [CmdletBinding()]
    param (
        [Parameter( Mandatory=$False, Position=0 )]
        [Object[]] $File
        ,
        [Parameter( Mandatory=$False )]
        [Alias('f')]
        [Switch] $Force
        ,
        [Parameter( Mandatory=$False )]
        [String] $Path
        ,
        [Parameter( Mandatory=$False )]
        [Switch] $Push
        ,
        [Parameter( Mandatory=$False )]
        [Alias('ii')]
        [Switch] $InvokeItem
        ,
        [Parameter( Mandatory=$False )]
        [Switch] $SkipDownload
        ,
        [Parameter( Mandatory=$False )]
        [Switch] $OnlyDownload
        ,
        [Parameter( Mandatory=$False )]
        [Switch] $SkipTest
        ,
        [Parameter( Mandatory=$False )]
        [String] $Algorithm = 'SHA256'
        ,
        [Parameter( Mandatory=$False )]
        [String] $Hash
        ,
        [Parameter( Mandatory=$False )]
        [Alias('a')]
        [Switch] $UnzipAndInvoke
        ,
        [parameter( Mandatory=$False, ValueFromPipeline=$True )]
        [object[]] $InputObject
    )
    ## init filepath array
    [string[]] $readLineAry = @()
    if ( $File.Count -gt 0 ){
        # get file from param
        [string[]] $readLineAry = @($File)
    } elseif ( $input.Count -gt 0 ){
        ## get file path from pipeline text
        [string[]] $readLineAry = $input `
            | ForEach-Object {
                if ( ($_ -is [System.IO.FileInfo]) -or ($_ -is [System.IO.DirectoryInfo]) ){
                    ## from filesystem object
                    [string] $oText = $_.FullName
                } elseif ( $_ -is [System.IO.FileSystemInfo] ){
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
    } else {
        ## get filepath from clipboard
        Add-Type -AssemblyName System.Windows.Forms
        ### get filepath as object
        [string[]] $readLineAry = @([Windows.Forms.Clipboard]::GetFileDropList())
        if ( $readLineAry.Count -eq 0 ){
            ### get filepath as text
            [string[]] $readLineAry = @([Windows.Forms.Clipboard]::GetText() -split "`r?`n") `
                | ForEach-Object {
                    if ($_ -ne '' ) { $_.Replace('"', '') }
                }
        }
    }
    # test
    if ( -not $readLineAry ){
        Write-Error "no input file." -ErrorAction Stop
    }
    # sort file paths
    #[string[]] $sortedReadLineAry = $readLineAry | Sort-Object
    [string[]] $sortedReadLineAry = $readLineAry
    # main
    foreach ( $item in $sortedReadLineAry ){
        if ($item -match '^http:|^https:'){
            # download from web
            $u = [Uri]::new($item)
            [String] $strUri = $u.AbsoluteUri
            [String] $leaf = $u.Segments | Select-Object -Last 1
            [String] $Name = [System.Web.HttpUtility]::UrlDecode($leaf)
            [String] $outDir = (Resolve-Path "${HOME}/Downloads").Path
            # test path
            if (Test-Path -LiteralPath $outDir -PathType Container){
                [String] $outPath = "$outDir" | Join-Path -ChildPath $Name
            } else {
                Write-Error "$outDir is not exists or is not directory." -ErrorAction Stop
            }
            if (Test-Path -LiteralPath $outPath){
                if ( $Force ){
                    #pass
                } elseif ( $Hash ){
                    # compare hash values
                    [String] $hashVal = Get-FileHash -LiteralPath $outPath -Algorithm $Algorithm `
                        | Select-Object -ExpandProperty Hash
                    Write-Host "Set: $Hash" -ForegroundColor Yellow
                    Write-Host "Get: $hashVal" -ForegroundColor Yellow
                    if ( $Hash -eq $hashVal ){
                        #pass
                        [bool] $isHashMatched = $True
                        Write-Host "Result: Matched hash. skip download." -ForegroundColor Green
                    } else {
                        [bool] $isHashMatched = $False
                        Write-Host "Result: UnMatched hash. start downloadd." -ForegroundColor Red
                        #Write-Error "Hash does not equal." -ErrorAction Stop
                    }
                } else {
                    if ( -not $SkipDownload ){
                        Write-Error "$outPath is already exists." -ErrorAction Stop
                    }
                }
            }
            if ( $Force -and $SkipDownload ){
                #pass
            } elseif ( $Force ){
                Invoke-WebRequest -Uri $strUri -OutFile $outPath
            } elseif ( $SkipDownload ){
                #pass
            } elseif ( $Hash ) {
                if ( $isHashMatched ){
                    #pass
                } else {
                    Invoke-WebRequest -Uri $strUri -OutFile $outPath
                }
            } else {
                Invoke-WebRequest -Uri $strUri -OutFile $outPath
            }
            $item = $outpath
        }
        # get destination directory
        [String] $outDir  = Split-Path -Parent (Resolve-Path -LiteralPath $item).Path
        [String] $outName = (Get-Item -LiteralPath $item).BaseName
        [String] $outExt = (Get-Item -LiteralPath $item).Extension
        if ( $SkipTest ){
            #pass
        } elseif ( $outExt -notmatch '\.zip$'){
            Write-Error "A file other than "".zip"" was specified:`n$(Resolve-Path -LiteralPath $item -Relative)" -ErrorAction Stop
        }
        if ( $Path ){
            [String] $outDir = (Resolve-Path -LiteralPath $Path).Path
        }
        # test path
        if (Test-Path -LiteralPath $outDir -PathType Container){
            [String] $outPath = "$outDir" | Join-Path -ChildPath $outName
            if (Test-Path -LiteralPath $outPath -PathType Container){
                if ( -not $Force ){
                    Write-Error "$outPath is already exists." -ErrorAction Stop
                }
            }
        } else {
            Write-Error "$outDir is not exists or is not directory." -ErrorAction Stop
        }
        # expand zip
        [String] $destPath = $outPath
        if ( $OnlyDownload ){
            #pass
        } else {
            # zip
            Expand-Archive `
                -LiteralPath $item `
                -DestinationPath $destPath `
                -Force:$Force
        }
        Get-FileHash -LiteralPath $item -Algorithm $Algorithm `
            | Select-Object `
                Algorithm, `
                Hash , `
                @{N="From";E={(Get-Item -LiteralPath $_.Path).Name}}, `
                @{N="To";E={(Get-Item -LiteralPath $destPath).Name}}
    }
    if ( $InvokeItem -or $UnzipAndInvoke ){
        Invoke-Item -LiteralPath $outPath
    }
    if ( $Push ){
        Push-Location -LiteralPath $outPath
    }
}
# set alias
[String] $tmpAliasName = "clip2unzip"
[String] $tmpCmdName   = "Unzip-Archive"
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
