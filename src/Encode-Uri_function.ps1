<#
.SYNOPSIS
    Encode-Uri - Encode utf-8 decoded uri.

    Encode utf-8 decoded uri.
    URI-encoded lines are output as-is by default.
    The -Force option will re-encode URI-encoded lines.

.EXAMPLE
    echo "./%E6%8E%B2%E7%A4%BA%E6%9D%BF/start.txt" | Encode-Uri -Debug

.Link
    Encode-Uri (encuri), Decode-Uri (decuri)

.NOTES
    Uri.EscapeUriString(String) Method (System)
    https://learn.microsoft.com/en-us/dotnet/api/system.uri.escapeuristring

    Uri.UnescapeDataString Method (System)
    https://learn.microsoft.com/en-us/dotnet/api/system.uri.unescapedatastring
#>
function Encode-Uri {

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
        [string] $decodedUri = $_
        [string] $status = ''
        ## skip if not encoded
        if ( -not $Force -and $decodedUri -cmatch '^.*%[0-9a-zA-Z][0-9a-zA-Z]+' ){
            ## output as-is
            [string] $encodedUri = $decodedUri
            Write-Debug "skipped: $decodedUri"
            [string] $status = 'skipped'
        } else {
            if ( $PSVersionTable.PSVersion.Major -le 5){
                ## PowerShell 5-
                [string] $encodedUri = [System.Web.HttpUtility]::urlencode($decodedUri, [Text.Encoding]::GetEncoding("utf-8"))
                Write-Debug "encoded by pwsh5: $decodedUri"
            } else {
                ## PowerShell 6+
                [string] $encodedUri = [uri]::EscapeUriString($decodedUri)
                Write-Debug "encoded by pwsh6+: $decodedUri"
            }
            [string] $status = 'encoded'
        }
        if ( $AsObject ){
            [PSCustomObject]@{
                EncodeFrom = $decodedUri
                EncodeTo = $encodedUri
                Status = $status
            }
        } elseif ( $AsArray ){
            @($decodedUri, $encodedUri)
        } else {
            Write-Output $encodedUri
        }
    }
}
# set alias
[String] $tmpAliasName = "encuri"
[String] $tmpCmdName   = "Encode-Uri"
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

