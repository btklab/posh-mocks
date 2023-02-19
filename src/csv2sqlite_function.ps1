<#
.SYNOPSIS
    csv2sqlite - Apply sqlite-sql to csv files

    Usage:
        csv2sqlite csv,csv,... -q "<sqlstring>"
        csv2sqlite csv,csv,... -ReadFile <sqlfile>
        "<sqlstring>" | csv2sqlite csv,csv,...
        cat <sqlfile> | csv2sqlite csv,csv,...

        csv2sqlite db -q "<sqlstring>"
        csv2sqlite db -ReadFile <sqlfile>
        "<sqlstring>" | csv2sqlite db
        cat <sqlfile> | csv2sqlite db

    Dependencies:
        sqlite3 <https://www.sqlite.org/index.html>
    
    If csv file is specified, the csv file treated as DB name.

    Whether the input format is CSV or other is
    determined by the input file extension.

    Multiple CSV files can be specified by separating
    with commas.

    Multiple tables can be joined using NATURAL JOIN statement, etc...

    -Coms '<com>','<com>',... Commands can also be specified manually.
        e.g. -Coms '.tables','.show','.mode markdown'

    -ComsBefore '<com>','<com>',... Settings before CSV import.
        for example, you can import headerless CSV data
        into an existing "table" in "a.db" as follows:
    
    Example:
        csv2sqlite a.db -noheader -ComsBefore '.mode csv','.separator ","','.import table.csv' -SQL "SELECT * FROM table"
    
        thanks:
            https://qiita.com/Kunikata/items/61b5ee2c6a715f610493
    
    Behavior of importing CSV files depends on whether the table
    to import already exists or not

        - If the table does not exist
            - The fiest row of the CSV file is used to
              define column names
            - All data types will be recognized as TEXT.
        
        - If the table already exists
            - The first row of the CSV file is also treated as part of data.
            - Since tThere is no option to skip the first row, it is
              necessary to delete the header row before reading CSV
              files with a header row.
            - If the table already contains data, new data will be appended.

.EXAMPLE
    cat create_table.sql

    -- create users table
    DROP TABLE IF EXISTS users;
    CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        department_id INTEGER DEFAULT NULL,
        name TEXT DEFAULT NULL,
        mail TEXT DEFAULT NULL,
        created_at TEXT NOT NULL DEFAULT '0000-00-00 00:00:00',
        updated_at TEXT NOT NULL DEFAULT '0000-00-00 00:00:00',
        deleted INTEGER NOT NULL DEFAULT 0
    );
    -- create index
    CREATE INDEX IF NOT EXISTS idx_department_id_on_users ON users (department_id);

    -- https://qiita.com/Kunikata/items/61b5ee2c6a715f610493
    -- primary key is automatically indexed, so there is no need to index it again.
    -- blanks are inserted in the un-enterd fields during import, 
    -- not the value set by the DEFAULT constraint.
    -- If there are not enough commas, the rest will be filled with NULLs,
    -- but if a NOT NULL constraint is applied at that time,
    -- an error occur even if a DEFAULT constraint is set.

.EXAMPLE
    cat dat.csv
    id,main,id2,sub,val
    01,aaa,01,xxx,10
    01,aaa,02,yyy,10
    01,aaa,03,zzz,10
    02,bbb,01,xxx,10
    02,bbb,02,yyy,10
    02,bbb,03,zzz,10
    01,aaa,04,ooo,10
    03,ccc,01,xxx,10
    03,ccc,02,yyy,10
    03,ccc,03,zzz,10
    04,ddd,01,xxx,10
    04,ddd,02,yyy,10
    04,ddd,03,zzz,10

    PS > csv2sqlite dat.csv -q "select main,sum(val) from dat group by main;" -OutputFile o.csv | cat
    main  sum(val)
    ----  --------
    aaa   40
    bbb   30
    ccc   30
    ddd   30


    PS > "select *,sum(val) from dat where main like '%b%' group by main;" | csv2sqlite dat.csv -o o.csv | cat
    id  main  id2  sub  val  sum(val)
    --  ----  ---  ---  ---  --------
    02  bbb   01   xxx  10   30


