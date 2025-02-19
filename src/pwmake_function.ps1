<#
.SYNOPSIS
    pwmake - Pwsh implementation of GNU make command

    Read and execute Makefile in current directory.
    
    Usage:
        - man2 pwmake
        - pwmake (find and execute Makefile in the current directory)
        - pwmake -f path/to/Makefile (specify external Makefile path)
        - pwmake -Help (get help comment written at the end of each target line)
        - pwmake -DryRun
        - pwmake -Param "hoge"
        - pwmake -Params "hoge", "fuga"

    Makefile minimal examples:

        ```Makefile
        all: ## do nothing
            echo "hoge"
        ```

        ```Makefile
        file := index.md

        (dot)PHONY: all
        all: ${file} ## echo filename
            echo ${file}
            # $param is predifined [string] variable
            echo $param
            # $params is also predifined [string[]] variable
            echo $params
            echo $params[0]
        ```

    Execution examples:

        ```powershell
        pwmake
        pwmake -f ./path/to/the/Makefile
        pwmake -Help
        pwmake -DryRun
        pwmake -Param "hoge"             # set predefine variable string
        pwmake -Params "hoge", "fuga"    # set predefine variable string array
        pwmake -Variables "file=main.md" # override variable
        ```

    Note:
        Only the following automatic variables are impremented:
            - $PSScriptRoot : Makefile directory path
            - $@ : Target file name
            - $< : The name of the first dependent file
            - $^ : Names of all dependent file
            - %.ext : Replace with a string with the extension removed
                  from the target name. Only target line can be used.

        ```Makefile
        # '%' example:
        %.tex: %.md
            cat $< | md2html > $@
        ```

        ```Makefile
        root := $PSScriptRoot/args
        all:
            echo $PSScriptRoot
            echo $PSScriptRoot/hoge
            echo ${root}
        ```

    Detail:
        - Makefile format roughly follows GNU make
            - but spaces at the beginning of the line are
              accepted with Tab or Space
            - to define variables, use ${} instead of $()
            - if @() is used, it is interpreted as a Subexpression
              operator (described later)
        - If no target is pecified in args, the first target is executed.
        - Since it operates in the current process, dot sourcing functions
          read in current process can also be described in Makefile.
        - If the file path specified in Makefile is not an absolute
          path, it is regarded as a relative path.
        - [-n|-DryRun] switch available.
            - [-toposort] switch show Makefile dependencies.
        - Comment with "#"
            - only the target line and Variable declaration line(a line
              that does not start with a blank space)) can be commented
              at the end of the line.
                - comment at the end of command line is unavailable, but
                  using the "-DeleteCommentEndOfCommandLine" switch forces
                  delete comment from the "#" sign to the end of the line.
            - end-of-line commnent not allowed in command line.
            - do not comment out if the rightmost character of the comment
              line is double-quote or single-quote. for example, following
              command interpreted as "#" in a strings.
                - "# this is not a comment"
            - but also following is not considered a comment. this is
              unexpected result.
                - key = val ## note grep "hoge"
            - Any line starting with whitespaces and "#" is treated as a
              comment line regardress of the rightmost character.
            - The root directory of the relative path written in the Makefile is
              where the pwmake command was executed.
            - "-f <file>" read external Makefile.
                - the root directory of relative path in the external Makefile
                  is the Makefile path.
            
        Commentout example:
            
            home := $($HOME) ## comment

            target: deps  ## comment
                command \
                    | sed 's;^#;;' \
                    #| grep -v 'hoge'  <-- allowed comment out
                    | grep -v 'hoge' ## notice!!  <-- not allowed (use -DeleteCommentEndOfCommandLine)
                    > a.md
        
    Tips:
        If you put "## comment..." at the end of each target line
        in Makefile, you can get the comment as help message for
        each target with pwmake -Help [-f MakefilePath]

            ```Makefile
            target: [dep dep ...] ## this is help message
            ```

            ```powershell
            PS> pwmake -Help
            ##
            ## target synopsis
            ## ------ --------
            ## help   help message
            ## new    create directory and set skeleton files
            ```
            
    Note:
        - Variables can be declared between the first line and the line
          containing colon ":"
        - Lines containing a colon ":" are considered target lines, and
          all other lines that beginning with whitespaces are command lines.
        - Do not include spaces in file path and target nemes.
        - Command lines are preceded by one or more spaces or tabs.
        - If "@" is added to the begining of the command line, the command
          line will not be echoed to the output.
        - Use ${var} when using the declared variables. Do not use @(var).
        - but $(powershell-command) can be used for the value to be
          assigned to the variable. for example,
            - DATE := $((Get-Date).ToString('yyyy-MM-dd'))
                - assigns with expands the right side
            - DATE := ${(Get-Date).ToString('yyyy-MM-dd')}
                - assigns without expanding the right side
            - DATE  = $((Get-Date).ToString('yyyy-MM-dd'))
                - assigns without expanding the right side
            - DATE  = ${(Get-Date).ToString('yyyy-MM-dd')}
                - assigns without expanding the right side
            - Note: except for the first example, variables are expanded at runtime.
        - Only one shell-command is accepted per line when assigning variables
        - Shell variable assignment foo := $(Get-Date).ToString('yyyy-MM-dd')
            - executes the shell before assigning to the variable and store it in
              the variable.
            - executes the shell when it is used by assigning it as an expression.
            - if a variable assigned with "=" is assigned to another variable,
              the expression is assigned to that variable with either "=" or ":=".
        - If there is no paticular reason, it may be easier to understand variables
          by immediately evaluating them with ":=", such as vat := str, var = $(),
          and then assigning them.
        - Variables that are evaluated when used, such as var = $(), can behave in
          unexpected ways unless you understand them well.
        - Shell variable assignment foo := Get-Date assigns as a simple strings.
          If the character string on the right side can be interpreted as a
          powershell command, it may be executed when used line foo = $(Get-Command).
          However, it is safer to wrap powershell commands in $().
        
        - The linefeed escape character is following:
            - backslash
            - backquote
            - pipeline (vertical bar)

    references:

        - https://www.gnu.org/software/make/
        - https://www.oreilly.co.jp/books/4873112699/

