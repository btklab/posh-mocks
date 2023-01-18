<#
.SYNOPSIS

grep - similar to grep in UNIX

指定した文字列にヒットする行を出力

デフォルトで大文字小文字を区別しないが、
-CaseSensitiveスイッチで大文字小文字を区別する

デフォルトでパターンを正規表現として解釈するが、
[-s|-SimpleMatch]オプションでパターンを文字列として認識する

cat file1,file2,... | grep '<regex>' [-v][-f][-s][-C <int>]
cat file1,file2,... | grep '<regex>' [-o]
grep '<regex>' -H file1,file2,...

    -v: 指定文字にヒットしない行を出力
    -o: ヒットした文字のみ出力
    -f: ファイルから検索文字列（regex）を指定
    -H: 指定されたファイル内を検索
        -Recurseで再帰的にファイルを検索
        -FileNameOnlyでファイル名のみ一意に出力
        -FileNameAndLineNumberでファイル名と列数を出力

検索速度は（ラップしているため）遅い。
筆者の環境ではシンプルにSelect-Stringを用いた方が早かった。

Select-String

PS> 1..10 | %{ Measure-Command{ 1..100000 | sls 99999 }} | ft

Days Hours Minutes Seconds Milliseconds
---- ----- ------- ------- ------------
0    0     0       0       437
0    0     0       0       386
0    0     0       0       394
0    0     0       0       385
0    0     0       0       407
0    0     0       0       715
0    0     0       0       424
0    0     0       0       424
0    0     0       0       443
0    0     0       0       423

grep

1..10 | %{ Measure-Command{ 1..100000 | grep 99999 }} | ft

Days Hours Minutes Seconds Milliseconds
---- ----- ------- ------- ------------
0    0     0       1       84
0    0     0       1       74
0    0     0       1       287
0    0     0       1       81
0    0     0       1       186
0    0     0       1       186
0    0     0       1       79
0    0     0       1       382
0    0     0       1       178
0    0     0       1       183


.LINK
    grep, sed

    about Select-String
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/select-string?view=powershell-7.3

    about splatting
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting?view=powershell-7.3



.EXAMPLE
# Find a case-sensitive match (grep 'regex' -CaseSensitive)

'Hello', 'HELLO' | grep 'HELLO' -CaseSensitive -SimpleMatch

HELLO

.EXAMPLE
# Find a pattern match (grep 'regex')

grep '\?' -H "$PSHOME\en-US\*.txt"
    https://go.microsoft.com/fwlink/?LinkID=108518.
    or go to: https://go.microsoft.com/fwlink/?LinkID=210614
    or go to: https://go.microsoft.com/fwlink/?LinkID=113316
      Get-Process -?         : Displays help about the Get-Process cmdlet.

.EXAMPLE
# Skip blank lines (grep ".")

PS> "aaa","","bbb","ccc"
aaa

bbb
ccc

PS> "aaa","","bbb","ccc" | grep .
aaa
bbb
ccc

.EXAMPLE
# Find matches in text files (grep 'regex' -H file,file,...)

Get-Alias   | Out-File -FilePath .\Alias.txt   -Encoding UTF8
Get-Command | Out-File -FilePath .\Command.txt -Encoding UTF8
grep 'Get\-' -H .\*.txt | Select-Object -First 5

Alias.txt:7:Alias           cal2 -> Get-OLCalendar
Alias.txt:8:Alias           cat -> Get-Content
Alias.txt:28:Alias           dir -> Get-ChildItem
Alias.txt:44:Alias           gal -> Get-Alias
Alias.txt:46:Alias           gbp -> Get-PSBreakpoint

.EXAMPLE
# Find a string in subdirectories (grep 'regex' -H file,file,... [-r|Recurse])

grep 'tab' -H '*.md' -r [-FileNameOnly|-FileNameAndLineNumber]

Table: caption
:::{.table2col}
| table |

The following commands are also approximately equivalent

ls *.md -Recurse | grep "table"

table2col.md:10:Table: caption
table2col.md:12::::{.table2col}
table2col.md:66:| table |

.EXAMPLE
# Find strings that do not match a pattern (grep 'regex' [-v|-NotMatch])

Get-Command | Out-File -FilePath .\Command.txt -Encoding utf8
cat .\Command.txt | grep "Get\-", "Set\-" -NotMatch | Select-Object -Last 5

Cmdlet          Write-Output                                       7.0.0.0    Microsoft.PowerShell.Utility
Cmdlet          Write-Progress                                     7.0.0.0    Microsoft.PowerShell.Utility
Cmdlet          Write-Verbose                                      7.0.0.0    Microsoft.PowerShell.Utility
Cmdlet          Write-Warning                                      7.0.0.0    Microsoft.PowerShell.Utility

.EXAMPLE
# Use double quotes when searching for tab characters (grep "`t")

 "1,2,3", "4,5,6", "7,8,9", "" | %{ $_ -replace ',', "`t" } | grep "`t[28]"

1       2       3
7       8       9

.EXAMPLE
# Find lines before and after a match (grep "regex" -C <int>,<int> )

