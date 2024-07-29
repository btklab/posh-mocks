<#
.SYNOPSIS
    pawk - Pattern-Action processor like GNU AWK

        pawk -Pattern { condition } -Action { action }

    pawk reads the input a line at a time, scans for pattern,
    and executes the associated action if pattern matched.

    As a feature, pipeline processing can be applied only to
    specific columns for multiple column inputs, like below.

        # input line (csv: comma separated values)
        PS> $dat = "abc,def,ghi","jkl,mno,pqr","stu,vwz,012"
        abc,def,ghi
        jkl,mno,pqr
        stu,vwz,012

        # apply rev commnand only 2nd columns
        PS> $dat | pawk -fs "," -Pattern {$1 -match "^j"} -Action {$2=$2|rev;$0}
        jkl,onm,pqr

        # apply rev commnand only 2nd columns and output all lines
        PS> $dat | pawk -fs "," -Pattern {$1 -match "^j"} -Action {$2=$2|rev} -AllLine
        abc,def,ghi
        jkl,onm,pqr
        stu,vwz,012

        # -Begin, -Process and -End block like AWK
        PS> 1..10 | pawk -Begin { $sum=0 } -Action { $sum+=$1 } -End { $sum }
        55

    options:
        - [[-a|-Action] <ScriptBlock>] ...action script
        - [-p|-Pattern <ScriptBlock>] ...pattern criteria
        - [-b|-Begin <ScriptBlock>] ...run before reading input
        - [-f|-First <ScriptBlock>] ...run only the first input
        - [-e|-End] <ScriptBlock> ...run after reading input
        - [-fs|-Delimiter <String>] ...input/output field separator
        - [-ifs|-InputDelimiter <String>] ...input field separator
        - [-ofs|-OutputDelimiter <String>] ...output field separator
            - If -ifs or -ofs are not specified, -fs delimiter
              will be used as both the input and output delimiter.
            - If -ifs and/or -ofs are specified together,
              -fs delimiter will be overridden.
        - [-AllLine] ...output all input even if not match pattern
                         (but action is only apply to matching rows)
        - [-SkipBlank] ...continue processing when empty line is detected
        - [-LeaveBlank] ...Skip and Leave empty lines

    note:
        -Action, -Pattern, -Begin, -End options should be specified in
        the script block.

        The column specification symbols are $1,$2,...,$NF. (The left most
        column number is 1 and counts up to the right.) Specifying $0 means
        the entire row. Note that it is not allowed to assign value to $0
        (do not use $0=$val in script block).

        Each column value is interpreted as System.Double if it looks like
        a number, and otherwise, as System.String. Note that zero starting
        numbers are treated as system.string exceptionally.
        Underscore(_) can also be used as a numeric delimiter. (e.g. 123_456)

        Built-in variables and options:
            - $NF : the last element of the current line
                    (not the number of current line)
            - $NR : current row number

    simple examples:
        # sum from 1 to 10 and output the result
        PS> 1..10 | pawk -Begin {$sum=0} -Action {$sum+=$1} -End {$sum}
        55

        # notes on interpreting numbers and strings
        # input data (zero padding numbers)
        PS> 1..5 | %{ "{0:d3}" -f $_ }
        001
        002
        003
        004
        005

        PS> 1..5 | %{ "{0:d3}" -f $_ } | pawk -Pattern {$1 -eq 1}
        match nothing.
        because numbers starting with zero are considered strings.

        PS> 1..5 | %{ "{0:d3}" -f $_ } | pawk -Pattern {[int]$1 -eq 1}
        001

        PS> 1..5 | %{ "{0:d3}" -f $_ } | pawk -Pattern {$1 -eq "001"}
        001

        PS> 1..5 | %{ "{0:d3}" -f $_ } | pawk -Pattern {$1 -ne "001"}
        002
        003
        004
        005

        PS> 1..5 | %{ "{0:d3}" -f $_ } | pawk -Pattern {$1 -eq "001"} -Action {$1+1}
        0011

        PS> 1..5 | %{ "{0:d3}" -f $_ } | pawk -Pattern {$1 -eq "001"} -Action {$1+1} -AllLine
        0011
        002
        003
        004
        005

        PS> 1..5 | %{ "{0:d3}" -f $_ } | pawk -Pattern {$1 -eq "001"} -Action {[int]$1+1}
        2

        PS> 1..5 | %{ "{0:d3}" -f $_ } | pawk -Pattern {$1 -eq "001"} -Action {[int]$1+1} -AllLine
        2
        002
        003
        004
        005

        # column specification using $0
        PS> "a b c 1","d e f 2","g h i 3"
        a b c 1
        d e f 2
        g h i 3

        PS> "a b c 1","d e f 2","g h i 3" | pawk -Action {$0 + " zzz"}
        a b c 1 zzz
        d e f 2 zzz
        g h i 3 zzz

        # replace 2nd column
        PS> "a b c 1","d e f 2","g h i 3" | pawk -Action {$2="zzz" ; $0}
        a zzz c 1
        d zzz f 2
        g zzz i 3

        # when using the column specification operator "$1" in double uotes,
        # add the subexpression operator like "$($1)"
        PS> "a b c 1","d e f 2","g h i 3" | pawk -Action {"id: $($4), tag: ""$($1)"""}
        id: 1, tag: "a"
        id: 2, tag: "d"
        id: 3, tag: "g"

        # see more examples in .EXAMPLE section.

    inspired by:
        The GNU Awk Users Guide
        https://www.gnu.org/software/gawk/manual/gawk.html

