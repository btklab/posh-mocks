# small functions
# is file exists?
function isFileExists ([string]$f){
    if(-not (Test-Path -LiteralPath "$f")){
        return $True
    } else {
        return $False
    }
}
# is command exist?
function isCommandExist ([string]$cmd) {
    try { Get-Command $cmd -ErrorAction Stop | Out-Null
        return $True
    } catch {
        return $False
    }
}
function Celsius2Fahrenheit ( [float] $C ){
    return $($C * 1.8 + 32)
}
function Fahrenheit2Celsius ( [float] $F ){
    return $(( $F - 32 ) / 1.8)
}
# for windows only
if ($IsWindows){
    # Set-Alias
    if($PSVersionTable.PSVersion.Major -ge 5){
        Set-Alias -Name wzip -Value Compress-Archive -PassThru | ForEach-Object{ Write-Host "$($_.DisplayName)" -ForegroundColor Green }
        Set-Alias -Name wunzip -Value Expand-Archive -PassThru | ForEach-Object{ Write-Host "$($_.DisplayName)" -ForegroundColor Green }
    }
    function which($cmdname) {
        Get-Command $cmdname -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Definition
    }
    function Get-ImeDict {
        Get-ChildItem -LiteralPath "$HOME\AppData\Roaming\Microsoft\IME\15.0\IMEJP\UserDict\"
    }
    function sudo {Start-Process pwsh.exe -Verb runas}
    function Get-FontFamilies {
        return (New-Object "System.Drawing.Text.InstalledFontCollection").Families
    }
}
if ($IsLinux){
    # replace-alias
    if( Test-Path alias:curl ){ Remove-Alias curl }
    if( Test-Path alias:wget ){ Remove-Alias wget }
    if( Test-Path alias:echo ){ Remove-Alias echo }
    # set-alias
    Set-Alias -Name ls -Value Get-ChildItem -PassThru | ForEach-Object{ Write-Host "$($_.DisplayName)" -ForegroundColor Green }
    Set-Alias -Name cp -Value Copy-Item -PassThru | ForEach-Object{ Write-Host "$($_.DisplayName)" -ForegroundColor Green }
    Set-Alias -Name mv -Value Move-Item -PassThru | ForEach-Object{ Write-Host "$($_.DisplayName)" -ForegroundColor Green }
    Set-Alias -Name rm -Value Remove-Item -PassThru | ForEach-Object{ Write-Host "$($_.DisplayName)" -ForegroundColor Green }
    Set-Alias -Name cat -Value Get-Content -PassThru | ForEach-Object{ Write-Host "$($_.DisplayName)" -ForegroundColor Green }
    Set-Alias -Name sort -Value Sort-Object -PassThru | ForEach-Object{ Write-Host "$($_.DisplayName)" -ForegroundColor Green }
}
