function Get-DateAlternative {
    <#
    .SYNOPSIS
        Get-DateAlternative - Add year to month/day input. To prevent mistyping the number of year.

            Get-DateAlternative 1/23
            2023-01-23
            # Result of execution on a certain day in **2023**.

        Output to both clipboard and stdout by default.
        with -stdout switch, output only to stdout.

    .EXAMPLE
        # Result of execution on a certain day in **2023**.

        Get-DateAlternative 1/23
        2023-01-23
        

    .EXAMPLE
        # Result of execution on a certain day in **2023**.

        thisyear 2/28 -s "_this_year"
        2023-02-28_this_year

        nextyear 2/29 -s "_next_year"
        2024-02-29_next_year

        lastyear 2/28 -s "_last_year"
        2022-02-28_last_year

        Get-DateAlternative 2/28 -s "_gdate"
        2023-02-28_gdate

    .LINK
        thisyear, lastyear, nextyear, Get-DateAlternative

    .NOTES
        Get-Date (Microsoft.PowerShell.Utility)
        https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-date

    #>
    param (
        [parameter(Mandatory=$False, Position=0, ValueFromPipeline=$True)]
        [Alias('d')]
        [string[]] $Date = @($((Get-Date).ToString('M/d'))),
        
        [Parameter(Mandatory=$False)]
        [ValidateSet('clipboard', 'stdout')]
        [Alias('r')]
        [string] $RedirectTo = 'clipboard',
        
        [Parameter(Mandatory=$False)]
        [Alias('p')]
        [string] $Prefix = '',
        
        [Parameter(Mandatory=$False)]
        [Alias('s')]
        [string] $Suffix = '',
        
        [Parameter(Mandatory=$False)]
        [Alias('f')]
        [string] $Format,
        
        [Parameter(Mandatory=$False)]
        [Alias('jp')]
        [switch] $FormatJP,
        
        [Parameter(Mandatory=$False)]
        [Alias('jz')]
        [switch] $FormatJPZeroPadding,
        
        [Parameter(Mandatory=$False)]
        [switch] $Slash,
        
        [Parameter(Mandatory=$False)]
        [Alias('h')]
        [switch] $GetDateTimeFormat,
        
        [Parameter(Mandatory=$False)]
        [switch] $Year2,
        
        [Parameter(Mandatory=$False)]
        [int] $BaseYear = 0,
        
        [Parameter(Mandatory=$False)]
        [Alias('w')]
        [switch] $DayOfWeek,
        
        [Parameter(Mandatory=$False)]
        [Alias('wr')]
        [switch] $DayOfWeekWithRound,
        
        [Parameter(Mandatory=$False)]
        [int] $AddDays,
        
        [Parameter(Mandatory=$False)]
        [int] $AddMonths,
        
        [Parameter(Mandatory=$False)]
        [int] $AddYears,
        
        [Parameter(Mandatory=$False)]
        [ValidateScript({[int]($_) -gt 0})]
        [int] $Duplicate,
        
        [Parameter(Mandatory=$False)]
        [Alias('n')]
        [switch] $NoSeparator,
        
        [Parameter(Mandatory=$False)]
        [Alias('eom')]
        [switch] $EndOfMonth
    )
    if ( $GetDateTimeFormat ){
        (Get-Culture).DateTimeFormat
        return
    }
    # set format strings
    if ( $Year2 ){
        [string] $fmtYear  = 'yy'
    } else {
        [string] $fmtYear  = 'yyyy'
    }
    [string] $fmtMonth = 'MM'
    [string] $fmtDay   = 'dd'
    if ( $Format ){
        # manual formatting
        [string] $fmt = $Format
    } elseif ( $FormatJPZeroPadding ){
        # japanese datetime format
        [string] $fmt = 'yyyy年MM月dd日'
    } elseif ( $FormatJP ){
        # japanese datetime format
        [string] $fmt = 'yyyy年M月d日'
    } elseif ( $NoSeparator ){
        # 6-8 digits format
        [string] $fmt = @($fmtYear, $fmtMonth, $fmtDay) -join ""
    } else {
        # set date separator
        if ( $Slash ){
            [string] $dateSeparator = "/"
        } else {
            [string] $dateSeparator = "-"
        }
        [string] $fmt = @($fmtYear, $fmtMonth, $fmtDay) -join $dateSeparator
    }
    if ( $DayOfWeek ){
        $fmt += " ddd"  
    }
    if ( $DayOfWeekWithRound ){
        $fmt += " (ddd)"  
    }
    Write-Debug "dateformat: ""$fmt"""
    #
    # main
    #
    if ( ($input.Count -eq 0) -and (-not $Date) ){
        Write-Error "Please set -Date." -ErrorAction Stop
    } elseif ( $input.Count -eq 0 ){
        [string[]] $dateAry = @($Date)
    } else {
        # read from stdin
        [string[]] $dateAry = $input
    }
    [string[]] $outputAry = foreach ($d in $dateAry){
        # test option
        if ( $d -match '\-' ){
            [int[]] $splitDate = $d -split "-"
        } else {
            [int[]] $splitDate = $d -split "/"
        }
        [int] $iMonth = $splitDate[0]
        [int] $iDay   = $splitDate[1]
        if ( $splitDate.Count -ne 2 ) {
            Write-Error "Invalid date. set month and date like ""1/23"" or ""1-23""" -ErrorAction Stop
        }
        if ( $iMonth -eq 0 -or $iDay -eq 0 ) {
            Write-Error "Invalid date. set month and date like ""1/23"" or ""1-23""" -ErrorAction Stop
        }
        # set ymd
        ## set base year (default = thisyear)
        [int] $iYear = (Get-Date).AddYears($BaseYear).Year
        if ( $AddYears ){
            [datetime] $tmpDate = (Get-Date "$iYear/$iMonth/$iDay").AddYears($AddYears)
            [int] $iYear  = $tmpDate.Year
            [int] $iMonth = $tmpDate.Month
            [int] $iDay   = $tmpDate.Day
        }
        if ( $AddMonths ){
            [datetime] $tmpDate = (Get-Date "$iYear/$iMonth/$iDay").AddMonths($AddMonths)
            [int] $iYear  = $tmpDate.Year
            [int] $iMonth = $tmpDate.Month
            [int] $iDay   = $tmpDate.Day
        }
        if ( $AddDays ){
            [datetime] $tmpDate = (Get-Date "$iYear/$iMonth/$iDay").AddDays($AddDays)
            [int] $iYear  = $tmpDate.Year
            [int] $iMonth = $tmpDate.Month
            [int] $iDay   = $tmpDate.Day
        }
        if ( $EndOfMonth ){
            [int] $iDay = 1
        }
        # test date
        try {
            Get-Date -Date "$iYear/$iMonth/$iDay" > $Null
        } catch {
            Write-Error "Error: ""$iYear/$iMonth/$iDay"" was not recognized as a valid DateTime." -ErrorAction Stop
        }
        # parse date
        $splatting = @{
            Year   = $iYear
            Month  = $iMonth
            Day    = $iDay
        }
        if ( $EndOfMonth ){
            [string] $oDateStr = (Get-Date @splatting).AddMonths(1).AddDays(-1).ToString($fmt)
        } else {
            [string] $oDateStr = Get-Date @splatting -Format $fmt
        }
        $oDateStr = $Prefix + $oDateStr + $Suffix
        if ( $Duplicate ){
            # duplicate outputs per record
            1..$Duplicate | ForEach-Object {
                Write-Output $oDateStr
            }
        } else {
            Write-Output $oDateStr
        }
    }
    # redirect to...
    if ( $RedirectTo -eq 'clipboard' ){
       $outputAry | Set-Clipboard
       $outputAry
    } else {
       $outputAry
    }
}


