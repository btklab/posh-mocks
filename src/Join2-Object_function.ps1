<#
.SYNOPSIS
    Join2-Object (Alias: join2o) - INNER/OUTER Join records

    INNER/OUTER Join records. If key not match,
    the record will be replaced with dummy data.
    Using System.Array.IndexOf() method (case sensitive)

    Receive a transaction object via the pipeline,
    combine it with the master object using common
    key(s), and return it. Transaction accept only
    objects, but master data can be either csv-file
    or objects.

        Import-Csv tran.csv | Join2-Object master.csv -On Id
        Import-Csv tran.csv | Join2-Object (Import-Csv master.csv) -On Id

    Automatically detect duplicate keys in master data
    and stop processing.

    No need to pre-sort keys for master data and transaction
    data. You can also use pre-sorted Master data and specify
    the -PreSortedMaster switch to speed up processing. Note
    that using un-pre-sorted master data with -PreSortedMaster
    switch will work, but the master key check for duplicate
    will not work.

        Join2-Object
            [-m|-Master] <Object[]>
            [-t|-Tran] <Object[]>
            [-On|-MasterKey] <String[]>
            [-tkey|-TransKey <String[]>]
            [-Where <ScriptBlock>]
            [-s|-AddSuffixToMasterProperty <String>]
            [-p|-AddPrefixToMasterProperty <String>]
            [-d|-Delimiter <String>]
            [-mh|-MasterHeader <String[]>]
            [-th|-TranHeader <String[]>]
            [-Dummy <String>]
            [-OnlyIfInBoth]
            [-OnlyIfInTransaction]
            [-PreSortedMasterKey]
            [-SortTranKey]
            [-IncludeMasterKey]

.Parameter Master
    Specify MasterSata file or object

.Parameter MasterKey
    Specify Common Key

.Parameter TransKey
    Specify Transaction Key when the join key name is
    different between transaction and master

.Parameter Where
    Specify the filter for records to be retrieved
    using a script block.

.Parameter AddSuffixToMasterProperty
    Rename master data property name. Used when the
    property name overlaps with transaction data.
    "m_" is set by default.

.Parameter AddPrefixToMasterProperty
    Rename master data property name. Used when the
    property name overlaps with transaction data.
    None is set by default.

.Parameter Delimiter
    Master/Trans file delimiter when specifying master data
    as a file. Comma separated by defalut.

.Parameter MasterHeader
    Master file header array when specifying headerless
    master data as a file.

.Parameter TranHeader
    Transaction file header array when specifying headerless
    transaction data as a file.

.Parameter Dummy
    Alternative string if a transaction key that is not
    in the master data. $Null by default.

.Parameter OnlyIfInBoth
    Output only data that exists in both
    master and transaction.

.Parameter OnlyIfInTransaction
    Output only data that exists in transaction.

.Parameter PreSortedMasterKey
    If you specify this when inputting pre-sorted master
    data, you can skip the sorting process and shorten
    processing time.

    No need to pre-sort keys for master and transaction
    data. Note that using un-presorted master data with
    -PreSortedMaster switch will work, but the master key
    check for duplicate will not work.

.Parameter IncludeMasterKey
    Include master data key properties in the output.
    Not included by default.

.NOTES
    Everything you wanted to know about arrays
    en https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-arrays
    ja https://learn.microsoft.com/ja-jp/powershell/scripting/learn/deep-dives/everything-about-arrays

.LINK
    Join-Object - PowerShell Team
    https://devblogs.microsoft.com/powershell/join-object/

