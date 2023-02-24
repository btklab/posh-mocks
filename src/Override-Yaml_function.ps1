<#
.SYNOPSIS
    Override-Yaml - Override external YAML file in markdown file
    
    Add external yaml data to the markdown yaml header, but if the
    key is duplicated, the data on the markdown side is given priority.
    Shared parts of yaml header and chunk option used in RMarkdown
    and Quarto can be output to external files.

    Only single line supported for yaml written in the markdown file.
    If you write an array with multiple lines, try to write it in one
    line. ( e.g. author: ['author1', 'author2'] )
    
    Motivation: The yaml header of markdown documents using RMarkdown
    or Quarto tends to be long, so I want to clean it up. The yaml header
    contains a mix of individual article blocks such as title, date, author,...
    and sharable blocks, so keep the article body simple by separating them.

    Option:
        -Settings <file>,<file>,... : Load external configuration files
                                      right after yaml header. As a use,
                                      Rmd's chunk option
    
        -Footers <file>,<file>,... : Load external configuration files
                                     at the end of the content.
    
        -ReplaceYaml <old_text_regex>,<new_text>: replace yaml
    
    Note:
        - yaml block separator in markdown file is '---'
        - Only one-line settings are overridden
            - If you write the array in one-line, do as follows:
                - keyword: ['hoge','fuga']
                - author: ['hoge','fuga']
        - Items that are not in outer yaml are output as is

.LINK
    Override-Yaml, md2import, md2tex, md2html, filehame, tex2pdf

.EXAMPLE
    cat a.md
    ---
    title: Override-Title
    subtitle: Override-Subtitle
    author: ["btklab1", "btklab2"]
    date: Override-Date
    ---

    ## hoge

    fuga


    PS > cat .\a.yaml | head
    ---
    title: dummy
    author: dummy
    lang: ja
    date: dummy
    date-format: "YYYY-M-D (ddd)"
    citation:
      url: https://example.com/
    abstract: "abstract"
    ...

    PS > cat a.md | Override-Yaml a.yaml | head
    ---
    subtitle: Override-Subtitle
    title: Override-Title
    author: ["btklab1", "btklab2"]
    lang: ja
    date: Override-Date
    date-format: "YYYY-M-D (ddd)"
    citation:
      url: https://example.com/
    abstract: "abstract"
    ...


.EXAMPLE
    cat a.md | Override-Yaml a.yaml -Settings chunk.R
    ---
    subtitle: Override-Subtitle
    title: Override-Title
    author: ["btklab1", "btklab2"]
    lang: ja
    date: Override-Date
    date-format: "YYYY-M-D (ddd)"
    citation:
      url: https://example.com/
    abstract: "abstract"
    format:
      html:
        minimal: false
        code-fold: true
        toc: true
        #toc-depth: 2
        #number-sections: true
        #number-depth: 3
        fig-width: 5
        #fig-height: 4
        #standalone: true
        #self-contained: true
        citations-hover: true
        footnotes-hover: true
        link-external-newwindow: true
        theme:
          light: cosmo
          dark: darkly
        #include-in-header: ../../quarto-header.html
        include-before-body: ../../quarto-before.html
        include-after-body: ../../quarto-footer.html
        #html-math-method:
        #  method: mathjax
        #  url: "https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"
        css: ../../quarto-styles.css
        fontsize: 1.0em
        #fig-cap-location: margin
        #tbl-cap-location: margin
        # ref:[document | section | block | margin ]
        # cit:[document | margin ]
        reference-location: margin
        citation-location: margin
        default-image-extension: svg
      pdf:
        documentclass: bxjsarticle
        classoption:
          - pandoc
          - ja=standard
          - jafont=haranoaji
          #- twocolumn
          #- landscape
          #- everyparhook=compat
        include-in-header:
          - ../../quarto-preamble.tex
        #include-before-body: quarto-before.tex
        #include-after-body: quarto-after.tex
        #papersize: a4
        #toc: true
        toc-depth: 1
        number-sections: true
        #number-depth: 3
        #lof: true
        #lot: true
        #fig-width: 3
        #fig-height: 2
        fig-pos: 'H'
        colorlinks: true
        #pagestyle: headings
        geometry:
          - top=20mm
          - bottom=20mm
          #- right=20mm
          #- left=20mm
          - right=45mm
          - left=25mm
          #- heightrounded
          #- showframe
        #cite-method: biblatex
        #keep-tex: true
        #fig-cap-location: margin
        #tbl-cap-location: margin
        # ref:[document | section | block | margin ]
        # cit:[document | margin ]
        reference-location: margin
        citation-location: document
        default-image-extension: pdf
      #docx:
      #  toc: false
    pdf-engine: lualatex
    #bibliography: ../../quarto-bib.bib
    #jupyter: python3
    #execute:
    #  echo: false
    #code-fold: true
    #code-summary: "Show the code"
    highlight-style: github
    shortcodes:
      - ../../quarto-shortcode-ruby.lua
      - ../../quarto-shortcode-color.lua
      - ../../quarto-shortcode-imgr.lua
    title-block-banner: true
    crossref:
      fig-title: "fig"
      tbl-title: "tab"
      title-delim: ":"
      fig-prefix: "fig"
      tbl-prefix: "tab"
      ref-hyperlink: false
    ---

    ```{r setup, include=FALSE}
    library(knitr)
    library(tidyr)
    library(ggplot2)

    ## Global options
    opts_chunk$set(
      echo=FALSE,
      fig.align = "center",
      fig.dim=c(),
      cache=TRUE,
      prompt=FALSE,
      tidy=FALSE,
      comment="##",
      message=FALSE,
      warning=FALSE)
    opts_knit$set(aliases=c(
        h="fig.height",
        w="fig.width",
        c="fig.cap"))

    ## Functions
    color <- function(col, str) {
      if (knitr::is_latex_output()) {
        sprintf("\\textcolor{%s}{%s}", col, str)
      } else if (knitr::is_html_output()) {
        sprintf("<span style='color: %s;'>%s</span>", col, str)
      } else str
    }
    ruby <- function(str, rub) {
      if (knitr::is_latex_output()) {
        sprintf("\\ruby{%s}{%s}", str, rub)
      } else if (knitr::is_html_output()) {
        sprintf("<ruby><rb>%s</rb><rt>%s</rt></ruby>", str, rub)
      } else str
    }
    insert_pdf <- function(file='index.pdf') {
      if (knitr::is_html_output()) {
        sprintf("- [PDFで見る](%s)", file)
      }
    }
    img <- function(file, alt='') {
      if (knitr::is_html_output()) {
        sprintf("![%s](%s.svg)", alt, file)
      } else if (knitr::is_latex_output()) {
        sprintf("![%s](%s.pdf)", alt, file)
      } else if (knitr::pandoc_to('docx')){
        sprintf("![%s](%s.svg)", alt, file)
      }
    }
    ```

    ## hoge

    fuga