.LINK
    toposort, pwmake

.EXAMPLE
    # Makefile example1: simple Makefile

    ```Makefile
    .PHONY: all
    all: hoge.txt

    hoge.txt: log.txt
        1..10 | grep 10 >> hoge.txt

    log.txt:
        (Get-Date).ToString('yyyy-MM-dd HH:mm:ss') | sed 's;2022;2000;' | md2html >> log.txt
    ```

.EXAMPLE
    # Get help of each task and DryRun Makefile
    PS > cat Makefile

    ```Makefile
    # use uplatex
    file    := a
    texfile := ${file}.tex
    dvifile := ${file}.dvi
    pdffile := ${file}.pdf
    date    := $((Get-Date).ToString('yyyy-MM-dd (ddd) HH:mm:ss'))

    .PHONY: all
    all: ${pdffile} ## Generate pdf file and open.
        @echo ${date}

    ${pdffile}: ${dvifile} ## Generate pdf file from dvi file.
        dvipdfmx -o $@ $<

    ${dvifile}: ${texfile} ## Generate dvi file from tex file.
        uplatex $<
        uplatex $<

    .PHONY: clean
    clean: ## Remove cache files.
        Remove-Item -Path *.aux,*.dvi,*.log -Force
    ```

    # Get help of each task
    PS > pwmake -f Makefile -Help
    PS > pwmake -Help

    target synopsis
    ------ --------
    all    Generate pdf file and open.
    a.pdf  Generate pdf file from dvi file.
    a.dvi  Generate dvi file from tex file.
    clean  Remove cache files.

    # DryRun
    PS > pwmake -DryRun
    ######## override args ##########
    None

    ######## argblock ##########
    file=a
    texfile=a.tex
    dvifile=a.dvi
    pdffile=a.pdf
    date=2023-01-15 (Sun) 10:26:09

    ######## phonies ##########
    all
    clean

    ######## comBlock ##########
    all: a.pdf
     @echo 2023-01-15 (Sun) 10:26:09

    a.pdf: a.dvi
     dvipdfmx -o $@ $<

    a.dvi: a.tex
     uplatex $<
     uplatex $<

    clean:
     Remove-Item -Path *.aux,*.dvi,*.log -Force

    ######## topological sorted target lines ##########
    a.tex
    a.dvi
    a.pdf
    all

    ######## topological sorted command lines ##########
    uplatex a.tex
    uplatex a.tex
    dvipdfmx -o a.pdf a.dvi
    @echo 2023-01-15 (Sun) 10:26:09

    ######## execute commands ##########
    uplatex a.tex
    uplatex a.tex
    dvipdfmx -o a.pdf a.dvi
    @echo 2023-01-15 (Sun) 10:26:09


    # Processing stops when a run-time error occurs
    PS > pwmake
    > uplatex a.tex
    pwmake: The term 'uplatex' is not recognized as a name of a cmdlet, function, script file, or executable program.
    Check the spelling of the name, or if a path was included, verify that the path is correct and try again.

.EXAMPLE
    # use predefined vaiable: $PSScriptRoot
    # This gets the parent folder path of the Make file.
    PS > cat Makefile

    ```Makefile
    root := $PSScriptRoot/args
    all:
        echo $PSScriptRoot
        echo $PSScriptRoot/hoge
        echo ${root}
    ```

    PS> pwmake -f ./Makefile
        C:/Users/btklab/cms/
        C:/Users/btklab/cms/hoge
        C:/Users/btklab/cms/args

