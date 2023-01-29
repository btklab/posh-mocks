<#
.SYNOPSIS
    csv2txt - Convert CSV to SSV

    Convert Comma-Separated-Values to Space-Separated-Values

    csv2txt [-z|-NaN]
        -z : Fill blank data with zeros
        -NaN : Fill blank data with "NaN"

    LF in cells in CSV output from Excel are
    converted to "\n".

    Notes:
        - Output is space delimited
        - "\" convert to "\\"
        - LF convert to "\n"
        - Space in the data is converted to "_"
        - "_" in data is convert to "\_"
        - Empty fields are represented by "_"
    
    Structure of the input CSV file
        - Separate fields with commas
        - Put line breaks at the end of records
        - Fields with commas/double quotes/line breaks
          should always be enclosed in double quotes.
          even if these sybols are not present,
          they may be enclosed in double quotes
        - Double quotes in data should be escaped
          with consecutive double quotes like ""

.LINK
    csv2txt, json2txt

.EXAMPLE
cat a.csv | csv2txt

PS > cat a.csv | csv2txt -z

PS > cat a.csv | csv2txt -NaN

#>
function csv2txt {

    begin
    {
        if( [string] ($args[0]) -eq "-z"){
            [string] $nulldata = '0'
        }elseif( [string] ($args[0]) -eq "-NaN"){
            [string] $nulldata = 'NaN'
        }else{
            [string] $nulldata = '_'
        }

        # init var
        [int] $cnt = 0
        [string] $tmpBuf = ''
    }

    process
    {
        # Count whether the double quote is even or odd
        $strLen = $_.Length
        for($i = 0; $i -lt $strLen; $i++){
            [string] $strWord = $_[$i]
            if($strWord -eq '"'){ $cnt += 1 }
            # counting double quotes as even or odd
            # if the number of double quotes is odd,
            # convert the comma to another symbol.
            # Also, convert "\" to different symbol
            if($cnt % 2 -eq 1){
                if($strWord -eq ','){
                    [string] $addWord = '\c'
                }elseif($strWord -eq '\'){
                    [string] $addWord = '@y@y@'
                }else{
                    [string] $addWord = $strWord
                }
            }else{
                # if the number of double quotes is even
                if($strWord -eq '\'){
                    [string] $addWord = '@y@y@'
                }else{
                    [string] $addWord = $strWord
                }
            }
            $tmpBuf = [string]$tmpBuf + [string]$addWord
        }
        # if the double-quote counter is even, output,
        # otherwise read next line
        if($cnt % 2 -eq 0){

            # various string conversion
            # Remove double-quote at the beginning of a line
            $tmpBuf = $tmpBuf -Replace '^"', ''

            # Remove double-quote at the end of a line
            $tmpBuf = $tmpBuf -Replace '"$', ''

            # Convert '",' to ',' in a line
            $tmpBuf = $tmpBuf.Replace('",', ',')

            # Convert ',"' to ',' in a line
            $tmpBuf = $tmpBuf.Replace(',"', ',')

            # Replace double quote to another symbol
            $tmpBuf = $tmpBuf.Replace('""', '\d')

            # Replace underscore
            $tmpBuf = $tmpBuf.Replace('_', '\_')

            # Replace spaces
            $tmpBuf = $tmpBuf.Replace(' ', '_')

            # Replace comma at the end of lines
            $addNull = ',' + [string]$nulldata
            $tmpBuf = $tmpBuf -Replace ',$', $addNull

            # Replace comma at the beginning of lines
            $addNull = [string]$nulldata + ','
            $tmpBuf = $tmpBuf -Replace '^,', $addNull

            # Replace consecutive commas (empty data cell)
            $addNull = ',' + [string]$nulldata + ','
            $tmpBuf = $tmpBuf.Replace(',,', $addNull)
            $tmpBuf = $tmpBuf.Replace(',,', $addNull)

            # Replace reamaining commas
            $tmpBuf = $tmpBuf.Replace(',', '\s')

            # Re-converts symbols
            # \s separator
            $tmpBuf = $tmpBuf.Replace('\s', ' ')
            # \c commas
            $tmpBuf = $tmpBuf.Replace('\c', ',')
            # \d double-quotes
            $tmpBuf = $tmpBuf.Replace('\d', '"')
            # Replace "@y@y@" to "\\"
            $tmpBuf = $tmpBuf.Replace('@y@y@', '\\')
            # output
            Write-Output $tmpBuf
            $tmpBuf = ''
        }else{
            $tmpBuf = [string]$tmpBuf + '\n'
        }
    }
}
