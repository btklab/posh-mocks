<#
.SYNOPSIS
    filehame - Insert contents into template

    When it finds a line containing keyword from the template,
    it inserts another text file there.

    "file-hame" in Japanese means "insert-file" in English.

    If you specify a hyphen "-" in the argument, it means
    read from stdin.

    Keyword is case sensitive.

    Usage:
        filehame -l <keyword> <templateFile> <insertFile>
    
    Template example (keyword = "TEXTBODY"):
        <!DOCTYPE html>
        <html lang="ja">
        <head>
          <meta charset="UTF-8">
          <link rel="stylesheet" href="styles.css" media="screen" />
          <link rel="stylesheet" href="styles.css" media="print" />
          <meta name="viewport"
            content="width=device-width, initial-scale=1.0, maximum-scale=4.0, user-scalable=yes" />
        </head>
        <body>

        <!-- TEXTBODY -->

        </body>
        </html>

.EXAMPLE
    cat template.html
    <!DOCTYPE html>
    <html lang="ja">
    <head>
      <meta charset="UTF-8">
      <link rel="stylesheet" href="styles.css" media="screen" />
      <link rel="stylesheet" href="styles.css" media="print" />
      <meta name="viewport"
        content="width=device-width, initial-scale=1.0, maximum-scale=4.0, user-scalable=yes" />
    </head>
    <body>

    <!-- TEXTBODY -->

    </body>
    </html>


    PS > cat contents.md
    # contents

    hoge


    PS > cat contents.md | pandoc -f markdown -t html5 | filehame -l TEXTBODY template.html -
    # Meaning:
    #   Insert pandoc-converted content into the line
    #   containing the keyword "TEXTBODY" in template.html
    
    <!DOCTYPE html>
    <html lang="ja">
    <head>
      <meta charset="UTF-8">
      <link rel="stylesheet" href="styles.css" media="screen" />
      <link rel="stylesheet" href="styles.css" media="print" />
      <meta name="viewport"
        content="width=device-width, initial-scale=1.0, maximum-scale=4.0, user-scalable=yes" />
    </head>
    <body>

    <h1 id="contents">contents</h1>
    <p>hoge</p>

    </body>
    </html>

#>
function filehame {

    Param (
        [Parameter( Position=0, Mandatory=$True )]
        [Alias('l')]
        [string] $LineText,

        [Parameter( Position=1, Mandatory=$True )]
        [string] $templateFile,

        [Parameter( Position=2, Mandatory=$True )]
        [string] $insertFile,

        [parameter( ValueFromPipeline=$True )]
        [string[]] $Text
    )

    begin
    {
        ## test opt
        if(($templateFile -eq '-') -and ($insertFile -eq '-')){
            Write-Error "Could not set stdin for both template and inset." -ErrorAction Stop
        }
        ## is input from the pipeline?
        $pipeFlag = $False
        if(($templateFile -eq '-') -or ($insertFile -eq '-')){
            $pipeFlag = $True
            $textAryList = New-Object 'System.Collections.Generic.List[System.String]'
        }
    }

    process
    {
        ## set text from pipeline into List
        if($pipeFlag){ $textAryList.Add([string]$_) }
    }

    end
    {
        ## set list as array
        if($pipeFlag){
            [string[]]$textAry = @()
            $textAry = $textAryList.ToArray()
        }
        ## pattern1
        if( ($templateFile -ne '-') -and ($insertFile -ne '-') ){
            ## read first half of templateFile
            $readFlag = $True
            Get-Content -LiteralPath $templateFile -Encoding UTF8 `
                | ForEach-Object {
                    if( "$_".Contains($LineText) ){ $readFlag = $False }
                    if( $readFlag ){ Write-Output $_ }
                }
            ## read all of insertFile
            if ( $readFlag ){ Write-Error "Could not find $LineText" -ErrorAction Stop}
            Get-Content -LiteralPath $insertFile -Encoding UTF8 `
                | ForEach-Object { Write-Output $_ }
            ## read last half of templateFile
            $readFlag = $False
            Get-Content -LiteralPath $templateFile -Encoding UTF8 `
                | ForEach-Object {
                    if( $readFlag ){ Write-Output $_ }
                    if( "$_".Contains($LineText) ){ $readFlag = $True }
                }
            return
        }
        ## pattern2
        if( ($templateFile -ne '-') -and ($insertFile -eq '-') ){
            ## read first half of templateFile
            $readFlag = $True
            Get-Content -LiteralPath $templateFile -Encoding UTF8 `
                | ForEach-Object {
                    if( "$_".Contains($LineText) ){ $readFlag = $False }
                    if( $readFlag ){ Write-Output $_ }
                }
            ## read all of insertFile
            if ( $readFlag ){ Write-Error "Could not find $LineText" -ErrorAction Stop}
            $textAry | ForEach-Object { Write-Output $_ }
            ## read last half of templateFile
            $readFlag = $False
            Get-Content -LiteralPath $templateFile -Encoding UTF8 `
                | ForEach-Object {
                    if( $readFlag ){ Write-Output $_ }
                    if( "$_".Contains($LineText) ){ $readFlag = $True }
                }
                return
        }
        ## pattern3
        if( ($templateFile -eq '-') -and ($insertFile -ne '-') ){
            ## read first half of templateFile
            $readFlag = $True
            $textAry `
                | ForEach-Object {
                    if( "$_".Contains($LineText) ){ $readFlag = $False }
                    if( $readFlag ){ Write-Output $_ }
                }
            ## read all of insertFile
            if ( $readFlag ){ Write-Error "Could not find $LineText" -ErrorAction Stop}
            Get-Content -LiteralPath $insertFile -Encoding UTF8 `
                | ForEach-Object { Write-Output $_ }
            ## read last half of templateFile
            $readFlag = $False
            $textAry `
                | ForEach-Object {
                  if( $readFlag ){ Write-Output $_ }
                  if( "$_".Contains($LineText) ){ $readFlag = $True }
                }

        }
    }
}
