if (!require("shiny")) {
  install.packages("shiny")
  require("shiny")
}

#  Define User Interface that has sidebar with numeric input and model plot
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Forecasting time series"),
  
  # Sidebar with a slider input for the forecast horizon and drop down selection for voi
  sidebarLayout(
    sidebarPanel(
      h4("User input"),
                 br(),
                 p("Choose the parameters for your custom forecast."),
                 #br(),
                 #  Build type selection
                 selectInput(inputId = "voi", label = "Select variable of interest:",
                             choices = c("UK BCIS Tender Price Index" = "tpi", 
                               "RPIX" = "rpix",
                               "Consumer Price Index" = "cpi",           
                               "Gross Domestic Product" = "gdp")
                             ),
                 #br(),
                 p("The forecast horizon in Quarters."),
                 sliderInput("h",
                             "Forecast Horizon:",
                             min = 0,
                             max = 12,
                             value = 8),
                 br(),
                 sliderInput("confidence_levels", label = "Prediction Intervals",
                             min = 0.50, max = 0.99,
                             value = c(0.80, 0.95)),
      #checkboxInput("legend", label = "Disable legend", value = "never"),
                 #numericInput(inputId = "monies", label = "Monies", value = 100,
                  #            min = 0, max = NA, step = NA, width = NULL),
                 br(),
                 submitButton("Forecast"),
                 br(),
                 img(src = "efa_logo.png", height = 72, width = 72),
                 br(),
                 br(),
                 "Developed by ",
                 span("Dr Matthew Gregory.", style = "color:blue")
                 
    ),
    
    # Show a plot of the time series using forecast, dygraphs and zra to combine the two
    mainPanel(
      h4("Time series and forecast using ", a(href = "https://www.otexts.org/fpp/7", "exponential smoothing methods.")),
      dygraphOutput("plot_zra"),
      hr(),
      br(),
      h4("Percentage inflation of forecast values relative to the most recent Quarter's value:"),
      verbatimTextOutput("inflation"),
      br(),
      h4("Normal forecast point estimates (mean) and prediction intervals (upper and lower) if you anticipate typical market behaviour:"),
      #tags$head( tags$style( HTML('#summary table {border-collapse:collapse; } 
                             #summary table th { transform: rotate(-45deg)}'))),
      tableOutput("summary"),
      br(),
      h4("Conservative forecast intervals if uncertainity is high:"),
      tags$head( tags$style( HTML('#summary2 table {border-collapse:collapse; } 
                                  #summary2 table th { transform: rotate(-45deg)}'))),
      tableOutput("summary2"),
      br(),
      #downloadButton('downloadData', 'Download forecast'),
      tags$blockquote("Prediction is very difficult, especially if it's about the future.", cite = "Nils Bohr")

    )
    
    
  )
  
))