function thisyear {
    <#
    .SYNOPSIS
        thisyear - Add current year to month/day input. To prevent mistyping the number of year.

            thisyear 1/23
            2023/1/23
            # Result of execution on a certain day in **2023**.

        Output to both clipboard and stdout by default.
        with -stdout switch, output only to stdout.

    .EXAMPLE
        # Result of execution on a certain day in **2023**.

        thisyear 1/23
        2023/1/23


    .EXAMPLE
        # Result of execution on a certain day in **2023**.

        thisyear 2/28 -s "_this_year"
        2023-02-28_this_year

        nextyear 2/29 -s "_next_year"
        2024-02-29_next_year

        lastyear 2/28 -s "_last_year"
        2022-02-28_last_year

        Get-DateAlternative 2/28 -s "_gdate"
        2023-02-28_gdate

    .LINK
        thisyear, lastyear, nextyear, Get-DateAlternative

    .NOTES
        Get-Date (Microsoft.PowerShell.Utility)
        https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-date

    #>
    param (
        [parameter(Mandatory=$False, Position=0, ValueFromPipeline=$True)]
        [Alias('d')]
        [string[]] $Date = @($((Get-Date).ToString('M/d'))),
        
        [Parameter(Mandatory=$False)]
        [ValidateSet('clipboard', 'stdout')]
        [Alias('r')]
        [string] $RedirectTo = 'clipboard',
        
        [Parameter(Mandatory=$False)]
        [Alias('p')]
        [string] $Prefix = '',
        
        [Parameter(Mandatory=$False)]
        [Alias('s')]
        [string] $Suffix = '',
        
        [Parameter(Mandatory=$False)]
        [Alias('f')]
        [string] $Format,
        
        [Parameter(Mandatory=$False)]
        [Alias('jp')]
        [switch] $FormatJP,
        
        [Parameter(Mandatory=$False)]
        [Alias('jz')]
        [switch] $FormatJPZeroPadding,
        
        [Parameter(Mandatory=$False)]
        [switch] $Slash,
        
        [Parameter(Mandatory=$False)]
        [Alias('h')]
        [switch] $GetDateTimeFormat,
        
        [Parameter(Mandatory=$False)]
        [switch] $Year2,
        
        [Parameter(Mandatory=$False)]
        [int] $BaseYear = 0,
        
        [Parameter(Mandatory=$False)]
        [Alias('w')]
        [switch] $DayOfWeek,
        
        [Parameter(Mandatory=$False)]
        [Alias('wr')]
        [switch] $DayOfWeekWithRound,
        
        [Parameter(Mandatory=$False)]
        [int] $AddDays,
        
        [Parameter(Mandatory=$False)]
        [int] $AddMonths,
        
        [Parameter(Mandatory=$False)]
        [int] $AddYears,
        
        [Parameter(Mandatory=$False)]
        [ValidateScript({[int]($_) -gt 0})]
        [int] $Duplicate,
        
        [Parameter(Mandatory=$False)]
        [Alias('n')]
        [switch] $NoSeparator,
        
        [Parameter(Mandatory=$False)]
        [Alias('eom')]
        [switch] $EndOfMonth
    )
    # main
    $splatting = @{
        RedirectTo = $RedirectTo
        Prefix = $Prefix
        Suffix = $Suffix
        FormatJP = $FormatJP
        FormatJPZeroPadding = $FormatJPZeroPadding
        Slash = $Slash
        GetDateTimeFormat = $GetDateTimeFormat
        Year2 = $Year2
        BaseYear = $BaseYear
        DayOfWeek = $DayOfWeek
        DayOfWeekWithRound = $DayOfWeekWithRound
        NoSeparator = $NoSeparator
        EndOfMonth = $EndOfMonth
    }
    if ( $Format    ) { $splatting.Set_Item("Format", $Format) }
    if ( $AddDays   ) { $splatting.Set_Item("AddDays", $AddDays) }
    if ( $AddMonths ) { $splatting.Set_Item("AddMonths", $AddMonths) }
    if ( $AddYears  ) { $splatting.Set_Item("AddYears", $AddYears) }
    if ( $Duplicate ) { $splatting.Set_Item("Duplicate", $Duplicate) }
    if ( ($input.Count -eq 0) -and (-not $Date) ){
        Write-Error "Please set -Date." -ErrorAction Stop
    } elseif ( $input.Count -eq 0 ){
        $splatting.Set_Item('Date', @($Date))
    } else {
        # read from stdin
        $splatting.Set_Item('Date', $input)
    }
    Get-DateAlternative @splatting
}


