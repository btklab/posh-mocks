<#
.SYNOPSIS
    Measure-Summary (Alias: msummary) - Generate summary statistics for dataset

    Generate summary statistics for dataset.
    The numeric columns are automatically detected.
    NaN values are automatically excluded.
    
    Pre "Sort-Object -Stable" is no needed.

        Original script:

            nicholasdille / PowerShell-Statistics / Measure-Object.ps1
            https://github.com/nicholasdille/PowerShell-Statistics/tree/master

            Changes from the original:
                - Change function name
                - Allow value from pipeline
                - Give an alias to options
                - Add -Key option
                - Specify the quartile when the number of
                  data is 0 to 8
                - Add Outlier property
                - Use hashtable instead of Add-Member
                - Enable auto-select properties

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
    Measure-Object, Measure-Stats, Measure-Quartile, Measure-Summary, Transpose-Property

.EXAMPLE
    Import-Csv -Path iris.csv `
        | Measure-Summary `
        | Format-Table

    Property      Count Mean   SD  Min Qt25 Median Qt75  Max Outlier
    --------      ----- ----   --  --- ---- ------ ----  --- -------
    sepal_length 150.00 5.84 0.83 4.30 5.10   5.80 6.40 7.90    0.00
    sepal_width  150.00 3.06 0.44 2.00 2.80   3.00 3.40 4.40    1.00
    petal_length 150.00 3.76 1.77 1.00 1.60   4.35 5.10 6.90    0.00
    petal_width  150.00 1.20 0.76 0.10 0.30   1.30 1.80 2.50    0.00

    # with Transpose-Property
    Import-Csv -Path iris.csv `
        | Measure-Summary `
        | Transpose-Property -Property "Property" `
        | Format-Table

    Property sepal_length sepal_width petal_length petal_width
    -------- ------------ ----------- ------------ -----------
    Count          150.00      150.00       150.00      150.00
    Mean             5.84        3.06         3.76        1.20
    SD               0.83        0.44         1.77        0.76
    Min              4.30        2.00         1.00        0.10
    Qt25             5.10        2.80         1.60        0.30
    Median           5.80        3.00         4.35        1.30
    Qt75             6.40        3.40         5.10        1.80
    Max              7.90        4.40         6.90        2.50
    Outlier          0.00        1.00         0.00        0.00

.EXAMPLE
    Import-Csv -Path iris.csv `
        | Shorten-PropertyName `
        | Measure-Summary -Property "s_w"

    Property : s_w
    Count    : 150
    Mean     : 3.05733333333333
    SD       : 0.435866284936699
    Min      : 2
    Qt25     : 2.8
    Median   : 3
    Qt75     : 3.4
    Max      : 4.4
    Outlier  : 1

.EXAMPLE
    Import-Csv -Path iris.csv `
        | Shorten-PropertyName `
        | Measure-Summary -Property "s_w" -Detail

    Property     : s_w
    Count        : 150
    Mean         : 3.05733333333333
    SD           : 0.435866284936699
    Min          : 2
    Qt25         : 2.8
    Median       : 3
    Qt75         : 3.4
    Max          : 4.4
    IQR          : 0.6
    HiIQR        : 4.3
    LoIQR        : 1.9
    TukeysRange  : 0.9
    Confidence95 : 0
    Outlier      : 1
    OutlierHi    : 1
    OutlierLo    : 0

.EXAMPLE
    # Detect outliers
    Import-Csv -Path iris.csv `
        | Shorten-PropertyName `
        | Measure-Summary -Property "s_w", "p_l" `
        | Format-List

    Property : s_w
    Count    : 150
    Mean     : 3.05733333333333
    SD       : 0.435866284936699
    Min      : 2
    Qt25     : 2.8
    Median   : 3
    Qt75     : 3.4
    Max      : 4.4
    Outlier  : 1

    Property : p_l
    Count    : 150
    Mean     : 3.758
    SD       : 1.76529823325947
    Min      : 1
    Qt25     : 1.6
    Median   : 4.35
    Qt75     : 5.1
    Max      : 6.9
    Outlier  : 0

