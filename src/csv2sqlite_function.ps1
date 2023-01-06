<#
.SYNOPSIS

csv2sqlite - csvファイルにsqlite的sqlを適用する

csvファイルを読み込んだ場合はcsvファイル名がDB名
csvファイルかそれ以外かは入力ファイル拡張子で判断
csvファイルはカンマ区切りで複数指定可能。
  NATURAL JOINなど複数テーブルを結合できる。

Usage:
  csv2sqlite csv,csv,... "<sqlstring>"
  csv2sqlite csv,csv,... -ReadFile <sqlfile>
  "<sqlstring>" | csv2sqlite csv,csv,...
  cat <sqlfile> | csv2sqlite csv,csv,...

  csv2sqlite db "<sqlstring>"
  csv2sqlite db -ReadFile <sqlfile>
  "<sqlstring>" | csv2sqlite db
  cat <sqlfile> | csv2sqlite db

  -Coms '<com>','<com>',... 手動でコマンドを指定してもよい。
    たとえば、-Coms '.tables','.show','.mode markdown'

  -ComsBefore '<com>','<com>',... で、csvのインポート前のセッティングができる
    たとえば以下のようにすればヘッダレスcsvデータをa.dbの既存テーブルに取り込める：
    https://qiita.com/Kunikata/items/61b5ee2c6a715f610493
    
    csv2sqlite a.db -noheader -ComsBefore '.mode csv','.separator ","','.import table.csv' -SQL "SELECT * FROM table"

CSVファイルのインポートは、インポート先のテーブルが既に存在しているかどうかで挙動が違う

- テーブルが存在しない場合
  - CSVファイルの先頭行がカラム名の定義に使われる
  - データ型は全てTEXTになる

- テーブルが存在する場合
  - CSVファイルの先頭行もデータとして扱われる
  - 先頭行を無視するオプションは存在しないので、
    先頭行があるCSVファイルの場合は事前に先頭行を削除しておく必要がある
  - すでにデータが入っている場合は追記される

.EXAMPLE
cat create_table.sql

-- ユーザーテーブルの作成
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
-- インデックスの作成
CREATE INDEX IF NOT EXISTS idx_department_id_on_users ON users (department_id);

-- https://qiita.com/Kunikata/items/61b5ee2c6a715f610493
-- primary keyには自動的にインデックスが張られるので改めてインデックスを作成する必要はありません
-- インポートの際にはCSVで未入力の箇所には空白文字列が入るのでDEFAULT制約で設定した値にはなりません
-- コンマの数が足りない場合は残りがNULLで埋められますが、その時にNOT NULL制約がかかっていると
-- DEFAULT制約を設定していてもエラーになる

.EXAMPLE
csv2sqlite data.csv "select omise,sum(val) from data group by omise;" -OutputFile o.csv | cat

omise  sum(val)
-----  --------
上野店    247
新宿店    184
新橋店    219
池袋店    166

.EXAMPLE
"select *,sum(val) from data where omise like '%新%' group by omise;" | csv2sqlite data.csv -OutputFile o.csv | cat

data  omise  date      val  sum(val)
----  -----  --------  ---  --------
0003  新宿店    20060201  82   184
0001  新橋店    20060201  91   219

.EXAMPLE
csv2sqlite titanic.csv "select * from titanic limit 5;"

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
csv2sqlite .\diamonds.csv "select * from diamonds limit 5"

carat  cut        color  clarity  depth  table  price  x     y     z
-----  ---------  -----  -------  -----  -----  -----  ----  ----  ----
0.23   Ideal      E      SI2      61.5   55     326    3.95  3.98  2.43
0.21   Premium    E      SI1      59.8   61     326    3.89  3.84  2.31
0.23   Good       E      VS1      56.9   65     327    4.05  4.07  2.31
0.29   Premium    I      VS2      62.4   58     334    4.2   4.23  2.63
0.31   Good       J      SI2      63.3   58     335    4.34  4.35  2.75

.EXAMPLE
csv2sqlite b.db "select *,strftime('%Y-%m-%d',created_at) as modtime from order_records;"

id  customer_name  product_name  unit_price  qty  created_at            modtime
--  -------------  ------------  ----------  ---  -------------------   ----------
1    kaneko         orange A      1.2         10   2022-10-02 16:37:58   2022-10-02
2    miyamoto       Apple M       2.5         2    2022-10-02 16:37:58   2022-10-02
3    kaneko         orange B      1.2         8    2022-10-02 16:37:58   2022-10-02
4    miyamoto       Apple L       3.0         1    2022-10-02 16:37:58   2022-10-02