.LINK
    lcalc

.PARAMETER Action
    [-a|-Action] <ScriptBlock>

    Apply <scriptblock> to rows and columns matching the condition of
    -Pattern option.

    Without -Pattern option, apply <scriptblock> to all records.

    The column specification symbols are $1,$2,...,$NF. (The left most
    column number is 1 and counts up to the right.)

    Specifying $0 means the entire row. Note that it is not allowed to
    assign value to $0 (do not use $0=$val in script block).

.PARAMETER Pattern
    [-p|-Pattern] <ScriptBlock>

    Output only rows that matches <scriptblock> conditions.
    With -Action option, apply -Action <scriptblock> to match rows.

    With -AllLine switch, all rows are output regardless of whether
    matches pattern or not. Note that even in this case,
    the -Action <scriptblock> is only applied to rows that match
    -Pattern option.

    The column specification symbols are $1,$2,...,$NF.
    (The left most column number is 1 and counts up to the right.)

    Specifying $0 means the entire row. Note that it is not allowed
    to assign value to $0 (do not use $0=$val in script block).

.PARAMETER Begin
    [-b|-Begin] <ScriptBlock>

    A scriptblock to run before reading any input.
    For example, it is used for init variables, adding headers, and more...

.PARAMETER End
    [-e|-End] <ScriptBlock>

    A scriptblock to run after reading all input.
    For example, it is used for output/format results, adding footers, and more...

.PARAMETER Delimiter
    [-fs|-Delimiter] <String>

    Specifies the input/output delimiter. Default is a space.
    (default: -fs " ")

    When specifying special characters like tabs and line feeds,
    wrap them in double quotes.

    If -ifs or -ofs are not specified, this -fs delimiter will be
    used as both the input and output delimiter.

    If -ifs and/or -ofs are specified together, this -fs value will
    be overridden.

.PARAMETER InputDelimiter
    [-ifs|-InputDelimiter] <String>

    Specifies the input delimiter.

    When specifying special characters like tabs and line feeds,
    wrap them in double quotes.

    If -fs and -ifs are specified at the same time, -ifs is selected.

.PARAMETER OutputDelimiter
    [-ofs|-OutputDelimiter] <String>

    Specifies the output delimiter.]

    When specifying special characters like tabs and line feeds,
    wrap them in double quotes.

    If -fs and -ofs are specified at the same time, -ofs is selected.

