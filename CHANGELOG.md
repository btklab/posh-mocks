# Changelog

All notable changes to "posh-mocks" project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- None

### Added

- None

## [2.1.1]

### Changed

- Changed [i] behavior when non-existent file is specified.
- Fixed [README.md] examples.


## [2.1.0]

### Changed

- Breaking Change [ycalc], [percentile] change `-SkipHeader` option to `NoHeader` option. Input expects space-separated data with headers.
- Fixed [README.md], [logi2dot], [logi2pu], [percentile] typo.
- Fixed [addb], [addl], [addr], [movw], [tarr] replace tab to 4-spaces.

### Added

- Added [ysort], [ycalc], [fval] functions.
- Added [wrap] function.
- Added [percentile] supports multiple value fields. Missing/Empty value detection/removal/replacement.
- Added [flow2pu] [gantt2pu] [logi2pu] [mind2pu] [seq2pu] `-FontSize` option.


## [2.0.0]

### Changed

- Breaking Change [chead], [ctail] refactored.
- Fixed [i] error handling when file does not exist.


## [1.1.0]

### Changed

- Fixed [gantt2pu], [logi2pu], [mind2pu] Wrap title string in double quotes
- Changed [watercss] Synopsis
- Fixed [README.md]

### Added

- Added [flow2pu] function
- Added [seq2pu] function


## [1.0.0] - 2023-02-23

### Changed

- Added [README.md] hyperlinks to related file in section titles
- Enabled [map2] change upper-left-mark using `-UpperLeftMark` option

### Added

- Added [movw] function
- Added [decil] function
- Added [summary] function
- Added [fpath] function
- Added [watercss] function


## [0.2.0] - 2023-02-22

### Changed

- Changed [csv2sqlite] update examples
- Changed [CHANGELOG.md] test tagging and write CHANGELOG.md

### Added

- Added [percentile] function


## [0.1.0] - 2023-02-19

### Changed

- Changed Translate japanese to english

### Added 

- Added [Add-CrLf-EndOfFile], [Add-CrLf], [addb], [addl], [addr], [addt], [cat2], [catcsv], [chead], [clip2img], [clipwatch], [conv], [ConvImage], [count], [csv2sqlite], [csv2txt], [ctail], ctail2, [delf], [dot2gviz], [filehame], [fillretu], [flat], [fwatch], [gantt2pu], [gdate], [Get-OGP], [getfirst], [getlast], [grep], [gyo], [han], [head], [i], [image2md], [jl], [json2txt], [juni], [keta], [kinsoku], [lastyear], [lcalc], [linkcheck], [linkextract], [logi2dot], [logi2pu], [man2], [map2], [mind2dot], [mind2pu], [nextyear], [Override-Yaml], [pawk], [pu2java], [pwmake], [retu], [rev], [rev2], [say], [sed-i], [sed], [self], [sleepy], [sm2], [table2md], [tac], [tail], [tarr], [tateyoko], [teatimer], [tenki], [tex2pdf], [thisyear], [toml2psobject], [uniq], [vbStrConv], [yarr], [zen]



[README.md]: blob/main/README.md
[CHANGELOG.md]: blob/main/CHANGELOG.md

[Add-CrLf-EndOfFile]: src/Add-CrLf-EndOfFile_function.ps1
[Add-CrLf]: src/Add-CrLf_function.ps1
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
[i]: src/i_function.ps1
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


[unreleased]: https://github.com/btklab/posh-mocks/compare/2.1.1..HEAD
[2.1.1]: https://github.com/btklab/posh-mocks/releases/tag/2.1.1
[2.1.0]: https://github.com/btklab/posh-mocks/releases/tag/2.1.0
[2.0.0]: https://github.com/btklab/posh-mocks/releases/tag/2.0.0
[1.1.0]: https://github.com/btklab/posh-mocks/releases/tag/1.1.0
[1.0.0]: https://github.com/btklab/posh-mocks/releases/tag/1.0.0
[0.2.0]: https://github.com/btklab/posh-mocks/releases/tag/0.2.0
[0.1.0]: https://github.com/btklab/posh-mocks/releases/tag/0.1.0

