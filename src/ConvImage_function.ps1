<#
.Synopsis
    ConvImage - Image rotation, flipping, scaling

    Image format conversion is automatically recognized
    form the extension of the filenames.

    ConvImage -i <file> -o <file> [-notOverWrite]
    ConvImage -i <file> -o <file> -resize <height>x<width> [-notOverWrite]
    ConvImage -i <file> -o <file> -rotate <degrees> [-flip] [-flop] ] [-notOverWrite]

    Inspired by:

    Get-Draw.ps1 - miyamiya/mypss: My PowerShell scripts - GitHub
        - https://github.com/miyamiya/mypss
        - License: The MIT License (MIT): Copyright (c) 2013 miyamiya
    ImageMagick (command)
        - https://imagemagick.org/index.php

.Parameter inputFile
    Input image file.

.Parameter outputFile
    Output image file
    
    Convert to the specified format from file extension.
    Extensions that can be used:
    
    jpg,png,bmp,emf,gif,tiff,wmf,exif,guid,icon,...

.Parameter Exif
    Inherit image file properties such as Exif information
    as much as possible.

    Supported only when resizing image.

.Parameter ExifOrientationOnly
    Inherit only the properties (Exif information) of the
    image orientation (up, down, left and right)

    Supported only when resizing image.

.Parameter resize
    Specify the output image size in <height>x<width>
    e.g. 200x100 or 200

    Aspect ratio is preserved. if size is specified by
    <height>x<width>, the aspect ratio is maintained
    and resized based on the longest side.

    e.g.
    100x100 : Pixel specification
    100     : Pixel specification (height only)
    50%     : Ratio specification (height only)

.Parameter rotate
    Specify rotation angle.

.Parameter flip
    flip top/bottom

.Parameter flop
    Invert left/right

.Parameter notOverWrite
    If the output file already exists,
    do not overwrite it.

.EXAMPLE
PS > ConvImage before.jpg after.png

Description
========================
Easiest example.
Convert format "before.jpg" to "after.png".

.EXAMPLE
PS > ConvImage before.jpg after.png -resize 500x500

Description
========================
The simplest example #2.
Convert format "before.jpg" to  "after.png", and
resize the image to fit in the 500x500 px.
Acpect ratio is preserved.

.EXAMPLE
PS > ConvImage -i before.jpg -o after.png -resize 100x100

Description
========================
Option names are described without omission.(but use alias)
The results is the same as above example.

.EXAMPLE
PS > ConvImage -i before.jpg -o after.png -resize 100x100 -notOverWrite

Description
========================
Convert format ".jpg" to ".png",
Resize to 100x100 px with keeoing the aspect ratio,
do not overwrite if "after.png" already exist.

.EXAMPLE
PS > ConvImage before.jpg after.png -resize 10%

Description
========================
Convert format ".jpg" to ".png",
Scale down to 10% (1/10) of the pixels in height and width.
Acpect ratio is preserved.

.EXAMPLE
PS > ConvImage before.jpg after.png -resize 100

Description
========================
Convert format ".jpg" to ".png",
Resize 1o 100px in height (vertical),
Aspect ratio is preserved.

.EXAMPLE
PS > ConvImage before.jpg after.png -rotate 90

Description
========================
Convert format ".jpg" to ".png",
Rotate 90 degrees.

.EXAMPLE
PS > ConvImage before.jpg after.png -rotate 90 -flip

Description
========================
Convert format ".jpg" to ".png",
Rotate 90 degrees and
Flip upside down.

.EXAMPLE
PS > ConvImage before.jpg after.png -rotate 90 -flop

Description
========================
Convert format ".jpg" to ".png",
Rotate 90 degrees,
Flip left and right

