<#
.SYNOPSIS
    Edit-Property - Edit values in a specific column

    Edit values in a specific column while preserving other columns.

.EXAMPLE
    # edit date format
    cat data.txt

    date version
    2020-02-26 v2.2.4
    2020-02-26 v3.0.3
    2019-11-10 v3.0.2
    2019-11-10 v3.0.1
    2019-09-18 v3.0.0
    2019-08-10 v2.2.3

    cat data.txt `
        | ConvertFrom-Csv -Delimiter " " `
        | Edit-Property -p date -e {(Get-Date $_.date).ToString('yyyy/MM/dd (ddd)') }

    date             version
    ----             -------
    2020/02/26 (Wed) v2.2.4
    2020/02/26 (Wed) v3.0.3
    2019/11/10 (Sun) v3.0.2
    2019/11/10 (Sun) v3.0.1
    2019/09/18 (Wed) v3.0.0

.EXAMPLE
    # create a new property from an exiting property
    cat data.txt `
        | ConvertFrom-Csv -Delimiter " " `
        | Edit-Property -p date2 -e {(Get-Date $_.date ).ToString('yy/M/d') }

     date       version date2
     ----       ------- -----
     2020-02-26 v2.2.4  20/2/26
     2020-02-26 v3.0.3  20/2/26
     2019-11-10 v3.0.2  19/11/10
     2019-11-10 v3.0.1  19/11/10
     2019-09-18 v3.0.0  19/9/18

#>
function Edit-Property
{
    [CmdletBinding()]
    Param(        
        [Parameter(Mandatory=$True, Position=0)]
        [Alias('p')]
        [Alias('n')]
        [String[]] $Property
        ,
        [Parameter(Mandatory=$True, Position=1)]
        [Alias('e')]
        [Scriptblock] $Expression
        ,
        [Parameter(Mandatory=$False, ValueFromPipeline=$True)]
        [PSObject] $InputObject
    )
    # set variables
    [bool] $isPropertyExist = $False
    # get all property names
    [String[]] $OldPropertyNames = ($input[0].PSObject.Properties).Name
    [String[]] $ReplaceComAry = @()
    $OldPropertyNames | ForEach-Object {
        [string] $oldName = $_
        if ( $Property.Contains($oldName) ){
            $ReplaceComAry += "@{N=""$oldName""; E={ $($Expression.ToString()) }}"
            [bool] $isPropertyExist = $True
        } else {
            $ReplaceComAry += "@{N=""$oldName""; E={ `$_.""$($oldName)""}}"
        }
    }
    if ( -not $isPropertyExist ){
        # add new property
        $ReplaceComAry += "@{N=""$($Property[0])""; E={ $($Expression.ToString()) }}"
    }
    # invoke command strings
    $hashAry = $ReplaceComAry | ForEach-Object {
        Write-Debug $_
        Invoke-Expression -Command $_
    }
    $input | Select-Object -Property $hashAry
}
# set alias
[String] $tmpAliasName = "editprop"
[String] $tmpCmdName   = "Edit-Property"
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

