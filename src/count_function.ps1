<#
.SYNOPSIS
    count - Count up keys

    Counts the number of lines on the same key
    form a space-separated input.

    count [-c] <key1> <key2>

    Count the number of lines with the same key
    from <k1> to <k2> columns of the pipline input.

    Case insensitive.
    Requires prior sorting by key sequence.

    If -c switch is specified, output all rows
    while counting up the same key strings.

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

PS> cat dat.txt | grep . | sort | count 1 2
4 01 aaa
3 02 bbb
3 03 ccc
3 04 ddd

PS> cat dat.txt | grep . | sort | count -c 1 2
1 01 aaa 01 xxx 10
2 01 aaa 02 yyy 10
3 01 aaa 03 zzz 10
4 01 aaa 04 ooo 10
1 02 bbb 01 xxx 10
2 02 bbb 02 yyy 10
3 02 bbb 03 zzz 10
1 03 ccc 01 xxx 10
2 03 ccc 02 yyy 10
3 03 ccc 03 zzz 10
1 04 ddd 01 xxx 10
2 04 ddd 02 yyy 10
3 04 ddd 03 zzz 10

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

# Forgetting to sort by key yields unexpected results
PS > | grep . | count 1 2
3 01 aaa # <- unexpected result!
3 02 bbb
1 01 aaa # <- unexpected result!
3 03 ccc
3 04 ddd

#>
function count {

    begin
    {
        # parse args
        if($args.Count -lt 2){
            Write-Error "Insufficient arguments." -ErrorAction Stop
        }elseif ($args[0] -eq "-c"){
            if($args.Count -lt 3){
                Write-Error "Insufficient arguments." -ErrorAction Stop
            }
            [bool] $oFlag = $True
            [int] $k1 = [int] ($args[1]) - 1
            [int] $k2 = [int] ($args[2]) - 1
        }else{
            [bool] $oFlag = $False
            [int] $k1 = [int] ($args[0]) - 1
            [int] $k2 = [int] ($args[1]) - 1
        }
        # row counter
        [int] $readRow = 0
        # key counter
        [int] $keyCount = 0
        # init var
        [string] $writeLine = ""
        [string] $Delimiter = " "
    }
    process
    {
        $readRow++
        [string] $readLine = [string] $_
        if ( $Delimiter -eq '' ){
            [string[]] $splitLine = $readLine.ToCharArray()
        } else {
            [string[]] $splitLine = $readLine.Split( $Delimiter )
        }
        # create key string
        [string] $key = $splitLine[($k1..$k2)] -Join "$Delimiter"
        # reset count if key changed
        if($readRow -gt 1){
            if ($oFlag){
                [string] $writeLine = [string] $keyCount + "$Delimiter" + $lastline
                Write-Output "$writeLine"
            } else {
                if($key -ne $lastkey){
                    [string] $writeLine = [string]$keyCount + "$Delimiter" + $lastkey
                    Write-Output "$writeLine"
                }
            }
            if($key -ne $lastkey){
                $keyCount = 0
            }
        }
        [string] $lastkey = $key
        [string] $lastline = $readLine
        # count up key num
        $keyCount++
    } # end of process block
    end
    {
        if ($oFlag){
            [string] $writeLine = [string] $keyCount + "$Delimiter" + $lastline
        } else {
            [string] $writeLine = [string] $keyCount + "$Delimiter" + $lastkey
        }
        Write-Output "$writeLine"
    }
}