.EXAMPLE
    # read from objects

    ## master

    @(
    "Id,Name"
    "1,John"
    "2,Mark"
    "3,Hanna"
    ) | ConvertFrom-Csv `
      | Set-Variable -Name master

    ## transaction

    @(
    "EmployeeId,When"
    "1,6/12/2012 08:05:01 AM"
    "1,6/13/2012 07:59:12 AM"
    "1,6/14/2012 07:49:10 AM"
    "2,6/12/2012 10:33:00 AM"
    "2,6/13/2012 10:15:00 AM"
    "44,2/29/2012 01:00:00 AM"
    ) | ConvertFrom-Csv `
      | Set-Variable -Name tran


    ## main

    $tran `
        | Join2-Object $master `
            -On id `
            -TransKey EmployeeId `
            -Dummy "@@@" `
            -IncludeMasterKey `
            -PreSortedMasterKey `
        | ft

    EmployeeId When                  m_Id m_Name
    ---------- ----                  ---- ------
    1          6/12/2012 08:05:01 AM 1    John
    1          6/13/2012 07:59:12 AM 1    John
    1          6/14/2012 07:49:10 AM 1    John
    2          6/12/2012 10:33:00 AM 2    Mark
    2          6/13/2012 10:15:00 AM 2    Mark
    44         2/29/2012 01:00:00 AM @@@  @@@

.EXAMPLE
    # read from csv files

    cat tran.csv
        id,v1,v2,v3,v4,v5
        0000005,82,79,16,21,80
        0000001,46,39,8,5,21
        0000004,58,71,20,10,6
        0000009,60,89,33,18,6
        0000003,30,50,71,36,30
        0000007,50,2,33,15,62

    cat master.csv
        id,name,val,class
        0000003,John,26,F
        0000005,Mark,50,F
        0000007,Bob,42,F

    Import-Csv tran.csv `
        | Join2-Object master.csv -On id `
        | ft

    id      v1 v2 v3 v4 v5 m_name m_val m_class
    --      -- -- -- -- -- ------ ----- -------
    0000005 82 79 16 21 80 Mark   50    F
    0000001 46 39 8  5  21
    0000004 58 71 20 10 6
    0000009 60 89 33 18 6
    0000003 30 50 71 36 30 John   26    F
    0000007 50 2  33 15 62 Bob    42    F

.EXAMPLE
    # Filtering record with -OnlyIfInBoth switch
    Import-Csv tran.csv `
        | Join2-Object `
            -Master master.csv `
            -On id `
            -OnlyIfInBoth `
        | ft

    id      v1 v2 v3 v4 v5 m_name m_val m_class
    --      -- -- -- -- -- ------ ----- -------
    0000005 82 79 16 21 80 Mark   50    F
    0000003 30 50 71 36 30 John   26    F
    0000007 50 2  33 15 62 Bob    42    F

