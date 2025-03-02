# Changelog

All notable changes to "posh-mocks" project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [unreleased]

- NA

## [7.5.1] - 2025-01-12

- Added: [pwmake] Autovariable: PSScriptRoot
- Added: [Encode-Uri] (Alias: encuri) Status property when using `-AsObject` option
- Added: [Decode-Uri] (Alias: decuri) Status property when using `-AsObject` option
- Changed: [Invoke-Link] (Alias: i) to open only the first matched location

## [7.5.0] - 2025-01-01

- Added: [Encode-Uri] (Alias: encuri) function
- Added: [Decode-Uri] (Alias: decuri) function
- Changed: [Get-OGP] make if statement early return
- Changed: [Unique-Object] Changed to output columns other than the specified columns
- Fixed: [Invoke-Link] Fixed a bug that caused links to be executed twice when .lnk was specified
- Update: [Get-Ticket] Synopsis
- Added: [Get-Ticket] `-TagOnly` switch
- Changed: [Get-Ticket] Changed short Act names to default
- Changed: [Get-Ticket] Enable link with one-liner
- Changed: [Get-Ticket] Enable execution of links written in one-liner
- Changed: [Get-Ticket] Changed the tag string to an array
- Changed: [Get-Ticket] Enabled `-InvokeLink` when `-AsObject` switch is specified
- Changed: [Get-Ticket] Suppress standard output when `-InvokeLink`

## [7.4.2] - 2024-12-09

- Fixed: [Invoke-Link] -DryRun does not run to completion


## [7.4.1] - 2024-12-09

- Changed: [Invoke-Link] `-Command` option name was renamed to `-App` and made explicit mandatory.
- Added: [Rename-Normalize] synopsis
- Added: [clip2img] an example

## [7.4.0] - 2024-12-08

- Changed: [ForEach-Replace] Set the default value of the `-To` option to an empty string
- Added: [man2] `-Recent`, `-Descending`, `-Object` switch
- Added: [Get-OGP] `-Dokuwiki` switch
- Added [Set-DotEnv] (Alias: pwenv) function
- Added [PullOut-String] (Alias: pullstr) function
- Added [Auto-Clip] (Alias: aclip) function
- Added [Tee-Clip] (Alias: tclip) function
- Changed [Invoke-Link] Do not sort urls

### Breaking Changes

- Changed [Invoke-Link] Only top links are opened by default.

## [7.3.0] - 2024-10-24

- Added [Join-Line2] (Alias: jl2) function
- Added [jl] indentation to examples
- Added [Add-ID] function
- Added [Execute-TinyTeX] Specify the repository URL
- Added [Unzip-Archive] compare hash
- Added [Invoke-Link] Grep option
- Changed [Invoke-Link] parse text file only to .txt, .md and files without extensions
- Changed [Invoke-Link] made tag symbols case insensitive
- Fixed [grep] synopsis
- Fixed [README.md] typo
- Translated [README.md] Partially translated from Japanese to English
- Fixed [Invoke-Link] initialization of arrays when multiple lines are input from a pipeline.

## [7.2.4] - 2024-08-16

- Enabled [Invoke-Link] value from pipeline and clipboard
- Added [ClipImageFrom-File] Object output option
- Added [ClipImageFrom-File] function
- Fixed [clip2file] `-Files` option

## [7.2.3] - 2024-07-29

- Added [Cast-Date] function.
- Added [Cast-Decimal] function.
- Added [Cast-Double] function.
- Added [Cast-Integer] function.
- Added [Edit-Property] function.
- Added [Trim-EmptyLine] function
- Fixed [GetValueFrom-Key] skip if there is insufficient number of elements
- Translated [README.md] synopsis Japanese to English

### Breaking Change

- Changed [Get-Ticket] output when using -Gantt option

## [7.2.2] - 2024-04-21

- Added [GetValueFrom-Key] (Alias: getvalkey) function
- Fixed [grep] `-File` option
- Added [pawk] AutoSubExpression switch
- Changed [Invoke-Link] Tag management
- Translated [README.md] synopsis Japanese to English

## [7.2.1] - 2024-03-17

- Enabled [Invoke-Link] Tag management
- Added [Invoke-Link] `-Recurse` option
- Added [Get-Histogram] Detect NaN
- Added [Get-Histogram] `-Cast` option
- Added [math2tex] AddDollars, AddBrackets option
- Changed [Get-Ticket] ErrorActionPreference setting
- Changed [Invoke-Link] ErrorActionPreference setting
- Changed [linkcheck] ErrorActionPreference setting

## [7.2.0] - 2024-02-27

- Fixed [dot2gviz] an error when outputting svg format
- Fixed [pu2java] an error when outputting svg format
- Changed [dot2gviz] Changed to use Start-Process instead of Invoke-Expression
- Changed [pu2java] Changed to use Start-Process instead of Invoke-Expression
- Fixed [Execute-TinyTeX] quotes when specifying multiple packages
- Added [Execute-TinyTeX] `-RemovePackage` option, `-InstallJaPackages`
- Added [math2tex] physics, siunitx, chemfig, luatexja package

