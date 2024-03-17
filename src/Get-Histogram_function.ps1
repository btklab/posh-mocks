<#
.SYNOPSIS
    Get-Histogram

        Original script:

            nicholasdille / PowerShell-Statistics / Get-Histogram.ps1
                https://github.com/nicholasdille/PowerShell-Statistics/tree/master

            Changes from the original:
            
                - Changed parameter names
                - Give an alias to options
                - Narrowed down the default output properties to:
                    - Index, lowerBound, upperBound, Count
                - Add -AllProperty (output) option
                - Add -Key option
                - Allow value from pipeline
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
    Add-Stats, Add-MovingWindow, Get-Histogram, Plot-BarChart

.EXAMPLE
    Get-Process `
        | select Name,Id,WorkingSet `
        | Get-Histogram -Value WorkingSet -BucketWidth 5mb -Minimum 0 -Maximum 50mb `
        | Plot-BarChart count -w 40 -m "|" `
        | ft

    Index  lowerBound  upperBound Count BarChart
    -----  ----------  ---------- ----- --------
        1        0.00  5242880.00    13 ||||||||
        2  5242880.00 10485760.00    64 ||||||||||||||||||||||||||||||||||||||||
        3 10485760.00 15728640.00    35 |||||||||||||||||||||
        4 15728640.00 20971520.00    22 |||||||||||||
        5 20971520.00 26214400.00    14 ||||||||
        6 26214400.00 31457280.00     5 |||
        7 31457280.00 36700160.00     5 |||
        8 36700160.00 41943040.00     5 |||
        9 41943040.00 47185920.00     3 |
       10 47185920.00 52428800.00     1 |

.EXAMPLE
    Import-Excel iris.xlsx `
        | Shorten-PropertyName `
        | Get-Histogram p_l -w 0.3 `
        | Plot-BarChart count -w 40 -m "|" `
        | ft

    Index lowerBound upperBound Count BarChart
    ----- ---------- ---------- ----- --------
        1       1.00       1.30    11 |||||||||||||
        2       1.30       1.60    33 ||||||||||||||||||||||||||||||||||||||||
        3       1.60       1.90     6 |||||||
        4       1.90       2.20     0 |
        5       2.20       2.50     0 |
        6       2.50       2.80     0 |
        7       2.80       3.10     1 |
        8       3.10       3.40     2 ||
        9       3.40       3.70     4 ||||
       10       3.70       4.00     9 ||||||||||
       11       4.00       4.30     9 ||||||||||
       12       4.30       4.60    15 ||||||||||||||||||
       13       4.60       4.90    14 ||||||||||||||||
       14       4.90       5.20    14 ||||||||||||||||
       15       5.20       5.50     7 ||||||||
       16       5.50       5.80    12 ||||||||||||||
       17       5.80       6.10     7 ||||||||
       18       6.10       6.40     2 ||
       19       6.40       6.70     3 |||
       20       6.70       7.00     1 |

