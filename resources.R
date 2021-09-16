##################################
# Created by EPI-interactive
# 12 Mar 2021
# https://www.epi-interactive.com
##################################


# Global functions --------------------------------------------------------
g_getDownloadIcon <- list(icon("image", lib = "font-awesome"),"Export PNG")

#export functions
g_getImageFileName <- function(title){
    paste0(title,"_",format(Sys.time(),"%Y%m%d%H%M"), '.png', sep='')
}

g_getImageDownloader <- function(data, file, title ="", width=800, height=450){
    cssPath <- paste0(getwd(),"/www/css/download.css")
    
    header <- tagList(
        includeCSS(cssPath),
        div(p(class="img-download-chart-heading", tags$span(title)))
    )
    
    imgPath <- paste0(getwd(),"/www/images/Epi_logo.png")
    
    footer <- tagList(
        includeCSS(cssPath),
        div(class ="watermark",style="float: left;",
            div(class="watermark-date", span("Epi-interactive")),
            tags$img(src=imgPath, id="EPI_logo_watermark")
        ),
        div(class ="watermark", style="float: right;",
            div(class="watermark-date", strftime(Sys.Date(), "%d/%m/%Y", tz = "Pacific/Auckland"))
        ))
    
    oldwd <- getwd()
    dir <- tempdir()
    setwd(dir)
    
    header <- saveComponent(header, "header", width)
    footer <- saveComponent(footer, "footer", width)
    
    if(!is.null(data)){
        getPlot(data, width, height)
        plot <- image_read("temp.png")
        allComponents <- c(header,  plot, footer)
    }
    
    setwd(oldwd)
    allComponents <- image_append(allComponents, stack=T)
    
    image_write(allComponents, file, format = "png")
}


# Local functions ---------------------------------------------------------
getPlot <- function(data, width, height){
    orca(data, "temp.png", width = width, height = height)
}

saveComponent <- function(component, fileName, width){
    pngName <- paste0(fileName,".png")
    htmlName <- paste0(fileName,".html")
    
    save_html(component, htmlName)
    webshot(htmlName, pngName, vwidth =width, vheight =20)
    image_read(pngName)
}



