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
wd <- "C://Users//mammykins//Google Drive//R//tpi/App-forecast"  #  the working directory, the address of the relevant input file or raw data on your computer, note the // separation.
todays_yr_qtr <- as.yearqtr(as.Date(x = today(), format = "%Y-%m-%d"))  #  what is the date, year and quarter? This can be manually adjusted to reproduce early forecasts.

voi <- "tpi"  #  variable of interest, SHINY input name
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

if ( any(is.na(ukdata)) ) warning('There are some missing values in the data, check the csv.file for blank spaces or columns. Check the data is up-to-date.')

#SELECT DATA
#  Convert the date into quarterly zoo class, assign the voi data to variable_of_interest,
#  then remove any forecasts in the data, then omit NA.
df <- data.frame(thedate = as.yearqtr(ukdata$date, format = "%b-%y"),
                 variable_of_interest = ukdata[, voi],
                 stringsAsFactors = FALSE) %>%
  filter(thedate < todays_yr_qtr) %>%
  na.omit()

#  We convert into zoo (due to our using the as.yearqtr funciton earlier)
#  Then back into ts (as ZRA does not accept ts)
z <- zoo(x = df$variable_of_interest, order.by = df$thedate)  #  i prefer reading as zoo as it explicitly indexes the date, useful for spotting a gap in the dates or other errors

ukdata_ts <- as.ts(z)

#PLOT
zra <- ZRA(ukdata_ts, FP = h, SL = confidence_levels)
plot(zra)  #  What is the default forecast? Depends on the class of the object, default for ts is ETS. See ?forecast
#  We did all that work, ashame not to use ARIMA for TPI
#  However, this ZRA package is useful starting point and ETS may be better default
#  Assume the forecast package knows more than we do.