## [7.1.0] - 2024-02-18

- Added [Execute-RMarkdown] (Alias: rmarkdown) function
- Renamed [Execute-TinyTeX] from `Execute-TinyTex`
- Added [Inkscape-Converter] (Alias: inkconv) function

## [7.0.0] - 2024-02-17

- Added [Execute-TinyTeX] (Alias: tinytex) function
- Added [math2tex] function
- Fixed [sleepy] PercentComplete value to 100 if it is greater than 100
- Fixed [README.md] create command list script
- Added [Invoke-Link] `-InvokeById` option
- Added [Join2-Object] `-Tran` option

### Breaking Change

- Changed [pu2java] jar file location

## [6.10.2] - 2024-01-13

- Added [examples.md]
- Added [Get-ClipboardAlternative] -t option as alias for -AsPlainText
- Fixed [logi2dot]
- Fixed [Get-Ticket] correct the insertion position of the date when specifying the `-Add` option
- Deleted [Edit-Function] `edit` alias

### Breaking Change

- Renamed `gdate` to [Get-DateAlternative]

## [6.10.1] - 2024-01-13

- Added [Get-ClipboardAlternative] `-Property` option
- Changed default fontname "Meiryo" to "MS Gothic"
- Changed [mind2pu] read legend from input instead of argument
- Added [Get-Ticket] `-Relax` option
- Added [Grep-Block], [Sort-Block] functions
- Changed [README.md] simplified explanation of `man2` function
- Changed the file path is now displayed in the error message when aliases are duplicated

## [6.10.0] - 2023-12-26

- Added [Test-isAsciiLine] (Alias: isAsciiLine) function
- Added [Shutdown-ComputerAFM] function
- Fixed [README.md] typo

### Breaking Change

- Rename `Sleep-Computer` to `Sleep-ComputerAFM`

## [6.9.0] - 2023-12-24

- Added [Get-ClipboardAlternative] (Alias: [gclipa]) function
- Added [Unzip-Archive] (Alias: [clip2unzip]) function
- Fixed [README.md] typo

## [6.8.1] - 2023-12-24

- Fixed [README.md] section links
- Fixed [linkcheck] determination of input presence/absence
- Fixed [clip2file], [clip2hyperlink], [clip2normalize], [clip2push], [clip2shortcut]

## [6.8.0] - 2023-12-21

- Added `Sleep-Computer` function
- Added [Set-NowTime2Clipboard] function
- Added [README.md] text banner
- Added [pawk] `-First` option, `-IgnoreConsecutiveDelimiters` switch

## [6.7.1] - 2023-12-16

- Fixed [README.md], [Get-Ticket] typo
- Fixed [Get-Ticket] Missing `-Raw` option
- Fixed [Decrease-Indent] a bug where input via pipeline could not be read
- Corrected [Decrease-Indent] the variable type of `-Skip` option from string to integer

## [6.7.0] - 2023-12-08

- Added [README.md] section anchor tag and fix typo
- Added [Decrease-Indent] function
- Fixed [Get-Ticket] synopsis
- Added [Get-Ticket] `-ForceXonCreationDateBeforeToday` option
- Added [Get-Ticket] `-GetSeries` option
- Changed Set-Alias output to Write-Host [operator.ps1], [Add-Quartile], [Add-Stats], [Apply-Function], [Delete-Object], [Edit-Function], [Get-Book], [Get-Diary], [Get-Note], [Get-OGP], [Get-Recipe], [Get-Ticket], [GroupBy-Object], [Invoke-Link], [Invoke-Logger], [Join2-Object], [Measure-Quartile], [Measure-Stats], [Measure-Summary], [New-Function], [New-Function], [New-Quarto], [Rename-Normalize], [Schedule-Task], [Search-WordMeaning], [Sort-Ordinal], [Zap-Web], [grep], [head], [tail]
- Added [Get-Ticket] `-OutputSection` and `-AsObjectAndShortenAct` option

## [6.6.0] - 2023-12-03

- Added [Get-Ticket] function

## [6.5.4] - 2023-11-26

- Fixed [man2] Resolve path
- Added [Edit-Function] function
- Added [Edit-Function] behavior when specifying an existing file
- Added test for existing alias before adding alias: [Add-Quartile], [Add-Stats], [Apply-Function], [Edit-Function], [Get-OGP], [grep], [GroupBy-Object], [head], [Invoke-Link], [Invoke-Logger], [Join2-Object], [Measure-Quartile], [Measure-Stats], [Measure-Summary], [Rename-Normalize], [Sort-Ordinal], [tail]

## [6.5.3] - 2023-11-17

- Updated [Measure-Summary] synopsis
- Supported [grep] `-LeaveHeaderAndBoarder` option when used with `-Context` option
- Fixed [Join2-Object] Synopsis
- Added [Replace-ForEach] `-OnlyIfPropertyExists` option

## [6.5.2] - 2023-11-01

- Added [grep] `-LeaveHeaderAndBoarder` option

## [6.5.1] - 2023-11-01

