library(shiny)

#  initialisation of server.R
shinyServer(function(input, output) {
  
  #REACTIVE
  #  prevent Shiny from re-running unnecessary code
  #  Note how we assign the reactive to dataInput
  #  then when we call it later we use dataInput(), else error
  #  see ?forecast for default method, mostly will be ETS for this time series type
  dataInput <- reactive({ts(data = ukdata[, input$voi], end = todays_yr_qtr, frequency = 4) %>%
      na.omit() %>%  #  make quarterly time series, forecast, create zra class
      zra_custom(FP = input$h, SL = input$confidence_levels)
  })
  
  
  output$plot_zra <- renderDygraph({
    
   
    plot(dataInput()) %>% 
      dyLegend(show = "onmouseover", hideOnMouseOut = TRUE,
               width = 500, labelsSeparateLines = FALSE)
    #  We did all that work, ashame not to use ARIMA for TPI, add check box later
    #  However, this ZRA package is useful starting point and ETS may be better default
    #  Assume Hyndman's forecast package knows more than we do.

  })

    output$summary <- renderTable({
      
    #http://stackoverflow.com/questions/26507806/display-xtable-in-shiny
    xtable(as.zooreg(dataInput()$piv1))

  })
  
  output$summary2 <- renderTable({
    
    zra <- zra_custom(ukdata_ts, FP = input$h, SL = input$confidence_levels)
    
    #http://stackoverflow.com/questions/26507806/display-xtable-in-shiny
    xtable(as.zooreg(dataInput()$piv2))
    
  })
  
  output$inflation <- renderPrint({
    
    pred_inflation <- inflation(tail(ukdata_ts, 1), dataInput()$fit1)
    
    pred_inflation %>%
      zooreg(frequency = 4, start = end(ukdata_ts) + 0.25) %>%
      #gsub(pattern = "(", replacement = " Q ", fixed = TRUE) %>%
      print()
    
   # paste("The predicted value of your monies is ",
    #  input$monies + ((input$monies/100)*pred_inflation) %>%
    #  zooreg(frequency = 4, start = end(ukdata_ts) + 0.25) %>%
     # print)
  })
  
#  http://shiny.rstudio.com/articles/download.html
  
})
