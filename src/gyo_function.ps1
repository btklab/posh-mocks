<#
.SYNOPSIS
行数のカウント

gyo [file]...

file を指定しなかった場合、
標準入力から読み込み。

file を指定した場合、
ファイル名とともに行数を出力するが、
標準入力からはデータを受け付けない点に注意。

.DESCRIPTION
-

.EXAMPLE
PS C:\>cat a.txt | gyo
a.txt の行数を出力

.EXAMPLE
PS C:\>gyo *.txt
拡張子が.txt のファイルのファイル名と
行数を出力


#>
function gyo {
    begin {
        $stdinFlag = $false
        $readFileFlag = $false
        $readRowCounter = 0

        if($args.Count -eq 0){
            # 引数なしの場合：標準入力からデータを得る
            $stdinFlag = $true
        }else{
            # 引数ありの場合:引数はすべてファイル名とみなす
            $readFileFlag = $true
            $fileArryStartCounter = 0
        }
    }
    process {
        if($stdinFlag){
            $readRowCounter++
        }
    }
    end {
        if($readFileFlag){
            for($i = $fileArryStartCounter; $i -lt $args.Count; $i++){
                $fileList = (Get-ChildItem $args[$i] | %{ $_.FullName })
                foreach($f in $fileList){
                    $fileFullPath = "$f"
                    $fileCat = (Get-Content -LiteralPath "$fileFullPath" -Encoding UTF8)
                    $fileGyoNum = [string](Get-Content -LiteralPath "$fileFullPath" -Encoding UTF8).Length
                    $dispFileName = (Split-Path -Leaf "$f")
                    # ※入力が一行だけの場合、入力行はオブジェクトでなく配列になってしまうため修正
                    if ($fileCat -eq $Null){
                        Write-Output ( [string]0 + ' ' + "$dispFileName")
                    } elseif($fileCat.GetType().Name -eq "String"){
                        Write-Output ( [string]1 + ' ' + "$dispFileName")
                    }else{
                        Write-Output ( [string]$fileGyoNum + ' ' + "$dispFileName")
                    }
                }
            }
        }else{
            Write-Output $readRowCounter
        }
    }
}

