##################################
# Created by EPI-interactive
# 12 Mar 2021
# https://www.epi-interactive.com
##################################

library(shiny)
library(shinyjs)
library(plotly)
library(magick)
library(htmltools)
library(webshot)

source("resources.R")

censusData <- read.csv("www/census-data.csv", encoding = "UTF-8")

ui <- fluidPage(
    tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "css/style.css"),
        tags$link(rel = "stylesheet", type = "text/css", href = "css/download.css"),
        tags$link(rel = "stylesheet", type = "text/css", href = "css/nprogress.css"),
        tags$script(src = "js/main.js"),
        tags$script(src = "js/nprogress.js"),
        ),
    div(class="col-xs-3 sidebar",
        div(
            h1("Image Downloader"),
            hr(),
            selectInput("ethnicity", 
                      label = "Ethnicity",
                      choices = censusData["Eth.name"], 
                      selected = "White")
        ),
        tags$img(src="images/Powered_Epi_Logo.png", width= "90%")
    ),   
    div(class="col-xs-9 main",
          plotlyOutput("plot_output", height="550px"),
          downloadLink(
              outputId = "nz_eth_export_image_download",
              label = g_getDownloadIcon
          )
      )
)

server <- function(input, output) {
    if (is.null(suppressMessages(webshot:::find_phantom()))) { webshot::install_phantomjs() }

    getChart <- function() {
        x <- list(type = 'category', 
                  categoryorder = "array", 
                  categoryarray = c("0-4 years", "5-9 years", "10-14 years", "15-19 years", "20-24 years", 
                                     "25-29 years", "30-34 years", "35-39 years", "40-44 years", "45-49 years", 
                                     "50-54 years", "55-59 years", "60-64 years", "65-69 years", "70-74 years", 
                                     "75-79 years", "80-84 years", "85 years and over"), 
                  title = "Age Bracket",
                  tickangle = 75
        )
        l <- list(orientation = 'h',
                  x = 1, 
                  y = 1.1,
                  xanchor = "right",
                  yanchor = "bottom"
        )
        t <- list(text  = paste0("<b>",input$ethnicity, " Age Brackets in NZ</b>"), xanchor = "left", x = 0)
        
        
        plot_ly(type = 'bar',) %>%
            add_trace(data = subset(censusData, subset = (Eth.name == input$ethnicity & Sex.no == 1 & percent.of.Total != 100)),
                    x = ~Age.bracket, 
                    y = ~Total,  
                    name = 'Male',
                    marker = list(color = "#01515E")
             ) %>% 
             add_trace(data = subset(censusData, subset = (Eth.name == input$ethnicity & Sex.no == 2 & percent.of.Total != 100)),
                  y = ~Total, 
                  x = ~Age.bracket,
                  name = 'Female',
                  marker = list(color = "#91C61E")
             ) %>% 
             layout(title = t,
                    yaxis = list(title = 'Total'), 
                    xaxis = x,  
                    barmode = 'group',
                    legend = l
             ) %>% 
             config(displayModeBar = FALSE)
    }
    
    output$plot_output <- renderPlotly({
        getChart()
    })
    
    output$nz_eth_export_image_download <- downloadHandler(
        filename = function () {
            g_getImageFileName("image_download")
        },
        content = function(file) {
            heading <- "Populations of NZ - Age/Sex distribution"
            g_getImageDownloader(getChart(), file, heading)
        }
    )
}

shinyApp(ui, server)




