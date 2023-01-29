<#
.SYNOPSIS
    delf - delete fields

    Delete specified columns(fields).
    Specify rightmost columns with "NF".

    delf <num> <num>...

.LINK
    self, delf


.EXAMPLE
"1 2 3","4 5 6","7 8 9" | delf 1 2
3
6
9

# delete field 1 and 2

.EXAMPLE
"1 2 3 4 5","6 7 8 9 10" | delf 1 NF-1
2 3 5
7 8 10

# delete field 1 and 2nd field from right

#>
function delf {

    begin
    {
        # init var
        [string] $writeLine  = ''
        [string] $getLineExp = ''

        # test args
        if($args.Count -lt 1){
            Write-Error "invalid args." -ErrorAction Stop
        }
        # parse args
        foreach($item in $args){
            if($item -match "NF"){
                $item = $item -replace 'NF', '$splitLine.Count-1'
                $item = $item -replace '(..*)', '($1)'
            }else{
                $item = [int] $item - 1
            }
            $getLineExp = $getLineExp + ' ' + '($i -ne ' + [string]$item + ')'
        }
        $getLineExp = $getLineExp -replace '\) \(', ') -and ('
    }

    process
    {
        [string] $readLine = [string] $_
        [string[]] $splitLine = $readLine -Split ' '
        for($i=0;$i -lt $splitLine.Count;$i++){
            $ifExp = Invoke-Expression "$getLineExp"
            if($ifExp){$writeLine += ' ' + [string]$splitLine[$i]}
        }
        [string] $writeLine = $writeLine.Trim()
        Write-Output $writeLine
        $writeLine = ''
    }
}
