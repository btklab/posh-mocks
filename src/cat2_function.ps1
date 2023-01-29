<#
.SYNOPSIS
    cat2 - Concatenate files and print on the standard output

    cat2 file2 file2...

    cat2 reads and outputs the specified text files in order.
    When read multiple files, use spaces instead of commas
    as delimiter. (in Get-Content commandlet, arguments are
    delimited by commas.)

    Wildcard (*) can be used, but files are read in
    lexicographical order.

    By using hyphen (-), read form stdin.

.EXAMPLE
echo "hoge" | cat2 b.txt a.txt -

.EXAMPLE
cat2 *.txt

#>
function cat2 {
    # test args
    if($args.Count -lt 1){
        Write-Error "Invalid args." -ErrorAction Stop
    }
    # get content of each files
    foreach ($f in $args){
        if($f -eq '-'){
            $input
        }else{
            $fileList = (Get-ChildItem -Path "$f" | ForEach-Object { $_.FullName })
            foreach ($f in $fileList){
                Get-Content -Path "$f" -Encoding UTF8
            }
        }
    }
}