.EXAMPLE
    csv2sqlite titanic.csv -q "select * from titanic limit 5;"

    survived  pclass  sex     age   sibsp  parch  fare     embarked  class
    --------  ------  ------  ----  -----  -----  -------  --------  -----
    0         3       male    22.0  1      0      7.25     S         Third
    1         1       female  38.0  1      0      71.2833  C         First
    1         3       female  26.0  0      0      7.925    S         Third
    1         1       female  35.0  1      0      53.1     S         First
    0         3       male    35.0  0      0      8.05     S         Third

.EXAMPLE
    "select * from titanic limit 5;" | csv2sqlite titanic.csv
    survived  pclass  sex     age   sibsp  parch  fare     embarked  class
    --------  ------  ------  ----  -----  -----  -------  --------  -----
    0         3       male    22.0  1      0      7.25     S         Third
    1         1       female  38.0  1      0      71.2833  C         First
    1         3       female  26.0  0      0      7.925    S         Third
    1         1       female  35.0  1      0      53.1     S         First
    0         3       male    35.0  0      0      8.05     S         Third

.EXAMPLE
    csv2sqlite diamonds.csv -q "select * from diamonds limit 5"

    carat  cut        color  clarity  depth  table  price  x     y     z
    -----  ---------  -----  -------  -----  -----  -----  ----  ----  ----
    0.23   Ideal      E      SI2      61.5   55     326    3.95  3.98  2.43
    0.21   Premium    E      SI1      59.8   61     326    3.89  3.84  2.31
    0.23   Good       E      VS1      56.9   65     327    4.05  4.07  2.31
    0.29   Premium    I      VS2      62.4   58     334    4.2   4.23  2.63
    0.31   Good       J      SI2      63.3   58     335    4.34  4.35  2.75

.EXAMPLE
    csv2sqlite b.db -q "select *,strftime('%Y-%m-%d',created_at) as modtime from order_records;"

    id  customer_name  product_name  unit_price  qty  created_at            modtime
    --  -------------  ------------  ----------  ---  -------------------   ----------
    1    taro01         orange A      1.2         10   2022-10-02 16:37:58   2022-10-02
    2    jirojiro       Apple M       2.5         2    2022-10-02 16:37:58   2022-10-02
    3    taro01         orange B      1.2         8    2022-10-02 16:37:58   2022-10-02
    4    jirojiro       Apple L       3.0         1    2022-10-02 16:37:58   2022-10-02

.EXAMPLE
    cat a.sql | csv2sqlite ex1

    id  year  month  day  customer_name  product_name  unit_price  qty  created_at           updated_at
    --  ----  -----  ---  -------------  ------------  ----------  ---  -------------------  -------------------
    1   2020  7      26   taro01         orange A      1.2         10   2022-10-06 22:38:09  2022-10-06 22:38:09
    2   2020  7      26   jirojiro       Apple M       2.5         2    2022-10-06 22:38:09  2022-10-06 22:38:09
    3   2020  7      27   taro01         orange B      1.2         8    2022-10-06 22:38:09  2022-10-06 22:38:09
    4   2020  7      28   jirojiro       Apple L       3.0         1    2022-10-06 22:38:09  2022-10-06 22:38:09

    PS > cat a.sql

    DROP TABLE IF EXISTS order_records;
    CREATE TABLE order_records (
        id            INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        year          INTEGER NOT NULL CHECK ( year > 2008 ),
        month         INTEGER NOT NULL CHECK ( month >= 1 AND month <= 12 ),
        day           INTEGER NOT NULL CHECK ( day >= 1 AND day <= 31 ),
        customer_name TEXT NOT NULL,
        product_name  TEXT NOT NULL,
        unit_price    REAL NOT NULL CHECK ( unit_price > 0 ),
        qty           INTEGER NOT NULL DEFAULT 1 CHECK ( qty > 0 ),
        created_at    TIMESTAMP NOT NULL DEFAULT (datetime('now', 'localtime')),
        updated_at    TIMESTAMP NOT NULL DEFAULT (datetime('now', 'localtime')),
        CHECK ( ( unit_price * qty ) < 200000 ) );

    CREATE TRIGGER order_records_update AFTER UPDATE ON order_records
    BEGIN
        UPDATE order_records SET last_updated_at = (datetime('now', 'localtime')) WHERE id = new.id; 
    END;

    BEGIN TRANSACTION;
    INSERT INTO order_records (year, month, day, customer_name, product_name, unit_price, qty) values( 2020, 7, 26,  'taro01', 'orange A', 1.2, 10 );
    INSERT INTO order_records (year, month, day, customer_name, product_name, unit_price, qty) values( 2020, 7, 26,  'jirojiro', 'Apple M',  2.5, 2 );
    INSERT INTO order_records (year, month, day, customer_name, product_name, unit_price, qty) values( 2020, 7, 27,  'taro01',   'orange B', 1.2, 8 );
    INSERT INTO order_records (year, month, day, customer_name, product_name, unit_price) values( 2020, 7, 28,  'jirojiro',   'Apple L', 3 );
    COMMIT;

    SELECT * FROM order_records;


