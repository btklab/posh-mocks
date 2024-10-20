<#
.SYNOPSIS
    i : Invoke-Link - Open file/web links written in a text file

    Open file/web links written in a text file or via pipeline or via Clipboard.
    The processing priority is pipeline > arguments > clipboard.

        - If a text file (Ext: None, .txt, .md, ...) is specified,
          open each line as link in default application
            - Link beginning with "http" or "www":
                - Start-Process (default browser)
            - Directory and others:
                - Invoke-Item <link>
        - If a link file (.lnk) is specified, open the link in explorer
        - If a PowerShell Script file (.ps1) is specified,
          execute the script in current process:
            - Able to use dot sourcing functions in current process
            - Specify the absolute file path in the text file as possible.
              Or Note that when specifying a relative path, the root is the
              location of the current process
        - If a directory is specified, the names and first lines of the
          files in that hierarchy are listed.
            - Collect files recursively with -Recurse option

    Link file settings:

        - Multiple links(lines) in a file available.
        - Tag
            - To add tags, add a space + "#tag" to a comment line
              starting with "#" or "Tag:"
                - e.g. # commnent #tag-1 #tag-2
                - e.g. Tag: #tag-1 #tag-2
            - If you specify a directory as an argument:
                - tags will be output. This is useful when searching linked files by tag.
                - the directory name is set as a tag.
        - Skip line
            - Lines that empty or beginning with "#" are skipped.
            - Lines that empty or beginning with "Tag:" are skipped.
        - The link execution app can be any command if "-Command" option is
          specified.
        - Links written in a text file may or may not be enclosed in
          single/double quotes.
        - If -l or -Location specified, open the file location in explorer
          (do not run link)
        - Environment variables such as ${HOME} can be used for path strings.

    Usage:
        i                  ... Invoke-Item from Clipboard
        i <dir>            ... Invoke-Item <dir>
        i <file>           ... Invoke-Item <links-writtein-in-text-file>
        i <file> <command> ... command <links-writtein-in-text-file>
        i <file> -l or -Location ... Open <link> location in explorer
        i <file> -d or -DryRun   ... DryRun (listup links)
        i <file> -e or -Edit     ... Edit <linkfile> using text editor

        "url" | i                ... Start-Process -FilePath <url>
        "url" | i -c "firefox"   ... firefox <url>
    
    Example of link file with tag:
        cat ./work/apps/chrome.txt

            # title of link file #app #browser
            Tag: #hoge #fuga
            "C:\Program Files\Google\Chrome\Application\chrome.exe"

    Input:
        cat ./link/about_Invoke-Item.txt
        https://learn.microsoft.com/ja-jp/powershell/module/microsoft.powershell.management/invoke-item
    
    Output:
        i ./link/about_Invoke-Item.txt
        # open link in default browser

        i ./link/about_Invoke-Item.txt firefox
        # open link in "firefox" browser

    Note:
        I use this function and link file combination:

        1. As a starting point for tasks and apps
        2. As a website favorite link collection
        3. As a simple task runner

.EXAMPLE
    i                  ... Invoke-Item from Clipboard
    i <file>           ... Invoke-Item <links-writtein-in-text-file>
    i <file> <command> ... command <links-writtein-in-text-file>
    i <file> <command> -b    ... run command in background
    i <file> -l or -Location ... Open <link> location in explorer
    i <file> -d or -DryRun   ... DryRun (listup links)
    i <file> -e or -Edit     ... Edit <linkfile> using text editor

    "url" | i                ... Start-Process -FilePath <url>
    "url" | i -c "firefox"   ... firefox <url>

.EXAMPLE
    cat ./link/rmarkdown_site.txt
    "C:/Users/path/to/the/index.html"

    # dry run
    i ./link/rmarkdown_site.txt -d
    ./link/rmarkdown.txt
    Invoke-Item "C:/Users/path/to/the/index.html"

    # open index.html in default browser/explorer/apps
    i ./link/rmarkdown_site.txt

    # open index.html in firefox browser
    i ./link/rmarkdown_site.txt firefox

    # open index.html in VSCode
    i ./link/rmarkdown_site.txt code

    # show index.html file location
    i ./link/rmarkdown_site.txt -l

    # show index.html file location and resolve-path
    i ./link/rmarkdown_site.txt -l | Resolve-Path -Relative

    # open index.html file location in explorer using Invoke-Item
    i ./link/rmarkdown_site.txt -l ii