.EXAMPLE
    # Summary with Format-Table
    Import-Csv -Path iris.csv `
        | Shorten-PropertyName `
        | Measure-Summary -Property "s_w", "p_l" `
        | Format-Table

    Property  Count Mean   SD  Min Qt25 Median Qt75  Max Outlier
    --------  ----- ----   --  --- ---- ------ ----  --- -------
    s_w      150.00 3.06 0.44 2.00 2.80   3.00 3.40 4.40    1.00
    p_l      150.00 3.76 1.77 1.00 1.60   4.35 5.10 6.90    0.00


    # With Transpose-Property function
    Import-Csv -Path iris.csv `
        | Shorten-PropertyName `
        | Measure-Summary -Property "s_w", "p_l" `
        | Transpose-Property -Property "Property" `
        | Format-Table

    Property    s_w    p_l
    --------    ---    ---
    Count    150.00 150.00
    Mean       3.06   3.76
    SD         0.44   1.77
    Min        2.00   1.00
    Qt25       2.80   1.60
    Median     3.00   4.35
    Qt75       3.40   5.10
    Max        4.40   6.90
    Outlier    1.00   0.00

#>
function Measure-Summary {
    [CmdletBinding()]
    Param(
        [Parameter( Mandatory=$False )]
        [Alias('p')]
        [string[]] $Property
        ,
        [Parameter( Mandatory=$False )]
        [Alias('k')]
        [string[]] $Key
        ,
        [Parameter( Mandatory=$False )]
        [double] $OutlierMultiple = 1.5
        ,
        [Parameter( Mandatory=$False )]
        [switch] $Detail
        ,
        [Parameter( Mandatory=$False )]
        [switch] $ExcludeOutlier
        ,
        [Parameter( Mandatory=$False, ValueFromPipeline=$True )]
        [PSObject] $InputObject
    )
    # private function
    function isDouble {
        param(
            [parameter(Mandatory=$True, Position=0)]
            [string] $Token
        )
        $Token = $Token.Trim()
        $double = New-Object System.Double
        switch -Exact ( $Token.ToString() ) {
            {[Double]::TryParse( $Token.Replace('_',''), [ref] $double )} {
                return $True
            }
            default {
                return $False
            }
        }
    }
    # get all property names
    if ( $Property ){
        [String[]] $AllPropertyNames = $Property
    } else {
        [String[]] $AllPropertyNames = ($input[0].PSObject.Properties).Name
    }
    foreach ( $p in $AllPropertyNames ){
        if ( -not $Property ){
            # is double?
            if ( -not (isDouble $($input[1].$p)) ){
                continue
            }
        }
        #region Percentiles require sorted data
        if ( -not $Key ){
            $Data = $input `
                | Select-Object -Property $AllPropertyNames `
                | Where-Object { $_.$p -ne $Null -and $_.$p -ne 'NA' -and $_.$p -ne 'NaN' -and $_.$p -ne '' } `
                | Sort-Object -Property { [double]($_.$p) } -Stable
        } else {
            $Data = $input `
                | Select-Object -Property * `
                | Where-Object { $_.$p -ne $Null -and $_.$p -ne 'NA' -and $_.$p -ne 'NaN' -and $_.$p -ne '' } `
                | Sort-Object -Property { [double]($_.$p) } -Stable
        }
        #endregion

        #region Grab basic measurements from upstream Measure-Object
        if ( $Detail ){
            $Stats = $Data `
                | Measure-Object -Property $p -Minimum -Maximum -Sum -Average -StandardDeviation
        } else {
            $Stats = $Data `
                | Measure-Object -Property $p -Minimum -Maximum -Average -StandardDeviation
        }
        # convert psobject to hash
        $hash = [ordered] @{}
        foreach ($item in $Stats.psobject.properties){
            $hash[$item.Name] = $item.Value
        }
        #endregion

        # set key strings
        if ( $Key ){
            [string[]] $propKeyAry = @()
            foreach ($k in $Key){
                $propKeyAry += [string]($Data[0].$k)
            }
            [string] $propKeyStr = $propKeyAry -join ", "
            Write-Debug "Key: $propKeyStr"
            $hash["Key"] = $propKeyStr
        }
        
        #region Calculate median
        Write-Debug ('[{0}] Number of data items is <{1}>' -f $MyInvocation.MyCommand.Name, $Data.Count)
        if ($Data.Count % 2 -eq 0) {
            Write-Debug ('[{0}] Even number of data items' -f $MyInvocation.MyCommand.Name)

            $MedianIndex = ($Data.Count / 2) - 1
            Write-Debug ('[{0}] Index of Median is <{1}>' -f $MyInvocation.MyCommand.Name, $MedianIndex)
            
            $LowerMedian = $Data[$MedianIndex] | Select-Object -ExpandProperty $p
            $UpperMedian = $Data[$MedianIndex + 1] | Select-Object -ExpandProperty $p
            Write-Debug ('[{0}] Lower Median is <{1}> and upper Median is <{2}>' -f $MyInvocation.MyCommand.Name, $LowerMedian, $UpperMedian)
            
            $Median = ([double]$LowerMedian + [double]$UpperMedian) / 2
            Write-Debug ('[{0}] Average of lower and upper Median is <{1}>' -f $MyInvocation.MyCommand.Name, $Median)

        } else {
            Write-Debug ('[{0}] Odd number of data items' -f $MyInvocation.MyCommand.Name)

            $MedianIndex = [math]::Ceiling(($Data.Count - 1) / 2)
            Write-Debug ('[{0}] Index of Median is <{1}>' -f $MyInvocation.MyCommand.Name, $MedianIndex)

            $Median = $Data[$MedianIndex] | Select-Object -ExpandProperty $p
            Write-Debug ('[{0}] Median is <{1}>' -f $MyInvocation.MyCommand.Name, $Median)
        }
        $hash["Median"] = $Median
        #endregion

        #region Calculate variance
        #$Variance = 0
        #foreach ($_ in $Data) {
        #    $Variance += [math]::Pow( [double]($_.$p) - $Stats.Average, 2)
        #}
        #[double] $Variance /= $Stats.Count
        #endregion

        #region Calculate standard deviation
        #[double] $StandardDeviation = [math]::Sqrt($Variance)
        [double] $StandardDeviation = $Stats.StandardDeviation
        #endregion

        #region Calculate percentiles
        if ( $Stats.Count -eq 1 ){
            [int] $Percentile25Index = 0
            [int] $Percentile75Index = 0
        } elseif ( $Stats.Count -eq 2 ){
            [int] $Percentile25Index = 0
            [int] $Percentile75Index = 1
        } elseif ( $Stats.Count -eq 3 ){
            [int] $Percentile25Index = 1
            [int] $Percentile75Index = 1
        } elseif ( $Stats.Count -eq 4 ){
            [int] $Percentile25Index = 1
            [int] $Percentile75Index = 2
        } elseif ( $Stats.Count -eq 5 ){
            [int] $Percentile25Index = 1
            [int] $Percentile75Index = 3
        } elseif ( $Stats.Count -eq 6 ){
            [int] $Percentile25Index = 1
            [int] $Percentile75Index = 4
        } elseif ( $Stats.Count -eq 7 ){
            [int] $Percentile25Index = 1
            [int] $Percentile75Index = 5
        } elseif ( $Stats.Count -eq 8 ){
            [int] $Percentile25Index = 2
            [int] $Percentile75Index = 5
        } else {
            [int] $Percentile25Index = [math]::Ceiling(25 / 100 * $Data.Count)
            [int] $Percentile75Index = [math]::Ceiling(75 / 100 * $Data.Count)
        }
        $hash["Qt25"] = $([double]($Data[$Percentile25Index].$p))
        $hash["Qt75"] = $([double]($Data[$Percentile75Index].$p))
        [double] $IQR = $hash["Qt75"] - $hash["Qt25"]
        $hash["IQR"] = $IQR
        [double] $HiIQR = $hash["Qt75"] + $OutlierMultiple * $IQR
        $hash["HiIQR"] = $HiIQR
        [double] $LoIQR = $hash["Qt25"] - $OutlierMultiple * $IQR
        $hash["LoIQR"] = $LoIQR
        #endregion

        #region Calculate Tukey's range for outliers
        [double] $TukeysOutlier = $OutlierMultiple
        [double] $TukeysRange = $TukeysOutlier * ($hash["Qt75"] - $hash["Qt25"])
        $hash["TukeysRange"] = $TukeysRange
        #endregion

        #region Calculate confidence intervals
        $z = @{
            '90' = 1.645
            '95' = 1.96
            '98' = 2.326
            '99' = 2.576
        }
        [double] $Confidence95 = $z.95 * $Stats.StandardDeviation / [math]::Sqrt($Stats.Count)
        $hash["Confidence95"] = $Confidence95
        #endregion

        #region Detect outliers
        if ( -not  $ExcludeOutlier ){
            # Detect outlier
            [int] $countOutlier = 0
            [int] $countOutlierHi = 0
            [int] $countOutlierLo = 0
            foreach ($_ in $Data) {
                if ( [double]($_.$p) -gt $HiIQR){
                    $countOutlier++
                    $countOutlierHi++
                } elseif ( [double]($_.$p) -lt $LoIQR){
                    $countOutlier++
                    $countOutlierLo++
                } else {
                    # pass
                }
            }
            $hash["Outlier"]   = $countOutlier
            $hash["OutlierHi"] = $countOutlierHi
            $hash["OutlierLo"] = $countOutlierLo
        }
        #endregion

        #region Return measurements
        # convert hash to psobject
        if ( $Key ){
            if ( $Detail ){
                New-Object psobject -Property $hash `
                    | Select-Object -Property `
                        "Key", `
                        "Property", `
                        @{N="Count"      ;E={[double]($_."Count")}}, `
                        @{N="Sum"        ;E={[double]($_."Sum")}}, `
                        @{N="Mean"       ;E={[double]($_."Average")}}, `
                        @{N="SD"         ;E={[double]($_."StandardDeviation")}}, `
                        @{N="Min"        ;E={[double]($_."Minimum")}}, `
                        @{N="Qt25"       ;E={[double]($_."Qt25")}}, `
                        @{N="Median"     ;E={[double]($_."Median")}}, `
                        @{N="Qt75"       ;E={[double]($_."Max")}}, `
                        @{N="Max"        ;E={[double]($_."Maximum")}}, `
                        @{N="IQR"        ;E={[double]($_."IQR")}}, `
                        @{N="HiIQR"      ;E={[double]($_."HiIQR")}}, `
                        @{N="LoIQR"      ;E={[double]($_."LoIQR")}}, `
                        @{N="TukeysRange"  ;E={[double]($_."TukeysRange")}}, `
                        @{N="Confidence95" ;E={[double]($_."Confidence95")}}, `
                        @{N="Outlier"    ;E={[double]($_."Outlier")}}, `
                        @{N="OutlierHi"  ;E={[double]($_."OutlierHi")}}, `
                        @{N="OutlierLo"  ;E={[double]($_."OutlierLo")}}
            } else {
                New-Object psobject -Property $hash `
                    | Select-Object -Property `
                        "Key", `
                        "Property", `
                        @{N="Count"     ;E={[double]($_."Count")}}, `
                        @{N="Mean"      ;E={[double]($_."Average")}}, `
                        @{N="SD"        ;E={[double]($_."StandardDeviation")}}, `
                        @{N="Min"       ;E={[double]($_."Minimum")}}, `
                        @{N="Qt25"      ;E={[double]($_."Qt25")}}, `
                        @{N="Median"    ;E={[double]($_."Median")}}, `
                        @{N="Qt75"      ;E={[double]($_."Qt75")}}, `
                        @{N="Max"       ;E={[double]($_."Maximum")}}, `
                        @{N="Outlier"   ;E={[double]($_."Outlier")}}
            }
        } else {
            if ( $Detail ){
                New-Object psobject -Property $hash `
                    | Select-Object -Property `
                        "Property", `
                        @{N="Count"      ;E={[double]($_."Count")}}, `
                        @{N="Sum"        ;E={[double]($_."Sum")}}, `
                        @{N="Mean"       ;E={[double]($_."Average")}}, `
                        @{N="SD"         ;E={[double]($_."StandardDeviation")}}, `
                        @{N="Min"        ;E={[double]($_."Minimum")}}, `
                        @{N="Qt25"       ;E={[double]($_."Qt25")}}, `
                        @{N="Median"     ;E={[double]($_."Median")}}, `
                        @{N="Qt75"       ;E={[double]($_."Max")}}, `
                        @{N="Max"        ;E={[double]($_."Maximum")}}, `
                        @{N="IQR"        ;E={[double]($_."IQR")}}, `
                        @{N="HiIQR"      ;E={[double]($_."HiIQR")}}, `
                        @{N="LoIQR"      ;E={[double]($_."LoIQR")}}, `
                        @{N="TukeysRange"  ;E={[double]($_."TukeysRange")}}, `
                        @{N="Confidence95" ;E={[double]($_."Confidence95")}}, `
                        @{N="Outlier"    ;E={[double]($_."Outlier")}}, `
                        @{N="OutlierHi"  ;E={[double]($_."OutlierHi")}}, `
                        @{N="OutlierLo"  ;E={[double]($_."OutlierLo")}}
            } else {
                New-Object psobject -Property $hash `
                    | Select-Object -Property `
                        "Property", `
                        @{N="Count"     ;E={[double]($_."Count")}}, `
                        @{N="Mean"      ;E={[double]($_."Average")}}, `
                        @{N="SD"        ;E={[double]($_."StandardDeviation")}}, `
                        @{N="Min"       ;E={[double]($_."Minimum")}}, `
                        @{N="Qt25"      ;E={[double]($_."Qt25")}}, `
                        @{N="Median"    ;E={[double]($_."Median")}}, `
                        @{N="Qt75"      ;E={[double]($_."Qt75")}}, `
                        @{N="Max"       ;E={[double]($_."Maximum")}}, `
                        @{N="Outlier"   ;E={[double]($_."Outlier")}}
            }
        }
        #endregion
    }
}
# set alias
[String] $tmpAliasName = "msummary"
[String] $tmpCmdName   = "Measure-Summary"
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
