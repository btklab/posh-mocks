<#
.SYNOPSIS

flat - Flat columns

半角スペース区切りの入力を任意列数で折り返す
引数を何も指定しなければ全行1列に整形して出力


.DESCRIPTION

inspired by:
シェルの弱点を補おう！"まさに"なCLIツール、egzact
https://qiita.com/greymd/items/3515869d9ed2a1a61a49
Qiita:greymd氏, 2016/05/12, accessed 2017/11/13

.EXAMPLE
1..9 | flat
1 2 3 4 5 6 7 8 9


.EXAMPLE
1..9 | flat 4
1 2 3 4
5 6 7 8
9

.EXAMPLE
echo "aiueo" | flat 3 -ifs "" -ofs ""
aiu
eo

#>
function flat {
    param (
        [Parameter(Mandatory=$False, Position=0)]
        [Alias('n')]
        [int] $Num,

        [Parameter(Mandatory=$False)]
        [Alias('ifs')]
        [string] $InputDelimiter = ' ',

        [Parameter(Mandatory=$False)]
        [Alias('ofs')]
        [string] $OutputDelimiter = ' ',

        [parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [string[]] $InputText
    )
    begin {
        # parse option
        if (-not $Num){
            [boolean] $flatFlag = $True
        } else {
            [boolean] $flatFlag = $False
        }
        if ($InputDelimiter -eq ''){
            [boolean] $emptyDelimiterFlag = $True
        } else {
            [boolean] $emptyDelimiterFlag = $False
        }
        # init var
        [int] $cnt = 0
        [string] $tempLine = ''
        $tempAryList = New-Object 'System.Collections.Generic.List[System.String]'
    }
    process {
        [string] $line = [string] $_
        if ($flatFlag){
            # flatten input
            $tempAryList.Add($line)
        } else {
            [string[]] $splitLine = $line -split $InputDelimiter
            if ($emptyDelimiterFlag){
                # delete first and last element in $splitLine
                $splitLine = $splitLine[1..($splitLine.Count - 2)]
            }
            foreach ($s in $splitLine){
                $cnt++
                if ($cnt -lt $Num){
                    $tempAryList.Add($s)
                } else {
                    $tempAryList.Add($s)
                    [string] $tempLine = $tempAryList.ToArray() -join $OutputDelimiter
                    Write-Output $tempLine
                    $cnt = 0
                    $tempAryList = New-Object 'System.Collections.Generic.List[System.String]'
                }
            }
        }
    }
    end {
        if ($tempAryList.ToArray().Count -gt 0){
            [string] $tempLine = $tempAryList.ToArray() -join $OutputDelimiter
            Write-Output $tempLine
        }
    }
}
