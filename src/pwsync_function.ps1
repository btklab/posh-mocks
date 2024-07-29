<#
.SYNOPSIS
    pwsync - Robust File Copy for Windows using robocopy.exe

        pwsync <source> <destination> [-MIR] [options] [-Exec|-Echo|-DryRun|-Quit]

    Limitation:
        Only for Windows OS, UTF-8

    Option:
        -Create: Creates a directory tree and zero-length files only
        -Quit: test args (not execute) (default)
        -L|-DryRun: dry run (not execute)
        -Echo|-EchoCommand: display robocopy command (not execute)
        -Exec|-Execute: execute robocopy command
            Does not run unless "-Execute" switch is specified

    Usage:
        # 1. init (Creates a directory tree and zero-length files only)
        #  eq: robocpy "src" "dst" /MIR /DCOPY:DAT /CREATE

            pwsync src dst -Create [-Quit]
            pwsync src dst -Create -DryRun
            pwsync src dst -Create -Execute

        # 2-1. copy
        #  eq: robocopy "src" "dst" *.* /COPY:DAT /DCOPY:DAT /R:5 /W:5 /UNILOG:NUL /TEE

            pwsync src dst [-Quit]
            pwsync src dst -DryRun
            pwsync src dst -Exec

        # 2-2. mirror
        #  eq: robocopy "src" "dst" *.* /COPY:DAT /DCOPY:DAT /R:5 /W:5 /UNILOG:NUL /TEE
        #  eq: rsync -av --delete (using Linux rsync command)

            pwsync src dst -MIR [-Quit]
            pwsync src dst -MIR -DryRun
            pwsync src dst -MIR -Exec

    Full options:
        [-f|-Source]
        [-t|-Destination]
        [-Files = '*.*']
        [-MIR|-Mirror] or [-d|-Delete]
        [-Compress]
        [-R|-Retry = 5]
        [-W|-WaitTime = 5]
        [-Mot]
        [-Mon]
        [-LEV|-Level]
        [-E|-Empty]
        [-S|-ExcludeEmpty]
        [-Log]
        [-XF|-ExcludeFiles]
        [-XD|-ExcludeDirs]
        [-Init] or [-Create]
        [-IncludeSystemFileAndHiddenFile]
        [-ExcludeSystemFileAndHiddenFile]
        
        [-AttribFullBackup]
        [-A|-AttribDifferencialBackup]
        [-M|-AttribIncrementalBackup]
        [-DeleteSystemAndHiddenAttribFromDest] avoide destination becomes hidden

        [-MAXAGE|-ExcludeLastWriteDateOlderEqual <n> or YYYYMMDD]
        [-MINAGE|-ExcludeLastWriteDateNewerEqual <n> or YYYYMMDD]
        [-MAXLAD|-ExcludeLastAccessDateOlderEqual <n> or YYYYMMDD]
        [-MINLAD|-ExcludeLastAccessDateNewerEqual <n> or YYYYMMDD]

        [-Quit]
        [-L|-DryRun]
        [-Echo|-EchoCommand]
        [-exec|-Execute]

        [-h|-Help]

    Thanks:
        Robosync
        https://n-archives.net/software/robosync/

        robocopy - learn.microsoft.com
        https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy

        attrib - learn.microsoft.com
        https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/attrib

.EXAMPLE
    # 1. init (Creates a directory tree and zero-length files only)
    #  eq: robocpy "src" "dst" /MIR /DCOPY:DAT /CREATE

        pwsync src dst -Create [-Quit]
        pwsync src dst -Create -DryRun
        pwsync src dst -Create -Execute

    # 2-1. copy
    #  eq: robocopy "src" "dst" *.* /COPY:DAT /DCOPY:DAT /R:5 /W:5 /UNILOG:NUL /TEE

        pwsync src dst [-Quit]
        pwsync src dst -DryRun
        pwsync src dst -Exec

    # 2-2. mirror
    #  eq: robocopy "src" "dst" *.* /COPY:DAT /DCOPY:DAT /R:5 /W:5 /UNILOG:NUL /TEE
    #  eq: rsync -av --delete (using Linux rsync command)

        pwsync src dst -MIR [-Quit]
        pwsync src dst -MIR -DryRun
        pwsync src dst -MIR -Exec

.EXAMPLE
    # Copy only directories (/QUIT)
    pwsync src dst -MIR -E -XF *.*
    robocopy "src" "dst" *.* /L /MIR /COPY:DAT /DCOPY:DAT /R:5 /W:5 /UNILOG:NUL /TEE /XF *.* /E /QUIT

