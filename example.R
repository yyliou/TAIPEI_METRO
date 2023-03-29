# pkg required
library("readODS")
library("dplyr")
library("reshape2")
library("data.table")
library("ggplot2")
library("magrittr")

# example
b <- mrtp(begin    = 202101,
          end      = 202212,
          location = "/Users/oliverliou/Desktop")
b <- b[b$date == "2022-09-03",]

# plotting
plot(b, out = T)