.EXAMPLE
    csv2sqlite ex2 -ReadFile a.sql

    id  year  month  day  customer_name  product_name  unit_price  qty  created_at           updated_at
    --  ----  -----  ---  -------------  ------------  ----------  ---  -------------------  -------------------
    1   2020  7      26   taro01         orange A      1.2         10   2022-10-06 22:58:30  2022-10-06 22:58:30
    2   2020  7      26   jirojiro       Apple M       2.5         2    2022-10-06 22:58:30  2022-10-06 22:58:30
    3   2020  7      27   taro01         orange B      1.2         8    2022-10-06 22:58:30  2022-10-06 22:58:30
    4   2020  7      28   jirojiro       Apple L       3.0         1    2022-10-06 22:58:30  2022-10-06 22:58:30

.EXAMPLE
    "select count(*) as cnt from order_records;" | csv2sqlite ex1 -Coms '.tables','.show'

    order_records
            echo: off
             eqp: off
         explain: auto
         headers: on
            mode: column --wrap 60 --wordwrap off --noquote
       nullvalue: ""
          output: stdout
    colseparator: ","
    rowseparator: "\n"
           stats: off
           width:
        filename: ex1
    cnt
    ---
    12

.EXAMPLE
    "SELECT * FROM users natural join langs natural join binds;" | csv2sqlite users.csv,langs.csv,binds.csv -OutputFile o.csv | cat

    users_id  users_name  langs_id  langs_name
    --------  ----------  --------  ----------
    1         John         1         C
    1         John         2         C++
    1         John         5         PHP
    2         Mark         3         Java
    2         Mark         4         Perl
    2         Mark         5         PHP

    PS> cat users.csv
    users_id,users_name
    1,John
    2,Mark

    PS> cat langs.csv
    langs_id,langs_name
    1,C
    2,C++
    3,Java
    4,Perl
    5,PHP

    PS> cat binds.csv
    users_id,langs_id
    1,1
    1,2
    1,5
    2,3
    2,4
    2,5


    ```sql
    CREATE TABLE users(users_id PRIMARY KEY, users_name TEXT);
    CREATE TABLE langs(langs_id PRIMARY KEY, langs_name TEXT);
    CREATE TABLE binds(users_id INTEGER, langs_id INTEGER,PRIMARY KEY(users_id, langs_id),
    FOREIGN KEY(users_id) REFERENCES users(users_id), FOREIGN KEY(langs_id) REFERENCES langs(langs_id));

    INSERT INTO langs VALUES(1,'C');
    INSERT INTO langs VALUES(2,'C++');
    INSERT INTO langs VALUES(3,'Java');
    INSERT INTO langs VALUES(4,'Perl');
    INSERT INTO langs VALUES(5,'PHP');

    INSERT INTO users VALUES(1,'John');
    INSERT INTO users VALUES(2,'Mark');

    INSERT INTO binds VALUES(1,1);
    INSERT INTO binds VALUES(1,2);
    INSERT INTO binds VALUES(1,5);
    INSERT INTO binds VALUES(2,3);
    INSERT INTO binds VALUES(2,4);
    INSERT INTO binds VALUES(2,5);
    ```


    PS > "SELECT users_name,lang_names FROM users NATURAL JOIN (SELECT users_id,json_group_array(langs_name) as lang_names FROM binds NATURAL JOIN langs GROUP BY users_id);" | csv2sqlite users.csv,langs.csv,binds.csv -OutputFile o.csv | cat

    users_name  lang_names
    ----------  ---------------------
    John        ["C","C++","PHP"]
    Mark        ["Java","Perl","PHP"]

    thanks:
        https://qiita.com/SoraKumo/items/ecaeeea51297cb6896c9

