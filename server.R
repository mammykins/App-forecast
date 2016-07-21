library(shiny)

#  Define server logic required to draw figure
#  initialisation of server.R
shinyServer(function(input, output) {
  
  output$plot_zra <- renderDygraph({
    #reactive()#h <- input$h
    #confidence_levels <- input$confidence_levels
    #voi <- input$voi
    
    #SELECT DATA
    ukdata_ts <- ts(data = ukdata[, input$voi], end = todays_yr_qtr, frequency = 4) %>%
      na.omit()  #  problematic if there are gaps in your data!
    
    #PLOT
    zra <- zra_custom(ukdata_ts, FP = input$h, SL = input$confidence_levels)
    #  gap bug caused by startvalue <- end(data)[1] + 1, should be 0.25 for quarterly
    
    plot(zra) %>% #  What is the default forecast? Depends on the class of the object, default for ts is ETS. See ?forecast
      dyLegend(show = "onmouseover", hideOnMouseOut = TRUE,
               width = 500, labelsSeparateLines = FALSE)
      #  We did all that work, ashame not to use ARIMA for TPI
    #  However, this ZRA package is useful starting point and ETS may be better default
    #  Assume the forecast package knows more than we do.

  })
  # Generate a summary of the forecast (inefficient and time consuming as repeated)
  output$summary <- renderTable({
    
    max_forecast <- todays_yr_qtr + input$h / 4 
    ukdata_ts <- ts(data = ukdata[, input$voi],
                    end = todays_yr_qtr, frequency = 4) %>%
      na.omit()
    
    zra <- zra_custom(ukdata_ts, FP = input$h, SL = input$confidence_levels)
    
    #http://stackoverflow.com/questions/26507806/display-xtable-in-shiny
    
    #xtable((as.zoo(zra$series)))
    #print(tail(zra$series))
    xtable(as.zooreg(zra$piv1))
    #xtable(as.zooreg(zra$piv2))
    
    
  })
  
  output$summary2 <- renderTable({
    
    max_forecast <- todays_yr_qtr + input$h / 4 
    ukdata_ts <- ts(data = ukdata[, input$voi],
                    end = todays_yr_qtr, frequency = 4) %>%
      na.omit()
    
    zra <- zra_custom(ukdata_ts, FP = input$h, SL = input$confidence_levels)
    
    #http://stackoverflow.com/questions/26507806/display-xtable-in-shiny
    
    #xtable((as.zoo(zra$series)))
    #print(tail(zra$series))
    #xtable(as.zooreg(zra$piv1))
    xtable(as.zooreg(zra$piv2))
    
    
  })
  
  output$inflation <- renderPrint({
    
    max_forecast <- todays_yr_qtr + input$h / 4 
    ukdata_ts <- ts(data = ukdata[, input$voi], end = todays_yr_qtr, frequency = 4) %>%
      na.omit()
    
    zra <- zra_custom(ukdata_ts, FP = input$h, SL = input$confidence_levels)
    
    pred_inflation <- inflation(tail(ukdata_ts, 1), zra$fit1)
    print(pred_inflation)  # Inflation percentage against current quarter as base value
    
  })
  

  
})
