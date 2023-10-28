<#
.SYNOPSIS
    Plot-BarChart - Plot Barchart on the console

        Plot-BarChart

            [-v|-Value] <String>
                Specify value property for plot barchart

            [[-k|-Key] <String[]>] (Optional)
                Specify puroperties to output

            [-w|-Width <Int32>] (Optional)
                Specify the maximum length of the chart from 1 to 100
                default 100

            [-m|-Mark <String>] (Optional)
                Specify the chart string

            [-MaxValue <Int32>] (Optional)
                Specify the maximum value of the chart manually

    Value property accept positive integers or positive decimals.
    Negavive values are considered zero.

    Output all properties by default. If -Key <property,property,...>
    specified, you can filter only required property.

    The maximum length (width) of the bar chart drawing area is as follows:

        (chart available area) =
            (Console width) - (Property width exclude barchart property)

    If specify the "-w|-Width <int 1-100>" option, the maximum width of
    the bar chart strings will be relative to the above width of 100.

    The maximum value of the graph is automatically obtained from the
    specified property.
    If you specify the -MaxValue <int> option, the maximum value will be
    set to the specified value.

    Original script:

        nicholasdille / PowerShell-Statistics / Add-Bar.ps1
            https://github.com/nicholasdille/PowerShell-Statistics/tree/master

        Changes from the original:
        
            - Newly written with reference only to the concept
            - Changed Function name, Options, Script
            - Use hashtable instead of Add-Member
            - Restrict from division by zero

        Original software Licensed under the Apache License, Version 2.0
        https://www.apache.org/licenses/LICENSE-2.0.html
        
                                        Apache License
                                Version 2.0, January 2004
                                http://www.apache.org/licenses/

        TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION

        1. Definitions.

            "License" shall mean the terms and conditions for use, reproduction,
            and distribution as defined by Sections 1 through 9 of this document.

            "Licensor" shall mean the copyright owner or entity authorized by
            the copyright owner that is granting the License.

            "Legal Entity" shall mean the union of the acting entity and all
            other entities that control, are controlled by, or are under common
            control with that entity. For the purposes of this definition,
            "control" means (i) the power, direct or indirect, to cause the
            direction or management of such entity, whether by contract or
            otherwise, or (ii) ownership of fifty percent (50%) or more of the
            outstanding shares, or (iii) beneficial ownership of such entity.

            "You" (or "Your") shall mean an individual or Legal Entity
            exercising permissions granted by this License.

            "Source" form shall mean the preferred form for making modifications,
            including but not limited to software source code, documentation
            source, and configuration files.

            "Object" form shall mean any form resulting from mechanical
            transformation or translation of a Source form, including but
            not limited to compiled object code, generated documentation,
            and conversions to other media types.

            "Work" shall mean the work of authorship, whether in Source or
            Object form, made available under the License, as indicated by a
            copyright notice that is included in or attached to the work
            (an example is provided in the Appendix below).

            "Derivative Works" shall mean any work, whether in Source or Object
            form, that is based on (or derived from) the Work and for which the
            editorial revisions, annotations, elaborations, or other modifications
            represent, as a whole, an original work of authorship. For the purposes
            of this License, Derivative Works shall not include works that remain
            separable from, or merely link (or bind by name) to the interfaces of,
            the Work and Derivative Works thereof.

            "Contribution" shall mean any work of authorship, including
            the original version of the Work and any modifications or additions
            to that Work or Derivative Works thereof, that is intentionally
            submitted to Licensor for inclusion in the Work by the copyright owner
            or by an individual or Legal Entity authorized to submit on behalf of
            the copyright owner. For the purposes of this definition, "submitted"
            means any form of electronic, verbal, or written communication sent
            to the Licensor or its representatives, including but not limited to
            communication on electronic mailing lists, source code control systems,
            and issue tracking systems that are managed by, or on behalf of, the
            Licensor for the purpose of discussing and improving the Work, but
            excluding communication that is conspicuously marked or otherwise
            designated in writing by the copyright owner as "Not a Contribution."

            "Contributor" shall mean Licensor and any individual or Legal Entity
            on behalf of whom a Contribution has been received by Licensor and
            subsequently incorporated within the Work.

        2. Grant of Copyright License. Subject to the terms and conditions of
            this License, each Contributor hereby grants to You a perpetual,
            worldwide, non-exclusive, no-charge, royalty-free, irrevocable
            copyright license to reproduce, prepare Derivative Works of,
            publicly display, publicly perform, sublicense, and distribute the
            Work and such Derivative Works in Source or Object form.

        3. Grant of Patent License. Subject to the terms and conditions of
            this License, each Contributor hereby grants to You a perpetual,
            worldwide, non-exclusive, no-charge, royalty-free, irrevocable
            (except as stated in this section) patent license to make, have made,
            use, offer to sell, sell, import, and otherwise transfer the Work,
            where such license applies only to those patent claims licensable
            by such Contributor that are necessarily infringed by their
            Contribution(s) alone or by combination of their Contribution(s)
            with the Work to which such Contribution(s) was submitted. If You
            institute patent litigation against any entity (including a
            cross-claim or counterclaim in a lawsuit) alleging that the Work
            or a Contribution incorporated within the Work constitutes direct
            or contributory patent infringement, then any patent licenses
            granted to You under this License for that Work shall terminate
            as of the date such litigation is filed.

        4. Redistribution. You may reproduce and distribute copies of the
            Work or Derivative Works thereof in any medium, with or without
            modifications, and in Source or Object form, provided that You
            meet the following conditions:

            (a) You must give any other recipients of the Work or
                Derivative Works a copy of this License; and

            (b) You must cause any modified files to carry prominent notices
                stating that You changed the files; and

            (c) You must retain, in the Source form of any Derivative Works
                that You distribute, all copyright, patent, trademark, and
                attribution notices from the Source form of the Work,
                excluding those notices that do not pertain to any part of
                the Derivative Works; and

            (d) If the Work includes a "NOTICE" text file as part of its
                distribution, then any Derivative Works that You distribute must
                include a readable copy of the attribution notices contained
                within such NOTICE file, excluding those notices that do not
                pertain to any part of the Derivative Works, in at least one
                of the following places: within a NOTICE text file distributed
                as part of the Derivative Works; within the Source form or
                documentation, if provided along with the Derivative Works; or,
                within a display generated by the Derivative Works, if and
                wherever such third-party notices normally appear. The contents
                of the NOTICE file are for informational purposes only and
                do not modify the License. You may add Your own attribution
                notices within Derivative Works that You distribute, alongside
                or as an addendum to the NOTICE text from the Work, provided
                that such additional attribution notices cannot be construed
                as modifying the License.

            You may add Your own copyright statement to Your modifications and
            may provide additional or different license terms and conditions
            for use, reproduction, or distribution of Your modifications, or
            for any such Derivative Works as a whole, provided Your use,
            reproduction, and distribution of the Work otherwise complies with
            the conditions stated in this License.

        5. Submission of Contributions. Unless You explicitly state otherwise,
            any Contribution intentionally submitted for inclusion in the Work
            by You to the Licensor shall be under the terms and conditions of
            this License, without any additional terms or conditions.
            Notwithstanding the above, nothing herein shall supersede or modify
            the terms of any separate license agreement you may have executed
            with Licensor regarding such Contributions.

        6. Trademarks. This License does not grant permission to use the trade
            names, trademarks, service marks, or product names of the Licensor,
            except as required for reasonable and customary use in describing the
            origin of the Work and reproducing the content of the NOTICE file.

        7. Disclaimer of Warranty. Unless required by applicable law or
            agreed to in writing, Licensor provides the Work (and each
            Contributor provides its Contributions) on an "AS IS" BASIS,
            WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
            implied, including, without limitation, any warranties or conditions
            of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A
            PARTICULAR PURPOSE. You are solely responsible for determining the
            appropriateness of using or redistributing the Work and assume any
            risks associated with Your exercise of permissions under this License.

        8. Limitation of Liability. In no event and under no legal theory,
            whether in tort (including negligence), contract, or otherwise,
            unless required by applicable law (such as deliberate and grossly
            negligent acts) or agreed to in writing, shall any Contributor be
            liable to You for damages, including any direct, indirect, special,
            incidental, or consequential damages of any character arising as a
            result of this License or out of the use or inability to use the
            Work (including but not limited to damages for loss of goodwill,
            work stoppage, computer failure or malfunction, or any and all
            other commercial damages or losses), even if such Contributor
            has been advised of the possibility of such damages.

        9. Accepting Warranty or Additional Liability. While redistributing
            the Work or Derivative Works thereof, You may choose to offer,
            and charge a fee for, acceptance of support, warranty, indemnity,
            or other liability obligations and/or rights consistent with this
            License. However, in accepting such obligations, You may act only
            on Your own behalf and on Your sole responsibility, not on behalf
            of any other Contributor, and only if You agree to indemnify,
            defend, and hold each Contributor harmless for any liability
            incurred by, or claims asserted against, such Contributor by reason
            of your accepting any such warranty or additional liability.


