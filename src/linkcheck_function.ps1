<#
.SYNOPSIS
    linkcheck - Broken link checker

    Test the urri connection specified in the argument.
    
    reference:
    - Invoke-WebRequest
      https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-7.2

    -Header: Recognize 1st column as filename, 2nd as href.
      The filename is added to the leftmost of output.
      The filename must not contain spaces. 

.LINK
    linkextract, linkcheck2

.PARAMETER Header
    Recognize 1st column as filename, 2nd as href.
    The filename is added to the leftmost of output.
    The filename must not contain spaces. 
    
    Output example:
    Case: -Header is specified
    [ng] index.html www.microsoft.com/unknownhost

    Case: -Header is not specified:
    [ng] www.microsoft.com/unknownhost

.PARAMETER VerboseOutput
    Regardless of errors, all input with [ng] or [ok] tag.

    Rerurn a list of broken links at the end of the output.

.PARAMETER WaitSeconds
    Sleep time (seconds) per link verification

.EXAMPLE
    cat uri-list.txt
    https://www.example.com/
    www.microsoft.com/unknownhost

    linkcheck www.microsoft.com/unknownhost
    Detect broken links.
    [ng] www.microsoft.com/unknownhost

.EXAMPLE
    cat uri-list.txt | linkcheck
    Detect broken links.
    [ng] www.microsoft.com/unknownhost

.EXAMPLE
    linkcheck (cat uri-list.txt) -WaitSeconds 1
    Detect broken links.
    [ng] www.microsoft.com/unknownhost

.EXAMPLE
    linkcheck (cat uri-list.txt) -VerboseOutput
    [ok] https://www.example.com/
    [ng] www.microsoft.com/unknownhost
    Detect broken links.
    [ng] www.microsoft.com/unknownhost

.EXAMPLE
    $uAry = @("https://www.example.com/","www.microsoft.com/unknownhost")
    linkcheck $uAry -VerboseOutput

    [ok] https://www.example.com/
    [ng] www.microsoft.com/unknownhost
    Detect broken links.
    [ng] www.microsoft.com/unknownhost

.EXAMPLE
    cat uri-list.txt
    a.html https://www.example.com/
    a.html www.microsoft.com/unknownhost

    cat uri-list.txt | linkcheck
    Detect broken links.
    [ng] a.html https://www.example.com/
    [ng] a.html www.microsoft.com/unknownhost

#>
function linkcheck {
    Param(
        [parameter(
            Mandatory=$True,
            Position=0,
            ValueFromPipeline=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]] $Uris,

        [parameter(Mandatory=$False)]
        [switch] $Header,
        
        [parameter(Mandatory=$False)]
        [int] $WaitSeconds = 1,
        
        [parameter(Mandatory=$False)]
        [switch] $VerboseOutput
    )
    # set uri
    if( $input.Count -gt 0 ){
        [string[]] $src = $input
    } else {
        [string[]] $src = $Uris
    }
    # set variables
    [string[]] $errAry = @()
    # main
    foreach($line in $src){
        if($Header){
            [string[]] $splitLine = $line.split(' ', 2)
            if($splitLine.Count -ne 2){
                Write-Error "Invalid line detected: $line" -ErrorAction Stop
            }
            [string] $uri  = $splitLine[0]
            [string] $href = $splitLine[1]
        } else {
            [string] $uri  = ''
            [string] $href = $line
        }
        # ad hock countermeasure
        # For some reason, the variable "$uri" may be $null
        # from pipline input
        if ($uri -ne $null) {
            $origErrActPref = $ErrorActionPreference
            try {
                $ErrorActionPreference = "SilentlyContinue"
                $Response = Invoke-WebRequest -Uri "$href"
                $ErrorActionPreference = $origErrActPref
                # This will only execute if the Invoke-WebRequest is successful.
                $StatusCode = $Response.StatusCode
                [string] $msg = "$uri $href"
                [string] $msg = "[ok] " + $msg.trim()
                if($VerboseOutput){Write-Host $msg -ForegroundColor Green}
            } catch {
                $StatusCode = $_.Exception.Response.StatusCode.value__
                [string] $msg = "$uri $href"
                [string] $msg = "[ng] " + $msg.trim()
                if($VerboseOutput){Write-Host $msg -ForegroundColor Yellow}
                $errAry += ,$msg
            } finally {
                $ErrorActionPreference = $origErrActPref
            }
            Start-Sleep -Seconds $WaitSeconds
        }
    }
    ## output error
    # ad hock countermeasure
    if ($uri -ne $null){
        if ($errAry){
            if ($Header){
                Write-Output "Detect broken links in $uri"
            } else {
                Write-Output "Detect broken links."
            }
            #Write-Output "----"
            foreach($e in $errAry){
                Write-Output "$e"
            }
        } else {
            if ($Header){
                Write-Output "No broken links in $uri"
            } else {
                Write-Output "No broken links."
            }
        }
    }
}
