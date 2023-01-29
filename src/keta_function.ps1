<#
.SYNOPSIS
    keta - Padding per columns

    Display each column right-justified with spaces
    filled in according to the number of characters
    in each column.

    Make the standard output easier to read for human
    on the terminal.

    keta [-l]
    -l: left padding

.EXAMPLE
    "aaa bbb ccc","dddddd eeee ffff"
    aaa bbb ccc
    dddddd eeee ffff

    # right padding (default)
    PS > "aaa bbb ccc","dddddd eeee ffff" | keta
       aaa  bbb  ccc
    dddddd eeee ffff

    # left padding (-l switch)
    PS > "aaa bbb ccc","dddddd eeee ffff" | keta -l
    aaa    bbb  ccc 
    dddddd eeee ffff

#>
function keta {

    begin
    {
        # get args
        if(($args.Count) -and ( [string]($args[0]) -eq '-l' )){
            $leftPaddingFlag = $True
        } else {
            $leftPaddingFlag = $False
        }
        # init variables
        [string] $Delimiter = ' '
        [string] $sp = ''
        [string] $writeLine = ''
        [int] $readRow = 0
        $hashRow = @{}
        # hashtable for storing the number of character bytes for each column
        $hashColByte = @{}
    }

    process
    {
        # 1st pass
        $readRow++
        [string] $readLine = [string] $_
        $hashRow["key$readRow"] = $readLine
        [string[]] $splitLine = $readLine -Split $Delimiter

        # get number of columns
        if($readRow -eq 1){$retu = $splitLine.Count}

        # get number of character width for each column
        for($i = 0; $i -lt $splitLine.Count; $i++){
            [string] $colStr = $splitLine[$i]
            [int] $colWidth = [System.Text.Encoding]::GetEncoding("Shift_Jis").GetByteCount($colStr)

            # get max column width for each column
            if([int]($colWidth) + 0 -gt [int]($hashColByte[$i]) + 0){
                $hashColByte[$i] = $colWidth
            }
        }
    }

    end
    {
        # 2nd pass
        for($i = 1; $i -le $readRow; $i++){
            # reload the line and getting the number of character width
            $splitLine = $hashRow["key$i"] -Split $Delimiter

            # get number of character width per column
            for($j = 0; $j -lt $splitLine.Count; $j++){
                [string] $colStr = $splitLine[$j]
                [int] $colWidth = [System.Text.Encoding]::GetEncoding("Shift_JIS").GetByteCount($colStr)

                # padding
                [int] $setByteNum = [int]($hashColByte[$j]) - [int]($colWidth)
                if($setByteNum -le 0){$setByteNum = 0}

                for($k = 1; $k -le $setByteNum; $k++){
                    $sp = $sp + ' '
                }

                # left padding or right padding?
                if($leftPaddingFlag){
                    [string] $tmpWriteLine = $colStr + $sp
                }else{
                    [string] $tmpWriteLine = $sp + $colStr
                }
                $sp = ''

                # output
                if($j -eq 0){
                    [string] $writeLine = $tmpWriteLine
                }else{
                    [string] $writeLine = $writeLine + $Delimiter + $tmpWriteLine
                }
            }
            Write-Output $writeLine
            [string] $writeLine = ''
        }
    }
}
