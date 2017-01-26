# App-forecast
Time series forecasting for common inflators and economic indices using the forecast package in R.

https://mammykins.shinyapps.io/App-forecast/

#  Purpose
Forecasting using standard time series methods a range of commonly used indices used by the EFA to assist in predicitng future costs and or
uncertainity about such costs.

#  Tools and packages
we use the dygraphs package based on the javascript dygraphs charts plotting. Shiny is used for extra funcitonality. The ZRA package helped in combining all these tools.

#  Development plan
We start off with a minimal viable product forecasting using the default of the forecast function in Rob Hyndman's forecast package.
The default is ETS for the commonly used indices, we intend to add ARIMA functionality and additional data later.

#  References
http://rstudio.github.io/dygraphs/
https://www.otexts.org/fpp
