<#
.SYNOPSIS
    Test-isAsciiLine (Alias: isAsciiLine) - Test if a line of text contains only ASCII characters

.EXAMPLE
    "a".."d" | isAsciiLine
    
    isAscii Line
    ------- ----
       True    a
       True    b
       True    c
       True    d

.EXAMPLE
    "a".."d" | isAsciiLine -AsPlainText
    T a
    T b
    T c
    T d

#>
function Test-isAsciiLine {

    [CmdletBinding()]
    param (
        [parameter( Mandatory=$False )]
        [Switch] $AsPlainText,
        
        [parameter( Mandatory=$False, ValueFromPipeline=$True )]
        [Object[]] $InputText
    )
    $regASCII = "^[\x00-\x7F]*$"
    foreach ( $line in @($input) ){
        if ( $line -cmatch $regASCII ){
            if ( $AsPlainText ){
                # output as text
                "T $line"
            } else {
                # output as object
                [pscustomobject] @{
                    isAscii = $True
                    Line = $line
                }
            }
        } else {
            if ( $AsPlainText ){
                # output as text
                "F $line"
            } else {
                # output as object
                [pscustomobject] @{
                    isAscii = $False
                    Line = $line
                }
            }
        }
    }
}
# set alias
[String] $tmpAliasName = "isAsciiLine"
[String] $tmpCmdName   = "Test-isAsciiLine"
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
