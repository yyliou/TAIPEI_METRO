# pkg required
library("readODS")
library("dplyr")
library("reshape2")
library("data.table")
library("ggplot2")
library("magrittr")
library("hydroTSM")

# generate station-date data
b <- mrtp(begin = 201801, end = 202212, location = "/Users/oliverliou/Desktop")

ls(b)
test <- b[b$type == 1,]
test$lnf <- log(test$flow)
model <- lm(lnf ~ year + season + month + week + day + ny + cny +
              branch + branch_trans + high +
              hot + lrt + main_trans + node + rail +
              covid_2 + covid_3 + ticket, data = test)
summary(model)

# plotting
plot(b)

# generate a time series data
c <- td(b)

# forecasting by a fixed proportion
pd(c,.9)
