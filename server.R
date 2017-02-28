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
               width = 500, labelsSeparateLines = FALSE) %>%
      dyShading(from = "2008-4-1", to = "2009-4-1") %>%  #  Great Recession
       dyEvent("2008-4-1", "Great Recession", labelLoc = "bottom", color = "black") %>%
      #dyAnnotation("2008-4-1", text = "C", tooltip = "Great Recession") %>%
      dyShading(from = "1990-7-1", to = "1991-7-1") %>%  #  Early 90s recession
       dyEvent("1990-7-1", "Early '90s recession", labelLoc = "bottom", color = "black") %>%
      dyShading(from = "1980-1-1", to = "1981-1-1") %>%  #  Early 80s recession
       dyEvent("1980-1-1", "Early '80s recession", labelLoc = "bottom", color = "black") %>%
      dyEvent("2016-6-1", "Brexit", labelLoc = "bottom", color = "black")
      
      
    #  https://en.wikipedia.org/wiki/List_of_recessions_in_the_United_Kingdom
    #  We did all that work, ashame not to use ARIMA for TPI, add check box later
    #  However, this ZRA package is useful starting point and ETS may be better default
    #  Assume Hyndman's forecast package knows more than we do.

  })

    output$summary <- renderTable({
      
    #http://stackoverflow.com/questions/26507806/display-xtable-in-shiny
    xtable(as.zooreg(dataInput()$piv1))

  })
  
  output$summary2 <- renderTable({
    
    
    #http://stackoverflow.com/questions/26507806/display-xtable-in-shiny
    xtable(as.zooreg(dataInput()$piv2))
    
  })
  
  output$inflation <- renderTable({
    
    pred_inflation <- inflation(tail(dataInput()$series, 1)[1], dataInput()$fit1[1:input$h])
    
    pred_inflation %>%
      zooreg(frequency = 4, start = end(dataInput()$series) + 0.25) %>%
      #gsub(pattern = "(", replacement = " Q ", fixed = TRUE) %>%
      xtable()
    
   # paste("The predicted value of your monies is ",
    #  input$monies + ((input$monies/100)*pred_inflation) %>%
    #  zooreg(frequency = 4, start = end(ukdata_ts) + 0.25) %>%
     # print)
  })
  
  output$budget <- renderTable({
    
    pred_inflation <- inflation(tail(dataInput()$series, 1)[1], dataInput()$fit1[1:input$h])
    
    pred_inflation <- pred_inflation %>%
      zooreg(frequency = 4, start = end(dataInput()$series) + 0.25)  
      #gsub(pattern = "(", replacement = " Q ", fixed = TRUE) %>%
      #print()
    
    # paste("The predicted value of your monies is ",
    input$monies + ((input$monies/100)*pred_inflation) %>%
      zooreg(frequency = 4, start = end(dataInput()$series) + 0.25) %>%
      xtable()
  })
  
#  http://shiny.rstudio.com/articles/download.html
  
})
