library(shiny)

#  Define server logic required to draw figure
#  initialisation of server.R
shinyServer(function(input, output) {
  
  output$plot_zra <- renderDygraph({
    #reactive()#h <- input$h
    #confidence_levels <- input$confidence_levels
    #voi <- input$voi
    
    max_forecast <- todays_yr_qtr + input$h / 4  #  four quarters in a year
    
        #SELECT DATA
    #  Convert the date into quarterly zoo class, assign the voi data to variable_of_interest,
    #  then remove any forecasts in the data, then omit NA.
    df <- data.frame(thedate = as.yearqtr(ukdata$date, format = "%b-%y"),
                     variable_of_interest = ukdata[, input$voi],
                     stringsAsFactors = FALSE) %>%
      filter(thedate < todays_yr_qtr) %>%
      na.omit()
    
    #  We convert into zoo (due to our using the as.yearqtr funciton earlier)
    #  Then back into ts (as ZRA does not accept ts)
    z <- zoo(x = df$variable_of_interest, order.by = df$thedate)  #  i prefer reading as zoo as it explicitly indexes the date, useful for spotting a gap in the dates or other errors
    
    ukdata_ts <- as.ts(z)
    
    #PLOT
    zra <- ZRA(ukdata_ts, FP = input$h, SL = input$confidence_levels)
    
   
    plot(zra)  #  What is the default forecast? Depends on the class of the object, default for ts is ETS. See ?forecast
    #  We did all that work, ashame not to use ARIMA for TPI
    #  However, this ZRA package is useful starting point and ETS may be better default
    #  Assume the forecast package knows more than we do.

  })
  # Generate a summary of the forecast (inefficient adn time consuming as repeated)
  output$summary <- renderPrint({
    max_forecast <- todays_yr_qtr + input$h / 4 
    df <- data.frame(thedate = as.yearqtr(ukdata$date, format = "%b-%y"),
                     variable_of_interest = ukdata[, input$voi],
                     stringsAsFactors = FALSE) %>%
      filter(thedate < todays_yr_qtr) %>%
      na.omit()
    z <- zoo(x = df$variable_of_interest, order.by = df$thedate)  
    ukdata_ts <- as.ts(z)
    zra <- ZRA(ukdata_ts, FP = input$h, SL = input$confidence_levels)
    
    print(zra)
    
  })
  
  output$inflation <- renderPrint({
    max_forecast <- todays_yr_qtr + input$h / 4 
    df <- data.frame(thedate = as.yearqtr(ukdata$date, format = "%b-%y"),
                     variable_of_interest = ukdata[, input$voi],
                     stringsAsFactors = FALSE) %>%
      filter(thedate < todays_yr_qtr) %>%
      na.omit()
    z <- zoo(x = df$variable_of_interest, order.by = df$thedate)  
    ukdata_ts <- as.ts(z)
    zra <- ZRA(ukdata_ts, FP = input$h, SL = input$confidence_levels)
    
    print(inflation(tail(ukdata_ts, 1), zra$fit1))  # Inflation percentage against current quarter as base value
    
  })
  
})
