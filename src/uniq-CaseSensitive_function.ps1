<#
.SYNOPSIS
重複行をなくし一意とする
ただし大文字小文字を区別する
事前ソート必要

uniq-CaseSensitive [-c | -d]

 -c: 重複数をカウントする

 -d: 重複している列のみ出力する


.DESCRIPTION
-

.EXAMPLE
PS C:\>cat a.txt
A 1 10
B 1 10
A 1 10
C 1 10

PS C:\>cat a.txt | sort -CaseSensitive | uniq-CaseSensitive
A 1 10
B 1 10
C 1 10

.EXAMPLE
PS C:\>cat a.txt | uniq-CaseSensitive
A 1 10
B 1 10
A 1 10
C 1 10

説明
-----------
事前ソートし忘れた場合うまく重複が削除されません。


.EXAMPLE
PS C:\>cat a.txt | sort -CaseSensitive | uniq-CaseSensitive -c
2 A 1 10
1 B 1 10
1 C 1 10

説明
-----------
重複数をカウントする


.EXAMPLE
PS C:\>cat a.txt | sort -CaseSensitive | uniq-CaseSensitive -d
A 1 10

説明
-----------
重複している行のみ出力する


#>
function uniq-CaseSensitive{

    begin
    {
        $countFlag = $false
        $chofukuFlag = $false
        if($args[0] -eq '-c'){$countFlag = $true}
        if($args[0] -eq '-d'){$chofukuFlag = $true}
        $readCounter = 0
        $uniqCounter = 0
        $lastKey = ''
    }

    process
    {
        $readCounter++
        $key = [string]$_
        if($readCounter -gt 1){
            if($countFlag){
                if("$key" -cne "$lastKey"){
                    Write-Output ([string]$uniqCounter + ' ' + $lastKey)
                    [int]$uniqCounter = 0
                }
            }elseif($chofukuFlag){
                if("$key" -cne "$lastKey"){
                    if($uniqCounter -ge 2){Write-Output $lastKey}
                    [int]$uniqCounter = 0
                }
            }else{
                if(("$key" -cne "$lastKey") -and ($readCounter -ne 1)){
                    Write-Output $lastKey
                }
            }
        }
        $lastKey = $key;
        $uniqCounter++;
    }

    end
    {
        if($countFlag){
            Write-Output ([string]$uniqCounter + ' ' + $lastKey)
        }elseif($chofukuFlag){
            if($uniqCounter -ge 2){Write-Output $lastKey}
        }else{
            Write-Output $lastKey
        }
    }
}
