<#
.SYNOPSIS
    fwatch - A filewatcher using LastWriteTime

    -Hash option: using "Get-FileHash -Algorithm SHA256"

    Note:
        Watch only changed, not created, not deleted.


.PARAMETER Path
    Input file or directory

.PARAMETER Action
    ScriptBlock when change watched

.PARAMETER Interval
    Loop interval

.PARAMETER Hash
    Use FileHash for detect changed

.PARAMETER Quiet
    Do not show status info

.PARAMETER Log
    Output Log

.PARAMETER OutOnlyLog
    Action | Out-Null

.PARAMETER Recurse
    Recurse Directory


.EXAMPLE
fwatch -Path a.md -Action {cat a.md | md2html > a.html; ii a.html}

Watching... B51565E0F209DC192494C97989D68A299D790ED25EDB16FE888AC115D62E0D4C .\a.md

2021-11-12T22:42:51.081 Changed: .\a.md

=====
watch only a.md file and if changed, run action

.EXAMPLE
fwatch -Path . -Action {cat a.md | md2html > a.html; ii a.html} -Recurse

Watching... 3F86ECD8F17648F29E94242E8E912CFF8CBA5482C7590C1DC6F02AADEEF9FF24 .\a.html
Watching... 3D1725FC9C79C17610B14B259DE5E2A74E37C603A1DCE568B3B1751F63BFC624 .\a.md
Watching... 6B81AB24022CC2EEE6C50B2A0A470FBE5781F3F1D0E13D441F0F815C739CE87A .\a.png
Watching... 9F1407434FE32DD86F52E4D5DA58D5C54D3A6CF4689018F4391C22F2CF76633E .\a071558.md
Watching... A595ECBF50211699F1F501253885E2E169B4E459B9C9C867F782F4094F8D77B3 .\fibo.ps1
Watching... A595ECBF50211699F1F501253885E2E169B4E459B9C9C867F782F4094F8D77B3 .\fuga\b.md

2021-11-12T22:43:39.458 Changed: .\a.md
2021-11-12T22:43:40.610 Changed: .\a.html


=====
watch current directory and recurse directory


#>
function fwatch {
    Param(
        [Parameter(Position=0, Mandatory=$True)]
        [Alias('p')]
        [string] $Path,

        [Parameter(Position=1, Mandatory=$False)]
        [Alias('a')]
        [ScriptBlock] $Action,

        [Parameter(Mandatory=$False)]
        [string] $Interval = 1,

        [Parameter(Mandatory=$False)]
        [string] $Log,

        [Parameter(Mandatory=$False)]
        [string] $Message,

        [Parameter(Mandatory=$False)]
        [Alias('r')]
        [switch] $Recurse,

        [Parameter(Mandatory=$False)]
        [switch] $Hash,

        [Parameter(Mandatory=$False)]
        [switch] $OutOnlyLog,

        [Parameter(Mandatory=$False)]
        [Alias('q')]
        [switch] $Quiet
    )
    ## set log message
    [string]$scriptLine = "fwatch -Path $Path"
    if($Action) {$scriptLine += " -Action {$Action}"}
    if($Log)    {$scriptLine += " -Log $Log"}
    if($Recurse){$scriptLine += " -Recurse"}
    ## set Change detector
    if($Hash){
        ## detect file change by FileHash
        [ScriptBlock]$hashDetector = {(Get-FileHash -Algorithm SHA256 -LiteralPath $objFile).Hash}
    } else{
        ## detect file change by LastWriteTime
        [ScriptBlock]$hashDetector = {$objFile.LastWriteTime.ToString('yyyy-MM-ddTHH:mm:ss.fff')}
    }
    ## set file list
    if($Recurse){
        [ScriptBlock]$fileList = {@(Get-Childitem -Path $Path -File -Recurse)}
    } else {
        [ScriptBlock]$fileList = {@(Get-Childitem -Path $Path -File)}
    }
    #echo $objFiles.GetType()
    ## Output Log Header
    if(-not $Quiet){
        Write-Output "$scriptLine"
        Write-Output ''
    }
    ## create file hash(lastwritetime) dictionary
    $objFiles = & $fileList
    $fileHash = @{}
    foreach ($objFile in $objFiles) {
        [string]$hashVal = & $hashDetector
        [string]$relPath = Resolve-Path -LiteralPath $objFile -Relative
        $fileHash[$relPath] = $hashVal
    }
    ## main
    while ($true) {
        Start-Sleep -Second $interval
        $objFiles = & $fileList
        foreach ($objFile in $objFiles) {
            [string]$hashVal = & $hashDetector
            [string]$changeDatetime = $hashVal
            [string]$relPath = Resolve-Path -LiteralPath $objFile -Relative
            if( -not $fileHash.Contains($relPath) ){
                ## Case: file is not contains in the dictionary -> Create
                if(-not $Quiet){
                    $writeLine = "$changeDatetime Created... $relPath"
                    if($Message){ $writeLine = $writeLine + " $Message" }
                    Write-Output $writeLine
                }
                $fileHash[$relPath] = $hashVal
                if($OutOnlyLog){
                    if($Action){& $Action | Out-Null}
                } else {
                    if($Action){& $Action}
                }
            } elseif ($fileHash[$relPath] -ne $hashVal) {
                ## Case: file contains in the dictionary -> Check Change
                if(-not $Quiet){
                    $writeLine = "$changeDatetime Changed... $relPath"
                    if($Message){ $writeLine = $writeLine + " $Message" }
                    Write-Output $writeLine
                }
                $fileHash[$relPath] = $hashVal
                if($OutOnlyLog){
                    if($Action){& $Action | Out-Null}
                } else {
                    if($Action){& $Action}
                }
            }
        }
    }
}
