<#
.SYNOPSIS
    Apply-Function - Apply function for each category

    Apply a script for each category in the specified column.

        Apply-Function key,key,... [{ script | script}]

    Input must be pre stable-sorted by category(key) fields
    (Sort-Object <key>,<key>,... -Stable)

        # Exapmle: Get the minimum Id per processName

         ps `
            | Select-Object -First 40 `
            | Sort-Object ProcessName, Id -Stable `
            | Apply-Function ProcessName { select -First 1 } `
            | ft

    Multiple category properties can be specified.

        Example of specifying multiple category properties:

        Import-Csv penguins.csv `
            | sort species, island -Stable `
            | Shorten-PropertyName `
            | Apply-Function -key species,island {select -First 1} `
            | ft

.LINK
    Shorten-PropertyName, Drop-NA, Replace-NA, Apply-Function, GroupBy-Object, Add-Stats, Detect-XrsAnomaly, Plot-BarChart, Get-First, Get-Last, Select-Field, Delete-Field

.EXAMPLE
    # Get the first 1 records for each category(species, island)

    Import-Csv penguins.csv `
        | sort species, island -Stable `
        | Shorten-PropertyName `
        | Drop-NA species, island `
        | Apply-Function -key species,island {select -First 1} `
        | ft

    count species   island    b_l_m b_d_m f_l_m b_m_g sex    year key
    ----- -------   ------    ----- ----- ----- ----- ---    ---- ---
    21    Adelie    Biscoe    37.8  18.3  174   3400  female 2007 Adelie, Biscoe
    31    Adelie    Dream     39.5  16.7  178   3250  female 2007 Adelie, Dream
    1     Adelie    Torgersen 39.1  18.7  181   3750  male   2007 Adelie, Torgersen
    277   Chinstrap Dream     46.5  17.9  192   3500  female 2007 Chinstrap, Dream
    153   Gentoo    Biscoe    46.1  13.2  211   4500  female 2007 Gentoo, Biscoe

.EXAMPLE
    # Detect anomaly values by category(species)

    Import-Csv penguins.csv `
        | sort species -Stable `
        | Shorten-PropertyName `
        | Drop-NA b_l_m `
        | Apply-Function species {
            Detect-XrsAnomaly b_l_m -OnlyDeviationRecord } `
        | ft

    count species island b_l_m b_d_m f_l_m b_m_g sex  year xrs
    ----- ------- ------ ----- ----- ----- ----- ---  ---- ---
    186   Gentoo  Biscoe 59.6  17    230   6050  male 2007   3

    # Visualization by  plotting bar chart
    # on the console using Plot-BarChart function

    Import-Csv penguins.csv `
        | sort species, island -Stable `
        | Shorten-PropertyName `
        | Drop-NA b_l_m `
        | Apply-Function species, island {
            Add-Stats b_l_m -sum -mean `
            | Detect-XrsAnomaly b_l_m `
            | Get-Random -Count 3 } `
        | Plot-BarChart b_l_m count,key,xrs -w 20 -m "|" `
        | ft

    count key               xrs b_l_m BarChart
    ----- ---               --- ----- --------
    23    Adelie, Biscoe      0 35.9  ||||||||||||
    25    Adelie, Biscoe      0 38.8  |||||||||||||
    105   Adelie, Biscoe      0 37.9  |||||||||||||
    135   Adelie, Dream       0 38.1  |||||||||||||
    42    Adelie, Dream       0 40.8  ||||||||||||||
    140   Adelie, Dream       0 39.7  ||||||||||||||
    75    Adelie, Torgersen   0 35.5  ||||||||||||
    15    Adelie, Torgersen   0 34.6  ||||||||||||
    79    Adelie, Torgersen   0 36.2  ||||||||||||
    304   Chinstrap, Dream    0 49.5  |||||||||||||||||
    280   Chinstrap, Dream    0 45.4  ||||||||||||||||
    306   Chinstrap, Dream    0 52.8  ||||||||||||||||||
    254   Gentoo, Biscoe      0 55.9  ||||||||||||||||||||
    262   Gentoo, Biscoe      0 48.1  |||||||||||||||||
    203   Gentoo, Biscoe      0 46.6  ||||||||||||||||

.EXAMPLE
    # Example of specifying multiple category properties:    
    Import-Csv penguins.csv `
        | sort species, island -Stable `
        | Apply-Function species,island { select -First 3 } `
        | ft count, species, island, bill_length_mm

     count species   island    bill_length_mm
     ----- -------   ------    --------------
        21 Adelie    Biscoe             37.80
        22 Adelie    Biscoe             37.70
        23 Adelie    Biscoe             35.90
        31 Adelie    Dream              39.50
        32 Adelie    Dream              37.20
        33 Adelie    Dream              39.50
         1 Adelie    Torgersen          39.10
         2 Adelie    Torgersen          39.50
         3 Adelie    Torgersen          40.30
       277 Chinstrap Dream              46.50
       278 Chinstrap Dream              50.00
       279 Chinstrap Dream              51.30
       153 Gentoo    Biscoe             46.10
       154 Gentoo    Biscoe             50.00
       155 Gentoo    Biscoe             48.70

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
function Apply-Function
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
    [bool] $isFirstItem = $True
    [string] $oldVal = $Null
    [string] $newVal = $Null
    [string] $KeyPropertyName = "key"
    foreach ( $obj in @( $input | Select-Object * ) ){
        [string[]] $propKeyAry = @()
        foreach ($k in $Key){
            $propKeyAry += ,@([string]($obj.$k))
        }
        [string] $propKeyStr = $propKeyAry -join ", "
        [string] $newVal = $propKeyStr
        # convert psobject to hash
        $hash = [ordered] @{}
        foreach ($item in $obj.psobject.properties){
            $hash[$item.Name] = $item.Value
        }
        if ( $isFirstItem ){
            $isFirstItem = $False
            $groupAry = New-Object System.Collections.ArrayList
            if ( -not $ExcludeKey ){
                # if multiple keys are specified, Add key property
                $hash["$KeyPropertyName"] = $propKeyStr
            }
            # convert hash to psobject
            $groupAry.Add($(New-Object psobject -Property $hash)) > $Null
        } else {
            if ( $newVal -eq $oldVal){
                if ( -not $ExcludeKey ){
                    # if multiple keys are specified, Add key property
                    $hash["$KeyPropertyName"] = $propKeyStr
                }
                # convert hash to psobject
                $groupAry.Add($(New-Object psobject -Property $hash)) > $Null
            } else {
                if ( $Function ){
                    [string] $com = '$groupAry' + " | " + $function.ToString().Trim()
                    Write-Debug $com
                    Invoke-Expression -Command $com
                } else {
                    Write-Output $groupAry
                }
                $groupAry = New-Object System.Collections.ArrayList
                if ( -not $ExcludeKey){
                    # if multiple keys are specified, Add key property
                    $hash["$KeyPropertyName"] = $propKeyStr
                }
                # convert hash to psobject
                $groupAry.Add($(New-Object psobject -Property $hash)) > $Null
            }
        }
        [string] $oldVal = $newVal
    }
    if ( $Function ){
        [string] $com = '$groupAry' + " | " + $function.ToString().Trim()
        Write-Debug $com
        Invoke-Expression -Command $com
    } else {
        Write-Output $groupAry
    }
}
# set alias
[String] $tmpAliasName = "apply"
[String] $tmpCmdName   = "Apply-Function"
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
