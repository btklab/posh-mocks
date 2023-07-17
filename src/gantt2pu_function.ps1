<#
.SYNOPSIS
    gantt2pu - Visualizatoin of DANDORI-chart (setup-chart) for PlantUML.

    Calculate the task time backward from the GOAL (deadline) and
    draw a gantt-chart to find the start date.

    Reasons for working backwards from the goal to tasks and
    task times instead of piling up tasks to reach the goal:

        1. To eliminate omissions of tasks.
        2. To delay as much as possible the start date.
           Otherwise, all tasks are "start as soon as possible".
    
    Usage:
        cat a.txt | gantt2pu > a.pu; pu2java a.pu svg
    
    Input:
        # title

        ## project name [2023-03-01]
        < task3-review [4]
        << task3-2 [4]
        << task3-1 [4]
        < task2-review [5]
        << task2-2 [5]
        << task2-1 [5]
        ### sub milestone
        < task1-review [5]
        ### task1 fin
        < task1-2 [4]
        << task1-2-1 [4]
        < task1-1 [4]
    
    Format:
        - "m", "##" is a milestone. Specify with date as below.
            - "m MileStoneName [yyyy-m-d]" or
            - "## MileStoneName [yyyy-m-d]"
        - ">" indicates task to be done after the milestone. Specify with task time as below.
            - "> task name [1]"
        - "<" indicates task to be done before the milestone. Specify with task time as below.
            - "< task name [1]"
        - ">>" is task to do after the previous task or milestone. Specify with task time as below.
            - ">> task name [1]"
        - "<<" is task to do before the previous task or milestone. Specify with task time as below.
            - "<< task name [1]"
        - "mm", "###" puts the milestone on the start date or finish date of the previous task.
            - Unlike "m" and "##", no date specification is required.
            - "mm" is cleard every milestone, but it is not cleared with
              "-InheritTasks" switch, and all loaded tasks are memorized.
            - However, in the "<" direction, regardless of whether "-InheritTasks" switch is
              ON or OFF, the milestone is always placed at the "start position of the previous task".
        - "*" is an achievement or indicator that does not depend on tasks or
          milestones. Specify start and end datas.
            - "* indicator [2022-07-10,today] (60%)"
            - Color specification format: '-ColorResult "black/black"'
        - misc
            - Lines beginning with "//" are considered comment.
            - Strings after "--" are treated as comments and ignored.
                - Adding "--active", "--done" at the end of task make it easier
                  to visualize the progress.
            - Lines beginning with ".Tag" are treated as tags and ignored.
            - With "AsMilestone" switch, the output is:
                - [milestone] as [M1] happens 2022-01-01
            - With "SectionLv2" switch, the output is:
                - Use the 2nd level heading "## section" as a project separator,
                - The 3rd level heding "### milestone [yyyy-m-d]" as milestones,
                - The 4th level heading "#### sub-milestone" as sub-milestone
            - Add <link> to task name to set hyperlink:
                - task1 <https://plantuml.com/ja/gantt-diagram> [2]
                - task2 <https://plantuml.com/ja/gantt-diagram> [2]

        
    Recommended Usage:
        Set milestones as goal and task backward from there
        to build a plan, and find a start date for each tasks.
        
            m Milestone1 [yyyy-mm-dd]
            < task2 [5] --active
            << task2-1 [3] --active
            < task1 [3]
            << task1-2 [4]
            << task1-3 [10]

    More input examples:
        Milestones can also be project start date.
            m Milestone1 [2022-01-01]
            > task1 [5] --active
            >> task1-1 [3] --active
            > task2 [3]
            >> task2-2 [4]
            >> task2-3 [10]
    
    Note:
        - Duplicate task names are allowed. However,
          add spaces to the end of the task name each
          time it ovarlaps.
        - Brackets are not allowed in task names.
        - How to connect tasks:
            - Chained in series:
                - "> task1 [1]"
                - ">> task2 [1]"
                - ">> task3 [1]"
            - Parallel connection:
                - "> task1 [1]"
                - "> task2 [1]"
                - "> task3 [1]"
            - Preparatory task "<<" is written before ">>"
                - "> task1 [1]"
                - "<< prep-task1 [1]"
                - ">> task2 [1]"
                - ">> task3 [1]"
        - If the task name ends with {Name,Name,...} it
          will be regarded as a resources (details will
          be described later)
            - "> task {Name1} [5]"
            - This feature can be turned off with the "-OffResource" switch
        - "> task [1] (40%)" interpreted as the progress rate:
            - "> task1 {hoge,fuga} [1] (40%)"
            - ">> task2 {hoge:20%} [1] (100%)"
            - ">> task3 {fuga} [1] (50%)"
        - To place the milestone first, both the date specification
          of the milestone date and the "-StartDate <date>" option
          required.
            - "m StartMileStone 2020-02-01"
            - "> task1 [1]"
            - "> task2 [1]"
        - All lines and blank lines that start with anything other
          than "m", "mm", "<", "<<", ">>", ">", "#" are output as-is.
          So you can use PlantUML format. for exaple:
        
            -- 1st step --
            > task1 [1]
            >> task2 [1]
            >> task3 [1]
            -- 2nd step --
            >> task4 [1]
            >> task5 [1]
            note bottom
              this is note.
            end note
            >> task6 [1]
            >> task7 [1]
            >> task8 [1]
            >> task9 [1]
            legend right
              this is legend.
            end legend

        - If task time is "[2,3]", it is interpreted as
          "[task-time, delay-time]"
            - The direction of the delay time (future or past)
              is automatically determind by the direction of
              "<" and ">".

            m MileStone [yyyy-m-d]
            > task1 [2,3] <- Start 3 days after the milestone date
            < task2 [2,3] <- End 3 days before the milestone date
    
    Hint:
        A hint is to set milestones first, then
        Put tasks to be done before/after the milestone

    Reference:
        - https://plantuml.com/ja/gantt-diagram
        - https://www.navigate-inc.co.jp/manual/tips/51_1805.html

