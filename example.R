# pkg required

library("geosphere")
library("XML")
library("readODS")
library("dplyr")
library("reshape2")
library("data.table")
library("ggplot2")
library("magrittr")

# example
m <- mrt(begin    = 201501,
         end      = 201509,
         location = "/Users/liuyuyou/Desktop/MRT",
         radius   = 2)

# pure data
b <- mrtp(begin    = 201501,
          end      = 202212,
          location = "/Users/oliverliou/Desktop")
b <- b[b$date == "2022-09-03",]

# plotting
plot(b, out = T) # 想看建站或出站

g <- b[b$station_name == "公館"  & b$type == 1,]
write.csv(g,"/Users/liuyuyou/Desktop/MRT/gon.csv")