.EXAMPLE
    ## calc summary (basic statistics)

    PS > cat tab.csv
    name,val
    A,1
    B,3
    C,1
    A,2
    B,1
    A,2

    PS > cat summary.sql
    -- calc summary val from tab
    SELECT
        COUNT( val ) cnt
        , AVG( val ) ave
        , MAX( val ) max
        , MIN( val ) min
        , (
            SELECT
                AVG( val )
            FROM (
                SELECT   *
                FROM     tab
                ORDER BY val
                LIMIT    2 - ( SELECT COUNT(*) FROM tab ) % 2
                OFFSET   ( SELECT ( COUNT(*) - 1 ) / 2  FROM tab )
                )
            ) Qt50
    FROM tab;

    ## calc summary
    PS > cat summary.sql | sed 's;val;val;' | sed 's;tab;tab;' | csv2sqlite tab.csv
    cnt  ave               max  min  Qt50
    ---  ----------------  ---  ---  ----
    6    1.66666666666667  3    1    1.5


.EXAMPLE
    ## calculate percentile and rank using SQL
    ##
    ## thanks:
    ##  Qiita: @arc279
    ##  https://qiita.com/arc279/items/8bfebf6b856bbb62586e
    ##
    ##  SQLite tutorial PERCENT_RANK()
    ##  https://www.sqlitetutorial.net/sqlite-window-functions/sqlite-percent_rank/
    
    # input data
    PS > cat data.csv | head
    id,val
    AC01,6340834
    AC02,6340834
    AC03,6340834
    AC04,6340834
    AC05,6340834
    AC06,6340834
    AC99,6340834
    AS01,6340834
    AS02,6340834
    ...
    
    # SQL file
    PS > cat percentile_and_rank.sql
    SELECT
      COUNT(*)
      , MAX(percentile)
      , MAX(val)
      , rank
    FROM (
      SELECT
        *
        , CASE
          WHEN tab.percentile >= 0.8 THEN "A"
          WHEN tab.percentile >= 0.6 THEN "B"
          WHEN tab.percentile >= 0.4 THEN "C"
          WHEN tab.percentile >= 0.2 THEN "D"
          ELSE "E"
          END AS rank
      FROM (
        SELECT
          *
          , PERCENT_RANK() OVER( ORDER BY CAST(val AS INT) ) AS percentile
        FROM data
      ) tab
    )
    GROUP BY rank
    ;
    
    
    # calc percentile and rank from val
    PS > csv2sqlite data.csv -ReadFile percentile_and_rank.sql
    COUNT(*)  MAX(percentile)    MAX(val)  rank
    --------  -----------------  --------  ----
    113       1.0                9830001   A
    111       0.798932384341637  6712244   B
    92        0.599644128113879  6580027   C
    134       0.370106761565836  5428550   D
    113       0.193950177935943  862       E


    # calc only percentile
    PS > cat percentile_only.sql
    SELECT
      *
      , CASE
        WHEN tab.percentile >= 0.8 THEN "A"
        WHEN tab.percentile >= 0.6 THEN "B"
        WHEN tab.percentile >= 0.4 THEN "C"
        WHEN tab.percentile >= 0.2 THEN "D"
        ELSE "E"
        END AS rank
    FROM (
      SELECT
        *
        , PERCENT_RANK() OVER( ORDER BY CAST(val AS INT) ) AS percentile
      FROM data
    ) tab
    ;


    PS > csv2sqlite data.csv -ReadFile percentile_only.sql | head
    id    val      percentile           rank
    ----  -------  -------------------  ----
    FZ42  541      0.0                  E
    FZ57  670      0.00177935943060498  E
    FZ62  673      0.00355871886120996  E
    FZ64  862      0.00533807829181495  E
    FZ94  101003   0.00711743772241993  E
    CZ88  184302   0.00889679715302491  E
    CZ07  542121   0.0106761565836299   E
    GZ31  564005   0.0124555160142349   E


