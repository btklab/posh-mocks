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

        if the name after renaming is duplicated, show error
        message, skip the renaming process for that file, and
        continue processing other files.


.EXAMPLE
    ## shows what would happen if the command runs.The command is not run.

    ls | Rename-Normalize

        clip2file_ function.ps1       => clip2file_function.ps1
        clip2img -. ps1               => clip2img.ps1
        ｃｌｉｐ２ｉｍｇ　.ps1        => clip2img.ps1
        clip2img_ｱｶｻﾀﾅ_function.ps1   => clip2img_アカサタナ_function.ps1
        clipwatch-function - Copy.ps1 => clipwatch-function-Copy.ps1
        clipwatch-function.ps1        => clipwatch-function.ps1

    ## execute rename if "-Execute" specified.
    ## if the name after renaming is duplicated,
    ## show error message, skip the renaming process
    ## for that file, and continue processing
    ## other files.

    ls | Rename-Normalize -Execute

        clip2file_ function.ps1       => clip2file_function.ps1
        clip2img -. ps1               => clip2img.ps1
        ｃｌｉｐ２ｉｍｇ　.ps1        => clip2img.ps1
        Rename-Item: path\to\the\Rename-Normalize_function.ps1:182
        Line |
         182 |                  $f | Rename-Item -NewName { $newName }
             |                       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
             | Cannot create a file when that file already exists.
        clip2img_ｱｶｻﾀﾅ_function.ps1   => clip2img_アカサタナ_function.ps1
        clipwatch-function - Copy.ps1 => clipwatch-function-Copy.ps1
        clipwatch-function.ps1        => clipwatch-function.ps1


.EXAMPLE
    ## Add date prefix in "yyyy-MM-dd" format

    ls | Rename-Normalize -AddDate

        clip2file_ function.ps1       => 2023-04-06-clip2file_function.ps1
        clip2img -. ps1               => 2023-04-06-clip2img.ps1
        ｃｌｉｐ２ｉｍｇ　.ps1        => 2023-04-06-clip2img.ps1
        clip2img_ｱｶｻﾀﾅ_function.ps1   => 2023-04-06-clip2img_アカサタナ_function.ps1
        clipwatch-function - Copy.ps1 => 2023-04-06-clipwatch-function-Copy.ps1
        clipwatch-function.ps1        => 2023-04-06-clipwatch-function.ps1

.EXAMPLE
    ## combination with clip2file function

    ("copy files to clipboard and..."")

    clip2file | Rename-Normalize

        clip2file_ function.ps1       => clip2file_function.ps1
        clip2img -. ps1               => clip2img.ps1
        ｃｌｉｐ２ｉｍｇ　.ps1        => clip2img.ps1
        clip2img_ｱｶｻﾀﾅ_function.ps1   => clip2img_アカサタナ_function.ps1
        clipwatch-function - Copy.ps1 => clipwatch-function-Copy.ps1
        clipwatch-function.ps1        => clipwatch-function.ps1

.LINK
    clip2file, han, zen, Rename-Item, aclip

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
        
        [parameter( Mandatory=$False )]
        [string] $ReplaceChar = ' ',
        
        [Parameter( Mandatory=$False )]
        [switch] $FromTo,
        
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
    ## test command
    if ( -not (isCommandExist "han" ) ){
        Write-Error "could not found ""han"" command." -ErrorAction Stop
    }
    if ( -not (isCommandExist "zen" ) ){
        Write-Error "could not found ""zen"" command." -ErrorAction Stop
    }
    ## remove / replace filters
    filter remove-whitespaces-around-dot {
        $_ -replace '\s*\.\s*', '.'
    }
    filter replace-characters-to-avoid-in-filename {
        [string] $tmpLine = $_
        $tmpLine = $tmpLine.Replace('\', "$ReplaceChar")
        $tmpLine = $tmpLine.Replace('/', "$ReplaceChar")
        $tmpLine = $tmpLine.Replace(':', "$ReplaceChar")
        $tmpLine = $tmpLine.Replace('*', "$ReplaceChar")
        $tmpLine = $tmpLine.Replace('?', "$ReplaceChar")
        $tmpLine = $tmpLine.Replace('"', "$ReplaceChar")
        $tmpLine = $tmpLine.Replace('<', "$ReplaceChar")
        $tmpLine = $tmpLine.Replace('>', "$ReplaceChar")
        $tmpLine = $tmpLine.Replace('|', "$ReplaceChar")
        Write-Output $tmpLine
    }
    filter remove-whitespaces-around-hyphen {
        $_ -replace '\s*\-\s*', '-'
    }
    filter remove-whitespaces-around-underscore {
        $_ -replace '\s*_\s*', '_'
    }
    filter replace-consecutive-spaces-to-single-space {
        $_ -replace '  *', ' '
    }
    filter replace-whitespace-to-underscore {
        "$_".Replace(' ', '_')
    }
    filter remove-symbols-around-dot{
        $_ -replace '(\-|_)*\.(\-|_)*', '.'
    }
    filter remove-underscore-around-hyphen {
        "$_".Replace('_-_', '-')
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
    ## replace / remove symbols
    foreach ( $f in $fObj ){
        [string] $oldName = $f.Name
        ### replace kana half-width to full-width
        ###   and replace alphanumeric characters full to half-width
        [string] $newName = $f.Name | han | zen -k
        [string] $newName = $newName | replace-characters-to-avoid-in-filename
        [string] $newName = $newName | remove-whitespaces-around-dot
        [string] $newName = $newName | remove-whitespaces-around-hyphen
        [string] $newName = $newName | remove-whitespaces-around-underscore
        [string] $newName = $newName | replace-consecutive-spaces-to-single-space
        [string] $newName = $newName | replace-whitespace-to-underscore
        [string] $newName = $newName | remove-symbols-around-dot
        #[string] $newName = $newName | remove-underscore-around-hyphen
        if ( $AddDate ){
            ### add ymd-prefix
            if ( $newName -notmatch '^[0-9]{4}\-[0-9]{2}\-[0-9]{2}' ){
                ### exclude if name beginning with 'yyyy-MM-dd'
                [string] $ymd = (Get-Date).ToString($DateFormat)
                $newName = $ymd + $Delimiter + $newName
            }
        }
        ### display item
        if ( $FromTo -or -not $Execute ){
            [int] $curCharLength = [System.Text.Encoding]::GetEncoding("Shift_Jis").GetByteCount($oldName)
            [int] $padding = $maxCharLength - $curCharLength
            Write-Host -NoNewline $oldName -ForegroundColor "White"
            Write-Host -NoNewline "$(" {0}=> " -f ( " " * $padding ))"
            Write-Host $newName -ForegroundColor "Cyan"
        }
        if ( $oldName -ne $newName ){
            if ( $Execute ){
                ### execute rename-item
                $f | Rename-Item -NewName { $newName } -ErrorAction Continue -PassThru
            }
        }
    }
}
# set alias
[String] $tmpAliasName = "ren2norm"
[String] $tmpCmdName   = "Rename-Normalize"
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