.PARAMETER AllLine
    With -AllLine switch, all rows are output regardless of whether
    matches pattern or not. Note that even in this case,
    the -Action <scriptblock> is only applied to rows that match
    -Pattern option.

.PARAMETER SkipBlank
    Continue processing even if an empty line is detected.

.PARAMETER First
    Run only the first input

.EXAMPLE
    # sum from 1 to 10 and output the result
    PS> 1..10 | pawk -Begin {$sum=0} -Action {$sum+=$1} -End {$sum}
    55

    # output all line using $0 in -Action script block
    PS> 1..10 | pawk -Begin {$sum=0} -Action {$sum+=$1;$0} -End {"=====","sum: $sum"}
    1
    2
    3
    4
    5
    6
    7
    8
    9
    10
    =====
    sum: 55

.EXAMPLE
    # If both -Action {$0} and -AllLine switch are
    # used at the same time, the outputs are duplicated.
    PS> 1..3 | pawk -Begin {$sum=0} -Action {$sum+=$1;$0} -End {"=====","sum: $sum"} -AllLine
    1
    1
    2
    2
    3
    3
    =====
    sum: 6

    # All of the following get all line output
    PS> 1..3 | pawk -Begin {$sum=0} -Action {$sum+=$1} -End {"=====","sum: $sum"} -AllLine
    PS> 1..3 | pawk -Begin {$sum=0} -Action {$sum+=$1;$0} -End {"=====","sum: $sum"}
    1
    2
    3
    =====
    sum: 6

    # Although -Action {$0} and -AllLine switch have different outputs,
    # there is no difference in that the action is
    # executed only pattern-mathed rows.

    ## Case1: -Action {$0}
    PS> 1..3 | pawk -Begin {$sum=0} -Action {$sum+=$1 ; $0 } -End {"=====","sum: $sum"} -Pattern {$1 % 2 -eq 1}
    1
    3
    =====
    sum: 4

    ## Case2: -AllLine switch. Total value is the same as above. (sum=4)
    ## (Action skipped not mathed rows)
    PS> 1..3 | pawk -Begin {$sum=0} -Action {$sum+=$1} -End {"=====","sum: $sum"} -Pattern {$1 % 2 -eq 1} -AllLine
    1
    2
    3
    =====
    sum: 4

    # Note that if -AllLine switch is used,
    # it duplicates the output if there is
    # an output with -Action {action}

.EXAMPLE
    # notes on interpreting numbers and strings

    # input data (zero padding numbers)
    PS> $dat = 1..5 | %{ "{0:d3}" -f $_ }
    001
    002
    003
    004
    005

    PS> $dat | pawk -Pattern {$1 -eq 1}
    match nothing.
    because numbers starting with zero are considered strings.

    # Cast [string]"001" to [int]"001"
    PS> $dat | pawk -Pattern {[int]$1 -eq 1}
    001   # matched!

    # Match if you compare a zero-filled number as a string
    PS> $dat | pawk -Pattern {$1 -eq "001"}
    001

    # Inversion of the above criteria ( -eq to -ne )
    PS> $dat | pawk -Pattern {$1 -ne "001"}
    002
    003
    004
    005

    # Zero-filled numbers are strings,
    # so their sum with a number is a
    # concatenation of strings.
    PS> $dat | pawk -Pattern {$1 -eq "001"} -Action {$1+1}
    0011

    # -AllLine switch outputs all lines that
    #  do not match the pattern. However,
    # the action is executed only on lines that
    # match the pattern
    PS> $dat | pawk -Pattern {$1 -eq "001"} -Action {$1=$1+1} -AllLine
    0011
    002
    003
    004
    005

    # Cast 1st column of zero-filled numbers to an integer
    # and then takeing the numeric sum gives the expected behaviour.
    PS> $dat | pawk -Pattern {$1 -eq "001"} -Action {[int]$1+1}
    2

    # -AllLine switch
    PS> $dat | pawk -Pattern {$1 -eq "001"} -Action {$1=[int]$1+1} -AllLine
    2
    002
    003
    004
    005