.EXAMPLE
    ## Specify path containing wildcards
    i ./link/a.*
    
    ## Directory recursive search
    i ./work/ -Recurse

.EXAMPLE
    ## execute if *.ps1 file specified

    cat ./link/work/MicrosoftSecurityResponseCenter_Get-Rssfeed.ps1
    # MSRC - Microsoft Security Response Center
    rssfeed https://api.msrc.microsoft.com/update-guide/rss -MaxResults 30

    ## execute .ps1 function
    ## able to use dot sourcing functions in current process
    i ./link/MicrosoftSecurityResponseCenter_Get-Rssfeed.ps1

    channel                    date       item
    -------                    ----       ----
    MSRC Security Update Guide 2023-09-15 Chromium: CVE-2023-4900...
    MSRC Security Update Guide 2023-09-15 Chromium: CVE-2023-4901...
    MSRC Security Update Guide 2023-09-15 Chromium: CVE-2023-4902...
    MSRC Security Update Guide 2023-09-15 Chromium: CVE-2023-4903...
    MSRC Security Update Guide 2023-09-15 Chromium: CVE-2023-4904...
    MSRC Security Update Guide 2023-09-15 Chromium: CVE-2023-4905...

.EXAMPLE
    # tag search
    
    ## link file
    cat ./work/apps/chrome.txt
        # chrome #app
        Tag: #hoge #fuga
        "C:\Program Files\Google\Chrome\Application\chrome.exe"

    ## search by tag
    i ./work/apps/ | ? tag -match hoge
        Id Tag                 Name               Line
        -- ---                 ----               ----
         1 #app, #hoge, #fuga  ./work/apps/chrome # chrome #app

.LINK
    linkcheck