.LINK
    Shorten-PropertyName, Drop-NA, Replace-NA, Apply-Function, Add-Stats, Detect-XrsAnomaly, Plot-BarChart, Get-First, Get-Last, Select-Field, Delete-Field

    Add-MovingWindow, Get-Histogram

.EXAMPLE
    1..10 `
        | addt val `
        | ConvertFrom-Csv `
        | Plot-BarChart val -w 10 -m "|"

    val  BarChart
      -  --------
      1  |
      2  ||
      3  |||
      4  ||||
      5  |||||
      6  ||||||
      7  |||||||
      8  ||||||||
      9  |||||||||
      10 ||||||||||

.EXAMPLE
    cat iris.csv `
        | sed 's;([^,])[^,]+..._;$1_;g' `
        | sed 's;(_.)[^,]+;$1;g' `
        | head `
        | ConvertFrom-Csv `
        | Plot-BarChart s_l -w 40 -m "|" `
        | ft

    s_w p_l p_w species s_l BarChart
    --- --- --- ------- --- --------
    3.5 1.4 0.2 setosa  5.1 |||||||||||||||||||||||||||||||||||||
    3.0 1.4 0.2 setosa  4.9 ||||||||||||||||||||||||||||||||||||
    3.2 1.3 0.2 setosa  4.7 ||||||||||||||||||||||||||||||||||
    3.1 1.5 0.2 setosa  4.6 ||||||||||||||||||||||||||||||||||
    3.6 1.4 0.2 setosa  5.0 |||||||||||||||||||||||||||||||||||||
    3.9 1.7 0.4 setosa  5.4 ||||||||||||||||||||||||||||||||||||||||
    3.4 1.4 0.3 setosa  4.6 ||||||||||||||||||||||||||||||||||
    3.4 1.5 0.2 setosa  5.0 |||||||||||||||||||||||||||||||||||||
    2.9 1.4 0.2 setosa  4.4 ||||||||||||||||||||||||||||||||

.EXAMPLE
    # using Import-Excel module
    Import-Excel iris.xlsx `
        | Drop-NA sepal_length `
        | Shorten-PropertyName `
        | Plot-BarChart s_l -m "|" -w 20 `
        | ft

     s_w  p_l  p_w species  s_l BarChart
     ---  ---  --- -------  --- --------
    3.50 1.40 0.20 setosa  5.10 ||||||||||||
    3.00 1.40 0.20 setosa  4.90 ||||||||||||
    3.20 1.30 0.20 setosa  4.70 |||||||||||
    3.10 1.50 0.20 setosa  4.60 |||||||||||
    3.60 1.40 0.20 setosa  5.00 ||||||||||||
    3.90 1.70 0.40 setosa  5.40 |||||||||||||
    ...

.EXAMPLE
    ls ./tmp/ -File `
        | Plot-BarChart Length Name,Length -Mark "|" -w 40 `
        | ft

    Name  Length BarChart
    ----  ------ --------
    a.dot   2178 |||||||||
    a.md     209 |
    a.pu     859 |||
    a.svg   8842 ||||||||||||||||||||||||||||||||||||||||

.EXAMPLE
    cat iris.csv `
        | histogram -d "," -BIN_WIDTH .3 `
        | ConvertFrom-Csv `
        | Plot-BarChart Count sepal_length,Count -w 10 -Mark "@" `
        | ConvertTo-Csv -Delimiter " " `
        | chead `
        | sed 's;";;g' `
        | sed 's;@;| ;g' `
        | tateyoko `
        | tac `
        | keta

    output:
                      |
                      |
              |       |
              |       |
              |       |
              |       |   |       |  |
              |       |   |   |   |  |
      |       |   |   |   |   |   |  |
      |   |   |   |   |   |   |   |  |   |
      |   |   |   |   |   |   |   |  |   |   |   |   |
      9   7  25  11  28  15  13  14 15   6   2   4   1
    4.6 4.9 5.2 5.5 5.8 6.1 6.4 6.7  7 7.3 7.6 7.9 8.2

.EXAMPLE
    # Detect anomaly values by category(species)

    Import-Csv penguins.csv `
        | Drop-NA bill_length_mm `
        | Shorten-PropertyName `
        | sort species, island -Stable `
        | Apply-Function species, island {
            Detect-XrsAnomaly b_l_m -OnlyDeviationRecord } `
        |  ft count, key, b_l_m, sex, year, xrs

    count key            b_l_m sex  year xrs
    ----- ---            ----- ---  ---- ---
    186   Gentoo, Biscoe 59.6  male 2007   3

    # Visualization by plotting bar chart
    # on the console using Plot-BarChart function

    Import-Csv penguins.csv `
        | Drop-NA bill_length_mm `
        | Shorten-PropertyName `
        | sort species -Stable `
        | Apply-Function species {
            Detect-XrsAnomaly b_l_m -Detect } `
        | Plot-BarChart b_l_m count,species,xrs,detect -w 20 -m "|" `
        | ft `
        | oss `
        | sls "deviated" -Context 3
    
    count species xrs detect   b_l_m BarChart
    ----- ------- --- ------   ----- --------
      183 Gentoo    0           47.3 |||||||||||||||
      184 Gentoo    0           42.8 ||||||||||||||
      185 Gentoo    0           45.1 |||||||||||||||
    > 186 Gentoo    3 deviated  59.6 ||||||||||||||||||||
      187 Gentoo    0           49.1 ||||||||||||||||
      188 Gentoo    0           48.4 ||||||||||||||||
      189 Gentoo    0           42.6 ||||||||||||||

