<#
.SYNOPSIS
    tenki - Open tenki.jp or jma.go.jp in browser.

    Open Hyogo/Japan weather reports in browser.

    Usage:
        tenki
            ... open tenki.jp forecast and map

        tenki -jma
            ... open jma.go.jp forecast and map
        
        tenki -All
    
    Open pages:
        The weather information to be opened can
        be specified indivisually.
        "-All" switch to retrieve all information.

            [-f|-Forecast] (default)
            [-r|-Radar]
            [-c|-Cloud]
            [-a|-Amedas]
            [-m|-Map] (default)
            [-t|-Typhoon]
            [-w|-Warning]
            [-n|-News]
            [-Top]
            [-Rss]
            [-All]

#>
function tenki {
    param (
        [Parameter(Mandatory=$False)]
        [switch] $Jma,
        
        [Parameter(Mandatory=$False)]
        [switch] $NotBrowse,
        
        [Parameter(Mandatory=$False)]
        [switch] $All,
        
        [Parameter(Mandatory=$False)]
        [Alias('f')]
        [switch] $Forecast,
        
        [Parameter(Mandatory=$False)]
        [Alias('r')]
        [switch] $Radar,
        
        [Parameter(Mandatory=$False)]
        [Alias('c')]
        [switch] $Cloud,
        
        [Parameter(Mandatory=$False)]
        [Alias('a')]
        [switch] $Amedas,
        
        [Parameter(Mandatory=$False)]
        [Alias('m')]
        [switch] $Map,
        
        [Parameter(Mandatory=$False)]
        [switch] $Map24,
        
        [Parameter(Mandatory=$False)]
        [Alias('t')]
        [switch] $Typhoon,
        
        [Parameter(Mandatory=$False)]
        [Alias('w')]
        [switch] $Warning,
        
        [Parameter(Mandatory=$False)]
        [Alias('n')]
        [switch] $News,
        
        [Parameter(Mandatory=$False)]
        [switch] $Top,
        
        [Parameter(Mandatory=$False)]
        [switch] $Firefox,
        
        [Parameter(Mandatory=$False)]
        [switch] $Chrome,
        
        [Parameter(Mandatory=$False)]
        [switch] $Edge,
        
        [Parameter(Mandatory=$False)]
        [switch] $Rss,
        
        [Parameter(Mandatory=$False)]
        [switch] $Global,
        
        [Parameter(Mandatory=$False)]
        [int] $MaxResults = 20
    )
    # private function
    function isCommandExist ([string]$cmd) {
        try { Get-Command $cmd -ErrorAction Stop > $Null
            return $True
        } catch {
            return $False
        }
    }
    # set browser
    if ( $Firefox ){
        [string] $webBrowser = 'C:\Program Files\Mozilla Firefox\firefox.exe'
    } elseif ( $Chrome ){
        [string] $webBrowser = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
    } elseif ( $Edge ){
        [string] $webBrowser = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
    } else {
        [string] $webBrowser = 'Default'
    }
    # rss feed
    if ( $Rss ){
        if ( -not (isCommandExist rssfeed) ){
            Write-Error "command: rssfeed is not found." -ErrorAction Stop
        }
        [string] $urlRss = 'https://www.data.jma.go.jp/rss/jma.rss'
        rssfeed -uri $urlRss -MaxResults $MaxResults
        return
    }
    # set url
    $argHash = [ordered] @{}
    if ( $Jma ){
        $argHash["Forecast"] = 'https://www.data.jma.go.jp/gmd/cpd/twoweek/?fuk=63'
        $argHash["Map"]      = 'https://www.jma.go.jp/bosai/weather_map/'
        $argHash["Map24"]    = 'https://www.jma.go.jp/bosai/weather_map/'
        $argHash["Radar"]    = 'https://www.jma.go.jp/bosai/rain/rain.html'
        $argHash["Cloud"]    = 'https://www.jma.go.jp/bosai/map.html#5/34.5/137/&elem=ir&contents=himawari'
        $argHash["Amedas"]   = 'https://www.jma.go.jp/bosai/map.html#5/34.5/137/&elem=temp&contents=amedas&interval=60'
        $argHash["Typhoon"]  = 'https://www.jma.go.jp/bosai/map.html#5/34.5/137/&elem=root&typhoon=all&contents=typhoon'
        $argHash["Warning"]  = 'https://www.jma.go.jp/bosai/#pattern=default&area_type=offices&area_code=280000'
        $argHash["News"]     = 'https://www.jma.go.jp/jma/index.html'
        $argHash["Tweet"]    = 'https://twitter.com/JMA_bousai'
        $argHash["Top"]      = 'https://www.jma.go.jp/jma/index.html'
    } else {
        $argHash["Forecast"] = 'https://tenki.jp/forecast/6/31/6310/28100/10days.html'
        $argHash["Map"]      = 'https://tenki.jp/guide/chart/'
        $argHash["Map24"]    = 'https://tenki.jp/guide/chart/forecast/'
        $argHash["Radar"]    = 'https://tenki.jp/radar/6/31/'
        $argHash["Cloud"]    = 'https://tenki.jp/satellite/'
        $argHash["Amedas"]   = 'https://www.jma.go.jp/bosai/map.html#5/34.5/137/&elem=temp&contents=amedas&interval=60'
        $argHash["Typhoon"]  = 'https://tenki.jp/bousai/typhoon/'
        $argHash["Warning"]  = 'https://tenki.jp/bousai/warn/6/31/'
        $argHash["News"]     = 'https://tenki.jp/forecaster/'
        $argHash["Tweet"]    = 'https://twitter.com/tenkijp'
        $argHash["Top"]      = 'https://tenki.jp/'
    }
    if ( $Global ){
        $argHash["Forecast"]    = 'https://tenki.jp/world/'
        $argHash["Temperature"] = 'https://tenki.jp/world/temp.html'
        $argHash["Cloud"]       = 'https://tenki.jp/satellite/world/'
    }
    if ( $All ){
        [string[]] $argList = foreach ( $key in $argHash.Keys ){
            Write-Output $argHash[$key]
        }
    } else {
        [string[]] $argList = @()
        if ( $Forecast ){ [string[]] $argList += $argHash["Forecast"] }
        if ( $Radar )   { [string[]] $argList += $argHash["Radar"] }
        if ( $Cloud )   { [string[]] $argList += $argHash["Cloud"] }
        if ( $Map )     { [string[]] $argList += $argHash["Map"] }
        if ( $Map24 )   { [string[]] $argList += $argHash["Map24"] }
        if ( $Amedas )  { [string[]] $argList += $argHash["Amedas"] }
        if ( $Typhoon ) { [string[]] $argList += $argHash["Typhoon"] }
        if ( $Warning ) { [string[]] $argList += $argHash["Warning"] }
        if ( $Top )     { [string[]] $argList += $argHash["Top"] }
        if ( $News ) {
            [string[]] $argList += $argHash["News"]
            [string[]] $argList += $argHash["Tweet"]
        }
        if ( $argList.Count -eq 0 ){
            if ( $Global ){
                [string[]] $argList = @(
                    $argHash["Forecast"]
                    $argHash["Temperature"]
                    $argHash["Cloud"]
                    )
            } else {
                [string[]] $argList = @(
                    $argHash["Forecast"]
                    $argHash["Map"]
                    )
            }
        }
    }
    # invoke browser
    if ( $NotBrowse ){
        [pscustomobject] $argHash
    } else {
        Write-Debug "browser: $webBrowser"
        if ( $webBrowser -ceq "Default"){
            # use default browser
            foreach ( $uri in $argList ){
                Start-Process -FilePath $uri
            }
        } else {
            try {
                $splatting = @{
                    FilePath = $webBrowser
                    ArgumentList = $argList
                }
                Start-Process @splatting
            } catch {
                # use default browser
                foreach ( $uri in $argList ){
                    Start-Process -FilePath $uri
                }
            }
        }
    }
}