- Fixed [README.md]
- Changed [Measure-Summary], [Measure-Quartile] Move sum calculation to `-Detail` option
- Changed [Measure-Summary], [Measure-Quartile] Cast double
- Added [Transpose-Property] property name existence test

## [6.5.0] - 2023-10-31

- Updated [README.md]
- Added [grep] `-l|-LeaveHeader` option
- Rewrite [head], [tail] code
- Output Aliases when dot-sourcing function files
- Restricted [Get-Histogram], [Plot-BarChart] from division by zero
- Added [ysort] `-Ordinal` option
- Added [Unique-Object] function
- Added [Measure-Summary] function
- Added [Transpose-Property] function

## [6.4.0] - 2023-10-16

- Added [lcalc2] function
- Updated [README.md]
- Added [Join2-Object] `-OnlyIfInTransaction` switch
- Added [list2table] `-Header` option

## [6.3.0] - 2023-10-14

- Added [Join2-Object] function

## [6.2.1] - 2023-10-14

- Changed [Add-Quartile] Use hashtable instead of Add-Member
- Changed [Add-Stats] Use hashtable instead of Add-Member
- Changed [Apply-Function] Use hashtable instead of Add-Member
- Changed [Detect-XrsAnomaly] Use hashtable instead of Add-Member
- Changed [GroupBy-Object] Use hashtable instead of Add-Member
- Changed [Join2-Object] Use hashtable instead of Add-Member
- Changed [Measure-Quartile] Use hashtable instead of Add-Member
- Changed [Measure-Stats] Use hashtable instead of Add-Member
- Changed [Plot-BarChart] Use hashtable instead of Add-Member

## [6.2.0] - 2023-10-14

- Added [Measure-Quartile] function
- Added [Add-Quartile] function


## [6.1.1] - 2023-10-14

- Fixed [Add-Stats] an object variable input into the pipeline were overwritten
- Fixed [Apply-Function] an object variable input into the pipeline were overwritten
- Fixed [Detect-XrsAnomaly] an object variable input into the pipeline were overwritten
- Fixed [Get-First] an object variable input into the pipeline were overwritten
- Fixed [Get-Last] an object variable input into the pipeline were overwritten
- Fixed [GroupBy-Object] an object variable input into the pipeline were overwritten
- Fixed [Measure-Stats] an object variable input into the pipeline were overwritten
- Fixed [Plot-BarChart] an object variable input into the pipeline were overwritten
- Fixed [Replace-ForEach] an object variable input into the pipeline were overwritten

## [6.1.0] - 2023-10-05

- Added [Replace-ForEach] function
- Added [Detect-XrsAnomaly] `-Median` option
- Updated [README.md]
- Fixed [Add-Stats] type error in variable initialization

### Breaking Change

- Changed [Add-Stats] Output property name


## [6.0.0] - 2023-09-28

- Added [Get-Histogram] function
- Added [README.md] section CREDIT
- Added [Plot-BarChart] Apache License 2.0 into script file
- Updated [sed] Synopsis

### Breaking Change

- Renamed `Measure-Property` to [Measure-Stats]

## [5.0.3] - 2023-09-23

- Added `Measure-Property` function alias: mprop
- Added [Add-Stats] function alias: astat
- Changed [man2] ordinal sort

## [5.0.2] - 2023-09-23

- Fixed [README.md], [Plot-BarChart], [Detect-XrsAnomaly] typo
- Renamed `Measure-Property` param alias
- Renamed [Add-Stats] param alias

## [5.0.1] - 2023-09-22

- Fixed [README.md] typo

## [5.0.0] - 2023-09-22

### New functions

- Added: [Shorten-PropertyName] function
- Added: [Drop-NA], [Replace-NA] function
- Added: [Apply-Function] function
- Added: [GroupBy-Object] function
- Added: `Measure-Property` function
- Added: [Add-Stats] function
- Added: [Detect-XrsAnomaly] function
- Added: [Plot-BarChart] function
- Added: [Get-First], [Get-Last] function
- Added: [Select-Field], [Delete-Field] function

### Changes

- Added: [Get-OGP] `-Raw` option
- Fixed [percentile] typo in synopsis
- Enabled [clip2dir], [clip2file], [clip2hyperlink], [clip2normalize], [clip2push], [clip2shortcut], [clip2txt], [Rename-Normalize] pipeline input of file object, changed output from text object to file object
- Enabled `i` environment variables as path strings
- Changed `i` to `Invoke-Item` to the parent directory when `-Location` option is specified.
- Added `i` `-AsFileObject` output
- Added [mind2dot], [logi2dot] `-Concentrate` option
- Enabled [json2txt] symbols for key strings
- Changed [logi2pu] to omit `#` sign for -GrepColor option
- Enabled [logi2dot], [logi2pu] `-Grep` to work on subgraphs
- Added [mind2dot] `-TerminalShape` option
- Added [logi2dot], [logi2pu] `--` syntax to close all group parenthesis
- Fixed [pwmake] typo in synopsis

### Breaking Changes