#>
function Plot-BarChart {

    [CmdletBinding()]
    [OutputType('PSCustomObject')]
    param (
        [Parameter( Mandatory=$True, Position=0 )]
        [Alias('v')]
        [string] $Value,
        
        [Parameter( Mandatory=$False, Position=1 )]
        [Alias('k')]
        [string[]] $Key,
        
        [Parameter( Mandatory=$False )]
        [Alias('w')]
        [int] $Width,
        
        [Parameter( Mandatory=$False )]
        [int] $MaxValue,
        
        [Parameter( Mandatory=$False )]
        [Alias('m')]
        [string] $Mark,
        
        [Parameter( Mandatory=$False )]
        [Alias('n')]
        [string] $Name = "BarChart",
        
        [Parameter( Mandatory=$False )]
        [switch] $Percentile,
        
        [Parameter( Mandatory=$False )]
        [switch] $PercentileFromBar,
        
        [parameter( Mandatory=$False, ValueFromPipeline=$True )]
        [array] $InputObject
    )
    function Get-UIBufferSize {
        return (Get-Host).UI.RawUI.BufferSize
    }
    function Get-LineWidth {
        param (
            [Parameter(Mandatory=$True)]
            [string] $Line
        )
        [int] $lineWidth = 0
        $enc = [System.Text.Encoding]::GetEncoding("Shift_JIS")
        [int] $lineWidth = $enc.GetByteCount($Line)
        return $lineWidth
    }
    # Test property
    [bool] $isPropertyExists = $False
    [String[]] $AllPropertyNames = ($input[0].PSObject.Properties).Name
    foreach ( $PropertyName in $AllPropertyNames ) {
        if ( $PropertyName -eq $Value ){
            $isPropertyExists = $True
        }
    }
    if ( -not $isPropertyExists ){
        Write-Error "Property: $Value is not exists." -ErrorAction Stop
    }
    # Get console width
    [int] $ConsoleWidth = (Get-UIBufferSize).Width
    Write-Debug "Console width = $ConsoleWidth"
    # Get Property MaxValue
    $HashArguments = @{
        Property = $Value
        Maximum = $True
        Minimum = $True
        Average = $True
    }
    [object[]] $mObj = $input `
        | Select-Object * `
        | Measure-Object @HashArguments
    if ( $MaxValue ){
        # Manually set max value of value property
        [decimal] $PropertyMaxValue = $MaxValue
    } else {
        [decimal] $PropertyMaxValue = $mObj.Maximum
    }
    # test MaxValue
    if ( $PropertyMaxValue -eq 0 ){
        Write-Error "The maximum value is zero. Attempted to divide by zero." -ErrorAction Stop
    }
    Write-Debug "Property Max = $PropertyMaxValue"
    if ( $PercentileFromBar ){
        [decimal] $PropertyMeanValue  = $mObj.Average
        Write-Debug "Property Mean = $PropertyMeanValue"
    }
    if ( $PercentileFromMin ){
        [decimal] $PropertyMinValue  = $mObj.Minimum
        Write-Debug "Property Min = $PropertyMinValue"
    }
    # Create output property array
    # exclude soecified value property
    [bool] $isValuePropertyExist = $False
    [String[]] $KeyHeaders = ($input[0].PSObject.Properties).Name `
        | ForEach-Object {
            if ( $_ -eq $Value ){
                [bool] $isValuePropertyExist = $True
            }
            if ( $Key ){
                if ( ($Key -contains $_) -and -not ($_ -eq $Value) ){
                    Write-Output $_
                }
            } else {
                if ( $_ -ne $Value ){
                    Write-Output $_
                }
            }
        }
    # test is exist value property
    if ( -not $isValuePropertyExist ){
        Write-Error "Property: $Value is not exists." -ErrorAction Stop
    }
    # set specified value property
    $KeyHeaders += $Value
    Write-Debug "KeyHeaders = $($KeyHeaders -join ', ')"
    # 1st pass: Get KeyProperty maximum width
    # get the longer string length of property name and value
    $hash = @{}
    foreach ( $kh in $KeyHeaders ){
        if ( $kh -ne $Value ){ $hash[$kh] = 0 }
    }
    foreach ( $obj in @($input | Select-Object -Property $KeyHeaders)){
        foreach ( $k in $KeyHeaders ){
            # get length of property name 
            [int] $headLineWidth = Get-LineWidth($k)
            # get length of each property value
            if ( [string]($obj.$k) -eq '' -or $obj.$k -eq $Null ){
                [int] $propLineWidth = 0
            } else {
                [int] $propLineWidth = Get-LineWidth($obj.$k)
            }
            # get the longer string length of property name and value
            if ( $propLineWidth -gt $headLineWidth ){
                # case: property value longer than neme
                if ( $propLineWidth -gt $hash[$k] ){
                    $hash[$k] = $propLineWidth
                }
            } else {
                # case: property name longer than value
                if ( $headLineWidth -gt $hash[$k] ){
                    $hash[$k] = $headLineWidth
                }
            }
        }
    }
    # calculate key property maximum width
    ## Set a space between properties
    [int] $KeyMaxWidth = $KeyHeaders.Count
    ## Add the maximum string width for each property
    foreach ( $k in $hash.keys ){
        $KeyMaxWidth += [int]($hash[$k])
        Write-Debug "$k, $($hash[$k])"
    }
    Write-Debug "KeyMaxWidth = $KeyMaxWidth"
    # get available chart area (console with)
    [int] $MaxRange = $ConsoleWidth - $KeyMaxWidth - 2
    if ( $Percentile -or $PercentileFromBar ){
        [string] $PercentilePropName = "Percent"
        $MaxRange = $MaxRange - ("$PercentilePropName".Length)
    }
    if ( $Width ){
        [int] $MaxRange = $Width
    }
    if ( $MaxRange -lt 1 ){
        [int] $MaxRange = 1
    }
    Write-Debug "MaxRange = $MaxRange"
    # 2nd pass
    ## set bar chart string
    if ( $Mark ){
        [string] $BarCharactor = $Mark
    } else {
        [string] $BarCharactor = [char] 9608
    }
    ## plot barchart
    foreach ( $obj in @($input | Select-Object -Property $KeyHeaders) ){
        [decimal] $Ratio = [decimal]($obj.$Value) / [decimal]($PropertyMaxValue)
        [int] $BarLength = [math]::Floor($MaxRange * $Ratio)
        if ( $BarLength -le 0 ){
            $BarLength = 0
        } elseif ( $BarLength -lt 1 ){
            $BarLength = 1
        }
        Write-Debug "$BarLength / $MaxRange"
        [string] $BarStrings = $BarCharactor * $BarLength
        #[string] $BarStrings = " " * ($BarLength - 1) + $BarCharactor
        # convert psobject to hash
        $hash = [ordered] @{}
        foreach ($item in $obj.psobject.properties){
            $hash[$item.Name] = $item.Value
        }
        if ( $Percentile ){
            $hash["$PercentilePropName"] = $("{0:0.0000}" -f $Ratio)
        } elseif ( $PercentileFromBar ){
            $hash["$PercentilePropName"] = $("{0:0.0000}" -f $($obj.$Value / $PropertyMeanValue))
        } elseif ( $PercentileFromMin ){
            $hash["$PercentilePropName"] = $("{0:0.0000}" -f $($obj.$Value / $PropertyMinValue))
        }
        if ( $True ){
            $hash["$Name"] = $BarStrings
        }
        # convert hash to psobject
        New-Object psobject -Property $hash
    }
}