.LINK
    pu2java, dot2gviz, pert, pert2dot, pert2gantt2pu, mind2dot, mind2pu, gantt2pu, logi2dot, logi2dot2, logi2dot3, logi2pu, logi2pu2, flow2pu, seq2pu


.PARAMETER StartDate
    Porject start date
    (= chart start range)

.PARAMETER SectionLv2
    Use the 2nd level heading "## section" as a project separator,
    The 3rd level heding "### milestone [yyyy-m-d]" as milestones,
    The 4th level heading "#### sub-milestone" as sub-milestone

    Default:
    Use the 2nd level heading "## section [yyy-m-d]" as a milestone,
    The 3rd level heding "### milestone" as sub-milestone.

    Can be used with "-AsMilestone" switch.

.PARAMETER AsMilestone
    Interpret "## milestone [yyyy-mm-dd]" as
    "m milestone [yyyy-mm-dd]"

    Default:
    -- milestone [yyyy-mm-dd] --
    m fin [yyyy-mm-dd]

    Can be used with "-MarkdownLevel2AsSeparator" switch.

.PARAMETER Unit
    The unit of the duration date
    choice: days, weeks
    default: days

.PARAMETER Period
    Change display period.

        daily (default)
        weekly
        monthly
        quarterly
        yearly

.PARAMETER TaskbarColor
    e.g. Tomato/Brown


.PARAMETER NamedDates
    Name the calendar date.
    format: <start-date>,<end-date>,<name>

    e.g.
    -NamedDates 2022-07-15,2022-07-20,"Audit"

.PARAMETER CloseSatSun
    Closed on Saturdays and Sundays

.PARAMETER CloseDates
    Specify close days separated by commas.
    Consecutive dates can be specified by
    connecting dates with "to":

    e.g. 8/3,8/4,8/11to8/15
    e.g. 8-3,8-4,8-11to8-15

    see -> CloseCalendar

.PARAMETER OpenDates
    Specify open dates separated by commas.
    Consecutive dates can be specified by
    connecting dates with "to":

    e.g. 8/3,8/4,8/11to8/15
    e.g. 8-3,8-4,8-11to8-15

    see -> OpenCalendar

.PARAMETER CloseCalendar
    Specify close dates in a text file.
    Consecutive dates can be specified by
    connecting dates with "to".
    Spaces are allowd before and afeter "to"

    8/3
    8/11 to 8/15

    see -> CloseDates

.PARAMETER OpenCalendar
    Specify open dates in a text file.
    Consecutive dates can be specified by
    connecting dates with "to".
    Spaces are allowd before and afeter "to"
    
    8/3
    8/11 to 8/15

    see -> OpenDates

.PARAMETER Grep
    Search task name by regular expression.
    Paint bar red when matches.
    Paint color can be specified with "-GrepColor"

.PARAMETER GrepRes
    Search result task name by regular expression.
    Paint bar red when matches.
    Paint color can be specified with "-GrepColor"

.PARAMETER GrepColor
    Color of bars matched by -Grep option.

.PARAMETER OffSettings
    Do not output color settings.
    Default: use default color.

.PARAMETER Zoom
    Set column width

.PARAMETER Scale
    Set scale

.PARAMETER Today
    Fill today's date with light blue.


.PARAMETER TagMark
    Specify the tag recognition mark with regex.

    Default: .Tag <tag>,<tag>,...
          or .Tag: <tag>,<tag>,...

.EXAMPLE
    cat input.txt
    # title
    
    ## project name [2023-03-01]
    < task3-review [4]
    << task3-2 [4]
    << task3-1 [4]
    < task2-review [5]
    << task2-2 [5]
    << task2-1 [5]
    ### sub milestone
    < task1-review [5]
    ### task1 fin
    < task1-2 [4]
    << task1-2-1 [4]
    < task1-1 [4]


    PS > cat input.txt | gantt2pu -CloseSatSun -Today -StartDate 2023-1-18 > a.pu; pu2java a.pu png | ii
    @startgantt
    
    <style>
    ganttDiagram {
        arrow {
            LineColor Gray
        }
    }
    </style>
    
    language ja
    printscale daily zoom 1
    scale 1
    
    project starts 2023-01-31
    
    title "title"
    
    -- project name [2023-03-01] --
    [fin] as [M1] happens 2023-03-01
      [task3-review] as [T1] lasts 4 days and ends at [M1]'s start
      [task3-2] as [T2] lasts 4 days and ends at [T1]'s start
      [task3-1] as [T3] lasts 4 days and ends at [T2]'s start
      [task2-review] as [T4] lasts 5 days and ends at [M1]'s start
      [task2-2] as [T5] lasts 5 days and ends at [T4]'s start
      [task2-1] as [T6] lasts 5 days and ends at [T5]'s start
    [sub milestone] as [M2] happens at [T6]'s start
      [task1-review] as [T7] lasts 5 days and ends at [M2]'s start
    [task1 fin] as [M3] happens at [T7]'s start
      [task1-2] as [T8] lasts 4 days and ends at [M3]'s start
      [task1-2-1] as [T9] lasts 4 days and ends at [T8]'s start
      [task1-1] as [T10] lasts 4 days and ends at [M3]'s start
    
    @endgantt