.EXAMPLE
    ## date handling using julianday and window function
    
    PS > cat create_data.sql

    CREATE TABLE data (
        id INTEGER
        ,item TEXT
        ,qty INTEGER
        ,date TIMESTAMP
    );
    INSERT INTO data ("id", "item", "qty", "date") VALUES ('1001', 'Apple', '4', '2018-01-10' );
    INSERT INTO data ("id", "item", "qty", "date") VALUES ('1005', 'Banan', '8', '2018-01-20' );
    INSERT INTO data ("id", "item", "qty", "date") VALUES ('1010', 'Banan', '2', '2018-02-01' );
    INSERT INTO data ("id", "item", "qty", "date") VALUES ('1021', 'Apple', '9', '2018-02-15' );
    INSERT INTO data ("id", "item", "qty", "date") VALUES ('1025', 'Apple', '6', '2018-02-22' );
    INSERT INTO data ("id", "item", "qty", "date") VALUES ('1026', 'Apple', '5', '2018-02-23' );
    -- thanks
    -- https://qiita.com/tetr4lab/items/7beba8a29b2df2ef9060


    PS > cat date_handling_using_julianday_and_window_function.sql
    SELECT
        id
        , item
        , qty
        , DATE(date) as "date(TEXT)"
        , SUM(qty) OVER (ORDER BY date RANGE 10 PRECEDING) as "sum"
        , COUNT(*) OVER (ORDER BY date RANGE 10 PRECEDING) as "cnt"
        , DATE(date) as "date(JULIANDAY)"
        , SUM(qty) OVER (ORDER BY julianday(date) RANGE 10 PRECEDING) as "sum2"
        , COUNT(*) OVER (ORDER BY julianday(date) RANGE 10 PRECEDING) as "cnt2"
        , DATE(julianday(date) + 1) as day_plus_one
        , CASE CAST (strftime('%w', date) as INTEGER)
          WHEN 0 THEN 'sun'
          WHEN 1 THEN 'mon'
          WHEN 2 THEN 'tue'
          WHEN 3 THEN 'wed'
          WHEN 4 THEN 'thu'
          WHEN 5 THEN 'fri'
          ELSE 'sat' END as weekday
    FROM data ;

    ## date processed julianday function has the correct date-range and sum,
    ## but text date has incorrect date-range and sum

    PS > csv2sqlite a.db -ReadFile date_handling_using_julianday_and_window_function.sql

    id    item   qty  date(TEXT)  sum  cnt  date(JULIANDAY)  sum2  cnt2  day_plus_one  weekday
    ----  -----  ---  ----------  ---  ---  ---------------  ----  ----  ------------  -------
    1001  Apple  4    2018-01-10  4    1    2018-01-10       4     1     2018-01-11    wed
    1005  Banan  8    2018-01-20  8    1    2018-01-20       12    2     2018-01-21    sat
    1010  Banan  2    2018-02-01  2    1    2018-02-01       2     1     2018-02-02    thu
    1021  Apple  9    2018-02-15  9    1    2018-02-15       9     1     2018-02-16    thu
    1025  Apple  6    2018-02-22  6    1    2018-02-22       15    2     2018-02-23    thu
    1026  Apple  5    2018-02-23  5    1    2018-02-23       20    3     2018-02-24    fri

    ## output insert sql mode
    PS > csv2sqlite a.db -ReadFile date_handling_using_julianday_and_window_function.sql -Mode insert

    INSERT INTO "table"(id,item,qty,"date(TEXT)",sum,cnt,"date(JULIANDAY)",sum2,cnt2,day_plus_one,weekday) VALUES(1001,'Apple',4,'2018-01-10',4,1,'2018-01-10',4,1,'2018-01-11','wed');
    INSERT INTO "table"(id,item,qty,"date(TEXT)",sum,cnt,"date(JULIANDAY)",sum2,cnt2,day_plus_one,weekday) VALUES(1005,'Banan',8,'2018-01-20',8,1,'2018-01-20',12,2,'2018-01-21','sat');
    INSERT INTO "table"(id,item,qty,"date(TEXT)",sum,cnt,"date(JULIANDAY)",sum2,cnt2,day_plus_one,weekday) VALUES(1010,'Banan',2,'2018-02-01',2,1,'2018-02-01',2,1,'2018-02-02','thu');
    INSERT INTO "table"(id,item,qty,"date(TEXT)",sum,cnt,"date(JULIANDAY)",sum2,cnt2,day_plus_one,weekday) VALUES(1021,'Apple',9,'2018-02-15',9,1,'2018-02-15',9,1,'2018-02-16','thu');
    INSERT INTO "table"(id,item,qty,"date(TEXT)",sum,cnt,"date(JULIANDAY)",sum2,cnt2,day_plus_one,weekday) VALUES(1025,'Apple',6,'2018-02-22',6,1,'2018-02-22',15,2,'2018-02-23','thu');
    INSERT INTO "table"(id,item,qty,"date(TEXT)",sum,cnt,"date(JULIANDAY)",sum2,cnt2,day_plus_one,weekday) VALUES(1026,'Apple',5,'2018-02-23',5,1,'2018-02-23',20,3,'2018-02-24','fri');

    ## output json
    PS > csv2sqlite a.db -ReadFile date_handling_using_julianday_and_window_function.sql -Mode json

    [{"id":1001,"item":"Apple","qty":4,"date(TEXT)":"2018-01-10","sum":4,"cnt":1,"date(JULIANDAY)":"2018-01-10","sum2":4,"cnt2":1,"day_plus_one":"2018-01-11","weekday":"wed"},
    {"id":1005,"item":"Banan","qty":8,"date(TEXT)":"2018-01-20","sum":8,"cnt":1,"date(JULIANDAY)":"2018-01-20","sum2":12,"cnt2":2,"day_plus_one":"2018-01-21","weekday":"sat"},
    {"id":1010,"item":"Banan","qty":2,"date(TEXT)":"2018-02-01","sum":2,"cnt":1,"date(JULIANDAY)":"2018-02-01","sum2":2,"cnt2":1,"day_plus_one":"2018-02-02","weekday":"thu"},
    {"id":1021,"item":"Apple","qty":9,"date(TEXT)":"2018-02-15","sum":9,"cnt":1,"date(JULIANDAY)":"2018-02-15","sum2":9,"cnt2":1,"day_plus_one":"2018-02-16","weekday":"thu"},
    {"id":1025,"item":"Apple","qty":6,"date(TEXT)":"2018-02-22","sum":6,"cnt":1,"date(JULIANDAY)":"2018-02-22","sum2":15,"cnt2":2,"day_plus_one":"2018-02-23","weekday":"thu"},
    {"id":1026,"item":"Apple","qty":5,"date(TEXT)":"2018-02-23","sum":5,"cnt":1,"date(JULIANDAY)":"2018-02-23","sum2":20,"cnt2":3,"day_plus_one":"2018-02-24","weekday":"fri"}]

    ## output json and ConvertFrom-Json
    PS > (csv2sqlite a.db -ReadFile .\date_handling_using_julianday_and_window_function.sql -Mode json) -join '' | ConvertFrom-Json | ft

      id item  qty date(TEXT) sum cnt date(JULIANDAY) sum2 cnt2 day_plus_one
      -- ----  --- ---------- --- --- --------------- ---- ---- ------------
    1001 Apple   4 2018-01-10   4   1 2018-01-10         4    1 2018-01-11
    1005 Banan   8 2018-01-20   8   1 2018-01-20        12    2 2018-01-21
    1010 Banan   2 2018-02-01   2   1 2018-02-01         2    1 2018-02-02
    1021 Apple   9 2018-02-15   9   1 2018-02-15         9    1 2018-02-16
    1025 Apple   6 2018-02-22   6   1 2018-02-22        15    2 2018-02-23
    1026 Apple   5 2018-02-23   5   1 2018-02-23        20    3 2018-02-24

