# Changelog

All notable changes to "posh-mocks" project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [unreleased]

- NA

## [5.0.0] - 2023-09-22

### New functions

- Added: [Shorten-PropertyName] function
- Added: [Drop-NA], [Replace-NA] function
- Added: [Apply-Function] function
- Added: [GroupBy-Object] function
- Added: [Measure-Property] function
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
- Added `Add-CrLf-EndOfFile`, `Add-CrLf`, [addb], [addl], [addr], [addt], [cat2], [catcsv], [chead], [clip2img], [clipwatch], [conv], [ConvImage], [count], [csv2sqlite], [csv2txt], [ctail], ctail2, [delf], [dot2gviz], [filehame], [fillretu], [flat], [fwatch], [gantt2pu], [gdate], [Get-OGP], [getfirst], [getlast], [grep], [gyo], [han], [head], `i`, [image2md], [jl], [json2txt], [juni], [keta], [kinsoku], [lastyear], [lcalc], [linkcheck], [linkextract], [logi2dot], [logi2pu], [man2], [map2], [mind2dot], [mind2pu], [nextyear], [Override-Yaml], [pawk], [pu2java], [pwmake], [retu], [rev], [rev2], [say], [sed-i], [sed], [self], [sleepy], [sm2], [table2md], [tac], [tail], [tarr], [tateyoko], [teatimer], [tenki], [tex2pdf], [thisyear], [toml2psobject], [uniq], [vbStrConv], [yarr], [zen]



[README.md]: blob/main/README.md
[CHANGELOG.md]: blob/main/CHANGELOG.md

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
[gdate]: src/gdate_function.ps1
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
[lastyear]: src/gdate_function.ps1
[lcalc]: src/lcalc_function.ps1
[linkcheck]: src/linkcheck_function.ps1
[linkextract]: src/linkextract_function.ps1
[logi2dot]: src/logi2dot_function.ps1
[logi2pu]: src/logi2pu_function.ps1
[man2]: src/man2_function.ps1
[map2]: src/map2_function.ps1
[mind2dot]: src/mind2dot_function.ps1
[mind2pu]: src/mind2pu_function.ps1
[nextyear]: src/gdate_function.ps1
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
[thisyear]: src/gdate_function.ps1
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

[Apply-Function]: src/Apply-Function_function.ps1
[Detect-XrsAnomaly]: src/Detect-XrsAnomaly_function.ps1
[Drop-NA]: src/Drop-NA_function.ps1
[Replace-NA]: src/Replace-NA_function.ps1
[Get-RandomRecord]: src/Get-RandomRecord_function.ps1
[Plot-BarChart]: src/Plot-BarChart_function.ps1

[Add-LineBreak]: src/Add-LineBreak_function.ps1
[Add-LineBreakEndOfFile]: src/Add-LineBreakEndOfFile_function.ps1

[Shorten-PropertyName]: src/Shorten-PropertyName_function.ps1
[Drop-NA]: src/Drop-NA_function.ps1
[Replace-NA]: src/Replace-NA_function.ps1
[Apply-Function]: src/Apply-Function_function.ps1
[GroupBy-Object]: src/GroupBy-Object_function.ps1
[Measure-Property]: src/Measure-Property_function.ps1
[Add-Stats]: src/Add-Stats_function.ps1
[Detect-XrsAnomaly]: src/Detect-XrsAnomaly_function.ps1
[Plot-BarChart]: src/Plot-BarChart_function.ps1

[Get-First]: src/Get-First_function.ps1
[Get-Last]: src/Get-Last_function.ps1
[Select-Field]: src/Select-Field_function.ps1
[Delete-Field]: src/Delete-Field_function.ps1


[unreleased]: https://github.com/btklab/posh-mocks/compare/5.0.0..HEAD
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

