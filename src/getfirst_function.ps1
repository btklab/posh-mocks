<#
.SYNOPSIS
    getfirst - Get the first row of the same key

    Get the first row of the same key from
    a space-separated input. Case-insensitive
    
    getfirst <k1> <k2>

    How to read command:
       Get only the first row with the same key with the value
       concatenated from 1st to 2nd column as the key.

.LINK
    getfirst, getlast

.EXAMPLE
    cat dat.txt
    01 aaa 01 xxx 10
    01 aaa 02 yyy 10
    01 aaa 03 zzz 10
    02 bbb 01 xxx 10
    02 bbb 02 yyy 10
    02 bbb 03 zzz 10
    01 aaa 04 ooo 10
    03 ccc 01 xxx 10
    03 ccc 02 yyy 10
    03 ccc 03 zzz 10
    04 ddd 01 xxx 10
    04 ddd 02 yyy 10
    04 ddd 03 zzz 10

    PS > cat dat.txt | sort | getfirst 1 2
    01 aaa 01 xxx 10
    02 bbb 01 xxx 10
    03 ccc 01 xxx 10
    04 ddd 01 xxx 10

#>
function getfirst {
    begin
    {
        [string] $Delimiter = ' '
        # test args
        if($args.Count -ne 2){
            Write-Error "not enough arguments." -ErrorAction Stop
        }
        [int] $k1 = [int]($args[0]) - 1
        [int] $k2 = [int]($args[1]) - 1
        if (($k1 -lt 0) -or ($k2 -lt 0)){
            Write-Error "Specify an integer greater equal to 1" -ErrorAction Stop
        }
        if ($k2 -lt $k1){
            Write-Error "$k2 less than $k1." -ErrorAction Stop
        }
        # init key hashtable
        [int] $ver = $PSVersionTable.PSVersion.Major
        if($ver -le 2){
            $hash = @{}
        }else{
            $hash = [ordered]@{}
        }
    }
    process
    {
        [string] $readLine = [string] $_
        if ( $Delimiter -eq '' ){
            [string[]] $splitLine = $readLine.ToCharArray()
        } else {
            [string[]] $splitLine = $readLine.Split( $Delimiter )
        }
        if ($k2 -gt $splitLine.Count - 1){
            Write-Error "More than the number of columns was specified" -ErrorAction Stop
        }
        [string] $key = $splitLine[($k1..$k2)]
        if( -not ($hash.Contains("$key")) ){
            $hash["$key"] = $readLine
        }
    }
    end
    {
        foreach ($k in $hash.Keys){
            [string] $val = $hash[$k]
            Write-Output $val
        }
    }
}
