<#
.SYNOPSIS
    image2md - Convert image filename and alt text to markdown format
    
    Recog the strings up to the first space as the image file name,
    and the strings after that as the alt text. Therefore, image
    file names should not contain spaces.
    
    Usage:
        "a.png alt text" | image2md
        ![alt text](a.png)
    
    Options:
        -Flat <int> : Specify number of columns
        -Table : Output in markdown table format
        -Option "width=100" : Specify table options
          ![alt text](a.png){width=100}
        -Step <int> : Insert a blank line after every specified number of lines
    
    convert markdowned alt text to html5:
        -Html and -Markdownify : Convert alt text to markdown using pandoc

.LINK
    md2image, md2html

.EXAMPLE
    cat a.txt
    path/to/img.png alt text
    path/to/img.png alt text
    path/to/img.png alt text
    path/to/img.png alt text
    path/to/img.png alt text
    path/to/img.png alt text
    path/to/img.png alt text


    PS > cat a.md | image2md -Table -Flat 2 -Option 'width=100'
    | image | image |
    | :---: | :---: |
    | ![alt text](path/to/img.png){width=100} | ![alt text](path/to/img.png){width=100} |
    | ![alt text](path/to/img.png){width=100} | ![alt text](path/to/img.png){width=100} |
    | ![alt text](path/to/img.png){width=100} | ![alt text](path/to/img.png){width=100} |
    | ![alt text](path/to/img.png){width=100} |  |


    PS > cat a.md | image2md -Step 2
    ![alt text](path/to/img.png)
    ![alt text](path/to/img.png)

    ![alt text](path/to/img.png)
    ![alt text](path/to/img.png)

    ![alt text](path/to/img.png)
    ![alt text](path/to/img.png)

    ![alt text](path/to/img.png)


    PS > cat a.md | image2md -Step 2 -Flat 3
    ![alt text](path/to/img.png) ![alt text](path/to/img.png) ![alt text](path/to/img.png)
    ![alt text](path/to/img.png) ![alt text](path/to/img.png) ![alt text](path/to/img.png)

    ![alt text](path/to/img.png)

#>
function image2md {
    Param(
        [parameter(Mandatory=$False)]
        [int] $Flat = 1,

        [parameter(Mandatory=$False)]
        [string] $Option,

        [parameter(Mandatory=$False)]
        [switch] $Table,

        [parameter(Mandatory=$False)]
        [switch] $Hugo,

        [parameter(Mandatory=$False)]
        [switch] $Html,

        [parameter(Mandatory=$False)]
        [switch] $Markdownify,

        [parameter(Mandatory=$False)]
        [switch] $NoTableHeader,

        [parameter(Mandatory=$False)]
        [int] $Step,

        [parameter(Mandatory=$False)]
        [string] $StepString = '',

        [parameter(Mandatory=$False,
          ValueFromPipeline=$True)]
        [string[]] $Text
    )
    begin {
        # set variables
        [int] $rowCnt = 0
        [string] $writeLine = ''
        [string[]] $flatAry = @()
        [string[]] $tabAry  = @()
        # is command exist?
        function isCommandExist ($cmd) {
          try { Get-Command $cmd -ErrorAction Stop | Out-Null
            return $True
          } catch {
            return $False
          }
        }
        function isImageLine ([string]$line){
            if($line -match '^[^ ]+\.(png|jpe?g|bmp|gif)'){
                return $True
            }
            return $False
        }
        function ReplaceLine ([string]$line){
            if ( $line -notmatch ' '){
                [string] $fname = $line
                [string] $falt  = ''
            } else {
                [string] $fname = $line -replace '^([^ ]+) (.*)$','$1'
                [string] $falt  = $line -replace '^([^ ]+) (.*)$','$2'
            }
            $fname = $fname.trim()
            $falt  = $falt.trim()
            if($Hugo){
                if ($Option){
                    [string] $md = "{{< img src=""$fname"" caption=""$falt"" $Option >}}"
                } else {
                    [string] $md = "{{< img src=""$fname"" caption=""$falt"" >}}"
                }
            } elseif ($Html){
                if (($Markdownify) -and ($falt -ne '')){
                    ## is pandoc exists?
                    if ( -not (isCommandExist "pandoc")){
                        Write-Error "install Pandoc: winget install --id JohnMacFarlane.Pandoc --source winget" -ErrorAction Stop
                    }
                    $falt = $falt `
                        | pandoc --from markdown+emoji --to html5 `
                        | ForEach-Object {$_ -replace '<p>|</p>',''}
                }
                if ($Option){
                    [string] $md = "<img src=""$fname"" alt=""$falt"" $Option />"
                } else {
                    [string] $md = "<img src=""$fname"" alt=""$falt"" />"
                }
            } else {
                [string] $md = "![$falt]($fname)"
                if ($Option){$md = $md + "{$Option}"}
            }
            return $md
        }
    }
    process {
        [int] $rowCnt = $rowCnt + 1
        [string] $line = $_
        if($Table){
            if(($rowCnt -eq 1) -and (-not $NoTableHeader)){
                1..$($Flat) | ForEach-Object {
                    $flatAry += ,"image"
                    $tabAry += ,":---:"
                }
                $writeLine = $flatAry -Join ' | '
                $writeLine = "| $writeLine |"
                Write-Output $writeLine
                $writeLine = $tabAry -Join ' | '
                $writeLine = "| $writeLine |"
                Write-Output $writeLine
                [string[]] $flatAry = @()
                [string[]] $tabAry  = @()
            }
            if ($Flat -eq 1){
                $line = ReplaceLine $line
                $writeLine = "| $line |"
                Write-Output $writeLine
            } elseif ($rowCnt % $Flat -eq 0){
                # output line
                $line = ReplaceLine $line
                $flatAry += ,$line
                $writeLine = $flatAry -Join ' | '
                $writeLine = "| $writeLine |"
                Write-Output $writeLine
                [string[]] $flatAry = @()
            }else{
                # stack array
                $line = ReplaceLine $line
                $flatAry += ,$line
            }
        } else {
            if ($Flat -eq 1){
                $writeLine = ReplaceLine $line
                Write-Output $writeLine
            } elseif ($rowCnt % $Flat -eq 0){
                # output line
                $line = ReplaceLine $line
                $flatAry += ,$line
                $writeLine = $flatAry -Join ' '
                Write-Output $writeLine
                [string[]] $flatAry = @()
            }else{
                # stack array
                $line = ReplaceLine $line
                $flatAry += ,$line
            }
        }
        if($Step){
            if(($rowCnt / $Flat) % $Step -eq 0){
                Write-Output $StepString
            }
        }
    }
    end {
        if ($flatAry){
            if($Table){
                1..$($Flat - ($rowCnt % $Flat)) | ForEach-Object {
                    $flatAry += ,""
                }
                $writeLine = $flatAry -Join ' | '
                $writeLine = "| $writeLine |"
                Write-Output $writeLine
            } else {
                $writeLine = $flatAry -Join ' '
                Write-Output $writeLine
            }
        }
    }
}
