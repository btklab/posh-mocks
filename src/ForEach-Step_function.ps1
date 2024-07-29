<#
.SYNOPSIS
    ForEach-Step (alias: fstep) - Apply a function to each line-oriented step.

.LINK
    ForEach-Step, ForEach-Block, Add-ForEach, Apply-Function, Trim-EmptyLine, toml2psobject

.NOTES
    about Script Blocks - PowerShell
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_script_blocks

.EXAMPLE
    # Calculate the basic statistic for each of the three rows.
    1..10 | fstep -Step 3 -func { Measure-Object -AllStats } | ft

    Count Average   Sum Maximum Minimum StandardDeviation Property
    ----- -------   --- ------- ------- ----------------- --------
        3    2.00  6.00    3.00    1.00              1.00
        3    5.00 15.00    6.00    4.00              1.00
        3    8.00 24.00    9.00    7.00              1.00
        1   10.00 10.00   10.00   10.00              0.00

.EXAMPLE
    # Apply the command every three lines.
    1..10 | fstep -Step 3 -func {flat}

    <output>
    1 2 3
    4 5 6
    7 8 9
    10

#>
function ForEach-Step {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, Position=0, HelpMessage="Divide blocks by number of lines.")]
        [Alias('s')]
        [ValidateScript({ $_ -gt 0 })]
        [Int] $Step,
        
        [Parameter(Mandatory=$False, HelpMessage="Script block.")]
        [Alias('f')]
        [Scriptblock] $Func,
        
        [Parameter(Mandatory=$False, HelpMessage="End Script block.")]
        [Alias('e')]
        [Scriptblock] $End,
        
        [Parameter(Mandatory=$False, HelpMessage="Begin Script block.")]
        [Alias('b')]
        [Scriptblock] $Begin,
        
        [Parameter(Mandatory=$False, HelpMessage="Where object.")]
        [Alias('w')]
        [Scriptblock] $Where,
        
        [Parameter(Mandatory=$False, HelpMessage="Specify file path to read.")]
        [String] $Path,
        
        [Parameter(Mandatory=$False, HelpMessage="Ignore empty line.")]
        [Switch] $IgnoreEmptyLine,
        
        [parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [String[]] $Text
    )
    # private function
    function foreach_step_filter {
        param (
            [parameter(Mandatory=$False,ValueFromPipeline=$True)]
            [String[]] $objText
        )
        begin {
            # set variables
            [Int] $rowCounter   = 0
            [Int] $stepCounter  = 0
            [Int] $blockCounter = 0
            [Int] $beforeBlockCounter = 0
            [Bool] $isFirstItem  = $True
            [Bool] $isFirstBlock = $True
            [Bool] $isSameBlock  = $True
            [Bool] $isLastItem   = $False
            [Object] $blockList = New-Object 'System.Collections.Generic.List[System.String]'
        }
        process {
            ## pre process
            if ( $IgnoreEmptyLine -and $_ -match '^$' ){ return }
            $rowCounter++
            [String] $readLine = $_
            [Int] $stepCounter = $rowCounter % $Step
            if ( $stepCounter -eq 1 ){
                $blockCounter++
                [Bool] $isFirstItem = $True
            }
            if ( $blockCounter -gt 1 ){
                [Bool] $isFirstBlock = $False
            }
            if ( $stepCounter -eq 0 ){
                [Bool] $isLastItem = $True
            } else {
                [Bool] $isLastItem = $False
            }
            if ( $beforeBlockCounter -eq $blockCounter ){
                [Bool] $isSameBlock = $True
            } else {
                [Bool] $isSameBlock = $False
            }
            Write-Debug "row: $rowCounter, step: $stepCounter, block: $blockCounter"
            Write-Debug "isFirstItem: $isFirstItem, isLastItem: $isLastItem, isFirstBlock: $isFirstBlock, isSameBlock: $isSameBlock"
            ## main proecss
            if ( $stepCounter -eq 0 ){
                ## add item
                $blockList.Add( $readLine ) > $Null
                ## output ary
                if ( $Begin ){
                    & $Begin
                }
                ### process
                [String[]] $blockAry = $blockList.ToArray()
                if ( $blockAry.Count -gt 0 ){
                    if ( $Func ){
                        [string] $com = '$blockAry' + " | " + $Func.ToString()
                    } else {
                        [string] $com = '$blockAry'
                    }
                    if ( $Where ){
                        [string] $com = $com + " | Where-Object -FilterScript {" + $Where.ToString() + "}"
                    }
                    Write-Debug "com: $com"
                    Invoke-Expression -Command $com
                }
                ### end
                if ( $End ){
                    & $End
                }
                ## init list
                [Object] $blockList = New-Object 'System.Collections.Generic.List[System.String]'
                [String[]] $blockAry = @()
            } else {
                ## add item only
                $blockList.Add( $readLine ) > $Null
            }
            ## post process
            [Bool] $isFirstItem = $False
            [Int] $beforeBlockCounter = $blockCounter
        }
        end {
            ## output ary
            ### process
            [String[]] $blockAry = $blockList.ToArray()
            if ( $blockAry.Count -gt 0 ){
                ### begin
                if ( $Begin ){
                    & $Begin
                }
                ### process
                if ( $Func ){
                    [string] $com = '$blockAry' + " | " + $Func.ToString()
                } elseif ( $Proc ){
                    [string] $com = '$blockAry'
                }
                if ( $Where ){
                    [string] $com = $com + " | Where-Object -FilterScript {" + $Where.ToString() + "}"
                }
                Write-Debug "com: $com"
                Invoke-Expression -Command $com
                ### end
                if ( $End ){
                    & $End
                }
            }
        }
    }
    # main
    if ( $Path ){
        ## read from file
        $splatting = @{
            LiteralPath = $Path
            Encoding    = "utf8"
        }
        Get-Content @splatting `
            | foreach_step_filter
    } else {
        ## read from pipeline
        $input `
            | foreach_step_filter
    }
    return
}
# set alias
[String] $tmpAliasName = "fstep"
[String] $tmpCmdName   = "ForEach-Step"
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
