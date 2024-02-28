<#
.SYNOPSIS
    sed-i - Edit  file in place

    Pattern match replace and overwrite files at onece.

    Files are not overwritten unless "-Execute" switch is
    specified. This is to prevent unexpected replacements.

    Create a backup file (.bak) by default unless specified
    "-DoNotCreateBackup" switch. (so the original file can be restored
    from the .bak file)

    Usage:
        sed-i 's;abc;def;g' file -Execute
            equivalent to sed -i.bak 's;abc;def;g' file in GNU sed
        
        sed-i 's;abc;def;g' file -Execute -DoNotCreateBackup
            equivalent to sed -i 's;abc;def;g' file in GNU sed
            
        sed-i 's;<before>;<after>;g' file [-Execute] [-DoNotCreateBackup|-OverwriteBackup]
        sed-i 's;<before>;<after>;g','s;<before>;<after>;g',... file
    
    Options:
        -Patterns : specify patterns using regex
            - Multiple statements can be specified by separate with commas.
        -Execute : execute replace and overwrite files
        -DoNotCreateBackup : do not create backup
        -OverWriteBackup : overwrite .bak file even if there is already exist.
        -Encoding : UTF-8 (default)
        -MatchFileOnly : outputs only files to be replaced during dry run
    
    Hint:
        Below is a roughly equibalent PowerShell scripts without using
        this function. The point is to wrap Get-Content commandlet
        in parentheses.

        PS > (Get-Content file) | foreach { $_ -replace "pattern","replace" } | Set-Content file

        another one:

        PS > $Target = "test.txt"
        PS > $ENCODING = "UTF8"
        PS > (Get-Content $Target -Encoding $ENCODING) `
                | ForEach-Object { $_ -replace "http:","https:" } `
                | Set-Content $Target -Encoding $ENCODING
        
        If you do not enclose Get-Content process in parentheses,
        process will grap it and will not be able to overwrite the
        file. This is because the file reading of Get-Content is
        lazily evaluated line by line due to pipeline processing.

        Parentheses control the order of evaluation of expressins,
        but they can also be used to evaluate expressions immediately
        without lazy evaluation. If they used before the pipeline,
        it reads all the contents of the file and converts it to
        String type before passin it to the next prcess. This allows
        two commnands (Get-Content and Set-Content) to refer to the
        same file.

    thanks:
        https://tex2e.github.io/blog/powershell/sed

.LINK
    sed, sed-i

.PARAMETER Patterns
    set pattern using regex.
    Multiple statements can be specified by
    separate with commas.

        's;hoge;fuga;g'
        's;hoge;fuga;g','s;f(uga);h$1;'

.PARAMETER Execute
    Execute replacement

.PARAMETER DoNotCreateBackup
    Overwrite original files without creation of .bak files.

.PARAMETER SkipError
    Continue processing even if an error occurs

.PARAMETER OverWriteBackup
    overwrite .bak file even if there is already exist.
    By defalut, if .bak file exists, processing stops
    with an error.

.PARAMETER BackupExtension
    Specify backup file extension.
    ".bak" by default.

.EXAMPLE
    "abcde" > a.txt; sed-i 's;abc;def;g' a.txt
    ifile: ./a.txt
    ofile: ./a.txt.bak
    defde

.EXAMPLE
    ls *.txt
    Mode                 LastWriteTime         Length Name
    ----                 -------------         ------ ----
    -a---          2022/09/29    21:41              7 a.txt
    -a---          2022/09/29    21:41              7 b.txt

    PS> ls *.txt | %{ sed-i 's;abc;def;g' $_.FullName }
    ifile: a.txt
    ofile: a.txt.bak
    defde

.EXAMPLE
    # Replace and overwrite original file and create backup
    ls *.txt | %{ sed-i 's;abc;hoge;g' $_.FullName -Execute }
    a.txt > a.txt.bak
    b.txt > b.txt.bak

    # Replace and overwrite original file and *do not* create backup
    ls *.txt | %{ sed-i 's;abc;hoge;g' $_.FullName -Execute -DoNotCreateBackup }
    a.txt > a.txt
    b.txt > b.txt

