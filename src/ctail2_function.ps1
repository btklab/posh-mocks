<#
.SYNOPSIS
    ctail2 - Cut the last part of files

    Cut the last lines of input for the
    specified number of lines.

    Cut last one line by default.
    
    ctail2 [-n num] [file]...

    If no file is specified,
    read from pipeline input.

    If file is specified,
    do not accept input from pipline.

.LINK
    head, tail, chead, ctail, ctail2

.EXAMPLE
1..5 | ctail2
1
2
3
4

1..5 | ctail2 -n 2
1
2
3

#>
function ctail2 {

    [int]  $readRowCounter = 0
    [bool] $stdinFlag      = $false
    [bool] $readFileFlag   = $false
    [bool] $setNumFlag     = $false
    [bool] $oldVersionFlag = $false

    # test powershell version. because
    # Get-Content <file> -Head <n> is available
    # since v5.0
    $ver = [int]$PSVersionTable.PSVersion.Major
    if($ver -le 2){
        $oldVersionFlag = $true
    }
    # get input source and get number of cut lines
    if($args.Count -eq 0){
        # no args = get data from pipline
        $stdinFlag = $true
        $cutRowNum = 1
    }elseif( [string] ($args[0]) -eq '-n'){
        # with number of lines specified
        if($args.Count -lt 2){
            Write-Error "Insufficient args." -ErrorAction Stop}
        $setNumFlag = $true
        $cutRowNum = [int] ($args[1])
    }else{
        # if not -n option, all args are treated as file names
        $readFileFlag = $true
        $cutRowNum = 1
        $fileArryStartCounter = 0
    }
    # parse -n option
    if($setNumFlag){
        if($args.Count -eq 2){
            # if args.count -eq 2, get data from pipline
            $stdinFlag = $true
        }else{
            # if args.count -gt 2, the 3rd and subsequet
            # args are treated as file names
            $readFileFlag = $true
            $fileArryStartCounter = 2
        }
    }
    if($stdinFlag){
        $inputData = $input | ForEach-Object { $_ }
        $fileGyoNum = $inputData.Length - 1 - $cutRowNum
        if($fileGyoNum -ge 0){$inputData[0..$fileGyoNum]}
    }
    if($readFileFlag){
        for($i = $fileArryStartCounter; $i -lt $args.Count; $i++){
            $fileList = (Get-ChildItem -Path $args[$i] `
                | ForEach-Object { $_.FullName })
            foreach($f in $fileList){
                $fileFullPath = "$f"
                $fileGyoNum = (Get-Content -LiteralPath "$fileFullPath" -Encoding UTF8).Length - 1 - $cutRowNum
                if($fileGyoNum -ge 0){(Get-Content -LiteralPath "$fileFullPath" -Encoding UTF8)[0..$fileGyoNum]}
            }
        }
    }
}
