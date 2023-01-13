$pwshSrcDir = Join-Path $PSScriptRoot "src"

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
    . $pwshSrcDir/chead_function.ps1
    . $pwshSrcDir/ctail_function.ps1
    . $pwshSrcDir/ctail2_function.ps1

    . $pwshSrcDir/cat2_function.ps1
    . $pwshSrcDir/tac_function.ps1

    ## misc
    . $pwshSrcDir/say_function.ps1
    . $pwshSrcDir/teatimer_function.ps1
}

## get funcs
. $pwshSrcDir/man2_function.ps1


### pwsh implementation of gnu make command
. $pwshSrcDir/pwmake_function.ps1
#Set-Alias -name make -value pwmake

## text filter
. $pwshSrcDir/keta_function.ps1
. $pwshSrcDir/gyo_function.ps1
. $pwshSrcDir/tateyoko_function.ps1
. $pwshSrcDir/fillretu_function.ps1
. $pwshSrcDir/yarr_function.ps1
. $pwshSrcDir/tarr_function.ps1
. $pwshSrcDir/juni_function.ps1
. $pwshSrcDir/retu_function.ps1
. $pwshSrcDir/count_function.ps1

. $pwshSrcDir/flat_function.ps1

. $pwshSrcDir/Add-CrLf_function.ps1
. $pwshSrcDir/Add-CrLf-EndOfFile_function.ps1
. $pwshSrcDir/addb_function.ps1
. $pwshSrcDir/addl_function.ps1
. $pwshSrcDir/addr_function.ps1
. $pwshSrcDir/addt_function.ps1

## writing
. $pwshSrcDir/jl_function.ps1
. $pwshSrcDir/kinsoku_function.ps1

## web
. $pwshSrcDir/Get-OGP_function.ps1
Set-Alias -name ml -value Get-OGP

## csv
. $pwshSrcDir/catcsv_function.ps1
. $pwshSrcDir/csv2txt_function.ps1
. $pwshSrcDir/csv2sqlite_function.ps1

## TOML/JSON
. $pwshSrcDir/toml2psobject_function.ps1
. $pwshSrcDir/json2txt_function.ps1

## clipboard
. $pwshSrcDir/clip2img_function.ps1
. $pwshSrcDir/clipwatch_function.ps1

## file watcher
. $pwshSrcDir/fwatch_function.ps1


## office

## graph and plot

## sys admin

## statistics

## math

## misc
. $pwshSrcDir/sleepy_function.ps1

