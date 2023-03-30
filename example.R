# pkg required
library("readODS")
library("dplyr")
library("reshape2")
library("data.table")
library("ggplot2")
library("magrittr")
library("hydroTSM")

# generate station-date data
b <- mrtp(begin = 202101, end = 202212, location = "/Users/oliverliou/Desktop")

# plotting
plot(b, out = T)

# generate a time series data
c <- td(b)

# forecasting by a fixed proportion
pd(c,.9)
