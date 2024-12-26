<#
.SYNOPSIS
    watercss - Get Water.css rel link

    A small tool to always quickly install Water.css,
    a simple and beautiful CSS framework.

    Usage:
        watercss
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/water.css@2/out/water.css">

    kognise/water.css: A drop-in collection of CSS styles to make simple websites just a little nicer

    thanks:
        Water.css: https://watercss.kognise.dev/
        GitHub: https://github.com/kognise/water.css
        License: The MIT License (MIT) Copyright © 2019 Kognise

.LINK
    thanks:
        Water.css: https://watercss.kognise.dev/
        GitHub: https://github.com/kognise/water.css
        License: The MIT License (MIT) Copyright © 2019 Kognise


#>
function watercss {
    param (
        [Parameter( Mandatory=$False )]
        [Alias('a')]
        [switch] $Automatic,
        
        [Parameter( Mandatory=$False )]
        [Alias('l')]
        [switch] $Light,
        
        [Parameter( Mandatory=$False )]
        [Alias('d')]
        [switch] $Dark,
        
        [Parameter( Mandatory=$False )]
        [Alias('g')]
        [switch] $GitHub,
        
        [Alias('w')]
        [switch] $WebSite,
        
        [Parameter( Mandatory=$False )]
        [Alias('c')]
        [switch] $CDN,
        
        [Parameter( Mandatory=$False )]
        [Alias('v')]
        [int] $CDNVersion = 2,
        
        [Parameter( Mandatory=$False )]
        [Alias('ex')]
        [switch] $ExtraCss
    )
    if ( $GitHub ){
        Write-Output 'https://github.com/kognise/water.css'
    } elseif ( $WebSite ){
        Write-Output 'https://watercss.kognise.dev/'
    } elseif ( $CDN ){
        Write-Output "https://cdn.jsdelivr.net/npm/water.css@$CDNVersion/"
    } else {
        ## theme
        if ( $Light ){
            ## Light theme
            Write-Output "<link rel=""stylesheet"" href=""https://cdn.jsdelivr.net/npm/water.css@$CDNVersion/out/light.css"">"
        } elseif ( $Dark ){
            ## Dark theme 
            Write-Output "<link rel=""stylesheet"" href=""https://cdn.jsdelivr.net/npm/water.css@$CDNVersion/out/dark.css"">"
        } elseif ( $Automatic ) {
            ## Automatic
            Write-Output "<link rel=""stylesheet"" href=""https://cdn.jsdelivr.net/npm/water.css@$CDNVersion/out/water.css"">"
        } else {
            ## Default: Automatic
            Write-Output "<link rel=""stylesheet"" href=""https://cdn.jsdelivr.net/npm/water.css@$CDNVersion/out/water.css"">"
        }
        if ( $ExtraCss ){
            ## extra css
            #Write-Output '<style type="text/css">'
            #Write-Output ''
            #Write-Output '</style>'
        }
    }
}
