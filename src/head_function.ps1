<#
.SYNOPSIS
    head - Output the first part of files

    Output only the specified number of lines
    from the beginning of lines.

    Defaults to 10 lines of output.
    
    head [-n num] [file]...

    If file is not specified, it is read from
    the pipeline input.

    If file is specified, outputs the specified
    number of lines along with the file name.

.LINK
    head, tail, chead, ctail, tail-f

.EXAMPLE
    1..20 | head
    1
    2
    3
    4
    5
    6
    7
    8
    9
    10
    
    PS > 1..20 | head -n 5
    1
    2
    3
    4
    5

.EXAMPLE
    head head*.ps1
    ==> .\head_function.ps1 <==
    <#
        head - Output the first part of files
    
        Output only the specified number of lines
        from the beginning of lines.
    
        Defaults to 10 lines of output.
    
        head [-n num] [file]...
    
    
    PS> head -n 5 head*.ps1
    ==> .\head_function.ps1 <==
    <#
        head - Output the first part of files
    
        Output only the specified number of lines
    
#>
function head {

  begin
  {
    [int] $readRowCounter  = 0
    [bool] $stdinFlag      = $False
    [bool] $readFileFlag   = $False
    [bool] $setNumFlag     = $False
    [bool] $oldVersionFlag = $False

    # get PowerShell version
    # Get-Content -LiteralPath file -Head <n> is only available after v5.0
    [int] $ver = $PSVersionTable.PSVersion.Major
    if($ver -le 2){ $oldVersionFlag = $True }

    # get input format and number of output lines from args
    if( $args.Count -eq 0 ){
      # without args: get input from pipeline
      [bool] $stdinFlag = $True
      [int] $dispRowNum = 10
    } elseif ( [string]($args[0]) -eq '-n' ){
      # "-n <n>" if the number of rows is specified
      if($args.Count -lt 2){
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
        $stdinFlag = $True
      } else {
        # If args.count -gt 2,
        # remaining args treat as files.
        $readFileFlag = $True
        $fileArryStartCounter = 2
      }
    }
  } # end of begin block

  process
  {
    if( $stdinFlag ){
      $readRowCounter++
      if( $readRowCounter -le $dispRowNum ){
        Write-Output $_
      }
    }
  } # end of process block

  end
  {
    if($readFileFlag){
      for($i = $fileArryStartCounter; $i -lt $args.Count; $i++){
        $fileList = (Get-ChildItem -Path $args[$i] | ForEach-Object { $_.FullName } )
        foreach($f in $fileList){
          # output file name
          [string] $dispFileName = Resolve-Path $f -Relative
          Write-Output ('==> ' + "$dispFileName" + ' <==')
          # output lines according to PowerShell version
          if($oldVersionFlag){
            # -le v2.0
            $tmpDispRowNum = $dispRowNum - 1
            #@(Get-Content -LiteralPath "$f" -Encoding oem)[0..$tmpDispRowNum]
            @(Get-Content -LiteralPath "$f" -Encoding UTF8)[0..$tmpDispRowNum]
          }else{
            #Get-Content -LiteralPath "$f" -Encoding oem -Head $dispRowNum
            Get-Content -LiteralPath "$f" -Encoding UTF8 -Head $dispRowNum
          }
          # Output empty line as a display separator
          Write-Output ''
        }
      }
    }
  } # end of end block
}