function nextyear {
    <#
    .SYNOPSIS
        nextyear - Add next year to month/day input. To prevent mistyping the number of year.

            nextyear 1/23
            2024-01-23
            # Result of execution on a certain day in **2023**.

        Output to both clipboard and stdout by default.
        with -stdout switch, output only to stdout.

    .EXAMPLE
        # Result of execution on a certain day in **2023**.

        nextyear 1/23
        2024-01-23

    .EXAMPLE
        # Result of execution on a certain day in **2023**.

        thisyear 2/28 -s "_this_year"
        2023-02-28_this_year

        nextyear 2/29 -s "_next_year"
        2024-02-29_next_year

        lastyear 2/28 -s "_last_year"
        2022-02-28_last_year

        Get-DateAlternative 2/28 -s "_gdate"
        2023-02-28_gdate

    .LINK
        thisyear, lastyear, nextyear, Get-DateAlternative

    .NOTES
        Get-Date (Microsoft.PowerShell.Utility)
        https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-date

    #>
    param (
        [parameter(Mandatory=$False, Position=0, ValueFromPipeline=$True)]
        [Alias('d')]
        [string[]] $Date = @($((Get-Date).ToString('M/d'))),
        
        [Parameter(Mandatory=$False)]
        [ValidateSet('clipboard', 'stdout')]
        [Alias('r')]
        [string] $RedirectTo = 'clipboard',
        
        [Parameter(Mandatory=$False)]
        [Alias('p')]
        [string] $Prefix = '',
        
        [Parameter(Mandatory=$False)]
        [Alias('s')]
        [string] $Suffix = '',
        
        [Parameter(Mandatory=$False)]
        [Alias('f')]
        [string] $Format,
        
        [Parameter(Mandatory=$False)]
        [Alias('jp')]
        [switch] $FormatJP,
        
        [Parameter(Mandatory=$False)]
        [Alias('jz')]
        [switch] $FormatJPZeroPadding,
        
        [Parameter(Mandatory=$False)]
        [switch] $Slash,
        
        [Parameter(Mandatory=$False)]
        [Alias('h')]
        [switch] $GetDateTimeFormat,
        
        [Parameter(Mandatory=$False)]
        [switch] $Year2,
        
        [Parameter(Mandatory=$False)]
        [int] $BaseYear = 1,
        
        [Parameter(Mandatory=$False)]
        [Alias('w')]
        [switch] $DayOfWeek,
        
        [Parameter(Mandatory=$False)]
        [Alias('wr')]
        [switch] $DayOfWeekWithRound,
        
        [Parameter(Mandatory=$False)]
        [int] $AddDays,
        
        [Parameter(Mandatory=$False)]
        [int] $AddMonths,
        
        [Parameter(Mandatory=$False)]
        [int] $AddYears,
        
        [Parameter(Mandatory=$False)]
        [ValidateScript({[int]($_) -gt 0})]
        [int] $Duplicate,
        
        [Parameter(Mandatory=$False)]
        [Alias('n')]
        [switch] $NoSeparator,
        
        [Parameter(Mandatory=$False)]
        [Alias('eom')]
        [switch] $EndOfMonth
    )
    # main
    $splatting = @{
        RedirectTo = $RedirectTo
        Prefix = $Prefix
        Suffix = $Suffix
        FormatJP = $FormatJP
        FormatJPZeroPadding = $FormatJPZeroPadding
        Slash = $Slash
        GetDateTimeFormat = $GetDateTimeFormat
        Year2 = $Year2
        BaseYear = $BaseYear
        DayOfWeek = $DayOfWeek
        DayOfWeekWithRound = $DayOfWeekWithRound
        NoSeparator = $NoSeparator
        EndOfMonth = $EndOfMonth
    }
    if ( $Format    ) { $splatting.Set_Item("Format", $Format) }
    if ( $AddDays   ) { $splatting.Set_Item("AddDays", $AddDays) }
    if ( $AddMonths ) { $splatting.Set_Item("AddMonths", $AddMonths) }
    if ( $AddYears  ) { $splatting.Set_Item("AddYears", $AddYears) }
    if ( $Duplicate ) { $splatting.Set_Item("Duplicate", $Duplicate) }
    if ( ($input.Count -eq 0) -and (-not $Date) ){
        Write-Error "Please set -Date." -ErrorAction Stop
    } elseif ( $input.Count -eq 0 ){
        $splatting.Set_Item('Date', @($Date))
    } else {
        # read from stdin
        $splatting.Set_Item('Date', $input)
    }
    Get-DateAlternative @splatting
}


