[string] $pwshSrcDir = Join-Path $PSScriptRoot "src"
[string] $pwshSrcDir = $pwshSrcDir.Replace('\', '/')

# for windows only
if ($IsWindows){
    ## set encode utf8
    chcp 65001
    #$OutputEncoding = [System.Text.Encoding]::UTF8
    [System.Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")
    [System.Console]::InputEncoding  = [System.Text.Encoding]::GetEncoding("utf-8")
    # compartible with multi byte code
    $env:LESSCHARSET = "utf-8"
}
if ($IsWindows){
    ## unix-like commands
    . $pwshSrcDir/sed_function.ps1
    . $pwshSrcDir/sed-i_function.ps1
    . $pwshSrcDir/grep_function.ps1
    . $pwshSrcDir/uniq_function.ps1

    . $pwshSrcDir/head_function.ps1
    . $pwshSrcDir/tail_function.ps1
    . $pwshSrcDir/tail-f_function.ps1
    . $pwshSrcDir/chead_function.ps1
    . $pwshSrcDir/ctail_function.ps1

    . $pwshSrcDir/cat2_function.ps1
    . $pwshSrcDir/tac_function.ps1
    . $pwshSrcDir/rev_function.ps1

    ## file and directory manipuration
    . $pwshSrcDir/Rename-Normalize_function.ps1
    Set-Alias -name ren2norm -value Rename-Normalize
    . $pwshSrcDir/push2loc_function.ps1

    ## misc
    . $pwshSrcDir/say_function.ps1
    . $pwshSrcDir/teatimer_function.ps1
}

## get funcs
. $pwshSrcDir/man2_function.ps1


### pwsh implementation of gnu make command
. $pwshSrcDir/pwmake_function.ps1
#Set-Alias -name make -value pwmake
. $pwshSrcDir/pwsync_function.ps1

## text filter
. $pwshSrcDir/keta_function.ps1
. $pwshSrcDir/self_function.ps1
. $pwshSrcDir/delf_function.ps1
. $pwshSrcDir/sm2_function.ps1
. $pwshSrcDir/map2_function.ps1
. $pwshSrcDir/gyo_function.ps1
. $pwshSrcDir/tateyoko_function.ps1
. $pwshSrcDir/fillretu_function.ps1
. $pwshSrcDir/yarr_function.ps1
. $pwshSrcDir/tarr_function.ps1
. $pwshSrcDir/juni_function.ps1
. $pwshSrcDir/retu_function.ps1
. $pwshSrcDir/count_function.ps1
. $pwshSrcDir/getfirst_function.ps1
. $pwshSrcDir/getlast_function.ps1
. $pwshSrcDir/fval_function.ps1

. $pwshSrcDir/Add-CrLf_function.ps1
. $pwshSrcDir/Add-CrLf-EndOfFile_function.ps1

. $pwshSrcDir/lcalc_function.ps1
. $pwshSrcDir/pawk_function.ps1

. $pwshSrcDir/han_function.ps1
. $pwshSrcDir/zen_function.ps1
. $pwshSrcDir/vbStrConv_function.ps1

. $pwshSrcDir/flat_function.ps1
. $pwshSrcDir/addb_function.ps1
. $pwshSrcDir/addl_function.ps1
. $pwshSrcDir/addr_function.ps1
. $pwshSrcDir/addt_function.ps1
. $pwshSrcDir/rev2_function.ps1
. $pwshSrcDir/conv_function.ps1
. $pwshSrcDir/wrap_function.ps1

### gdate includes thisyear, nextyear, lastyear
. $pwshSrcDir/gdate_function.ps1

## graph and chart
. $pwshSrcDir/dot2gviz_function.ps1
. $pwshSrcDir/pu2java_function.ps1

. $pwshSrcDir/gantt2pu_function.ps1
. $pwshSrcDir/mind2dot_function.ps1
. $pwshSrcDir/mind2pu_function.ps1
. $pwshSrcDir/logi2dot_function.ps1
. $pwshSrcDir/logi2pu_function.ps1
. $pwshSrcDir/flow2pu_function.ps1
. $pwshSrcDir/seq2pu_function.ps1


## image processing
. $pwshSrcDir/ConvImage_function.ps1


## writing
. $pwshSrcDir/mdgrep_function.ps1
. $pwshSrcDir/tex2pdf_function.ps1
. $pwshSrcDir/jl_function.ps1
. $pwshSrcDir/kinsoku_function.ps1
. $pwshSrcDir/filehame_function.ps1
. $pwshSrcDir/table2md_function.ps1
. $pwshSrcDir/image2md_function.ps1
. $pwshSrcDir/Override-Yaml_function.ps1

## web
. $pwshSrcDir/linkcheck_function.ps1
. $pwshSrcDir/linkextract_function.ps1
. $pwshSrcDir/Get-OGP_function.ps1
Set-Alias -name ml -value Get-OGP
. $pwshSrcDir/fpath_function.ps1
. $pwshSrcDir/watercss_function.ps1

## csv
. $pwshSrcDir/catcsv_function.ps1
. $pwshSrcDir/csv2txt_function.ps1
. $pwshSrcDir/csv2sqlite_function.ps1

## TOML/JSON
. $pwshSrcDir/toml2psobject_function.ps1
. $pwshSrcDir/json2txt_function.ps1

## clipboard
. $pwshSrcDir/clip2img_function.ps1
. $pwshSrcDir/clip2file_function.ps1
. $pwshSrcDir/clip2normalize_function.ps1
. $pwshSrcDir/clip2push_function.ps1
. $pwshSrcDir/clip2hyperlink_function.ps1
if ( $IsWindows ){
. $pwshSrcDir/clip2shortcut_function.ps1
}


## file watcher
. $pwshSrcDir/fwatch_function.ps1


## office

## sys admin

## statistics
. $pwshSrcDir/percentile_function.ps1
. $pwshSrcDir/decil_function.ps1
. $pwshSrcDir/summary_function.ps1
. $pwshSrcDir/movw_function.ps1
. $pwshSrcDir/ysort_function.ps1
. $pwshSrcDir/ycalc_function.ps1

## math

## misc
. $pwshSrcDir/i_function.ps1
. $pwshSrcDir/tenki_function.ps1
. $pwshSrcDir/sleepy_function.ps1
. $pwshSrcDir/Get-AppShortcut_function.ps1

