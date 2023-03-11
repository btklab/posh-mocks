<#
.SYNOPSIS
    gyo - Count rows
    
    gyo [file]...

    If file is not specified, it is read from
    the pipeline input.

    If file is specified, the number of lines is
    outut along with the filename.

.LINK
    gyo, retu

.EXAMPLE
    1..10 | gyo
    10

.EXAMPLE
    gyo gyo*.ps1
    70 gyo_function.ps1

#>
function gyo {
    begin {
        [bool] $stdinFlag    = $False
        [bool] $readFileFlag = $False
        [int] $readRowCounter = 0

        if($args.Count -eq 0){
            # No args: get input from pipeline
            [bool] $stdinFlag = $True
        }else{
            # With args: all args are treated as file
            [bool] $readFileFlag = $True
            [int] $fileArryStartCounter = 0
        }
    }
    process {
        if($stdinFlag){ $readRowCounter++ }
    }
    end {
        if($readFileFlag){
            for($i = $fileArryStartCounter; $i -lt $args.Count; $i++){
                $fileList = (Get-ChildItem $args[$i] | ForEach-Object { $_.FullName })
                foreach($f in $fileList){
                    $fileFullPath = "$f"
                    $fileCat = (Get-Content -LiteralPath "$fileFullPath" -Encoding UTF8)
                    $fileGyoNum = (Get-Content -LiteralPath "$fileFullPath" -Encoding UTF8).Length
                    $dispFileName = (Split-Path -Leaf "$f")
                    # Fixed input rows becoming arrays
                    # instead of objects when there is only
                    # one line of input.
                    if ($fileCat -eq $Null){
                        Write-Output "0 $dispFileName"
                    } elseif($fileCat.GetType().Name -eq "String"){
                        Write-Output "1 $dispFileName"
                    }else{
                        Write-Output "$fileGyoNum $dispFileName"
                    }
                }
            }
        }else{
            Write-Output $readRowCounter
        }
    }
}
