<#
.SYNOPSIS
    Get-Ticket (Alias: t) - A parser for tickets written in one-liner text

    Parse "todo.txt" like format and output as Text/PsObject:

        (B) 2023-12-01 +proj This is a [first ticket] @haccp #tag1 #tag2 due:2023-12-31 link:"path/to/the/file or url"
        x 2023-12-02 2023-12-01 This is a completed ticket

    For todo / task / ticket management, alternatively as a changelog or
    book reference log or recipe consisting of title and body.

    The default behaviour is:

        1. read the [tickets.md] file in the current directory and
        2. return the active tickets as text line.

        The file name to be read by default is searched in the
        following order and the first match is read:

            ticket.txt
            ticket.md
            tickets.txt
            tickets.md

        Or input from pipeline allowed.

        [-f|-File <path>] is the file specification.
        [-o|-AsObject] is output as PsObject.
        [-a|-AllData] is to output both incomplete and completed tickets.

    Basic workflow:

        1. Write tickets in [tickets.md] with text editor

            (B) 2024-12-17 +pwsh Add-Ticket [tickets.md] @home #lang/pwsh #work/pwsh link:"https://github.com/btklab"
            (B) 2024-12-17 +pwsh Register-Git [tickets.md] @home #lang/pwsh

        2. list active tickets as text line from [tickets.md]

            PS> Get-Ticket
            PS> t
            PS> Get-Content tickets.md | Get-Ticket
            PS> Get-Content tickets.md | t

            The output is in text format by default. like this:

            1 (B) 2024-12-17 +pwsh Add-Ticket [tickets.md] @home #lang/pwsh #work/pwsh link:"https://github.com/btklab"
            2 (B) 2024-12-17 +pwsh Register-Git [tickets.md] @home #lang/pwsh

            If you are bothered by the tags and links,
            use the "-OffTag" and "-OffLink" switches.

            PS> t -OffLink -OffTag

            1 (B) 2024-12-17 +pwsh Add-Ticket [tickets.md] @home
            2 (B) 2024-12-17 +pwsh Register-Git [tickets.md] @home

            To output as objects, use the [-o|-AsObject] switch.

            PS> t -AsObject | ft
            PS> t -o | ft

            Id Done Project ABC Act                     Name         Tag
            -- ---- ------- --- ---                     ----         ---
             1 -    +pwsh   (B) 2024-12-17 Add-Ticket   [tickets.md] {#lang/p…
             2 -    +pwsh   (B) 2024-12-17 Register-Git [tickets.md] {#lang/p…

             [-full|-AllProperty] switch prints all properties.

            PS> t . 1 -AsObject -AllProperty
            PS> t . 1 -o -full

            Id       : 1
            Done     : -
            Project  : +pwsh
            ABC      : (B)
            Act      : 2024-12-17 Add-Ticket
            Name     : [tickets.md]
            At       : @home
            Due      :
            Status   :
            Tag      : {#lang/pwsh, #work/pwsh}
            Link     : https://github.com/btklab
            Create   : 2024-12-17
            Complete :
            Remain   : 0
            Age      : 0
            Raw      : (B) 2024-12-17 +pwsh Add-Ticket [tickets.md] @home #lang/pwsh #work/pwsh link:"https://github.com/btklab"             

        3. filter tickets with keyword (regex) (position=0)

            PS> Get-Ticket -Where keyword
            PS> t -w keyword
            PS> t keyword

            PS> # the regex "." means wildcard (matches any character)
            PS> t .

            1 (B) 2024-12-17 +pwsh Add-Ticket [tickets.md] @home #lang/pwsh #work/pwsh link:"https://github.com/btklab"
            2 (B) 2024-12-17 +pwsh Register-Git [tickets.md] @home #lang/pwsh
            
        4. select id and output body (position=1)

            PS> Get-Ticket -Where keyword -Id 1,3
            PS> t -w keyword -id 1,3
            PS> t keyword 1,3

            PS> # the regex "." means wildcard (matches any character)
            PS> t . 1,3

            PS> # invoke link in body with [-i|-InvokeLink]
            PS> # e.g. link: https://example.com/
            PS> t . 1,3 -InvokeLink
            PS> t . 1,3 -i

        5. complete the task

            Mark the line with an "x" to complete it

            PS> vim tickets.txt
            x (B) 2024-12-17 +pwsh Register-Git [tickets.md] @home #lang/pwsh

            You can also add a completion date

            PS> vim tickets.txt
            x (B) 2024-12-31 2024-12-17 +pwsh Register-Git [tickets.md] @home #lang/pwsh

            [-a|-AllData] output both incomplete and completed tickets

            PS> Get-Ticket -AllData
            PS> t -a

            Or you can simply grep tickets.txt

            PS> (sls '^x ' tickets.txt).Line

        6. (Loop)

    Various output:

        As Text line:

            Default

        As PsObject with [-o|-AsObject]:

            Sorting by tag, date, etc. is simpler with PsObject
            than with plain text.

            PS> Get-Ticket -Where keyword -Id 1,3 -AsObject
            PS> t -w keyword -id 1,3 -o
            PS> t keyword 1,3 -o

            add required Properties to PsObject output
            (There are few default output properties as follows)
            (Id, Done, Project, Act, Name, At)

            PS> Get-Ticket -Where keyword -id 1,3 -AsObject -AllProperty
            PS> t -where keyword -id 1,3 -AsObject -full
            PS> t keyword 1,3 -o -full

            or

            PS> Get-Ticket -Where keyword -id 1,3 -AsObject -Plus Age,Remain
            PS> t keyword 1,3 -o -p Age,Remain
        
        As plantUML Gantt Chart format with [-Gantt|-GanttNote]:

            Ticket requires both Created and Due date.

            plantUML:
                https://plantuml.com/

            PS> Get-Ticket -Where keyword -Id 1,3 -Gantt
            PS> t -w keyword -id 1,3 -Gantt
            PS> t keyword 1,3 -Gantt

            Note style:

            PS> Get-Ticket -Where keyword -Id 1,3 -GanttNote
            PS> t -w keyword -id 1,3 -GanttNote
            PS> t keyword 1,3 -GanttNote

    Format pattern:

        Note:
        
            ignore empty line and starging with "#" and space.
            lines with one or more spaces at the beginning of the line
            are also ignored, but are output when "-id [int[]]" option
            is specified, they can be used as body for tickets.

        Reference:

            https://github.com/todotxt/todo.txt
        
        Format pattern:

            [tickets.md]

            # Basic
            A simple task
            (B) A simple task with Priority

            # Creation/Completion date
            (A) 2023-12-01 Task with Created date and Priority
            2023-12-01 Task with Created date 
            x 2023-12-31 Task with Completed date
            x 2023-12-31 2023-12-01 Task with Completed date

            # Due date with "due:yyyy-mm-dd"
            A task with due date. due:2023-12-01
            2023-12-01 A task with created date and due date. due:2023-12-31

            # Status with "status:<str>,<str>,..."
            A task with status. status:daily
            A task with status. status:daily,weekly,monthly,yearly,routine
            A task with status. status:daily,active

            # Project, Context, Tag with "+project", "@at", "#tag"
            +proj Task with Project
            +proj Task with Project and @context
            +proj Task with Project and #tag #tag2

            # Document name with "[name]"
            Read-Book [book name with spaces]
            A task with related [document name]

            # Title and Body (for tasknote, changelog, book-reference)
            A Task with multiple line note
                Note have one or more spaces at the beginning of each line.
                link: https://example.com/
                  -> with [-i] option, "link: <link>" opened by default app

            # Misc
            The double phyen -- is deleted from the "Act" property
                when the "-AsObject" option is specified

    A quick demo:

        1. Create/Add [tickets.md] with text editor: [Get-Ticket -e]

            [tickets.md]
            This is task1
            This is task2
                body of task2
            x This is completed task

        2. List active tickets: [Get-Ticket [-a]]

            PS> Get-Ticket
            PS> Get-Ticket .
            PS> Get-Content tickets.md | Get-Ticket
            PS> Get-Content tickets.md | Get-Ticket .
            PS> t
            PS> t .
            1 This is task1
            2 This is task2

            PS> Get-Ticket -AllData
            PS> t -a
            1 This is task1
            2 This is task2
            3 x This is completed task

        3. Filter tickets : [Get-Ticket <regex>]

            PS> # get task contains "task2"
            PS> Get-Ticket -Where task2
            PS> t task2
            1 This is task2
        
        4. Show Title and Body: [Get-Ticket <regex> <id,id,...>]

            PS> # get body of task2
            PS> Get-Ticket -Where task2 -id 1
            PS> t task2 1 
            This is task2
                body of task2
            
        5. Mark the first ticket done with text editor: [Get-Ticket -e]

            [tickets.md]
            x This is task1  <-- Add "x" to the beginning of the line
            This is task2
                body of task2
            x This is completed task

        6. List active tickets: [Get-Ticket [-a]]

            PS> Get-Ticket
            PS> t
            1 This is task2

            PS> Get-Ticket -AllData
            PS> t -a
            1 x This is task1
            2 This is task2
            3 x This is completed task

    Tips for Ticket writing:

        Tasks should be broken down concretely to a level
        where action can be imagined.
        Consider a vague task as a +project tag.

        [tickets.md]

        # Bad. Vague task will remain long
        Keep house clean

        # Good. Tasks broken down into concrete
        +HouseKeepingProject Dry the bedding in the sun. status:daily
        +HouseKeepingProject Vacuum the floor in the north room. status:daily
        +HouseKeepingProject Fold the laundry. status:daily
        +HouseKeepingProject Repair tears in curtain. status:monthly

    Option:

    - Get and Output
        - [-a|-AllData] ...Get data including completed tickets
        - [-Id] ...Show body (description)
            - [-i|-ii|-InvokeLink] ...Invoke link in the body block
            - [[-App|-InvokeLinkWith] <app>] ...Invoke link with app
        - [-os||-OutputSection] ...Output with Section/Comment
    - Output as PsObject
        - [-o|-AsObject] ...Output as PsObject
            - [-la|-LongAct]
            - [-full|-AllProperty]
            - [-p|-Plus <String[]>]
            - [-d|-DeleteTagFromAct]
            - [-sp|-ShortenProperty]
    - Output as Gantt chart format for plantUMLweekl
        - [-Gantt] ...Output as plantUML gantt chart format
        - [-GanttNote] ...Output as plantUML gantt chart format
            - [-GanttPrint <String>]
            - [-GanttFontSize <Int32>]
            - [-GanttZoom <Double>]
            - [-GanttAddDays <Int32>]
            - [-GanttScale <Double>]
            - [-GanttDateFormat <String>]
    - Edit [tickets.md]
        - [-Edit] ...Edit [tickets.md]
        - [-Editor <app>] ...Edit [tickets.md] with app
    - Filter with status
        - [-Status <String[]>] ...Filter tickets with status:<string>
        - [-Daily] ...Filter tickets with status:daily
        - [-Weekly] ...Filter tickets with status:weekly
        - [-Monthly] ...Filter tickets with status:monthly
        - [-Yearly] ...Filter tickets with status:yearly
        - [-Routine]  ...Filter tickets with status:routine
        - [-NoRoutine] ...Filter tickets that do not contain
                            the above routine/recurse keywords
    - List file, property, section
        - [-lsFile] ...List tickets file in current directory
        - [-lsProperty] ...List property
        - [-lsSection] ...List [tickets.md]'s section
    - Misc
        - [-f|-File <String>] ...Read file specification
        - [-DefaultFileName <String>] ...Set default file name
        - [-SkipTest] ...Skip test [isBracketClosed]
    - Add ticket into [tickets.md]
        - [-AddEmpty]
        - [-AddTailEmpty]
        - [-Add <ticket>]
        - [-AddTail <ticket>]
            - [-NoBackup] ...Do not create .bk when adding a task
    - Done ticket in [tickets.md]
        - [-Done <Int32[]>]
            - [-WhatIf] ...Shows what would happen if the cmdlet runs.
                            **The cmdlet isn't run**.
            - [-NoBackup] ...Do not create .bk when overwriting
                            completion mark

    file [tickets.md] example:

        # todo
        (B) 2023-12-01 +proj This is a first ticket  @home #todo/act due:2023-12-31
        (A) 2023-12-01 +proj This is a second ticket @home #todo/act status:monthly:25
        (B) 2023-12-01 +proj This is a third ticket  @home #todo/act status:routine
        x 2023-12-10 2023-12-01 +proj This is a completed ticket @home #todo/done

        # book
        Read book [The HACCP book] +haccp @book #book/author/btklab
            this is body
            link: https://example.com/

        # double hyphen behavior
        x This is done -- Delete the string after the double hyphen #tips #notice
             ...The string after the double hyphen " -- " is deleted
                from the "Act" property when the "-AsObject" option is specified
        x [the -- in the name] is ignored. #tips #notice
             ...The double hyphen " -- " in the [name] is not delete anystring
                after that.

.LINK
    Get-Ticket series:
    Get-Ticket (t), Get-Book (b), Get-Changelog (c), Get-Recipe (recipe), Get-Diary (d), Get-Checklist (checklist)

.EXAMPLE
    # Sort By Project
    PS > Get-Ticket -AsObject -AllProperty | Sort-Object -Property "Project" | Format-Table
    PS > t -o -sa -full | Sort "Project" | ft

    Id Done Project     Act                          Name        
    -- ---- -------     ---                          ----        
     1 -    +Get-Ticket (B) 2023-12-01 Add-Ticket    [tickets.md]
     2 -    +Get-Ticket (B) 2023-12-01 Register-Git  [tickets.md]

.EXAMPLE
    # Group by Atmark
    PS > Get-Ticket -AsObject | Group-Object -Property "At" -NoElement
    PS > t -o | Group "At" -NoElement

    Count Name
    ----- ----
        1 @haccp
        1 @life

    # Group by Project
    PS > Get-Ticket -AsObject | Group-Object -Property "Project" -NoElement
    PS > t -o | Group "Project" -NoElement

    Count Name
    ----- ----
        2 +verification
        1 +audit
        1 +event

    # Group by At and Project
    PS > Get-Ticket | Group-Object "At", "Project" -NoElement

    Count Name
    ----- ----
        1 @haccp, +verification
        1 @haccp, +audit
        1 @life, +event

.EXAMPLE
    # Open link with default browser/filemanager app
    PS > Get-Ticket -id 1 -InvokeLink
    PS > Get-Ticket -id 1 -i

    2023-11-28 Keep-Ledger [household ledger] @life status:monthly:25
        link: https://www.google.com/

    PS > # Open link with firefox
    PS > Get-Ticket -id 1 -InvokeLinkWith firefox
    PS > Get-Ticket -id 1 -iw firefox

    2023-11-28 Keep-Ledger [household ledger] @life status:monthly:25
        link: https://www.google.com/


.EXAMPLE
    # list section written in markdown format
    PS > Get-Ticket -lsSection

    # family
    # books
    # computer
    # haccp

.EXAMPLE
    # output as plantUML gantt chart and create gantt chart using [pu2java] function
    PS > # Note:
    PS > #  All tickets must contain both create and due date
    PS > #  for output as gantt chart format

    PS > Get-Ticket -Where '@haccp' -Gantt > a.pu; pu2java a.pu svg | ii
        @startgantt

        Project starts the 2023-11-30
        2023-12-03 is colored LightBlue
        saturday are closed
        sunday are closed
        printscale daily zoom 1
        scale 1.4

        <style>
        ganttDiagram {
            task {
                    FontColor black
                    FontSize 12
            }
            note {
                    FontSize 12
            }
            separator {
                    FontSize 10
            }
        }
        </style>

        -- +prj --

        [Take-Picture1] on {@haccp} starts 2023-11-28 and ends 2023-12-09

        [Take-Picture2] on {@haccp} starts 2023-11-28 and ends 2023-12-09

        @endgantt

.EXAMPLE
    # list Get-Ticket family (series)
    PS> Get-Ticket -GetSeries

    Alias Name
    ----- ----
    t     Get-Ticket
    d     Get-Diary
    b     Get-Book
    re    Get-Recipe
    n     Get-Note


#>
function Get-Ticket {

    [CmdletBinding(DefaultParameterSetName="None")]
    param (
        [Parameter( Mandatory=$False, Position=0 )]
        [Alias('w')]
        [String] $Where = '.',
        
        [Parameter( Mandatory=$False, Position=1 )]
        [Int[]] $Id,
        
        [Parameter( Mandatory=$False )]
        [Alias('p')]
        [String[]] $Plus,
        
        [Parameter( Mandatory=$False )]
        [Alias('f')]
        [String] $File,
        
        [Parameter( Mandatory=$False )]
        [Alias('full')]
        [Switch] $AllProperty,
        
        [Parameter( Mandatory=$False )]
        [Alias('New')]
        [String] $Add,
        
        [Parameter( Mandatory=$False )]
        [String] $AddTail,
        
        [Parameter( Mandatory=$False )]
        [Switch] $AddEmpty,
        
        [Parameter( Mandatory=$False )]
        [Switch] $AddTailEmpty,
        
        [Parameter( Mandatory=$False )]
        [String] $DefaultFileName = './ticket.txt',
        
        [Parameter( Mandatory=$False )]
        [Alias('a')]
        [Switch] $AllData,
        
        [Parameter( Mandatory=$False )]
        [Alias('e')]
        [Switch] $Edit,
        
        [Parameter( Mandatory=$False )]
        [String] $Editor,
        
        [Parameter( Mandatory=$False )]
        [Int[]] $Done,
        
        [Parameter( Mandatory=$False )]
        [Alias('sp')]
        [Switch] $ShortenProperty,
        
        [Parameter( Mandatory=$False )]
        [Alias('o')]
        [Switch] $AsObject,
        
        [Parameter( Mandatory=$False )]
        [Alias('r')]
        [Switch] $Relax,
        
        [Parameter( Mandatory=$False )]
        [Switch] $Gantt,
        
        [Parameter( Mandatory=$False )]
        [Switch] $GanttNote,
        
        [Parameter( Mandatory=$False )]
        [ValidateSet("daily", "weekly", "monthly", "yearly", "quarterly")]
        [String] $GanttPrint = "daily",
        
        [Parameter( Mandatory=$False )]
        [Int] $GanttFontSize = 12,
        
        [Parameter( Mandatory=$False )]
        [Double] $GanttZoom = 1,
        
        [Parameter( Mandatory=$False )]
        [Int] $GanttAddDays = -3,
        
        [Parameter( Mandatory=$False )]
        [Double] $GanttScale = 1.4,
        
        [Parameter( Mandatory=$False )]
        [String] $GanttDateFormat = 'M/d (ddd)',
        
        [Parameter( Mandatory=$False )]
        [String] $GanttFontName,
        
        [Parameter( Mandatory=$False )]
        [String[]] $Status,
        
        [Parameter( Mandatory=$False, ParameterSetName="Daily" )]
        [Switch] $Daily,
        
        [Parameter( Mandatory=$False, ParameterSetName="Weekly" )]
        [Switch] $Weekly,
        
        [Parameter( Mandatory=$False, ParameterSetName="Monthly" )]
        [Switch] $Monthly,
        
        [Parameter( Mandatory=$False, ParameterSetName="Yearly" )]
        [Switch] $Yearly,
        
        [Parameter( Mandatory=$False )]
        [Switch] $Routine,
        
        [Parameter( Mandatory=$False )]
        [Switch] $NoRoutine,
        
        [Parameter( Mandatory=$False )]
        [Switch] $SkipTest,
        
        [Parameter( Mandatory=$False )]
        [Switch] $NoBackup,
        
        [Parameter( Mandatory=$False )]
        [Alias('d')]
        [Switch] $DeleteTagFromAct,
        
        [Parameter( Mandatory=$False )]
        [Alias('la')]
        [Switch] $LongAct,
        
        [Parameter( Mandatory=$False )]
        [Alias('i')]
        [Alias('ii')]
        [Switch] $InvokeLink,
        
        [Parameter( Mandatory=$False )]
        [Alias('iw')]
        [Alias('App')]
        [String] $InvokeLinkWith,
        
        [Parameter( Mandatory=$False )]
        [Switch] $WhatIf,
        
        [Parameter( Mandatory=$False )]
        [Alias('lsf')]
        [Switch] $lsFile,
        
        [Parameter( Mandatory=$False )]
        [Alias('lsp')]
        [Switch] $lsProperty,
                
        [Parameter( Mandatory=$False )]
        [Alias('lss')]
        [Switch] $lsSection,
        
        [Parameter( Mandatory=$False )]
        [Alias('x')]
        [Switch] $ForceXonCreationDateBeforeToday,

        [Parameter( Mandatory=$False )]
        [Switch] $GetSeries,
        
        [Parameter( Mandatory=$False )]
        [Alias('os')]
        [Switch] $OutputSection,
        
        [Parameter( Mandatory=$False )]
        [Switch] $OffLink,
        
        [Parameter( Mandatory=$False )]
        [Switch] $OffTag,
        
        [Parameter( Mandatory=$False )]
        [Switch] $TagOnly,
        
        [Parameter( Mandatory=$False )]
        [String] $HyphenPlaceHolder = '///@H@y@p@h@e@n@s@I@n@B@r@a@c@k@e@t@///',
        
        [parameter( Mandatory=$False, ValueFromPipeline=$True )]
        [object[]] $InputObject
    )
    # Output Get-Ticket series
    if ( $GetSeries ){
        [String[]] $serNames = @(
            "Get-Ticket",
            "Get-Diary",
            "Get-Book",
            "Get-Recipe",
            "Get-Note"
        )
        [String[]] $serAliases = @(
            "t",
            "d",
            "b",
            "re",
            "n"
        )
        $hash = [ordered] @{}
        for ( $i = 0; $i -lt $serNames.Count; $i++ ){
            $hash["Alias"] = $serAliases[$i]
            $hash["Name"]  = $serNames[$i]
            [pscustomobject] $hash
        }
        return
    }
    # set output property names
    if ( $LongAct ){
        # LongAct: Name in Act
        if ( $ShortenProperty ){
            [String[]] $splatProp = @(
                "Id",
                "Done",
                "Project",
                "ABC",
                "Act",
                "Tag",
                "Link"
            )
        } else {
            [String[]] $splatProp = @(
                "Id",
                "Done",
                "Project",
                "ABC",
                "Act",
                "Tag",
                "Link"
            )
        }
        [String[]] $splatFullProp = @(
            "Id",
            "Done",
            "Project",
            "ABC",
            "Act",
            "Due",
            "Status",
            "Tag",
            "Create",
            "Complete",
            "Remain",
            "Age",
            "Link",
            "Raw",
            "Note"
        )
    } else {
        # ShortAct: separate Act, Name, Tag
        if ( $ShortenProperty ){
            [String[]] $splatProp = @(
                "Id",
                "Done",
                "Project",
                "ABC",
                "Act",
                "Name",
                "Tag",
                "Link"
            )
        } else {
            [String[]] $splatProp = @(
                "Id",
                "Done",
                "Project",
                "ABC",
                "Act",
                "Name",
                "Tag",
                "Link"
            )
        }
        [String[]] $splatFullProp = @(
            "Id",
            "Done",
            "Project",
            "ABC"
            "Act",
            "Name",
            "At",
            "Due",
            "Status",
            "Tag",
            "Create",
            "Complete",
            "Remain",
            "Age",
            "Link",
            "Raw",
            "Note"
        )
    }
    # set opt
    if ( $LongAct ){
        $ShortenAct = $False
    } else {
        $ShortenAct = $True
    }
    if ( $Relax ){
        [Object[]] $relaxAry = @()
        $AsObject = $True
    }
    if ( $AsObject ){
        [Object[]] $objAry = @()
        $AsObject = $True
    }
    # execute -ls
    if ( $lsProperty ){
        $hash = @{}
        foreach ( $item in $splatFullProp ){
            $hash["Property"] = $item
            [pscustomobject] $hash
        }
        #$splatFullProp -join ", "
        return
    }
    if ( $lsFile ){
        [String] $lsFilePath = $DefaultFileName -replace '\.[^\.]+$' , '*'
        Get-ChildItem -Path $lsFilePath -File
        return
    }
    # private functions
    function isBracketClosed ( [String] $line ){
        [Int] $bracketCount = 0
        for ($i = 0; $i -lt $line.Length; $i++){
            switch -Exact ( $line[$i] ){
                '[' { $bracketCount++ }
                ']' { $bracketCount-- }
                default {
                    #pass
                }
            }
        }
        if ( $bracketCount -eq 0 ){
            # bracket is closed
            return $True
        } else {
            # bracket is not closed
            return $False
        }
    }
    function replaceHyphenInBrackets {
        param (
            [String] $line,
            [String] $placeHolder = $HyphenPlaceHolder
        )
        if ( $line -match '\[[^\]]* \-\-' ) {
            # replace hyphens in brackets only at the end of line
            [String] $lineHead    = $line -replace '^(.*)(\[[^\]]* \-\-[^\]]*\])(.*)$', '$1'
            [String] $lineBracket = $line -replace '^(.*)(\[[^\]]* \-\-[^\]]*\])(.*)$', '$2'
            [String] $lineTail    = $line -replace '^(.*)(\[[^\]]* \-\-[^\]]*\])(.*)$', '$3'
            # replace hypen in brackets
            $lineBracket = $lineBracket.Replace( '--', $placeHolder )
            [String] $retLine = $lineHead + $lineBracket + $lineTail
            if ( $retLine -match '\[[^\]]* \-\-' ){
                # recursion
                $retLine = replaceHyphenInBrackets $retLine
            }
            return $retLine
        } else {
            return $line
        }
    }
    function restoreReplacedHyphenInBrackets {
        param (
            [String] $line,
            [String] $placeHolder = $HyphenPlaceHolder
        )
        [String] $retLine = $line.Replace( $placeHolder , '--' )
        return $retLine
    }
    function deleteOptionStrings {
        param (
            [String] $line
        )
        [String] $retLine = $line -replace ' --.*$', ''
        return $retLine
    }
    function getMatchesValue {
        param (
            [String] $line,
            [String] $pattern,
            [Parameter( Mandatory=$False )]
            [String[]] $replaceChar
        )
        $splatting = @{
            Pattern       = $pattern
            CaseSensitive = $False
            Encoding      = "utf8"
            SimpleMatch   = $False
            NotMatch      = $False
            AllMatches    = $True
        }
        [String[]] $retAry = ($line | Select-String @splatting).Matches.Value `
            | ForEach-Object {
                [String] $writeLine = "$_".Trim()
                if ( $replaceChar.Count -gt 0 ){
                    foreach ( $r in $replaceChar ){
                        $writeLine = $writeLine.Replace($r, '')
                        $writeLine = $writeLine.Trim()
                    }
                }
                if ( $writeLine -ne '' ){
                    Write-Output $writeLine
                }
            }
        return $retAry
    }
    function getOptDueDate {
        param ( [String] $line )
        [String] $reg = '^.*\s+due:([-/0-9]{6,10}).*$'
        # Convert date to string
        if ( $line -match $reg ){
            [String] $match = $line -replace $reg, '$1'
            [String] $ret = $( (Get-Date $match).ToString('yyyy-MM-dd') )
        } else {
            $ret = $Null
        }
        return $ret
    }
    function getOptLink {
        param ( [String] $line )
        [String] $reg1 = '^.*\s+link:"([^"]+)".*$'
        [String] $reg2 = '^.*\s+link:([^ ]+).*$'
        # Convert date to string
        if ( $line -match $reg1 ){
            [String] $ret = $line -replace $reg1, '$1'
        } elseif ( $line -match $reg2 ){
            [String] $ret = $line -replace $reg2, '$1'
        } else {
            $ret = $Null
        }
        return $ret
    }
    function getOptStatus {
        param ( [String] $line )
        [String] $reg = '^.*\s+status:([^ ]+).*$'
        if ( $line -match $reg ){
            [String] $match = $line -replace $reg, '$1'
            [String[]] $statAry = $match -split ','
        } else {
            [String[]] $statAry = @($Null)
        }
        return $statAry
    }
    function getOptAge {
        param (
            [String] $From,
            [String] $To
        )
        [Int] $ret = (New-TimeSpan -Start $From -End $To).TotalDays
        return $ret
    }
    function getOptDone {
        param ( [String] $line )
        if ( $line -cmatch '^x ' ){
            [String] $ret = 'x'
        } else {
            [String] $ret = '-'
        }
        return $ret
    }
    function deleteLinkStr {
        param ( [String] $line )
        $line = $line -replace ' link:"[^"]+"', ''
        $line = $line -replace ' link:[^ ]+', ''
        $line = $line.Trim()
        return $line
    }
    function deleteTagStr {
        param ( [String] $line )
        $line = $line -replace ' #[^ ]+', ''
        $line = $line.Trim()
        return $line
    }
    function isLineEmpty ([String] $line ){
        if ( $line -match '^$' ){
            return $True
        } else {
            return $False
        }
    }
    function isLineBeginningWithSharpMark ([String] $line ){
        if ( $line -match '^#+ ' ){
            return $True
        } else {
            return $False
        }
    }
    function isLineBeginningWithSpace ([String] $line ){
        if ( $line -match '^\s' ){
            return $True
        } else {
            return $False
        }
    }
    function removeStringsFromLine {
        param (
            [String] $line,
            [String] $targetStrings
        )
        # escape marks
        [String] $reg = "^" + $targetStrings
        [String] $reg = $reg.Replace('[', '\[')
        [String] $reg = $reg.Replace(']', '\]')
        [String] $reg = $reg.Replace('+', '\+')
        if ( $line -match $reg ){
            $line = $line.Replace("$targetStrings", '').Trim()
        } else {
            $line = $line.Replace(" $targetStrings",  '')
        }
        return $line
    }
    function isStatusContainsRoutine {
        param (
            [String[]] $statusAry,
            [String[]] $optRoutineAry = @("daily", "weekly", "monthly", "yearly", "routine"),
            [String[]] $optStatus = $Status,
            [String] $optParamSetName = $($PsCmdlet.ParameterSetName),
            [Switch] $optRoutine = $Routine
        )
        [String] $routineReg = $optRoutineAry -Join '|'
        [Bool] $statContainsRoutine = $False
        if ( ($optStatus.Count -gt 0) -and ($optParamSetName -ne 'None') ){
            foreach ( $s in $statusAry ){
                if ( $s -match "$($optParamSetName)|$($optStatus -join '|')" ){
                    [Bool] $statContainsRoutine = $True
                }
            }
        } elseif ( ($optStatus.Count -gt 0) ){
            foreach ( $s in $statusAry ){
                if ($s -match "$($optStatus -join '|')"){
                    [Bool] $statContainsRoutine = $True
                }
            }
        } elseif ( $optParamSetName -ne 'None' ){
            foreach ( $s in $statusAry ){
                if ( $s -match "$($optParamSetName)" ){
                    [Bool] $statContainsRoutine = $True
                }
            }
        } elseif ( $optRoutine ){
            foreach ( $s in $statusAry ){
                if ( $s -match $routineReg ){
                    [Bool] $statContainsRoutine = $True
                }
            }
        } else {
            foreach ( $s in $statusAry ){
                if ( $s -match $routineReg ){
                    [Bool] $statContainsRoutine = $True
                }
            }
        }
        return $statContainsRoutine
    }
    function outputHashAsPSCustomObject {
        param (
            [System.Collections.Specialized.OrderedDictionary] $hash,
            [System.Collections.Hashtable] $splattingSelect
        )
        [pscustomobject] $hash `
            | Select-Object @splattingSelect
    }
    function getDefaultFileName {
        param (
            [String] $optDefaultFileName = $DefaultFileName
        )
        [String] $suf = ""
        [String] $fileNameLeaf    = $optDefaultFileName -replace '\.[^\.]+$' ,"${suf}"
        [String] $txtFileSingular = $optDefaultFileName -replace '\.[^\.]+$' ,"${suf}.txt"
        [String] $mdFileSingular  = $optDefaultFileName -replace '\.[^\.]+$' ,"${suf}.md"
        [String] $txtFilePlural   = $optDefaultFileName -replace '\.[^\.]+$' ,"s${suf}.txt"
        [String] $mdFilePlural    = $optDefaultFileName -replace '\.[^\.]+$' ,"s${suf}.md"
        [bool] $isTxtFileSingularExists = Test-Path -LiteralPath $txtFileSingular
        [bool] $isTxtFilePluralExists   = Test-Path -LiteralPath $txtFilePlural
        [bool] $isMdFileSingularExists  = Test-Path -LiteralPath $mdFileSingular
        [bool] $isMdFilePluralExists    = Test-Path -LiteralPath $mdFilePlural
        if ( $isTxtFileSingularExists ){
            [String] $inputFilePath = $txtFileSingular
        } elseif ( $isMdFileSingularExists ){
            [String] $inputFilePath = $mdFileSingular
        } elseif ( $isTxtFilePluralExists ){
            [String] $inputFilePath = $txtFilePlural
        } elseif ( $isMdFilePluralExists ){
            [String] $inputFilePath = $mdFilePlural
        } else {
            # -not $isTxtFileExists -and -not $isMdFileExists
            Write-Error "file: '$fileNameLeaf' is not exists." -ErrorAction Stop
            return
        }
        return $inputFilePath
    }
    function isLinkHttp ( [string] $line ){
        [bool] $httpFlag = $False
        if ( $line -match '^https*:' ){ $httpFlag = $True }
        if ( $line -match '^www\.' )  { $httpFlag = $True }
        return $httpFlag
    }
    function isLinkAlive ( [string] $uri ){
        return $True

        #$origErrActPref = $ErrorActionPreference
        #try {
        #    $ErrorActionPreference = "SilentlyContinue"
        #    $Response = Invoke-WebRequest -Uri "$uri"
        #    $ErrorActionPreference = $origErrActPref
        #    # This will only execute if the Invoke-WebRequest is successful.
        #    $StatusCode = $Response.StatusCode
        #    return $True
        #} catch {
        #    $StatusCode = $_.Exception.Response.StatusCode.value__
        #    return $False
        #} finally {
        #    $ErrorActionPreference = $origErrActPref
        #}
    }
    # Add new ticket
    if ( $Add -or $AddTail -or $AddEmpty -or $AddTailEmpty -or $Edit -or $Editor ){
        [String] $nowDateStr =$((Get-Date).ToString('yyyy-MM-dd'))
        if ( $Add ){
            [String] $addLine = $Add
            if ( $addLine -cmatch '^(\([A-Z]\))(.*)$' ){
                # if priority is specified
                [String] $leftStr  = $addLine -creplace '^(\([A-Z]\))(.*)$', '$1'
                [String] $rightStr = $addLine -creplace '^(\([A-Z]\))(.*)$', '$2'
                [String] $newLine = $leftStr + " " + $nowDateStr + $rightStr
            } else {
                [String] $newLine = $nowDateStr + " " + $addLine
            }
        } elseif ( $AddTail ){
            [String] $addLine = $AddTail
            if ( $addLine -cmatch '^(\([A-Z]\))(.*)$' ){
                # if priority is specified
                [String] $leftStr  = $addLine -creplace '^(\([A-Z]\))(.*)$', '$1'
                [String] $rightStr = $addLine -creplace '^(\([A-Z]\))(.*)$', '$2'
                [String] $newLine = $leftStr + " " + $nowDateStr + $rightStr
            } else {
                [String] $newLine = $nowDateStr + " " + $addLine
            }
        } elseif ( $AddEmpty -or $AddTailEmpty ){
            [String] $newLine = $nowDateStr + " " + "(B)"
        }
        # Add Create date string end of newline
        if ( $newLine -cnotmatch ' due:[0-9]+' ){
            $newLine = $newLine + ' due:' + $((Get-Date).AddDays(7).ToString('yyyy-MM-dd'))
        }
        # overwrite file
        if ( $File ){
            [String] $inputFilePath = $File
        } elseif ( $input.Count -gt 0 ) {
            # read from stdin
            Write-Error "-Add could not be used for pipeline input." -ErrorAction Stop
        } else {
            # read from default file
            [String] $inputFilePath = getDefaultFileName $DefaultFileName
        }
        # test path
        if ( (Get-ChildItem -Path $inputFilePath).Count -ne 1 ){
            Write-Error "Add/Edit option is only available for a single text file." -ErrorAction Stop
        }
        if ( $Add -or $AddEmpty -or $AddTail -or $AddTailEmpty ){
            # Create backup
            if ( -not $NoBackup ){
                [String] $outDir = Get-Item -LiteralPath $inputFilePath | Split-Path -Parent
                [String] $outFileName = Get-Item -LiteralPath $inputFilePath | Split-Path -Leaf
                [String] $outFileName = $outFileName + '.bk'
                [String] $outPath = Join-Path -Path $outDir -ChildPath $outFileName
                Copy-Item -LiteralPath $inputFilePath -Destination $outPath -Force
            }
            if ( $Add -or $AddEmpty ){
                (Get-Content -LiteralPath $inputFilePath -Encoding utf8 `
                    | ForEach-Object `
                        -Begin { $newLine } `
                        -Process { $_ } ) `
                    | Set-Content -LiteralPath $inputFilePath -Encoding utf8
            } elseif ( $AddTail -or $AddTailEmpty ){
                Add-Content `
                    -LiteralPath $inputFilePath `
                    -Value $newLine `
                    -Encoding utf8
            }
        }
        # run editor
        if ( $Edit -or $Editor -or $AddEmpty ){
            if ( $Editor ){
                [string] $com = $Editor
                [string] $com = "$com ""$inputFilePath"""
                Invoke-Expression -Command $com -ErrorAction Stop
            } else {
                Invoke-Item -Path $inputFilePath
            }
            return
        }
        # Output Raw data
        Get-Ticket -File $inputFilePath
        return
    }
    # parse tickets
    # splatting for Select-String
    $splatting = @{
        Encoding = "utf8"
    }
    if ( $lsSection ){
        # filter only section written in markdown format
        $splatting.Set_Item('Pattern', '^#+ ..*')
        $splatting.Set_Item('NotMatch', $False)
        $splatting.Set_Item('SimpleMatch', $False)
    } elseif ( $Done.Count -gt 0){
        # output all items other than those starting with a space
        $splatting.Set_Item('Pattern', '^')
        $splatting.Set_Item('NotMatch', $False)
        $splatting.Set_Item('SimpleMatch', $False)
    } elseif ( $AllData -and ($Id.Count -gt 0) ){
        # output all items other than those starting with a space
        $splatting.Set_Item('Pattern', '^.')
        $splatting.Set_Item('NotMatch', $False)
        $splatting.Set_Item('SimpleMatch', $False)
    } elseif ( $AllData ){
        # output all items other than those starting with a space
        $splatting.Set_Item('Pattern', '^\s')
        $splatting.Set_Item('NotMatch', $True)
        $splatting.Set_Item('SimpleMatch', $False)
    } elseif ( $Id.Count -gt 0 ){
        # output all items include lines starting with space
        $splatting.Set_Item('Pattern', '^.')
        $splatting.Set_Item('NotMatch', $False)
        $splatting.Set_Item('SimpleMatch', $False)
    } else {
        # output only active items
        $splatting.Set_Item('Pattern', '^x |^\s')
        $splatting.Set_Item('NotMatch', $True)
        $splatting.Set_Item('SimpleMatch', $False)
        $splatting.Set_Item('CaseSensitive', $True)
    }
    if ($PSVersionTable.PSVersion.Major -ge 7){
        # -NoEmphasis parameter was introduced in PowerShell 7
        $splatting.Set_Item('NoEmphasis', $True)
    }
    # main
    ## private function
    function getCreationDateAndCompletedDate {
        param (
            [String] $line
        )
        # pattern: x (A) <complete> <create> ticket
        [String] $reg = '^x \([A-Z]\) ([-/0-9]{6,10}) ([-/0-9]{6,10}) .*$'
        if ( $line -cmatch $reg ){
            [String] $doneStr = 'x'
            [String] $completeDate = $line -creplace $reg, '$1'
            [String] $createDate   = $line -creplace $reg, '$2'
            [String[]] $retAry = @($doneStr, $createDate, $completeDate)
            return $retAry
        }
        # pattern: x (A) <complete> ticket
        [String] $reg = '^x \([A-Z]\) ([-/0-9]{6,10}) .*$'
        if ( $line -cmatch $reg ){
            [String] $doneStr = 'x'
            [String] $completeDate = $line -creplace $reg, '$1'
            [String] $createDate   = $Null
            [String[]] $retAry = @($doneStr, $createDate, $completeDate)
            return $retAry
        }
        # pattern: x <complete> <create> ticket
        [String] $reg = '^x ([-/0-9]{6,10}) ([-/0-9]{6,10}) .*$'
        if ( $line -cmatch $reg ){
            [String] $doneStr = 'x'
            [String] $completeDate = $line -creplace $reg, '$1'
            [String] $createDate   = $line -creplace $reg, '$2'
            [String[]] $retAry = @($doneStr, $createDate, $completeDate)
            return $retAry
        }
        # pattern: x <complete> ticket
        [String] $reg = '^x ([-/0-9]{6,10}) .*$'
        if ( $line -cmatch $reg ){
            [String] $doneStr = 'x'
            [String] $completeDate = $line -creplace $reg, '$1'
            [String] $createDate   = $Null
            [String[]] $retAry = @($doneStr, $createDate, $completeDate)
            return $retAry
        }
        # pattern: (A) <complete> <create> ticket
        [String] $reg = '^\([A-Z]\) ([-/0-9]{6,10}) ([-/0-9]{6,10}) .*$'
        if ( $line -cmatch $reg ){
            [String] $doneStr = 'x'
            [String] $completeDate = $line -creplace $reg, '$1'
            [String] $createDate   = $line -creplace $reg, '$2'
            [String[]] $retAry = @($doneStr, $createDate, $completeDate)
            return $retAry
        }
        # pattern: (A) <create> ticket
        [String] $reg = '^\([A-Z]\) ([-/0-9]{6,10}) .*$'
        if ( $line -cmatch $reg ){
            [String] $doneStr = '-'
            [String] $completeDate = $Null
            [String] $createDate   = $line -creplace $reg, '$1'
            [String[]] $retAry = @($doneStr, $createDate, $completeDate)
            return $retAry
        }
        # pattern: <create> <cpmplete> ticket
        [String] $reg = '^([-/0-9]{6,10}) ([-/0-9]{6,10}) .*$'
        if ( $line -cmatch $reg ){
            [String] $doneStr = '-'
            [String] $completeDate = $line -creplace $reg, '$1'
            [String] $createDate   = $line -creplace $reg, '$2'
            [String[]] $retAry = @($doneStr, $createDate, $completeDate)
            return $retAry
        }
        # pattern: x <complete> ticket
        [String] $reg = '^([-/0-9]{6,10}) .*$'
        if ( $line -cmatch $reg ){
            [String] $doneStr = '-'
            [String] $completeDate = $Null
            [String] $createDate   = $line -creplace $reg, '$1'
            [String[]] $retAry = @($doneStr, $createDate, $completeDate)
            return $retAry
        }
        [String] $reg = '^x .*$'
        if ( $line -cmatch $reg ){
            [String] $doneStr = 'x'
            [String] $completeDate = $Null
            [String] $createDate   = $Null
            [String[]] $retAry = @($doneStr, $createDate, $completeDate)
            return $retAry
        }
        if ( $True ){
            [String] $doneStr = '-'
            [String] $completeDate = $Null
            [String] $createDate   = $Null
            [String[]] $retAry = @($doneStr, $createDate, $completeDate)
            return $retAry
        }
    }
    function addXonCreationDateBeforeToday {
        param (
            [String] $line
        )
        [String] $doneStr = 'x'
        [String] $strToday = (Get-Date).ToString('yyyy-MM-dd')
        # pattern: (A) <date>
        [String] $reg = '^\([A-Z]\) ([-/0-9]{6,10}).*$'
        if ( $line -cmatch $reg ){
            [datetime] $dateCreate = Get-Date -Date $($line -creplace $reg, '$1')
            [String] $strCreate = $dateCreate.ToString('yyyy-MM-dd')
            if ( $strCreate -eq $strToday ){
                return $line
            } elseif ( $strCreate -gt $strToday ){
                return $line
            } else {
                # put dune mark at beginning of the line
                [String] $writeLine = "$doneStr $line"
                return $writeLine
            }
        }
        # pattern: <date>
        [String] $reg = '^([-/0-9]{6,10}).*$'
        if ( $line -cmatch $reg ){
            [datetime] $dateCreate = Get-Date -Date $($line -creplace $reg, '$1')
            [String] $strCreate = $dateCreate.ToString('yyyy-MM-dd')
            if ( $strCreate -eq $strToday ){
                return $line
            } elseif ( $strCreate -gt $strToday ){
                return $line
            } else {
                # put dune mark at beginning of the line
                [String] $writeLine = "$doneStr $line"
                return $writeLine
            }
        }
    }
    function invokeLinkStr {
        param (
            [String] $link
        )
        if ( $link -eq '' ){ return }
        if ( isLinkHttp $link ){
            if ( isLinkAlive $link ){
                # invoke-link
                if ( $InvokeLinkWith ){
                    [string] $com = "$InvokeLinkWith ""$link"""
                } else {
                    [string] $com = "Start-Process -FilePath ""$link"""
                }
                Write-Debug $com
                Invoke-Expression -Command $com -ErrorAction Stop
            } else {
                Write-Error "broken link: '$link'" -ErrorAction Stop
            }
        } else {
            if ( Test-Path -LiteralPath $link){
                # invoke-link
                if ( $InvokeLinkWith ){
                    [string] $com = "$InvokeLinkWith ""$link"""
                } else {
                    [string] $com = "Invoke-Item -Path ""$link"""
                }
                Write-Debug $com
                Invoke-Expression -Command $com -ErrorAction Stop
            } else {
                Write-Error "broken link: '$link'" -ErrorAction Stop
            }
        }
    }
    ## read line
    if ( $File ){
        # test path
        if ( -not (Test-Path -Path $File) ){
            Write-Error "file: $FIle is not exists." -ErrorAction Stop
        }
        # raed from specified file
        [String] $iFileName = $File
        $splatting.Set_Item('Path', (Get-ChildItem -Path $iFileName))
        [String[]] $readLineAry = (Select-String @splatting).Line
    } elseif ( $input.Count -gt 0 ) {
        # read from stdin
        [String[]] $readLineAry = ($input | Select-String @splatting).Line
    } else{
        # read from default file
        [String] $iFileName = getDefaultFileName $DefaultFileName
        $splatting.Set_Item('Path', (Get-ChildItem -Path $iFileName))
        [String[]] $readLineAry = (Select-String @splatting).Line
    }
    # lsSection option
    if ( $lsSection ){
        Write-Output $readLineAry
        return
    }
    # parse each line
    # init var
    [String] $beforeProjectName = ''
    [Int] $idCounter = 0
    if ( $Id.Count -gt 0){
        # init variables used in view mode
        [Int] $maxViewCount = ( $Id | Measure-Object -Maximum ).Maximum
        Write-Debug "Max View Int: $maxViewCount"
        [Bool] $isViewId = $False
        [Bool] $parseLine = $False
    }
    if ( $Done.Count -gt 0 ){
        # add done mark
        # test path
        if ( [String] $iFileName -eq ''){
            Write-Error "Done option is only available for a single text file." -ErrorAction Stop
        } elseif ( (Get-ChildItem -Path $iFileName).Count -ne 1 ){
            Write-Error "Done option is only available for a single text file." -ErrorAction Stop
        }
        # Create backup
        if ( -not $NoBackup ){
            [String] $outDir = Get-Item -LiteralPath $iFileName | Split-Path -Parent
            [String] $outFileName = Get-Item -LiteralPath $iFileName | Split-Path -Leaf
            [String] $outFileName = $outFileName + '.bk'
            [String] $outPath = Join-Path -Path $outDir -ChildPath $outFileName
            Copy-Item -LiteralPath $iFileName -Destination $outPath -Force
        }
        ## pricate function
        function addDoneBeginningWithLine {
            param (
                [String] $line
            )
            [String] $ret = $line
            ## Add done mark
            if ( $ret -cnotmatch '^x ' ){
                $ret = $ret -creplace '^', 'x '
            }
            ## Add complete date
            [String] $today = (Get-Date).ToString('yyyy-MM-dd')
            if ( $ret -cmatch '^x \([A-Z]\) ([-/0-9]{6,10}) ([-/0-9]{6,10}) (.*)$'){
                # delete priority
                $ret = $ret -creplace '^x \([A-Z]\) ([-/0-9]{6,10}) ([-/0-9]{6,10}) (.*)$', "x `$1 `$2 `$3"
            } elseif ( $ret -cmatch '^x \([A-Z]\) ([-/0-9]{6,10}) (.*)$'){
                # Add complete date
                $ret = $ret -creplace '^x \([A-Z]\) ([-/0-9]{6,10}) (.*)$', "x $today `$1 `$2"
            } elseif ( $ret -cmatch '^x \([A-Z]\) (.*)$'){
                # Add complete date
                $ret = $ret -creplace '^x \([A-Z]\) (.*)$', "x $today `$1"
            } elseif ( $ret -cmatch '^x ([-/0-9]{6,10}) ([-/0-9]{6,10}) (.*)$'){
                # pass
            } elseif ( $ret -cmatch '^x ([-/0-9]{6,10}) (.*)$'){
                # Add complete date
                $ret = $ret -creplace '^x ([-/0-9]{6,10}) (.*)$', "x $today `$1 `$2"
            } elseif ( $ret -cmatch '^x (.*)$'){
                # Add complete date
                $ret = $ret -creplace '^x (.*)$', "x $today `$1"
            }
            return $ret
        }
        # put done mark and set content
        [String[]] $outputAry = foreach ( $line in $readLineAry ){
            # get sub line that starting with space
            if ( isLineEmpty $line ){
                Write-Output $line
                continue
            } elseif ( isLineBeginningWithSharpMark $line ){
                Write-Output $line
                continue
            } elseif ( isLineBeginningWithSpace $line ){
                Write-Output $line
                continue
            } else {
                if ( $AllData ){
                    $idCounter++
                    if ( $Done.Contains($idCounter) ){
                        # match id = done
                        addDoneBeginningWithLine $line
                        if ( -not $WhatIf ){
                            Write-Host "$line" -ForegroundColor green
                        }
                    } else {
                        # not match id
                        Write-Output $line
                    }
                } else {
                    if ( $line -cnotmatch '^x '){
                        $idCounter++
                        if ( $Done.Contains($idCounter) ){
                            # match id = done
                            addDoneBeginningWithLine $line
                            if ( -not $WhatIf ){
                                Write-Host "$line" -ForegroundColor green
                            }
                        } else {
                            # not match id
                            Write-Output $line
                        }
                    } else {
                        Write-Output $line
                    }
                }
                continue
            }
        }
        if ( $WhatIf){
            $outputAry
        } else {
            $outputAry | Set-Content -LiteralPath $iFileName -Encoding utf8
        }
        return
    }
    # parse data
    if ( $Gantt -or $GanttNote ){
        [Bool] $isGanttItemExists = $False
        if ( $Gantt ){
            $ganttFontColor = "black"
        } elseif ( $GanttNote ){
            $ganttFontColor = "transparent"
        }
        Write-Output "@startgantt"
        Write-Output ""
        Write-Output "Project starts the $((Get-Date).AddDays($GanttAddDays).ToString('yyyy-MM-dd'))"
        Write-Output "$((Get-Date).ToString('yyyy-MM-dd')) is colored LightBlue"
        Write-Output "saturday are closed"
        Write-Output "sunday are closed"
        Write-Output "printscale $GanttPrint zoom $GanttZoom"
        Write-Output "scale $GanttScale"
        Write-Output ""
        Write-Output "<style>"
        Write-Output "ganttDiagram {"
        Write-Output "  task {"
        Write-Output "    FontColor $ganttFontColor"
        if ( $GanttFontName ){
        Write-Output "    FontName ""$GanttFontName"""
        }
        Write-Output "    FontSize $GanttFontSize"
        Write-Output "  }"
        Write-Output "  note {"
        if ( $GanttFontName ){
        Write-Output "    FontName ""$GanttFontName"""
        }
        Write-Output "    FontSize $GanttFontSize"
        Write-Output "  }"
        Write-Output "  separator {"
        if ( $GanttFontName ){
        Write-Output "    FontName ""$GanttFontName"""
        }
        Write-Output "    FontSize $($GanttFontSize - 2)"
        Write-Output "  }"
        Write-Output "}"
        Write-Output "</style>"
        Write-Output ""
    }
    foreach ( $line in $readLineAry ){
        # test
        if ( -not $SkipTest){
            if ( -not ( isBracketClosed $line ) ){
                Write-Error "Detect unclosed parentheses: $line" -ErrorAction Stop
            }
        }
        # skip blank line
        if ( isLineEmpty $line ){
            continue
        }
        # skip line beggining with "#" and space
        if ( isLineBeginningWithSharpMark $line ){
            if ( -not $OutputSection ){
                continue
            }
        }
        if ( $ForceXonCreationDateBeforeToday -and ( -not $AllData )){
            $line = addXonCreationDateBeforeToday $line
        }
        # view mode
        if ( ($Id.Count -gt 0) -and (-not $Gantt) -and (-not $GanttNote) -and (-not $AsObject) ){
            # get sub line that starting with space
            Write-Debug "id-view: $idCounter $line idview: $isViewId parseLine: $parseLine"
            if ( $isViewId -and $parseLine -and (isLineBeginningWithSpace $line) ){
                if ( $InvokeLink -or $InvokeLinkWith ){
                    if ($line -match '^\s+link:\s*'){
                        [String] $link = $line
                        Write-Output $line
                        [String] $link = $link -replace '^\s+link:\s*', ''
                        [String] $link = $link -replace('^"', '')
                        [String] $link = $link -replace('"$', '')
                        invokeLinkStr $link
                    }
                } else {
                    Write-Output $line
                }
                continue                  
            }
            # set id
            if ( -not (isLineBeginningWithSpace $line) ){
                [Bool] $isViewId  = $False
                [Bool] $parseLine = $False
                if ( $AllData ){
                    if ( $line -match $Where ) {
                        $idCounter++
                        $parseLine = $True
                    } else {
                        continue
                    }
                } else {
                    if ( $line -match $Where) {
                        if ( $line -cnotmatch '^x ' ){
                            $idCounter++
                            $parseLine = $True
                        } else {
                            # pass
                            continue
                        }
                    } else {
                        # pass
                        continue
                    }
                }
                # get status
                [String[]] $statAry = getOptStatus $line
                ## filter status array
                if ( ($Status.Count -gt 0) -or $Routine -or $NoRoutine ){
                    [Bool] $statContainsRoutine = isStatusContainsRoutine -statusAry $statAry
                    if ( $NoRoutine ){
                        if ( $statContainsRoutine ){
                            $idCounter--
                            $parseLine = $False
                            continue
                        } else {
                            # pass
                        }
                    } else {
                        if ( $statContainsRoutine ){
                            # pass
                        } else {
                            $idCounter--
                            $parseLine = $False
                            continue
                        }
                    }
                }
                Write-Debug "Id: $idCounter"
            }
            if ( $idCounter -gt $maxViewCount ){
                # ends when id greater than maximum view count
                return
            }
            if ( $Id.Contains($idCounter) ){
                if ( $parseLine ){
                    [Bool] $isViewId = $True
                    if ( $TagOnly ){
                        [String[]] $tagAry = getMatchesValue $line ' #[^ ]+|^#[^ ]+'
                        if ( $tagAry.Count -gt 0 ){
                            Write-Output $tagAry
                        }
                        continue
                    }
                    if ( $InvokeLink -or $InvokeLinkWith ){
                        if ( $line -match 'link:..*'){
                            $linkStr = getOptLink $line
                            #Write-Output " link: $linkStr"
                            invokeLinkStr $linkStr
                        }
                    }
                    if ( $OffLink ){
                        $line = deleteLinkStr $line
                    }
                    if ( $OffTag ){
                        $line = deleteTagStr $line
                    }
                    Write-Output $line
                } else {
                    [Bool] $isViewId = $False
                }
            }
            continue
        } # end of view mode
        #
        # main
        #
        # set id
        if ( ($Id.Count -eq 0) -and (isLineBeginningWithSpace $line) ){
            continue
        }
        if ( $AllData ){
            if ( $line -match $Where ){
                # pass
            } else {
                continue
            }
        } else {
            if ( ($line -cnotmatch '^x ') -and ( $line -match $Where) ){
                # pass
            } else {
                continue
            }
        }
        $idCounter++
        # test id if -id option specified
        if ( $Id.Count -gt 0 ){
            if ( $Id.Contains($idCounter) ){
                #pass
            } else {
                continue
            }
        }
        # get raw line
        [String] $rawLine = $line
        Write-Debug "Raw: $rawLine"
        # get done
        [String] $doneStr = getOptDone $line
        [String] $doneStr, $createDate, $completeDate = getCreationDateAndCompletedDate $line
        Write-Debug "done: $doneStr"
        Write-Debug "CreateDate: $createDate"
        Write-Debug "CompleteDate: $completeDate"
        # replace brackets
        [String] $line = replaceHyphenInBrackets $line
        # get AtMark
        [String[]] $AtMarkAry = getMatchesValue $line ' @[^ ]+|^@[^ ]+'
        [String] $AtMarkStr = $AtMarkAry -join ', '
        Write-Debug "At: $AtMarkStr"
        # get tag
        [String[]] $tagAry = getMatchesValue $line ' #[^ ]+|^#[^ ]+'
        [String] $tagStr = $tagAry -join ', '
        Write-Debug "Tag: $tagStr"
        # get due date
        $dueDate = getOptDueDate $line
        ## delete due date
        $line = $line -replace ' due:([-/0-9]{6,10})', ''
        Write-Debug "Due: $dueDate"
        # get link
        $linkStr = getOptLink $line
        ## delete link
        $line = deleteLinkStr $line
        Write-Debug "Link: $linkStr"
        # get status
        [String[]] $statAry = getOptStatus $line
        ## filter status array
        if ( ($Status.Count -gt 0) -or $Routine -or $NoRoutine ){
            [Bool] $statContainsRoutine = isStatusContainsRoutine -statusAry $statAry
            if ( $NoRoutine ){
                if ( $statContainsRoutine ){
                    $idCounter--
                    continue
                } else {
                    # pass
                }
            } else {
                if ( $statContainsRoutine ){
                    # pass
                } else {
                    $idCounter--
                    continue
                }
            }
        }
        ## delete status
        [String] $statStr = $statAry -join ', '
        $line = $line -replace ' status:[^ ]+', ''
        Write-Debug "Status: $statStr"
        # calc days
        [String] $today = (Get-Date).ToString('yyyy-MM-dd')
        ## get Age
        if ( $createDate -ne '' ){
            [Int] $Age = getOptAge $createDate $today
        } else {
            $Age = $Null
        }
        Write-Debug "Age: $Age"
        ## get remain days
        if ( $doneStr -ceq 'x' ){
            # completed
            [Int] $remainDays = $Null
        } elseif ( $dueDate -ne $Null ){
            [Int] $remainDays = getOptAge $today $dueDate
        } elseif ( $completeDate -ne $Null ){
            [Int] $remainDays = $Null
        } else {
            [Int] $remainDays = $Null
        }
        Write-Debug "Remain: $remainDays"
        # get project
        [String[]] $projectAry = getMatchesValue $line ' \+[^ ]+|^\+[^ ]+'
        [String] $projectStr = $projectAry -join ', '
        Write-Debug "project: $projectStr"
        # get name
        ## delete option block before get name
        $line = deleteOptionStrings $line
        [String[]] $nameAry = getMatchesValue $line ' \[[^\]]*\]|^\[[^\]]*\]'
        [String] $nameStr = restoreReplacedHyphenInBrackets $($nameAry -join ', ')
        Write-Debug "name: $($nameAry -join ', ')"
        # Delete project, tag, name from line
        if ( $DeleteTagFromAct -or $ShortenAct -or $Gantt -or $GanttNote ){
            if ( $projectAry.Count -gt 0 ){
                foreach ( $item in $projectAry ){
                    $line = removeStringsFromLine -line $line -targetStrings $item
                }
            }
            if ( $nameAry.Count -gt 0 ){
                foreach ( $item in $nameAry ){
                    $line = removeStringsFromLine -line $line -targetStrings $item
                }
            }
            if ( $AtMarkAry.Count -gt 0 ){
                foreach ( $item in $AtMarkAry ){
                    $line = removeStringsFromLine -line $line -targetStrings $item
                }
            }
            if ( $tagAry.Count -gt 0 ){
                foreach ( $item in $tagAry ){
                    $line = removeStringsFromLine -line $line -targetStrings $item
                }
            }
        }
        ## restore replaced hyphen
        $line = restoreReplacedHyphenInBrackets $line
        Write-Debug "line: $line"
        # get act (before delete option block)
        [String] $actStr = $line -creplace '^(x|\-) ', ''
        if ( $actStr -cmatch '^\([A-Z]\) ..*$'){
            [String] $priorityStr = $actStr -replace '^(\([A-Z]\)) (..*)$', '$1'
            [String] $actStr      = $actStr -replace '^(\([A-Z]\)) (..*)$', '$2'
        } else {
            [String] $priorityStr = ''
        }
        
        Write-Debug "act: $actStr"
        # set hash
        [System.Collections.Specialized.OrderedDictionary] $hash = @{}
        if ( $True ){
            $hash["Id"]      = $idCounter
            $hash["Done"]    = $doneStr.Trim()
            $hash["Project"] = $projectStr.Trim()
            $hash["ABC"]     = $priorityStr.Trim()
            $hash["Act"]     = $actStr.Trim()
            $hash["Name"]    = $nameStr.Trim()
            $hash["At"]      = $AtMarkStr.Trim()
            $hash["Due"]     = $dueDate
            $hash["Status"]  = $statStr.Trim()
            #$hash["Tag"]     = $tagStr.Trim()
            $hash["Tag"]     = $tagAry
            $hash["Link"]    = $linkStr
        }
        if ( $True ){
            $hash["Create"]   = $createDate
            $hash["Complete"] = $completeDate
            $hash["Remain"]   = $remainDays
            $hash["Age"]      = $Age
            $hash["Raw"]      = $rawLine.Trim()
            $hash["Note"]     = $Null
        }
        ## output as raw text
        if ( $TagOnly ){
            if ( $tagAry.Count -gt 0 ){
                Write-Output $tagAry
            }
            continue
        }
        if ( $AsObject -or $Gantt -or $GanttNote ){
            #pass
        } else {
            # raw output 
            [String] $outputStr = $hash["Raw"]
            if ( $OffLink ){
                [String] $outputStr = deleteLinkStr $outputStr
            }
            if ( $OffTag ){
                [String] $outputStr = deleteTagStr $outputStr
            }
            [String] $outputStr = "$idCounter $outputStr"
            Write-Output $outputStr
            continue
        }
        # output as ganttchart in plantUML format
        if ( $Gantt -or $GanttNote ){
            if ( $rawLine -notmatch $Where ){
                continue
            }
            if ( $hash["Create"] -eq $Null){
                Write-Error "Create Date is not set: $($hash["Raw"])" -ErrorAction Stop
            }
            if ( $hash["Due"] -eq $Null){
                Write-Error "Due Date is not set: $($hash["Raw"])" -ErrorAction Stop
            }
            #[Double] $dblSpanDays = (New-TimeSpan -Start (Get-Date $hash["Create"]) -End (Get-Date $hash["Due"])).TotalDays
            #[Int] $intSpanDays = [math]::Ceiling($dblSpanDays)
            [Double] $dblRemainDays = (New-TimeSpan -Start (Get-Date) -End (Get-Date $hash["Due"])).TotalDays
            [Int] $intRemainDays = [math]::Ceiling($dblRemainDays)
            [String] $actLine = $hash["Act"]
            $actLine = $actLine -creplace '^\([A-Z]\) ', ''
            $actLine = $actLine -creplace '^([-/0-9]{6,10}) ', ''
            $actLine = $actLine -creplace '^([-/0-9]{6,10}) ', ''
            $nameLine = $($hash["Name"]).Trim()
            #$nameLine = $nameLine.Replace(', ', ',')
            if ($hash["Project"] -ne '' -and $hash["Project"] -ne $beforeProjectName){
                Write-Output "-- $($hash["Project"]) --"
                [String] $beforeProjectName = $hash["Project"]
                Write-Output ""
            }
            if ( $GanttNote ){
                if ( $hash["At"] -ne '' ){
                    $actLine = "[$actLine] on {$($hash['At'])}" -replace '\s+@', ' @'
                } else {
                    $actLine = "[$actLine]"
                }
            } else {
                if ( $hash["At"] -ne '' ){
                    $actLine = "[$actLine $nameLine] on {$($hash['At'])}" -replace '\s+@', ' @'
                } else {
                    $actLine = "[$actLine $nameLine]".Trim()
                }
            }
            Write-Output "$actLine starts $($hash["Create"]) and ends $($hash["Due"])"
            if ( $GanttNote ){
                if ( $($nameLine + $hash["Project"]) -ne ''){
                    Write-Output ""
                    Write-Output "note bottom"
                    Write-Output "$((Get-Date $createDate).ToString($GanttDateFormat)) to $((Get-Date $dueDate).ToString($GanttDateFormat)) rem $intRemainDays d"
                    #Write-Output ""
                    Write-Output "  - $actLine"
                    if ( $nameLine -ne ''){
                    Write-Output "  - $nameLine"
                    }
                    Write-Output "end note"
                }
            }
            Write-Output ""
            [Bool] $isGanttItemExists = $True
            continue
        }
        # output as object
        $splattingSelect = @{}
        if ( $Plus.Count -gt 0 ){
            [String[]] $splatPropAry = $splatProp + $Plus
            $splattingSelect.Set_Item("Property", $splatPropAry)
        } elseif ( $AllProperty ){
            $splattingSelect.Set_Item("Property", @('*'))
        } else {
            $splattingSelect.Set_Item("Property", $splatProp)
        }
        Write-Debug "Status searchword: $($PsCmdlet.ParameterSetName)"
        Write-Debug "Status searchword: $($Status -join '|')"
        [pscustomobject] $outputObj = outputHashAsPSCustomObject $hash $splattingSelect
        if ( $Relax ){
            $relaxAry += $outputObj
        } else {
            $objAry += $outputObj
        }
        continue
    }
    if ( $Gantt -or $GanttNote ){
        if ( -not $isGanttItemExists ){
            Write-Error "No item matched." -ErrorAction Stop
        }
        Write-Output "@endgantt"
        return
    }
    if ( $AsObject -and $objAry.Count -gt 0 ){
        Write-Output $objAry
        if ( $Id.Count -gt 0){
            if ( $InvokeLink -or $InvokeLinkWith ){
                invokeLinkStr "$($hash["Link"])"
            }
        }
        return
    }
    if ( $Relax -and $relaxAry.Count -gt 0 ){
        Write-Output $relaxAry | Format-Table
        if ( $Id.Count -gt 0){
            if ( $InvokeLink -or $InvokeLinkWith ){
                invokeLinkStr "$($hash["Link"])"
            }
        }
        return
    }
}
# set alias
[String] $tmpAliasName = "t"
[String] $tmpCmdName   = "Get-Ticket"
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