.EXAMPLE
    # clone posh-source to posh-mocks
    PS > cat Makefile

    ```Makefile
    home := $($HOME)
    pwshdir  := ${home}\cms\bin\posh-source
    poshmock := ${home}\cms\bin\posh-mocks

    .PHONY: all
    all: pwsh ## update all

    .PHONY: pwsh
    pwsh: ${pwshdir} ${poshmock} ## update pwsh scripts
        @Push-Location -LiteralPath "${pwshdir}\"
        Copy-Item -LiteralPath \
            ./CHANGELOG.md, \
            ./README.md \
            -Destination "${poshmock}\"
        Set-Location -LiteralPath "src"
        Copy-Item -LiteralPath \
            ./self_function.ps1, \
            ./delf_function.ps1, \
            ./sm2_function.ps1, \
            ./man2_function.ps1 \ ## Note ! do not use comma
            -Destination "${poshmock}\src\"
        @Pop-Location
        @if ( -not (Test-Path -LiteralPath "${pwshdir}\img\") ) { Write-Error "src is not exists: ""${pwshdir}\img\""" -ErrorAction Stop }
        @if ( -not (Test-Path -LiteralPath "${poshmock}\img\") ) { Write-Error "dst is not exists: ""${poshmock}\img\""" -ErrorAction Stop }
        Robocopy "${pwshdir}\img\" "${poshmock}\img\" /MIR /XA:SH /R:0 /W:1 /COPY:DAT /DCOPY:DT /UNILOG:NUL /TEE
        Robocopy "${pwshdir}\.github\" "${poshmock}\.github\" /MIR /XA:SH /R:0 /W:1 /COPY:DAT /DCOPY:DT /UNILOG:NUL /TEE
        Robocopy "${pwshdir}\tests\" "${poshmock}\tests\" /MIR /XA:SH /R:0 /W:1 /COPY:DAT /DCOPY:DT /UNILOG:NUL /TEE
    ```