- Renamed: `i` to [Invoke-Link]
- Renamed: `Add-CrLf` to [Add-LineBreak]
- Renamed: `Add-CrLf-EndOfFile` to [Add-LineBreakEndOfFile]


## [4.3.0]

- Enabled [logi2dot], [logi2pu] Nested groups
- Added [pwmake] Predefined variables (`-Param`, `-Params`)
- Fixed [README.md] Synopsis
- Added `i` -BackGround option
- Enabled `i` to specify multiple input files
- Explicit [mind2dot] variable type


## [4.2.4] - 2023-08-05

- Added Restart-Explorer function to operator.ps1
- Fixed [flow2pu], [seq2pu] Fixed an error that occurred when there was a string "begin" in a comment on PowerShell 7.3.6 on Linux(Ubuntu22.04) 
    - `ParseError: Executable script code found in signature block.`
- Changed [operator.ps1] Limit the use of functions using "System.Windows.Forms.dll" to the windows environment.

## [4.2.3] - 2023-08-04

- Fixed [sed], [README.md] typo
- Refactored [logi2dot], [logi2pu]
- Added [mind2pu] `-Raw` option

## [4.2.2] - 2023-07-22

- Enabled [mdgrep], [list2table] Support for tab list

## [4.2.1] - 2023-07-21

- Fixed [mdgrep] bug: remove extra white space at beginning of each list
- Fixed [README.md]

## [4.2.0] - 2023-07-20

- Added [list2table] `-Tag`, `-TagOff` switch

## [4.1.1] - 2023-07-20

- Fix [mdgrep], [list2table], [mind2dot] getItemLevel function

## [4.1.0] - 2023-07-17

- Allowed [gantt2pu] blank lines and comment out in external files
- Updated [README.md]
- Added [clip2hyperlink] option `-Leaf`, `-Parent`

## [4.0.0] - 2023-07-16

- Changed [list2table] to output in object format by default
- Changed [head], [tail] display path to relative path when using wildcard

## [3.14.2] - 2023-07-16

- Fixed [list2table], [mdgrep], [mdfocus] synopsis

## [3.14.1] - 2023-07-16

- Fixed [sed] bug fix for print/delete option

## [3.14.0] - 2023-07-15

- Added [mdfocus] function

## [3.13.1] - 2023-07-15

- Fixed [list2table] Typo in variable name (critical)
- Fixed Typo

## [3.13.0] - 2023-07-13

- Enabled [list2table] Supports list symbols `+`, `*`, `1.` in addition to the symbol `-`
- Enabled [mdgrep] Supports list symbols `-`, `+`, `*`, `1.` in addition to the symbol `#`
- Fixed [mdgrep] Typo
- Fixed [mind2dot] Typo

## [3.12.0] - 2023-07-12

- Added [list2table] function

## [3.11.0]

- Deleted [clipwatch] `-Repeat` option
- Added [clip2file] `-UrlDecode` option
- Added [Get-OGP] `-cite` option


## [3.10.1] - 2023-05-19

- Fixed [clip2file], [README.md] Synopsis

## [3.10.0] - 2023-05-19

- Fixed [Rename-Normalize], [clip2push], [clip2shortcut], [push2loc] do not use `Write-Host -Message` argument
- Fixed [clip2file] sorted by filename
- Added [sleepy] `-FirstBell` option
- Added [clip2hyperlink] function



## [3.9.0] - 2023-04-20

- Updated [README.md]
- Fixed [toml2psobject] QuoteValue function: enable null option
- Added [clip2shortcut] function


## [3.8.0] - 2023-04-09

- Fixed [README.md] typo
- Added [logi2dot] enable legend block.
- Added [mdgrep] grep changelog example.
- Added [push2loc] function.
- Added [clip2push] function.
- Added [Rename-Normalize] filter "replace-characters-to-avoid-in-filename".


## [3.7.0] - 2023-04-07

