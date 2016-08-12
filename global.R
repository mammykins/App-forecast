#Read in the data and get the libraries

set.seed(1337)
#LIBRARY - check if packages are installed and load them
library(dplyr)
library(zoo)
library(forecast)
library(lubridate)
library(dygraphs)
library(ZRA)
library(xtable)


# DATA --------------------------------------------------------------------
#READ DATA
#  this data needs to be up-to-date to the most recent quarters
#  For TPI older time points may need to be changed as the BCIS fix
#  the data after they receive a sample size of 30 or so,
#  or after 18 months generally, this means we are forecasting off
#  of their forecasts
ukdata <- paste("master_data", ".csv", sep = "")  #  file should be located in wd
if ( all(list.files() != ukdata))  warning('You are in the wrong folder or the desired file does not exist in the current working folder!')
ukdata <- read.csv(ukdata,
                   header = TRUE)  # in tidy dataframe format, one row per observation

# SOURCES -----------------------------------------------------------------
#  TPI   UK BCIS subscription, Adam Bray or Vicky Brooks
#  RPIX  https://www.ons.gov.uk/economy/inflationandpriceindices/timeseries/chmk/mm23
#  CPI All-Items Index  https://www.ons.gov.uk/economy/inflationandpriceindices/timeseries/d7bt/mm23
#  GDP  ... can't find quarterly easy access, ask Adam Bray

# DATE --------------------------------------------------------------------
#TODAY's DATE
todays_yr_qtr <- as.yearqtr(as.Date(x = today(), format = "%Y-%m-%d"))


# CUSTOM FUN --------------------------------------------------------------
#INFLATION, relative to base Quarter, use todays_yr_qtr if most contemporary
inflation <- function(base_year_value, forecasted_point_estimates) {

inflation_percentage <- round(x = ((forecasted_point_estimates - base_year_value) / base_year_value) * 100,
                              digits = 2)
return(inflation_percentage)
}

zoo.to.data.frame <- function(x, index.name="Date") {
  stopifnot(is.zoo(x))
  xn <- if( is.null(dim(x)) ) deparse(substitute(x)) else colnames(x)
  setNames(data.frame(index(x), x, row.names = NULL), c(index.name,xn))
}

#ZRA custom
#  changed startvalue <- end(data) + 1 due to quarterly data
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