.EXAMPLE
    # Filtering record with -Where statement
    Import-Csv tran.csv `
        | Join2-Object `
            -Master master.csv `
            -On id `
            -Where { [double]($_.v2) -gt 39 } `
        | ft

    id      v1 v2 v3 v4 v5 m_name m_val m_class
    --      -- -- -- -- -- ------ ----- -------
    0000005 82 79 16 21 80 Mark   50    F
    0000004 58 71 20 10 6
    0000009 60 89 33 18 6
    0000003 30 50 71 36 30 John   26    F

#>
function Join2-Object
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, Position=0)]
        [Alias('m')]
        [object[]] $Master,
        
        [Parameter(Mandatory=$False)]
        [Alias('t')]
        [object[]] $Tran,
        
        [Parameter(Mandatory=$True, Position=1)]
        [Alias('On')]
        [string[]] $MasterKey,
        
        [Parameter(Mandatory=$False)]
        [Alias('tkey')]
        [string[]] $TransKey,
        
        [Parameter(Mandatory=$False)]
        [scriptblock] $Where,
        
        [Parameter(Mandatory=$False)]
        [Alias('s')]
        [string] $AddSuffixToMasterProperty = "m_",
        
        [Parameter(Mandatory=$False)]
        [Alias('p')]
        [string] $AddPrefixToMasterProperty,
        
        [Parameter(Mandatory=$False)]
        [Alias('d')]
        [string] $Delimiter = ",",
        
        [Parameter(Mandatory=$False)]
        [Alias('mh')]
        [string[]] $MasterHeader,
        
        [Parameter(Mandatory=$False)]
        [Alias('th')]
        [string[]] $TransHeader,
        
        [Parameter(Mandatory=$False)]
        [string] $Dummy = $Null,
        
        [Parameter(Mandatory=$False)]
        [switch] $OnlyIfInBoth,
        
        [Parameter(Mandatory=$False)]
        [switch] $OnlyIfInTransaction,
        
        [Parameter(Mandatory=$False)]
        [switch] $PreSortedMasterKey,
        
        [Parameter(Mandatory=$False)]
        [switch] $SortTranKey,
        
        [Parameter(Mandatory=$False)]
        [switch] $Descending,
        
        [Parameter(Mandatory=$False)]
        [switch] $IncludeMasterKey,
        
        [Parameter(Mandatory=$False, ValueFromPipeline=$True)]
        [object[]] $InputObject
    )
    # private function
    function Rename-MasterProperty
    {
        [CmdletBinding()]
        Param(
            [Parameter(Mandatory=$True, Position=0)]
            [Alias('f')]
            [regex] $From,

            [Parameter(Mandatory=$True, Position=1)]
            [Alias('t')]
            [string] $To,

            [Parameter(Mandatory=$False)]
            [Alias('s')]
            [switch] $SimpleMatch,
            
            [Parameter(Mandatory=$False, ValueFromPipeline=$True)]
            [object[]] $InputObject
        )
        # init variables
        [String[]] $OldPropertyNames = ($input[0].PSObject.Properties).Name
        [String[]] $ReplaceComAry = @()
        [String[]] $newNameAry = @()
        foreach ( $oldName in $OldPropertyNames ){
            if ( $SimpleMatch ){
                [string] $newName = $oldName.Replace($From, $To)
            } else {
                [string] $newName = $oldName -replace $From, $To
            }
            # duplicate test for newname
            if ( $newNameAry.Contains($newName) ){
                Write-Error "Property name: ""$oldName"" -> ""$newName"" already exists." -ErrorAction Stop
            }
            $newNameAry += $newName
            $ReplaceComAry += "@{N=""$newName""; E={`$_.""$($oldName)""}}"
        }
        $hash = $ReplaceComAry | ForEach-Object { Invoke-Expression -Command $_ }
        $input | Select-Object -Property $hash
        return
    }
    # is Master data file or object?
    #Write-Debug "Master: $($Master.GetType().FullName)"
    Write-Debug "Master: $($Master[0])"
    $sortHash = @{
        Property = $MasterKey
        Stable = $True
    }
    if ( $Master.Count -eq 1 -and ( Test-Path -LiteralPath "$($Master[0])") ){
        # Master is file
        # get master as object
        $csvHash = @{
            LiteralPath = [String]($Master[0])
            Delimiter   = "$MasterDelimiter"
            Encoding    = "utf8"
        }
        if ( $Header ){
            $csvHash.Set_Item("Header", $MasterHeader)
        }
        if ( $PreSortedMasterKey ){
            [object[]] $MasterData = Import-Csv @csvHash
        } else {
            [object[]] $MasterData = Import-Csv @csvHash `
                | Sort-Object @sortHash
        }
    } else {
        # MasterData is Object
        if ( $PreSortedMasterKey ){
            [object[]] $MasterData = $Master `
                | Sort-Object @sortHash
        } else {
            [object[]] $MasterData = $Master
        }
    }
    Write-Debug $MasterData.GetType().FullName
    # is Transaction data file or object or pipeline input?
    $sortHash = @{
        Stable = $True
        Descending = $Descending
    }
    if ( $TransKey ){
        $sortHash.Set_Item("Property", $TransKey)
    } else {
        $sortHash.Set_Item("Property", $MasterKey)
    }
    if ( $Tran.Count -gt 0 ){
        #Write-Debug "Tran: $($Tran.GetType().FullName)"
        Write-Debug "Tran: $($Tran[0])"
        if ( $Tran.Count -eq 1 -and ( Test-Path -LiteralPath "$($Tran[0])") ){
            # Transaction is file
            # get tran as object
            $csvHash = @{
                LiteralPath = [String]($Tran[0])
                Delimiter   = "$Delimiter"
                Encoding    = "utf8"
            }
            if ( $Header ){
                $csvHash.Set_Item("Header", $TranHeader)
            }
            if ( $SortTranKey ){
                [object[]] $TranData = Import-Csv @csvHash `
                    | Sort-Object @sortHash
            } else {
                [object[]] $TranData = Import-Csv @csvHash
            }
        } else {
            # MasterData is Object
            if ( $SortTranKey ){
                [object[]] $TranData = $Tran
            } else {
                [object[]] $TranData = $Tran `
                    | Sort-Object @sortHash
            }
        }
    } else {
        # read from pipeline
        if ( $SortTranKey ){
            [object[]] $TranData = $input `
                | Sort-Object @sortHash
        } else {
            [object[]] $TranData = $input
        }
    }
    Write-Debug "Tran: $($TranData.GetType().FullName)"
    # Replace master propertyname
    if ( $AddSuffixToMasterProperty ){
        $MasterData = $MasterData `
            | Rename-MasterProperty `
                -From '^' `
                -To "$AddSuffixToMasterProperty"
    }
    if ( $AddPrefixToMasterProperty ){
        $MasterData = $MasterData `
            | Rename-MasterProperty `
                -From '$' `
                -To "$AddPrefixToMasterProperty"
    }
    # set key list
    if ( $TransKey ){
        if ( $AddSuffixToMasterProperty -or $AddPrefixToMasterProperty ){
            [string[]] $mKeyList = foreach ( $k in $MasterKey ){
                $AddSuffixToMasterProperty + $k + $AddPrefixToMasterProperty }
            [string[]] $tKeyList = $TransKey
        } else {
            [string[]] $mKeyList = $MasterKey
            [string[]] $tKeyList = $TransKey
        }
    } else {
        if ( $AddSuffixToMasterProperty -or $AddPrefixToMasterProperty ){
            [string[]] $mKeyList = foreach ( $k in $MasterKey ){
                $AddSuffixToMasterProperty + $k + $AddPrefixToMasterProperty }
            [string[]] $tKeyList = $MasterKey
        } else {
            [string[]] $mKeyList = $MasterKey
            [string[]] $tKeyList = $MasterKey
        }
    }
    Write-Debug "masterKey : $($mKeyList -join ', ')"
    Write-Debug "transKey  : $($tKeyList -join ', ')"
    # set key ary
    [string] $oldKeyStr = ''
    [string[]] $mKeyAry = $MasterData `
        | ForEach-Object {
            [string] $mKeyStr = ''
            foreach ( $k in $mKeyList ){
                $mKeyStr = $mKeyStr + $_.$k
            }
            # test duplicated key
            if ( $mKeyStr -eq $oldKeyStr ){
                Write-Error "Duplicated master key : $mKeyStr" -ErrorAction Stop
            }
            Write-Output $mKeyStr
            [string] $oldKeyStr = $mKeyStr
        }
    Write-Debug "MasterKeyAry : $($mKeyAry -join ', ')"
    # Main
    ## get dummy record number
    [int] $MasterPropertyNum = @($MasterData[0].PSObject.Properties).Count
    [string[]] $MasterPropertyAry = @(($MasterData[0].PSObject.Properties).Name)
    Write-Debug ($MasterPropertyAry -join ', ')
    ## test for key duplication between master and transaction
    [string[]] $TransPropertyAry = @(($input[0].PSObject.Properties).Name)
    foreach ( $tk in $TransPropertyAry ){
        $tPropIndex = $MasterPropertyAry.IndexOf("$tk")
        if ( $tPropIndex -ge 0 ){
            Write-Error "PropertyName '$($MasterPropertyAry[$tPropIndex])' is duplicated between Master and Transaction." -ErrorAction Continue
            Write-Error "Use '-AddSuffixToMasterProperty ""m_""' option to Rename Master PropertyName" -ErrorAction Stop
        }
    }
    ## for each trans record
    #foreach ($obj in @( $input | Select-Object *) ){
    foreach ($obj in $TranData ){
        # create trans key string
        [string] $tKey = ''
        foreach ( $tk in $tKeyList ){
            $tKey = $tKey + $obj.$tk
        }
        # Find index from master data using "Array.IndexOf()" method.
        # This returns the 0-based index of an array or -1 if not found.
        $mKeyIndex = $mKeyAry.IndexOf("$tKey")
        Write-Debug "Index of $tKey : $mKeyIndex"
        # skip if tkey not exists in mkey list

        if ( $OnlyIfInBoth){
            if ( $mKeyIndex -lt 0 ){
                continue
            } else {
                # pass
            }
        }
        # join
        # convert psobject to hash
        $hash = [ordered] @{}
        foreach ($item in $obj.psobject.properties){
            $hash[$item.Name] = $item.Value
        }
        foreach ( $mk in $MasterPropertyAry ){
            if ( $mKeyIndex -lt 0 ){
                # set dummy record
                $hash["$mk"] = $Dummy
            } else {
                # set master columns
                $hash["$mk"] = $masterData[$mKeyIndex].$mk
            }
        }
        if( $OnlyIfInTransaction){
            if ( $mKeyIndex -lt 0 ){
                # pass
            } else {
                continue
            }
        }
        # where statement: convert hash to psobject
        if ( $Where ){
            if ( $IncludeMasterKey ){
                Where-Object `
                    -InputObject $(New-Object psobject -Property $hash) `
                    -FilterScript $Where
            } else {
                Where-Object `
                    -InputObject $(New-Object psobject -Property $hash) `
                    -FilterScript $Where `
                    | Select-Object -ExcludeProperty $mKeyList
            }
        } else {
            if ( $IncludeMasterKey ){
                New-Object psobject -Property $hash
            } else {
                New-Object psobject -Property $hash `
                    | Select-Object -ExcludeProperty $mKeyList
            }
        }
    }    
}
# set alias
[String] $tmpAliasName = "join2o"
[String] $tmpCmdName   = "Join2-Object"
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
