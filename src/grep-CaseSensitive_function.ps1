<#
.SYNOPSIS
指定した文字列にヒットする行を出力
大文字小文字を区別する
正規表現も使用できる

grep-CaseSensitive 'word' <file1,file2,...>
grep-CaseSensitive -v 'word' <file1,file2,...>
grep-CaseSensitive -o 'word' <file1,file2,...>
grep-CaseSensitive -H 'word' <file1,file2,...>
grep-CaseSensitive -f 'file' <file1,file2,...>

cat <file1,file2,...> | grep-CaseSensitive [-v | -o] 'word'

    -v: 指定文字にヒットしない行を出力

    -o: ヒットした文字のみ出力

    -f: ファイルから検索文字列（regex）を指定

    -H: 指定文字を含む行とファイル名を出力
        ファイル名はドライブ文字を除くフルパスが出力される。
        このオプションはShift-JISテキストファイルにのみ
        適用可能.パイプライン読み込み不可.

※パイプラインを使用しない書き方（ファイルを指定する書き方）
    の方が高速.（Select-Stringを使用する）

.EXAMPLE
PS C:\>grep-CaseSensitive 'word' a.txt

説明
--------------------------------
a.txt から word という文字列を含む行を出力する


.EXAMPLE
PS C:\>cat a.txt | grep-CaseSensitive 'word'

説明
--------------------------------
a.txt から word という文字列を含む行を出力する
ファイルを直接指定する場合よりも処理速度は遅い

PS C:\>grep-CaseSensitive 'word' *.txt

説明
--------------------------------
ファイル指定はワイルドカードも使用可能.
拡張子.txt から word という文字列を含む行を出力する

PS C:\>grep-CaseSensitive 'word' a.txt,b.txt

説明
--------------------------------
カンマで区切って複数のファイル指定も可能.
a.txt と b.txt から word という文字列を含む行を出力する


.EXAMPLE
PS C:\>cat a.txt | grep-CaseSensitive -v 'word'

説明
--------------------------------
a.txt から word という文字列を含まない行を出力する


.EXAMPLE
PS C:\>cat a.txt | grep-CaseSensitive -o 'word'

説明
--------------------------------
a.txt から word という文字列だけ抽出する


.EXAMPLE
PS C:\>grep-CaseSensitive -H 'word' *.txt

説明
--------------------------------
-Hオプションでファイル名とヒット行数も出力する.
カレントディレクトリのファイルのうち、拡張子が .txtのファイルから
word という文字列を含む行とファイル名を出力する


#>
function grep-CaseSensitive {

    begin
    {

        # 変数の初期化
        $file = ''
        $chkflag = $false
        $pipflag = $false
        $defaultflag = $false
        $vflag = $false
        $hflag = $false
        $oflag = $false
        $fflag = $false

        if($args.Count -lt 1){ throw "引数が不正です." }

        # v option: パイプライン読み込みモード
        if(($args[0] -eq "-v") -and ($args.Count -eq 2)){
                $pipflag = $true
                $vflag = $true
                $chkflag = $true
                $scrptn = $args[1]
        }

        # v option: ファイル読み込みモード
        if(($args[0] -eq "-v") -and ($args.Count -eq 3)){
                $vflag = $true
                $chkflag = $true
                $scrptn = $args[1]
                $file = $args[2]
        }

        # f option: パイプライン読み込みモード
        if(($args[0] -eq "-f") -and ($args.Count -eq 2)){
                $pipflag = $true
                $fflag = $true
                $chkflag = $true
                $scrptn = Get-Content -Path $args[1] -Encoding UTF8 | Select-String -Pattern '.'
        }

        # f option: ファイル読み込みモード
        if(($args[0] -eq "-f") -and ($args.Count -eq 3)){
                $fflag = $true
                $chkflag = $true
                $scrptn = Get-Content -Path $args[1] -Encoding UTF8 | Select-String -Pattern '.'
                $file = $args[2]
        }

        # o option: パイプライン読み込みモード
        if(($args[0] -eq "-o") -and ($args.Count -eq 2)){
                $pipflag = $true
                $oflag = $true
                $chkflag = $true
                $scrptn = $args[1]
                $regex = [Regex]$scrptn
        }

        # o option: ファイル読み込みモード
        if(($args[0] -eq "-o") -and ($args.Count -eq 3)){
                $oflag = $true
                $chkflag = $true
                $scrptn = $args[1]
                $file = $args[2]
                $regex = [Regex]$scrptn
        }

        # H option: ファイル読み込みモード
        if(($args[0] -eq "-H") -and ($args.Count -eq 3)){
                $hflag = $true
                $chkflag = $true
                $scrptn = $args[1]
                $file = $args[2]
        }

        # default: パイプライン読み込みモード
        if((!$chkflag) -and ($args.Count -eq 1)){
                $pipflag = $true
                $chkflag = $true
                $defaultflag = $true
                $scrptn = $args[0]
        }

        # default: ファイル読み込みモード
        if((!$chkflag) -and ($args.Count -eq 2)){
                $chkflag = $true
                $defaultflag = $true
                $scrptn = $args[0]
                $file = $args[1]
        }

        # 不正な引数
        if(!$chkflag){throw '引数が不正です.'}

    }

    process
    {
        if(($vflag) -and ($pipflag)){
                if($_ -cnotmatch $scrptn){ Write-Output $_ }
        }
        if(($fflag) -and ($pipflag)){
                $_ | Select-String -Pattern $scrptn -CaseSensitive
        }
        if(($defaultflag) -and ($pipflag)){
                if($_ -cmatch $scrptn){ Write-Output $_ }
        }
        if(($oflag) -and ($pipflag)){
                $regex.Matches($_) | foreach{ Write-Output $_.Value }
        }
    }

    end
    {

        if(($hflag) -and (!$pipflag)){
                if($args.Count -lt 3){ throw "引数が不正です." }

                Select-String -Pattern $scrptn -Path $file -Encoding UTF8 -CaseSensitive |
                %{
                        #$p = $_.Path -Replace '^[A-Z]:\\',''
                        $p = $_.Path
                        $line = $p + ':' + [string]$_.LineNumber + ':' + [string]$_.Line
                        Write-Output $line
                }
        }

        # vオプション: ファイル読み込みモード
        if(($vflag) -and (!$pipflag)){
                Select-String -Pattern $scrptn -Path $file -NotMatch -Encoding UTF8 -CaseSensitive |
                %{ Write-Output $_.Line }
        }

        # fオプション: ファイル読み込みモード
        if(($fflag) -and (!$pipflag)){
                Select-String -Pattern $scrptn -Path $file -Encoding UTF8 -CaseSensitive |
                ForEach-Object { Write-Output $_.Line }
        }

        # oオプション: ファイル読み込みモード
        if(($oflag) -and (!$pipflag)){
                Select-String -Pattern $scrptn -Path $file -Encoding UTF8 -CaseSensitive |
                %{ Write-Output $_.Line } |
                % { $regex.Matches($_) | foreach{ Write-Output $_.Value }}
        }

        # デフォルト: ファイル読み込みモード
        if(($defaultflag) -and (!$pipflag)){
                Select-String -Pattern $scrptn -Path $file -Encoding UTF8 -CaseSensitive |
                %{ Write-Output $_.Line }
        }
    }
}