.EXAMPLE
    # -Key <key> Get the Key property from the
    # first record and display it. Use Apply-Function to
    # aggregate by group in advance.

    Import-Excel iris.xlsx `
        | Shorten-PropertyName -v `
        | sort species -Stable `
        | Apply-Function species { `
            MovingWindow-Approach -v sl `
            | Get-Histogram rolling -BucketWidth .7 -Maximum 8 -Minimum 4 -Key species `
            | Plot-BarChart count -m "|" } `
        | ft

    species    Index lowerBound upperBound Count BarChart
    -------    ----- ---------- ---------- ----- --------
    setosa         1       4.00       4.70     1
    setosa         2       4.70       5.40    43 ||||||||||||||||||||
    setosa         3       5.40       6.10     2
    setosa         4       6.10       6.80     0
    setosa         5       6.80       7.50     0
    setosa         6       7.50       8.20     0
    versicolor     1       4.00       4.70     0
    versicolor     2       4.70       5.40     0
    versicolor     3       5.40       6.10    36 ||||||||||||||||||||
    versicolor     4       6.10       6.80    10 |||||
    versicolor     5       6.80       7.50     0
    versicolor     6       7.50       8.20     0
    virginica      1       4.00       4.70     0
    virginica      2       4.70       5.40     0
    virginica      3       5.40       6.10     0
    virginica      4       6.10       6.80    36 ||||||||||||||||||||
    virginica      5       6.80       7.50    10 |||||
    virginica      6       7.50       8.20     0

#>
function Get-Histogram {
    [CmdletBinding(DefaultParameterSetName='BucketCount')]
    Param(
        [Parameter(Mandatory=$True, Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('v')]
        [string] $Value
        ,
        [Parameter(Mandatory=$False)]
        [Alias('k')]
        [string] $Key
        ,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Alias('min')]
        [float] $Minimum
        ,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Alias('max')]
        [float] $Maximum
        ,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ $_ -ne 0 })]        
        [Alias('w')]
        [float] $BucketWidth = 1
        ,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Alias('c')]
        [float] $BucketCount
        ,
        [Parameter(Mandatory=$False)]
        [Alias('a')]
        [switch] $AllProperty
        ,
        [Parameter(Mandatory=$False)]
        [ValidateSet("int", "double", "decimal")]
        [string] $Cast = "double"
        ,
        [Parameter(Mandatory=$False, ValueFromPipeline=$True )]
        [ValidateNotNullOrEmpty()]
        [array] $InputObject
    )
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
    Write-Verbose ('[{0}] Building histogram' -f $MyInvocation.MyCommand)
    Write-Debug ('[{0}] Retrieving measurements from upstream cmdlet for {1} values' -f $MyInvocation.MyCommand, $input.Count)
    Write-Progress -Activity 'Measuring data'
    $Stats = $input | Measure-Object -Minimum -Maximum -Property $Value
    [int] $inputCount = $Stats.Count
    if ( $inputCount -eq 0 ){
        # test input count
        Write-Error "InputCount = 0 detected. Attempted to divide by zero." -ErrorAction Stop
    }
    if (-Not $PSBoundParameters.ContainsKey('Minimum')) {
        $Minimum = $Stats.Minimum
        Write-Debug ('[{0}] Minimum value not specified. Using smallest value ({1}) from input data.' -f $MyInvocation.MyCommand, $Minimum)
    }
    if (-Not $PSBoundParameters.ContainsKey('Maximum')) {
        $Maximum = $Stats.Maximum
        Write-Debug ('[{0}] Maximum value not specified. Using largest value ({1}) from input data.' -f $MyInvocation.MyCommand, $Maximum)
    }
    if (-Not $PSBoundParameters.ContainsKey('BucketCount')) {
        $BucketCount = [math]::Ceiling(($Maximum - $Minimum) / $BucketWidth)
        Write-Debug ('[{0}] Bucket count not specified. Calculated {1} buckets from width of {2}.' -f $MyInvocation.MyCommand, $BucketCount, $BucketWidth)
    }
    if ($BucketCount -gt 100) {
        Write-Warning ('[{0}] Generating {1} buckets' -f $MyInvocation.MyCommand, $BucketCount)
    }
    Write-Debug ('[{0}] Building buckets using: Minimum=<{1}> Maximum=<{2}> BucketWidth=<{3}> BucketCount=<{4}>' -f $MyInvocation.MyCommand, $Minimum, $Maximum, $BucketWidth, $BucketCount)
    Write-Progress -Activity 'Creating buckets'
    $OverallCount = 0
    $Buckets = 1..$BucketCount | ForEach-Object {
        if ( $AllProperty ){
            [pscustomobject]@{
                Index          = $_
                lower_bound    = $Minimum + ($_ - 1) * $BucketWidth
                upper_bound    = $Minimum +  $_      * $BucketWidth
                Count          = 0
                Relative_Count = 0
                Group          = New-Object -TypeName System.Collections.ArrayList
                PSTypeName     = 'HistogramBucket'
            }
        } elseif ( $Key ) {
            [pscustomobject]@{
                $Key          = ''
                Index         = $_
                lower_bound   = $Minimum + ($_ - 1) * $BucketWidth
                upper_bound   = $Minimum +  $_      * $BucketWidth
                Count         = 0
                Group         = New-Object -TypeName System.Collections.ArrayList
                PSTypeName    = 'HistogramBucket'
            }
        } else {
            [pscustomobject]@{
                Index         = $_
                lower_bound   = $Minimum + ($_ - 1) * $BucketWidth
                upper_bound   = $Minimum +  $_      * $BucketWidth
                Count         = 0
                Group         = New-Object -TypeName System.Collections.ArrayList
                PSTypeName    = 'HistogramBucket'
            }
        }
    }
    Write-Debug ('[{0}] Building histogram' -f $MyInvocation.MyCommand)
    $DataIndex = 1
    foreach ($_ in $input) {
        if ( [string]($_.$Value) -match '^NA$' ){
            Write-Error "Drop 'NA/NaN' in advance." -ErrorAction Stop
        }
        if ( [string]($_.$Value) -match '^NaN$' ){
            Write-Error "Drop 'NA/NaN' in advance." -ErrorAction Stop
        }
        #if ( [string]($_.$Value) -match '^\s*$' ){
        if ( [string]($_.$Value).Trim() -eq '' ){
            Write-Error "The input string '' was not in a correct format." -ErrorAction Stop
        }
        try {
            if ( $Cast -eq 'double' ){
                $val = [double]( $_.$Value )
            } elseif ( $Cast -eq 'decimal' ){
                $val = [decimal]( $_.$Value )
            } elseif ( $Cast -eq 'int' ){
                $val = [int]( $_.$Value )
            } else {
                $val = [double]( $_.$Value )
            }
        } catch {
            Write-Error $Error[0] -ErrorAction Stop
        }
        Write-Progress -Activity 'Filling buckets' -PercentComplete ($DataIndex / $inputCount * 100)
        
        if ($val -ge $Minimum -and $val -le $Maximum) {
            $BucketIndex = [math]::Floor(($val - $Minimum) / $BucketWidth)
            if ($BucketIndex -lt $Buckets.Length) {
                $Buckets[$BucketIndex].Count += 1
                [void]$Buckets[$BucketIndex].Group.Add($_)
                $OverallCount += 1
            }
        }
        ++$DataIndex
    }
    if ( $AllProperty) {
        Write-Debug ('[{0}] Adding relative count' -f $MyInvocation.MyCommand)
        foreach ($_ in $Buckets) {
            $_.RelativeCount = if ($OverallCount -gt 0) { $_.Count / $OverallCount } else { 0 }
        }
        Write-Debug ('[{0}] Returning histogram' -f $MyInvocation.MyCommand)
        $Buckets
    } elseif ( $Key ) {
        # Get key from first record
        [string[]] $keyAry = @()
        foreach ( $k in $Key ){
            [string] $keyStr = "-"
            [string] $tmpKeyStr = ''
            for ($i=0; $i -lt $Buckets.Count; $i++){
                [string] $tmpKeyStr = $($Buckets[$i].Group[$i].$Key)
                if ( $tmpKeyStr -ne ''){
                    $keyStr = $tmpKeyStr
                    Write-Debug "for-loop break count: $i"
                    break
                }
            }
        }
        foreach ($_ in $Buckets) {
            $_.$Key = $keyStr
        }
        Write-Debug ('[{0}] Returning histogram' -f $MyInvocation.MyCommand)
        [string[]] $pAry = @()
        $pAry += $Key
        $pAry += "Index"
        $pAry += "lower_bound"
        $pAry += "upper_bound"
        $pAry += "Count"
        $Buckets | Select-Object -Property $pAry
    } else {
        [string[]] $pAry = @()
        $pAry += "Index"
        $pAry += "lower_bound"
        $pAry += "upper_bound"
        $pAry += "Count"
        Write-Debug ('[{0}] Returning histogram' -f $MyInvocation.MyCommand)
        $Buckets | Select-Object -Property $pAry
    }
}
