<#
.SYNOPSIS
    GetValueFrom-Key (alias: getvalkey) - Get the value only from the key-value text data

    Returns only the values that match the specified key from
    text data stored in space-delimited (space or tab) key-value format.

    cat file | GetValueFrom-Key [[-k|-Key] <Regex[]>]
     or 
    GetValueFrom-Key [[-k|-Key] <Regex[]>] [[-p|-Path] <String[]>]
        [-d|-Delimiter <String>]
        [-f|-File]
        [-v|-NotMatch]
        [-s|-SimpleMatch]
        [-CaseSensitive]
        [-r|-Recurse]
        [-Split <n>]
        [-Get <n>]

    cat keyval-dict.txt

        key value
        hog val hoge
        fug val fuga

    cat keyval-dict.txt | getvalkey hog

        val hoge

    cat keyval-dict.txt | getvalkey .

        value
        val hoge
        val fuga

.LINK
    about_Split - Microsoft Learn
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_split

.EXAMPLE
    cat keyval-dict.txt

        key value
        hog val hoge
        fug val fuga

    # output values that match "hog"
    PS> cat keyval-dict.txt | getvalkey hog

        val hoge
    
    # output all values
    cat keyval-dict.txt | getvalkey .

        value
        val hoge
        val fuga

.EXAMPLE
    # output with key (using -Get option
    cat keyval-dict.txt | getvalkey hog -Get 0,1

        hog val hoge

#>
function GetValueFrom-Key {
    Param(
        [Parameter(Mandatory=$False,Position=0, HelpMessage="Specify key using regex.")]
        [alias('k')]
        [string[]] $Key,
        
        [Parameter(Mandatory=$False,Position=1, HelpMessage="Specify file path to search.")]
        [alias('p')]
        [string[]] $Path,
        
        [Parameter(Mandatory=$False, HelpMessage="Specify key-value delimiter.")]
        [alias('d')]
        [string] $Delimiter = "\s+",
        
        [Parameter(Mandatory=$False, HelpMessage="Specify key-value delimiter.")]
        [alias('dfs')]
        [string] $OutputDelimiter,
        
        [Parameter(Mandatory=$False, HelpMessage="Specifies the maximum number of substrings returned by the split operation.")]
        [int] $Split = 2,
        
        [Parameter(Mandatory=$False, HelpMessage="Specifies the number of column want to extract.")]
        [int[]] $Get = @(1),
        
        [Parameter(Mandatory=$False, HelpMessage="Specify an external file containing the search strings")]
        [alias('f')]
        [string] $File,
        
        [Parameter(Mandatory=$False, HelpMessage="Invert search results")]
        [alias('v')]
        [switch] $NotMatch,
        
        [Parameter(Mandatory=$False, HelpMessage="Search without regex.")]
        [alias('s')]
        [switch] $SimpleMatch,
        
        [Parameter(Mandatory=$False, HelpMessage="Case sensitive")]
        [switch] $CaseSensitive,
        
        [Parameter(Mandatory=$False, HelpMessage="Recursively search files.")]
        [alias('r')]
        [switch] $Recurse,
        
        [parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [string[]] $Text
    )
    # test params
    if ((-not $Key) -and (-not $File)){
        Write-Error "do not set regex pattern or pattern-files." -ErrorAction Stop
    }
    # set params
    [int[]] $GetColNums = $Get
    [string[]] $Pattern = @()
    foreach ( $k in $Key ){
        [string] $regex += $Key
        $Pattern += $regex
        Write-Debug "regex: $regex"
    }
    [string[]] $pat = @()
    if ($File){
        # read patterns from files
        $pat = Get-Content -Path $File -Encoding UTF8
    } else {
        foreach ( $p in $Pattern ){
            $pat += $Pattern
        }
    }
    $splatting = @{
        Pattern       = $pat
        CaseSensitive = $CaseSensitive
        Encoding      = "utf8"
        SimpleMatch   = $SimpleMatch
        NotMatch      = $NotMatch
        AllMatches    = $AllMatches
    }
    if ($PSVersionTable.PSVersion.Major -ge 7){
        # -NoEmphasis parameter was introduced in PowerShell 7
        $splatting.Set_Item('NoEmphasis', $True)
    }
    if ($Path){
        $splatting.Set_Item('Path', (Get-ChildItem -Path $Path -Recurse:$Recurse))
    }
    # main
    [int] $cnt = 0
    ## regex '^[^ ]+( ).*$'
    [string] $tmpDelim = $Delimiter -replace '\+$', ''
    [string] $regGetOutputDelim = '^[^' + $tmpDelim + ']+(' + $tmpDelim + ').*$'
    if ($Path){
        (Select-String @splatting).Line | ForEach-Object {
            $cnt++
            if ( $cnt -eq 1 ){
                [string] $oDelim = $_ -replace $regGetOutputDelim, '$1'
            }
            [string[]] $splitLine = $_ -split $Delimiter, $Split
            foreach ( $p in $pat ){
                if ( $splitLine[0] -match $p ){
                    Write-Output $($splitLine[$GetColNums] -join $oDelim)
                    Write-Debug "$splitLine"
                }
            }
        }
        return
    }
    ($input | Select-String @splatting).Line | ForEach-Object {
        $cnt++
        if ( $cnt -eq 1 ){
            [string] $oDelim = $_ -replace $regGetOutputDelim, '$1'
        }
        [string[]] $splitLine = $_ -split $Delimiter, $Split
        foreach ( $p in $pat ){
            if ( $splitLine[0] -match $p ){
                Write-Output $($splitLine[$GetColNums] -join $oDelim)
                Write-Debug "$splitLine"
            }
        }
    }
    return
}
# set alias
[String] $tmpAliasName = "getvalkey"
[String] $tmpCmdName   = "GetValueFrom-Key"
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
