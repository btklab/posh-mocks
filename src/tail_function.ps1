<#
.SYNOPSIS
    tail - Output the last part of files
      
        tail [-n num] [file]...

    If no file is specified, read from stdin.
    Specifying file is faster than read from stdin.

.LINK
    head, tail, chead, ctail, ctail2

.EXAMPLE
    1..20 | tail
    11
    12
    13
    14
    15
    16
    17
    18
    19
    20

    1..20 | tail -n 5
    16
    17
    18
    19
    20

.EXAMPLE
    tail *.txt

    PS > tail -n 5 *.txt

#>
function tail{

  begin{
    [int] $readRowCounter = 0
    [bool] $stdinFlag      = $False
    [bool] $readFileFlag   = $False
    [bool] $setNumFlag     = $False
    [bool] $oldVersionFlag = $false
    $tailHash = @{}
    # get PowerShell version
    # Get-Content -LiteralPath file -Tail <n> is only available after v5.0
    [int] $ver = $PSVersionTable.PSVersion.Major
    if( $ver -le 2 ){
      [bool] $oldVersionFlag = $True
    }
    if( $args.Count -eq 0 ){
      # without args: get input from pipeline
      [bool] $stdinFlag = $True
      [int] $dispRowNum = 10
    } elseif ( [string]($args[0]) -eq '-n' ){
      # "-n <n>" if the number of rows is specified
      if( $args.Count -lt 2 ){
        Write-Error "Insufficient args." -ErrorAction Stop
      }
      [bool] $setNumFlag = $True
      [int] $dispRowNum = [int]($args[1])
    } else {
      # If no not specified number of rows,
      # all args treat as files.
      [bool] $readFileFlag = $True
      [int] $dispRowNum = 10
      [int] $fileArryStartCounter = 0
    }
    # Input format for "-n <n>"
    if( $setNumFlag ){
      if( $args.Count -eq 2 ){
        # If args.count -eq 2,
        # get data from pipeline
        [bool] $stdinFlag = $True
      }else{
        # If args.count -gt 2,
        # remaining args treat as files.
        [bool] $readFileFlag = $True
        [int] $fileArryStartCounter = 2
      }
    }
    # init tailHash
    # used to detect when the number of lines is
    # less than the specified number of lines.
    [string] $chkStr = 'nulpopopo'
    for($i = 1; $i -le $dispRowNum; $i++){
      [string] $tmpKey = 'COL' + [string]$i
      $tailHash["$tmpKey"] = $chkStr
    }
  } # end of begin block

  process{
    if( $stdinFlag ){
      $readRowCounter++
      [string] $tmpKey = 'COL' + [string]$readRowCounter
      $tailHash["$tmpKey"] = $_
      if( $readRowCounter -eq $dispRowNum ){
        [int] $readRowCounter = 0
      }
    }
  } # end of process block

  end{
    if( $stdinFlag ){
      if( $readRowCounter -eq 0 ){
        for( $i = 1; $i -le $dispRowNum; $i++ ){
          [string] $tmpKey = 'COL' + [string]$i
          Write-Output $tailHash["$tmpKey"]
        }
      }else{
        for( $i = $readRowCounter + 1; $i -le $dispRowNum; $i++ ){
          [string] $tmpKey = 'COL' + [string]$i
          if( [string]($tailHash["$tmpKey"]) -ne [string]$chkStr ){
            Write-Output $tailHash["$tmpKey"]
          }
        }
        for( $i = 1; $i -le $readRowCounter; $i++ ){
          [string] $tmpKey = 'COL' + [string]$i
          Write-Output $tailHash["$tmpKey"]
        }
      }
      return
    }
    if( $readFileFlag ){
      for( $i = $fileArryStartCounter; $i -lt $args.Count; $i++ ){
        $fileList = (Get-Item -Path $args[$i] | ForEach-Object { $_.FullName } )
        foreach($f in $fileList){
          # Output filename
          #$dispFileName = (Split-Path -Leaf "$files")
          [string] $dispFileName = "$f"
          Write-Output ('==> ' + "$dispFileName" + ' <==')
          # Output specified number of lines
          # depending on PowerShell version
          if($oldVersionFlag){
            # -le v2.0
            [int] $tmpDispRowNum = $dispRowNum * -1
            @(Get-Content -Path "$f" -Encoding UTF8)[($tmpDispRowNum..-1)]
          }else{
            Get-Content -Path "$f" -Tail $dispRowNum -Encoding UTF8
          }
          # Output blank line as file separator
          Write-Output ''
        }
      }
      return
    }
  } #end of end block
}
