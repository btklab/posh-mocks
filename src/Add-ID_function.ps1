<#
.SYNOPSIS
    Add-ID - Add unique key property

    Give each row a formatted id.

    By default, sequential integer numbers are assigned.
    The default id property name is "id".
    If there are duplicates, it will be "id<n>".

.EXAMPLE
    # input data
    ls -File | select Name, Length
    
        Name  Length
        ----  ------
        a.txt      0
        b.txt      0
        c.txt      0
    
    # assign ids to each row
    ls -File | select Name, Length | Add-ID
    
        id Name  Length
        -- ----  ------
         1 a.txt      0
         2 b.txt      0
         3 c.txt      0

.EXAMPLE
    # assign formatted ids to each row
    ls -File | select Name, Length | Add-ID -Format 'key_000'
    
        id      Name  Length
        --      ----  ------
        key_001 a.txt      0
        key_002 b.txt      0
        key_003 c.txt      0

.EXAMPLE
    # assign formatted ids to each row
    ls -File | select Name, Length | Add-ID -Prefix "key_"
        
        id    Name  Length
        --    ----  ------
        key_1 a.txt      0
        key_2 b.txt      0
        key_3 c.txt      0

#>
function Add-ID
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$False, Position=0)]
        [Alias('n')]
        [String] $Name = 'id'
        ,
        [Parameter(Mandatory=$False)]
        [Alias('p')]
        [String] $Prefix
        ,
        [Parameter(Mandatory=$False)]
        [Alias('f')]
        [String] $Format
        ,
        [Parameter(Mandatory=$False, ValueFromPipeline=$True)]
        [PSObject] $InputObject
    )
    # set Property name counter
    [Int] $NameCounter = 1
    [String] $uniqKeyName = $Name
    # Check for duplicate property names
    [String[]] $PropNames = ($input[0].PSObject.Properties).Name
    while ( $PropNames -contains $uniqKeyName) {
        $NameCounter++
        [String] $uniqKeyName = $Name + [String]$NameCounter
    }
    # Set of unique key name
    Write-Debug "uniq_key_name: $uniqKeyName"
    [Int] $counter = 0
    foreach ( $i in $input ){
        # convert psobject to hash
        $counter++
        if ( $Prefix ) {
            if ( $Format ){
                [String] $keyStr = $Prefix + $($counter.ToString($Format))
            } else {
                [String] $keyStr = $Prefix + [String]$counter
            }
        } else {
            if ( $Format ){
                [String] $keyStr = $($counter.ToString($Format))
            } else {
                [Int] $keyStr = $counter
            }
        }
        $hash = [ordered] @{}
        $hash[$uniqKeyName] = $keyStr
        foreach ($obj in $i.psobject.properties){
            $hash[$obj.Name] = $obj.Value
        }
        # convert hash to psobject
        New-Object psobject -Property $hash
    }
}