.EXAMPLE
    # Column specification using $0

    PS> $dat = "a b c 1","d e f 2","g h i 3"
    a b c 1
    d e f 2
    g h i 3

    PS> $dat | pawk -Action {$0 + " zzz"}
    a b c 1 zzz
    d e f 2 zzz
    g h i 3 zzz

    # Replace 2nd column
    PS> $dat | pawk -Action {$2="zzz" ; $0}
    PS> $dat | pawk -Action {$2="zzz"} -AllLine
    a zzz c 1
    d zzz f 2
    g zzz i 3

.EXAMPLE
    # Read csv data

    PS> $dat = "a b c 1","d e f 2","g h i 3" | %{ $_ -replace " ",","}
    a,b,c,1
    d,e,f,2
    g,h,i,3

    PS> $dat | pawk -fs "," -Action {$2=$2*3 ; $0}
    a,bbb,c,1
    d,eee,f,2
    g,hhh,i,3

    # Convert csv to tsv
    PS> $dat | pawk -fs "," -Action {$0} -ofs "`t"
    a       b       c       1
    d       e       f       2
    g       h       i       3

.EXAMPLE
    # Pattern match and execute Action

    PS> $dat = "a b c 1","d e f 2","g h i 3" | %{ $_ -replace " ",","}
    a,b,c,1
    d,e,f,2
    g,h,i,3

    # Pattern match
    PS> $dat | pawk -fs "," -Pattern {$NF -gt 1}
    d,e,f,2
    g,h,i,3

    PS> $dat | pawk -fs "," -Pattern {$NF -gt 1 -and $2 -match 'e'}
    d,e,f,2

    PS> $dat | pawk -fs "," -Pattern {$NF -le 1}
    a,b,c,1

    # Pattern match and replace 1st field
    PS> $dat | pawk -fs "," -Pattern {$NF -gt 1} -Action {$1="aaa";$0}
    aaa,e,f,2
    aaa,h,i,3

    # Pattern match and replace 1st field and output all rows,
    # but -Action script is applied only pattern matched rows.
    PS> $dat | pawk -fs "," -Pattern {$NF -gt 1} -Action {$1="aaa"} -AllLine
    a,b,c,1
    aaa,e,f,2
    aaa,h,i,3

.EXAMPLE
    # Handling zero padding numbers

    PS> $dat = "001,aaa,1","002,bbb,2","003,ccc,4","005,ddd,5"
    001,aaa,1
    002,bbb,2
    003,ccc,4
    005,ddd,5

    # Zero padding numbers are not double but string
    PS> $dat | pawk -fs "," -Pattern {$1 -eq 2}
    # not match

    PS> $dat | pawk -fs "," -Pattern {$1 -eq "002"}
    002,bbb,2

    # Cast as double
    PS> $dat | pawk -fs "," -Pattern {[int]$1 -eq 2}
    002,bbb,2

.EXAMPLE
    # Use -begin -end example

    PS> $dat = "001,aaa,1","002,bbb,2","003,ccc,4","005,ddd,5"
    001,aaa,1
    002,bbb,2
    003,ccc,4
    005,ddd,5

    # Add 3rd field values and output result
    PS> $dat | pawk -fs "," -Begin {$sum=0} -Action {$sum+=$3} -End {$sum}
    12

    PS> $dat | pawk -fs "," -Begin {$sum=0} -Action {$sum+=[math]::Pow($3,2);$0+","+[math]::Pow($3,2)} -End {$sum}
    001,aaa,1,1
    002,bbb,2,4
    003,ccc,4,16
    005,ddd,5,25
    46

