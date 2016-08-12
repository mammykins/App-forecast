#  TITLE: FORECASTING APP FOR Educaiton Funding Agency
#  PURPOSE: forecasting using standard time series methods a range of 
#  commonly used indices used by the EFA to assist in predicitng future costs and or
#  uncertainity about such costs.
#  TOOL: we use the dygraphs package based on the javascript dygraphs charts plotting.
#  http://rstudio.github.io/dygraphs/
#  We start off with a minimal viable product forecastign using ARIMA and or ETS for
#  the commonly used indices, with the aim of adding more later. We' put together the code to
#  plot here and then build it into a shiny app later.
#  DATE: 29/06/2016


#SETUP
rm(list = ls()) #  clear workspace
set.seed(1337)
#LIBRARY - check if packages are installed and load them
library(dplyr)
library(zoo)
library(forecast)
library(lubridate)
library(dygraphs)
library(ZRA)  #  handle forecast objects with dygraphs

#INPUTS
h <- 8  #  the forecast horizon, predicting h quarters into the future
confidence_levels <- c(80, 95)  #  default 80 and 95% confidence intervals, can change here
wd <- "C://Users//mammykins//Documents/GitHub/App-forecast"  #  the working directory, the address of the relevant input file or raw data on your computer, note the // separation.
todays_yr_qtr <- as.yearqtr(as.Date(x = today(), format = "%Y-%m-%d"))  #  what is the date, year and quarter? This can be manually adjusted to reproduce early forecasts.

voi <- "cpi"  #  variable of interest, SHINY input name
######################
######################
# ----
#SETUP
setwd(wd)

#READ DATA
ukdata <- paste("master_data", ".csv", sep = "")  #  file should be located in wd
if ( all(list.files() != ukdata))  warning('You are in the wrong folder or the desired file does not exist in the current working folder!')
ukdata <- read.csv(ukdata,
                   header = TRUE)  # in tidy dataframe format, one row per observation

if ( any(is.na(tail(ukdata)) )) warning('There are some missing values in the data, check the csv.file for blank spaces or columns. Check the data is up-to-date, gaps are problematic, if found this tool should not be used.')



# SELECT DATA -------------------------------------------------------------
ukdata_ts <- ts(data = ukdata[, voi], end = todays_yr_qtr, frequency = 4) %>%
  na.omit()  #  problematic if there are gaps in your data!


# CUSTOM ZRA --------------------------------------------------------------

zra_custom <- function(data, FP = 10, SL = c(0.8, 0.95), ...) 
{
  startvalue <- end(data) + 0.25
  f <- frequency(data)
  d <- data
  if (is.ts(d) == TRUE) {
    if (is.matrix(d) == TRUE) {
      result <- NULL
      stop("Only 1 Time Series can analyzed at once")
    }
    else {
      prognose <- forecast(d, h = FP, level = SL, ...)
      result <- list()
      result$series <- data
      result$SL <- SL
      result$FP <- FP
      if (length(SL) == 1) {
        up1 <- ts(prognose$upper[, 1], start = startvalue, 
                  frequency = f)
        low1 <- ts(prognose$lower[, 1], start = startvalue, 
                   frequency = f)
        fit1 <- (up1 + low1)/2
        result$up1 <- up1
        result$low1 <- low1
        result$fit1 <- fit1
        result$piv1 <- cbind(fit1, up1, low1)
      }
      if (length(SL) == 2) {
        up1 <- ts(prognose$upper[, 1], start = startvalue, 
                  frequency = f)
        low1 <- ts(prognose$lower[, 1], start = startvalue, 
                   frequency = f)
        fit1 <- (up1 + low1)/2
        up2 <- ts(prognose$upper[, 2], start = startvalue, 
                  frequency = f)
        low2 <- ts(prognose$lower[, 2], start = startvalue, 
                   frequency = f)
        fit2 <- (up2 + low2)/2
        result$up1 <- up1
        result$low1 <- low1
        result$fit1 <- fit1
        result$piv1 <- cbind(fit1, up1, low1)
        result$up2 <- up2
        result$low2 <- low2
        result$fit2 <- fit2
        result$piv2 <- cbind(fit2, up2, low2)
      }
      if (length(SL) != 1 & length(SL) != 2) {
        stop("Only 2 Significance levels can be plotted at once.")
      }
    }
  }
  else {
    result <- NULL
    stop("Data have to be a Time Series Obejct, with the Class ts.")
  }
  class(result) <- "ZRA"
  return(result)
}
# CUSTOM FUN --------------------------------------------------------------
#INFLATION, relative to base Quarter, use todays_yr_qtr if most contemporary
inflation <- function(base_year_value, forecasted_point_estimates) {
  
  inflation_percentage <- round(x = ((forecasted_point_estimates - base_year_value) / base_year_value) * 100,
                                digits = 2)
  return(inflation_percentage)
}

# PLOT --------------------------------------------------------------------


zra <- zra_custom(ukdata_ts, FP = h, SL = confidence_levels)
#  gap bug caused by startvalue <- end(data)[1] + 1, should be 0.25 for quarterly

plot(zra)  #  What is the default forecast? Depends on the class of the object, default for ts is ETS. See ?forecast
#  We did all that work, ashame not to use ARIMA for TPI
#  However, this ZRA package is useful starting point and ETS may be better default
#  Assume the forecast package knows more than we do.
#  We can use zra_custom to edit if necessary.


# MAKE DATAFRAME FOR pretty table -----------------------------------------

pred_inflation <- inflation(tail(zra$series, 1), zra$fit1)

pred_inflation <- pred_inflation %>%
  zooreg(frequency = 4, start = end(zra$series) + 0.25) %>%
  xtable(digits = 2)


 