#>
function ConvImage {
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $True,Position=0)]
        [Alias('i')]
        [string[]]$inputFile,

        [parameter(Mandatory = $True,Position=1)]
        [Alias('o')]
        [string[]]$outputFile,

        [parameter(Mandatory = $False)]
        [string]$resize = "None",

        [parameter(Mandatory = $False)]
        [ValidateSet("90", "180", "270")]
        [string]$rotate = "None",

        [parameter(Mandatory = $False)]
        [switch]$flip,

        [parameter(Mandatory = $False)]
        [switch]$flop,

        [parameter(Mandatory = $False)]
        [switch]$Exif,

        [parameter(Mandatory = $False)]
        [switch]$ExifOrientationOnly,

        [parameter(Mandatory = $False)]
        [switch]$notOverWrite
    )

    # get current directory path
    $str_path = (Convert-Path .)

    # if input file is not an absolute path,
    # add an absolute path
    if($inputFile -eq ''){
        Write-Error 'Invalid input file path.' -ErrorAction Stop
    }
    if(($inputFile -notmatch '^[A-Z]:\\.*') -and ($inputFile -notmatch '^\\\\')){
        $inputFilePath = (Join-Path "$str_path" "$inputFile")
    }else{
        $inputFilePath = $inputFile
    }

    # if output file is not an absolute path,
    # add an absolute path
    if($outputFile -eq ''){
        Write-Error 'Invalid output file path.' -ErrorAction Stop}
    if(($outputFile -notmatch '^[A-Z]:\\.*') -and ($outputFile -notmatch '^\\\\')){
        $outputFilePath = (Join-Path "$str_path" "$outputFile")
    }else{
        $outputFilePath = $outputFile
    }

    # test existence of input file
    # and get full path
    if( ! (Test-Path "$inputFilePath") ){
        Write-Error "$inputFile is not exist." -ErrorAction Stop
    }
    # is no overwrite mode?
    if( $notOverWrite ){
        if( (Test-Path "$outputFilePath") ){
            Write-Error "$outputFile is already exist." -ErrorAction Stop
        }
    }

    # if input -eq output, exit
    if("$outputFilePath" -eq "$inputFilePath"){
        Write-Error "The same file is specified for input and output." -ErrorAction Stop
    }

    # get file extenxtion
    $inputExt = $inputFile -Replace '^.*\.([^.]*)$','$1'
    $inputExt = $inputExt.ToLower()
    $outputExt = $outputFile -Replace '^.*\.([^.]*)$','$1'
    $outputExt = $outputExt.ToLower()

    # format conversion of output file extensions
    if($outputExt -eq 'jpg' ) { $ImageFormatExt = 'Jpeg' }
    if($outputExt -eq 'jpeg') { $ImageFormatExt = 'Jpeg' }
    if($outputExt -eq 'png' ) { $ImageFormatExt = 'Png'  }
    if($outputExt -eq 'bmp' ) { $ImageFormatExt = 'Bmp'  }
    if($outputExt -eq 'emf' ) { $ImageFormatExt = 'Emf'  }
    if($outputExt -eq 'gif' ) { $ImageFormatExt = 'Gif'  }
    if($outputExt -eq 'tiff') { $ImageFormatExt = 'Tiff' }
    if($outputExt -eq 'wmf' ) { $ImageFormatExt = 'Wmf'  }
    if($outputExt -eq 'exif') { $ImageFormatExt = 'Exif' }
    if($outputExt -eq 'guid') { $ImageFormatExt = 'Guid' }
    if($outputExt -eq 'icon') { $ImageFormatExt = 'Icon' }

    # test file extension
    $iExtFlag = $false
    $oExtFlag = $false
    [string[]]$extLists = @("jpg","jpeg","png","bmp","emf","gif","tiff","wmf","exif","guid","icon") 
    foreach ($ex in $extLists){
        if($ex -eq $inputExt) {$iExtFlag = $true}
        if($ex -eq $outputExt){$oExtFlag = $true}
    }
    if(!$iExtFlag){
        Write-Error "Incorrect extension of input file." -ErrorAction Stop
    }
    if(!$oExtFlag){
        Write-Error "Incorrect extension of output file." -ErrorAction Stop
    }
    # create output file path
    [string] $tmpFileName = $outputFilePath -Replace '^(.*\.)[^.]*$','$1'
    [string] $outputFilePath = $tmpFileName + $outputExt

    # generate rotate flip type compatible strings
    # rotate
    if($rotate -eq 'None'){
        [string] $rotateStr = 'Rotate' + "$rotate"
    }else{
        [string] $rotateStr = 'Rotate' + [string]$rotate
    }    

    # flip,flop
    if($flip -and $flop){
        $flipStr = 'FlipXY'
    }elseif($flip -and (!$flop)){
        $flipStr = 'FlipY'
    }elseif((!$flip) -and $flop){
        $flipStr = 'FlipX'
    }else{
        $flipStr = 'FlipNone'
    }

    # Parse rotate option
    $RotateFlipTypeStr = $rotateStr + $flipStr
    if($RotateFlipTypeStr -eq "RotateNoneFlipNone"){
        [bool] $rotateFlag = $false
    }else{
        [bool] $rotateFlag = $true
    }
    # parse resize option
    #     100x100 : Pixel specification
    #     100     : Pixel specification (height only)
    #     50%     : Ratio specification (height only)
    [bool] $resizeFlag  = $false
    [bool] $percentFlag = $false
    [bool] $splitFlag   = $false
    # is '%' include?
    if([string]$resize -match '%'){
        $percentFlag = $true
        $resize = $resize -Replace '%',''
    }
    # is 'x' include?
    if([string]$resize -match 'x'){
        $resizeFlag  = $true
        $splitFlag   = $true
        $splitResize = $resize -Split 'x'
        if($splitResize.Count -ne 2){
            Write-Error "Incorrect -Resize option." -ErrorAction Stop
        }
        $TateNum = [int]$splitResize[0]
        $YokoNum = [int]$splitResize[1]
    }elseif($resize -ne 'None'){
        $resizeFlag = $true
        $TateYokoNum = [int]$resize
    }
    # only one of "Resize" and "Rotate, Flip, Flop" can be executed
    if($rotateFlag -and $resizeFlag){
        Write-Error 'only one of "Resize" and "Rotate, Flip, Flop" can be executed.'  -ErrorAction Stop
    }
    #
    # main
    #
    Add-Type -AssemblyName System.Drawing
    # load input image file
    $image = New-Object System.Drawing.Bitmap("$inputFilePath")
    ## Rotate, Flip, Flop
    if($rotateFlag){
        # Rotate
        $image.RotateFlip("$RotateFlipTypeStr") 
        # save image
        $image.Save("$outputFilePath", [System.Drawing.Imaging.ImageFormat]::"$ImageFormatExt")
        # dispose object
        $image.Dispose()
    ## Resize image
    }elseif($resizeFlag){
        # generate object to be shrunk
        if($splitFlag){
            # Case: <height>x<width>
            if($percentFlag){
                # include '%'
                # percent specification
                $tateRatio = $TateNum / 100
                $yokoRatio = $YokoNum / 100
                $ratio = $tateRatio
            }else{
                # Pixel specification
                # fit into a specified size
                # adopt the value with the higher
                # reduction ratio in height and width.
                $tateRatio = $TateNum / $image.Height
                $yokoRatio = $YokoNum / $image.Width
                if($tateRatio -gt $yokoRatio){
                    # height -gt width
                    $ratio = $yokoRatio
                }else{
                    $ratio = $tateRatio
                }
            }
        }else{
            # numerical value only (height only) specified
            if($percentFlag){
                # include '%'
                # percent specification
                $ratio = $TateYokoNum / 100
            }else{
                # Pixel specification
                $ratio = $TateYokoNum / $image.Height
            }
        }
        $resizeHeightPixel = $image.Height * $ratio
        $resizeWidthPixel = $image.Width * $ratio

        #$canvas = New-Object System.Drawing.Bitmap([int]($image.Width / 2), [int]($image.Height / 2))
        $canvas = New-Object System.Drawing.Bitmap([int]($resizeWidthPixel), [int]($resizeHeightPixel))

        # drawing to reduced destination
        $graphics = [System.Drawing.Graphics]::FromImage($canvas)
        $graphics.DrawImage($image, (New-Object System.Drawing.Rectangle(0, 0, $canvas.Width, $canvas.Height)))

        # transfer of attributes
        # (Exif, rotate information, etc.)
        if ($Exif){
            foreach($item in $image.PropertyItems) {
                $canvas.SetPropertyItem($item)
            }
        }
        if ($ExifOrientationOnly){
            ## only the orientation of the image
            ## is taken over.
            ## in Exif, orientation information (ID)
            ## is 0x0112 (274 in decimal)
            ## ref: https://www.media.mit.edu/pia/Research/deepview/exif.html
            ## ref: https://blog.shibayan.jp/entry/20140428/1398688687
            foreach($item in $image.PropertyItems) {
                if ($item.Id -eq 0x0112){
                    $canvas.SetPropertyItem($item)
                }
            }
        }

        # save image
        $canvas.Save("$outputFilePath", [System.Drawing.Imaging.ImageFormat]::"$ImageFormatExt")

        # dispose objects
        $graphics.Dispose()
        $canvas.Dispose()
        $image.Dispose()

    ## Image format conversion only
    }else{
        # save image
        $image.Save("$outputFilePath", [System.Drawing.Imaging.ImageFormat]::"$ImageFormatExt")

        # dispose object
        $image.Dispose()
    }
}
