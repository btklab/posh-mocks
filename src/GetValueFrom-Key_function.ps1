<#
.SYNOPSIS
    GetValueFrom-Key (alias: getvalkey) - Get the value only from the key-value text data

    Returns only the values that match the specified key from
    text data stored in space-delimited (space or tab) key-value format.

    Whitespaces before and after keys and values are trimmed and
    ignored.

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
    # output with key (using -Get option)
    cat keyval-dict.txt | getvalkey hog -Get 0,1

        hog val hoge

#>
function GetValueFrom-Key {
    Param(
        [Parameter(Mandatory=$False,Position=0, HelpMessage="Specify key using regex.")]
        [alias('k')]
        [string[]] $Key = ".",
        
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
        
        [Parameter(Mandatory=$False, HelpMessage="Case sensitive")]
        [switch] $CaseSensitive,
        
        [Parameter(Mandatory=$False, HelpMessage="Recursively search files.")]
        [alias('r')]
        [switch] $Recurse,
        
        [Parameter(Mandatory=$False, HelpMessage="Skip empty value")]
        [switch] $SkipEmpty,
        
        [Parameter(Mandatory=$False, HelpMessage="Skip comment")]
        [switch] $SkipComment,
        
        [Parameter(Mandatory=$False, HelpMessage="Comment symbol")]
        [string] $CommentString = '#',
        
        [Parameter(Mandatory=$False, HelpMessage="Yaml delimiter")]
        [switch] $Yaml,
        
        [Parameter(Mandatory=$False, HelpMessage="Toml delimiter")]
        [switch] $Toml,
        
        [parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [string[]] $Text
    )
    # test params
    if ((-not $Key) -and (-not $File)){
        Write-Error "do not set regex pattern or pattern-files." -ErrorAction Stop
    }
    # private function
    function parse_text_from_pipeline {
        param (
            [parameter(Mandatory=$False,ValueFromPipeline=$True)]
            [String[]] $objText
        )
        begin {
            if ( $Yaml ){
                [string] $splitDelimiter = ':'
            } elseif ( $Toml ){
                [string] $splitDelimiter = '='
            } else {
                [string] $splitDelimiter = $Delimiter
            }
            [int] $cnt = 0
            ## regex '^[^ ]+( ).*$'
            [string] $tmpDelim = $splitDelimiter -replace '\+$', ''
            [string] $regGetOutputDelim = '^[^' + $tmpDelim + ']+(' + $tmpDelim + ').*$'
            [string] $regSkipComment = '^\s*' + $CommentString
        }
        process {
            [string] $readLine = $_.Trim()
            ## skip comment
            if ( $SkipComment -and $readLine -match $regSkipComment ){
                return
            }
            [string[]] $splitLine = $readLine -split $splitDelimiter, $Split
            ## skip if there is insufficient number of elements
            if ( $splitLine.Count -lt $Split ){
                return
            }
            $cnt++
            ## Get a delimiter character from the first data
            if ( $cnt -eq 1 ){
                [string] $oDelim = $readLine -replace $regGetOutputDelim, '$1'
            }
            [Bool] $isMatchPattern = $False
            foreach ( $p in $pat ){
                if ( -not $isMatchPattern ){
                    if ( $($splitLine[0]).Trim() -match $p ){
                        [Bool] $isMatchPattern = $True
                        $splitLine[0] = ($splitLine[0]).Trim()
                        [string] $writeLine = ($splitLine[$GetColNums] -join $oDelim).Trim()
                        if ( $SkipEmpty -and $writeLine -eq '' ){
                            #pass
                        } else {
                            Write-Output $writeLine
                            Write-Debug "$splitLine"
                        }
                    }
                }
            }
        }
    }
    # set params
    [int[]] $GetColNums = $Get
    [string[]] $pat = @()
    if ($File){
        # read pattern from files
        Get-Content -Path $File -Encoding UTF8 | ForEach-Object {
            $pat += $_
        }
    } else {
        # read pattern from -Key <regex>,<regex>,...
        if ( -not $Key ){
            Write-Warning "Please specify -Key <regex>." -ErrorAction Stop
        }
        foreach ( $k in $Key ){
            $pat += $k
        }
    }
    $splatting = @{
        Pattern       = '^$'
        CaseSensitive = $CaseSensitive
        Encoding      = "utf8"
        NotMatch      = $True
    }
    if ($PSVersionTable.PSVersion.Major -ge 7){
        # -NoEmphasis parameter was introduced in PowerShell 7
        $splatting.Set_Item('NoEmphasis', $True)
    }
    if ($Path){
        $splatting.Set_Item('Path', (Get-ChildItem -Path $Path -Recurse:$Recurse))
    }
    # main
    if ($Path){
        (Select-String @splatting).Line `
            | parse_text_from_pipeline
    } else {
        ($input | Select-String @splatting).Line `
            | parse_text_from_pipeline
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