.EXAMPLE
    # Rename extension of script files and Zip archive
    PS > pwmake -f ~/Documents/Makefile -Help

    target synopsis
    ------ --------
    all    Add ".txt" to the extension of the script file and Zip archive
    clean  Remove "*.txt" items in Documents directory

    # Show Makefile
    PS > cat ~/Documents/Makefile
    documentdir := ~/Documents

    .PHONY: all
    all: ## Add ".txt" to the extension of the script file and Zip archive
        ls -Path \
            ${documentdir}/*.ps1 \
            , ${documentdir}/*.py \
            , ${documentdir}/*.R \
            , ${documentdir}/*.yaml \
            , ${documentdir}/*.Makefile \
            , ${documentdir}/*.md \
            , ${documentdir}/*.Rmd \
            , ${documentdir}/*.qmd \
            , ${documentdir}/*.bat \
            , ${documentdir}/*.cmd \
            , ${documentdir}/*.vbs \
            , ${documentdir}/*.js \
            , ${documentdir}/*.vimrc \
            , ${documentdir}/*.gvimrc \
            | ForEach-Object { \
                Write-Host "Rename: $($_.Name) -> $($_.Name).txt"; \
                $_ | Rename-Item -NewName {$_.Name -replace '$', '.txt' } \
            }
        Compress-Archive \
            -Path ${documentdir}/*.txt \
            -DestinationPath ${documentdir}/a.zip -Update

    .PHONY: clean
    clean: ## Remove "*.txt" items in Documents directory
        ls -Path "${documentdir}/*.txt" \
            | ForEach-Object { \
                Write-Host "Remove: $($_.Name)"; \
                Remove-Item -LiteralPath $_.FullName \
            }

#>
function pwmake {
    Param(
        [Parameter(Position=0, Mandatory=$False)]
        [Alias('t')]
        [string] $Target,

        [Parameter(Position=1, Mandatory=$False)]
        [Alias('v')]
        [string[]] $Variables,

        [Parameter(Mandatory=$False)]
        [Alias('f')]
        [string] $File = "Makefile",

        [Parameter(Mandatory=$False)]
        [Alias('d')]
        [string] $Delimiter = " ",

        [Parameter(Mandatory=$False)]
        [Alias('td')]
        [string] $TargetDelimiter = ":",

        [Parameter(Mandatory=$False)]
        [ValidateSet("stop","silentlyContinue")]
        [string] $ErrAction = "stop",

        [Parameter(Mandatory=$False)]
        [switch] $Help,

        [Parameter(Mandatory=$False)]
        [switch] $DeleteCommentEndOfCommandLine,

        [Parameter(Mandatory=$False)]
        [string] $Param,

        [Parameter(Mandatory=$False)]
        [string[]] $Params,

        [Parameter(Mandatory=$False)]
        [string] $PSScriptRoot,

        [Parameter(Mandatory=$False)]
        [Alias('n')]
        [switch] $DryRun
    )

    ## show-help function
    function ParseHelp ([string[]] $argBlock) {
        ## parse help messages written in the following format
        ##   target: [dep dep ...] ## synopsis
        ##
        ##   bellow is the output
        ##
        ##   PS> pwmake -Help
        ##
        ##   target synopsis
        ##   ------ --------
        ##   help   help message
        ##   new    create directory and set skeleton files
        ##
        if ($argBlock){
            $varDict = @{}
            foreach ($var in $argBlock) {
                ## get args and add dict (key, val)
                $key, $val = GetArgVar "$var" $varDict
                if($varDict){
                    foreach ($k in $varDict.Keys){
                        ## replace variables
                        [string]$targetVar = '${' + $k + '}'
                        [string]$replaceVar = $varDict[$k]
                        $val = $val.Replace($targetVar, $replaceVar)
                    }
                }
                $varDict.Add($key, $val)
                #Write-Output "$key=$val"
            }
        }        
        Select-String '^[a-zA-Z0-9_\-\{\}\$\.\ ]+?:' -Path $File -Raw `
            | ForEach-Object {
                $helpStr = [string]$_
                if ($helpStr -match ':='){
                    ## skip variable definition line
                    return
                } elseif ($helpStr -match '^\.phony'){
                    ## skip phony definition line
                    return
                } elseif ($helpStr -match ' ## '){
                    $helpStr = $helpStr -replace ':.*? ## ', ' ## '
                } else {
                    $helpStr = $helpStr -replace ':.*$', ''
                }
                if ($argBlock){
                    ## replace variables
                    foreach ($k in $varDict.Keys){
                        [string]$bef = '${' + $k + '}'
                        [string]$aft = $varDict[$k]
                        $helpStr = $helpStr.Replace($bef, $aft)
                    }
                }
                $helpStr
                } `
            | ForEach-Object {
                $helpAry = $_.split(' ## ', 2)
                return [pscustomobject]@{
                    target = $helpAry[0]
                    synopsis = $helpAry[1]}
            }
    }

    ## init var
    [string] $makeFile = $File
    $phonyDict = @{}
    [string] $makefileParentDir = Resolve-Path -LiteralPath "$makeFile" | Split-Path -Parent 
    [string] $makefileParentDir = $makefileParentDir.Replace('\', '/')

    ## test
    $isExistMakefile = Test-Path -LiteralPath $makeFile
    if( -not $isExistMakefile){
        Write-Error "Could not find ""$makefile""" -ErrorAction Stop
    }

    ## private functions
    function AddEndOfFileMarkAndIncludeMakefile ([string]$mfile){
        [string[]] $lines = @()
        [string] $parentDir = Split-Path "$mfile" -Parent
        [string[]] $lines = Get-Content -LiteralPath "$mfile" -Encoding utf8 `
            | ForEach-Object {
                $mfileline = [string]$_
                if ($mfileline -match '^include '){
                    ## include other makefile
                    $mfileline = $mfileline -replace '^include ',''
                    $mfileline = $mfileline.trim()
                    [string[]]$fListAry = $mfileline -split ' '
                    foreach ($f in $fListAry){
                        $fPath = Join-Path "$parentDir" "$f"
                        Get-Content -Path "$fPath" -Encoding utf8
                        Write-Output ''
                    }
                } else {
                    Write-Output "$mfileline"
                }
            }
        #$lines += ,@('')
        #$lines += ,@('end_of_makefile:')
        return $lines
    }

    function DeleteSpace ([string]$line, [bool]$firstComFlag, [regex]$reg){
        if($reg){
            $line = $line -replace $reg, ''}
        if($firstComFlag){
            $line = $line -replace '^\s+',' '}
        else{
            $line = $line -replace '^\s+',''}
        return $line
    }

    function RemoveLineBreaks ([string[]]$lines){
        [string] $prevLine = ''
        [string[]] $lines = $lines | ForEach-Object {
                [string] $line = [string] $_
                [string] $line = [string] $line -replace '^\s+',' '
                if ( $line -match ' \\$' ){
                    ## backslash
                    $line = $line -replace '\s+\\$',' @-->@'
                    $prevLine = $prevLine + $line
                } elseif ( $line -match ' \`$' ){
                    ## backquote
                    $line = $line -replace '\s+\`$',' @-->@'
                    $prevLine = $prevLine + $line
                } elseif ( $line -match ' \|$' ){
                    ## pipe
                    $line = $line -replace '\s+\|$',' | @-->@'
                    $prevLine = $prevLine + $line
                } else {
                    if($prevLine -ne ''){
                        $prevLine = $prevLine + $line
                        $prevLine = $prevLine -replace '@\-\->@\s*',''
                        Write-Output $prevLine
                        $prevLine = ''
                    }else{
                        Write-Output $line
                    }
                }
            }
        if ( $prevLine -ne '' ){
            $prevLine = $prevLine -replace '@\-\->@\s*',''
            $prevLine = $prevLine -replace '\s*$',''
            [string[]] $lines += ,$prevLine
        }
        return $lines
    }

    function DeleteComment ([string[]]$lines){
        $lines = foreach ($line in $lines) {
            if($line -notmatch '^\s*#'){
                #[regex]$reg = '#["' + "']+$"
                #$line = $line -replace "$reg",''
                if($line -match '^\s+'){
                    ## command line
                    if ( $DeleteCommentEndOfCommandLine ){
                        if ( $line -notmatch '#' ){
                            # do not contains "#"
                            # pass
                        } else {
                            # delete comment like: command # comment
                            $line = $line -replace '#.*$', ''
                        }
                    }
                }else{
                    ## target: dep line
                    $line = $line -replace '#.*[^"'']$', ''
                }
                $line = $line -replace ' *$', ''
                Write-Output $line
            }
        }
        return $lines
    }

    function SeparateBlock ([string[]]$lines){
        [bool] $argBlockFlag = $true
        [string[]] $argBlock = @()
        [string[]] $comBlock = @()
        foreach ($line in $lines) {
            if ($line -match '.'){
                if ($line -notmatch '='){
                    $argBlockFlag = $False
                }
            }
            if ($argBlockFlag){
                if( ($line -ne '') -and ($line -match ':=') ){
                    $line = $line -replace '\s*:=\s*',':='
                    $argBlock += ,@($line)
                }elseif( ($line -ne '') -and ($line -match '=') ){
                    $line = $line -replace '\s*=\s*','='
                    $argBlock += ,@($line)
                }
            }else{
                $comBlock += ,@($line)
            }
        }
        ## add emptyline at the end of comBlock for CreateTargetDict function
        $comBlock += ,@('')
        return $argBlock, $comBlock
    }

    function ReplaceOverrideVariables ([string[]]$lines){
        ## test and set var in dictionary
        $varDict = @{}
        foreach ($var in $Variables) {
            if($var -notmatch '='){
                Write-Error "Use ""<name>=<val>"" when setting -Variable $var" -ErrorAction Stop}
            $varAry = $var -split "=", 2
            $key = $varAry[0].trim()
            $val = $varAry[1].trim()
            $varDict.Add($key, $val)
        }
        ## replace var in lines
        $lines = foreach ($line in $lines) {
            foreach ($k in $varDict.Keys){
                ## replace variable
                [string]$bef = '${' + $k + '}'
                [string]$aft = $varDict[$k]
                $line = $line.Replace($bef, $aft)
            }
            Write-Output $line
        }
        return $lines
    }

    function GetArgVar ([string]$var, $varDict){
        ## input -> var := str
        ## input -> var := ${var}
        ## input -> var := ${var}.png
        ## input -> var := $(shell command)
        ## return: key:var, val:hoge
        if ($var -match ':='){
            ## ':=' defines a simply-expanded variable
            $varAry = $var -split ":=", 2
            [string]$key = $varAry[0].trim()
            [string]$val = $varAry[1].trim()
            if ( $key -match '^[Pp]aram$'){
                Write-Error 'Variable name: "Param" is predefined. Please use another keyword.' -ErrorAction Stop
            }
            if ( $key -match '^[Pp]arams$'){
                Write-Error 'Variable name: "Params" is predefined. Please use another keyword.' -ErrorAction Stop
            }
            if ( $key -match '^PSScriptRoot$'){
                Write-Error 'Variable name: "PSScriptRoot" is predefined. Please use another keyword.' -ErrorAction Stop
            }
            ## replace ${var}
            if ($val -match '\$\{'){
                if($varDict){
                    foreach ($k in $varDict.Keys){
                        ## replace variables
                        [string]$bef = '${' + $k + '}'
                        [string]$aft = $varDict[$k]
                        $val = $val.Replace($bef, $aft)
                    }
                }
            }
            ## execute shell command
            if ($val -match '\$\(..*\)'){
               ## if $val contains $(command)
               ##     execute $val as shell command before variable assignment
               [string]$bef = $val -replace '^.*(\$\(..*\)).*$', '$1'
               [string]$aft = Invoke-Expression "$bef"
               [string]$val = $val.Replace($bef, $aft)
            }
        } else {
            ## '=' defines a recursively-expanded variable
            $varAry = $var -split "=", 2
            [string]$key = $varAry[0].trim()
            [string]$val = $varAry[1].trim()
            if ( $key -match '^[Pp]aram$'){
                Write-Error 'Variable name: "Param" is predefined. Please use another keyword.' -ErrorAction Stop
            }
            if ( $key -match '^[Pp]arams$'){
                Write-Error 'Variable name: "Params" is predefined. Please use another keyword.' -ErrorAction Stop
            }
            if ( $key -match '^PSScriptRoot$'){
                Write-Error 'Variable name: "PSScriptRoot" is predefined. Please use another keyword.' -ErrorAction Stop
            }
            #$val = '$(' + $val + ')'
        }
        ## replace predefined variable
        $val = $val.Replace('${PSScriptRoot}', $makefileParentDir)
        $val = $val.Replace('{$PSScriptRoot}', $makefileParentDir)
        $val = $val.Replace('$PSScriptRoot', $makefileParentDir)
        return $key, $val
    }

    function ReplaceArgBlock ([string[]]$argBlock){
        $varDict = @{}
        ## replace var in argBlock
        $argBlock = foreach ($var in $argBlock) {
            ## get key, val
            $key, $val = GetArgVar "$var" $varDict
            if($varDict){
                foreach ($k in $varDict.Keys){
                    ## replace variables
                    [string]$bef = '${' + $k + '}'
                    [string]$aft = $varDict[$k]
                    $val = $val.Replace($bef, $aft)
                }
            }
            $varDict.Add($key, $val)
            Write-Output "$key=$val"
        }
        return $argBlock
    }

    function ReplaceComBlock ([string[]]$argBlock, [string[]]$comBlock){
        $varDict = @{}
        ## set replace-dictionary
        foreach ($var in $argBlock) {
            $varAry = $var -split "=", 2
            $key = $varAry[0].trim()
            $val = $varAry[1].trim()
            $varDict.Add($key, $val)
        }
        $comBlock = foreach ($line in $comBlock) {
            foreach ($k in $varDict.Keys){
                [string]$bef = '${' + $k + '}'
                [string]$aft = $varDict[$k]
                $line = $line.Replace($bef, $aft)
            }
            Write-Output $line
        }
        return $comBlock
    }

    function CollectPhonies ([string[]]$comBlock){
        [string[]]$phonies = @()
        $comBlock = foreach ($line in $comBlock) {
            if ($line -match '^\.PHONY:'){
                $line = $line -replace '^\.PHONY:\s*'
                $tmpPhonies = $line -split $Delimiter
                foreach ($ph in $tmpPhonies){
                    $phonies += $ph
                }
            } else {
                Write-Output $line
            }
        }
        return $comBlock, $phonies
    }

    function CreateTargetDict ([string[]]$comBlock){
        $comDict    = @{}
        $tarDepDict = @{}
        [bool]$isFirstTarget = $true
        [string[]]$targetLineAry = @()
        [string[]]$comAry = @()
        [string[]]$depAry = @()
        foreach ($line in $comBlock) {
            if ($line -eq ''){
                if($isFirstTarget){
                    Write-Error "wrong start line" -ErrorAction Stop}
                ## output dictionary
                $comDict.Add($tar, $comAry)
                [string[]]$comAry = @()
            } else {
                if($line -match '^[^\s+].*:'){
                    ## target: dependency line
                    $targetLineAry += ,@($line)
                    $tar, $dep = $line -split ':', 2
                    $tar = $tar.trim()
                    $dep = $dep.trim()
                    $depAry = $dep -split $Delimiter
                    $tarDepDict.Add($tar, $depAry)
                    if($isFirstTarget){
                        ## get first target name
                        $isFirstTarget = $False
                        $firstTarget = $tar
                    }
                } elseif ($line -match '^\s') {
                    ## command line
                    $comAry += ,@($line.trim())
                } else {
                    Write-Error "unexpected line: $line" -ErrorAction Stop
                }
            }
        }
        return $targetLineAry, $comDict, $tarDepDict, $firstTarget
    }

    function CleanComBlock ([string[]]$ary){
        $isFirstLine = $true
        $ary = foreach ($line in $ary) {
            if ($line -ne ''){
                if ($isFirstLine){
                    ## first target line: output only input line
                    Write-Output $line
                    $isFirstLine = $False
                }elseif ($line -match '^[^\s].*:'){
                    ## normal target line: output with emptyline
                    Write-Output ''
                    Write-Output $line
                }else{
                    ## command line: output only input line
                    if($line -notmatch '^\s'){
                        Write-Error "unexpected line: $line" -ErrorAction Stop
                    }
                    Write-Output $line
                }
            }
        }
        $ary += @('')
        return $ary
    }

    function isPercentUsedCorrectly ([string]$line, [switch]$isTaget){
        if($isTaget){
            if ($line -match '%\.'){ return $True }
        } else {
            if ($line -match '\$%\.'){ return $True }
        }
        Write-Error "Use the symbol '%' with the extension: $line" -ErrorAction Stop
        return $False

    }
    function ReplacePercentToTarget ([string[]]$ary){
        ## shortest remove right from dot in target string
        $repTar = $Target -replace '\.[^.\\/]*$', ''
        $repTar += '.'
        #Write-Debug $repTar
        $ary = foreach ($line in $ary) {
            if ($line -match '%\.'){
                if ($line -match '^[^\s].*:'){
                    ## target line: replace '%.' to target
                    $line = $line.Replace('%.',"$repTar")
                    Write-Output $line
                }else{
                    Write-Output $line
                }
            }else{
                Write-Output $line
            }
        }
        return $ary
    }

    function GetDepsDict ([string[]]$lines){
        $depsDict = @{}
        $firstTargetFlag = $True
        foreach ($line in $lines) {
            $t, $d = $line -split $TargetDelimiter, 2
            $t = $t.trim(); $d = $d.trim()
            if($d -eq ''){
                $depsAry = @()
            } else {
                $depsAry = $d -split $Delimiter
            }
            $depsDict.Add($t, $depsAry)
            if($firstTargetFlag){
                $firstTargetFlag = $False
                $firstTarget = $t
            }
        }
        return $depsDict
    }

    function IsTargetExists ([string]$tar, $dependencies){
        $tFlag = $False
        foreach ($key in $dependencies.Keys){
            if($key -eq $tar){$tFlag = $True}
        }
        return $tFlag
    }

    function Toposort_Tarjan ([string]$tar, $dependencies, $marked = @{}, $sorted = @()){
        ## Tarjan's topological sort
        ## :arg dependencies: dict of ``(tar, [list of dependencies])`` pairs
        if ($marked[$tar]){ return }
        $marked[$tar] = $True
        [string]$uniDeps = $dependencies[$tar] -Join $Delimiter
        if (IsTargetExists $uniDeps $dependencies){
            Toposort_Tarjan $uniDeps $dependencies $marked $sorted
        } else {
            foreach ($m in $dependencies[$tar]){
                Toposort_Tarjan $m $dependencies $marked $sorted
            }
        }
        $sorted += $tar
        return $sorted
    }

    function TargetContainsPhony ( [string]$tar, [string[]]$phonies ){
        $tarAry = $tar -split $Delimiter
        foreach ($ta in $tarAry){
            foreach ($phony in $phonies){
                if ($ta -eq $phony){ return $True }
            }
        }
        return $False
    }

    function DepContainsPhony ( [string[]]$depAry, [string[]]$phonies ){
        foreach ($de in $depAry){
            foreach ($phony in $phonies){
                if ($de -eq $phony){ return $True }
            }
        }
        return $False
    }

    function TargetFileIsNotExists ( [string]$tar ){
        $tarAry = "$tar" -split $Delimiter
        foreach ($ta in $tarAry){
            if ( -not (Test-Path -LiteralPath "$ta") ){ return $True }
        }
        return $False
    }

    function DepFileIsNotExists ( [string[]]$dependencies, [string[]]$phonies ){
        $depAry = $dependencies -split $Delimiter
        foreach ($de in $depAry){
            if ( TargetContainsPhony $de $phonies )   { return $True }
            if ( -not (Test-Path -LiteralPath "$de") ){ return $True }
        }
        return $False
    }

    function GetLastWriteTime ([string[]]$files, [string]$oldnew = "older"){
        [datetime]$retDate = (Get-Item -LiteralPath $files[0]).LastWriteTime
        foreach ($f in $files){
            [datetime]$tmpDate = (Get-Item -LiteralPath "$f").LastWriteTime
            if ($oldnew -eq 'older'){
                if ($tmpDate -lt $retDate){ $retDate = $tmpDate }
            }else{
                if ($tmpDate -gt $retDate){ $retDate = $tmpDate }
            }
        }
        return $retDate
    }

    function TargetFileOlerThanDepFile ([string]$tar, [string[]]$depAry){
        $tarAry = $tar -split $Delimiter
        [datetime]$tarFileOlderDate = GetLastWriteTime $tarAry "older"
        [datetime]$depFileNewerDate = GetLastWriteTime $depAry "newer"
        Write-Debug "tar older: $($tarFileOlderDate.ToString('yyyy-MM-dd HH:mm:ss'))"
        Write-Debug "dep newer: $($depFileNewerDate.ToString('yyyy-MM-dd HH:mm:ss'))"
        if ($tarFileOlderDate -lt $depFileNewerDate){
            return $True
        } else {
            return $False
        }
    }

    function IsTargetExecute ([string]$tar, $tarDepDict, $phonies){
        if ($tarDepDict[$tar][0] -eq '') {
            $depExists = $False
        } else {
            $depExists = $True
        }
        if ( $depExists -eq $False ){
            ## if target has no dependency
            if (TargetContainsPhony "$tar" $phonies){
                Write-Debug "check: TargetContainsPhony: $tar"
                return $True }
            if (TargetFileIsNotExists "$tar"){
                Write-Debug "check: TargetFileIsNotExists: $tar"
                return $True }
            Write-Debug "check: TargetFileIsExists: $tar"
        } else {
            ## if target has dependencies
            ### test targets
            if (TargetContainsPhony "$tar" $phonies){
                Write-Debug "check: TargetContainsPhony: $tar"
                return $True }
            if (TargetFileIsNotExists "$tar"){
                Write-Debug "check: TargetFileIsNotExists: $tar"
                return $True }
            ## test deps
            [string[]]$depAry = $tarDepDict[$tar]
            if (DepContainsPhony $depAry $phonies){
                Write-Debug "check: DepContainsPhony: $($tar): $($depAry)"
                return $True }
            if (DepFileIsNotExists $depAry $phonies){
                Write-Debug "check: DepFileIsNotExists: $($tar): $($depAry)"
                return $True }
            if (TargetFileOlerThanDepFile "$tar" $depAry){
                Write-Debug "check: TargetFileOlerThanDepFile: $($tar): $($depAry)"
                return $True }
             Write-Debug "check: TargetFileNewerThanDepFile: $($tar): $($depAry)"
        }
        return $False
    }

    function NoTarFile ([string]$tar){
        $targetFileIsNotExists = $False
        $tarAry = "$tar" -split $Delimiter
        foreach ($f in $tarAry){
            if ( -not (Test-Path -LiteralPath $f)){
                $targetFileIsNotExists = $True
            }
        }
        return $targetFileIsNotExists
    }

    function ReplaceAutoVar ([string]$comline, [string]$tar, $tarDepDict){
        ## replace auto variables written in each command line
        ##     $@ : Target file name
        ##     $< : The name of the first dependent file
        ##     $^ : Names of all dependent file
        ##     %.ext : Replace with a string with the extension removed
        ##         from the target name. Only target line can be used.
        ##     $PSScriptRoot : Parent path of Makefile

        ## set dependency line
        if ($tarDepDict[$tar][0] -eq '') {
            $dep = ''
        }else{
            $dep = $tarDepDict[$tar] -join "$Delimiter"
        }

        ## set replace str
        [string]$autoValTarAll   = $tar
        [string]$autoValTarFirst = ($tar -split "$Delimiter")[0]
        [string]$autoValDepAll   = $dep
        [string]$autoValDepFirst = ($dep -split "$Delimiter")[0]

        ## replace auto variables
        $comline = $comline.Replace('$@',"$autoValTarFirst")
        $comline = $comline.Replace('$<',"$autoValDepFirst")
        $comline = $comline.Replace('$^',"$autoValDepAll")
        $comline = $comline.Replace('${PSScriptRoot}', $makefileParentDir)
        $comline = $comline.Replace('{$PSScriptRoot}', $makefileParentDir)
        $comline = $comline.Replace('$PSScriptRoot', $makefileParentDir)
        return $comline
    }

    ## parse Makefile
    [string[]] $lines    = @()
    [string[]] $argBlock = @()
    [string[]] $comBlock = @()
    [string[]] $phonies  = @()

    ### preprocessing
    [string[]] $lines = AddEndOfFileMarkAndIncludeMakefile "$makeFile"
    [string[]] $lines = DeleteComment $lines
    [string[]] $lines = RemoveLineBreaks $lines

    ### replace variables
    if($Variables){
        [string[]] $lines = ReplaceOverrideVariables $lines
    }
    $argBlock, $comBlock = SeparateBlock $lines

    ### replace '%' to target string
    $comBlock = ReplacePercentToTarget $comBlock

    ## show help
    if ($Help){
        if($argBlock){
            ParseHelp $argBlock
        } else {
            ParseHelp
        }
        return
    }

    ### replace argblock
    if($argBlock){
        $argBlock = ReplaceArgBlock $argBlock
        $comBlock = ReplaceComBlock $argBlock $comBlock
    }

    ### create phonyDict
    $comBlock, $phonies = CollectPhonies $comBlock

    ### cleaning comBlock: add emptyline before target line
    $comBlock = CleanComBlock $comBlock

    ### debug
    if($DryRun){
        Write-Output "######## override args ##########"
        if($Variables){$Variables}else{"None"}
        Write-Output ''
        Write-Output "######## argblock ##########"
        if($argBlock){$argBlock}else{"None"}
        Write-Output ''
        Write-Output "######## phonies ##########"
        if($phonies){$phonies}else{"None"}
        Write-Output ''
        Write-Output "######## comBlock ##########"
        $comBlock
    }

    ## comBlock:
    ##   data structure: (block separator -eq emptyline)
    ## ----------------------------
    ##    target: dependent,...
    ##        command1
    ##        command2
    ##
    ##    target: dependent,...
    ##        command1
    ##        command2
    ##

    ## set dictionary
    $targetLineAry, $comDict, $tarDepDict, $firstTarget = CreateTargetDict $comBlock

    ## set target
    if($Target){
        [string] $tar = $Target
    } else {
        [string] $tar = $firstTarget
    }

    ## is exist target?
    if ( -not $comDict.ContainsKey($tar) ){
        Write-Error "Target: $tar is not exist in $makeFile" -ErrorAction Stop}

    ## set target and dependencies
    $depsDict = GetDepsDict $targetLineAry

    ## get topological sorted target line
    [string[]]$targetSortedList = @()
    $targetSortedList = Toposort_Tarjan "$tar" $depsDict
    #$targetSortedList = $targetLineAry | toposort

    ## debug log
    if ($DryRun){
        Write-Output "######## topological sorted target lines ##########"
        foreach ($line in $targetSortedList) {
            Write-Output "$line"
        }
        Write-Output ""
        Write-Output "######## topological sorted command lines ##########"
        foreach ($tmpTarget in $targetSortedList) {
            foreach($comline in $comDict[$tmpTarget]) {
                if ( $comline -notmatch '^\s*$' ){
                    $comline = ReplaceAutoVar "$comline" "$tmpTarget" $tarDepDict
                    #Write-Output "$($tmpTarget): $comline"
                    Write-Output "$comline"
                }
            }
        }
    }

    ## execute commands
    $isCommandExecuted = $False
    if ($DryRun){
        Write-Output ""
        Write-Output "######## execute commands ##########"
    }
    [string[]]$execComAry = @()
    foreach ($tar in $targetSortedList) {
        $targetLineIsExist = $comDict.ContainsKey($tar)
        if ( -not $targetLineIsExist ){
            if (NoTarFile "$tar"){
                ## target file is not exists
                Write-Error "Error: file is not exitsts: '$tar'." -ErrorAction Stop
            } else {
                ## target file is exists
                continue
            }
        }

        ## set commandline as string array
        [string[]]$commandlines = $comDict[$tar]

        ## set dependency line as string
        if ($tarDepDict[$tar][0] -eq '') {
            $dep = ''
        }else{
            $dep = $tarDepDict[$tar] -join "$Delimiter"
        }

        ## target should be execute?
        $comExecFlag = IsTargetExecute "$tar" $tarDepDict $phonies
        if( -not $comExecFlag ){
            ## continue ForEach-Object
            ## do not execute commands
            #if ($DryRun){ Write-Output "[F] $($tar): $dep" }
            continue
        }

        ## is commandlines are exists?
        if ($commandlines.Count -eq 0){
            ## continue ForEach-Object
            #if ($DryRun){ Write-Output "[F] $($tar): $dep" }
            continue
        }

        ## execute commandlines
        foreach ($comline in $commandlines){
            ## replace auto variables
            [string] $comline = ReplaceAutoVar "$comline" "$tar" $tarDepDict
            if (($comline -eq '') -or ($comline -match '^\s*$')){
                continue
            }
            ## main
            if ($DryRun){
                ## out debug
                #Write-Output "[T] $($tar): $comline"
                Write-Output "$comline"
            }else{
                ## exec commandline
                $echoCom = $True
                if ($comline -match '^@[^\(\{]'){
                    $echoCom = $False
                    $comline = $comline -replace '^@', ''
                }
                if ($echoCom){
                    Write-Host "> $comline" -ForegroundColor Green
                }
                try {
                    $isCommandExecuted = $True
                    Invoke-Expression "$comline"
                } catch {
                    if ($ErrAction -eq "stop"){
                        #Write-Warning "Error: $($tar): $comline"
                        Write-Error $Error[0] -ErrorAction Stop
                    }else{
                        #Write-Warning "Error: $($tar): $comline"
                        Write-Warning $Error[0]
                    }
                }
            }
        }
        if ($echoCom){ Write-Host "" }
    }
    if( (-not $isCommandExecuted) -and (-not $DryRun)){
        Write-Host "make: '$tar' is up to date."
    }
}
