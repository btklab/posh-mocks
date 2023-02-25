<#
.SYNOPSIS
    i - Invoke-Links - Read and execute links written in a text file.

    This function is similar to execute shortcut (ii shortcut.lnk),
    but also open the file location in explorer, or open the link
    with any command.

    If you want to open a file as a link, but sometimes you want to
    open the "file location" in explorer, you can do it with one file.
    (For those who don't want to create two shortcuts for files and
    directories)

    The link execution app can be any command if "-Command" option is
    specified, otherwise follow the rules below:

    - Link beginning with "http" or "www": Start-Process (default browser)
    - Directory and others: Invoke-Item <link>

    Shortcuts writtein in a text file may or may not be enclosed in
    single/double quotes.

    Multiple links(lines) in a file available. Lines that empty or beginning
    with "#" are skipped.


    Usage:
        i                  ... Equivalent to Get-ChildItem .
        i <dir>            ... Get-ChildItem <dir>
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

.EXAMPLE
    i             ... Equivalent to Get-ChildItem .
    i <dir>            ... Get-ChildItem <dir>
    i <file>           ... Invoke-Item <links-writtein-in-text-file>
    i <file> <command> ... command <links-writtein-in-text-file>
    i <file> -l or -Location ... Open <link> location in explorer
    i <file> -q or -DryRun   ... DryRun (listup links)
    i <file> -e or -Edit     ... Edit <linkfile> using text editor

.EXAMPLE
    cat ./link/rmarkdown_site.txt
    "C:\Users\btklab\cms\repos\rmarkdown-skeleton\docs\index.html"

    # Get-ChildItem <dir>
    i ./link/
    i ./link/ | Format-Wide
    Mode         LastWriteTime Length Name
    ----         ------------- ------ ----
    -a---  2023/02/07    23:21    102 hoge.md
    -a---  2023/02/07    23:31     97 about_Invoke-Item.txt
    -a---  2023/02/07    20:58     25 google


    # dry run
    PS > i ./link/rmarkdown_site.txt -q
    .\link\rmarkdown.txt
    Invoke-Item 'C:\Users\btklab\cms\repos\rmarkdown-skeleton\docs\index.html'


    # open index.html in default browser
    PS > i ./link/rmarkdown_site.txt


    # open index.html in VSCode
    PS > i ./link/rmarkdown_site.txt code


    # open index.html file location in explorer
    PS > i ./link/rmarkdown_site.txt -l


.LINK
    linkcheck

#>
function i {

    param (
        [Parameter( Mandatory=$False, Position=0 )]
        [Alias('f')]
        [string] $File,
        
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
        [switch] $LinkCheck,

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
        if ( $isWindows ){
            notepad $fpath
        } else {
            vi $fpath
        }
        return
    }
    # set links
    if ( $File ){
        # is path directory?
        if ( -not (isLinkHttp $File) ){
            if ( Test-Path -LiteralPath $File -PathType Container){
                if ( $DryRun ){
                    Write-Output $File
                    return
                }
                Get-ChildItem -LiteralPath $File
                return
            }
        }
        # is file exist?
        if ( -not ( Test-Path -LiteralPath $File ) ){
            if ( $Edit ){
                editFile $File
                return
            } else {
                # about Read-Host
                # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/read-host
                [string] $resp = Read-Host "$File is not exists. Create and Edit? (y/n)"
                if ( $resp -eq 'y' ){
                    editFile $File
                }
                return
            }
        }
        # edit file mode
        if ( $Edit ){
            editFile $File
            return
        }
        # is windows shortcut?
        [string] $ext = (Get-Item -LiteralPath $File).Extension
        if ( ( $ext -eq '.lnk' ) -or ( $ext -eq '.url') ){
            if ( $DryRun ){
                "Invoke-Item -LiteralPath $File"
                return
            } else {
                Invoke-Item -LiteralPath $File
                return
            }
        }
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
    }
    if ( -not $File -or -not $linkLines ){
        # Get-ChildItem .
       Get-ChildItem -LiteralPath '.'
       return
    }
    if ( $DryRun ){
        Write-Host "$File" -ForegroundColor Green
    }
    if ( $Location ){
        $linkLines
        if ( $DryRun ){ return }
        Invoke-Item -LiteralPath $linkLines
        return
    }
    foreach ( $hlink in $linkLines ){
        # execute command
        if ( $Command ){
            [string] $com = $Command
        } else {
            if ( isLinkHttp $hlink ){
                [string] $com = "Start-Process -FilePath"
            } else {
                [string] $com = "Invoke-Item"
            }
        }
        Write-Debug $hlink
        $com = "$com '$hlink'"
        if ( $DryRun ){
            Write-Output $com
        } else {
            Invoke-Expression -Command $com
        }
    }
}