.EXAMPLE
    # As a feature, pipeline processing can be applied only to
    # specific columns for multiple column inputs, like below.

    # Input
    PS> $dat = "abc,def,ghi","jkl,mno,pqr","stu,vwz,012"
    abc,def,ghi
    jkl,mno,pqr
    stu,vwz,012

    # Apply rev commnand only 2nd columns
    PS> $dat | pawk -fs "," -Action {$2=$2|rev;$0}
    PS> $dat | pawk -fs "," -Action {$2=$2|rev} -AllLine
    abc,fed,ghi # reverse 2nd column
    jkl,onm,pqr # reverse 2nd column
    stu,zwv,012 # reverse 2nd column

    # Apply rev commnand only 2nd columns and only pattern matched rows
    PS> $dat | pawk -fs "," -Action {$2=$2|rev} -Pattern {$1 -match '^j'} -AllLine
    abc,def,ghi  # not match
    jkl,onm,pqr  # reverse 2nd column
    stu,vwz,012  # not match


.EXAMPLE
    # Select column

    # Input data
    PS> $dat = "abc,def,ghi","jkl,mno,pqr","stu,vwz,012"
    abc,def,ghi
    jkl,mno,pqr
    stu,vwz,012

    # The following is probably not expected behavior
    PS> $dat | pawk -fs "," -Action {$1,$2}
    abc
    def
    jkl
    mno
    stu
    vwz

    # Use -join operator
    PS> $dat | pawk -fs "," -Action {$1,$2 -join ","}
    abc,def
    jkl,mno
    stu,vwz

    # Use @() to specify an array
    PS> $dat | pawk -fs "," -Action {@($1,$2) -join ","}
    abc,def
    jkl,mno
    stu,vwz

    # Equivalent alternate solution.Using the fact that input rows　are
    # separated by delimiters and stored in a variable of array named "$self".
    # note that the index is zero start in this case.
    PS> $dat | pawk -fs "," -Action {$self[0..1] -join ","}
    abc,def
    jkl,mno
    stu,vwz

.EXAMPLE
    # Various column selections

    # Input data
    PS> $dat = "abc,def,ghi","jkl,mno,pqr","stu,vwz,012"
    abc,def,ghi
    jkl,mno,pqr
    stu,vwz,012

    # Duplicate columns
    PS> $dat | pawk -fs "," -Action {$1,$1,$1,$1 -join ","}
    abc,abc,abc,abc
    jkl,jkl,jkl,jkl
    stu,stu,stu,stu

    # Select max Number of field(column)
    PS> $dat | pawk -fs "," -Action {$NF}
    ghi
    pqr
    012

    # Select max Number -1 of field(column)
    PS> $dat | pawk -fs "," -Action {$self[-2]}
    def
    mno
    vwz

    PS> $dat | pawk -fs "," -Action {$self[$self.count-2]}
    def
    mno
    vwz

    # Select n to last columns
    PS> $dat |pawk -fs "," -Action {$self[1..($self.count-1)] -join ","}
    def,ghi
    mno,pqr
    vwz,012

.EXAMPLE
    # Manipulation of specific columns

    # Input
    PS> $dat = "001,aaa,2022-01-01","002,bbb,2022-01-02","003,ccc,2022-01-03","005,ddd,2022-01-04"
    001,aaa,2022-01-01
    002,bbb,2022-01-02
    003,ccc,2022-01-03
    005,ddd,2022-01-04

    # Add days +1 to 3rd column
    PS> $dat | pawk -fs "," -Action {$3=(Get-Date $3).AddDays(-10).ToString('yyyy-MM-dd')} -AllLine
    001,aaa,2021-12-22
    002,bbb,2021-12-23
    003,ccc,2021-12-24
    005,ddd,2021-12-25

