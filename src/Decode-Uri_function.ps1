<#
.SYNOPSIS
    Decode-Uri - Decode utf-8 encoded uri.

    Decode utf-8 encoded uri.
    Lines that do not contain a uri encoded string are
    output as-is by default.
    The -Force option will re-decode URI-decoded lines.

.EXAMPLE
    echo "./%E6%8E%B2%E7%A4%BA%E6%9D%BF/start.txt" | Decode-Uri -Debug

.Link
    Encode-Uri (encuri), Decode-Uri (decuri)

.NOTES
    Uri.EscapeUriString(String) Method (System)
    https://learn.microsoft.com/en-us/dotnet/api/system.uri.escapeuristring

    Uri.UnescapeDataString Method (System)
    https://learn.microsoft.com/en-us/dotnet/api/system.uri.unescapedatastring
#>
function Decode-Uri {
    [CmdletBinding()]
    param (
        [Parameter( Mandatory=$False )]
        [Alias('o')]
        [switch] $AsObject
        ,
        [Parameter( Mandatory=$False )]
        [Alias('a')]
        [switch] $AsArray
        ,
        [Parameter( Mandatory=$False )]
        [Alias('t')]
        [switch] $AsText
        ,
        [Parameter( Mandatory=$False )]
        [Alias('f')]
        [switch] $Force
        ,
        [parameter( Mandatory=$False, ValueFromPipeline=$True )]
        [object[]] $InputText
    )
    begin {
        if ( $PSVersionTable.PSVersion.Major -le 5){
            Add-Type -AssemblyName System.Web
        }
    }
    process {
        [string] $encodedUri = $_
        [string] $status = ''
        ## skip if not encoded
        if ( -not $Force -and $encodedUri -cnotmatch '^.*%[0-9a-zA-Z][0-9a-zA-Z]+' ){
            ## output as-is
            [string] $decodedUri = $encodedUri
            Write-Debug "skipped: $encodedUri"
            [string] $status = 'skipped'
        } else {
            if ( $PSVersionTable.PSVersion.Major -le 5){
                ## PowerShell 5-
                [string] $decodedUri = [System.Web.HttpUtility]::UrlDecode($encodedUri, [Text.Encoding]::GetEncoding("utf-8"))
                Write-Debug "decoded by pwsh5: $encodedUri"
            } else {
                ## PowerShell 6+
                [string] $decodedUri = [uri]::UnEscapeDataString($encodedUri)
                Write-Debug "decoded by pwsh6+: $encodedUri"
            }
            [string] $status = 'decoded'
        }
        if ( $AsObject ){
            [PSCustomObject]@{
                DecodeFrom = $encodedUri
                DecodeTo = $decodedUri
                Status = $status
            }
        } elseif ( $AsArray ){
            @($encodedUri, $decodedUri)
        } else {
            Write-Output $decodedUri
        }
    }
}
# set alias
[String] $tmpAliasName = "decuri"
[String] $tmpCmdName   = "Decode-Uri"
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