- Fixed [fwatch] synopsis
- Changed [operator.ps1] path delimiter `\` to `/`
- Added [tail-f] function


## [3.6.2] - 2023-04-06

- Updated `i` synopsis
- Updated [README.md] synopsis
- Changed [mind2dot] legend table color

## [3.6.1] - 2023-04-06

- Changed [Rename-Normalize] make the replacement process a filter and set-alias "ren2norm"
- Changed [clip2file] swap the order of -Name and -Full switch
- Updated [README.md] fix typo


## [3.6.0] - 2023-04-04

- Changed [Rename-Normalize] examples that better explain what the function does.
- Added [clip2normalize] function.


## [3.5.0]

- Added [clip2file] function.
- Added [Rename-Normalize] function.

## [3.4.0]

- Added [pwsync] function.
- Added [Get-AppShortcut] shortcut: IME switch input language.


## [3.3.1]

- Fixed [pwmake] overwrite optimized variable error
- Added [pwmake] example


## [3.3.0]

- Updated [README.md]
- Added [mdgrep] `-CustomCommentBlock` enable the language-specific comment block symbol

## [3.2.0]

- Updated [README.md]
- Added [man2] `-Independent` option and fix
- Added [pwmake] `-DeleteCommentEndOfCommandLine` option
- Added [mdgrep] `-IgnoreLeadingSpaces` option

## [3.1.0] - 2023-03-18 Sat

- Updated [README.md]
- Fixed [percentile] synopsis
- Added [mdgrep] function
- Added [Get-AppShortcut] function
- Added [clip2img] examples

## [3.0.1] - 2023-03-17 Fri

- Added [kinsoku] left parenthesis and fullstop symbols
- Added `tests` for Pester-Test
- Added `.github/workflows/test_pwsh_on_ubuntu_latest.yaml` for [GitHub workflow][githubworkflow]

[githubworkflow]: https://docs.github.com/en/actions/using-workflows


## [3.0.0]

- Breaking change: `-split` operator to `.Split()` method

## [2.1.3]

- Fix [image2md] parse imagefile regardless of extension.

## [2.1.2]

- Enable [grep] `-AllMatches` when `-Path` specified.
- Fix [image2md] parse imagefile regardless of extension.


## [2.1.1]

- Changed `i` behavior when non-existent file is specified.
- Fixed [README.md] examples.


## [2.1.0]

- Breaking Change [ycalc], [percentile] change `-SkipHeader` option to `NoHeader` option. Input expects space-separated data with headers.
- Fixed [README.md], [logi2dot], [logi2pu], [percentile] typo.
- Fixed [addb], [addl], [addr], [movw], [tarr] replace tab to 4-spaces.
- Added [ysort], [ycalc], [fval] functions.
- Added [wrap] function.
- Added [percentile] supports multiple value fields. Missing/Empty value detection/removal/replacement.
- Added [flow2pu] [gantt2pu] [logi2pu] [mind2pu] [seq2pu] `-FontSize` option.


## [2.0.0]

- Breaking Change [chead], [ctail] refactored.
- Fixed `i` error handling when file does not exist.


## [1.1.0]

- Fixed [gantt2pu], [logi2pu], [mind2pu] Wrap title string in double quotes
- Changed [watercss] Synopsis
- Fixed [README.md]
- Added [flow2pu] function
- Added [seq2pu] function


## [1.0.0] - 2023-02-23

- Added [README.md] hyperlinks to related file in section titles
- Enabled [map2] change upper-left-mark using `-UpperLeftMark` option
- Added [movw] function
- Added [decil] function
- Added [summary] function
- Added [fpath] function
- Added [watercss] function


## [0.2.0] - 2023-02-22

- Changed [csv2sqlite] update examples
- Changed [CHANGELOG.md] test tagging and write CHANGELOG.md
- Added [percentile] function


## [0.1.0] - 2023-02-19

- Changed Translate japanese to english
- Added `Add-CrLf-EndOfFile`, `Add-CrLf`, [addb], [addl], [addr], [addt], [cat2], [catcsv], [chead], [clip2img], [clipwatch], [conv], [ConvImage], [count], [csv2sqlite], [csv2txt], [ctail], ctail2, [delf], [dot2gviz], [filehame], [fillretu], [flat], [fwatch], [gantt2pu], `gdate`, [Get-OGP], [getfirst], [getlast], [grep], [gyo], [han], [head], `i`, [image2md], [jl], [json2txt], [juni], [keta], [kinsoku], [lastyear], [lcalc], [linkcheck], [linkextract], [logi2dot], [logi2pu], [man2], [map2], [mind2dot], [mind2pu], [nextyear], [Override-Yaml], [pawk], [pu2java], [pwmake], [retu], [rev], [rev2], [say], [sed-i], [sed], [self], [sleepy], [sm2], [table2md], [tac], [tail], [tarr], [tateyoko], [teatimer], [tenki], [tex2pdf], [thisyear], [toml2psobject], [uniq], [vbStrConv], [yarr], [zen]



[README.md]: blob/main/README.md
[CHANGELOG.md]: blob/main/CHANGELOG.md
[examples.md]: blob/main/examples.md

[addb]: src/addb_function.ps1
[addl]: src/addl_function.ps1
[addr]: src/addr_function.ps1
[addt]: src/addt_function.ps1
[cat2]: src/cat2_function.ps1
[catcsv]: src/catcsv_function.ps1
[chead]: src/chead_function.ps1
[clip2img]: src/clip2img_function.ps1
[clipwatch]: src/clipwatch_function.ps1
[conv]: src/conv_function.ps1
[ConvImage]: src/ConvImage_function.ps1
[count]: src/count_function.ps1
[csv2sqlite]: src/csv2sqlite_function.ps1
[csv2txt]: src/csv2txt_function.ps1
[ctail]: src/ctail_function.ps1
[delf]: src/delf_function.ps1
[dot2gviz]: src/dot2gviz_function.ps1
[filehame]: src/filehame_function.ps1
[fillretu]: src/fillretu_function.ps1
[flat]: src/flat_function.ps1
[wrap]: src/wrap_function.ps1
[fwatch]: src/fwatch_function.ps1
[gantt2pu]: src/gantt2pu_function.ps1
[Get-DateAlternative]: src/Get-DateAlternative_function.ps1
[Get-OGP]: src/Get-OGP_function.ps1
[getfirst]: src/getfirst_function.ps1
[getlast]: src/getlast_function.ps1
[grep]: src/grep_function.ps1
[gyo]: src/gyo_function.ps1
[han]: src/han_function.ps1
[head]: src/head_function.ps1
[image2md]: src/image2md_function.ps1
[jl]: src/jl_function.ps1
[json2txt]: src/json2txt_function.ps1
[juni]: src/juni_function.ps1
[keta]: src/keta_function.ps1
[kinsoku]: src/kinsoku_function.ps1
[lastyear]: src/Get-DateAlternative_function.ps1
[lcalc]: src/lcalc_function.ps1
[linkcheck]: src/linkcheck_function.ps1
[linkextract]: src/linkextract_function.ps1
[logi2dot]: src/logi2dot_function.ps1
[logi2pu]: src/logi2pu_function.ps1
[man2]: src/man2_function.ps1
[map2]: src/map2_function.ps1
[mind2dot]: src/mind2dot_function.ps1
[mind2pu]: src/mind2pu_function.ps1
[nextyear]: src/Get-DateAlternative_function.ps1
[Override-Yaml]: src/Override-Yaml_function.ps1
[pawk]: src/pawk_function.ps1
[pu2java]: src/pu2java_function.ps1
[pwmake]: src/pwmake_function.ps1
[retu]: src/retu_function.ps1
[rev]: src/rev_function.ps1
[rev2]: src/rev2_function.ps1
[say]: src/say_function.ps1
[sed-i]: src/sed-i_function.ps1
[sed]: src/sed_function.ps1
[self]: src/self_function.ps1
[sleepy]: src/sleepy_function.ps1
[sm2]: src/sm2_function.ps1
[table2md]: src/table2md_function.ps1
[tac]: src/tac_function.ps1
[tail]: src/tail_function.ps1
[tarr]: src/tarr_function.ps1
[tateyoko]: src/tateyoko_function.ps1
[teatimer]: src/teatimer_function.ps1
[tenki]: src/tenki_function.ps1
[tex2pdf]: src/tex2pdf_function.ps1
[thisyear]: src/Get-DateAlternative_function.ps1
[toml2psobject]: src/toml2psobject_function.ps1
[uniq]: src/uniq_function.ps1
[vbStrConv]: src/vbStrConv_function.ps1
[yarr]: src/yarr_function.ps1
[zen]: src/zen_function.ps1

[percentile]: src/percentile_function.ps1
[decil]: src/decil_function.ps1
[summary]: src/summary_function.ps1
[movw]: src/movw_function.ps1

[fpath]: src/fpath_function.ps1
[watercss]: src/watercss_function.ps1

[flow2pu]: src/flow2pu_function.ps1
[seq2pu]: src/seq2pu_function.ps1

[ysort]: src/ysort_function.ps1
[ycalc]: src/ycalc_function.ps1
[fval]: src/fval_function.ps1

[Get-AppShortcut]: src/Get-AppShortcut_function.ps1
[mdgrep]: src/mdgrep_function.ps1

[pwsync]: src/pwsync_function.ps1
[clip2file]: src/clip2file_function.ps1
[Rename-Normalize]: src/Rename-Normalize_function.ps1
[clip2normalize]: src/clip2normalize_function.ps1

[tail-f]: src/tail-f_function.ps1
[operator.ps1]: operator.ps1

[push2loc]: src/push2loc_function.ps1
[clip2push]: src/clip2push_function.ps1
[clip2shortcut]: src/clip2shortcut_function.ps1

[clip2hyperlinkl]: src/clip2hyperlink_function.ps1
[list2table]: src/list2table_function.ps1
[mdfocus]: src/mdfocus_function.ps1

[Add-LineBreak]: src/Add-LineBreak_function.ps1
[Add-LineBreakEndOfFile]: src/Add-LineBreakEndOfFile_function.ps1

[Shorten-PropertyName]: src/Shorten-PropertyName_function.ps1
[Drop-NA]: src/Drop-NA_function.ps1
[Replace-NA]: src/Replace-NA_function.ps1
[Apply-Function]: src/Apply-Function_function.ps1
[GroupBy-Object]: src/GroupBy-Object_function.ps1
[Measure-Stats]: src/Measure-Stats_function.ps1
[Add-Stats]: src/Add-Stats_function.ps1
[Detect-XrsAnomaly]: src/Detect-XrsAnomaly_function.ps1

[Get-Histogram]: src/Get-Histogram_function.ps1
[Plot-BarChart]: src/Plot-BarChart_function.ps1

[Get-First]: src/Get-First_function.ps1
[Get-Last]: src/Get-Last_function.ps1
[Select-Field]: src/Select-Field_function.ps1
[Delete-Field]: src/Delete-Field_function.ps1

[Replace-ForEach]: src/Replace-ForEach_function.ps1

[Measure-Quartile]: src/Measure-Quartile_function.ps1
[Add-Quartile]: src/Add-Quartile_function.ps1

[Join2-Object]: src/Join2-Object_function.ps1

[lcalc2]: src/lcalc2_function.ps1

[Unique-Object]: src/Unique-Object_function.ps1
[Measure-Summary]: src/Measure-Summary_function.ps1
[Transpose-Property]: src/Transpose-Property_function.ps1

[Edit-Function]: src/Edit-Function_function.ps1
[Get-Ticket]: src/Get-Ticket_function.ps1

[Decrease-Indent]: src/Decrease-Indent_function.ps1

[Set-NowTime2Clipboard]: src/Set-NowTime2Clipboard_function.ps1
[Sleep-ComputerAFM]: src/Sleep-ComputerAFM_function.ps1
[Shutdown-ComputerAFM]: src/Shutdown-ComputerAFM_function.ps1

[Unzip-Archive]: src/Unzip-Archive_function.ps1
[clip2unzip]: src/Unzip-Archive_function.ps1

[Get-ClipboardAlternative]: src/Get-ClipboardAlternative_function.ps1
[gclipa]: src/Get-ClipboardAlternative_function.ps1

[Test-isAsciiLine]: src/Test-isAsciiLine_function.ps1
[isAsciiLine]: src/Test-isAsciiLine_function.ps1

[Grep-Block]: src/Grep-Block_function.ps1
[Sort-Block]: src/Sort-Block_function.ps1

[Execute-TinyTeX]: src/Execute-TinyTeX_function.ps1
[Execute-RMarkdown]: src/Execute-RMarkdown_function.ps1

[math2tex]: src/math2tex_function.ps1
[Inkscape-Converter]: src/Inkscape-Converter_function.ps1

[GetValueFrom-Key]: src/GetValueFrom-Key_function.ps1

[Trim-EmptyLine]: src/Trim-EmptyLine_function.ps1

[Cast-Date]: src/Cast-Date_function.ps1
[Cast-Decimal]: src/Cast-Decimal_function.ps1
[Cast-Double]: src/Cast-Double_function.ps1
[Cast-Integer]: src/Cast-Integer_function.ps1
[Edit-Property]: src/Edit-Property_function.ps1

[ClipImageFrom-File]: src/ClipImageFrom-File_function.ps1

[Invoke-Link]: src/Invoke-Link_function.ps1

[Add-ID]: src/Add-ID_function.ps1

[Join-Line2]: src/Join-Line2_function.ps1

[Tee-Clip]: src/Tee-Clip_function.ps1
[Auto-Clip]: src/Auto-Clip_function.ps1

[PullOut-String]: src/PullOut-String_function.ps1

[Set-DotEnv]: src/Set-DotEnv_function.ps1

[Decode-Uri]: src/Decode-Uri_function.ps1
[Encode-Uri]: src/Encode-Uri_function.ps1

[unreleased]: https://github.com/btklab/posh-mocks/compare/7.5.1..HEAD
[7.5.1]: https://github.com/btklab/posh-mocks/releases/tag/7.5.1
[7.5.0]: https://github.com/btklab/posh-mocks/releases/tag/7.5.0
[7.4.2]: https://github.com/btklab/posh-mocks/releases/tag/7.4.1
[7.4.1]: https://github.com/btklab/posh-mocks/releases/tag/7.4.1
[7.4.0]: https://github.com/btklab/posh-mocks/releases/tag/7.4.0
[7.3.0]: https://github.com/btklab/posh-mocks/releases/tag/7.3.0
[7.2.4]: https://github.com/btklab/posh-mocks/releases/tag/7.2.4
[7.2.3]: https://github.com/btklab/posh-mocks/releases/tag/7.2.3
[7.2.2]: https://github.com/btklab/posh-mocks/releases/tag/7.2.2
[7.2.1]: https://github.com/btklab/posh-mocks/releases/tag/7.2.1
[7.2.0]: https://github.com/btklab/posh-mocks/releases/tag/7.2.0
[7.1.0]: https://github.com/btklab/posh-mocks/releases/tag/7.1.0
[7.0.0]: https://github.com/btklab/posh-mocks/releases/tag/7.0.0
[6.10.2]: https://github.com/btklab/posh-mocks/releases/tag/6.10.2
[6.10.1]: https://github.com/btklab/posh-mocks/releases/tag/6.10.1
[6.10.0]: https://github.com/btklab/posh-mocks/releases/tag/6.10.0
[6.9.0]: https://github.com/btklab/posh-mocks/releases/tag/6.9.0
[6.8.1]: https://github.com/btklab/posh-mocks/releases/tag/6.8.1
[6.8.0]: https://github.com/btklab/posh-mocks/releases/tag/6.8.0
[6.7.0]: https://github.com/btklab/posh-mocks/releases/tag/6.7.0
[6.6.0]: https://github.com/btklab/posh-mocks/releases/tag/6.6.0
[6.5.4]: https://github.com/btklab/posh-mocks/releases/tag/6.5.4
[6.5.3]: https://github.com/btklab/posh-mocks/releases/tag/6.5.3
[6.5.2]: https://github.com/btklab/posh-mocks/releases/tag/6.5.2
[6.5.1]: https://github.com/btklab/posh-mocks/releases/tag/6.5.1
[6.5.0]: https://github.com/btklab/posh-mocks/releases/tag/6.5.0
[6.4.0]: https://github.com/btklab/posh-mocks/releases/tag/6.4.0
[6.3.0]: https://github.com/btklab/posh-mocks/releases/tag/6.3.0
[6.2.1]: https://github.com/btklab/posh-mocks/releases/tag/6.2.1
[6.2.0]: https://github.com/btklab/posh-mocks/releases/tag/6.2.0
[6.1.1]: https://github.com/btklab/posh-mocks/releases/tag/6.1.1
[6.1.0]: https://github.com/btklab/posh-mocks/releases/tag/6.1.0
[6.0.0]: https://github.com/btklab/posh-mocks/releases/tag/6.0.0
[5.0.3]: https://github.com/btklab/posh-mocks/releases/tag/5.0.3
[5.0.2]: https://github.com/btklab/posh-mocks/releases/tag/5.0.2
[5.0.1]: https://github.com/btklab/posh-mocks/releases/tag/5.0.1
[5.0.0]: https://github.com/btklab/posh-mocks/releases/tag/5.0.0
[4.3.0]: https://github.com/btklab/posh-mocks/releases/tag/4.3.0
[4.2.4]: https://github.com/btklab/posh-mocks/releases/tag/4.2.4
[4.2.3]: https://github.com/btklab/posh-mocks/releases/tag/4.2.3
[4.2.2]: https://github.com/btklab/posh-mocks/releases/tag/4.2.2
[4.2.1]: https://github.com/btklab/posh-mocks/releases/tag/4.2.1
[4.2.0]: https://github.com/btklab/posh-mocks/releases/tag/4.2.0
[4.1.1]: https://github.com/btklab/posh-mocks/releases/tag/4.1.1
[4.1.0]: https://github.com/btklab/posh-mocks/releases/tag/4.1.0
[4.0.0]: https://github.com/btklab/posh-mocks/releases/tag/4.0.0
[3.14.3]: https://github.com/btklab/posh-mocks/releases/tag/3.14.3
[3.14.2]: https://github.com/btklab/posh-mocks/releases/tag/3.14.2
[3.14.1]: https://github.com/btklab/posh-mocks/releases/tag/3.14.1
[3.14.0]: https://github.com/btklab/posh-mocks/releases/tag/3.14.0
[3.13.1]: https://github.com/btklab/posh-mocks/releases/tag/3.13.1
[3.13.0]: https://github.com/btklab/posh-mocks/releases/tag/3.13.0
[3.12.0]: https://github.com/btklab/posh-mocks/releases/tag/3.12.0
[3.11.0]: https://github.com/btklab/posh-mocks/releases/tag/3.11.0
[3.10.1]: https://github.com/btklab/posh-mocks/releases/tag/3.10.1
[3.10.0]: https://github.com/btklab/posh-mocks/releases/tag/3.10.0
[3.9.0]: https://github.com/btklab/posh-mocks/releases/tag/3.9.0
[3.8.0]: https://github.com/btklab/posh-mocks/releases/tag/3.8.0
[3.7.0]: https://github.com/btklab/posh-mocks/releases/tag/3.7.0
[3.6.2]: https://github.com/btklab/posh-mocks/releases/tag/3.6.2
[3.6.1]: https://github.com/btklab/posh-mocks/releases/tag/3.6.1
[3.6.0]: https://github.com/btklab/posh-mocks/releases/tag/3.6.0
[3.5.0]: https://github.com/btklab/posh-mocks/releases/tag/3.5.0
[3.4.0]: https://github.com/btklab/posh-mocks/releases/tag/3.4.0
[3.3.1]: https://github.com/btklab/posh-mocks/releases/tag/3.3.1
[3.3.0]: https://github.com/btklab/posh-mocks/releases/tag/3.3.0
[3.2.0]: https://github.com/btklab/posh-mocks/releases/tag/3.2.0
[3.1.0]: https://github.com/btklab/posh-mocks/releases/tag/3.1.0
[3.0.1]: https://github.com/btklab/posh-mocks/releases/tag/3.0.1
[3.0.0]: https://github.com/btklab/posh-mocks/releases/tag/3.0.0
[2.1.3]: https://github.com/btklab/posh-mocks/releases/tag/2.1.3
[2.1.2]: https://github.com/btklab/posh-mocks/releases/tag/2.1.2
[2.1.1]: https://github.com/btklab/posh-mocks/releases/tag/2.1.1
[2.1.0]: https://github.com/btklab/posh-mocks/releases/tag/2.1.0
[2.0.0]: https://github.com/btklab/posh-mocks/releases/tag/2.0.0
[1.1.0]: https://github.com/btklab/posh-mocks/releases/tag/1.1.0
[1.0.0]: https://github.com/btklab/posh-mocks/releases/tag/1.0.0
[0.2.0]: https://github.com/btklab/posh-mocks/releases/tag/0.2.0
[0.1.0]: https://github.com/btklab/posh-mocks/releases/tag/0.1.0
