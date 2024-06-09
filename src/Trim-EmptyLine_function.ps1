<#
.SYNOPSIS
    Trim-EmptyLine (alias: etrim) - Remove empty lines from the beginning and end of line.

.EXAMPLE
    [string[]] $dat = @("",""),@("a".."c"),@("",""),@("d".."f"),@("","") | % { $_ }
    $dat
     
     (output)
         <- Empty line
         <- Empty line
        a
        b
        c
         <- Empty line
         <- Empty line
        d
        e
        f
         <- Empty line
         <- Empty line


    $dat | Trim-EmptyLine
     
     (output: Remove empty lines from the beginning and end of line)
        a
        b
        c
         <- Empty line
         <- Empty line
        d
        e
        f


.LINK
    Add-LineBreakEndOfFile

.NOTES
    Trim Your Strings with PowerShell
    https://devblogs.microsoft.com/scripting/trim-your-strings-with-powershell/

#>
function Trim-EmptyLine {
    Param(
        [Parameter(Mandatory=$False, Position=0, HelpMessage="Specify file path to trim empty line.")]
        [Alias('f')]
        [String] $File,
        
        [Parameter(Mandatory=$False, HelpMessage="Specify empty line regex.")]
        [Alias('c')]
        [String] $Character = '',
        
        [Parameter(Mandatory=$False, HelpMessage=".TrimStart()")]
        [Switch] $TrimStart,
        
        [Parameter(Mandatory=$False, HelpMessage=".TrimEnd()")]
        [Switch] $TrimEnd,
        
        [Parameter(Mandatory=$False, HelpMessage=".Trim()")]
        [Switch] $TrimBoth,
        
        [parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [String[]] $Text
    )
    # parse opt
    [String] $charEmptyLine = '^' + $Character + '$'
    # private function
    function ReverseLine {
        Param(
            [parameter(Mandatory=$False,ValueFromPipeline=$True)]
            [String[]] $ReadLineAry
        )
        $input[-1..(-($input.Count))]
    }
    function TrimEmptyInHeader {
        Param(
            [parameter(Mandatory=$True, Position=0)]
            [String] $regTrimTarget,
            [parameter(Mandatory=$False,ValueFromPipeline=$True)]
            [String[]] $ReadLineAry
        )
        begin {
            [bool] $isHeader = $True
        }
        process {
            [string] $readLine = $_
            if ( $isHeader -and $readLine -match $regTrimTarget) {
                return
            }
            if ( $isHeader -and $readLine -notmatch $regTrimTarget) {
                $isHeader = $False
            }
            Write-Output $readLine
        }
    }
    # main
    if ($File){
        $splatting = @{
            LiteralPath = $File
            Encoding    = "utf8"
        }
        if ( $TrimStart -and $TrimEnd ){
            Get-Content @splatting `
                | ReverseLine `
                | TrimEmptyInHeader $charEmptyLine `
                | ReverseLine `
                | TrimEmptyInHeader $charEmptyLine
        } elseif ( $TrimBoth ){
            Get-Content @splatting `
                | ReverseLine `
                | TrimEmptyInHeader $charEmptyLine `
                | ReverseLine `
                | TrimEmptyInHeader $charEmptyLine
        } elseif ( $TrimStart ){
            Get-Content @splatting `
                | TrimEmptyInHeader $charEmptyLine
        } elseif ( $TrimEnd ){
            Get-Content @splatting `
                | ReverseLine `
                | TrimEmptyInHeader $charEmptyLine `
        } else {
            Get-Content @splatting `
                | ReverseLine `
                | TrimEmptyInHeader $charEmptyLine `
                | ReverseLine `
                | TrimEmptyInHeader $charEmptyLine
        }
        return
    }
    if ( $True ) {
        if ( $TrimStart -and $TrimEnd ){
            $input `
                | ReverseLine `
                | TrimEmptyInHeader $charEmptyLine `
                | ReverseLine `
                | TrimEmptyInHeader $charEmptyLine
        } elseif ( $TrimBoth ){
            $input `
                | ReverseLine `
                | TrimEmptyInHeader $charEmptyLine `
                | ReverseLine `
                | TrimEmptyInHeader $charEmptyLine
        } elseif ( $TrimStart ){
            $input `
                | TrimEmptyInHeader $charEmptyLine
        } elseif ( $TrimEnd ){
            $input `
                | ReverseLine `
                | TrimEmptyInHeader $charEmptyLine `
                | ReverseLine
        } else {
            $input `
                | ReverseLine `
                | TrimEmptyInHeader $charEmptyLine `
                | ReverseLine `
                | TrimEmptyInHeader $charEmptyLine
        }
    }
    return
}
# set alias
[String] $tmpAliasName = "etrim"
[String] $tmpCmdName   = "Trim-EmptyLine"
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
