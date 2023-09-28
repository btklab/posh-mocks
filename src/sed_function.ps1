<#
.SYNOPSIS
    sed - a  Stream EDitor
    
    String replacer. Degraded copy of GNU sed.

    Basically case-insensitive, but case-sensitive whtn
    the "g" flag (described later) is specified.

    Usage:
        sed 's;pattern;replace;g' : global replace
        sed 's;oattern;replace;'  : replace first match only

        Use double quotes to handle control characters such as
        Tab, LineFeed.

            sed "s;`t;,;g"  : replace tab to comma

        The second character from the left of the statement is
        taken as the delimiter between the pattern and the
        replacement strings. (It does not necessarily have to
        be ";"). Any of the following are equivalent.

            sed 's;hello;world;g'
            sed 's@hello@world@g'
            sed 's_hello_world_g'
    
    Print mode:
        sed 'p;pattern for start-of-output;pattern for end-of-output;'

        Output only the lines from the output start-pattern to the
        output end-pattern. Specifying different patterns for the
        start key and end key makes it easier to get the expected
        output.

        (If you spesify the same patterns for the start key and the
        end key, output only the linse containing that pattern, and
        the line in between will not be output.)

    Delete mode:
        sed 'd;pattern for start-of-deletion;pattern for end-of-deletion;'

.LINK
    grep, sed, sed-i

.EXAMPLE
    # g flag - replace all strings matching a pattern
    'a1b1c1' | sed 's;1;2;g'
    a2b2c2

    # replace only first match
    # (Note that this mode is case sensitive)
    'a1b1c1' | sed 's;1;2;'
    a2b1c1

    # delete tab (use double quote)
    cat a.txt | sed "s;`t;;g"

.EXAMPLE
    # print mode

    # input data
    $dat = "aaa", "bbb", "ccc", "ddd", "eee"
    aaa
    bbb
    ccc
    ddd
    eee

    # Output between "bbb" and "ddd"
    $dat | sed 'p;^bbb;^ddd;'
    bbb
    ccc
    ddd


.EXAMPLE
    # delete mode

    # input data
    $dat = "aaa", "bbb", "ccc", "ddd", "eee"
    aaa
    bbb
    ccc
    ddd
    eee

    # Delete between "bbb" and "ddd"
    $dat | sed 'd;^bbb;^ddd;'
    aaa
    eee
#>
function sed {
    begin {
        ## set flags
        [bool] $gflag     = $False
        [bool] $sflag     = $False
        [bool] $pflag     = $False
        [bool] $dflag     = $False
        [bool] $pReadFlag = $False
        [bool] $justFlagged = $False
        
        ## test args
        if($args.Count -ne 1){
            Write-Error "Insufficient args." -ErrorAction Stop
        }
        [string] $OptStr = ([string]($args[0])).Substring(0,1)
        if( ($OptStr -ne "s") -and `
            ($OptStr -ne "p") -and `
            ($OptStr -ne "d") ){
            Write-Error "Invalid args." -ErrorAction Stop
        }
        
        ## get separator
        ## The second character from the left of the statement.
        [string] $SepStr = ([string]($args[0])).Substring(1,1)
        
        # get regex pattern
        $regexstr = ([string]($args[0])).Split("$SepStr")
        if($regexstr.Count -ne 4){
            Write-Error "Invalid args."  -ErrorAction Stop
        }
        [string] $srcptn = $regexstr[1]
        [string] $repptn = $regexstr[2]
        if( $srcptn -eq '' ){
            Write-Error "Invalid args." -ErrorAction Stop
        }
        
        # test args
        if( [string]($regexstr[0]) -eq 's' ){
            [bool] $sflag = $True
        }
        if( [string]($regexstr[0]) -eq 'p' ){
            [bool] $pflag = $True
            [bool] $pReadFlag = $False
        }
        if( [string]($regexstr[0]) -eq 'd' ){
            [bool] $dflag = $True
            [bool] $pReadFlag = $True
        }
        if( [string]($regexstr[3]) -eq 'g' ){
            [bool] $gflag = $True
        }else{
            [regex] $regex = $srcptn
        }
        if(!($sflag) -and !($pflag) -and !($dflag)){
            Write-Error "Invalid args" -ErrorAction Stop}
        Write-Debug "$srcptn, $repptn"
    }

    process {
        if($sflag){
            # s flag : replacement mode
            if($gflag){
                [string] $line = $_ -replace "$srcptn", "$repptn"
            }else{
                [string] $line = $regex.Replace("$_", "$repptn", 1)
            }
            Write-Output $line
        }elseif($pflag){
            # p flag : print only matched line
            [string] $line = [string]$_
            if ( -not $pReadFlag ){
                if($line -match "$srcptn" ){
                    Write-Output $line
                    $pReadFlag = $True
                    [bool] $justFlagged = $True
                }
            }
            if ( $pReadFlag -and ( -not $justFlagged ) ){
                if($line -match "$repptn" ){
                    $pReadFlag = $False
                }
                Write-Output $line
            }
            [bool] $justFlagged = $False
        }elseif($dflag){
            # d flag : delete mode
            [string] $line = [string] $_
            if ( $pReadFlag ){
                if($line -match "$srcptn" ){
                    $pReadFlag = $False
                    [bool] $justFlagged = $True
                } else {
                    Write-Output $line
                }
            }
            if ( ( -not $pReadFlag ) -and ( -not $justFlagged ) ){
                if($line -match "$repptn" ){
                    $pReadFlag = $True
                }
            }
            [bool] $justFlagged = $False
        }
    }
}