function lastyear {
    <#
    .SYNOPSIS
        lastyear - Add last year to month/day input. To prevent mistyping the number of year.

            lastyear 1/23
            2022-01-23
            # Result of execution on a certain day in **2023**.

        Output to both clipboard and stdout by default.
        with -stdout switch, output only to stdout.

    .EXAMPLE
        # Result of execution on a certain day in **2023**.

        lastyear 1/23
        2022-01-23

    .EXAMPLE
        # Result of execution on a certain day in **2023**.

        thisyear 2/28 -s "_this_year"
        2023-02-28_this_year

        nextyear 2/29 -s "_next_year"
        2024-02-29_next_year

        lastyear 2/28 -s "_last_year"
        2022-02-28_last_year

        Get-DateAlternative 2/28 -s "_gdate"
        2023-02-28_gdate

    .LINK
        thisyear, lastyear, nextyear, Get-DateAlternative

    .NOTES
        Get-Date (Microsoft.PowerShell.Utility)
        https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-date

    #>
    param (
        [parameter(Mandatory=$False, Position=0, ValueFromPipeline=$True)]
        [Alias('d')]
        [string[]] $Date = @($((Get-Date).ToString('M/d'))),
        
        [Parameter(Mandatory=$False)]
        [ValidateSet('clipboard', 'stdout')]
        [Alias('r')]
        [string] $RedirectTo = 'clipboard',
        
        [Parameter(Mandatory=$False)]
        [Alias('p')]
        [string] $Prefix = '',
        
        [Parameter(Mandatory=$False)]
        [Alias('s')]
        [string] $Suffix = '',
        
        [Parameter(Mandatory=$False)]
        [Alias('f')]
        [string] $Format,
        
        [Parameter(Mandatory=$False)]
        [Alias('jp')]
        [switch] $FormatJP,
        
        [Parameter(Mandatory=$False)]
        [Alias('jz')]
        [switch] $FormatJPZeroPadding,
        
        [Parameter(Mandatory=$False)]
        [switch] $Slash,
        
        [Parameter(Mandatory=$False)]
        [Alias('h')]
        [switch] $GetDateTimeFormat,
        
        [Parameter(Mandatory=$False)]
        [switch] $Year2,
        
        [Parameter(Mandatory=$False)]
        [int] $BaseYear = -1,
        
        [Parameter(Mandatory=$False)]
        [Alias('w')]
        [switch] $DayOfWeek,
        
        [Parameter(Mandatory=$False)]
        [Alias('wr')]
        [switch] $DayOfWeekWithRound,
        
        [Parameter(Mandatory=$False)]
        [int] $AddDays,
        
        [Parameter(Mandatory=$False)]
        [int] $AddMonths,
        
        [Parameter(Mandatory=$False)]
        [int] $AddYears,
        
        [Parameter(Mandatory=$False)]
        [ValidateScript({[int]($_) -gt 0})]
        [int] $Duplicate,
        
        [Parameter(Mandatory=$False)]
        [Alias('n')]
        [switch] $NoSeparator,
        
        [Parameter(Mandatory=$False)]
        [Alias('eom')]
        [switch] $EndOfMonth
    )
    # main
    $splatting = @{
        RedirectTo = $RedirectTo
        Prefix = $Prefix
        Suffix = $Suffix
        FormatJP = $FormatJP
        FormatJPZeroPadding = $FormatJPZeroPadding
        Slash = $Slash
        GetDateTimeFormat = $GetDateTimeFormat
        Year2 = $Year2
        BaseYear = $BaseYear
        DayOfWeek = $DayOfWeek
        DayOfWeekWithRound = $DayOfWeekWithRound
        NoSeparator = $NoSeparator
        EndOfMonth = $EndOfMonth
    }
    if ( $Format    ) { $splatting.Set_Item("Format", $Format) }
    if ( $AddDays   ) { $splatting.Set_Item("AddDays", $AddDays) }
    if ( $AddMonths ) { $splatting.Set_Item("AddMonths", $AddMonths) }
    if ( $AddYears  ) { $splatting.Set_Item("AddYears", $AddYears) }
    if ( $Duplicate ) { $splatting.Set_Item("Duplicate", $Duplicate) }
    if ( ($input.Count -eq 0) -and (-not $Date) ){
        Write-Error "Please set -Date." -ErrorAction Stop
    } elseif ( $input.Count -eq 0 ){
        $splatting.Set_Item('Date', @($Date))
    } else {
        # read from stdin
        $splatting.Set_Item('Date', $input)
    }
    Get-DateAlternative @splatting
}
