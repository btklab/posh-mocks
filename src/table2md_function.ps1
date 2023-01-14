<#
.SYNOPSIS

table2md - Convert tab and csv delimited tables to markdown table format

tab区切り・csv区切りの表をmarkdown形式に変換する
標準入力、第一引数で何も指定ない場合はクリップボードの値を使おうとする。

csv,tsvはヘッダありデータのみ受付。
デフォルトでタブ区切り(-Delimiter "\t")

エクセル表を直接コピーして変換する用途を想定している。
ただしセル内改行やセル結合した入力はうまく変換できない。

  - csv,tsvは数字・ハイフン・ドットだけのセルは自動で右寄せ
  - 単位つきcsvカラム（列）も、-Units unit1,unit2,...指定で右寄せ
  - 半角スペース+kg,ml,CFU,RLUなどいくつかの単位は標準で右寄せ。

用法: cat a.csv | table2md -Delimiter "," -Caption "titlle"

関連: md2import, table2md, md2tex, md2html

.EXAMPLE
cat a.tsv | table2md -Caption "title"

Table: title

|sepal_length|sepal_width|petal_length|petal_width|species|
|---:|---:|---:|---:|:---|
|5.1|3.5|1.4|0.2|setosa|
|4.9|3.0|1.4|0.2|setosa|
|4.7|3.2|1.3|0.2|setosa|
|4.6|3.1|1.5|0.2|setosa|
|5.0|3.6|1.4|0.2|setosa|


.EXAMPLE
cat a.tsv | table2md -Units "CFU","kg" | head -n 15

単位つきcsvカラム（列）は、-Units unit-name1,unit-name2,... 指定で右寄せ

|sepal_length|sepal_width|petal_length|petal_width|species|
|---:|---:|---:|---:|:---|
|5.1|3.5 CFU|1.4 kg|0.2|setosa|
|4.9|3.0 CFU|1.4 kg|0.2|setosa|
|4.7|3.2 CFU|1.3 kg|0.2|setosa|
|4.6|3.1 CFU|1.5 kg|0.2|setosa|
|5.0|3.6 CFU|1.4 kg|0.2|setosa|

#>
function table2md {
    Param(
        [parameter(Mandatory=$False)]
        [string[]]$Units,

        [parameter(Mandatory=$False)]
        [string[]]$DefaultUnits = @(" kg"," g"," cm"," mm"," m"," CFU"," RLU"," ml"," L"," %"," ％"),

        [Parameter(Mandatory=$False)]
        [ValidateSet( " ", ",", "\t")]
        [Alias("d")]
        [string] $Delimiter = "\t",

        [Parameter(Mandatory=$False)]
        [Alias("c")]
        [string] $Caption,

        [parameter(Mandatory=$False,
          ValueFromPipeline=$true)]
        [string[]]$Text
    )
    # private functions
    function isNumeric ($token){
        $double = New-Object System.Double
        if ([Double]::TryParse($token.ToString().Replace('"',''), [ref]$double)) {
            return $True
        } else {
            return $False
        }
    }
    function isNumericAndUnit ($val){
        $uflag = $False
        if($Units){
            foreach($uni in $Units){
                [regex]$reg = $uni + '$'
                if($val -match $reg){
                    $uflag = $True
                }
            }
        }
        return $uflag
    }
    function isNumericAndDefaultUnit ($val){
        $uflag = $False
        if($DefaultUnits){
            foreach($uni in $DefaultUnits){
                [regex]$reg = $uni + '$'
                if($val -match $reg){
                  $uflag = $True
                }
            }
        }
        return $uflag
    }
    function parseTable {
        Param ( [string[]]$readLines)
        [string[]]$retAry = @()
        ## set option (e.g. caption="caption")
        if($Caption){
             $retAry += ,"Table: $Caption"
             $retAry += ,"" }
        ## replace delimiter to pipe
        $rcnt = 0
        foreach ($csvLine in $readLines) {
            $rcnt++
            if($rcnt -eq 2){
                ## align right if colitem is numeric
                $csvColHeader = ''
                $csvColAry = $csvLine -split "$Delimiter"
                foreach ($csvCol in $csvColAry){
                    $csvCol = $csvCol.Trim()
                    if(isNumeric $csvCol){
                        ## numeric
                        $csvColHeader += "| ---: "
                    }elseif(isNumericAndUnit $csvCol){
                        ## numeric and unit
                        $csvColHeader += "| ---: "
                    }elseif(isNumericAndDefaultUnit $csvCol){
                        ## numeric and unit
                        $csvColHeader += "| ---: "
                    }else{
                        ## strings
                        $csvColHeader += "| :--- "
                    }
                }
                $retAry += ,$($csvColHeader + "|")
            }
            $csvLine = $csvLine.Replace('"','')
            $csvLine = $csvLine -replace "$Delimiter",' | '
            $csvLine = $csvLine -replace '^','| '
            $csvLine = $csvLine -replace '$',' |'
            $retAry += ,$csvLine
        }
        return $retAry
    }
    $readListHeader = New-Object 'System.Collections.Generic.List[System.String]'
    $readList       = New-Object 'System.Collections.Generic.List[System.String]'
    [bool] $headerFlag = $False
    [bool] $tableFlag  = $False
    if ($input.Count -ne 0){
      [string[]] $inAry = $input
    } else {
      [string[]] $inAry = Get-ClipBoard
    }
    foreach ($line in $inAry){
        if ($line -match "$Delimiter"){
            $tableFlag = $True
        }
        if (-not $tableFlag){
            $headerFlag = $True
            $readListHeader.Add($line)
        } else {
          if ($line -ne ''){
            $readList.Add($line)
          }
        }
    }
    ## Output header
    if ($headerFlag){
        [string[]]$readHeaders = @()
        $readHeaders = $readListHeader.ToArray()
        foreach ($rHeader in $readHeaders){
          Write-Output $rHeader
        }
    }
    ## Output markdown table
    if ($tableFlag){
        [string[]]$readLines = @()
        $readLines = $readList.ToArray()
        parseTable $readLines
    }
}
