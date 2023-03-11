<#
.SYNOPSIS
    self - select fields

    Select specified columns(fields).
    Specify rightmost columns with "NF".
    Specify all columns with "0".

    self <num> <num>...

.LINK
    self, delf

.EXAMPLE
    "1 2 3","4 5 6","7 8 9" | self 1 3
    1 3
    4 6
    7 9

    # select field 1 and 3

.EXAMPLE
     "123 456 789","223 523 823" | self 2.2.2
    56
    23

    # select entire line and add 2nd field,
    # and cut out 2 characters from the 2nd character in the 2nd field

.EXAMPLE
    "123 456 789","223 523 823" | self 0 2.2.2
    123 456 789 56
    223 523 823 23

    # select the 1st field from the leftmost field and
    # select the 2nd field from the rightmost field(=NF)

.EXAMPLE
    "1 2 3 4 5","6 7 8 9 10" | self 1 NF-1
    1 4
    6 9

    # select the 1st column, 
    # and the 2nd column from the right

#>
function self {
    begin
    {
        # test args
        if($args.Count -lt 1){
            Write-Error "invalid args." -ErrorAction Stop
        }
        # init var
        [string] $getLineExp = ''
        [string] $Delimiter = ' '
        # convert args to column select command
        foreach($a in $args){
            [string] $repdot2space = $a -replace '\.', ' '
            [string[]] $tmpindividualarg = $repdot2space.Split(' ')
            # generate column select command
            # "NF" means rightmost column
            if( [string]($tmpindividualarg[0]) -match "NF" ){
                [string] $getColNum = $tmpindividualarg[0] -replace 'NF', '$splitLine.Count-1'
                [string] $getColNum = $getColNum -replace '(..*)', '($1)'
            }elseif([int]($tmpindividualarg[0]) -eq 0){
                [string] $getColNum = '@@@'
            }else{
                [string] $getColNum = [int]($tmpindividualarg[0]) - 1
            }

            if($tmpindividualarg.Count -eq 2){
                [int] $substrStartNum  = [int]($tmpindividualarg[1]) - 1
                [string] $substrEndNum = '$($splitLine[' + $getColNum + '].Length - 1)'
            }
            if($tmpindividualarg.Count -eq 3){
                [int] $substrStartNum  = [int]($tmpindividualarg[1]) - 1
                [string] $substrEndNum = [int]($tmpindividualarg[2]) + $substrStartNum - 1
            }
            # set column select command
            if($tmpindividualarg.Count -eq 1){
                [string] $getLineExp += $Delimiter + '[string]$splitLine[' + $getColNum + ']'
            }else{
                [string] $getLineExp += $Delimiter + '[string]$(([string]$splitLine[' + $getColNum + '])[' + [string]$substrStartNum + '..' + [string]$substrEndNum + '] -Join "")'
            }
        }
        [string] $getLineExp = $getLineExp -replace '\] \[string', "] + ""$Delimiter"" + [string"
        [string] $getLineExp = $getLineExp -replace '\) \[string', ") + ""$Delimiter"" + [string"
        # if arg is 0, output the entire line
        [string] $getLineExp = $getLineExp -replace '\[string\]\$splitLine\[@@@\]', '$readLine'
        [string] $getLineExp = $getLineExp.Trim()
    }
    process
    {
        [string] $readLine = [string] $_
        if ( $Delimiter -eq '' ){
            [string[]] $splitLine = $readLine.ToCharArray()
        } else {
            [string[]] $splitLine = $readLine.Split( $Delimiter )
        }
        [string] $writeLine = Invoke-Expression $getLineExp
        Write-Output $writeLine
    }
}