.EXAMPLE
    # Manipulation of specific columns using pipe

    # Input
    PS> $dat = "001,aaa,20220101","002,bbb,20220102","003,ccc,20220103","005,ddd,20220104"
    001,aaa,20220101
    002,bbb,20220102
    003,ccc,20220103
    005,ddd,20220104

    # Format date for 3rd column.
    # (Column symbols ($1,$2,...) in single quotes are escaped.
    # so that $1,$2,... symbols in the ForEach-Object command
    # has the expected behavior.)
    $dat | pawk -fs "," -Action {$3=$3|ForEach-Object{$_ -replace '([0-9]{4})([0-9]{2})([0-9]{2})','$1-$2-$3'}; $0}
    001,aaa,2022-01-01
    002,bbb,2022-01-02
    003,ccc,2022-01-03
    005,ddd,2022-01-04

    # Equivalent alternative solution using [datetime]::ParseExact
    PS> $dat | pawk -fs "," -Action {$3=([datetime]::ParseExact($3,"yyyyMMdd",$null)).ToString('yyyy-MM-dd'); $0}
    001,aaa,2022-01-01
    002,bbb,2022-01-02
    003,ccc,2022-01-03
    005,ddd,2022-01-04

.EXAMPLE
    # Usage of build-in variables ($NF, $NR)

    # Input
    PS> $dat = "1,aaa,111","2,bbb,222","3,ccc,333"
    1,aaa,111
    2,bbb,222
    3,ccc,333

    PS> $dat | pawk -fs "," -Pattern {$NF -ge 222}
    2,bbb,222
    3,ccc,333

    PS> $dat | pawk -fs "," -Pattern {$NR -ge 1}
    1,aaa,111
    2,bbb,222
    3,ccc,333

.EXAMPLE
    # Re-arrange 2-4 characters of an undelimited strings.

    # Input
    PS> "aiueo","12345","abcde"
    aiueo
    12345
    abcde

    # Re-arrange 2-4 chars of each row.
    PS> "aiueo","12345","abcde" | pawk -fs '' -Action {$self[0,3,2,1,4] -join ''}
    aeuio
    14325
    adcbe

    # Equivalent to the above
    PS> "aiueo","12345","abcde" | pawk -fs '' -Action {@($1,$4,$3,$2,$5) -join ''}
    aeuio
    14325
    adcbe

    # If an empty string is specified as the delimiter,
    # the first and last elements are dropped from the array.

.EXAMPLE
    # -First option usecase

    PS> cat bank-account.txt
    2023-10-01   0 100 +start @bank
    2023-10-15 100 200 +electricity @bank

    PS> cat bank-account.txt | pawk -First {$sum=$3} -Action {$sum+=$2;$3=$sum} -AllLine -IgnoreConsecutiveDelimiters
    2023-10-01 0 100 +start @bank
    2023-10-15 100 200 +electricity @ban

.EXAMPLE
    # when using the column specification operator "$1" in double uotes,
    # add the subexpression operator like "$($1)"
    PS> "a b c 1","d e f 2","g h i 3" | pwk -Action {"id: $($4), tag: ""$($1)"""}
    id: 1, tag: "a"
    id: 2, tag: "d"
    id: 3, tag: "g"