#>
function gantt2pu {
    Param(
        [Parameter(Position=0, Mandatory=$False)]
        [ValidateSet("days", "weeks")]
        [string]$Unit = "days",

        [Parameter(Mandatory=$False)]
        [ValidateSet("daily", "weekly","monthly","quarterly","yearly")]
        [string]$Period = "daily",

        [Parameter(Mandatory=$False)]
        [string] $Lang = "ja",

        [Parameter(Mandatory=$False)]
        [string] $Title,

        [Parameter(Mandatory=$False)]
        [datetime] $StartDate,

        [Parameter(Mandatory=$False)]
        [datetime] $EndDate,

        [Parameter(Mandatory=$False)]
        [int] $StartDateFix = -1,

        [Parameter(Mandatory=$False)]
        [string] $MilestoneMark = '##',

        [Parameter(Mandatory=$False)]
        [switch] $MarkdownLevel2AsSeparator,

        [Parameter(Mandatory=$False)]
        [switch] $SectionLv2,

        [Parameter(Mandatory=$False)]
        [switch] $AsMilestone,

        [Parameter(Mandatory=$False)]
        [string] $TaskbarColor,

        [Parameter(Mandatory=$False)]
        [string] $ArrowColor = "Gray",

        [Parameter(Mandatory=$False)]
        [switch]$CloseSatSun,

        [Parameter(Mandatory=$False)]
        [string[]]$CloseDates,

        [Parameter(Mandatory=$False)]
        [string[]]$CloseCalendar,

        [Parameter(Mandatory=$False)]
        [string[]]$OpenDates,

        [Parameter(Mandatory=$False)]
        [string[]]$OpenCalendar,

        [Parameter(Mandatory=$False)]
        [string[]]$ColorDates,

        [Parameter(Mandatory=$False)]
        [string[]]$NamedDates,

        [Parameter(Mandatory=$False)]
        [switch]$ColorToday,

        [Parameter(Mandatory=$False)]
        [string] $TodayColor = "Aquamarine",

        [Parameter(Mandatory=$False)]
        [regex]$Grep,

        [Parameter(Mandatory=$False)]
        [string]$GrepColor = 'Tomato/Brown',

        [Parameter(Mandatory=$False)]
        [regex]$GrepRes,

        [Parameter(Mandatory=$False)]
        [int] $Zoom = 1,

        [Parameter(Mandatory=$False)]
        [int] $Scale = 1,

        [Parameter(Mandatory=$False)]
        [string]$ColorResult = "Gray/Gray",

        [Parameter(Mandatory=$False)]
        [switch]$Today,

        [Parameter(Mandatory=$False)]
        [switch]$Monochrome,

        [Parameter(Mandatory=$False)]
        [switch]$HandWritten,

        [Parameter(Mandatory=$False)]
        [switch]$InheritTasks,

        [Parameter(Mandatory=$False)]
        [switch]$OffSettings,

        [Parameter(Mandatory=$False)]
        [string]$DuplicatedTaskMark = ' ',

        [Parameter(Mandatory=$False)]
        [string]$DefaultFontName = "MS Gothic",

        [Parameter(Mandatory=$False)]
        [int]$FontSize,

        [Parameter(Mandatory=$False)]
        [ValidateSet(
            "none", "amiga", "aws-orange", "blueprint", "cerulean",
            "cerulean-outline", "crt-amber", "crt-green",
            "mars", "mimeograph", "plain", "sketchy", "sketchy-outline",
            "spacelab", "toy", "vibrant"
        )]
        [string]$Theme,

        [Parameter(Mandatory=$False)]
        [string] $MilestoneStr = 'fin',

        [Parameter(Mandatory=$False)]
        [regex] $TagMark = '^\.Tag[:]*\s*',

        [parameter(Mandatory=$False,
          ValueFromPipeline=$True)]
        [string[]] $Text
    )

    begin{
        ## init var
        $readLineList = New-Object 'System.Collections.Generic.List[System.String]'
        [string[]] $oldestDateList = @()
        [string[]] $beforeTaskListForMilestone = @()
        [string[]] $beforeTaskListForTask = @()
        [string[]] $beforeResultList = @()

        ## flags
        [bool] $firstMilestoneFlag = $True
        [bool] $firstTaskFlag      = $True
        [bool] $firstResultFlag    = $True

        ## marks
        [string] $beforeTaskMark = '@@befTask@@'

        ## before, 1st, parend id
        [string] $parentMilestoneID = 'NA'
        [string] $beforeTaskID      = 'NA'
        [string] $beforeResultID    = 'NA'
        [string] $befResParallelID  = ''
        [string] $befResSeriesID    = ''

        ## id counter
        [int] $rowCounter     = 0
        [int] $countMilestone = 0
        [int] $countTask      = 0
        [int] $countResult    = 0

        ## task id
        [string] $mHead = 'M'
        [string] $tHead = 'T'
        [string] $rHead = 'R'
        [string] $milestoneID = $mHead + [string]$countMilestone
        [string] $taskID      = $tHead + [string]$countTask
        [string] $resultID    = $rHead + [string]$countResult

        ## taskname dictionary
        $dictTaskName = @{}
        $dictBeforeTaskName = @{}

        ## private functions
        function IsDate ([string]$dat){
            if ($dat -match 'today'){
                $dat = (Get-Date).ToString('yyyy-MM-dd')
            }
            try   { [string]$resDate = (Get-Date $dat).ToString('yyyy-MM-dd') }
            catch { Write-Error "Please specify date for the first milestone: $dat" -ErrorAction Stop}
            return $resDate
        }
        function GetYMD ([string]$dat){
            try   { [string]$resDate = (Get-Date $dat).ToString('yyyy-MM-dd') }
            catch { [string]$resDate = "NotDate" }
            return $resDate
        }
        function DeleteComment ([string]$line){
            ## delete after "--"
            if ($line -match '^\-.*\-$'){
                ## as-is output for plantuml task separator
                return $line
            } elseif ($line -match '\-\-') {
                ## escape milestone/task mark '--'
                $line = $line -replace '^(\s*)\-\-','$1@a@a@a@'
                ## delete comment
                $line = $line -replace '\s*?\-\-.*$',''
                ## undo escape
                $line = $line -replace '^(\s*)@a@a@a@','$1--'
                return $line
            }
            return $line
        }
        function ParseResource ([string]$res){
            return "on $res "
        }
        function ParseMileDate ([string]$dat){
            $dat = $dat -replace '\[|\]',''
            $dat = IsDate $dat
            return $dat
        }
        function ParseResDate ([string]$dat){
            $dat = $dat -replace '\[|\]',''
            if($dat -match '\(..*\)'){
                $com = $dat -replace '^(..*)\s+\(\s*(..*)\s*\)',' and is $2 completed'
                $dat = $dat -replace '^(..*)\s+\(\s*(..*)\s*\)','$1'
            } else {
                $com = ''
            }
            $splitDat = $dat.Split(',')
            if ($splitDat.Count -eq 1){
                $dat1 = IsDate $splitDat[0]
                $dat2 = $dat1
            } else {
                $dat1 = IsDate $splitDat[0]
                $dat2 = IsDate $splitDat[1]
            }
            return $dat1,$dat2,$com
        }
        function ParseTaskDate ([string]$dat, [bool]$Rev = $False, [string]$befTasMark){
            $com = ''
            $delay = ''
            $dat = $dat -replace '\[|\]',''
            if($dat -match '\(..*\)'){
                $com = $dat -replace '^(..*)\s+\(\s*(..*)\s*\)',' and is $2 completed'
                $dat = $dat -replace '^(..*)\s+\(\s*(..*)\s*\)','$1'
            }
            if($dat -match ','){
                ## case of $dat=lasts,delay
                $lasts = ($dat.Split(','))[0]
                $delay = ($dat.Split(','))[1]
                if (-not $Rev){
                    try {
                        $lasts = (Get-Date $lasts).ToString('yyyy-MM-dd')
                        $dat = "ends $lasts"
                    } catch {
                        $dat = "lasts $lasts $Unit"
                    }
                    $delay = " and starts $delay $Unit after [$befTasMark]'s end"
                } else  {
                    try {
                        $lasts = (Get-Date $lasts).ToString('yyyy-MM-dd')
                        $dat = "starts $lasts"
                    } catch {
                        $dat = "lasts $lasts $Unit"
                    }
                    $delay = " and ends $delay $Unit before [$befTasMark]'s start"
                }
            } else{
                ## case of $dat=lasts
                if ( -not $Rev){
                    $dat = "lasts $dat $Unit and starts at [$befTasMark]'s end"
                } else {
                    $dat = "lasts $dat $Unit and ends at [$befTasMark]'s start"
                }
            }
            $dat = $dat + $delay + $com
            return $dat
        }
        function ParseMilestone ([string]$line, [bool]$isFirst){
            ## parallel connection milestone
            $lin = $line
            $lin = $lin -replace "^m ",''
            $lin = $lin -replace '^\-\>\s+',''
            $lin = $lin -replace '^\-\-\s+',''
            if ($isFirst){
                ## first milestone
                ## task,date
                $tas = $lin -replace '^(..*)\s+(..*?)$','$1'
                $dat = $lin -replace '^(..*)\s+(..*?)$','$2'
                $dat = ParseMileDate $dat
            } else {
                ## subsequent milestone
                ## task,[date]
                if($lin -match '\['){
                    ## with date
                    $tas = $lin -replace '^(..*)\s+(..*?)$','$1'
                    $dat = $lin -replace '^(..*)\s+(..*?)$','$2'
                    $dat = ParseMileDate $dat
                } else {
                    ## without date
                    $tas = $lin
                    $dat = ""
                }
            }
            if ($tas -match '<..*>'){
                ## hyperlink
                $hlink = $tas -replace '^(..*)\s*<(..*)>\s*$','$2'
                $tas   = $tas -replace '^(..*)\s*<(..*)>\s*$','$1'
            } else {
                $hlink = ''
            }
            $tas = $tas.trim()
            $hlink = $hlink.trim()
            return $tas,$dat,$hlink
        }
        function ParseTaskResource ([string]$tas){
            $res = ''
            if($tas -match '\{'){
                $res = $tas -replace '^(..*)\s+(\{..*\})$','$2'
                $tas = $tas -replace '^(..*)\s+(\{..*\})$','$1'
            }
            return $tas,$res
        }
        function ParseTask ([string]$line, [bool]$Rev = $False, [string]$befTasMark){
            ## parallel connection task
            $lin = $line
            $lin = $lin -replace '^>+\s+',''
            $lin = $lin -replace '^<+\s+',''
            $tas = $lin -replace '^(..*)\s+(\[..*)$','$1'
            $dat = $lin -replace '^(..*)\s+(\[..*)$','$2'
            $tas,$res = ParseTaskResource $tas
            $dat = ParseTaskDate $dat $Rev $befTasMark
            if ($tas -match '<..*>'){
                ## hyperlink
                $hlink = $tas -replace '^(..*)\s*<(..*)>\s*$','$2'
                $tas   = $tas -replace '^(..*)\s*<(..*)>\s*$','$1'
            } else {
                $hlink = ''
            }
            $tas = $tas.trim()
            $hlink = $hlink.trim()
            return $tas,$res,$dat,$hlink
        }
        function ParseResult ([string]$line){
            ## parallel connection task
            $lin = $line
            $lin = $lin -replace '^\*+\s+',''
            $tas = $lin -replace '^(..*)\s+(\[..*)$','$1'
            $dat = $lin -replace '^(..*)\s+(\[..*)$','$2'
            $tas,$res = ParseTaskResource $tas
            $dat1,$dat2,$com = ParseResDate $dat
            if ($tas -match '<..*>'){
                ## hyperlink
                $hlink = $tas -replace '^(..*)\s*<(..*)>\s*$','$2'
                $tas   = $tas -replace '^(..*)\s*<(..*)>\s*$','$1'
            } else {
                $hlink = ''
            }
            $tas = $tas.trim()
            $hlink = $hlink.trim()
            return $tas,$res,$dat1,$dat2,$com,$hlink
        }
        function ReplaceMarkdownListToLRMark ([string]$line){
            $lin = $line
            $lin = $lin -replace '^\- ','< '
            $lin = $lin -replace '^\s+\- ','<< '
            $lin = $lin -replace '^\+ ','> '
            $lin = $lin -replace '^\s+\+ ','>> '
            $lin = $lin -replace '^\s*\* ','* '
            $lin = $lin -replace '^\s*mm ','mm '
            $lin = $lin.Trim()
            return $lin
        }
        ## set markdown level
        if ($SectionLv2){
            $SeparatorMark    = '##'
            $MilestoneMark    = '###'
            $MilestoneMarkSub = '####'
        } else {
            $SeparatorMark    = $null
            $MilestoneMark    = '##'
            $MilestoneMarkSub = '###'
        }
    }
    process{
        $rowCounter++
        [string]$readLine = $_
        ## ignore .Tag line
        if ($readLine -match "$TagMark"){
            $readLine = ''}
        $readLine = ReplaceMarkdownListToLRMark $readLine
        $readLine = DeleteComment $readLine
        $readLine = $readLine -replace ' +$',''
        ## parse milestone marks
        if($SectionLv2){
            if ($readLine -match "^$SeparatorMark (..*)"){
                $readLine = $readLine -replace "^$SeparatorMark (..*)$",'-- $1 --'}
        }
        if ($readLine -match "^$MilestoneMarkSub (..*)"){
            $readLine = $readLine -replace "^$MilestoneMarkSub ",'mm '}
        if ($readLine -match "^$MilestoneMark "){
            if ($AsMilestone){
                ## parse '## milestone yyyy-mm-dd'
                ## to
                ## 'm milestone yyyy-mm-dd'
                $readLine = $readLine -replace "^$MilestoneMark ","m "
            } else {
                ## parse '## milestone yyyy-mm-dd'
                ## to
                ## '-- milestone yyyy-mm-dd'
                ## 'm fin. yyyy-mm-dd'
                $readLine = $readLine -replace "^$MilestoneMark ",""
                $mSeparator = "-- $readLine --"
                $readLineList.Add($mSeparator)
                $mSepDate = $readLine -replace '^..*(\[..*\]) *$','$1'
                $readLine = "m $MilestoneStr $mSepDate"
            }
        }
        if ($readLine -match "^m "){
            ## init var
            [string[]]$beforeTaskListForMilestone = @()
            [string[]]$beforeResultList = @()
            ## init parent, before id
            [string]$parentMilestoneID = 'NA'
            [string]$beforeTaskID      = 'NA'
            [string]$beforeResultID    = 'NA'
            [string]$befTask = ''
            [string]$befResParallelID  = ''
            [string]$befResSeriesID    = ''
            ## init flags
            [bool] $firstMilestoneFlag = $True
            [bool] $firstTaskFlag      = $True
            [bool] $firstResultFlag    = $True
            [bool] $revFlag            = $False
            ## dictionary
            if(-not $InheritTasks){
                $dictBeforeTaskName = @{}
            }
        }
        ## main
        switch -Regex ($readLine) {
            '^\-.*\-$' {
                ## as-is output for plantuml task separator
                $readLineList.Add($readLine)
                [bool] $revFlag = $False
                Break;
            }
            "^m " {
                ## Milestone (parallel)
                if($readLine -notmatch '\['){
                    Write-Error "Enclose the date and number of dates in square brackets. e.g. [1] $readLine" -ErrorAction Stop
                }
                $countMilestone++
                [bool] $firstTaskFlag = $True
                [bool] $revFlag = $False
                [string] $milestoneID = $mHead + [string]$countMilestone
                if ($firstMilestoneFlag){
                    ## first milestone
                    [bool] $firstMilestoneFlag = $False
                    $tas,$dat,$hlink = ParseMilestone $readLine $True
                    ## is taskname duplicated?
                    while ($dictTaskName.ContainsKey($tas)){
                        $tas = [string]$tas + "$DuplicatedTaskMark"
                    }
                    $dictTaskName.Add($tas,$milestoneID)
                    $dictBeforeTaskName.Add($tas,$milestoneID)

                    $readLineList.Add("[$tas] as [$milestoneID] happens $dat")
                    if ($hlink -ne ''){
                        $readLineList.Add("[$milestoneID] links to [[$hlink]]")
                    }
                    ## set project start date
                    $firstDate = $dat
                    $oldestDateList += ,@(GetYMD $dat)
                } else {
                    ## subsequent milestone
                    $tas,$dat,$hlink = ParseMilestone $readLine $False
                    ## is taskname duplicated?
                    while ($dictTaskName.ContainsKey($tas)){
                        $tas = [string]$tas + "$DuplicatedTaskMark"
                    }
                    $dictTaskName.Add($tas,$milestoneID)
                    $dictBeforeTaskName.Add($tas,$milestoneID)

                    if ($dat -eq ''){ $dat = $firstDate }
                    $readLineList.Add("[$tas] as [$milestoneID] happens $dat")
                    if ($hlink -ne ''){
                        $readLineList.Add("[$milestoneID] links to [[$hlink]]")
                    }
                }
                ## init before tasklist
                #$beforeTaskListForTask = $beforeTaskListForMilestone
                [string[]]$beforeTaskListForMilestone = @()
                $beforeTaskListForMilestone = ,@($milestoneID)
                $parentMilestoneID = $milestoneID
                Write-Debug "$milestoneID $beforeTaskID $taskID $readLine"
                break;
            }
            "^mm " {
                ## Milestone start at ends of before tasks (parallel)
                $countMilestone++
                $milestoneID = $mHead + [string]$countMilestone
                ## subsequent milestone
                $tas = $readLine -replace '^mm ',''
                ## is taskname duplicated?
                while ($dictTaskName.ContainsKey($tas)){
                    $tas = [string]$tas + "$DuplicatedTaskMark"
                }
                $dictTaskName.Add($tas,$milestoneID)
                $dictBeforeTaskName.Add($tas,$milestoneID)

                if ($revFlag){
                    ## case of prepare task like '< task1'
                        $readLineList.Add("[$tas] as [$milestoneID] happens at [$beforeTaskID]'s start")
                } else {
                    foreach ($key in $dictBeforeTaskName.keys){
                        ## case of normal task like '> task1'
                        $beftId = $dictBeforeTaskName[$Key]
                        $readLineList.Add("[$tas] as [$milestoneID] happens at [$beftId]'s end")
                    }
                }
                if(-not $InheritTasks){
                    $dictBeforeTaskName = @{}
                    $dictBeforeTaskName.Add($tas,$milestoneID)
                }
                ## init before tasklist
                $parentMilestoneID = $milestoneID
                #$beforeTaskListForTask = $beforeTaskListForMilestone
                Write-Debug "$milestoneID $beforeTaskID $taskID $readLine"
                break;
            }
            '^> [^ ]+|^< [^ ]+' {
                ## Task (parallel)
                if($readLine -notmatch '\['){
                    Write-Error "Enclose the date and number of dates in square brackets. e.g. [1] $readLine" -ErrorAction Stop
                }
                $countTask++
                $taskID = $tHead + [string]$countTask
                ## check direction
                if ($readLine -match '^>'){
                    $Rev = $False
                    $revFlag = $Rev
                } else {
                    $Rev = $True
                    $revFlag = $Rev
                }
                ## set before tasklist
                $beforeTaskListForMilestone += ,@($taskID)
                if ($firstTaskFlag){
                    ## first task
                    $befTask = $parentMilestoneID
                    $firstTaskFlag = $False
                } else {
                   ## subsequent task
                    $befTask = $parentMilestoneID
                }
                $tas,$res,$dat,$hlink = ParseTask $readLine $Rev $beforeTaskMark
                ## is taskname duplicated?
                while ($dictTaskName.ContainsKey($tas)){
                    $tas = [string]$tas + "$DuplicatedTaskMark"
                }
                $dictTaskName.Add($tas,$taskID)
                $dictBeforeTaskName.Add($tas,$taskID)

                $col = ""
                if ($res -ne ""){ $res = ParseResource $res }
                if ($Grep){ if ("$tas $res" -match $Grep){ $col = " and is colored in $GrepColor" } }
                if ($dat -match "$beforeTaskMark"){
                    ## with delay
                    $dat = $dat -replace "$beforeTaskMark",$parentMilestoneID
                    if ($dat -match " \[NA\]'s "){
                        Write-Error "Milestone is not set: line $rowCounter : ""$readLine""" -ErrorAction Stop}
                    $readLineList.Add("  [$tas] as [$taskID] " + $res + $dat + $col)
                } else {
                    ## without delay
                    $readLineList.Add("  [$tas] as [$taskID] " + $res + $dat + $col)
                }
                if ($hlink -ne ''){
                    ## add hyperlink
                    $readLineList.Add("  [$taskID] links to [[$hlink]]")
                }
                $beforeTaskID = $taskID
                Write-Debug "$milestoneID $beforeTaskID $taskID $readLine"
                break;
            }
            '^>> [^ ]+|^<< [^ ]+' {
                ## Task (series)
                if($readLine -notmatch '\['){
                    Write-Error "Enclose the date and number of dates in square brackets. e.g. [1] $readLine" -ErrorAction Stop
                }
                $countTask++
                $taskID = $tHead + [string]$countTask
                ## check direction
                if ($readLine -match '^>'){
                    $Rev = $False
                    $revFlag = $Rev
                } else {
                    $Rev = $True
                    $revFlag = $Rev
                }
                ## set before tasklist
                if ($firstTaskFlag){
                    ## first task
                    $befTask = $parentMilestoneID
                    $beforeTaskListForMilestone = @()
                    $beforeTaskListForMilestone += ,@($taskID)
                    $firstTaskFlag = $False
                } else {
                   ## subsequent task
                    $befTask = $beforeTaskID
                    $beforeTaskListForMilestone[$beforeTaskListForMilestone.Count - 1] = $taskID
                }
                $tas,$res,$dat,$hlink = ParseTask $readLine $Rev $beforeTaskMark
                ## is taskname duplicated?
                while ($dictTaskName.ContainsKey($tas)){
                    $tas = [string]$tas + "$DuplicatedTaskMark"
                }
                $dictTaskName.Add($tas,$taskID)
                $dictBeforeTaskName.Add($tas,$taskID)

                $col = ""
                if ($res -ne ""){ $res = ParseResource $res }
                if ($Grep){ if ("$tas $res" -match $Grep){ $col = " and is colored in $GrepColor" } }
                if ($dat -match "$beforeTaskMark"){
                    ## with delay
                    $dat = $dat -replace $beforeTaskMark,$befTask
                    if ($dat -match " \[NA\]'s "){
                        Write-Error "Milestone is not set: line $rowCounter : ""$readLine""" -ErrorAction Stop}
                    $readLineList.Add("  [$tas] as [$taskID] " + $res + $dat + $col)
                } else {
                    ## without delay
                    $readLineList.Add("  [$tas] as [$taskID] " + $res + $dat + $col)
                }
                if ($hlink -ne ''){
                    ## add hyperlink
                    $readLineList.Add("  [$taskID] links to [[$hlink]]")
                }
                $beforeTaskID = $taskID
                Write-Debug "$milestoneID $beforeTaskID $taskID $readLine"
                break;
            }
            '^\*+ [^ ]+'  {
                ## Result (parallel)
                if($readLine -notmatch '\['){
                    Write-Error "Enclose the date and number of dates in square brackets. e.g. [1] $readLine" -ErrorAction Stop
                }
                $countResult++
                $resultID = $rHead + [string]$countResult
                if ($firstResultFlag){
                    ## first result
                    $firstResultFlag = $False
                    $beforeResultID  = $parentMilestoneID
                } else {
                   ## subsequent result
                    $beforeResultID  = $befResParallelID
                }
                $tas,$res,$dat1,$dat2,$com,$hlink = ParseResult $readLine
                ## is taskname duplicated?
                while ($dictTaskName.ContainsKey($tas)){
                    $tas = [string]$tas + "$DuplicatedTaskMark"
                }
                $dictTaskName.Add($tas,1)

                $tmpYMD = GetYMD $dat1; if($tmpYMD -ne "NotDate"){$oldestDateList += ,@($tmpYMD)}
                $tmpYMD = GetYMD $dat2; if($tmpYMD -ne "NotDate"){$oldestDateList += ,@($tmpYMD)}
                if ($res -ne ""){ $res = ParseResource $res }
                $oline = "  [$tas] as [$resultID] " + $res + "starts $dat1 and ends $dat2"
                if ($com -ne ''){$oline = $oline + $com}
                $readLineList.Add($oline)
                #$readLineList.Add("    [$beforeResultID] -[#lightgray]-> [$resultID]")
                if ($GrepRes){
                    if ("$tas $res" -match $GrepRes){
                        $readLineList.Add("    [$resultID] is colored in $GrepColor")
                    } else {
                        $readLineList.Add("    [$resultID] is colored in $ColorResult")
                    }
                } else {
                    $readLineList.Add("    [$resultID] is colored in $ColorResult")
                }
                if ($hlink -ne ''){
                    ## add hyperlink
                    $readLineList.Add("    [$resultID] links to [[$hlink]]")
                }
                $befResParallelID = $parentMilestoneID
                $befResSeriesID   = $resultID
                Write-Debug "$milestoneID $beforeResultID $resultID $readLine"
                break;
            }
            default {
                if (($rowCounter -eq 1) -and ($readLine -match '^# ') -and ( -not $Title)){
                    ## infile title
                    [string] $readLine = $readLine -replace '^# (..*)$','title "$1"'
                    $readLineList.Add($readLine)
                } else {
                    ## output as-is
                    $readLineList.Add($readLine)
                }
            }
        }
    }
    end{
        ## test option
        if (($oldestDateList.Count -eq 0) -and ( -not $StartDate)){
            ## test project start date
            Write-Error "Need to set -StartDate option" -ErrorAction Stop}
        if ($TaskbarColor){
            ## test taskbar color option
            if ($TaskbarColor -notmatch '/'){
                Write-Error "Please separate TaskbarColor using ""/"" line ""line/fill""." -ErrorAction Stop
            }
        }
        ## header
        Write-Output "@startgantt"
        Write-Output ""
        ### color settings
        if (-not $OffSettings){
            if (($TaskbarColor) -or ($ArrowColor)){
                Write-Output ""
                Write-Output "<style>"
                Write-Output "ganttDiagram {"
            }
            if ($TaskbarColor){
                $taskLineColor = ($TaskbarColor.Split("/"))[0]
                $taskFillColor = ($TaskbarColor.Split("/"))[1]
                Write-Output "    task {"
                Write-Output "        BackGroundColor $taskFillColor"
                Write-Output "        LineColor $taskLineColor"
                Write-Output "    }"
            }
            if ($ArrowColor){
                Write-Output "    arrow {"
                Write-Output "        LineColor $ArrowColor"
                Write-Output "    }"
            }
            if (($TaskbarColor) -or ($ArrowColor)){
                Write-Output "}"
                Write-Output "</style>"
            }
        }
        ### other option
            Write-Output ""
            if ($Title){
                Write-Output "title ""$Title"""
                Write-Output ""
            }
            Write-Output "language $Lang"
            Write-Output "printscale $Period zoom $Zoom"
            Write-Output "scale $Scale"
        if ($Today){
            Write-Output "$((Get-Date).ToString('yyyy-MM-dd')) is colored in $TodayColor"}
        if ($Monochrome)  {
            Write-Output "skinparam monochrome true"  }
        if ($HandWritten) {
            Write-Output "skinparam handwritten true" }
        if ($DefaultFontName){
            Write-Output "skinparam defaultFontName ""$DefaultFontName""" }
        if ($FontSize){
            Write-Output "skinparam defaultFontSize $FontSize" }
        if ($Theme) {
            Write-Output "!theme $Theme" }
        Write-Output ""
        if ($ColorDates){
            foreach ($cDate in $ColorDates){
                if ($cDate -match 'to'){
                    $cDateAry   = $cDate -split '\s*to\s*'
                    $cDateStart = (Get-Date $cDateAry[0]).ToString('yyyy-MM-dd')
                    $cDateEnd   = (Get-Date $cDateAry[1]).ToString('yyyy-MM-dd')
                    Write-Output "$cDateStart to $cDateEnd are colored in $TodayColor"
                } else {
                    $cDate = Get-Date "$cDate"
                    $cDatStr = $cDate.ToString('yyyy-MM-dd')
                    Write-Output "$cDatStr is colored in $TodayColor"
                }
            }
        }
        if ($ColorToday){
            $cDatStr = (Get-Date).ToString('yyyy-MM-dd')
            Write-Output "$cDatStr is colored in $TodayColor"
        }
        if ($CloseSatSun){
            Write-Output "Saturday are closed"
            Write-Output "Sunday are closed"
        }
        if ($CloseDates){
            foreach ($cDate in $CloseDates){
                if ($cDate -match 'to'){
                    $cDateAry   = $cDate -split '\s*to\s*'
                    $cDateStart = (Get-Date $cDateAry[0]).ToString('yyyy-MM-dd')
                    $cDateEnd   = (Get-Date $cDateAry[1]).ToString('yyyy-MM-dd')
                    Write-Output "$cDateStart to $cDateEnd are closed"
                } else {
                    $cDate = Get-Date "$cDate"
                    $cDatStr = $cDate.ToString('yyyy-MM-dd')
                    Write-Output "$cDatStr is closed"
                }
            }
        }
        if ($CloseCalendar){
            foreach ($cCal in $CloseCalendar){
                if (-not (Test-Path -Path "$cCal")){
                    Write-Error "$cCal is not exist." -ErrorAction Stop
                }
                Get-Content -Path $cCal -Encoding UTF8 `
                    | ForEach-Object {
                        $cDate = $_.trim()
                        if ( ($cDate -eq '') -or ($cDate -match '^#') ){
                              #pass
                        } elseif ($cDate -match 'to'){
                            $cDateAry   = $cDate -split '\s*to\s*'
                            $cDateStart = (Get-Date $cDateAry[0]).ToString('yyyy-MM-dd')
                            $cDateEnd   = (Get-Date $cDateAry[1]).ToString('yyyy-MM-dd')
                            Write-Output "$cDateStart to $cDateEnd are closed"
                        } else {
                            $cDate = Get-Date "$cDate"
                            $cDatStr = $cDate.ToString('yyyy-MM-dd')
                            Write-Output "$cDatStr is closed"
                        }
                    }
            }
        }
        if ($OpenDates){
            foreach ($oDate in $OpenDates){
                if ($oDate -match 'to'){
                    $oDateAry   = $oDate -split '\s*to\s*'
                    $oDateStart = (Get-Date $oDateAry[0]).ToString('yyyy-MM-dd')
                    $oDateEnd   = (Get-Date $oDateAry[1]).ToString('yyyy-MM-dd')
                    Write-Output "$oDateStart to $oDateEnd are opened"
                } else {
                    $oDate = Get-Date "$oDate"
                    $oDatStr = $oDate.ToString('yyyy-MM-dd')
                    Write-Output "$oDatStr is opened"
                }
            }
        }
        if ($OpenCalendar){
            foreach ($oCal in $OpenCalendar){
                if (-not (Test-Path -Path "$oCal")){
                    Write-Error "$oCal is not exist." -ErrorAction Stop
                }
                Get-Content -Path $oCal -Encoding UTF8 `
                    | ForEach-Object {
                        $oDate = $_.trim()
                        if ( ($oDate -eq '') -or ($oDate -match '^#') ){
                            #pass
                        } elseif ($oDate -match 'to'){
                            $oDateAry   = $oDate -split '\s*to\s*'
                            $oDateStart = (Get-Date $oDateAry[0]).ToString('yyyy-MM-dd')
                            $oDateEnd   = (Get-Date $oDateAry[1]).ToString('yyyy-MM-dd')
                            Write-Output "$oDateStart to $oDateEnd are opened"
                        } else {
                            $oDate = Get-Date "$oDate"
                            $oDatStr = $oDate.ToString('yyyy-MM-dd')
                            Write-Output "$oDatStr is opened"
                        }
                    }
            }
        }
        ## set project start date
        if($Unit -eq 'weeks'){ [int]$wDays = $StartDateFix * 7
        }else{ [int]$wDays = $StartDateFix }
        if ($StartDate){
            [string]$dateYMD = (Get-Date $StartDate).AddDays($wDays).ToString('yyyy-MM-dd')
        } else {
            [string]$dateYMD = $oldestDateList | Sort-Object | Select-Object -First 1
            [string]$dateYMD = (Get-Date $dateYMD).AddDays($wDays).ToString('yyyy-MM-dd')
        }
        Write-Output ""
        Write-Output "project starts $dateYMD"
        Write-Output ""

        ## body
        $readLineAry = $readLineList.ToArray()
        foreach ($element in $readLineAry){
            Write-Output $element }

        ## footer
        Write-Output ""
        if ($EndDate){
            $eDateStr = $EndDate.ToString('yyyy-MM-dd')
            Write-Output "[end.] happens at $eDateStr"
            Write-Output ""
        }
        if ($NamedDates){
            $splitNamedDates = $NamedDates.Split(',')
            if ($splitNamedDates.Count -ne 3){
                Write-Error "-NamedDates <start-date>,<end-date>,<name>" -ErrorAction Stop
            }
            [string]$sdat = (Get-Date $splitNamedDates[0]).ToString('yyyy-MM-dd')
            [string]$edat = (Get-Date $splitNamedDates[1]).ToString('yyyy-MM-dd')
            [string]$ndat = $splitNamedDates[2]
            Write-Output "$sdat to $edat are named [$ndat]"
            Write-Output ""
        }
        Write-Output "@endgantt"
    }
}
