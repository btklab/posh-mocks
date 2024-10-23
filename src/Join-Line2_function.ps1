<#
.SYNOPSIS
    Join-Line2 (Alias: jl2) - Concatenates lines until a specified string is found

.LINK
    jl, jl2, list2txt, csv2txt

.EXAMPLE
    # concat line
    cat data.txt
        # data
        
        [date]
          2024-10-24
        
        [title]
        
        [author]
          btklab,
          fuga
        
        [summary]
          summary-1
          summary-2
          summary-3
        
        [link]
          link-1
          link-2
        
    cat data.txt | jl2 -Match '\['
        # data
        [date] 2024-10-24
        [title]
        [author] btklab, fuga
        [summary] summary-1 summary-2 summary-3
        [link] link-1 link-2

.EXAMPLE
    # skip header
    cat data.txt | jl2 -Match '\[' -SkipHeader
        [date] 2024-10-24
        [title]
        [author] btklab, fuga
        [summary] summary-1 summary-2 summary-3
        [link] link-1 link-2

.EXAMPLE
    # delete match
    cat data.txt | jl2 -Match '\[([^]]+)\]' -Delete
        # data
        2024-10-24
        <blankline>
        btklab, fuga
        summary-1 summary-2 summary-3
        link-1 link-2

.EXAMPLE
    # replace match
    cat data.txt | jl2 -Match '\[([^]]+)\]' -Replace '$1:'
        # data
        date: 2024-10-24
        title:
        author: btklab, fuga
        summary: summary-1 summary-2 summary-3
        link: link-1 link-2

.EXAMPLE
    # concatenates lines by item,
    # deletes item names,
    # and outputs in one tab-delimited line
    # for spread sheet
    (cat data.txt | jl2 -Match '\[([^]]+)\]' -Delete -SkipHeader) -join "`t"
        2024-10-24<TAB><TAB>btklab, fuga<TAB>summary-1 summary-2 summary-3<TAB>link-1 link-2

#>
function Join-Line2 {

    [CmdletBinding()]
    param (
        [Parameter(
            HelpMessage="Search regex",
            Mandatory=$False,
            Position = 0
        )]
        [Alias('m')]
        [String] $Match = "."
        ,
        [Parameter(
            HelpMessage="Output delimiter",
            Mandatory=$False,
            Position = 1
        )]
        [Alias('d')]
        [String] $Delimiter = " "
        ,
        [Parameter(
            HelpMessage="Do not trim line",
            Mandatory=$False
        )]
        [Alias('nt')]
        [Switch] $NoTrim
        ,
        [Parameter(
            HelpMessage="Do not skip blank line",
            Mandatory=$False
        )]
        [Alias('ns')]
        [Switch] $NoSkip
        ,
        [Parameter(
            HelpMessage="Skip header until a specified string is found",
            Mandatory=$False
        )]
        [Alias('s')]
        [Switch] $SkipHeader
        ,
        [Parameter(
            HelpMessage="Delete matched strings",
            Mandatory=$False
        )]
        [Alias('dm')]
        [Switch] $Delete
        ,
        [Parameter(
            HelpMessage="Replace matched strings",
            Mandatory=$False
        )]
        [Alias('rm')]
        [String] $Replace
        ,
        [parameter(
            HelpMessage="Input",
            Mandatory=$False,
            ValueFromPipeline=$True
        )]
        [Object[]] $InputText
    )

    begin {
        [Int] $rowCounter = 0
        [Bool] $firstMatch = $False
        [String[]] $tempLineAry = @()
        $tempAryList = New-Object 'System.Collections.Generic.List[System.String]'
    }

    process {
        $rowCounter++
        [String] $readLine = [String] $_
        if ( $NoTrim ){
            #pass
        } else {
            [String] $readLine = $readLine.Trim()
        }
        if ( $readLine -match $Match ){
            [Bool] $firstMatch = $True
        }
        ## test readline
        Write-Debug "firstMatch: $firstMatch"
        if ( $SkipHeader -and -not $firstMatch ){
            return
        }
        if ( $NoSkip ){
            #pass
        } else {
            if ( $readLine -eq ''){
                return
            }
        }
        if ( $readLine -match $Match ){
            ## output stocked lines
            [String[]] $tempLineAry = $tempAryList.ToArray()
            if ( $tempLineAry.Count -gt 0 ){
                [String] $writeLine = $tempLineAry -join $Delimiter
                if ( $NoTrim ){
                    #pass
                } else {
                    [String] $writeLine = $writeLine.Trim()
                }
                Write-Output $writeLine
            }
            ## flush
            [String[]] $tempLineAry = @()
            $tempAryList = New-Object 'System.Collections.Generic.List[System.String]'
        }
        ## replace match
        if ( $Replace ){
            [String] $readLine = $readLine -replace $Match, $Replace
        } elseif ( $Delete ){
            [String] $readLine = $readLine -replace $Match, ''
        }
        if ( $NoTrim ){
            #pass
        } else {
            [String] $readLine = $readLine.Trim()
        }
        $tempAryList.Add( $readLine )
    }

    end {
        ## output stocked lines
        [String[]] $tempLineAry = $tempAryList.ToArray()
        if ( $tempLineAry.Count -gt 0 ){
            [String] $writeLine = $tempLineAry -join $Delimiter
            if ( $NoTrim ){
                #pass
            } else {
                [String] $writeLine = $writeLine.Trim()
            }
            Write-Output $writeLine
        }
        ## flush
        [String[]] $tempLineAry = @()
        $tempAryList = New-Object 'System.Collections.Generic.List[System.String]'
    }
}
# set alias
[String] $tmpAliasName = "jl2"
[String] $tmpCmdName   = "Join-Line2"
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