#>
function pawk {
    Param(
        [Parameter(Mandatory=$False,Position = 0)]
        [Alias('a')]
        [ScriptBlock]$Action,

        [Parameter(Mandatory=$False)]
        [Alias('p')]
        [ScriptBlock]$Pattern,

        [Parameter(Mandatory=$False)]
        [Alias('b')]
        [ScriptBlock]$Begin,

        [Parameter(Mandatory=$False)]
        [Alias('e')]
        [ScriptBlock]$End,

        [Parameter(Mandatory=$False)]
        [Alias('f')]
        [ScriptBlock]$First,

        [Parameter(Mandatory=$False)]
        [Alias('fs')]
        [string]$Delimiter = ' ',

        [Parameter(Mandatory=$False)]
        [Alias('ifs')]
        [string] $InputDelimiter,

        [Parameter(Mandatory=$False)]
        [Alias('ofs')]
        [string] $OutputDelimiter,

        [Parameter(Mandatory=$False)]
        [switch] $AllLine,

        [Parameter(Mandatory=$False)]
        [switch] $SkipBlank,

        [Parameter(Mandatory=$False)]
        [switch] $LeaveBlank,

        [Parameter(Mandatory=$False)]
        [switch] $ParseBoolAndNull,

        [Parameter(Mandatory=$False)]
        [switch] $IgnoreConsecutiveDelimiters,

        [Parameter(Mandatory=$False)]
        [switch] $AutoSubExpression,

        [parameter( Mandatory=$False, ValueFromPipeline=$True)]
        [string[]]$Text
    )
    begin{
        # init var
        [int] $NR = 0
        # set input/output delimiter
        if ( $InputDelimiter -and $OutputDelimiter ){
            [string] $iDelim = $InputDelimiter
            [string] $oDelim = $OutputDelimiter
        } elseif ( $InputDelimiter ){
            [string] $iDelim = $InputDelimiter
            [string] $oDelim = $InputDelimiter
        } elseif ( $OutputDelimiter ){
            [string] $iDelim = $Delimiter
            [string] $oDelim = $OutputDelimiter
        } else {
            [string] $iDelim = $Delimiter
            [string] $oDelim = $Delimiter
        }
        # test is iDelim -eq empty string?
        if ($iDelim -eq ''){
            [bool] $emptyDelimiterFlag = $True
        } else {
            [bool] $emptyDelimiterFlag = $False
            if ( $IgnoreConsecutiveDelimiters ){
                $iDelim = $iDelim + '+'
            }
        }
        # private functions
        function replaceFieldStr ([string] $str){
            $str = " " + $str
            $str = escapeDollarMarkBetweenQuotes $str
            if ( $AutoSubExpression ){
                $str = $str.Replace('$0','$($self -join $oDelim)')
                $str = $str -replace('([^\\`])\$NF','${1}$($self[($self.Count-1)])')
                $str = $str -replace '([^\\`])\$(\d+)','${1}$($self[($2-1)])'
            } else {
                $str = $str.Replace('$0','$self -join $oDelim')
                $str = $str -replace('([^\\`])\$NF','${1}$self[($self.Count-1)]')
                $str = $str -replace '([^\\`])\$(\d+)','${1}$self[($2-1)]'
            }
            $str = $str.Replace('\$','$').Replace('`$','$')
            $str = $str.Trim()
            return $str
        }
        function escapeDollarMarkBetweenQuotes ([string] $str){
            # escape "$" to "\$" between single quotes
            [bool] $escapeFlag = $False
            [string[]] $strAry = $str.GetEnumerator() | ForEach-Object {
                    [string] $char = [string] $_
                    if ($char -eq "'"){
                        if ($escapeFlag -eq $False){
                            $escapeFlag = $True
                        } else {
                            $escapeFlag = $False
                        }
                    } else {
                        if (($escapeFlag) -and ($char -eq '$')){
                            $char = '\$'
                        }
                    }
                    Write-Output $char
                }
            [string] $ret = $strAry -Join ''
            return $ret
        }
        function tryParseDouble {
            param(
                [parameter(Mandatory=$True, Position=0)]
                [string] $val
            )
            [string] $val = $val.Trim()
            if ($val -match '^0[0-9]+$'){
                return $val
            }
            $double = New-Object System.Double
            if ($ParseBoolAndNull){
                switch -Exact ($val) {
                    "true"  { return $True }
                    "false" { return $False }
                    "yes"   { return $True }
                    "no"    { return $False }
                    "on"    { return $True }
                    "off"   { return $False }
                    "null"  { return $Null }
                    "nil"   { return $Null }
                    default {
                        #pass
                        }
                }
            }
            switch -Exact ($val) {
                {[Double]::TryParse($val.Replace('_',''), [ref] $double)} {
                    return $double
                }
                default {
                    return $val
                }
            }
        }
        if ($Pattern) {
            [string] $PatternBlockStr = $Pattern.ToString().Trim()
            [string] $PatternBlockStr = replaceFieldStr $PatternBlockStr
            Write-Debug "Pattern: $PatternBlockStr"
        }
        if ($Action) {
            [string] $ActionBlockStr = $Action.ToString().Trim()
            [string] $ActionBlockStr = replaceFieldStr $ActionBlockStr
            Write-Debug "Action: $ActionBlockStr"
        }
        if ($End) {
            [string] $EndBlockStr = $End.ToString().Trim()
            Write-Debug "End: $EndBlockStr"
        }
        if ($Begin) {
            [string] $BeginBlockStr = $Begin.ToString().Trim()
            Invoke-Expression -Command $BeginBlockStr -ErrorAction Stop
            Write-Debug "Begin: $BeginBlockStr"
        }
        if ( $First ){
            [bool] $isFirstLine = $True
            [string] $FirstBlockStr = $First.ToString().Trim()
            [string] $FirstBlockStr = replaceFieldStr $FirstBlockStr
            Write-Debug "First: $FirstBlockStr"
        }
    }
    process{
        # set variables
        $NR++
        [string] $line = [string] $_
        if ($line -eq ''){
            if ( $LeaveBlank ){
                Write-Output ''
                return
            }
            if ( $SkipBlank ){
                return
            } else {
                Write-Error 'Detect empty line.' -ErrorAction Stop
                return
            }
        }
        # split line by delimiter
        if ( $emptyDelimiterFlag ){
            [string[]] $tmpAry = $line.ToCharArray()
        } elseif ( $IgnoreConsecutiveDelimiters ){
            [string[]] $tmpAry = $line -split $iDelim
        } else {
            [string[]] $tmpAry = $line.Split( $iDelim )
        }
        #[int] $NF = $tmpAry.Count
        [object[]] $self = @()
        foreach ($element in $tmpAry){
            if ( [string]($element) -eq ''){
                $self += $element
            } else {
                $self += tryParseDouble $element
            }
        }
        ## Case: pattern and Action
        if (($Pattern) -and ($Action)) {
            if (Invoke-Expression -Command $PatternBlockStr -ErrorAction Stop ) {
                if ( $First -and $isFirstLine ){
                    Invoke-Expression -Command $FirstBlockStr -ErrorAction Stop
                    $isFirstLine = $False
                }
                Invoke-Expression -Command $ActionBlockStr -ErrorAction Stop
            }
            if ( $AllLine ){
                # Output all line
                $self -Join "$oDelim"
            }
            return
        }
        ## Case: pattern Only
        if ($Pattern) {
            if ($AllLine) {
                if ( $First -and $isFirstLine ){
                    Invoke-Expression -Command $FirstBlockStr -ErrorAction Stop
                    $isFirstLine = $False
                }
                Invoke-Expression -Command $PatternBlockStr -ErrorAction Stop > $Null
                $self -Join "$oDelim"
            } else {
                if (Invoke-Expression -Command $PatternBlockStr -ErrorAction Stop ) {
                    if ( $First -and $isFirstLine ){
                        Invoke-Expression -Command $FirstBlockStr -ErrorAction Stop
                        $isFirstLine = $False
                    }
                    $self -Join "$oDelim"
                }
            }
            return
        }
        ## Case: action Only
        if ($Action) {
            if ( $First -and $isFirstLine ){
                Invoke-Expression -Command $FirstBlockStr -ErrorAction Stop
                $isFirstLine = $False
            }
            Invoke-Expression -Command $ActionBlockStr -ErrorAction Stop
            if ($AllLine) {
                $self -Join "$oDelim"
            }
            return
        }
    }
    end{
        ## Invoke end block
        if ($End) {
            Invoke-Expression -Command $EndBlockStr
        }
    }
}
