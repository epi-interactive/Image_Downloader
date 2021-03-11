# Image Extractor
Sometimes you will want to control the images users take of your graphs. This can be beneficial if you would like to include information on the subject of the graph, append a legend or include watermarks/logos etc. This image extractor example provides the ability to customise the output of graph screenshots.

You can try out the app [here](https://rshiny.epi-interactive.com/apps/image_downloader/)


# How it works
Add in the download anchor for the graph.
```r
mainPanel(
    plotlyOutput("plot_output"),
    downloadLink(
        outputId = "export_image_download",
        label = g_getDownloadIcon
    )
)
```

Create an output listener thats builds the file name and file content.
```r
output$export_image_download <- downloadHandler(
    filename = function () {
        g_getImageFileName("image_download")
    },
    content = function(file) {
        heading <- "Populations of NZ - Age/Sex distribution"
        g_getImageDownloader(getChart(), file, heading)
    }
)
```

Set exported image filename
```r
g_getImageFileName <- function(title){
    paste0(title,"_",format(Sys.time(),"%Y%m%d%H%M"), '.png', sep='')
}
```

Create additional elements to add to the graph, in this case a title and watermark.
```r
header <- tagList(
    includeCSS(cssPath),
    div(p(class="img-download-chart-heading", tags$span(title)))
)

logo <- image_read("www/images/Epi_logo.png")

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
    


 save_html(header, "header.html")
    webshot("header.html", "header.png", vwidth =width, vheight =20)
    footer <- image_read("header.png")

    save_html(date, "date.html")
    webshot("date.html", "date.png", vwidth =width, vheight =20)
    footer <- image_read("date.png")
```

Get image components in the order you want them appended to one another.
```r
getPlot(data, width, height)
plot <- image_read("temp.png")
allCompenents <- c(header,  plot, footer)
```

Use the orca library to create a PNG from the plotly object.
```r
getPlot <- function(data, width, height){
    orca(data, "temp.png", width = width, height = height)
}
```

Put image together and write out to download function, the stack option casues the elements to be placed vertically instead of horizontally.
```r
side_by_side = image_append(allCompenents, stack=T)
    
image_write(side_by_side, file, format = "png")
```

This CSS selector allows you to control the placement of all of your image download buttons.
```css
a[id*="_export_image_download"] {
    float: right;
}
```

*Data obtained from [Stats NZ.](https://www.stats.govt.nz/tools/2018-census-place-summaries/new-zealand#more-data-and-information)*