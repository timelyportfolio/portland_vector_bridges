library(htmltools)
library(rvest)
library(pipeR)

cleanSVG <- function(){
  lapply(
    list.files(".", pattern = ".svg")
    ,function(svg){
        html(svg) %>>%
          html_nodes("svg") %>>%
          (~ xmlApply(
            ., 
            function(s){
              a = xmlAttrs(s)
              removeAttributes(s)
              xmlAttrs(s) <- a[c("version","xmlns","xmlns:xlink","viewbox")]
              xmlAttrs(s) <- c(
                style = paste0(
                  "height:100%;width:100%;"
                )
              )
            }
          )
          ) %>>%
          (saveXML(xmlDoc(.[[1]]))) %>>%
          HTML %>>% cat(file=svg)
    }
  )
}

#cleanSVG()

tagList(
  tags$div( class="bss-slides num1", tabindex="1", autofocus="autofocus"
    ,style = "width:100%;height:40%"
    ,lapply(
      list.files(".", pattern = ".svg")
      ,function(svg){
        tags$figure(
          style = "width:100%;"
          ,tags$img(
            style = "width:100%;height:100%;"
            ,src = svg
            #,type="image/svg+xml"
            #, data = svg %>>% HTML
          )
          ,tags$figcaption(
            style = "right:auto;"
            ,paste0(gsub(x=svg,pattern="\\.svg",replacement="")," by ",collapse="") %>>% HTML
            ,tags$a(
              href = "https://github.com/darrell/portland_vector_bridges"
              ,"Darrell"
            )
            ,tags$br()
            ,"Slideshow by "
            ,tags$a(
                href = "http://leemark.github.io/better-simple-slideshow/"
                ,"better-simple-slideshow"
            )
          )
        )
      }
    )
  )
  , markdown::markdownToHTML("Readme.md",options=c("fragment_only")) %>>% HTML
  , tags$script(
"
      // copied from http://leemark.github.io/better-simple-slideshow/
      var opts = {
        auto : {
            speed : 3500, 
            pauseOnHover : true
        },
        fullScreen : false, 
        swipe : true
      };
      makeBSS('.num1', opts);
" %>>% HTML  
  )
) %>>%
  attachDependencies(
    list(
      htmlDependency(
        name="better-simple-slideshow"
        ,version="1.0"
        ,src=c("href"="./better-simple-slideshow")
        ,script = "better-simple-slideshow.min.js"
        ,style = "simple-slideshow-styles.css"
      )
      ,htmlDependency(
        name="hammer"
        ,version="1.1.3"
        ,src=c(href="https://cdnjs.cloudflare.com/ajax/libs/hammer.js/1.1.3")
        ,script = "hammer.min.js"
      )
    )
  ) %>>%
  save_html("index.html")
