<#
.SYNOPSIS
    Add-ForEach (alias: addf) - Insert arrayed strings for each input repeatedly.

    Repeatedly inserts a given string array into each input.

     "john","doe","0123-123-123", "foo","bar","0123-123-123" `
        | addf "fname","lname","phone" -fs " : " -End ""

    fname : john
    lname : doe
    phone : 0123-123-123
    
    fname : foo
    lname : bar
    phone : 0123-123-123

.LINK
    ForEach-Step, ForEach-Block, Add-ForEach, Apply-Function, Trim-EmptyLine, toml2psobject

.EXAMPLE
    # add name for each value
    1..10 | addf "item.1", "item.2", "item.3"

    <output>
    item.1 1
    item.2 2
    item.3 3
    item.1 4
    item.2 5
    item.3 6
    item.1 7
    item.2 8
    item.3 9
    item.1 10

.EXAMPLE
    # add name for each value
    1..10 | addf "item.1", "item.2", "item.3" -fs " = "

    <output>
    item.1 = 1
    item.2 = 2
    item.3 = 3
    item.1 = 4
    item.2 = 5
    item.3 = 6
    item.1 = 7
    item.2 = 8
    item.3 = 9
    item.1 = 10

.EXAMPLE
    # Insert a blank line after each label
    1..10 | addf "item.1", "item.2", "item.3" -End ""

    <output>
    item.1 1
    item.2 2
    item.3 3
    
    item.1 4
    item.2 5
    item.3 6
    
    item.1 7
    item.2 8
    item.3 9
    
    item.1 10

.EXAMPLE
    # wrap output
    1..10 | addf "item.1", "item.2", "item.3" -fs " = " -Begin "{" -End "}" -Indent "    "

    <output>
    {
        item.1 = 1
        item.2 = 2
        item.3 = 3
    }
    {
        item.1 = 4
        item.2 = 5
        item.3 = 6
    }
    {
        item.1 = 7
        item.2 = 8
        item.3 = 9
    }
    {
        item.1 = 10
    }

.EXAMPLE
    # wrap output and add record separator
    1..10 | addf "item.1", "item.2", "item.3" -fs " = " -Begin "{" -End "}" -Indent "    " -rs "," -SkipLastSeparator

    <output>
    {
        item.1 = 1,
        item.2 = 2,
        item.3 = 3
    },
    {
        item.1 = 4,
        item.2 = 5,
        item.3 = 6
    },
    {
        item.1 = 7,
        item.2 = 8,
        item.3 = 9
    },
    {
        item.1 = 10
    }

#>
function Add-ForEach {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, HelpMessage="Add array")]
        [Alias('a')]
        [String[]] $Array,
        
        [Parameter(Mandatory=$False, HelpMessage="indent string")]
        [Alias('i')]
        [String] $Indent = '',
        
        [Parameter(Mandatory=$False, HelpMessage="wrap string")]
        [Alias('w')]
        [String] $Wrap = '',
        
        [Parameter(Mandatory=$False, HelpMessage="field separator string")]
        [Alias('fs')]
        [String] $FieldSeparator = ' ',
        
        [Parameter(Mandatory=$False, HelpMessage="record separator string")]
        [Alias('rs')]
        [String] $RecordSeparator = '',
        
        [Parameter(Mandatory=$False, HelpMessage="skip last separator")]
        [Alias('skiplast')]
        [Switch] $SkipLastSeparator,
        
        [Parameter(Mandatory=$False, HelpMessage="Begin")]
        [Alias('b')]
        [String[]] $Begin,
        
        [Parameter(Mandatory=$False, HelpMessage="End")]
        [Alias('e')]
        [String[]] $End,
        
        [Parameter(Mandatory=$False, HelpMessage="Specify file path to read.")]
        [String] $Path,
        
        [parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [String[]] $Text
    )
    function add_foreach_filter {
        param (
            [parameter(Mandatory=$False,ValueFromPipeline=$True)]
            [String[]] $objText
        )
        begin {
            # set variables
            [Int] $rowCounter = 0
            [String] $beforeEndCharStr = '@@@@do@@not@@set@@@'
            [String] $beforeEndChar = $beforeEndCharStr
        }
        process {
            ## pre process
            $rowCounter++
            [String] $readLine = $_
            if ( $rowCounter -eq 1 ){
                [String] $beforeReadLine = $readLine
                [String] $beforeRowCounter = $rowCounter
                return
            }
            [Int] $mod = $beforeRowCounter % $Array.Count - 1
            if ( $mod -eq 0 ){
                [Bool] $isFirstItem = $True
            } else {
                [Bool] $isFirstItem = $False
            }
            if ( $Mod -eq -1 ){
                [Bool] $isLastItem = $True
            } else {
                [Bool] $isLastItem = $False
            }
            if ( $mod -eq -1 ){
                [Int] $idx = $Array.Count - 1
            } else {
                [Int] $idx = $mod
            }
            Write-Debug "index: $idx"
            ## begin
            if ( $isFirstItem -and $beforeEndChar -ne $beforeEndCharStr ){
                Write-Output $($beforeEndChar + $RecordSeparator)
                [String] $beforeEndChar = $beforeEndCharStr
            }
            if ( $isFirstItem -and $Begin.Count -gt 0 ){
                Write-Output $($Begin[0])
            }
            ## process
            [String] $writeLine = $Indent
            $writeLine += $Array[$idx]
            $writeLine += $FieldSeparator
            $writeLine += $Wrap
            $writeLine += $beforeReadLine
            $writeLine += $Wrap
            if ( $SkipLastSeparator -and $isLastItem ){
                # pass
            } else {
                $writeLine += $RecordSeparator
            }
            Write-Output $writeLine
            ## end
            if ( $isLastItem -and $End.Count -gt 0 ){
                [String] $beforeEndChar = $End[0]
            }
            [String] $beforeReadLine = $readLine
            [Int] $beforeRowCounter = $rowCounter
        }
        end {
            [Bool] $isLastItem = $True
            [Int] $mod = $beforeRowCounter % $Array.Count - 1
            if ( $mod -eq 0 ){
                [Bool] $isFirstItem = $True
            } else {
                [Bool] $isFirstItem = $False
            }
            if ( $mod -eq -1 ){
                [Int] $idx = $Array.Count - 1
            } else {
                [Int] $idx = $mod
            }
            Write-Debug "index: $idx"
            ## begin
            if ( $isFirstItem -and $beforeEndChar -ne $beforeEndCharStr ){
                Write-Output $($beforeEndChar + $RecordSeparator)
                [String] $beforeEndChar = $beforeEndCharStr
            }
            if ( $isFirstItem -and $Begin.Count -gt 0 ){
                Write-Output $($Begin[0])
            }
            ## process
            [String] $writeLine = $Indent
            $writeLine += $Array[$idx]
            $writeLine += $FieldSeparator
            $writeLine += $Wrap
            $writeLine += $beforeReadLine
            $writeLine += $Wrap
            if ( $SkipLastSeparator -and $isLastItem ){
                # pass
            } else {
                $writeLine += $RecordSeparator
            }
            Write-Output $writeLine
            ## end
            if ( $isLastItem -and $End.Count -gt 0 ){
                [String] $writeLine = $End[0]
                if ( $writeLine -eq '' ){
                    return
                }
                if ( $SkipLastSeparator -and $isLastItem ){
                    # pass
                } else {
                    $writeLine += $RecordSeparator
                }
                Write-Output $writeLine
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
            | add_foreach_filter
    } else {
        ## read from pipeline
        $input `
            | add_foreach_filter
    }
    return
}
# set alias
[String] $tmpAliasName = "addf"
[String] $tmpCmdName   = "Add-ForEach"
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
