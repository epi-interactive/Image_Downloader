library(shiny)
library(shinyjs)
library(plotly)
library(magick)
library(htmltools)
library(webshot)
library(orca)

source("resources.R")

censusData <- read.csv("www/census-data.csv", encoding = "UTF-8")

#ns <- session$ns

ui <- fluidPage(
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "css/download.css")),
    titlePanel("Image Extractor"),
    sidebarLayout(position = "right",
                  sidebarPanel(
                      fluidRow(
                          selectInput("ethnicity", label = h3("Ethnicity"),
                                      choices = censusData["Eth.name"], selected = "White")
                      ),
                  ),
                  mainPanel(
                      plotlyOutput("plot_output"),
                      downloadLink(
                          outputId = "nz_eth_export_image_download",
                          label = g_getDownloadIcon
                      )
                  )
    )
    
)

server <- function(input, output) {
    if (is.null(suppressMessages(webshot:::find_phantom()))) { webshot::install_phantomjs() }

    getChart <- function() {
    fig <- plot_ly(subset(censusData, subset = (Eth.name == input$ethnicity & Sex.no == 1 & percent.of.Total != 100)),
                           x = ~Age.bracket, y = ~Total, type = 'bar', name = 'Male')
            fig <- fig %>% add_trace(y = ~Total, name = 'Female', 
                                     data = subset(censusData, subset = (Eth.name == input$ethnicity & Sex.no == 2 & percent.of.Total != 100)))
            fig <- fig %>% layout(title = paste0(input$ethnicity, " Age Brackets in NZ"), yaxis = list(title = 'Total'), xaxis = list(type = 'category', categoryorder = "array", 
                                     categoryarray = c("0-4 years", "5-9 years", "10-14 years", "15-19 years", "20-24 years", 
                                                       "25-29 years", "30-34 years", "35-39 years", "40-44 years", "45-49 years", 
                                                       "50-54 years", "55-59 years", "60-64 years", "65-69 years", "70-74 years", 
                                                       "75-79 years", "80-84 years", "85 years and over"), title = "Age Bracket"),  barmode = 'group')
            fig <- fig %>% config(displayModeBar = FALSE)
            
            return(fig)
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