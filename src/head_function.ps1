<#
.SYNOPSIS
    Head-Object (Alias: head) - Output the first part of files

    Output only the specified number of lines from the beginning
    of lines.

    Defaults to 10 lines of output.
    
    If file is not specified, it is read from the pipeline input.

.LINK
    head, tail

.EXAMPLE
    head *.* -n 3

    ==> timeline-date-val.txt <==
    date val1 val2
    2018-01 107.3 272.1
    2018-02 98.1 262.1

    ==> tips.csv <==
    "total_bill","tip","sex","smoker","day","time","size"
    16.99,1.01,"Female","No","Sun","Dinner",2
    10.34,1.66,"Male","No","Sun","Dinner",3

    ==> titanic.csv <==
    survived,pclass,sex,age,sibsp,parch,fare,embarked,class,who,adult_male,deck,embark_town,alive,alone
    0,3,male,22.0,1,0,7.25,S,Third,man,True,,Southampton,no,False
    1,1,female,38.0,1,0,71.2833,C,First,woman,False,C,Cherbourg,yes,False
#>
function Head-Object {
    Param(
        [Parameter(Mandatory=$False,Position=0)]
        [alias('p')]
        [string[]] $Path,
        
        [Parameter(Mandatory=$False)]
        [alias('n')]
        [int] $Num = 10,
        
        [parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [string[]] $InputObject
    )
    # main
    ## If file paths specified as an argument
    if ( $Path ){
        [object[]] $PathObjects = Get-ChildItem -Path $Path
        Write-Debug $PathObjects.Count
        if ( $PathObjects.Count -eq 1 ){
            # output contents
            $splatting = @{
                Path       = $Path
                TotalCount = $Num
                Encoding   = "utf8"
            }
            Get-Content @splatting
        } else {
            # output contents with file name
            foreach ( $p in $PathObjects ){
                [string] $fileName = $p.Name
                $splatting = @{
                    Path       = $p.FullName
                    TotalCount = $Num
                    Encoding   = "utf8"
                }
                Write-Host ""
                Write-Host "==> $fileName <==" -ForegroundColor Green
                Get-Content @splatting
            }
        }
        return
    }
    ## If a text object is input from the pipeline
    $splatting = @{
        First = $Num
    }
    $input | Select-Object @splatting
    return
}
# set alias
[String] $tmpAliasName = "head"
[String] $tmpCmdName   = "Head-Object"
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
