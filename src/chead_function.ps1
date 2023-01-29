<#
.SYNOPSIS
    chead - Cut the first part of files

    Cut the specified number of lines
    from the first part of input.

    Accepts input only from pipline.
    Cut 1 row by default.

    The +h option treats the 1st row as a
    header and skips it.

    chead [+h] [-n num]

.LINK
    head, tail, chead, ctail, ctail2

.EXAMPLE
1..5 | chead
2
3
4
5

PS > 1..5 | chead -n 3
4
5

PS > 1..5 | chead +h -n 3
1
5

#>
function chead {

    begin
    {
        [int] $readRowCounter = 0
        [bool] $headerFlag = $false
        # get nubmer of rows to cut
        if($args.Count -eq 0){
            # cut 1 row by default
            [int] $cutRowNum = 1
    
        }elseif( [string] ($args[0]) -eq '-n'){
            # number of cut rows specified
            if($args.Count -lt 2){
                Write-Error "Invalid args." -ErrorAction Stop
            }
            $cutRowNum = [int] ($args[1])
        
        }elseif( [string] ($args[0]) -eq '+h'){
            $headerFlag = $True
            $cutRowNum = 1
            if( [string] ($args[1]) -eq '-n' ){
                # -n 行数指定ありの場合
                if($args.Count -lt 3){
                    Write-Error "Insufficient args." -ErrorAction Stop}
                $cutRowNum = [int] ($args[2])
            }
        }else{
          Write-Error "Invalid args." -ErrorAction Stop
        }
    } # end of begin block
    process
    {
        $readRowCounter++
        [string] $readLine = [string] $_
        if($headerFlag){
            if($readRowCounter -eq 1){
                Write-Output $readLine
            }else{
                if( ($readRowCounter - 1) -gt $cutRowNum){
                    Write-Output $readLine
                }
            }
        } else {
            if($readRowCounter -gt $cutRowNum){
                Write-Output $readLine
            }
        }
    } # end of process block
}
