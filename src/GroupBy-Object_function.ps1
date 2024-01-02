<#
.SYNOPSIS
    GroupBy-Object - Apply function to each group

    For categorical data analysis of time series data.
    Multiple columns can be specified at once.
    No pre-sorting of key column required.

        GroupBy-Object [-k] <col>,<col>,... [{script | script}]
        GroupBy [-k] <col>,<col>,... [{script | script}]

.LINK
    Apply-Function, GroupBy-Object

.EXAMPLE
    # Select first record for each key (key = species and island)
    # (pre-sorted key do not required)
    Import-Csv penguins.csv `
        | Shorten-PropertyName `
        | GroupBy-Object species, island { select -First 1 } `
        | ft species, island, b_l_m, sex, year, key

    species   island    b_l_m sex    year key
    -------   ------    ----- ---    ---- ---
    Adelie    Biscoe    37.8  female 2007 Adelie, Biscoe
    Adelie    Dream     39.5  female 2007 Adelie, Dream
    Adelie    Torgersen 39.1  male   2007 Adelie, Torgersen
    Chinstrap Dream     46.5  female 2007 Chinstrap, Dream
    Gentoo    Biscoe    46.1  female 2007 Gentoo, Biscoe

    # Do the same using only built-in commands
    # (pre-sorted key do not required)
    Import-Csv penguins.csv `
        | Shorten-PropertyName `
        | Group-Object species, island `
        | %{ $n = $_.Name; $_.Group `
            | %{ `
                $_ | Add-Member -NotePropertyName "key" -NotePropertyValue $n; $_ `
            } `
            | select -First 1 `
        } `
        | ft

    count species   island    b_l_m sex    year key
    ----- -------   ------    ----- ---    ---- ---
    21    Adelie    Biscoe    37.8  female 2007 Adelie, Biscoe
    31    Adelie    Dream     39.5  female 2007 Adelie, Dream
    1     Adelie    Torgersen 39.1  male   2007 Adelie, Torgersen
    277   Chinstrap Dream     46.5  female 2007 Chinstrap, Dream
    153   Gentoo    Biscoe    46.1  female 2007 Gentoo, Biscoe

.EXAMPLE
    # Calculate stats of bill_length_mm for each Group (key = species and island)
    # (pre-sorted key do not required)
    Import-Csv penguins.csv `
        | GroupBy-Object species, island { `
            Drop-NA bill_length_mm `
            | Measure-Stats bill_length_mm key -Average -Sum -Count
        } `
        | ft

    key               Count Average     Sum Property
    ---               ----- -------     --- --------
    Adelie, Biscoe       44   38.98 1714.90 bill_length_mm
    Adelie, Dream        56   38.50 2156.10 bill_length_mm
    Adelie, Torgersen    51   38.95 1986.50 bill_length_mm
    Chinstrap, Dream     68   48.83 3320.70 bill_length_mm
    Gentoo, Biscoe      123   47.50 5843.10 bill_length_mm

    # Do the same with Apply-Function (alias: apply)
    # (pre-sorted key required)
    Import-Csv penguins.csv `
        | sort species, island `
        | GroupBy-Object species,island { `
            Drop-NA bill_length_mm `
            | Measure-Stats bill_length_mm key -Average -Sum -Count
        } `
        | ft

#>
function GroupBy-Object
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, Position=0)]
        [Alias('k')]
        [String[]] $Key,
        
        [Parameter(Mandatory=$False, Position=1)]
        [Alias('f')]
        [scriptblock] $Function,
        
        [Parameter(Mandatory=$False)]
        [string] $KeyPropertyName = "key",
        
        [Parameter(Mandatory=$False)]
        [switch] $ExcludeKey,
        
        [Parameter(Mandatory=$False, ValueFromPipeline=$True)]
        [PSObject] $InputObject
    )
    foreach ( $obj in @($input | Group-Object $Key)){
        $groupAry = New-Object System.Collections.ArrayList
        [string] $keyStr = $obj.Name
        foreach ( $g in @($obj.Group) ){
            $hash = [ordered] @{}
            foreach ($item in $g.psobject.properties){
                $hash[$item.Name] = $item.Value
            }
            if ( -not $ExcludeKey ){
                $hash["$KeyPropertyName"] = $keyStr
            }
            # convert hash to psobject
            $groupAry.Add($(New-Object psobject -Property $hash)) > $Null
        }
        if ( $Function ){
            [string] $com = '$groupAry' + " | " + $function.ToString().Trim()
            Write-Debug $com
            Invoke-Expression -Command $com
        } else {
            Write-Output $groupAry
        }
    }
}
# set alias
[String] $tmpAliasName = "groupBy"
[String] $tmpCmdName   = "GroupBy-Object"
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
