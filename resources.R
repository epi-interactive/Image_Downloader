g_getDownloadIcon <- list(icon("image", lib = "font-awesome"),"Export PNG")

getIncidenceChartData <- function(toggle){
    return(plotly)
}

#export functions
g_getImageFileName <- function(title){
    paste0(title,"_",format(Sys.time(),"%Y%m%d%H%M"), '.png', sep='')
}

getPlot <- function(data, width, height){
    orca(data, "temp.png", width = width, height = height)
}

#title is string
g_getImageDownloader <- function(data, file, title ="", width=800, height=450){
    cssPath <- paste0(getwd(),"/www/css/download.css")
    
    header <- tagList(
        includeCSS(cssPath),
        div(p(class="img-download-chart-heading", tags$span(title)))
    )
    
    imgPath <- paste0("file:///",getwd(),"/www/images/Epi_logo.png")
    
    date <- tagList(
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
    
    save_html(header, "header.html")
    webshot("header.html", "header.png", vwidth =width, vheight =20)
    header <- image_read("header.png")

    save_html(date, "date.html")
    webshot("date.html", "date.png", vwidth =width, vheight =20)
    footer <- image_read("date.png")
    
    if(!is.null(data)){
        getPlot(data, width, height)
        plot <- image_read("temp.png")
        allComponents <- c(header,  plot, footer)
    }
    
    setwd(oldwd)
    side_by_side = image_append(allComponents, stack=T)
    
    image_write(side_by_side, file, format = "png")
}