Get-Command | Out-File -FilePath .\Command.txt -Encoding utf8
cat .\Command.txt | grep 'Get\-Computer' -C 2, 3

  Cmdlet          Get-Command                                        7.3.1.500  Microsoft.PowerShell.Core
  Cmdlet          Get-ComputeProcess                                 1.0.0.0    HostComputeService
> Cmdlet          Get-ComputerInfo                                   7.0.0.0    Microsoft.PowerShell.Management
  Cmdlet          Get-Content                                        7.0.0.0    Microsoft.PowerShell.Management
  Cmdlet          Get-Counter                                        7.0.0.0    Microsoft.PowerShell.Diagnostics
  Cmdlet          Get-Credential                                     7.0.0.0    Microsoft.PowerShell.Security

Tips: use Out-String -Stream (alias:oss) to greppable

cat .\Command.txt | grep 'Get\-Computer' -C 2, 3 | oss | grep '>'

> Cmdlet          Get-ComputerInfo                                   7.0.0.0    Microsoft.PowerShell.Management

.EXAMPLE
# Find all pattern matches (grep 'regex' -o)

cat "$PSHOME\en-US\*.txt" | grep "PowerShell"

    PowerShell Help System
    Displays help about PowerShell cmdlets and concepts.
    PowerShell Help describes PowerShell cmdlets, functions, scripts, and
    modules, and explains concepts, including the elements of the PowerShell
    PowerShell does not include help files, but you can read the help topics
    You can find help for PowerShell online at
       1. Start PowerShell with the "Run as administrator" option.
      Get-Help About_Modules : Displays help about PowerShell modules.


cat "$PSHOME\en-US\*.txt" | grep "PowerShell" -o
PowerShell
PowerShell
PowerShell
PowerShell
PowerShell
PowerShell
PowerShell
PowerShell
PowerShell

.EXAMPLE
# Convert pipeline objects to strings using Out-String -Stream

$hash = @{
    Name = 'foo'
    Category = 'bar'
}

# !! NO output, due to .ToString() conversion
$hash | grep 'foo'

# Out-String converts the output to a single multi-line string object
$hash | Out-String | grep 'foo'

Name                           Value
----                           -----
Name                           foo
Category                       bar

# Out-String -Stream converts the output to a multiple single-line string objects
$hash | Out-String -Stream | grep 'foo'

Name                           foo

.EXAMPLE
# Read regex pattern from file (grep -f <file> [-SimpleMatch])

cat a.txt | grep -f regfile.txt
cat a.txt | grep regfile.txt -f

#>
function grep {
    Param(
        [Parameter(Mandatory=$False,Position=0)]
        [string[]] $Pattern,

        [Parameter(Mandatory=$False,Position=1)]
        [alias('H')]
        [string[]] $Path,

        [Parameter(Mandatory=$False)]
        [alias('f')]
        [switch] $File,

        [Parameter(Mandatory=$False)]
        [alias('v')]
        [switch] $NotMatch,

        [Parameter(Mandatory=$False)]
        [alias('s')]
        [switch] $SimpleMatch,

        [Parameter(Mandatory=$False)]
        [alias('o')]
        [switch] $AllMatches,

        [Parameter(Mandatory=$False)]
        [alias('C')]
        [int[]] $Context,

        [Parameter(Mandatory=$False)]
        [switch] $CaseSensitive,

        [Parameter(Mandatory=$False)]
        [alias('r')]
        [switch] $Recurse,

        [Parameter(Mandatory=$False)]
        [switch] $FileNameOnly,

        [Parameter(Mandatory=$False)]
        [switch] $FileNameAndLineNumber,

        [parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [string[]] $Text
    )
    # test params
    if ((-not $Pattern) -and (-not $File)){
        Write-Error "do not set regex pattern or pattern-files." -ErrorAction Stop
    }
    # set params
    if ($File){
        # read patterns from files
        $pat = Get-Content -Path $Pattern -Encoding UTF8
    } else {
        $pat = $Pattern
    }
    $splatting = @{
        Pattern       = $pat
        CaseSensitive = $CaseSensitive
        Encoding      = "utf8"
        SimpleMatch   = $SimpleMatch
        NotMatch      = $NotMatch
        AllMatches    = $AllMatches
    }
    if ($PSVersionTable.PSVersion.Major -ge 7){
        # -NoEmphasis parameter was introduced in PowerShell 7
        $splatting.Set_Item('NoEmphasis', $True)
    }
    if ($Context){
        $splatting.Set_Item('Context', $Context)
    }
    if ($Path){
        $splatting.Set_Item('Path', (Get-ChildItem -Path $Path -Recurse:$Recurse))
    }
    # main
    if ($Path){
        if ($FileNameOnly){
            (Select-String @splatting).FileName | Sort-Object -Stable -Unique; return
        } elseif ($FileNameAndLineNumber){
            Select-String @splatting | Out-String -Stream  ; return
        } else {
            (Select-String @splatting).Line; return
        }
    }
    if ($AllMatches){
        ($input | Select-String @splatting).Matches.Value; return
    }
    if ($Context){
        $input | Select-String @splatting | Out-String -Stream ; return
    }
    ($input | Select-String @splatting).Line ; return
}