#>
function sed-i {
    Param(
        [Parameter(Position=0,Mandatory=$True)]
        [Alias('p')]
        [string[]] $Patterns,

        [Parameter(Position=1,Mandatory=$True)]
        [Alias('t')]
        [string] $Target,

        [Parameter(Mandatory=$False)]
        [Alias('e')]
        [switch] $Execute,

        [Parameter(Mandatory=$False)]
        [switch] $SkipError,

        [Parameter(Mandatory=$False)]
        [string] $BackupExtension = '.bak',

        [Parameter(Mandatory=$False)]
        [switch] $OverWriteBackup,

        [Parameter(Mandatory=$False)]
        [switch] $DoNotCreateBackup,

        [Parameter(Mandatory=$False)]
        [switch] $MatchFileOnly,

        [Parameter(Mandatory=$False)]
        [string] $Encoding = 'utf8'
    )
    # test path
    if (-not $SkipError){
        if (-not (Test-Path -LiteralPath "$Target")){
            Write-Error "$Target is not exists." -ErrorAction Stop
        }
    }
    if ($DoNotCreateBackup){
        [string] $BackupTarget = "$Target"
    } else {
        [string] $BackupTarget = "$Target" + "$BackupExtension"
    }

    # private function
    function execSed {
        Param(
            [Parameter(Position=0,Mandatory=$True)]
            [string] $Patn,
            [Parameter(Position=1,Mandatory=$True)]
            [string] $Line
        )
        ## test replace option
        [string] $OptStr = ($Patn).Substring(0,1)
        if( ($OptStr -ne "s") -and `
            ($OptStr -ne "p") -and `
            ($OptStr -ne "d") ){
            Write-Error "Invalid args." -ErrorAction Stop
        }
        ## get separator string (2nd letter from the left)
        [string] $SepStr = ($Patn).Substring(1,1)
        # get regex pattern
        [string[]] $regexstr = ($Patn).Split("$SepStr")
        if($regexstr.Count -ne 4){
            Write-Error "Invalid args." -ErrorAction Stop
        }
        [regex] $srcptn = $regexstr[1]
        [regex] $repptn = $regexstr[2]
        if( $srcptn -eq ''){
            Write-Error "Invalid args" -ErrorAction Stop
        }
        # parse flags
        if( [string]($regexstr[0]) -eq 's' ){
            [bool] $sflag = $True
        }
        if( [string]($regexstr[0]) -eq 'p' ){
            [bool] $pflag = $True
            [bool] $pReadFlag = $False
        }
        if( [string]($regexstr[0]) -eq 'd' ){
            [bool] $dflag = $True
            [bool] $pReadFlag = $True
        }
        if($regexstr[3] -like 'g'){
            [bool] $gflag = $True
        }else{
            [regex] $regex = [regex]$srcptn        
        }
        # main
        if($sflag){
            # s flag : replacement mode
            if($gflag){
                [string] $writeLine = $Line -replace "$srcptn", "$repptn"
            }else{
                [string] $writeLine = $regex.Replace("$Line", "$repptn", 1)
            }
            Write-Output $writeLine
        }elseif($pflag){
            # p flag : print only matched line
            if($Line -match "$srcptn" ){$pReadFlag = $True}
            if($pReadFlag){Write-Output $Line}
            if($Line -match "$repptn" ){$pReadFlag = $False}
        }elseif($dflag){
            # d flag : delete mode
            if($Line -match "$srcptn" ){$pReadFlag = $False}
            if($pReadFlag){Write-Output $Line}
            if($Line -match "$repptn" ){$pReadFlag = $True}
        }
    }
    function getPatn {
        Param(
            [Parameter(Position=0,Mandatory=$True)]
            [string] $Patn
        )
        ## test replace option
        [string] $OptStr = ($Patn).Substring(0,1)
        if( ($OptStr -ne "s") -and `
            ($OptStr -ne "p") -and `
            ($OptStr -ne "d") ){
            Write-Error "Invalid args." -ErrorAction Stop
        }
        ## get separator string (2nd letter from the left)
        [string] $SepStr = ($Patn).Substring(1,1)
        # get regex pattern
        [string[]] $regexstr = ($Patn).Split("$SepStr")
        if($regexstr.Count -ne 4){
            Write-Error "Invalid args." -ErrorAction Stop
        }
        [string] $srcptn = $regexstr[1]
        [string] $repptn = $regexstr[2]
        if( $srcptn -eq '' ){
            Write-Error "Invalid args." -ErrorAction Stop
        }
        return $srcptn
    }

    # main
    if ($Execute){
        # exec sed -i
        if (-not $DoNotCreateBackup){
            if (-not $OverWriteBackup){
                if (Test-Path -LiteralPath "$BackupTarget"){
                    $bfile = "$BackupTarget".Replace('\','/')
                    Write-Error """$bfile"" is already exists." -ErrorAction Stop
                }
            }
            Copy-Item -LiteralPath "$Target" -Destination "$BackupTarget" -Force
        }
        $tfile = "$Target".Replace('\','/')
        $bfile = "$BackupTarget".Replace('\','/')
        Write-Host "$tfile > $bfile"
        (Get-Content -LiteralPath "$Target" -Encoding $Encoding) `
            | ForEach-Object {
                [string] $line = [string] $_
                if ($line -notmatch '^$'){
                    foreach ($patn in $Patterns){
                        $line = execSed -Patn "$Patn" -Line "$line"
                    }
                }
                Write-Output "$line"
            } `
            | Set-Content -LiteralPath "$Target" -Encoding $Encoding
    } else {
        if ($MatchFileOnly){
            # output match file only
            [bool] $testFlag = $False
            foreach ($patn in $Patterns){
                [regex] $p = getPatn "$patn"
                $tmpVar = Select-String -Pattern "$p" -LiteralPath "$Target"
                if ($tmpVar -eq $Null){ $testFlag = $True }
            }
            if ($testFlag){ Write-Output "$($Target.Replace('\','/'))" }
        } else {
            Write-Host "ifile: ""$($Target.Replace('\','/'))""" -ForegroundColor Yellow
            Write-Host "ofile: ""$($BackupTarget.Replace('\','/'))""" -ForegroundColor Yellow
            # dry run
            (Get-Content -LiteralPath "$Target" -Encoding $Encoding) `
                | ForEach-Object {
                    [string] $line = [string] $_
                    if ($line -notmatch '^$'){
                        foreach ($patn in $Patterns){
                            $line = execSed -Patn "$Patn" -Line "$line"
                        }
                    }
                    Write-Output "$line"
                }
            Write-Output ''
        }
    }
}
