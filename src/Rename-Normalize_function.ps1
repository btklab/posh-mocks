<#
.SYNOPSIS
    Rename-Normalize - File name normalizer for Japanese on windows

    Read and rename file objects from standard input.

    By default, shows what would happen if the command runs.
    The command is not run.

    Execute rename if -Execute switch is specified

    Convert rules:
        half to full-width kana
        full to half-width alphanumeric characters
        replace spaces to underscores

    Optional rules:
        AddDate ...Add date prefix in "yyyy-MM-dd" format

    Dependencies:
        han, zen

    Note:
        Do not execute rename if the file name is the same
        before and after renaming.

        Consecutive spaces are replaced with a single space.

        A hyphen surrounded by spaces or underscores is
        replaced by a hyphen excluding surrounds.

.EXAMPLE
    ## shows what would happen if the command runs.The command is not run.
    ls | Rename-Normalize
        clip2file　function.ps1       => clip2file_function.ps1
        clip2img　ｱｲｳｴｵ　function.ps1 => clip2img_アイウエオ_function.ps1
        clipwatch   -    function.ps1 => clipwatch-function.ps1
        ｃｌｉｐ２ｉｍｇ.ps1          => clip2img.ps1

    ## execute rename if "-Execute" specified
    ls | Rename-Normalize -Execute

.EXAMPLE
    ## Add date prefix in "yyyy-MM-dd" format
    ls | Rename-Normalize -AddDate
        clip2file　function.ps1       => 2023-04-04-clip2file_function.ps1
        clip2img　ｱｲｳｴｵ　function.ps1 => 2023-04-04-clip2img_アイウエオ_function.ps1
        clipwatch   -    function.ps1 => 2023-04-04-clipwatch-function.ps1
        ｃｌｉｐ２ｉｍｇ.ps1          => 2023-04-04-clip2img.ps1

.EXAMPLE
    ## combination with clip2file function
    ("copy files to clipboard and..."")
    clip2file | Rename-Normalize
        clip2file　function.ps1       => clip2file_function.ps1
        clip2img　ｱｲｳｴｵ　function.ps1 => clip2img_アイウエオ_function.ps1
        clipwatch   -    function.ps1 => clipwatch-function.ps1
        ｃｌｉｐ２ｉｍｇ.ps1          => clip2img.ps1

.LINK
    clip2file, han, zen, Rename-Item

#>
function Rename-Normalize {

    param (
        [parameter( Mandatory=$False )]
        [Alias('e')]
        [switch] $Execute,
        
        [parameter( Mandatory=$False )]
        [Alias('a')]
        [switch] $AddDate,
        
        [parameter( Mandatory=$False )]
        [Alias('f')]
        [string] $DateFormat = 'yyyy-MM-dd',
        
        [parameter( Mandatory=$False )]
        [Alias('d')]
        [string] $Delimiter = '-',
        
        [parameter( Mandatory=$False, ValueFromPipeline=$True )]
        [object[]] $InputFiles
    )

    ## is command exist?
    function isCommandExist ([string]$cmd) {
        try { Get-Command $cmd -ErrorAction Stop > $Null
            return $True
        } catch {
            return $False
        }
    }
    if ( -not (isCommandExist "han" ) ){
        Write-Error "could not found ""han"" command." -ErrorAction Stop
    }
    if ( -not (isCommandExist "zen" ) ){
        Write-Error "could not found ""zen"" command." -ErrorAction Stop
    }
    ## test input
    if ( $input.Count -lt 1 ){
        Write-Error "file-objects not found from stdin." -ErrorAction Stop
        return
    }
    [object[]] $fObj = $input
    [int] $maxCharLength = $fObj `
        | ForEach-Object {
            [System.Text.Encoding]::GetEncoding("Shift_Jis").GetByteCount($_.Name)
        } `
        | Sort-Object -Descending `
        | Select-Object -First 1
    
    foreach ( $f in $fObj ){
        [string] $oldName = $f.Name
        [string] $newName = $f.Name | han | zen -k
        [string] $newName = $newName.Replace('  ', ' ')
        [string] $newName = $newName.Replace('  ', ' ')
        [string] $newName = $newName.Replace(' ', '_')
        [string] $newName = $newName.Replace('_-_', '-')
        if ( $AddDate ){
            ### add ymd-prefix
            if ( $newName -notmatch '^[0-9]{4}\-[0-9]{2}\-[0-9]{2}' ){
                ### exclude if name beginning with 'yyyy-MM-dd'
                [string] $ymd = (Get-Date).ToString($DateFormat)
                $newName = $ymd + $Delimiter + $newName
            }
        }
        ### display item
        [int] $curCharLength = [System.Text.Encoding]::GetEncoding("Shift_Jis").GetByteCount($oldName)
        [int] $padding = $maxCharLength - $curCharLength
        Write-Host -NoNewline -Message $oldName -ForegroundColor "White"
        Write-Host -NoNewline -Message "$(" {0}=> " -f ( " " * $padding ))"
        Write-Host -Message $newName -ForegroundColor "Cyan"
        if ( $oldName -ne $newName ){
            if ( $Execute ){
                ### execute rename-item
                $f | Rename-Item -NewName { $newName }
            }
        }
    }
}