.EXAMPLE
cat a.sql | csv2sqlite ex1

id  year  month  day  customer_name  product_name  unit_price  qty  created_at           updated_at
--  ----  -----  ---  -------------  ------------  ----------  ---  -------------------  -------------------
1   2020  7      26   kaneko         orange A      1.2         10   2022-10-06 22:38:09  2022-10-06 22:38:09
2   2020  7      26   miyamoto       Apple M       2.5         2    2022-10-06 22:38:09  2022-10-06 22:38:09
3   2020  7      27   kaneko         orange B      1.2         8    2022-10-06 22:38:09  2022-10-06 22:38:09
4   2020  7      28   miyamoto       Apple L       3.0         1    2022-10-06 22:38:09  2022-10-06 22:38:09

PS> cat a.sql

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
INSERT INTO order_records (year, month, day, customer_name, product_name, unit_price, qty) values( 2020, 7, 26,  'kaneko', 'orange A', 1.2, 10 );
INSERT INTO order_records (year, month, day, customer_name, product_name, unit_price, qty) values( 2020, 7, 26,  'miyamoto', 'Apple M',  2.5, 2 );
INSERT INTO order_records (year, month, day, customer_name, product_name, unit_price, qty) values( 2020, 7, 27,  'kaneko',   'orange B', 1.2, 8 );
INSERT INTO order_records (year, month, day, customer_name, product_name, unit_price) values( 2020, 7, 28,  'miyamoto',   'Apple L', 3 );
COMMIT;

SELECT * FROM order_records;


.EXAMPLE
csv2sqlite ex2 -ReadFile a.sql

id  year  month  day  customer_name  product_name  unit_price  qty  created_at           updated_at
--  ----  -----  ---  -------------  ------------  ----------  ---  -------------------  -------------------
1   2020  7      26   kaneko         orange A      1.2         10   2022-10-06 22:58:30  2022-10-06 22:58:30
2   2020  7      26   miyamoto       Apple M       2.5         2    2022-10-06 22:58:30  2022-10-06 22:58:30
3   2020  7      27   kaneko         orange B      1.2         8    2022-10-06 22:58:30  2022-10-06 22:58:30
4   2020  7      28   miyamoto       Apple L       3.0         1    2022-10-06 22:58:30  2022-10-06 22:58:30

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
1         太郎          1         C
1         太郎          2         C++
1         太郎          5         PHP
2         次郎          3         Java
2         次郎          4         Perl
2         次郎          5         PHP

PS> cat users.csv
users_id,users_name
1,太郎
2,次郎

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

INSERT INTO users VALUES(1,'太郎');
INSERT INTO users VALUES(2,'次郎');

INSERT INTO binds VALUES(1,1);
INSERT INTO binds VALUES(1,2);
INSERT INTO binds VALUES(1,5);
INSERT INTO binds VALUES(2,3);
INSERT INTO binds VALUES(2,4);
INSERT INTO binds VALUES(2,5);
```

.EXAMPLE
 "SELECT users_name,lang_names FROM users NATURAL JOIN (SELECT users_id,json_group_array(langs_name) as lang_names FROM binds NATURAL JOIN langs GROUP BY users_id);" | csv2sqlite users.csv,langs.csv,binds.csv -OutputFile o.csv | cat

users_name  lang_names
----------  ---------------------
太郎          ["C","C++","PHP"]
次郎          ["Java","Perl","PHP"]


https://qiita.com/SoraKumo/items/ecaeeea51297cb6896c9
グループ化とjson_group_arrayを組み合わせ、JSONの配列にまとめることが出来た

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
            "table"
            )]
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
        Write-Warning 'install sqlite3'
        Write-Warning 'https://www.sqlite.org/index.html'
        throw
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
            $line = [string]$_
            $line = $line -replace '^\s+', ''
            $line = $line -replace '\s+$', ''
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
        [boolean] $csvFlag = $True
    } else {
        [boolean] $csvFlag = $False
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
        $sqlAry = $input
    } else {
        $sqlAry += ,$SQL
    }
    $sqlAry = DeleteComment $sqlAry
    $sqlAry = TrimSpace $sqlAry
    $sqlAry = SkipBlank $sqlAry
    if ($ReadFile){
        [string] $sqlOneliner = ".read $rFile"
    } else {
        [string] $sqlOneliner = $sqlAry -Join ' '
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