#>
function csv2sqlite {
    Param(
        [Parameter(Position=0,Mandatory=$True)]
        [Alias('i')]
        [string[]] $Files,

        [Parameter(Mandatory=$False)]
        [Alias('o')]
        [string] $OutputFile,

        [Parameter(Mandatory=$False)]
        [Alias('m')]
        [ValidateSet(
            "ascii",
            "box",
            "csv",
            "column",
            "html",
            "insert",
            "json",
            "line",
            "list",
            "markdown",
            "quote",
            "table")]
        [string] $Mode = 'column',

        [Parameter(Mandatory=$False)]
        [Alias('d')]
        [ValidateSet('\t', ' ', ',')]
        [string] $Delimiter = ',',
        
        [Parameter(Mandatory=$False)]
        [Alias('r')]
        [string] $ReadFile,

        [Parameter(Mandatory=$False)]
        [string[]] $Coms,

        [Parameter(Mandatory=$False)]
        [string[]] $ComsBefore,

        [Parameter(Mandatory=$False)]
        [switch] $NoHeader,

        [parameter(Mandatory=$False,
            ValueFromPipeline=$True)]
        [Alias('q')]
        [string[]] $SQL
    )
    # is file exists?
    function isFileExists ([string]$f){
        if(-not (Test-Path -LiteralPath "$f")){
            Write-Error "$f is not exists." -ErrorAction Stop
        }
        return
    }
    # is pandoc command exist?
    function isCommandExist ([string]$comName) {
      try { Get-Command $comName -ErrorAction Stop | Out-Null
        return $True
      } catch {
        return $False
      }
    }
    if ( -not (isCommandExist "sqlite3")){
        Write-Error 'install sqlite3' -ErrorAction SilentlyContinue
        Write-Error 'https://www.sqlite.org/index.html' -ErrorAction Stop
    }
    function DeleteComment ([string[]]$lines){
        $lines = $lines | ForEach-Object {
            $line = [string]$_
            if($line -notmatch '^\s*\-\-'){
                Write-Output "$line"
            }
        }
        return $lines
    }
    function TrimSpace ([string[]]$lines){
        $lines = $lines | ForEach-Object {
            $line = "$_".Trim()
            #$line = $line -replace '^\s+', ''
            #$line = $line -replace '\s+$', ''
            $line = $line -replace '\s+;', ';'
            Write-Output "$line"
        }
        return $lines
    }
    function SkipBlank ([string[]]$lines){
        $lines = $lines | ForEach-Object {
            $line = [string]$_
            if($line -match '.'){
                Write-Output "$line"
            }
        }
        return $lines
    }
    # main
    [string[]] $iFiles = @()
    foreach ($f in $Files){
        $iFiles += "$f".Replace('\','/')
    }
    [string[]] $dbNames = @()
    [string[]] $dbExts  = @()
    foreach ($f in $iFiles){
        $dbName   = $f -replace '^(..*)(\.[^.]+)$','$1'
        $dbNames += $dbName -replace '^..*/',''
        $dbExts  += $f -replace '^(..*)(\.[^.]+)$','$2'
    }
    # set options
    if ($dbExts[0] -eq '.csv'){
        [bool] $csvFlag = $True
    } else {
        [bool] $csvFlag = $False
    }
    if($NoHeader){
        [string] $hSwitch = 'noheader'
    } else {
        [string] $hSwitch = 'header'
    }
    if ($OutputFile){
        [string] $oFile = "$OutputFile".Replace('\','/')
    } else {
        [string] $oFile = 'stdout'
    }
    if ($ReadFile){
        [string] $rFile = "$ReadFile".Replace('\','/')
    }
    ## cleaning sql
    [string[]]$sqlAry = @()
    if ($input){
        [string[]] $sqlAry = $input
    } else {
        $sqlAry += ,$SQL
    }
    [string[]] $sqlAry = DeleteComment $sqlAry
    [string[]] $sqlAry = TrimSpace $sqlAry
    [string[]] $sqlAry = SkipBlank $sqlAry
    if ($ReadFile){
        [string] $sqlOneliner = ".read $rFile"
    } else {
        [string] $sqlOneliner = $sqlAry -Join ' '
        Write-Debug $sqlOneliner
    }
    # debug
    #Write-Debug "$iFile : $dbName : $dbExt"
    #Write-Debug "$sqlOneliner"
    # invoke command
    [string[]] $cmdAry = @()
    $cmdAry += "sqlite3"
    $cmdAry += "-$hSwitch"
    if ($ComsBefore){
        foreach ($c in $ComsBefore){
            $cmdAry += "-cmd ""$c"""
        }
    }
    if ($csvFlag){
        $cmdAry += "-separator ""$Delimiter"""
        $cmdAry += "-cmd "".mode csv"""
        for ($i = 0; $i -lt $iFiles.Count; $i++){
            $cmdAry += "-cmd "".import $($iFiles[$i]) $($dbNames[$i])"""
        }
    }
    if ($Coms){
        foreach ($c in $Coms){
            $cmdAry += "-cmd ""$c"""
        }
    }
    $cmdAry += "-cmd "".mode $Mode"""
    $cmdAry += "-cmd "".output $oFile"""
    if ($csvFlag){
        $cmdAry += ":memory:"
    } else {
        $cmdAry += "$($iFiles[0])"
    }
    $cmdAry += """$sqlOneliner"""
    # execute sqlite3
    $cmdStr = $cmdAry -Join ' '
    Write-Debug $($cmdAry -Join "`n ")
    Invoke-Expression "$cmdStr"
    if ($OutputFile){
        Get-Item "$OutputFile"
    }
}