#>
function Invoke-Link {

    [CmdletBinding()]
    param (
        [Parameter( Mandatory=$False, Position=0, ValueFromPipeline=$True )]
        [Alias('f')]
        [string[]] $Files,
        
        [Parameter( Mandatory=$False, Position=1 )]
        [Alias('c')]
        [string] $Command,
        
        [Parameter( Mandatory=$False )]
        [Alias('l')]
        [switch] $Location,
        
        [Parameter( Mandatory=$False )]
        [Alias('e')]
        [switch] $Edit,
        
        [Parameter( Mandatory=$False )]
        [string] $Editor,
        
        [Parameter( Mandatory=$False )]
        [switch] $LinkCheck,
        
        [Parameter( Mandatory=$False )]
        [Alias('b')]
        [switch] $BackGround,
        
        [Parameter( Mandatory=$False )]
        [Alias('r')]
        [switch] $Recurse,
        
        [Parameter( Mandatory=$False )]
        [Alias('g')]
        [switch] $AsFileObject,
        
        [Parameter( Mandatory=$False )]
        [Alias('rmext')]
        [switch] $RemoveExtension,
        
        [Parameter( Mandatory=$False )]
        [Alias('a')]
        [switch] $AllowBulkInput,
        
        [Parameter( Mandatory=$False )]
        [Alias('i')]
        [int[]] $InvokeById,
        
        [Parameter( Mandatory=$False )]
        [int[]] $Id,
        
        [Parameter( Mandatory=$False )]
        [ValidateSet(
            "Break", "Ignore", "SilentlyContinue",
            "Suspend", "Continue", "Inquire", "Stop" )]
        [string] $ErrAction = "Stop",
        
        [Parameter( Mandatory=$False )]
        [int] $LimitErrorCount = 5,
        
        [Parameter( Mandatory=$False )]
        [string] $Grep,
        
        [Parameter( Mandatory=$False )]
        [Alias('v')]
        [switch] $NotMatch,
        
        [Parameter( Mandatory=$False )]
        [Alias('d')]
        [switch] $DryRun,
        
        [Parameter( Mandatory=$False )]
        [Alias('q')]
        [switch] $Quiet
    )
    # private functions
    function isCommentOrEmptyLine ( [string] $line ){
        [bool] $coeFlag = $False
        if ( $line -match '^#' )   { $coeFlag = $True }
        if ( $line -match '^\s*$' ){ $coeFlag = $True }
        if ( $line -match '^[Tt][Aa][Gg]:' ){ $coeFlag = $True }
        return $coeFlag
    }
    function isLinkHttp ( [string] $line ){
        [bool] $httpFlag = $False
        if ( $line -match '^https*:' ){ $httpFlag = $True }
        if ( $line -match '^www\.' )  { $httpFlag = $True }
        return $httpFlag
    }
    function isLinkAlive ( [string] $uri ){
        $origErrActPref = $ErrorActionPreference
        try {
            $ErrorActionPreference = "SilentlyContinue"
            $Response = Invoke-WebRequest -Uri "$uri"
            $ErrorActionPreference = $origErrActPref
            # This will only execute if the Invoke-WebRequest is successful.
            $StatusCode = $Response.StatusCode
            return $True
        } catch {
            $StatusCode = $_.Exception.Response.StatusCode.value__
            return $False
        } finally {
            $ErrorActionPreference = $origErrActPref
        }
    }
    function editFile ( [string] $fpath ){
        if ( $Editor ){
            Invoke-Expression -Command "$Editor $fpath"
        } else {
            if ( $isWindows ){
                notepad $fpath
            } else {
                vim $fpath
            }
        }
        return
    }
    function getRelativePath ( [string] $LiteralPath ){
        [String] $res = Resolve-Path -LiteralPath $LiteralPath -Relative
        if ( $IsWindows ){ [String] $res = $res.Replace('\', '/') }
        return $res
    }
    function getMatchesValue {
        param (
            [String] $line,
            [String] $pattern,
            [Parameter( Mandatory=$False )]
            [String[]] $replaceChar
        )
        $splatting = @{
            Pattern       = $pattern
            CaseSensitive = $False
            Encoding      = "utf8"
            SimpleMatch   = $False
            NotMatch      = $False
            AllMatches    = $True
        }
        [String[]] $retAry = ($line | Select-String @splatting).Matches.Value `
            | ForEach-Object {
                [String] $writeLine = "$_".Trim()
                if ( $replaceChar.Count -gt 0 ){
                    foreach ( $r in $replaceChar ){
                        $writeLine = $writeLine.Replace($r, '')
                    }
                }
                Write-Output $writeLine
            }
        return $retAry
    }
    # set variable
    [int] $errCounter = 0
    # test bulk input
    if ( -not $AllowBulkInput ){
        $bulkList = New-Object 'System.Collections.Generic.List[System.String]'
        foreach ( $f in $Files ){
            # expand wildcard
            if ( Test-Path -LiteralPath $f ){
                Get-Item -Path $f | ForEach-Object {
                    if ( Test-Path -Path $_.FullName -PathType Leaf){
                        [String] $resPath = getRelativePath $_.FullName
                        $bulkList.Add($resPath)
                    }
                }
            }
        }
        [String[]] $bulkFileAry = $bulkList.ToArray()
        if ( $bulkFileAry.Count -gt 1 ){
            foreach ( $f in $bulkFileAry ){
                Write-Output $f
            }
            Write-Error "Detect input of 5 or more items. To avoid this error, specify the '-AllowBulkInput' option." -ErrorAction Stop
        }
    }
    # main
    [int] $fileCounter = 0
    [string[]] $readLineAry = @()
    if ( $input.Count -gt 0 ){
        ## get file path from pipeline text
        [string[]] $readLineAry = $input `
            | ForEach-Object {
                if ( ($_ -is [System.IO.FileInfo]) -or ($_ -is [System.IO.DirectoryInfo]) ){
                    ## from filesystem object
                    [string] $oText = $_.FullName
                } elseif ( $_ -is [System.IO.FileSystemInfo] ){
                    ## from filesystem object
                    [string] $oText = $_.FullName
                } else {
                    ## from text
                    [string] $oText = $_
                }
                Write-Output $oText
            }
        [string[]] $readLineAry = ForEach ($r in $readLineAry ){
            if ( $r -ne '' ){ $r.Replace('"', '') }
        }
    } elseif ( $Files.Count -gt 0 ){
        ## get filepath from option
        [string[]] $readLineAry = $Files | `
            ForEach-Object { (Get-Item -LiteralPath $_).FullName }
    } else {
        ## get filepath from clipboard
        if ( $True ){
            ### get filepath as object
            Add-Type -AssemblyName System.Windows.Forms
            [string[]] $readLineAry = [Windows.Forms.Clipboard]::GetFileDropList()
        }
        if ( -not $readLineAry ){
            ### get filepath as text
            [string[]] $readLineAry = Get-Clipboard | `
                ForEach-Object { if ($_ -ne '' ) { $_.Replace('"', '')} }
        }
    }
    ## test
    if ( $readLineAry.Count -lt 1 ){
        Write-Error "no input file." -ErrorAction Stop
    }
    ## sort file paths
    #[string[]] $sortedReadLineAry = $readLineAry | Sort-Object
    ## parse paths
    foreach ( $f in $readLineAry ){
        # interpret Paths containing wildcards
        if ( Test-Path -Path $f -PathType Container){
            [string[]] $tmpFiles = Get-Item -Path $f `
                | Resolve-Path -Relative
        } elseif ( Test-Path -Path $f -PathType Leaf){
            [string[]] $tmpFiles = Get-ChildItem -Path $f -Recurse:$Recurse -File `
                | Resolve-Path -Relative
        } else {
            [string[]] $tmpFiles = @()
            $tmpFiles += $f
        }
        # set links
        foreach ( $File in $tmpFiles ){
            $hrefList = New-Object 'System.Collections.Generic.List[System.String]'
            # is path directory?
            if ( Test-Path -LiteralPath $File -PathType Container){
                if ( $DryRun ){
                    Write-Output $File
                    continue
                }
                # return file paths
                #Invoke-Item -LiteralPath $File
                Get-ChildItem -LiteralPath $File -Recurse:$Recurse -File `
                    | Sort-Object {
                        -join ( [int[]] ($_.FullName.ToCharArray()) | ForEach-Object { [System.Convert]::ToString($_, 16)})
                    } `
                    | ForEach-Object {
                        $fileCounter++
                        if ( $InvokeById.Count -gt 0){
                            if ($InvokeById.Contains($fileCounter)){
                                [String] $relPath = getRelativePath $_.FullName
                                Write-Output "Invoke-Link: $relPath"
                                Invoke-Link -Files $_.FullName
                            }
                            return
                        }
                        if ( $Id.Count -gt 0){
                            i ($Id.Contains($fileCounter)){
                                Get-Item -LiteralPath $_.FullName
                            }
                            return
                        }
                        # set path
                        [String] $parentPath    = Split-Path -Parent $_
                        [String] $childPath     = Split-Path -Leaf $_
                        [String] $joinedPath    = Join-Path -Path $parentPath -ChildPath $childPath
                        [String] $relativePath  = getRelativePath $joinedPath
                        [String] $parentDirName = Split-Path -Parent $_ | Split-Path -Leaf
                        # remove extension
                        if ( $RemoveExtension -and $_.Name -notmatch '^\.') {
                            [String] $relativePath = $relativePath -replace '\.[^\.]+$', ''
                        }
                        if ( Test-Path -LiteralPath $_.FullName -PathType Container){
                            continue
                        } elseif ( -not ($_.Extension) -or $_.Extension -match '\.txt$|\.md$' ){
                            # get tag
                            [String] $pat = ' #[^ #]+'
                            $splatting = @{
                                Pattern       = $pat
                                CaseSensitive = $False
                                Encoding      = "utf8"
                                AllMatches    = $True
                                Path          = $_.FullName
                            }
                            #[String[]] $tagAry = getMatchesValue $line ' #[^ ]+|^#[^ ]+'
                            [String[]] $tagAry = (Select-String @splatting).Matches.Value `
                                | ForEach-Object {
                                    [String] $tmpTagStr = $("$_".Trim())
                                    if ( $tmpTagStr -ne '' ){
                                        Write-Output $("$_".Trim())
                                    }
                                }
                            # set tag
                            [String] $tagStr = '#' + $parentDirName
                            if ( $tagAry.Count -gt 0 ){
                                [String] $tagStr += ", "
                                [String] $tagStr += $tagAry -join ", "
                            }
                            [String] $tagStr += ","
                            $hash = [ordered] @{
                                Id   = $fileCounter
                                Tag  = $tagStr
                                Name = $relativePath
                                Line = Get-Content -Path $_.FullName -TotalCount 1 -Encoding utf-8
                            }
                        } else {
                            $hash = [ordered] @{
                                Id   = $fileCounter
                                Tag  = '#' + $parentDirName
                                Name = $relativePath
                                Line = $Null
                            }
                        }
                        [pscustomobject] $Hash
                    }
                continue
            }
            # is file exist?
            #if ( -not ( Test-Path -LiteralPath $File ) ){
            #    if ( $Edit ){
            #        # about Read-Host
            #        # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/read-host
            #        [string] $resp = Read-Host "$File is not exists. Create and Edit? (y/n)"
            #        if ( $resp -eq 'y' ){ editFile $File }
            #        continue
            #    }
            #    Invoke-Item -LiteralPath $File
            #    continue
            #}
            # edit file mode
            if ( Test-Path -LiteralPath $File ){
                if ( $Edit ){
                    editFile $File
                    continue
                }
            }
            # output file name
            if ( -not $Quiet ){
                if ( -not $DryRun ){
                    # pass
                    #Write-Output $($File.Replace('\','/'))
                }
            }
            # is windows shortcut?
            if ( Test-Path -LiteralPath $File ){
                [string] $ext = (Get-Item -LiteralPath $File).Extension
                ## is file shortcut?
                if ( ( $ext -eq '.lnk' ) -or ( $ext -eq '.url') ){
                    if ( $DryRun ){
                        "Invoke-Item -LiteralPath $File"
                        continue
                    } else {
                        Invoke-Item -LiteralPath $File
                        continue
                    }
                }
                ## is file .ps1 script?
                if ( $ext -eq '.ps1' ){
                    [string] $ps1FileFullPath = (Resolve-Path -LiteralPath $File).Path
                    if ( $DryRun ){
                        "Invoke-Item -LiteralPath ""$ps1FileFullPath"""
                        continue
                    } else {
                        & $ps1FileFullPath
                        continue
                    }
                }
                ## is non-text file
                if ( -not ( ( -not $ext ) -or ( $ext -match '\.txt$|\.md$') ) ){
                    if ( $DryRun ){
                        "Invoke-Item -LiteralPath $File"
                        continue
                    } else {
                        Invoke-Item -LiteralPath $File
                        continue
                    }
                }
                ## is file .ps1 script?
            }
            ## is -not shortcut and -not ps1 script?
            [string[]] $linkLines = @()
            if ( Test-Path -LiteralPath $File ){
                ## link written in file
                $linkLines = Get-Content -LiteralPath $File -Encoding utf8
            } else {
                ## plain text link
                $linkLines += $File
            }
            $linkLines = $linkLines `
                | ForEach-Object {
                    [string] $linkLine = $_
                    if ( isCommentOrEmptyLine $linkLine ){
                        # pass
                    } else {
                        if ( $Grep ){
                            if ( $NotMatch ){
                                if ( $linkLine -notmatch $Grep ){
                                    #pass
                                } else {
                                    return
                                }
                            } else {
                                if ( $linkLine -match $Grep ){
                                    #pass
                                } else {
                                    return
                                }
                            }
                        }
                        # trim and drop quotes
                        $linkLine = $linkLine.Trim()
                        $linkLine = $linkLine -replace '^"',''
                        $linkLine = $linkLine -replace '"$',''
                        $linkLine = $linkLine -replace "^'",''
                        $linkLine = $linkLine -replace "'`$",''
                        # test path
                        if ( $Location ){
                            $linkLine = Split-Path "$linkLine" -Parent
                        }
                        if ( $LinkCheck ){
                            if ( isLinkHttp $linkLine ){
                                if ( isLinkAlive $linkLine ){
                                    # pass
                                } else {
                                    Write-Error "broken link: '$linkLine'" -ErrorAction Stop
                                }
                            } else {
                                if ( Test-Path -LiteralPath $linkLine){
                                    # pass
                                } else {
                                    Write-Error "broken link: '$linkLine'" -ErrorAction Stop
                                }
                            }
                        }
                        Write-Output $linkLine
                    }
                } | Sort-Object -Unique
            if ( $Edit ){
                continue
            }
            if ( -not $linkLines ){
                if ( Test-Path -LiteralPath $File -PathType Container){
                    continue
                }
                "Could not find links in file: $File" | Write-Error -ErrorAction Stop
                continue
            }
            if ( $DryRun ){
                Write-Host "$File" -ForegroundColor Green
            }
            if ( $Location -and -not $Command ){
                $linkLines | ForEach-Object {
                    if ( isLinkHttp $_ ){
                        #pass
                    } else {
                        Invoke-Item $_ }
                    }
                continue
            }
            foreach ( $href in $linkLines ){
                $hrefList.Add($href)
            }
        }
        if ( $Location -and -not $Command ){
            continue
        }
        [String[]] $linkAry = $hrefList.ToArray()
        $hrefList = New-Object 'System.Collections.Generic.List[System.String]'
        foreach ( $href in $linkAry ){
            # execute command
            if ( $Command ){
                [string] $com = $Command
            } else {
                if ( isLinkHttp $href ){
                    [string] $com = "Start-Process -FilePath"
                } elseif ($AsFileObject) {
                    [string] $com = "Get-Item -LiteralPath"
                } else {
                    [string] $com = "Invoke-Item"
                }
            }
            [string] $com = "$com ""$href"""
            Write-Host $com
            if ( $DryRun ){
                if ( $BackGround ){
                    try {
                        [string] $com = "Start-Job -ScriptBlock { Invoke-Expression -Command $com -ErrorAction $ErrAction }"
                    } catch {
                        $errCounter++
                    }
                    if ( $errCounter -ge $LimitErrorCount ){
                        Write-Warning "The number of errors exceeded the -LimitErrorCount = $LimitErrorCount times."
                        return
                    }
                }
                #Write-Output $com
            } else {
                if ( $BackGround ){
                    $executeCom = {
                        param( [string] $strCom, [string] $strErrAct )
                        try {
                            Invoke-Expression -Command $strCom -ErrorAction $strErrAct
                        } catch {
                            throw
                        }
                    }
                    try {
                        Start-Job -ScriptBlock $executeCom -ArgumentList $com, $ErrAction -ErrorAction $ErrAction
                    } catch {
                        $errCounter++
                    }
                    if ( $errCounter -ge $LimitErrorCount ){
                        Write-Warning "The number of errors exceeded the -LimitErrorCount = $LimitErrorCount times."
                        return
                    }
                } else {
                    try {
                        Invoke-Expression -Command $com -ErrorAction $ErrAction
                    } catch {
                        $errCounter++
                    }
                    if ( $errCounter -ge $LimitErrorCount ){
                        Write-Warning "The number of errors exceeded the -LimitErrorCount = $LimitErrorCount times."
                        return
                    }
                }
            }
        }
    }
}
# set alias
[String] $tmpAliasName = "i"
[String] $tmpCmdName   = "Invoke-Link"
[String] $tmpCmdPath = Join-Path `
    -Path $PSScriptRoot `
    -ChildPath $($MyInvocation.MyCommand.Name) `
    | Resolve-Path -Relative
if ( $IsWindows ){ $tmpCmdPath = $tmpCmdPath.Replace('\' ,'/') }
# is alias already exists?
if ((Get-Command -Name $tmpAliasName -ErrorAction SilentlyContinue).Count -gt 0){
    try {
        if ( (Get-Command -Name $tmpAliasName).CommandType -eq "Alias" ){
            if ( (Get-Command -Name $tmpAliasName).ReferencedCommand.Name -eq $tmpCmdName ){
                Set-Alias -Name $tmpAliasName -Value $tmpCmdName -PassThru `
                    | ForEach-Object{
                        Write-Host "$($_.DisplayName)" -ForegroundColor Green
                    }
            } else {
                throw
            }
        } elseif ( "$((Get-Command -Name $tmpAliasName).Name)" -match '\.exe$') {
            Set-Alias -Name $tmpAliasName -Value $tmpCmdName -PassThru `
                | ForEach-Object{
                    Write-Host "$($_.DisplayName)" -ForegroundColor Green
                }
        } else {
            throw
        }
    } catch {
        Write-Error "Alias ""$tmpAliasName ($((Get-Command -Name $tmpAliasName).ReferencedCommand.Name))"" is already exists. Change alias needed. Please edit the script at the end of the file: ""$tmpCmdPath""" -ErrorAction Stop
    } finally {
        Remove-Variable -Name "tmpAliasName" -Force
        Remove-Variable -Name "tmpCmdName" -Force
    }
} else {
    Set-Alias -Name $tmpAliasName -Value $tmpCmdName -PassThru `
        | ForEach-Object {
            Write-Host "$($_.DisplayName)" -ForegroundColor Green
        }
    Remove-Variable -Name "tmpAliasName" -Force
    Remove-Variable -Name "tmpCmdName" -Force
}