#>
function Override-Yaml {
    Param(
        [Parameter( Mandatory=$True, Position=0 )]
        [string] $Yaml,

        [Parameter( Mandatory=$False, Position=1 )]
        [string[]] $Settings,

        [Parameter( Mandatory=$False )]
        [string[]] $Footers,

        [Parameter( Mandatory=$False )]
        [string[]] $ReplaceYaml,

        [parameter( Mandatory=$False, ValueFromPipeline=$True )]
        [string[]] $Text
    )

    begin {
        ## test path
        if(-not (Test-Path -Path $Yaml)){
            Write-Error "file: $Yaml is not exists." -ErrorAction Stop
        }else{
            $yamlFullPath = Resolve-Path -Path $Yaml
        }
        ## test option
        if ( $ReplaceYaml ){
            if ( $ReplaceYaml.Count -ne 2 ){
                Write-Error "-ReplaceYaml '<old_text_regex>', '<new_text>'" -ErrorAction Stop
            }
        }
        ## private functions
        function getYamKeyVal {
            param( [string]$line )
            [string] $key = $line -replace '^([^:]+): *(..*)$','$1'
            [string] $val = $line -replace '^([^:]+): *(..*)$','$2'
            [string[]] $retAry = @( $key.Trim(), $val.Trim() )
            return $retAry
        }
        ## init variables
        [int] $rowCnt = 0
        [bool] $yamlFlag = $False
        [string] $nowLine = ''
        $innerYamlHash = @{}
        ## set yaml key
        [string[]] $outerYamlArray = Get-Content -LiteralPath $yamlFullPath -Encoding UTF8 `
            | ForEach-Object {
                [string] $readLine = [string] $_
                if ( $readLine -match '^(\s*[^#][^:]+): *(..*)$' ){
                    $ikey, $ival = getYamKeyVal $readLine
                    Write-Debug "yaml-key: $ikey"
                    Write-Output $ikey
                } else {
                    return
                }
            }
    }
    process{
        $rowCnt++
        $nowLine = [string]$_
        if( $rowCnt -eq 1 ){
            if ($nowLine -eq '---') {
                ## start parse yaml header
                [bool] $yamlFlag = $True
                Write-Output $nowLine
                return
            }
        } 
        if( ($yamlFlag) -and ($nowLine -ne '---' ) ){
            ## inside yaml block
            ## set yaml headers into dictionary
            $yamkey, $yamval = getYamKeyVal $nowline
            if($yamval -eq ''){
                Write-Error "Yaml error: empty val: ""$yamkey""" -ErrorAction Stop
            }
            if ( $outerYamlArray -contains $yamkey ){
                $innerYamlHash.Add($yamkey, $yamval)
            } else {
                Write-Output $nowLine
            }
            return
        } elseif ( ($yamlFlag) -and ( $nowLine -eq '---' ) ){
            ## finish parse yaml header
            [bool] $yamlFlag = $False
            ## create yaml from template
            Get-Content -LiteralPath $yamlFullPath -Encoding UTF8 `
              | ForEach-Object {
                    [string] $readLine = [string]$_
                    if ( $readLine -eq '---' ){ return }
                    if ( $readLine -eq ''    ){ return }
                    if ( $ReplaceYaml ){
                        $readLine = $readLine -replace $ReplaceYaml[0], $ReplaceYaml[1]
                    }
                    if ( $readLine -match '^([^:]+): *(..*)$' ){
                        $ikey, $ival = getYamKeyVal $readLine
                        if( $innerYamlHash.ContainsKey( $ikey )){
                            ## replace if hash has key
                            [string] $writeLine = $ikey + ": " + $innerYamlHash[$ikey]
                            Write-Output $writeLine
                        } else {
                            Write-Output $readLine
                        }
                        
                    } else {
                        Write-Output $readLine
                    }
            }
            Write-Output "---"
            Write-Output ""
            if( $Settings ){
                ## import setting files
                foreach( $settingFile in $Settings ){
                    Get-Content -LiteralPath $settingFile -Encoding UTF8
                    Write-Output ''
                }
            }
            return
        } else {
            Write-Output "$nowLine"
            return
        }
    }
    end {
        if( $Footers ){
            ## import setting files
            Write-Output ''
            foreach( $footerFile in $Footers ){
                Get-Content -LiteralPath $footerFile -Encoding UTF8
                Write-Output ''
            }
        }
    }
}
