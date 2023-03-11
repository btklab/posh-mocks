<#
.SYNOPSIS
    yarr - Expand long data to wide

    Convert long data to wide data using the specified
    columns as a key.

    Expects space-separated input without headers.
    No pre-sort required.
    Ignore case.

.LINK
    tarr, yarr

.EXAMPLE
    cat a.txt
    2018 1
    2018 2 9
    2018 3
    2017 1
    2017 2
    2017 3
    2017 4
    2017 5 6
    2022 1
    2022 2

    PS > cat a.txt | grep . | yarr -n 1
    2018 1 2 9 3
    2017 1 2 3 4 5 6
    2022 1 2

#>
function yarr {
    Param(
        [Parameter(Mandatory=$False,Position=0)]
        [Alias('n')]
        [int] $num = 1,

        [Parameter(Mandatory=$False)]
        [string] $Delimiter = ' ',

        [parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [string[]] $Text
    )

    begin {
        ## init var
        $hash = [ordered] @{}
    }
    process {
        [string] $readLine = $_
        # is line empty?
        if ($readLine -eq ''){
            Write-Error "Detect empty line: $readLine" -ErrorAction Stop
        }
        # split key
        if ( $Delimiter -eq '' ){
            [string[]] $keyValAry = $readLine.ToCharArray()
        } else {
            [string[]] $keyValAry = $readLine.Split( $Delimiter )
        }
        if ($keyValAry.Count -le $num){
            Write-Error "Detect key-only line: $readLine"  -ErrorAction Stop
        }
        # set key, val into hashtable
        [int] $sKey = 0
        [int] $eKey = $num - 1
        [int] $sVal = $eKey + 1
        [int] $eVal = $keyValAry.Count - 1
        [string] $key = $keyValAry[($sKey..$eKey)] -Join $Delimiter
        [string] $val = $keyValAry[($sVal..$eVal)] -Join $Delimiter
        if ($hash.Contains($key)){
            # if key already exist
            [string] $val = $hash["$key"] + $Delimiter + $val
            $hash["$key"] = $val
        } else {
            $hash.Add($key, $val)
        }
    }
    end {
        # output hash
        foreach ($k in $hash.keys){
            [string] $writeLine = $k + $Delimiter + $hash["$k"]
            Write-Output $writeLine
        }
    }
}