.EXAMPLE
    # Monitors the source and runs again in m minutes if changes are detected.
    pwsync src dst -MIR -Mot 1
    robocopy "src" "dst" *.* /L /MIR /MOT:1 /COPY:DAT /DCOPY:DAT /R:5 /W:5 /UNILOG:NUL /TEE /QUIT

    # Monitors the source and runs again in m minutes if changes are detected
    # or Monitors the source and runs again when more than n changes are detected.
    pwsync src dst -MIR -Mot 1 -Mon 5
    robocopy "src" "dst" *.* /L /MIR /MOT:1 /MON:5 /COPY:DAT /DCOPY:DAT /R:5 /W:5 /UNILOG:NUL /TEE /QUIT

.EXAMPLE
    # Incremental backup

    ## !! Keep the destination directory separate from the full backup directory

    ## full backup: -AttribFullBackup (backup and clear attrib)
    pwsync src dst -AttribFullBackup
    robocopy "src" "dst" *.* /L /COPY:DAT /DCOPY:DAT /R:5 /W:5 /UNILOG:NUL /TEE /E /QUIT
    attrib -a "src\*.*" /s

    ## incremental backup: -AttribIncrementalBackup (robocopy /M: copy and clear attrib)
    pwsync src gen -AttribIncrementalBackup
    robocopy "src" "gen" *.* /L /COPY:DAT /DCOPY:DAT /R:5 /W:5 /UNILOG:NUL /TEE /M /QUIT

.EXAMPLE
    # Differencial backup

    ## !! Keep the destination directory separate from the full backup directory

    ## full backup: -AttribFullBackup (backup and clear attrib)
    pwsync src dst -AttribFullBackup -Echo
    robocopy "src" "dst" *.* /L /COPY:DAT /DCOPY:DAT /R:5 /W:5 /UNILOG:NUL /TEE /E /QUIT
    attrib -a "src\*.*" /s

    ## differencial backup: -AttribDifferencialBackup (robocopy /A: copy but not clear attrib)
    pwsync src gen -AttribDifferencialBackup -Echo
    robocopy "src" "gen" *.* /L /COPY:DAT /DCOPY:DAT /R:5 /W:5 /UNILOG:NUL /TEE /A /QUIT


    # thanks
    # https://n-archives.net/software/robosync/articles/incremental-differential-backup/

.EXAMPLE
    # Exclude files
    # note that "n days ago" means the same hour, minute, and second
    # n days before the date and time at the time of execution.
    # On the other hand, "YYYYMMDD" means 00:00:00 on the specified date.
    
    # Exclude LastWriteDate older equal 3 days ago or 2023-03-24
    pwsync src dst -MAXAGE 3
    pwsync src dst -ExcludeLastWriteDateOlderEqual 3

    pwsync src dst -MAXAGE 20230324
    pwsync src dst -ExcludeLastWriteDateOlderEqual 20230324


    # Exclude LastWriteDate newer equal 3 days ago or 2023-03-24
    pwsync src dst -MINAGE 3
    pwsync src dst -ExcludeLastWriteDateNewerEqual 3

    pwsync src dst -MINAGE 20230324
    pwsync src dst -ExcludeLastWriteDateNewerEqual 20230324

        
    # Exclude LastAccessDate older equal 3 days ago or 2023-03-24
    pwsync src dst -MAXLAD 3
    pwsync src dst -ExcludeLastAccessDateOlderEqual 3

    pwsync src dst -MAXLAD 20230324
    pwsync src dst -ExcludeLastAccessDateOlderEqual 20230324


    # Exclude LastAccessDate newer equal 3 days ago or 2023-03-24
    pwsync src dst -MINLAD 3
    pwsync src dst -ExcludeLastAccessDateNewerEqual 3

    pwsync src dst -MINLAD 20230324
    pwsync src dst -ExcludeLastAccessDateNewerEqual 20230324

.LINK
    Robosync
    https://n-archives.net/software/robosync/

    robocopy - learn.microsoft.com
    https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy

    attrib - learn.microsoft.com
    https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/attrib

