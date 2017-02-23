if (!require("shiny")) {
  install.packages("shiny")
  require("shiny")
}

#  Define User Interface that has sidebar with numeric input and model plot
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Portender App"),
  
  # Sidebar with a slider input for the forecast horizon and drop down selection for voi
  sidebarLayout(
    sidebarPanel(
      h2("Forecasting time series"),
      p("This app forecasts different types of inflation pertinent to the construction industry.
        This allows informed budgeting by considering future costs of projects based on relevant
        predicted inflation indices. The Tender Price Index (TPI) affects the cost of a building
        with the Retail Price Index (RPIX) and Consumer Price Index (CPI) affecting other components
        of a social infrastructure construction project, such as costs of; furniture, fixtures and fittings.",
        style = "font-family: 'times'; font-si16pt"),
      #br(),
      # p("CAVEAT: this forecasting method is inappropriate during a recession."),
      #br(),
      h4("User input"),
                 #br(),
                 p("Choose the parameters for your custom forecast."),
                 #br(),
                 #  Build type selection
                 selectInput(inputId = "voi", label = "Select variable of interest:",
                             choices = c("UK BCIS Tender Price Index" = "tpi", 
                               "Retail Price Index X" = "rpix",
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
                 #br(),
                 sliderInput("confidence_levels", label = "Prediction Intervals",
                             min = 0.50, max = 0.99,
                             value = c(0.80, 0.95)),
                 #br(),
      
      #checkboxInput("legend", label = "Disable legend", value = "never"),
                 numericInput(inputId = "monies", label = "Capital Budget (if relevant)", value = 100,
                            min = 0, max = NA, step = NA, width = NULL),
                 #br(),
                 submitButton("Forecast"),
                 br(),
                 img(src = "efa_logo.png", height = 144, width = 144),
                 br(),
                 br(),
                 "Developed by ",
                 span("Dr Matthew Gregory.", style = "color:blue"),
                 br(),
                 h6("Data sources: ",
                    a(href = "https://www.gov.uk/government/statistics/bis-prices-and-cost-indices", "TPI"),
                    a(href = "https://www.ons.gov.uk/economy/inflationandpriceindices/timeseries/chmk/mm23", "RPIX"),
                    a(href = "https://www.ons.gov.uk/economy/inflationandpriceindices/timeseries/d7bt/mm23", "CPI"),
                    a(href = "https://www.ons.gov.uk/economy/grossdomesticproductgdp/bulletins/grossdomesticproductpreliminaryestimate/aprtojune2016", "GDP"),
                    a(href = "https://en.wikipedia.org/wiki/List_of_recessions_in_the_United_Kingdom", "Recessions")
                    ),
                  h6("Code: ", a(href = "https://github.com/mammykins/App-forecast", "Github"))
                 
    ),
    
    # Show a plot of the time series using forecast, dygraphs and zra to combine the two
    mainPanel(
      h4("Time series and forecast using ", a(href = "https://www.otexts.org/fpp/7", "exponential smoothing methods.")),
      dygraphOutput("plot_zra"),
      hr(),
      br(),
      h4("Percentage inflation of forecast values relative to the most recent Quarter's value through the forecast horizon:"),
      tableOutput("inflation"),
      h4("New total for the Capital Budget after inflation:"),
      tableOutput("budget"),
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