<#
.SYNOPSIS
    i : Invoke-Link - Open links written in a text file

    Open links written in a text file.

    - If a text file (.txt, .md, ...) is specified,
      open each line as link in default application
        - Link beginning with "http" or "www":
            - Start-Process (default browser)
        - Directory and others:
            - Invoke-Item <link>
    - If a link file (.lnk) is specified, open the link in explorer
    - If a PowerShell Script file (.ps1) is specified,
      execute the script in current process:
        - able to use dot sourcing functions in current process
        - Specify the absolute file path in the text file as possible.
          Or Note that when specifying a relative path, the root is the
          location of the current process

    Multiple links(lines) in a file available.
    Lines that empty or beginning with "#" are skipped.

    The link execution app can be any command if -Command option is
    specified.

    Links written in a text file may or may not be enclosed in
    single/double quotes.

    If -l or -Location specified, open the file location in explorer

    Environment variables such as ${HOME} can be used for path strings.

    Usage:
        i                  ... Equivalent to Invoke-Item .
        i <dir>            ... Invoke-Item <dir>
        i <file>           ... Invoke-Item <links-writtein-in-text-file>
        i <file> <command> ... command <links-writtein-in-text-file>
        i <file> -l or -Location ... Open <link> location in explorer
        i <file> -q or -DryRun   ... DryRun (listup links)
        i <file> -e or -Edit     ... Edit <linkfile> using text editor

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
    i                  ... Equivalent to Invoke-Item .
    i <dir>            ... Invoke-Item <dir>
    i <file>           ... Invoke-Item <links-writtein-in-text-file>
    i <file> <command> ... command <links-writtein-in-text-file>
    i <file> <command> -b    ... run command in background
    i <file> -l or -Location ... Open <link> location in explorer
    i <file> -q or -DryRun   ... DryRun (listup links)
    i <file> -e or -Edit     ... Edit <linkfile> using text editor

.EXAMPLE
    cat ./link/rmarkdown_site.txt
    "C:/Users/path/to/the/index.html"

    # dry run
    i ./link/rmarkdown_site.txt -q
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
    
    ## Filee Recursive search
    i ./work/google-* -Recurse

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

.LINK
    linkcheck

#>
function Invoke-Link {

    param (
        [Parameter( Mandatory=$True, Position=0 )]
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
        [ValidateSet(
            "Break", "Ignore", "SilentlyContinue",
            "Suspend", "Continue", "Inquire", "Stop" )]
        [string] $ErrAction = "Stop",
        
        [Parameter( Mandatory=$False )]
        [Alias('q')]
        [switch] $DryRun
    )
    # private functions
    function isCommentOrEmptyLine ( [string] $line ){
        [bool] $coeFlag = $False
        if ( $line -match '^#' )   { $coeFlag = $True }
        if ( $line -match '^\s*$' ){ $coeFlag = $True }
        return $coeFlag
    }
    function isLinkHttp ( [string] $line ){
        [bool] $httpFlag = $False
        if ( $line -match '^https*:' ){ $httpFlag = $True }
        if ( $line -match '^www\.' )  { $httpFlag = $True }
        return $httpFlag
    }
    function isLinkAlive ( [string] $uri ){
        try {
            $origErrActPref = $ErrorActionPreference
            $ErrorActionPreference = "SilentlyContinue"
            $Response = Invoke-WebRequest -Uri "$uri"
            $ErrorActionPreference = $origErrActPref
            # This will only execute if the Invoke-WebRequest is successful.
            $StatusCode = $Response.StatusCode
            return $True
        } catch {
            $StatusCode = $_.Exception.Response.StatusCode.value__
            return $False
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
    foreach ( $f in $Files){
        # interpret Paths containing wildcards
        if ( Test-Path -Path $f -PathType Container){
            [string[]] $tmpFiles = Get-Item -Path $f `
                | Resolve-Path -Relative
        } else {
            [string[]] $tmpFiles = Get-ChildItem -Path $f -Recurse:$Recurse `
                | Resolve-Path -Relative
        }
        # set links
        foreach ( $File in $tmpFiles ){
            # is path directory?
            if ( -not (isLinkHttp $File) ){
                if ( Test-Path -LiteralPath $File -PathType Container){
                    if ( $DryRun ){
                        Write-Output $File
                        continue
                    }
                    # return file paths
                    Invoke-Item -LiteralPath $File
                    continue
                }
            }
            # is file exist?
            if ( -not ( Test-Path -LiteralPath $File ) ){
                if ( $Edit ){
                    # about Read-Host
                    # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/read-host
                    [string] $resp = Read-Host "$File is not exists. Create and Edit? (y/n)"
                    if ( $resp -eq 'y' ){ editFile $File }
                    continue
                }
                Invoke-Item -LiteralPath $File
                continue
            }
            # edit file mode
            if ( $Edit ){
                editFile $File
                continue
            }
            # is windows shortcut?
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
            ## is -not shortcut and -not ps1 script?
            [string[]] $linkLines = Get-Content -LiteralPath $File -Encoding utf8 `
                | ForEach-Object {
                    [string] $linkLine = $_
                    if ( isCommentOrEmptyLine $linkLine ){
                        # pass
                    } else {
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
            if ( $Edit ){ continue }
            if ( -not $linkLines ){
                if ( Test-Path -LiteralPath $File -PathType Container){ continue }
                "Could not find links in file: $File" | Write-Error -ErrorAction Stop; continue
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
        }
        if ( $Location -and -not $Command ){
            continue
        }
        foreach ( $hlink in $linkLines ){
            # execute command
            if ( $Command ){
                [string] $com = $Command
            } else {
                if ( isLinkHttp $hlink ){
                    [string] $com = "Start-Process -FilePath"
                } elseif ($AsFileObject) {
                    [string] $com = "Get-Item -LiteralPath"
                } else {
                    [string] $com = "Invoke-Item"
                }
            }
            Write-Debug $hlink
            [string] $com = "$com ""$hlink"""
            if ( $DryRun ){
                if ( $BackGround ){
                    [string] $com = "Start-Job -ScriptBlock { Invoke-Expression -Command $com -ErrorAction $ErrAction }"
                }
                Write-Output $com
            } else {
                if ( $BackGround ){
                    Start-Job -ScriptBlock { Invoke-Expression -Command $com -ErrorAction $ErrAction }
                } else {
                    Invoke-Expression -Command $com -ErrorAction $ErrAction
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
