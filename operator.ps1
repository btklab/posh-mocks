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
    ## private functions
    function Restart-Explorer {
        Stop-Process -ProcessName explorer -Force
    }
    Set-Alias -Name rmExplorer -Value Restart-Explorer -PassThru | ForEach-Object{ Write-Host "$($_.DisplayName)" -ForegroundColor Green }

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
    . $pwshSrcDir/push2loc_function.ps1

    ## misc
    . $pwshSrcDir/say_function.ps1
    . $pwshSrcDir/teatimer_function.ps1
    . $pwshSrcDir/Sleep-ComputerAFM_function.ps1
    . $pwshSrcDir/Shutdown-ComputerAFM_function.ps1

    . $pwshSrcDir/Set-DotEnv_function.ps1
}

## get/edit funcs
. $pwshSrcDir/man2_function.ps1
. $pwshSrcDir/Edit-Function_function.ps1


### pwsh implementation of gnu make command
. $pwshSrcDir/pwmake_function.ps1
#Set-Alias -name make -value pwmake -PassThru | ForEach-Object{ Write-Host "$($_.DisplayName)" -ForegroundColor Green }
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

. $pwshSrcDir/Add-LineBreak_function.ps1
. $pwshSrcDir/Add-LineBreakEndOfFile_function.ps1
. $pwshSrcDir/Trim-EmptyLine_function.ps1
. $pwshSrcDir/ForEach-Block_function.ps1
. $pwshSrcDir/ForEach-Step_function.ps1
. $pwshSrcDir/Add-ForEach_function.ps1


. $pwshSrcDir/lcalc_function.ps1
. $pwshSrcDir/lcalc2_function.ps1
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

. $pwshSrcDir/PullOut-String_function.ps1

### gdate includes thisyear, nextyear, lastyear
. $pwshSrcDir/Get-DateAlternative_function.ps1

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
. $pwshSrcDir/mdfocus_function.ps1

. $pwshSrcDir/Execute-TinyTeX_function.ps1
. $pwshSrcDir/Execute-RMarkdown_function.ps1
. $pwshSrcDir/Inkscape-Converter_function.ps1

. $pwshSrcDir/math2tex_function.ps1
. $pwshSrcDir/tex2pdf_function.ps1
. $pwshSrcDir/jl_function.ps1
. $pwshSrcDir/Join-Line2_function.ps1
. $pwshSrcDir/kinsoku_function.ps1
. $pwshSrcDir/filehame_function.ps1
. $pwshSrcDir/table2md_function.ps1
. $pwshSrcDir/image2md_function.ps1
. $pwshSrcDir/Override-Yaml_function.ps1
. $pwshSrcDir/list2table_function.ps1

## web
. $pwshSrcDir/linkcheck_function.ps1
. $pwshSrcDir/linkextract_function.ps1
. $pwshSrcDir/Get-OGP_function.ps1
. $pwshSrcDir/Decode-Uri_function.ps1
. $pwshSrcDir/Encode-Uri_function.ps1
. $pwshSrcDir/fpath_function.ps1
. $pwshSrcDir/watercss_function.ps1

## csv
. $pwshSrcDir/catcsv_function.ps1
. $pwshSrcDir/csv2txt_function.ps1
. $pwshSrcDir/csv2sqlite_function.ps1

## TOML/JSON
. $pwshSrcDir/toml2psobject_function.ps1
if ( [double]("$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)") -ge 7.3 ){
    . $pwshSrcDir/json2txt_function.ps1
}

## clipboard operation
if ( $IsWindows ){
    . $pwshSrcDir/clip2img_function.ps1
    . $pwshSrcDir/clip2file_function.ps1
    . $pwshSrcDir/clip2normalize_function.ps1
    . $pwshSrcDir/clip2push_function.ps1
    . $pwshSrcDir/clip2hyperlink_function.ps1
    . $pwshSrcDir/clip2shortcut_function.ps1
    . $pwshSrcDir/ClipImageFrom-File_function.ps1
    . $pwshSrcDir/Get-ClipboardAlternative_function.ps1
    . $pwshSrcDir/Tee-Clip_function.ps1
    . $pwshSrcDir/Auto-Clip_function.ps1
}
. $pwshSrcDir/Decrease-Indent_function.ps1
. $pwshSrcDir/Unzip-Archive_function.ps1

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

# statistics - Anomaly detection
. $pwshSrcDir/Shorten-PropertyName_function.ps1
. $pwshSrcDir/Drop-NA_function.ps1
. $pwshSrcDir/Replace-NA_function.ps1
. $pwshSrcDir/Apply-Function_function.ps1
. $pwshSrcDir/GroupBy-Object_function.ps1
. $pwshSrcDir/Measure-Stats_function.ps1
. $pwshSrcDir/Add-Stats_function.ps1
. $pwshSrcDir/Measure-Quartile_function.ps1
. $pwshSrcDir/Add-Quartile_function.ps1
. $pwshSrcDir/Detect-XrsAnomaly_function.ps1
. $pwshSrcDir/Measure-Summary_function.ps1
. $pwshSrcDir/Transpose-Property_function.ps1

. $pwshSrcDir/Get-Histogram_function.ps1
. $pwshSrcDir/Plot-BarChart_function.ps1

. $pwshSrcDir/Get-First_function.ps1
. $pwshSrcDir/Get-Last_function.ps1
. $pwshSrcDir/Select-Field_function.ps1
. $pwshSrcDir/Delete-Field_function.ps1
. $pwshSrcDir/Unique-Object_function.ps1

. $pwshSrcDir/GetValueFrom-Key_function.ps1

. $pwshSrcDir/Replace-ForEach_function.ps1

. $pwshSrcDir/Join2-Object_function.ps1

. $pwshSrcDir/Cast-Date_function.ps1
. $pwshSrcDir/Cast-Decimal_function.ps1
. $pwshSrcDir/Cast-Double_function.ps1
. $pwshSrcDir/Cast-Integer_function.ps1
. $pwshSrcDir/Edit-Property_function.ps1

## math

## task/ticket management
. $pwshSrcDir/Get-Ticket_function.ps1
. $pwshSrcDir/Invoke-Link_function.ps1

. $pwshSrcDir/Sort-Block_function.ps1
. $pwshSrcDir/Grep-Block_function.ps1

## misc
. $pwshSrcDir/Test-isAsciiLine_function.ps1
. $pwshSrcDir/Set-NowTime2Clipboard_function.ps1
. $pwshSrcDir/tenki_function.ps1
. $pwshSrcDir/sleepy_function.ps1
. $pwshSrcDir/Get-AppShortcut_function.ps1