#>
function pwsync {

    param (
        [Parameter( Mandatory=$True, Position=0 )]
        [Alias('f')]
        [string] $Source,
        
        [Parameter( Mandatory=$True, Position=1 )]
        [Alias('t')]
        [string] $Destination,
        
        [Parameter( Mandatory=$False )]
        [string[]] $Files = '*.*',
        
        [Parameter( Mandatory=$False )]
        [Alias('MIR')]
        [switch] $Mirror,
        
        [Parameter( Mandatory=$False )]
        [switch] $Compress,
        
        [Parameter( Mandatory=$False )]
        [Alias('d')]
        [switch] $Delete,
        
        [Parameter( Mandatory=$False )]
        [Alias('R')]
        [int] $Retry = 5,
        
        [Parameter( Mandatory=$False )]
        [Alias('W')]
        [int] $WaitTime = 5,
        
        [Parameter( Mandatory=$False )]
        [int] $Mot,
        
        [Parameter( Mandatory=$False )]
        [int] $Mon,
        
        [Parameter( Mandatory=$False )]
        [Alias('LEV')]
        [int] $Level,
        
        [Parameter( Mandatory=$False,
            HelpMessage="Specifies the maximum file age (to exclude files older than n days or date)." )]
        [ValidateScript({ $_ -ge 0 })]
        [Alias('MAXAGE')]
        [int] $ExcludeLastWriteDateOlderEqual,
        
        [Parameter( Mandatory=$False,
            HelpMessage="Specifies the minimum file age (exclude files newer than n days or date)." )]
        [ValidateScript({ $_ -ge 0 })]
        [Alias('MINAGE')]
        [int] $ExcludeLastWriteDateNewerEqual,
        
        [Parameter( Mandatory=$False,
            HelpMessage="Specifies the maximum last access date (excludes files unused since n)." )]
        [ValidateScript({ $_ -ge 0 })]
        [Alias('MAXLAD')]
        [int] $ExcludeLastAccessDateOlderEqual,
        
        [Parameter( Mandatory=$False,
            HelpMessage="Specifies the minimum last access date (excludes files used since n) If n is less than 1900, n specifies the number of days. Otherwise, n specifies a date in the format YYYYMMDD." )]
        [ValidateScript({ $_ -ge 0 })]
        [Alias('MINLAD')]
        [int] $ExcludeLastAccessDateNewerEqual,
        
        [Parameter( Mandatory=$False )]
        [Alias('E')]
        [switch] $Empty,
        
        [Parameter( Mandatory=$False )]
        [Alias('S')]
        [switch] $ExcludeEmpty,
        
        [Parameter( Mandatory=$False )]
        [string] $Log,
        
        [Parameter( Mandatory=$False )]
        [Alias('XF')]
        [string[]] $ExcludeFiles,
        
        [Parameter( Mandatory=$False )]
        [Alias('XD')]
        [string[]] $ExcludeDirs,
        
        [Parameter( Mandatory=$False )]
        [switch] $Init,
        
        [Parameter( Mandatory=$False )]
        [switch] $Create,
        
        [Parameter( Mandatory=$False )]
        [switch] $IncludeSystemFileAndHiddenFile,
        
        [Parameter( Mandatory=$False )]
        [switch] $ExcludeSystemFileAndHiddenFile,
        
        [Parameter( Mandatory=$False )]
        [switch] $DeleteSystemAndHiddenAttribFromDest,
        
        [Parameter( Mandatory=$False )]
        [Alias('Z')]
        [switch] $RestartableMode,
        
        [Parameter( Mandatory=$False )]
        [switch] $AttribFullBackup,
        
        [Parameter( Mandatory=$False )]
        [Alias('A')]
        [switch] $AttribDifferencialBackup,
        
        [Parameter( Mandatory=$False )]
        [Alias('M')]
        [switch] $AttribIncrementalBackup,
        
        [Parameter( Mandatory=$False )]
        [Alias('echo')]
        [switch] $EchoCommand,
        
        [Parameter( Mandatory=$False )]
        [Alias('exec')]
        [switch] $Execute,
        
        [Parameter( Mandatory=$False )]
        [Alias('L')]
        [switch] $DryRun,
        
        [Parameter( Mandatory=$False )]
        [switch] $Quit,
        
        [Parameter( Mandatory=$False )]
        [Alias('h')]
        [switch] $Help
    )

    # init variable
    [string] $defaultOpt = '/QUIT'
    # private functions
    # is file exists?
    function isFileExists ([string]$f){
        if(-not (Test-Path -LiteralPath "$f")){
           return $True
        } else {
            return $False
        }
    }
    # is command exist?
    function isCommandExist ([string]$cmd) {
        try { Get-Command $cmd -ErrorAction Stop > $Null
            return $True
        } catch {
            return $False
        }
    }

    # test robocopy command
    if ( -not (isCommandExist robocopy) ){
        Write-Eroor "Robocopy is not found." -ErrorAction Stop
    }

    # test paths
    if ( -not (Test-Path -LiteralPath $Source -PathType Container) ){
        Write-Error "$Source is not a directory or not exists." -ErrorAction Stop
    }
    if ( -not (Test-Path -LiteralPath $Destination -PathType Container) ){
        Write-Error "$Destination is not a directory or not exists." -ErrorAction Stop
    }

    # set fullpath
    [string] $srcDir = (Get-Item -LiteralPath $Source).FullName
    [string] $srcDir = $srcDir -replace '\\$', ''
    [string] $dstDir = (Get-Item -LiteralPath $Destination).FullName
    [string] $dstDir = $dstDir -replace '\\$', ''

    [string[]] $roboArgs = @()
    if ( $Help ) {
        $roboArgs += '/?'
        Start-Process -FilePath Robocopy.exe -ArgumentList $roboArgs -NoNewWindow -Wait
        return
    }
    if ( $True ){
        # basic args
        $roboArgs += """$srcDir"""
        $roboArgs += """$dstDir"""
    }
    if ( $Files ){
        [string] $namStr = $Files -join " "
        $roboArgs += "$namStr"
    }
    if ( $DryRun ){
        $roboArgs += "/L"
    }
    if ( $Quit ){
        $roboArgs += "/QUIT"
    }
    if ( -not ( $Execute )){
        if ( ( -not $DryRun ) -and ( -not $Quit) ){
            # default
            $roboArgs += $defaultOpt
        }
    }
    if ( $Mirror -or $Delete -or $Init -or $Create ){
        $roboArgs += "/MIR"
    }
    if ( $RestartableMode ){
        $roboArgs += "/Z"
    }
    if ( $Compress ){
        $roboArgs += "/COMPRESS"
    }
    if ( $Init -or $Create ){
        $roboArgs += "/CREATE"
    }
    if ( $True ){
        $roboArgs += "/COPY:DAT"
        $roboArgs += "/DCOPY:DAT"
    }
    if ( $ExcludeLastWriteDateOlderEqual ){
        $roboArgs += "/MAXAGE:$ExcludeLastWriteDateOlderEqual"
    }
    if ( $ExcludeLastWriteDateNewerEqual ){
        $roboArgs += "/MINAGE:$ExcludeLastWriteDateNewerEqual"
    }
    if ( $ExcludeLastAccessDateOlderEqual ){
        $roboArgs += "/MAXLAD:$ExcludeLastAccessDateOlderEqual"
    }
    if ( $ExcludeLastAccessDateNewerEqual ){
        $roboArgs += "/MINLAD:$ExcludeLastAccessDateNewerEqual"
    }
    if ( $Mot ){
        $roboArgs += "/MOT:$Mot"
    }
    if ( $Mon ){
        $roboArgs += "/MON:$Mon"
    }
    if ( $Retry ){
        $roboArgs += "/R:$Retry"
    }
    if ( $WaitTime ){
        $roboArgs += "/W:$WaitTime"
    }
    if ( $True ){
        # compartible for UTF-8
        $roboArgs += "/UNILOG:NUL"
        $roboArgs += "/TEE"
    }
    if ( $IncludeSystemFileAndHiddenFile ){
        $roboArgs += "/IA:SH"
    }
    if ( $ExcludeSystemFileAndHiddenFile ){
        $roboArgs += "/XA:SH"
    }
    if ( $Level ){
        $roboArgs += "/LEV:$Level"
    }
    if ( $Log ){
        $roboArgs += "/LOG:""$Log"""
    }
    if ( $ExcludeDirs ){
        [string] $exDirs = $ExcludeDirs -join " "
        $roboArgs += "/XD $exDirs"
    }
    if ( $ExcludeFiles ){
        [string] $exFiles = $ExcludeFiles -join " "
        $roboArgs += "/XF $exFiles"
    }
    if ( $Empty ){
        $roboArgs += "/E"
    }
    if ( $ExcludeEmpty ){
        $roboArgs += "/S"
    }
    if ( $AttribFullBackup ) {
        if ( -not $Empty ){ $roboArgs += "/E" }
        # clear attrib
        [string[]] $attribArgs = @()
        $attribArgs += "-a"
        $attribArgs += """$srcDir\*.*"""
        $attribArgs += "/s"
    }
    if ( $AttribDifferencialBackup ){
        #$roboArgs += "/S"
        $roboArgs += "/A"
    }
    if ( $AttribIncrementalBackup ){
        #$roboArgs += "/S"
        $roboArgs += "/M"
    }
    if ( $DeleteSystemAndHiddenAttribFromDest ){
        # clear attrib from dest
        [string[]] $destAttribArgs = @()
        $destAttribArgs += "-s"
        $destAttribArgs += "-h"
        $destAttribArgs += """$dstDir"""
    }
    # execute
    if ( $EchoCommand ){
        "robocopy $roboArgs"
        if ( $AttribFullBackup ){
            "attrib $attribArgs"
        }
        if ( $DeleteSystemAndHiddenAttribFromDest ){
            "attrib $destAttribArgs"
        }
        return
    } else {
        Start-Process -FilePath Robocopy.exe -ArgumentList $roboArgs -NoNewWindow -Wait
        if ( $AttribFullBackup ){
            Start-Process -FilePath attrib.exe -ArgumentList $attribArgs -NoNewWindow -Wait
        }
        if ( $DeleteSystemAndHiddenAttribFromDest ){
            Start-Process -FilePath attrib.exe -ArgumentList $destAttribArgs -NoNewWindow -Wait
        }
        return
    }
}
